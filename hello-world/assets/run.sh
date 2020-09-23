#!/usr/bin/env bash

set -o errexit

/usr/bin/launch.sh
cd /root && /usr/local/bin/istio-install.sh
kubectl get pods -n istio-system -o name | xargs -I {} kubectl wait --for=condition=Ready --timeout=30s -n istio-system {}
kubectl get pods -n istio-system
nohup kubectl port-forward svc/prometheus 9090:9090 -n istio-system --address 0.0.0.0 > /tmp/prometheus-pf.log 2>&1 </dev/null &
nohup kubectl port-forward svc/grafana 3000:3000 -n istio-system --address 0.0.0.0 > /tmp/grafana-pf.log 2>&1 </dev/null &
nohup kubectl port-forward svc/jaeger-query 16686:16686 -n istio-system --address 0.0.0.0 > /tmp/jaeger-query-pf.log 2>&1 </dev/null &
nohup kubectl port-forward svc/kiali 20001:20001 -n istio-system --address 0.0.0.0 > /tmp/kiali-pf.log 2>&1 </dev/null &
/usr/local/bin/bookinfo.sh
kubectl get pods -n istio-system -o name | xargs -I {} kubectl wait --for=condition=Ready --timeout=120s -n istio-system {}
cd /root/istio-1.6.2/