#!/bin/bash

source launch.sh

for i in {1..100}
do
    if [ $(kubectl get pods --all-namespaces | wc -l) == 13 ]
    then
        break;
    else
        echo -n "."
        sleep .2
    fi
done 

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