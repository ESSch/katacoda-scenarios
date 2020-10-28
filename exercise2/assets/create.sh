#! /bin/bah

tar -cvf /tmp/exercise.tar /root/exercise && \
docker run \
  --name tar \
  -d \
  -p 9001:80 \
  -v /tmp/exercise.tar:/usr/share/nginx/html/exercise.tar:ro \
  nginx && \
curl -I localhost:9001/exercise.tar;

