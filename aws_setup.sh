#!/bin/bash
# for new AWS instance

sudo yum install git make docker -y
python3 -m ensurepip
python3 -m pip install httpie

sudo service docker start
sudo chmod 666 /var/run/docker.sock
docker ps

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version

git clone https://github.com/Kong/gateway-docker-compose-generator.git