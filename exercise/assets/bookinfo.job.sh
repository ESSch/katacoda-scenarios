#!/bin/sh
kubectl create -n bookinfo configmap bookinfo --from-file=/usr/local/bin/bookinfo.sh
kubectl create -n bookinfo configmap kube --from-file=${HOME}/.kube/config
kubectl apply -n bookinfo -f /usr/local/bin/bookinfo.yaml
kubectl get job bookinfo -n bookinfo
kubectl get pods -l job-name=bookinfo -n bookinfo
kubectl logs $(kubectl get pods -l job-name=bookinfo -n bookinfo -o jsonpath={@.items..metadata.name}) -n bookinfo
cp /root/.kube/config .
chmod a+rw config
chmod a+rw /root/.kube/config
# docker run --rm -it --name kubectl -v /root/config:/.kube/config:rw bitnami/kubectl:latest get pods -n bookinfo