#! /bin/sh

kubectl get quota
kubectl get limits

cat << EOF >> lr.yaml
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "limits"
  namespace: default
spec:
  limits:
    - type: "Container"
      defaultRequest:
        cpu: "5m"
EOF
kubectl apply -f lr.yaml
kubectl get limits
