#!/bin/bash
#2023-03-10
#lucaszhang@techtrex.com
[ -f /usr/bin/tcping ] && echo "/usr/bin/tcping exists,no need to re-install" && exit 1
yum install -y tcptraceroute bc
wget -O /usr/bin/tcping https://soft.mengclaw.com/Bash/TCP-PING --no-check-certificate
chmod +x /usr/bin/tcping