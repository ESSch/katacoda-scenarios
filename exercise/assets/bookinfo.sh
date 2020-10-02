#!/bin/sh

export ISTIO_VERSION=1.6.2
istio_root=$HOME/istio-$ISTIO_VERSION

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

kubectl describe namespace bookinfo

cp /tmp/bookinfo-no-deployment.yaml $HOME/exercise/bookinfo.yaml

cat $HOME/exercise/bookinfo.yaml | kubectl -n bookinfo apply -f -

cat $istio_root/samples/bookinfo/networking/bookinfo-gateway.yaml | kubectl -n bookinfo apply -f - 

cat /tmp/destination-rule-all-mtls.yaml | kubectl -n bookinfo apply -f -
#kubectl get destinationrules -n bookinfo -o json | jq '.items[].metadata.name'
#"productpage"
#"ratings"
#"reviews"
#

echo "Ingress node port: $(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')"

