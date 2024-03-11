#! /bin/bash
 
# curl foobar https://ip.cn/index.php?ip={ip_address}
for ((i=0;i<10;i++)); do
    curl https://ip.cn/index.php?ip=$((RANDOM%255+1)).$((RANDOM%255+1)).$((RANDOM%255+1)).$((RANDOM%255+1)) &
    sleep 0.05
done
wait
echo "Done"
