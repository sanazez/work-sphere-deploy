#!/bin/bash

TAG=$1

cd /path/to/work-sphere-deploy || exit 1

docker pull sanazez/work-sphere-api-gateway:${TAG} || exit 1
docker stop work-sphere-api || true
docker rm -f work-sphere-api || true

docker-compose up -d --force-recreate --no-deps api-gateway || exit 1

sleep 10

curl -f http://localhost:3000/health || exit 1
