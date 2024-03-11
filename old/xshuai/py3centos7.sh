#!/bin/bash

#安装依赖
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make libffi-devel

#安装py3
wget -P /opt/  219.146.255.198:8098/share/zhang/files/Python-3.8.11.tgz
cd /opt/
tar -zxvf Python-3.8.11.tgz
cd /opt/Python-3.8.11
./configure --prefix=/usr/local/python3
make
make install

#创建软连接
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
#mv /usr/bin/python /usr/bin/python.bak
#ln -s /usr/local/bin/python3 /usr/bin/python
#mv /usr/bin/pip /usr/bin/pip.bak
#ln -s /usr/local/bin/pip3 /usr/bin/pip

#配置yum
#sed -i 's/python/python2.7/g' /usr/libexec/urlgrabber-ext-down
#sed -i 's/python/python2.7/g' /usr/bin/yum
#sed -i 's/python/python2.7/g' /usr/sbin/iotop

rm -rf /opt/Python-3.8.11.tgz
rm -rf /opt/Python-3.8.11
