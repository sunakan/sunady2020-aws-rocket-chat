#!/bin/bash

for i in `seq 1 10`; do
  node main.js && s=$? && break || s=$?;
  echo 試行 $i 回目： 5秒待機中...;
  sleep 5;
done;

exit $$s
