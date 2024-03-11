import requests
import json

url = 'http://45.152.66.111:9093/api/v2/alerts'

headers = {
    'Content-type': 'application/json'
}

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

response = requests.post(url, headers=headers, data=json.dumps(data))

print(response.text)