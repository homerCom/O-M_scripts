import json
import logging
import datetime
from flask import Flask, request
import re
import requests

# alertmanager 地址
alertmanager_ip = '45.152.66.111'
alertmanager_port = '9093'

log_path = './alert.log'

# 需要保留小数点后2位并添加%的 报警名称列表
modify_list = [
    'CPUUsage_Linux_Low',
    'CPUUsage_Linux_Medium',
    'CPUUsage_Linux_High',
    'CPUUsage_Windows_Low',
    'CPUUsage_Windows_Medium',
    'CPUUsage_Windows_High',
    'DiskSpace_Linux_Low',
    'DiskSpace_Linux_Medium',
    'DiskSpace_Linux_High',
    'DiskSpace_Windows_Low',
    'DiskSpace_Windows_Medium',
    'Disk_Space_Windows_High',
    'MemoryUsage_Linux_Low',
    'MemoryUsage_Linux_Medium',
    'MemoryUsage_Linux_High',
    'MemoryUsage_Windows_Low',
    'MemoryUsage_Windows_Medium',
    'MemoryUsage_Windows_High',
    'Database_connection',
    'php_fpm_process',
    'CPU_Network_Critical',
    'Mem_Network_Critical',
    'Ssl_Cert_Will_Expire_Low',
    'Web_can_not_access_Critical',
    'Web_Anomaly_response_High',
    'Wan1_traffic_Network_Critical',
    'Wan2_traffic_Network_Critical'
]

alert_names = []

# 开启日志
logging.basicConfig(filename=log_path, level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')

# 实例flask
app = Flask(__name__)


# 将字符串切割并转换为字典
def valueString_splitting(valueString):
    dict_list = []
    pattern = r'\[([^\]]+)\]'
    result = re.findall(pattern, valueString)
    for r in result:
        pattern = r'labels=\{(.+?)\}.*value=(\S+)'
        match = re.search(pattern, r)
        if match:
            labels = match.group(1)
            values = match.group(2)
            values_key = 'value'

            pattern = r'(host|instance|job|relation)=([^,]+)'
            matches = re.findall(pattern, labels)
            label_dict = {}
            for match in matches:
                key = match[0]
                value = match[1]
                label_dict[key] = value
            label_dict.update({values_key: values})
            dict_list.append(label_dict)
    return dict_list


# 根据不同报警，修改value值的格式-保留小数点后2位，根据报警名称确定value值的后缀，“留空”或者”%“或者“ days”
def modify_value(alert_list):
    if alert_list[0]['alertname'] in modify_list and alert_list[0]['status'] == 'firing':
        for original_alert in alert_list:
            value = original_alert['value']
            if '.' not in value:  # 只含有整数部分
                value_modified = value
            else:
                integer_part, decimal_part = value.split('.')
                if decimal_part.startswith('00'):  # 小数部分全为0
                    value_modified = integer_part
                else:
                    decimal_part = decimal_part[:2]  # 小数部分前两位
                    value_modified = integer_part + '.' + decimal_part

            if original_alert['alertname'] == 'Ssl_Cert_Will_Expire_Low':
                value_modified += ' days'
            elif original_alert['alertname'] == 'Web_can_not_access_Critical':
                pass
            elif original_alert['alertname'] == 'Web_Anomaly_response_High':
                value_modified += 's'
            elif 'traffic_Network_Critical' in original_alert['alertname']:
                value_modified += 'M'
            else:
                value_modified += '%'
            original_alert['value'] = value_modified
    return alert_list


# 重新整理切割整合alert
def splitting_alert(alert):
    alert_list = []
    status = alert['status']
    alertname = alert['labels']['alertname']
    severity = alert['labels']['severity']
    summary = alert['annotations']['summary']
    startsAt = alert['startsAt']
    endsAt = alert['endsAt']
    generatorURL = alert['generatorURL']
    fingerprint = alert['fingerprint']

    # 根据消息状态，进行分割
    if status == 'firing':
        valueString = alert['valueString']
        value_lists = valueString_splitting(valueString)
        for tmp_alert in value_lists:
            add_dir = {'status': status, 'alertname': alertname, 'severity': severity, 'summary': summary,
                       'startAt': startsAt, 'endsAt': endsAt, 'generatorURL': generatorURL, 'fingerprint': fingerprint}
            tmp_alert.update(add_dir)
            alert_list.append(tmp_alert)
    elif status == 'resolved':
        add_dir = {'status': status, 'alertname': alertname, 'severity': severity, 'summary': summary,
                   'startAt': startsAt, 'endsAt': endsAt, 'generatorURL': generatorURL, 'fingerprint': fingerprint}
        alert_list.append(add_dir)

    # value值保留小数点后两位
    alert_list = modify_value(alert_list)

    return alert_list


def compare_alert(old_firing, new_firing):
    # 存放相同部分的列表
    firing_list = []
    # 存放不同部分的列表
    resolved_list = []
    # 遍历旧报警中的每个元素
    for old in old_firing:
        for new in new_firing:
            # 如果两个元素instance相同
            if old['instance'] == new['instance']:
                firing_list.append(new)
                break
        else:
            print('old:%s' %old)
            resolved_list.append(old)

    # 遍历新报警列表中的每个元素
    for new in new_firing:
        for item in firing_list:
            # 如果两个元素相同
            if item['instance'] == new['instance']:
                break
        else:
            new_time = datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=8)))  # 加上时区偏移量
            alert_time = new_time.strftime('%Y-%m-%dT%H:%M:%S.%f%z').replace('+0800', '+08:00')
            new['startAt'] = alert_time
            logging.info('New Alert: %s' %new)
            print('New: %s' %new)
            firing_list.append(new)

    # 当前时间设置为resolved时间
    now = datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=8)))  # 加上时区偏移量
    formatted_time = now.strftime('%Y-%m-%dT%H:%M:%S.%f%z').replace('+0800', '+08:00')

    # 将resolved_list中所有报警的状态修改为resolved
    for resoved in resolved_list:
        resoved['status'] = 'resolved'
        resoved['endsAt'] = formatted_time

    return firing_list, resolved_list


