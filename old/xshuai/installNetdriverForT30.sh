wget http://219.146.255.198:8098/share/zhang/files/e1000.tar.gz
tar -zxvf e1000.tar.gz
cd /root/e1000e-3.4.0.2/src/
make install
modprobe e1000e