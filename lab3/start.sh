#!/bin/bash
echo "Привет, это статическая страница!" >> index.html
sudo apt-get update
sudo apt-get install -y npm
sudo npm install http-server -g
nohup http-server &
