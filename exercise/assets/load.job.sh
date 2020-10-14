#!/bin/sh
kubectl create -n default configmap bookinfo --from-file=/usr/local/bin/load.sh
kubectl create -n default configmap kube --from-file=${HOME}/.kube/config
kubectl apply  -n default -f /usr/local/bin/load.yaml