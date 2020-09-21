#!/bin/sh

# kubectl get pods --all-namespaces
while [ "$(kubectl get pods --all-namespaces)" = "No resources found" ]; do 
    echo "Ensure k8s is properly initialized...No resources found"
    sleep 10
done

# ensure kubernetes is initialized
while [ "$(kubectl get pods -l app!=katacoda-cloud-provider -n kube-system -o=jsonpath='{.items[*].status.conditions[?(@.status == "False")].status}')" != "" ]; do 
    echo "Ensure k8s is properly initialized..."
    sleep 10
done

kubectl get pods --all-namespaces


# untaint control plane
kubectl taint nodes --all node-role.kubernetes.io/master-

# install opa
curl -sS -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod 755 opa
mv opa /usr/local/bin

export ISTIO_VERSION=1.6.2

[ ! -d "$HOME/istio-$ISTIO_VERSION/bin" ] && curl -sS -L https://istio.io/downloadIstio | sh -

export PATH=$HOME/istio-$ISTIO_VERSION/bin:$PATH
[ ! -d "$HOME/exercise" ] && mkdir $HOME/exercise

# cni workaround
ssh -o "StrictHostKeyChecking no" node01 'ip link set cni0 down'
ssh -o "StrictHostKeyChecking no" node01 'brctl delbr cni0'
ip link set cni0 down
brctl delbr cni0
kubectl scale deployment coredns --replicas=0 -n kube-system

while [ "$(kubectl get pods -l app!=katacoda-cloud-provider -n kube-system -o=jsonpath='{.items[*].status.conditions[?(@.status == "False")].status}')" != "" ]; do 
    echo "Ensure k8s is properly initialized..."
    sleep 10
done

kubectl scale deployment coredns --replicas=2 -n kube-system

while [ "$(kubectl get pods -l app!=katacoda-cloud-provider -n kube-system -o=jsonpath='{.items[*].status.conditions[?(@.status == "False")].status}')" != "" ]; do 
    echo "Ensure k8s is properly initialized..."
    sleep 10
done



istioctl install --set profile=demo --readiness-timeout='10m0s'
sleep 10

# scale down istio ingress
kubectl -n istio-system scale deployment istio-ingressgateway  --replicas=0
while [ "$(kubectl get pods -l app=istio-ingressgateway -n istio-system -o=jsonpath='{.items[*].status.conditions[?(@.status == "False")].status}')" != "" ]; do 
    echo "Scaling down istio-ingressgateway...."
    sleep 10
done

# patch ingress gateway
kubectl -n istio-system patch service istio-ingressgateway -p "$(cat /tmp/node-port.yaml)"
kubectl -n istio-system patch service istio-ingressgateway -p "$(cat /tmp/immutable-ports.yaml)"
kubectl -n istio-system patch service istio-ingressgateway -p "$(cat /tmp/traffic-policy.yaml)"
kubectl -n istio-system patch deployment istio-ingressgateway -p "$(cat /tmp/antiaffinity.yaml)"


kubectl -n istio-system scale deployment istio-ingressgateway  --replicas=2
while [ "$(kubectl get pods -n istio-system -o=jsonpath='{.items[*].status.conditions[?(@.status == "False")].status}')" != "" ]; do 
    echo "Scaling up istio-ingressgateway...."
    sleep 10
done

kubectl get pods -n istio-system
echo "Done."


# app=istio-ingressgateway