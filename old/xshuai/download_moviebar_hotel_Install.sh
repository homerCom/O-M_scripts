#!/bin/bash
echo -n "do you download moviebar install (y/n)"
read input 
if [[ $input != "n" ]]; then
  wget -O moviebar_install.zip "http://download.y.iqiyi.com/download/local-hotel/install.zip?st=IC1nL4cDugUBvZ8ovLrXkA&e=1981618752"
fi
