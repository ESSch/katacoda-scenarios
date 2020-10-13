#!/bin/bash

check="✔"
launch.sh &

echo "Load kubernetes..."
for i in {1..300}
do
    echo -n "."
    sleep .2
    ps -aux | grep "launch.sh" | grep -v PID | grep -v grep > /dev/null
    if [ $? -ne 0 ]
    then
        break
    fi
done
echo "";
echo "$check"

echo "Start pods..."
for i in {1..100}
do
    if [ $(kubectl get pods --all-namespaces | wc -l ) -ge 9 ]
    then
        break;
    else
        echo -n "."
        sleep .2
    fi
done 
echo "";
echo "$check"

echo "Start pods..."
for i in {1..100}
do
    if [ $(kubectl get pods --all-namespaces | grep Running | wc -l) -ge 8 ]
    then
        break;
    else
        echo -n "."
        sleep .2
    fi
done 
echo "";
echo "$check"

kubectl get pods --all-namespaces
