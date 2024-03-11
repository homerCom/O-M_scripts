#!/bin/bash
# lucaszhang@techtrex.com
# 2023-11-15
# Modify the history command to add the date and user information

[ $UID -ne 0 ] && echo "Please run as root" && exit 1

if grep -q "HISTTIMEFORMAT" /etc/profile; then
    echo "Nothing done, HISTTIMEFORMAT has been set before"
else
    echo 'export HISTTIMEFORMAT="%F %T `whoami` "' >> /etc/profile
    source /etc/profile
    [ $? -eq 0 ] && echo "Modify format successfully."
fi
