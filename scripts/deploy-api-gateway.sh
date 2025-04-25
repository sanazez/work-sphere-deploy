#!/bin/bash

TAG=$1

cd work-sphere-deploy || exit 1

# Update or add WORK_SPHERE_API_GATEWAY_TAG in .env file
if grep -q "^WORK_SPHERE_API_GATEWAY_TAG=" .env; then
  sed -i.bak "s|^WORK_SPHERE_API_GATEWAY_TAG=.*|WORK_SPHERE_API_GATEWAY_TAG=${TAG}|" .env && rm -f .env.bak
else
  echo "WORK_SPHERE_API_GATEWAY_TAG=${TAG}" >> .env
fi

# Verify that the tag was updated
grep "WORK_SPHERE_API_GATEWAY_TAG=${TAG}" .env || {
  echo "Failed to update WORK_SPHERE_API_GATEWAY_TAG in .env"
  exit 1
}

docker pull sanazez/work-sphere-api-gateway:${TAG} || exit 1
docker stop work-sphere-api-gateway || true
docker rm -f work-sphere-api-gateway || true

docker-compose up -d --force-recreate --no-deps api-gateway || exit 1

echo "Container logs for api-gateway:"
docker logs work-sphere-api-gateway

sleep 10

curl -f http://localhost:3000/health || exit 1
