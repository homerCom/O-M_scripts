#!/bin/bash
#author:lucaszhang@techtrex.com
#date:20220711

[ $UID -ne 0 ]&& echo "Plese run this script as root"&&exit 1

if [ ! -f /root/.ssh ];then
	mkdir -p /root/.ssh
fi

if [ -f /tmp/id_rsa.pub ];then
	rm -rf /tmpid_rsa_pub
fi

wget -P /tmp/  http://47.107.31.18/projects/ansible/id_rsa.pub
cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys
rm -rf /tmp/id_rsa_pub
