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

function format {
    status=$(echo $1 | jq -r '.status');
    if [[ "$status" == "1" ]]; then 
        echo -en "\e[32m"
    fi
    if [[ "$status" == "-1" ]]; then 
        echo -en "\e[91m"
    fi
    if [[ "$status" == "0" ]]; then 
        echo -en "\e[91m"
    fi
    echo -n "$1" | jq -r ".msg"
    echo -en "\e[0m"
}

echo -en "\e[93m"
cat <<EOF 

CloudNative checklist

Автоматическая проверка объектов:
EOF
echo -e "\e[0m"

readiness=$(kubectl get deployments app -o json | opa eval -f pretty -I -d /tmp/k8s_probes_readiness.rego "data.k8s.cloud")
liveness=$(kubectl  get deployments app -o json | opa eval -f pretty -I -d /tmp/k8s_probes_liveness.rego  "data.k8s.cloud")
startup=$(kubectl   get deployments app -o json | opa eval -f pretty -I -d /tmp/k8s_probes_startup.rego   "data.k8s.cloud")

format "$(echo $startup   | jq -r '.startup.apply_startup_probe')"
format "$(echo $readiness | jq -r '.readiness.apply_rediness_probe')"
format "$(echo $liveness  | jq -r '.liveness.apply_liveness_probe')"

