import tkinter as tk
import socket
import threading


class PortScanner:
    def __init__(self, root):
        # 创建窗口
        self.root = root
        self.root.title("端口扫描器")
        self.root.geometry("800x600")
        self.root.resizable(False, False)
        self.root.configure(background="#282c34")

        # 创建界面元素
        self.title_label = tk.Label(self.root, text="端口扫描器", font=("Arial", 20, "bold"), fg="white", bg="#282c34")
        self.title_label.pack(pady=(20, 0))

        self.host_label = tk.Label(self.root, text="域名或IP地址：", font=("Arial", 12), fg="white", bg="#282c34")
        self.host_label.pack(pady=(40, 0))
        self.host_entry = tk.Entry(self.root, font=("Arial", 12), width=30, bd=2, relief="groove")
        self.host_entry.pack(pady=(10, 0))

        self.port_range_label = tk.Label(self.root, text="端口范围（格式：起始端口-终止端口）或单个端口号：", font=("Arial", 12), fg="white",
                                         bg="#282c34")
        self.port_range_label.pack(pady=(20, 0))
        self.port_range_entry = tk.Entry(self.root, font=("Arial", 12), width=30, bd=2, relief="groove")
        self.port_range_entry.pack(pady=(10, 0))

        self.scan_button = tk.Button(self.root, text="开始扫描", font=("Arial", 12, "bold"), bg="#0078d7", fg="white", bd=0,
                                     command=self.scan_ports)
        self.scan_button.pack(pady=(20, 0))

        self.result_frame = tk.Frame(self.root, bg="#282c34")
        self.result_frame.pack(pady=(20, 0))
        self.result_label = tk.Label(self.result_frame, text="扫描结果：", font=("Arial", 14, "bold"), fg="white",
                                     bg="#282c34")
        self.result_label.pack(side="left")
        self.clear_button = tk.Button(self.result_frame, text="清除日志", font=("Arial", 12), bg="#0078d7", fg="white",
                                      bd=0, command=self.clear_result)
        self.clear_button.pack(side="right")
        self.result_scrollbar = tk.Scrollbar(self.result_frame, orient="vertical")
        self.result_scrollbar.pack(side="right", fill="y")
        self.result_text = tk.Text(self.result_frame, font=("Arial", 12), width=50, height=10, bd=2, relief="groove",
                                   yscrollcommand=self.result_scrollbar.set)
        self.result_text.pack(side="left", fill="both", expand=True)
        self.result_scrollbar.config(command=self.result_text.yview)

        self.open_ports_label = tk.Label(self.root, text="", font=("Arial", 12), fg="white", bg="#282c34")
        self.open_ports_label.pack(pady=(20, 0))

    # 扫描端口
    def scan_ports(self):
        # 检查输入的域名或IP地址是否为空
        if not self.host_entry.get():
            self.result_text.insert(tk.END, "请输入域名或IP地址！\n")
            return

        # 检查输入的域名或IP地址是否正确
        host = self.host_entry.get()
        try:
            socket.gethostbyname(host)
        except socket.gaierror:
            self.result_text.insert(tk.END, "域名或IP地址不正确，请重新输入！\n")
            return

        # 获取要扫描的端口范围或单个端口号
        port_range = self.port_range_entry.get()
        if "-" in port_range:
            # 检查端口范围格式是否正确
            try:
                start_port, end_port = map(int, port_range.split("-"))
            except:
                self.result_text.insert(tk.END, "端口范围格式不正确，请重新输入！\n")
                return
            # 显示扫描状态
            self.result_text.insert(tk.END, f"正在扫描 {host} 的端口范围 {port_range}...\n")
            # 创建多个线程，每个线程负责扫描一个端口
            threads = []
            for port in range(start_port, end_port + 1):
                t = threading.Thread(target=self.scan_port, args=(host, port))
                t.start()
                threads.append(t)
            # 等待所有线程结束
            for t in threads:
                t.join()
            # 输出扫描完成信息
            self.result_text.insert(tk.END, "端口扫描完成！\n")
        else:
            # 检查单个端口号格式是否正确
            try:
                port = int(port_range)
            except:
                self.result_text.insert(tk.END, "端口号格式不正确，请重新输入！\n")
                return
            # 显示扫描状态
            self.result_text.insert(tk.END, f"正在扫描 {host} 的端口 {port}...\n")
            # 创建一个线程，负责扫描该端口
            t = threading.Thread(target=self.scan_port, args=(host, port))
            t.start()

    # 扫描单个端口
    def scan_port(self, host, port):
        # 尝试连接端口
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(0.1)
            sock.connect((host, port))
            self.result_text.insert(tk.END, f"端口 {port} 开放\n")
            self.open_ports_label.config(text=f"开放的端口：{port}")
        except:
            self.result_text.insert(tk.END, f"端口 {port} 未开放\n")

    # 清除扫描结果
    def clear_result(self):
        self.result_text.delete("1.0", tk.END)


# 启动程序
if __name__ == "__main__":
    root = tk.Tk()
    app = PortScanner(root)
    root.mainloop()
