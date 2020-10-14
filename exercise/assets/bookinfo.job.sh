#!/bin/sh
kubectl create -n default configmap bookinfo --from-file=/usr/local/bin/bookinfo.sh
kubectl create -n default configmap kube --from-file=${HOME}/.kube/config
kubectl create -n default configmap deployment --from-file=/tmp/bookinfo-no-deployment.yaml
kubectl create -n default configmap mtls --from-file=/tmp/destination-rule-all-mtls.yaml
#kubectl create -n default configmap tmp --from-file=/tmp # /tmp/bookinfo-no-deployment.yaml /tmp/destination-rule-all-mtls.yaml
kubectl create -n default configmap gateway --from-file=/istio-1.6.2/samples/bookinfo/networking/bookinfo-gateway.yaml
chmod a+rw /root/.kube/config
kubectl apply -n default -f /usr/local/bin/bookinfo.yaml
kubectl get job bookinfo -n default
kubectl get pods -l job-name=bookinfo -n default
kubectl logs $(kubectl get pods -l job-name=bookinfo -n default -o jsonpath={@.items..metadata.name}) -n default -c bookinfo
kubectl describe pod $(kubectl get pods -l job-name=bookinfo -n default -o jsonpath={@.items..metadata.name}) -n bookinfo
vkubectl exec -it $(kubectl get pods -l job-name=bookinfo -o jsonpath={@.items..metadata.name}) -c bookinfo -- kubectl get pods
# docker run --rm -it --name kubectl -v /root/config:/.kube/config:rw bitnami/kubectl:latest get pods -n bookinfo
# /etc/config/bookinfo.sh