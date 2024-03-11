# 发送字段：labels，annotations，startsAt，endsAt，generatorURL
import json
import logging
import datetime
from flask import Flask, request
# from gevent.pywsgi import WSGIServer
import re
import requests

# 禁用开发服务器警告信息
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

CPUUsage_Linux_Low_Current = []

app = Flask(__name__)


# 将字符串切割并转换为字典
def valueString_splitting(valueString):
    match = re.findall(r'\[([^]]+)\]', valueString)
    result = []
    # 遍历匹配结果
    for m in match:
        d = {}
        # 提取 host、instance 和 job
        labels = re.findall(r'(\w+)=([\w\.\-]+)', m)
        for label in labels:
            d[label[0]] = label[1]
        result.append(d)
    return result


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

    return alert_list


def compare_alert(old_firing, new_firing):
    # 存放相同部分的列表
    firing_list = []
    # 存放不同部分的列表
    resolved_list = []

    # 遍历list1中的每个元素
    for old in old_firing:
        for new in new_firing:
            # 如果两个元素instance相同
            if old['instance'] == new['instance']:
                firing_list.append(new)
                break
        else:
            resolved_list.append(old)

    # 遍历新报警列表中的每个元素
    for new in new_firing:
        for item in firing_list:
            # 如果两个元素相同
            if item['instance'] == new['instance']:
                break
        else:
            firing_list.append(new)

    # 当前时间设置为resolved时间
    now = datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=8)))  # 加上时区偏移量
    formatted_time = now.strftime('%Y-%m-%dT%H:%M:%S.%f%z').replace('+0800', '+08:00')

    # 将resolved_list中所有报警的状态修改为resolved
    for resoved in resolved_list:
        resoved['status'] = 'resolved'
        resoved['endsAt'] = formatted_time

    return firing_list, resolved_list


# 发送警报给alertmanager，接收参数为列表
def send_alert(alert_list):
    for single_alert in alert_list:
        alert_data = [
            {
                "status": single_alert['status'],
                "labels": {
                    "alertname": single_alert['alertname'],
                    "severity": single_alert['severity'],
                    "host": single_alert['host'],
                    "instance": single_alert['instance'],
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

        alert_url = 'http://45.152.66.111:9093/api/v1/alerts'
        headers = {"Content-Type": "application/json"}
        response = requests.post(alert_url, headers=headers, data=json.dumps(alert_data))
        print(response.text)


@app.route('/webhook', methods=['POST'])
def webhook():
    grafana_data = json.loads(request.data)
    # print(grafana_data)
    for alert in grafana_data['alerts']:
        # 每个alert代表一个类型的报警，如MemoryUsage_Linux_Low
        alert = splitting_alert(alert)
        alertname = alert[0]['alertname']
        match alertname:
            case "CPUUsage_Linux_Low":
                global CPUUsage_Linux_Low_Current
                # 如果不是第一次发出报警
                if CPUUsage_Linux_Low_Current:
                    # 如果是报警解除消息
                    if alert[0]['status'] == 'resolved':
                        tmp = []
                        for tmp_alert in CPUUsage_Linux_Low_Current:
                            tmp_alert['status'] = 'resolved'
                            tmp_alert['endsAt'] = alert[0]['endsAt']
                            tmp.append(tmp_alert)
                        CPUUsage_Linux_Low_Current = tmp
                        print(CPUUsage_Linux_Low_Current)
                        send_alert(CPUUsage_Linux_Low_Current)

                        # 全部解决，清空警报列表
                        CPUUsage_Linux_Low_Current.clear()
                        print(CPUUsage_Linux_Low_Current)
                    # 如果是报警消息
                    elif alert[0]['status'] == 'firing':
                        send_alert(CPUUsage_Linux_Low_Current)
                        firing_list, resolved_list = compare_alert(CPUUsage_Linux_Low_Current, alert)
                        CPUUsage_Linux_Low_Current = firing_list
                        send_alert(CPUUsage_Linux_Low_Current)
                        send_alert(resolved_list)
                        print(CPUUsage_Linux_Low_Current)
                        print(resolved_list)
                        print("Not first firing")
                # 如果是第一次报警
                else:
                    if alert[0]['status'] == 'firing':
                        CPUUsage_Linux_Low_Current = alert
                        send_alert(CPUUsage_Linux_Low_Current)
                        print(CPUUsage_Linux_Low_Current)
                        print("First firing")
                    elif alert[0]['status'] == 'resolved':
                        pass

            # case "MemoryUsage_Linux_Low":
            #     print("Memory_low")

    return 'Alert OK', 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port='5001', debug=False)
    # WSGIServer(('0.0.0.0', 5001), app).serve_forever()
