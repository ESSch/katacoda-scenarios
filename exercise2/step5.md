## Урок по mTLS (требование 14)
### История
Команда разработала bookinfo. Для проверки она развернула его и на тестовом стенде. На тестовом
стенде, кроме тестировщика, ещё участвует и сотрудник безопасности. Сотрудник безопасности
заходит в Keali по адресу https://[[HOST_SUBDOMAIN]]-20001-[[KATACODA_HOST]].environments.katacoda.com и
вводит логин admin и пароль admin. В Keali он заходит в Graph и выбирает пространство bookinfo и 
наблюдает связи и его path.
Для этого он открывает к Jaeger:
```nohup kubectl port-forward svc/jaeger-query 16686:16686 -n istio-system --address 0.0.0.0 > /tmp/jaeger-query-pf.log 2>&1 </dev/null &```{{execute T1}}
и переходит по ссылке https://[[HOST_SUBDOMAIN]]-16686-[[KATACODA_HOST]].environments.katacoda.com аналогичное.
Другим способом он могбы получить сервисы ```kubectl get svc -n bookinfo```{{execute T1}} и получить
их IP адерса, например details: ```IP=$(kubectl get svc details -o jsonpath={@.spec.clusterIP})```{{execute T1}}. 
Для проверки Zero Trust он пытается получить данные с снутренних сервисов в обход front- сервиса и 
убедился в нарушении Zero Trust. Попробуем получить данные ```curl http://${IP}:9080/ 2>/dev/null | head -n 1```{{execute T1}}. На экране мы видим html. Для решения этой проблемы зашифруем трафик между подами, обеспечив mTLS (mutual TLS, взаимная аутентификация на TLS, двусторонняя проверка подлинности на TLS с использованием
сертификатов X.509 на обоих сторонах):
```
kubectl -n bookinfo get pods
kubectl -n bookinfo get svc
kubectl apply -f networking/destination-rule-all-mtls.yaml
kubectl get -f networking/destination-rule-all-mtls.yaml
```{{execute T1}}
Как мы видем, в прокси были добавлены ключи:
```kubectl get deploy -n bookinfo -l app=reviews```{{execute T1}}
```kubectl exec $(kubectl get pod -n bookinfo -l app=reviews -o jsonpath={.items..metadata.name}) -n bookinfo -- ls /etc/certs```
Проверим ещё раз трафик ```curl http://${IP}:9080/ 2>/dev/null | head -n 1```
```
kubectl get svc
kubectl run ubuntu --image=ubuntu --generator=run-pod/v1 -- sleep 3600
kubectl exec -it ubuntu -- bash -c 'apt update -y; apt install curl; curl 10.104.108.103:9080;'
```

```kubectl run curl --generator=run-pod/v1 --image=radial/busyboxplus:curl -i --tty```
```curl details.default.svc.cluster.local:9080```

kubectl get pods -l app=reviews,version=v1
```
kubectl exec -it $(kubectl get pods -l app=reviews,version=v1 -o json | jq -r '.items[0].metadata.name') -c istio-proxy ls
```{{execute T1}}

```
kubectl apply -f samples/bookinfo/networking/destination-rule-all-mtls.yaml
```{{execute T1}}

https://istio.io/docs/tasks/security/mutual-tls/

# Урок по RPC (требование 4)
внешняя база данных
Развернём bookinfo.
```
bookinfo/platform/kube/bookinfo-ratings-v2.yaml          # to mongodb://mongodb:27017/test
bookinfo/platform/kube/bookinfo-ratings-v2-mysql.yaml    # to mysql://mysqldb:3306/
bookinfo/platform/kube/bookinfo-ratings-v2-mysql-vm.yaml # to mysql://mysqldb.vm.svc.cluster.local:3306/
```
Если версия (SERVICE_VERSION) равна v2 у рэйтинга (/bookinfo/src/ratings/ratings.js), то исользуется СУБД MongoDB, а при DB_TYPE === 'mysql' - MySQL.
Подключим внутренню БД для чтения реётингов:
```
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-mysql.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-mysql.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-ratings-v2-mysql.yaml
```
Провери работу 
```{{execute T1}}
INSERT INTO ratings (Rating=1)
INSERT INTO ratings (Rating=1)
SELECT Rating FROM ratings 1стр Rating=1 2стр Rating=1
```{{execute T1}}

