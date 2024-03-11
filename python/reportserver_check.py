import socket
import binascii
import time

# G01表，TCP信息的16进制表示
message_G01 = "02 00 22 47 30 31 1e 31 32 33 34 35 36 37 1e 32 30 32 30 30 36 33 30 30 33 30 32 31 32 1e 31 32 33 34 35 36 37 5f"
message_N01 = '00 a7 02 00 a3 4e 30 31 1e 33 30 30 30 31 30 35 33 1e 31 39 32 2e 31 36 38 2e 38 2e 32 1e 31 1e 31 1e 1e 31 1e 34 30 30 30 30 30 30 30 1e 30 1e 31 30 30 1e 34 36 1e 32 30 31 38 30 33 30 36 32 32 32 33 33 36 1e 30 1e 37 43 3a 44 44 3a 39 30 3a 41 44 3a 45 38 3a 46 45 1e 31 2e 30 2e 30 35 1e 30 30 30 37 38 39 1e 33 41 32 38 31 31 34 30 30 30 42 42 38 37 38 43 1e 37 38 39 20 20 20 20 20 20 1e 31 36 31 36 31 30 31 33 33 30 30 30 31 30 35 33 1e 34 30 31 32 30 30 2a 2a 2a 2a 2a 2a 35 34 33 39 1e 30 31 32 5e'

# 将16进制字符串转换为字节串
message_bytes = bytes.fromhex(message_N01.replace(" ", ""))

# 域名列表
domains = ['cscsw.kiosoft.com']
port = 5005
result_file = "result.txt"


def send_tcp(address):
    try:
        # 创建TCP套接字
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # 连接到目标域名和端口
        sock.connect((address, port))
        # 发送TCP信息
        sock.sendall(message_bytes)
        # 接收返回消息
        response = sock.recv(1024)
        decoded_response = binascii.hexlify(response).decode()
        print(f"Received from {address}: {decoded_response}")

        # 等待1秒钟
        time.sleep(1)

        # 接收第二个返回消息
        response2 = sock.recv(1024)
        decoded_response2 = binascii.hexlify(response2).decode()
        print(f"Received (second) from {address}: {decoded_response2}")

        with open(result_file, "a") as file:
            file.write(f"Domain: {address}\n")
            file.write(f"Response 1: {decoded_response}\n")
            file.write(f"Response 2: {decoded_response2}\n\n")

    except socket.error as e:
        print(f"Error connecting to {address}: {e}")

    finally:
        # 关闭套接字连接
        sock.close()


if __name__ == "__main__":
    for domain in domains:
        send_tcp(domain)
