#!/bin/bash

curl -sS -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod 755 opa
mv opa /usr/local/bin


function print_policy {
    echo -en "\e[32m"
    echo -n "$1" | jq -r ".allow[]"
    echo -en "\e[0m"

    echo -en "\e[91m"
    echo -n "$1" | jq -r ".deny[]"
    echo -en "\e[0m"

    echo -en "\e[91m"
    echo -n "$1" | jq -r ".err[]"
    echo -en "\e[0m"
}

echo -en "\e[93m"
cat <<EOF 

CloudNative checklist

Автоматическая проверка объектов:
EOF
echo -e "\e[0m"

readiness=$(kubectl get deployments app -o json | opa eval -f pretty -I -d /tmp/k8s_probes_readiness.rego "data.k8s.cloud" | jq)
liveness=$(kubectl  get deployments app -o json | opa eval -f pretty -I -d /tmp/k8s_probes_liveness.rego  "data.k8s.cloud" | jq)
startup=$(kubectl   get deployments app -o json | opa eval -f pretty -I -d /tmp/k8s_probes_startup.rego   "data.k8s.cloud" | jq)

echo $startup
echo $readiness
echo $liveness