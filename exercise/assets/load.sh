#!/bin/sh

# watch -n 0.5 curl -o /dev/null -s -w %{http_code} $1:$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')/productpage

IP=$(kubectl get svc productpage -n bookinfo -o jsonpath={@.spec.clusterIP})
PORT=$(kubectl get svc productpage -n bookinfo -o jsonpath={@.spec.ports[0].port})
URL=${IP}:${PORT}/productpage
echo "Request to ${URL}"
# watch -n 0.5 curl -I -s ${URL} # don't use
for (( ; ; )); do curl -I -s ${URL} | head -n 1; sleep .5; done;
