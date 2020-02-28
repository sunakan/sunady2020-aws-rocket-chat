#!/bin/bash

for i in `seq 1 10`; do
  mongo mongo/rocketchat \
    --eval "rs.initiate({ _id: 'rs0', members: [{_id: 0, host: 'localhost:27017'}] })" \
    && s=$? && break || s=$?;
  echo 試行 $i 回目： 5秒待機中...;
  sleep 5;
done;

exit $s
