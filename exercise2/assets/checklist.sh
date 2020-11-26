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

readiness=$(kubectl get deployments app -o json | opa eval -f pretty -I -d /tmp/k8s_probes_readiness.rego "data.k8s.cloud")
liveness=$(kubectl  get deployments app -o json | opa eval -f pretty -I -d /tmp/k8s_probes_liveness.rego  "data.k8s.cloud")
startup=$(kubectl   get deployments app -o json | opa eval -f pretty -I -d /tmp/k8s_probes_startup.rego   "data.k8s.cloud")

echo $startup   | jq '.startup.apply_startup_probe.status'
echo $readiness | jq '.readiness.apply_rediness_probe.status'
echo $liveness  | jq '.liveness.apply_liveness_probe.status'