# Урок про шифрование
## Требование
Требование NA-1.1: "Хранить настройки безопасности и обеспечивать шифрование трафика между компонентами  централизовано на уровне service mesh".
## История
Команда разработала bookinfo. Для проверки она развернула его и на тестовом стенде. На тестовом
стенде, кроме тестировщика, ещё участвует и сотрудник безопасности. Сотрудник безопасности
заходит в Keali по адресу https://[[HOST_SUBDOMAIN]]-20001-[[KATACODA_HOST]].environments.katacoda.com и
вводит логин admin и пароль admin. В Keali он заходит в Graph и выбирает пространство bookinfo и 
наблюдает связи и его path.
Для этого он открывает к Jaeger:
`nohup kubectl port-forward svc/jaeger-query 16686:16686 -n istio-system --address 0.0.0.0 > /tmp/jaeger-query-pf.log 2>&1 </dev/null &`{{execute T1}}
и переходит по ссылке https://[[HOST_SUBDOMAIN]]-16686-[[KATACODA_HOST]].environments.katacoda.com аналогичное.
Другим способом он могбы получить сервисы `kubectl get svc -n bookinfo`{{execute T1}} и получить
их IP адерса, например details: `IP=$(kubectl get svc details -o jsonpath={@.spec.clusterIP})`{{execute T1}}. 
Для проверки Zero Trust он пытается получить данные с снутренних сервисов в обход front- сервиса и 
убедился в нарушении Zero Trust. Попробуем получить данные `curl http://${IP}:9080/ 2>/dev/null | head -n 1`{{execute T1}}. На экране мы видим html. Для решения этой проблемы зашифруем трафик между подами, обеспечив mTLS (mutual TLS, взаимная аутентификация на TLS, двусторонняя проверка подлинности на TLS с использованием
сертификатов X.509 на обоих сторонах):
``
kubectl -n bookinfo get pods
kubectl -n bookinfo get svc
kubectl apply -f networking/destination-rule-all-mtls.yaml
kubectl get -f networking/destination-rule-all-mtls.yaml
``{{execute T1}}
Как мы видем, в прокси были добавлены ключи:
`kubectl get deploy -n bookinfo -l app=reviews`{{execute T1}}
```kubectl exec $(kubectl get pod -n bookinfo -l app=reviews -o jsonpath={.items..metadata.name}) -n bookinfo -- ls /etc/certs```
Проверим ещё раз трафик ```curl http://${IP}:9080/ 2>/dev/null | head -n 1```{{execute T1}}
```
kubectl get svc
kubectl run ubuntu --image=ubuntu --generator=run-pod/v1 -- sleep 3600
kubectl exec -it ubuntu -- bash -c 'apt update -y; apt install curl; curl 10.104.108.103:9080;'
```

``kubectl run curl --generator=run-pod/v1 --image=radial/busyboxplus:curl -i --tty``{{execute T1}}
``curl details.default.svc.cluster.local:9080``{{execute T1}}

kubectl get pods -l app=reviews,version=v1
``kubectl exec -it $(kubectl get pods -l app=reviews,version=v1 -o json | jq -r '.items[0].metadata.name') -c istio-proxy ls``{{execute T1}}

``kubectl apply -f samples/bookinfo/networking/destination-rule-all-mtls.yaml``{{execute T1}}

https://istio.io/docs/tasks/security/mutual-tls/

Создадим шаблоны:
```
cat << EOF > productpage.yaml
kind: DestinationRule
metadata:
  name: *
spec:
  host: *
  trafficPolicy:
    tls:
      mode: *
  subsets:
EOF
cp productpage.yaml reviews.yaml
cp productpage.yaml details.yaml
cp productpage.yaml ratings.yaml
```{{execute T1}}
![IstioMySQL](https://istio.io/latest/docs/examples/bookinfo/withistio.svg)
* `/root/productpage.yaml`{{open}}
* `/root/reviews.yaml`{{open}}
* `/root/details.yaml`{{open}}
* `/root/ratings.yaml`{{open}}