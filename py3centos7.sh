#!/bin/bash

#安装依赖
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make libffi-devel

#安装openssl
wget https://www.openssl.org/source/openssl-1.1.1n.tar.gz --no-check-certificate
tar -zxf openssl-1.1.1n.tar.gz
cd openssl-1.1.1n
./config --prefix=/usr/local/openssl 
make -j && make install 

#安装py3
wget -P /opt/ https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
cd /opt/
tar -zxvf Python-3.10.12.tgz
cd /opt/Python-3.10.12
./configure --prefix=/usr/local/python3 --with-zlib --with-ssl
#./configure --prefix=/usr/local/python3 --with-openssl=/usr/local/openssl --with-openssl-rpath=auto
make
make install

#创建软连接
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
#mv /usr/bin/python /usr/bin/python.bak
#ln -s /usr/local/python3/bin/python3 /usr/bin/python
#mv /usr/bin/pip /usr/bin/pip.bak
#ln -s /usr/local/python3/bin/pip3 /usr/bin/pip

#配置yum
#sed -i 's/python/python2.7/g' /usr/libexec/urlgrabber-ext-down
#sed -i 's/python/python2.7/g' /usr/bin/yum
#sed -i 's/python/python2.7/g' /usr/sbin/iotop

rm -rf /opt/Python-3.10.12.tgz
rm -rf /opt/Python-3.10.12
