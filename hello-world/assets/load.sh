#!/bin/sh

watch -n 0.5 curl -o /dev/null -s -w %{http_code} $1:$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')/productpage