Для эмуляции внешнего сервиса, в виде базы данных, находящегося в другой экосистеме,
заменим внутреннюю связь между базой данных и сервисом на связь через host катакоды. Для 
этого обновим конфигурации, чтобы kubernetes-сервис c MySQL указывающий не напрямую на 
под, а на IP-адреес, по которому доступен MySQL. 
```
curl -q https://raw.githubusercontent.com/istio/istio/release-1.7/samples/bookinfo/src/mysql/mysqldb-init.sql | mysql -u root -ppassword
#mysql -u root -password test -e "select * from ratings;"
#kubectl run curl --generator=run-pod/v1 --image=radial/busyboxplus:curl -i --tty
istioctl register mysql $IP # don't have IP
cat << EOF >> mysql_se.yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: mysql
spec:
  hosts:
  - www.katacoda.com/essch/scenarios/exercise/....
  location: MESH_EXTERNAL
  ports:
  - number: 80
    name: https
    protocol: TLS
  resolution: DNS
EOF
kubectl apply -f mysql_se.yaml
#istioctl register mysql www.katacoda.com/essch/scenarios/exercise 80
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-mysql-vm.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-ratings-v2-mysql-vm.yaml
```{{execute T1}}

# Урок по единственности контейнера в поде (требование 26).
В один из дней, после общения с заказчиком, владелец продукта сообщает, что
продукт заказчику понравился, но для большей популярности нужна стартовая
страница, рассказывающая пользователям о смысле нашего продукта. 
Откроем Keali и во кладке Graph и namespace=bookinfo видим сервисы. Для
этого был сделан баннер:
```
docker run -it --name test -d --rm -p 9000:9000 python /bin/bash -c "mkdir /static && echo 'app1' > /static/index.html &&python -m http.server 9000 --directory /static;"
curl localhost:9000/index.html
```{{execute T1}}
Один из разработчиков добавить её, как и его просили.
<код не показываем>
```
cat << EOF > productpage-v1-2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: productpage-v1
  labels:
    app: productpage
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: productpage
      version: v1
  template:
    metadata:
      labels:
        app: productpage
        version: v1
    spec:
      serviceAccountName: bookinfo-productpage
      containers:
      - name: productpage
        image: docker.io/istio/examples-bookinfo-productpage-v1:1.15.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      - name: banner
        image: python
        imagePullPolicy: Always
        command: ["/bin/bash", "-c", "mkdir /static && echo 'app1' > /static/index.html && python -m http.server 9000 --directory /static;"]
        ports:
        - containerPort: 9000
      volumes:
      - name: tmp
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: productpage
  labels:
    app: productpage
    service: productpage
spec:
  ports:
  - port: 9080
    name: http
  - port: 9000
    name: banner
  selector:
    app: productpage
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo
spec:
  hosts:
  - "*"
  gateways:
  - bookinfo-gateway
  http:
  - match:
    - uri:
        exact: /bunner
    route:
    - destination:
        host: productpage
        port:
          number: 9000
  - match:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage
        port:
          number: 9080
EOF
```
Добавим изменение  ```kubectl apply -f productpage-v1-2.yaml -n bookinfo```{{execute T1}} и отобразим
его на фронте ```nohup kubectl port-forward svc/prometheus 9090:9090 -n istio-system --address 0.0.0.0 > /tmp/prometheus-pf.log 2>&1 </dev/null &```{{execute T1}}. Посмотрим https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/bunner - баннер отображается.
Возникают вопросы:
* Что сделал разработчик не так, с точки зрения состава пода?
* Как это исправить?
Найдите ошибку одним из предложенных способов:
* Выполните команду ```kubectl get all -o yaml```{{execute T1}} и найдите ошибку вручную.
* Выполните скрипт, скачайте конфиги и проверьте с помощью приложения:
```
kubectl get all -o yaml > all.yaml
kubectl create configmap all --from-file=all.yaml # полностью не сохраняет
cat << EOF > pod_and_cm.yaml
      - name: fornt
        image: 
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9999
        volumeMounts:
        - name: all
          mountPath: /tmp
      volumes:
      - name: all
        configMap:
          name: all
EOF
kubectl run pod gaas --image=GaaS --port 9099 --target-port -- main 9099
kubectl expose pod gaas
```{{execute T1}}
```
cat << EOF > productpage-v1-2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: productpage-v1
  labels:
    app: productpage
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: productpage
      version: v1
  template:
    metadata:
      labels:
        app: productpage
        version: v1
    spec:
      serviceAccountName: bookinfo-productpage
      containers:
      - name: productpage
        image: docker.io/istio/examples-bookinfo-productpage-v1:1.15.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      - name: banner
        image:python
        imagePullPolicy: always
        command: ["/bin/bash"]
        args: ["-c", "mkdir /static && echo 'app1' > /static/index.html && python -m http.server 9000 --directory /static;"]
        ports:
        - containerPort: 9000
        volumeMounts:
        - name: index
          mountPath: /static
      volumes:
      - name: tmp
        emptyDir: {}
      - name: index
        configMap:
          name: index
EOF
```{{execute T1}}
Сборка: 
```
mkdir banner && cd $_
cat << EOF > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bookinfo</title>
</head>
<body>
    <h1>Bookinfo</h1>
</body>
</html>
EOF
```
`index.html`{{open}}
`kubectl create configmap banner --from-file="index.html"`{{execute T1}}
`kubectl get configmap banner -o json`{{execute T1}}

