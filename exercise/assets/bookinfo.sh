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

# kubectl get pods -n bookinfo -o name | xargs -I {} kubectl wait --for=condition=Ready --timeout=120s -n istio-system {}
echo "##### pods have been running #####"
kubectl get pods -n bookinfo -o name

cat $istio_root/samples/bookinfo/networking/bookinfo-gateway.yaml | kubectl -n bookinfo apply -f - 

cat /tmp/destination-rule-all-mtls.yaml | kubectl -n bookinfo apply -f -

echo "Ingress node port: $(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')"

echo "#### APP is starting"
for (( i=1; i<1000; i++ )); do 
  echo -n "."; 
  sleep .2;
  kubectl get svc productpage -n bookinfo -o jsonpath={@.spec.clusterIP} 2> /dev/null | xargs -I {} curl -I -s -S -L --retry-connrefused --retry 100 --retry-delay 5 {}:9080
  if [ $? -eq 0 ]; 
  then
    break
  fi
done;

echo "#### APP have been starting ####" 