#!/bin/sh
check="\e[1;32m✔\e[0m"

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
kubectl get nodes -o json | grep master | grep '"key": "node-role.kubernetes.io/master"' > /dev/null
if [ $? -eq 0 ]
then
    echo "# Taint $(kubectl taint nodes controlplane node-role.kubernetes.io/master-)"
fi
# kubectl get nodes -o json | jq .items[].spec.taints

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

# scale down istio ingress, fix infinity
kubectl -n istio-system scale deployment istio-ingressgateway  --replicas=0
#for (( c=1; c < 10 && 
while [ "$(kubectl get pods -l app=istio-ingressgateway -n istio-system -o=jsonpath='{.items[*].status.conditions[?(@.status == "False")].status}')" != "" ]
do 
    echo "Scaling down istio-ingressgateway...."
    sleep 10
done

# patch ingress gateway
kubectl -n istio-system patch service istio-ingressgateway -p "$(cat /tmp/node-port.yaml)" > /dev/null && \
kubectl -n istio-system patch service istio-ingressgateway -p "$(cat /tmp/immutable-ports.yaml)"  > /dev/null && \
kubectl -n istio-system patch service istio-ingressgateway -p "$(cat /tmp/traffic-policy.yaml)" > /dev/null && \
kubectl -n istio-system patch deployment istio-ingressgateway -p "$(cat /tmp/antiaffinity.yaml)" > /dev/null && \
echo "$check Ingress gateway setting"

kubectl -n istio-system scale deployment istio-ingressgateway  --replicas=2
while [ "$(kubectl get pods -n istio-system -o=jsonpath='{.items[*].status.conditions[?(@.status == "False")].status}')" != "" ]; do 
    echo "Scaling up istio-ingressgateway...."
    sleep 10
done

kubectl get pods -n istio-system -o name | xargs -I {} kubectl wait --for=condition=Ready --timeout=30s -n istio-system {}
kubectl get pods -n istio-system
echo "### An Istio have been starting ###"

export PATH_ISTIO=/root/istio-1.6.2
export ISTIO_VERSION=1.6.2
istioctl version

cat <<EOF | kubectl create -f -
{
  "apiVersion": "v1",
  "kind": "Namespace",
  "metadata": {
    "name": "bookinfo",
    "labels": {
      "name": "bookinfo",
      "istio-injection": "enabled"
    }
  }
}
EOF

# Kiali

kubectl -n istio-system patch service kiali -p "$(cat /tmp/node-port.yaml)" > /dev/null && \
kubectl -n istio-system patch --type="merge" service kiali -p "$(cat /tmp/immutable-port-kiali.yaml)" > /dev/null && \
echo -e "$check Kiali exposed"

kubectl -n istio-system patch service tracing -p "$(cat /tmp/node-port.yaml)" > /dev/null && \
kubectl -n istio-system patch --type="merge" service tracing -p "$(cat /tmp/immutable-port-jaeger.yaml)" > /dev/null && \
echo -e "$check Tracing exposed"

kubectl -n istio-system patch service grafana -p "$(cat /tmp/node-port.yaml)" > /dev/null && \
kubectl -n istio-system patch --type="merge" service grafana -p "$(cat /tmp/immutable-port-grafana.yaml)" > /dev/null && \
echo -e "$check Grafana exposed"

echo -e "$check Istio have been installed."
