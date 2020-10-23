#!/bin/bash

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

readiness=$(kubectl get deployments -o json | opa eval -f pretty -I -d /tmp/readiness.rego "data.k8s")
liveness=$(kubectl  get deployments -o json | opa eval -f pretty -I -d /tmp/liveness.rego "data.k8s")

print_policy "$readiness"
print_policy "$liveness"
