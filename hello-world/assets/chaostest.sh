#!/bin/bash

while true
do
    echo "Choosing a pod to kill..."
    PODS=$(kubectl -n bookinfo get pods | grep -v NAME | awk '{print $1}')
    POD_COUNT=$(kubectl -n bookinfo get pods | grep -v NAME | wc -l)
    K=$(( ( $RANDOM % $POD_COUNT ) + 1))
    TARGET_POD=$(kubectl -n bookinfo get pods | grep -v NAME | awk '{print $1}' | head -n ${K} | tail -n 1)
    echo "Killing pod ${TARGET_POD}"
    kubectl -n bookinfo delete pod $TARGET_POD
    sleep 1
done