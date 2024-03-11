import requests
import json

alertmanager_url = 'http://45.152.66.111:9093/api/v2/alerts'

data = [
    {
        'labels': {
            'alertname': 'Test Alert',
            'severity': 'Low',
            'host': 'Aliyun',
            'instance': '47.107.31.18',
            'job': 'Ali'
        },
        "generatorURL": "http://test.com",
        'annotations': {
            'summary': 'This is a test alert',
            'description': 'This is the description of the test alert'
        },
        'startsAt': '2023-04-11T12:34:56.000Z'
    }
]

# 修改警报状态为resolved，添加endsAt字段
data[0]["status"] = "resolved"
data[0]["endsAt"] = "2023-04-11T13:34:56.000Z"

# 设置请求头的Content-Type字段为application/json
headers = {'Content-Type': 'application/json'}

# 发送POST请求
response = requests.post(alertmanager_url, data=json.dumps(data), headers=headers)

# 打印响应信息
print(response.status_code)
print(response.content)
