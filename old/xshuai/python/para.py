#!/usr/bin/python3

import paramiko

hostname = '192.168.1.223'
port = 22
username = 'root'
private_key = paramiko.RSAKey.from_private_key_file('/root/.ssh/id_rsa')

ssh  = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy)
ssh.connect(hostname=hostname, port=port, username=username, pkey=private_key)
stdin, stdout, stderr = ssh.exec_command('curl ip.cip.cc')
result = stdout.read().decode('utf-8')
ssh.close()
print(result)