# 发送警报给alertmanager，接收参数为报警列表
def send_alert(alert_list):
    for single_alert in alert_list:
        if 'relation' in single_alert:
            alert_data = [
                {
                    "status": single_alert['status'],
                    "labels": {
                        "alertname": single_alert['alertname'],
                        "severity": single_alert['severity'],
                        "host": single_alert['host'],
                        "instance": single_alert['instance'],
                        "job": single_alert['job'],
                        "relation": single_alert['relation']
                    },
                    "annotations": {
                        "summary": single_alert['summary'],
                        "value": single_alert['value'],
                    },
                    "generatorURL": single_alert['generatorURL'],
                    "startsAt": single_alert['startAt'],
                    "endsAt": single_alert['endsAt']
                }
            ]
        else:
            alert_data = [
                {
                    "status": single_alert['status'],
                    "labels": {
                        "alertname": single_alert['alertname'],
                        "severity": single_alert['severity'],
                        "host": single_alert['host'],
                        "job": single_alert['job'],
                        "instance": single_alert['instance']
                    },
                    "annotations": {
                        "summary": single_alert['summary'],
                        "value": single_alert['value'],
                    },
                    "generatorURL": single_alert['generatorURL'],
                    "startsAt": single_alert['startAt'],
                    "endsAt": single_alert['endsAt']
                }
            ]

        alertmanager_url = 'http://%s:%s/api/v1/alerts' %(alertmanager_ip, alertmanager_port)
        headers = {"Content-Type": "application/json"}
        try:
            response = requests.post(alertmanager_url, headers=headers, data=json.dumps(alert_data))
            logging.info("Sending to alertmanager: %s" %alert_data)
            print('status: %s' %response.status_code)
            logging.info('status: %s' %response.status_code)
        except requests.exceptions.RequestException as e:
            print("An error occurred: %s" %e)
            logging.info("An error occurred: %s" %e)


# 传入报警，
def alert_matched_send(alert, existing_alert):
    # 非首次发出报警
    if existing_alert:
        # 非首次报警，并且是报警解除消息
        if alert[0]['status'] == 'resolved':
            tmp = []
            for tmp_alert in existing_alert:
                tmp_alert['status'] = 'resolved'
                tmp_alert['endsAt'] = alert[0]['endsAt']
                tmp.append(tmp_alert)
            existing_alert = tmp
            send_alert(existing_alert)
            print("%s: All resolved" %existing_alert[0]['alertname'])
            logging.info("%s: All resolved" %existing_alert[0]['alertname'])
            # 全部解决，清空警报列表
            existing_alert.clear()
        # 非首次报警，并且是报警消息
        elif alert[0]['status'] == 'firing':
            firing_list, resolved_list = compare_alert(existing_alert, alert)
            existing_alert = firing_list
            # 发送报警消息
            send_alert(existing_alert)
            # 发送解决消息
            if resolved_list:
                send_alert(resolved_list)
            print("%s: Not first firing" %existing_alert[0]['alertname'])
            logging.info("%s: Not first firing" %existing_alert[0]['alertname'])
    # 首次报警
    else:
        if alert[0]['status'] == 'firing':
            existing_alert = alert
            send_alert(existing_alert)
            print("%s: First firing" %existing_alert[0]['alertname'])
            logging.info("%s: First firing" %existing_alert[0]['alertname'])
        elif alert[0]['status'] == 'resolved':
            pass

    return existing_alert

@app.route('/webhook', methods=['POST'])
def webhook():
    grafana_data = json.loads(request.data)
    print(grafana_data)
    logging.info('Receive from grafana: %s' %grafana_data)
    # 每个alert代表一个类型的报警，如MemoryUsage_Linux_Low
    for alert in grafana_data['alerts']:
        # 切割原始报警消息，存入alert列表
        alert = splitting_alert(alert)
        alertname = alert[0]['alertname']
        if alertname in alert_names:
            globals()[str(alertname)] = alert_matched_send(alert, globals()[str(alertname)])
        else:
            alert_names.append(alertname)
            globals()[str(alertname)] = []
            globals()[str(alertname)] = alert_matched_send(alert, globals()[str(alertname)])
    return 'Alert OK', 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port='5001', debug=False)