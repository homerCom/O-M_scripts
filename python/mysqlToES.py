import mysql.connector
from elasticsearch import Elasticsearch
import  datetime
from elasticsearch.exceptions import NotFoundError

# MySQL 连接参数
mysql_config = {
    'host': '192.168.7.143',
    'user': 'kiosoft',
    'password': '123456',
    'database': 'laundry',
    'port': 21791,
}

# Elasticsearch 连接
es = Elasticsearch(['http://192.168.7.143:9200'])
#es.indices.delete(index='laundry_n00', ignore=[400, 404])

def get_max_id_from_es(index_name):
    try:
        # 使用聚合查询来获取最大 ID
        body = {
            "aggs": {
                "max_id": {
                    "max": {
                        "field": "ID"
                    }
                }
            }
        }
        response = es.search(index=index_name, body=body)

        max_id = response["aggregations"]["max_id"]["value"]
        return int(max_id)
    except NotFoundError:
        return 0

def fetch_mysql_data(cursor, offset, batch_size):
    query = "SELECT * FROM n00 LIMIT %s OFFSET %s"
    cursor.execute(query, (batch_size, offset))
    return cursor.fetchall()

def transform_row(row):
    doc = {
        'ID': row[0],
        'SerialNumber': row[1],
        'UploadTime': row[2],
        'RoomID': row[3],
        'MachineID': row[4],
        'SiteCode': row[5],
        'ULN': row[6],
    }
    return doc

def read_mysql_and_write_to_es():
    # 连接到 MySQL 数据库
    mysql_conn = mysql.connector.connect(**mysql_config)
    cursor = mysql_conn.cursor()

    try:
        batch_size = 10000
        offset = get_max_id_from_es('laundry_n00')
        while True:
            rows = fetch_mysql_data(cursor, offset, batch_size)
            if not rows:
                break

            docs = [transform_row(row) for row in rows]

            # 构建批量操作请求
            bulk_data = []
            for doc in docs:
                bulk_data.append({"index": {"_index": "laundry_n00", "_type": "_doc"}})
                bulk_data.append(doc)

            # 执行批量操作
            es.bulk(body=bulk_data)

            offset += batch_size
    finally:
        # 关闭连接
        cursor.close()
        mysql_conn.close()

if __name__ == '__main__':
    start_time = datetime.datetime.now()
    read_mysql_and_write_to_es()
    stop_time = datetime.datetime.now()
    print("用时：", stop_time - start_time)