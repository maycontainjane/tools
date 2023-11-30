#!/bin/bash

echo "Stopping all containers..."
docker container stop $(docker ps -aq)
echo "Removing all containers..."
docker container rm $(docker ps -aq)
echo "Removing all images..."
docker rmi $(docker image ls -q)
echo "Removing all volumes..."
docker volume rm $(docker volume ls -q)
echo "Removing all networks..."
docker network rm $(docker network ls -q)

#rm -rf docker-compose.yml