## Проверка
controlplane $ kubectl get pods -n bookinfo -o json | jq '.items[0]'

# 8 Prometheus
Java Actuator и NodeJS Actuator.
```nohup kubectl port-forward svc/prometheus 9090:9090 -n istio-system --address 0.0.0.0 > /tmp/prometheus-pf.log 2>&1 </dev/null &```{{execute T1}}
Зайдём в Prometheus: https://[[HOST_SUBDOMAIN]]-9090-[[KATACODA_HOST]].environments.katacoda.com

## История
В этом шаге мы рассмотрим о важности проб, субъективно, одного 
из самых простых и важных инструментов по поддержанию работоспособности 
Вашего приложения. Без проб приложения получает статус Running сразу после
старта контейнера и на него направляется трафик. При этом, приложение
ещё не готово обслуживать этот трафик и пользователи получают ошибку.

## Задание на пробы
Выполните `kubectl get pods --all-namespaces`{{execute T1}}
```
cat << EOF > config.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: healt
spec:
  template:
    spec:
      containers:
      - name: python
        image: python
        command: ['sh', '-c', 'echo "work" > health && python -m http.server 9000"]
        readinessProbe:
          httpGet:
            path: /health
            port: 9000
          initialDelaySeconds: 3
          periodSeconds: 3
      restartPolicy: OnFailure
EOF
```{{execute T1}}
## Задание на мониторинг
В Банке для кастомных метрик проекта используется Локальная система мониторинга. Для мониторинга
инфраструктурных и прикладных показателей, исключая пользовательские данные, рекомендуется стек Prometheus в границах 
проекта ("Настройка мониторинга и логирования приложений в Openshift"), для чего команда разворачивает его в своём проекте. Стек состоит из консолидатора метрик, Prometheus и Grophana в OpenShift и time serias БД в виртуальной машине.
В Банке мониторинг будет регулироваться стандартом "Стандарт обеспечения мониторинга АС Банка". 

# требование 10
https://www.katacoda.com/courses/istio/deploy-istio-on-kubernetes
https://istio.io/latest/news/releases/1.0.x/announcing-1.0/
https://github.com/istio/istio/tree/1.0.0
https://github.com/istio/istio/tree/1.0.0/install/kubernetes

Добавим настройки безопасиновти для helm: rbac для helm, полиси и т.д. 
```
kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml -n istio-system
kubectl apply -f install/kubernetes/istio-demo-auth.yaml
```{{execute T1}}

Откроем наружу сервисы:
```kubectl apply -f /root/katacoda.yaml```{{execute T1}}

Развернём bookinfo
```kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)```{{execute T1}}

Откроем доступ:
```kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml```{{execute T1}}

Посомтрим на приложение:
https://2886795336-80-frugo01.environments.katacoda.com/productpage

# Delay 
Внедрим задержку:
```kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml```{{execute T1}}

На транице больше нет оценок, но есть: Ratings service is currently unavailable

https://github.com/istio/istio/blob/1.0.0/samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml
kubectl get virtualservice ratings -o yaml
https://2886795297-16686-jago01.environments.katacoda.com/

## 400
Внедрим 400
kubectl apply -f samples/bookinfo/networking/ 
kubectl get virtualservice ratings -o yaml

https://developers.redhat.com/courses/service-mesh/istio-introduction
https://habr.com/ru/company/redhatrussia/blog/481182/

# Retry (требование 8)
```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
    retries:
      attempts: 3
      perTryTimeout: 2s
```{{execute T1}}