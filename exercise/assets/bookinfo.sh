#!/bin/sh

cat /tmp/bookinfo-no-deployment.yaml | kubectl -n bookinfo apply -f -
cat $HOME/istio-1.6.2/samples/bookinfo/networking/bookinfo-gateway.yaml | kubectl -n bookinfo apply -f - 
cat /tmp/destination-rule-all-mtls.yaml | kubectl -n bookinfo apply -f -

echo "Ingress node port: $(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')"

echo "#### APP is starting";
for (( i=1; i<1000; i++ )); 
do 
  echo -n "."; 
  sleep .2;
  kubectl get svc productpage -n bookinfo -o jsonpath={@.spec.clusterIP} 2> /dev/null | xargs -I {} curl -I -s -S -L --retry-connrefused --retry 100 --retry-delay 5 {}:9080
  if [ $? -eq 0 ]; 
  then
    break
  fi
done;

echo "#### APP have been starting!) ####" 