#!/bin/bash
cd /data/moviebar
agentcode=`mysql localplay -e "select agent_code from local_bar;"|sed 1d`
echo $agentcode
wget -O serverInit.json "http://127.0.0.1/api/device/serverInit?agentCode=$agentcode"
