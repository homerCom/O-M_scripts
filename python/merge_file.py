import tkinter as tk
import tkinter.filedialog as filedialog
import os

def select_files():
    # 弹出文件选择对话框，让用户选择多个文件
    files = filedialog.askopenfilenames()
    # 显示选择的文件列表
    file_list.delete(0, tk.END)
    for file in files:
        file_list.insert(tk.END, file)

def merge_files():
    # 获取选择的文件列表
    files = file_list.get(0, tk.END)
    # 如果选择的文件列表为空，则提示用户选择文件
    if not files:
        tk.messagebox.showwarning('警告', '请选择要合并的文件！')
        return
    # 弹出保存文件对话框，让用户指定合并后的文件名和保存路径
    save_file = filedialog.asksaveasfile(mode='w', defaultextension='.txt')
    # 如果用户取消保存，则返回
    if not save_file:
        return
    # 读取所有文件的内容，并将它们写入到保存的文件中
    for i, file in enumerate(files):
        # 写入文件名作为注释（第一个文件前不需要加空行）
        if i > 0:
            save_file.write('\n')
        save_file.write(f"# {os.path.basename(file)}\n")
        # 写入文件内容
        with open(file, 'r') as f:
            save_file.write(f.read())
    # 关闭保存的文件
    save_file.close()
    # 显示合并完成的提示信息
    tk.messagebox.showinfo('提示', '文件合并完成！')

# 创建主窗口
root = tk.Tk()
root.title('文件合并工具')

# 创建选择文件按钮和文件列表框架
file_frame = tk.Frame(root)
select_button = tk.Button(file_frame, text='选择文件', command=select_files)
file_list = tk.Listbox(file_frame, width=50, height=10)

# 创建合并文件按钮
merge_button = tk.Button(root, text='合并文件', command=merge_files)

# 将选择文件按钮和文件列表框架添加到主窗口
select_button.pack(side=tk.LEFT, padx=10)
file_list.pack(side=tk.LEFT, padx=10, pady=10)
file_frame.pack()

# 将合并文件按钮添加到主窗口
merge_button.pack(pady=10)

# 运行主循环
root.mainloop()
