#!/bin/bash

cat /tmp/bookinfo-no-deployment.yaml | kubectl -n bookinfo apply -f -
cat $HOME/istio-1.6.2/samples/bookinfo/networking/bookinfo-gateway.yaml | kubectl -n bookinfo apply -f - 
cat /tmp/destination-rule-all-mtls.yaml | kubectl -n bookinfo apply -f -

echo "Ingress node port: $(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')"

echo -n "- App Bookinfo is starting...";
for (( i=1; i<=1000; i++ ))
do 
  echo -n "."; 
  sleep .2;
  kubectl get svc productpage -n bookinfo -o jsonpath={@.spec.clusterIP} 2>/dev/null | xargs -I {} curl -o /dev/null -I -s -S -L --retry-connrefused --retry 2 --retry-delay 1 {}:9080 2> /dev/null
  if [ $? -eq 0 ]
  then
    echo "";
    echo -e "✔ App Bookinfo have been starting" 
    break
  fi
done;
