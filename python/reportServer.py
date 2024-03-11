# 统计reportserver每个小时所有协议总数量
# 2023-10-24
# lucaszhang@techtrex.com

import redis

# 创建 Redis 连接
r = redis.Redis(host='127.0.0.1', port=6379, db=4, password='123456')


# 为每个表生成keys
def generate_key(table_list):
    generated_keys = []
    hours = []
    print(table_list)
    value = 0
    all_value = 0

    base_key = '20231022'
    for hour in range(9, 22):
        for table in table_list:
            key = f'{base_key}{hour:02d}_{table}'
            value = r.get(key)
            if value is not None:
                value = int(value.decode("utf-8"))
                all_value = all_value + value
        print(f'{base_key}{hour:02d}')
        print(all_value)
        value = 0
        all_value = 0
        print('--------------------------------')

table_list = [
    "G01",
    "L01", "L02", "L03", "L04", "L05", "L06", "L08", "L09",
    "N00", "N01", "N02", "N03", "N04", "N05", "N06", "N07", "N08", "N09", "N10", "N11", "N12", "N13", "N14", "N15", "N16",
    "P01", "P03",
    "R01", "R02", "R03", "R04", "R05", "R06",
    "U01", "U02", "U03", "U04", "U05", "U06", "U08", "U09", "U10", "U11", "U12", "U13", "U15", "U16",
    "X01", "X02", "X03"
]

keys = generate_key(table_list)

r.close()

