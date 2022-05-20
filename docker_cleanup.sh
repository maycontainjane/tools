#!/bin/bash

docker container rm $(docker ps -aq)
docker rmi $(docker image ls -q)
docker volume rm $(docker volume ls -q)

#rm -rf docker-compose.yml
