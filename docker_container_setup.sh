#!/bin/bash

# script to set up fresh aws container
# install docker, git, docker-compose, kong-ee, and gateway-docker-compose 
if [ -z "$DOCKERHUB_KONGCLOUD_PULL_PSW" ]; then
    echo "DOCKERHUB_KONGCLOUD_PULL_PSW environment variable is not set"
    exit 1
fi

if [ -z "$GITHUB_USER" ]; then
    echo "GITHUB_USER environment variable is not set"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN environment variable is not set"
    exit 1
fi

sudo yum update -y

sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

sudo chkconfig docker on

sudo yum install -y git

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# expect docker-compose version to return 'Docker Compose version v<version>'
if docker-compose --version | grep -q 'Docker Compose version v'; then
    echo "Docker Compose installed successfully"
else
    echo "Failed to install Docker Compose"
fi

# login to docker hub
docker login -u kongcloudpull -p $DOCKERHUB_KONGCLOUD_PULL_PSW

git clone https://$GITHUB_USER:$GITHUB_TOKEN@github.com/Kong/kong-ee.git
git clone https://$GITHUB_USER:$GITHUB_TOKEN@github.com/Kong/gateway-docker-compose-generator.git

