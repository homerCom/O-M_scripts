import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# 配置 SMTP 服务器信息
smtp_server = 'kiosoft-com.mail.protection.outlook.com'  # 你的 SMTP 服务器地址
smtp_port = 25  # SMTP 服务器端口号
smtp_username = 'cleanstore@kiosoft.com'  # 你的 SMTP 用户名
smtp_password = ''  # 你的 SMTP 密码

# 发件人和收件人
from_email = 'cleanstore@kiosoft.com'
to_email = 'lucaszhang@techtrex.com'

# 创建 MIMEText 对象，用于邮件正文
message = MIMEMultipart()
message['From'] = from_email
message['To'] = to_email
message['Subject'] = 'Test TLS'

# 邮件正文
body = 'Python send TLS mail test.'
message.attach(MIMEText(body, 'plain'))

# 使用 SMTP 发送邮件
try:
    # 创建 SMTP 连接
    server = smtplib.SMTP(smtp_server, smtp_port)
    server.ehlo()
    server.starttls()  # 开启 TLS 加密连接
    #server.login(smtp_username, smtp_password)

    # 发送邮件
    server.sendmail(from_email, to_email, message.as_string())

    # 关闭连接
    server.quit()
    print("Mail send sucessed!")
except Exception as e:
    print(f"Send failed: {str(e)}")

