# -*- coding: utf-8 -*-
import os
import json
import requests
import arrow
from flask import Flask
from flask import request

app = Flask(__name__)


def bytes2json(data_bytes):
    data = data_bytes.decode('utf8').replace("'", '"')
    return json.loads(data)


def makealertdata(data):
    # 获取告警详情
    alerts = data['alerts']
    # 获取告警类型名称级别
    commonLabels = data['commonLabels']
    alertname = commonLabels['alertname']
    severity = commonLabels['severity']
    alertnum = len(alerts)
    # 获取告警状态
    status = data['status']

    title = f"## 【{severity}】 本地测试环境:{alertname} 个数:{alertnum} \n\n"
    # 定义告警内容
    send_data = {
        "msgtype": "markdown",
        "markdown": {
            "content": title
        }
    }
    for output in alerts:
        status = output['status']
        if status == 'firing':
            status_zh = '报警'
        else:
            status_zh = '恢复'

        try:
            pod_name = output['labels']['pod']
        except KeyError:
            try:
                pod_name = output['labels']['pod_name']
            except KeyError:
                pod_name = 'null'
        try:
            namespace = output['labels']['namespace']
        except KeyError:
            namespace = 'null'
        try:
            message = output['annotations']['message']
        except KeyError:
            try:
                message = output['annotations']['description']
            except KeyError:
                message = 'null'
        alert_instance = output['labels']['instance']
        if status == 'firing':
            send_data['markdown']['content'] = send_data['markdown']['content'] + \
                                               f">**{status_zh}**\n" + \
                                               f">**告警主机**: {alert_instance} \n" + \
                                               f">**告警详情**: {message} \n" + \
                                               f">**触发时间**: {arrow.get(output['startsAt']).to('Asia/Shanghai').format('YYYY-MM-DD HH:mm:ss')} \n\n\n\n"

        elif output['status'] == 'resolved':
            duration = arrow.get(output['endsAt']) - arrow.get(output['startsAt'])
            send_data['markdown']['content'] = send_data['markdown']['content'] + \
                                               f">**{status_zh}**\n" + \
                                               f">**告警主机**: {alert_instance} \n" + \
                                               f">**告警详情**: {message} \n" + \
                                               f">**触发时间**: {arrow.get(output['startsAt']).to('Asia/Shanghai').format('YYYY-MM-DD HH:mm:ss')} \n" + \
                                               f">**触发结束时间**: {arrow.get(output['endsAt']).to('Asia/Shanghai').format('YYYY-MM-DD HH:mm:ss')} \n" + \
                                               f">**持续时间**: {int(duration.total_seconds())} 秒 \n\n\n\n"

    print(send_data)
    return send_data


def send_alert(data):
    print(data)

    # 微信机器人地址
    url = 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=换自己的'
    send_data = makealertdata(data)
    req = requests.post(url, json=send_data)
    result = req.json()
    if result['errcode'] != 0:
        print('notify weixin error: %s' % result['errcode'])


@app.route('/wechat', methods=['POST', 'GET'])
def send():
    if request.method == 'POST':
        post_data = request.get_data()
        send_alert(bytes2json(post_data))
        return 'success'
    else:
        return 'weclome to use prometheus alertmanager dingtalk webhook server!'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

