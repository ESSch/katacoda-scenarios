#!/bin/bash

check="\e[1;32m✔\e[0m"
launch.sh &
PID=$$
ps $PID | grep -v PID

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
    if [ $(kubectl get pods --all-namespaces | wc -l) -ge 9 ]
    then
        break;
    else
        echo -n "."
        sleep .2
    fi
done 
echo "";
echo "$check"

kubectl get pods $i -n kube-system

for i in "$(kubectl get pods -n kube-system -o json | jq -r '.items[].metadata.name')"; 
do
    kubectl get pods $i -n kube-system | grep -v NAME | grep Running > /dev/null
    if [ $? -ne 0 ]
    then
        echo "$i is starging..."
        for a in {1..100}
        do
            echo -n "."
            sleep .2
            kubectl get pods $i -n kube-system | grep -v NAME | grep Running > /dev/null
            if [ $? -eq 0 ]
            then
                continue;
            fi
        done
    else 
        kubectl get pods $i -n kube-system | grep -v NAME | grep Running
    fi
done
echo "";