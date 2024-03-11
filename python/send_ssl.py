import smtplib
from email.mime.text import MIMEText
from email.header import Header


sender = 'noreply@kiosoft.com'
receiver = 'lucaszhang@techtrex.com'
subject = 'TTI modem'
content = 'TTI modem test'

message = MIMEText(content, 'plain', 'utf-8')
message['From'] = Header(sender, 'utf-8')
message['To'] = Header(receiver, 'utf-8')
message['Subject'] = Header(subject, 'utf-8')

smtp_server = 'kiosoft-com.mail.protection.outlook.com'
smtp_port = 465
smtp_username = 'noreply@kiosoft.com'
smtp_password = ''

smtp_conn = smtplib.SMTP_SSL(smtp_server, smtp_port)
smtp_conn.login(smtp_username, smtp_password)
smtp_conn.sendmail(sender, receiver, message.as_string())
smtp_conn.quit()

