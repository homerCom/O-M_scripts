import redis

# 创建 Redis 连接
r = redis.Redis(host='127.0.0.1', port=6379, db=4, password='123456')


# 为每个表生成keys
def generate_key(table_name):
    generated_keys = []

    base_key = '20230910'

    for hour in range(24):
        key = f'{base_key}{hour:02d}_{table_name}'  # 使用f-string格式化键
        generated_keys.append(key)
    return generated_keys


def query_max(keys):
    max_key = None  # 用于存储具有最大值的键
    max_value = None  # 用于存储最大值

    # 查询并找到最大值的键和值
    for key in keys:
        value = r.get(key)
        if value is not None:
            value = int(value.decode("utf-8"))
            if max_value is None or value > max_value:
                max_value = value
                max_key = key

    if max_key is not None:
        print(f'{max_key}: {max_value}')
    else:
        print('No keys with values found')


table_list = ['P01', 'N01', 'R03', 'N13', 'R01', 'N16', 'N12', 'U02', 'N10', 'N09', 'U04', 'U01', 'L04', 'R05', 'U03',
              'N03', 'G01', 'R04', 'N11', 'R93', 'N00', 'N02', 'X01']

for table_name in table_list:
   keys = generate_key(table_name)
   query_max(keys)

# 关闭 Redis 连接
r.close()
