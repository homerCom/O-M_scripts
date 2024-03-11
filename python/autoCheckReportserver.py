import socket
import binascii
import time
import tkinter as tk

# G01表，TCP信息的16进制表示
message_N01 = '00 a7 02 00 a3 4e 30 31 1e 33 30 30 30 31 30 35 33 1e 31 39 32 2e 31 36 38 2e 38 2e 32 1e 31 1e 31 1e 1e 31 1e 34 30 30 30 30 30 30 30 1e 30 1e 31 30 30 1e 34 36 1e 32 30 31 38 30 33 30 36 32 32 32 33 33 36 1e 30 1e 37 43 3a 44 44 3a 39 30 3a 41 44 3a 45 38 3a 46 45 1e 31 2e 30 2e 30 35 1e 30 30 30 37 38 39 1e 33 41 32 38 31 31 34 30 30 30 42 42 38 37 38 43 1e 37 38 39 20 20 20 20 20 20 1e 31 36 31 36 31 30 31 33 33 30 30 30 31 30 35 33 1e 34 30 31 32 30 30 2a 2a 2a 2a 2a 2a 35 34 33 39 1e 30 31 32 5e'

# 将16进制字符串转换为字节串
message_bytes = bytes.fromhex(message_N01.replace(" ", ""))


def send_tcp(address):
    try:
        # 创建TCP套接字
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # 连接到目标域名和端口
        sock.connect((address, int(port_entry.get())))
        # 发送TCP信息
        sock.sendall(message_bytes)
        # 接收返回消息
        response = sock.recv(1024)
        decoded_response = binascii.hexlify(response).decode()
        print(f"Received from {address}: {decoded_response}")

        # 在GUI中显示返回结果
        result_text.insert(tk.END, f"{address}\n")
        result_text.insert(tk.END, f"{decoded_response}\n")

    except socket.error as e:
        print(f"Error connecting to {address}: {e}")

    finally:
        # 关闭套接字连接
        sock.close()


def start_test():
    # 清空显示框
    result_text.delete("1.0", tk.END)
    domains = domain_entry.get().split(",")
    for domain in domains:
        send_tcp(domain.strip())


# 创建主窗口
root = tk.Tk()
root.title("ReportServer Test Tool")

# 添加域名输入框
domain_label = tk.Label(root, text="域名：")
domain_label.grid(row=0, column=0)
domain_entry = tk.Entry(root)
domain_entry.grid(row=0, column=1)

# 添加端口号输入框
port_label = tk.Label(root, text="端口号：")
port_label.grid(row=1, column=0)
port_entry = tk.Entry(root)
port_entry.grid(row=1, column=1)

# 添加开始测试按钮
start_button = tk.Button(root, text="开始测试", command=start_test)
start_button.grid(row=2, column=0, columnspan=2)

# 添加结果显示框
result_text = tk.Text(root)
result_text.grid(row=3, column=0, columnspan=2)

root.mainloop()