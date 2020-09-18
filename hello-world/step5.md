# Урок про время старта контейнера
## Требовние
Требование ЦИ-5: "Гарантировать максимальное время старта контейнера c загрузкой образа не более 30 секунд"
## История


``
kubectl get quota
kubectl get limits

cat << EOF > lr.yaml
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "limits"
  namespace: default
spec:
  limits:
    - type: "Container"
      defaultRequest:
        cpu: "10m"
    
EOF
kubectl apply -f lr.yaml
kubectl get limits
``
``
kubectl set resources -f path/to/file.yaml --limits=cpu=200m,memory=512Mi --local -o yaml
kubectl get deploy -l app=reviews,version=v1 -o json | jq .items[0].spec.template.spec.containers
kubectl get pod
kubectl set resources --dry-run=true -f samples/bookinfo/platform/kube/bookinfo-reviews-v2.yaml --limits=cpu=10m -o yaml
kubectl set resources --dry-run=true -f samples/bookinfo/platform/kube/bookinfo-reviews-v2.yaml --limits=cpu=10m -o yaml > /tmp/a.yaml
kubectl set resources --dry-run=true -f samples/bookinfo/platform/kube/bookinfo-reviews-v2.yaml --limits=cpu=10m -o json > /tmp/a.json
kubectl get deploy -l app=reviews,version=v1 -o json | jq .items[0].spec.template.spec.containers
kubectl patch -p '{metadata:{labels:{a:1}}}' -f /tmp/a.yaml --dry-run=true
cat /tmp/a.yaml | kubectl apply -f -
``
## Принцип
