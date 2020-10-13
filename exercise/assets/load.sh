#!/bin/sh

watch -n 0.5 curl -o /dev/null -s -w %{http_code} $1:$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')/productpage

for i in "$(kubectl get pods -n kube-system -o json | jq -r '.items[].metadata.name')"; 
do
    kubectl get pods $i -n kube-system | grep -v NAME | grep Running > /dev/null
    if [ $? -ne 0 ]
    then
        echo "$i is starging..."
        for a in {1..100}
        do
            echo -n "."
            sleep 1
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