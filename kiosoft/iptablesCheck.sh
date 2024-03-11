#!/bin/bash
# Check if there are any DROP rules in the iptables INPUT chain and delete it by rule num.
drop_rule_exists=$(sudo iptables -nvL INPUT | grep -c "DROP")
if [ $drop_rule_exists -gt 0 ]; then
    echo `date +'%Y-%m-%d %H:%M:%S'` >> /var/log/iptalbes_monitor.log
    /usr/sbin/iptables -nvL INPUT >> /var/log/iptalbes_monitor.log
    for ((i = 1; i <= $drop_rule_exists; i++)); do
        /usr/sbin/iptables -D INPUT 1
        echo "The $i DROP rule has been removed." >> /var/log/iptalbes_monitor.log
    done
else
    echo "No DROP rules found."
fi
