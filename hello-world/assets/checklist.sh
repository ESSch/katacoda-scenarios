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

Свойства
    5. Готовность к отказу и автоматическому самовосстановлению любого из компонентов приложения и внешних компонентов/сервисов, от которых оно зависит
    3. Способность соблюдать нефункциональные требования при увеличении нагрузки послев добавления stateless экземпляров компонента

Автоматическая проверка объектов:
EOF
echo -e "\e[0m"

# policies
deployments=$(kubectl -n bookinfo get deployments -o json | opa eval -f pretty -I -d /tmp/deployment.rego "data.k8s.deployment.policy")
pods=$(kubectl -n bookinfo get pods -o json | opa eval -f pretty -I -d /tmp/pod.rego "data.k8s.pod.policy")
replicasets=$(kubectl -n bookinfo get replicasets -o json | opa eval -f pretty -I -d /tmp/replicaset.rego "data.k8s.replicaset.policy")

print_policy "$deployments"
print_policy "$pods"
print_policy "$replicasets"


