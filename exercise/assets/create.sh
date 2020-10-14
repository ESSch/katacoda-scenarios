#!/bin/bash

docker ps | grep tar && docker rm -f tar && echo "✔ Old archive deleted"
tar -cvf /tmp/exercise.tar /root/exercise && \
docker run \
  --name tar \
  -d \
  -p 9000:80 \
  -v /tmp/exercise.tar:/usr/share/nginx/html/exercise.tar:ro \
  nginx &&  \
echo "Arhive creating..." && sleep 5 && \
curl -I localhost:9000/exercise.tar &>/dev/null && \
echo "✔ Archive created"

