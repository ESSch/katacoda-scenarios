#!/bin/sh
kubectl create -n bookinfo configmap bookinfo --from-file=/usr/local/bin/bookinfo.sh
kubectl create -n bookinfo configmap kube --from-file=${HOME}/.kube/config
kubectl apply -n bookinfo -f /usr/local/bin/bookinfo.yaml