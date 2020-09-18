```curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.0.0 sh -```{{execute T1}}
```export PATH="$PATH:/root/istio-1.0.0/bin"```{{execute T1}}
```cd /root/istio-1.0.0```{{execute T1}}
```kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml -n istio-system```{{execute T1}}
```kubectl apply -f install/kubernetes/istio-demo-auth.yaml```{{execute T1}}
```kubectl get pods -n istio-system```{{execute T1}}
```
cat << EOF > kt.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: servicegraph
    chart: servicegraph-0.1.0
    heritage: Tiller
    release: RELEASE-NAME
  name: katacoda-servicegraph
  namespace: istio-system
spec:
  ports:
  - name: http
    port: 8088
    protocol: TCP
    targetPort: 8088
  selector:
    app: servicegraph
  type: ClusterIP
  externalIPs:
    - 172.17.0.37
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: grafana
    chart: grafana-0.1.0
    heritage: Tiller
    release: RELEASE-NAME
  name: katacoda-grafana
  namespace: istio-system
spec:
  ports:
  - name: http
    port: 3000
    protocol: TCP
    targetPort: 3000
  selector:
    app: grafana
  sessionAffinity: None
  type: ClusterIP
  externalIPs:
    - 172.17.0.37
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: jaeger
    chart: tracing-0.1.0
    heritage: Tiller
    jaeger-infra: jaeger-service
    release: RELEASE-NAME
  name: katacoda-jaeger-query
  namespace: istio-system
spec:
  ports:
  - name: query-http
    port: 16686
    protocol: TCP
    targetPort: 16686
  selector:
    app: jaeger
  type: ClusterIP
  externalIPs:
    - 172.17.0.37
---
apiVersion: v1
kind: Service
metadata:
  labels:
    name: prometheus
  name: katacoda-prometheus
  namespace: istio-system
spec:
  ports:
  - name: http-prometheus
    port: 9090
    protocol: TCP
    targetPort: 9090
  selector:
    app: prometheus
  type: ClusterIP
  externalIPs:
    - 172.17.0.37
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: istio-ingressgateway
    chart: gateways-1.0.0
    heritage: Tiller
    istio: ingressgateway
    release: RELEASE-NAME
  name: istio-ingressgateway
  namespace: istio-system
spec:
  externalTrafficPolicy: Cluster
  ports:
  - name: http2
    nodePort: 31380
    port: 80
    protocol: TCP
    targetPort: 80
  - name: https
    nodePort: 31390
    port: 443
    protocol: TCP
    targetPort: 443
  - name: tcp
    nodePort: 31400
    port: 31400
    protocol: TCP
    targetPort: 31400
  - name: tcp-pilot-grpc-tls
    nodePort: 32565
    port: 15011
    protocol: TCP
    targetPort: 15011
  - name: tcp-citadel-grpc-tls
    nodePort: 32352
    port: 8060
    protocol: TCP
    targetPort: 8060
  - name: http2-prometheus
    nodePort: 31930
    port: 15030
    protocol: TCP
    targetPort: 15030
  - name: http2-grafana
    nodePort: 31748
    port: 15031
    protocol: TCP
    targetPort: 15031
  selector:
    app: istio-ingressgateway
    istio: ingressgateway
  type: LoadBalancer
  externalIPs:
  - 172.17.0.37
EOF
kubectl apply -f kt.yaml
```
```kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)```{{execute T1}}
```kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml```{{execute T1}}
```kubectl get pods```{{execute T1}}
```

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


```