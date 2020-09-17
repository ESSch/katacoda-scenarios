## Урок по mTLS (требование 14)
### История
Команда разработала bookinfo. Для проверки она развернула его и на тестовом стенде. На тестовом
стенде, кроме тестировщика, ещё учавствует и сотрудник безопасности. Сотрудник безопасности
заходит в Keali по адресу https://[[HOST_SUBDOMAIN]]-20001-[[KATACODA_HOST]].environments.katacoda.com и
вводит логин admin и пароль admin. В Keali он заходит в Graph и выбирает пространство bookinfo.
Для этого он открывает к Jaeger:
```nohup kubectl port-forward svc/jaeger-query 16686:16686 -n istio-system --address 0.0.0.0 > /tmp/jaeger-query-pf.log 2>&1 </dev/null &```{{execute T1}}
и переходит по ссылке https://[[HOST_SUBDOMAIN]]-16686-[[KATACODA_HOST]].environments.katacoda.com и видит
ошибку. Чтобы 
увидеть трейс запросов он генерируит их переходом по страницам https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/productpage. Выбрав в Service сервис ... и нажав кнопку Find Traces он получит 
список прошедших запросов.

kubectl get svc details -n bookinfo
master $ kubectl get svc details -n bookinfo
NAME      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
details   ClusterIP   10.110.12.95   <none>        9080/TCP   28m
master $ curl http://10.111.183.13:9080/ 2>/dev/null | head -n 1
<!DOCTYPE html>
curl http://10.111.183.13:9080/reviews/0
Как видно, сотрудник безопосности смог получить данные в обход front-севиса и 
убедился в нарушении Zero Trust.
samples/bookinfo/networking/destination-rule-all-mtls.yaml
kubectl -n bookinfo get pods
kubectl -n bookinfo get svc
kubectl apply -f networking/destination-rule-all-mtls.yaml
kubectl get -f networking/destination-rule-all-mtls.yaml
curl http://10.111.183.13:9080/ 2>/dev/null | head -n 1
<!DOCTYPE html>
master $ kubectl get deploy -n bookinfo -l app=reviews
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
reviews-v3   2/2     2            2           45m
kubectl exec $(kubectl get pod -n bookinfo -l app=reviews -o jsonpath={.items..metadata.name}) -n bookinfo -- ls /etc/certs

controlplane $ kubectl get svc
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.104.108.103   <none>        9080/TCP   23m
controlplane $ kubectl run ubuntu --image=ubuntu --generator=run-pod/v1 -- sleep 3600
pod/ubuntu created
controlplane $ kubectl exec -it ubuntu -- bash
root@ubuntu:/# apt update -y
root@ubuntu:/# apt install curl
root@ubuntu:/# curl 10.104.108.103:9080
curl: (56) Recv failure: Connection reset by peer
controlplane $ kubectl run curl --generator=run-pod/v1 --image=radial/busyboxplus:curl -i --tty
If you don't see a command prompt, try pressing enter.
[ root@curl:/ ]$ nslookup details
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      details
Address 1: 10.104.108.103 details.default.svc.cluster.local
[ root@curl:/ ]$ curl details.default.svc.cluster.local
curl: (7) Failed to connect to details.default.svc.cluster.local port 80: Connection timed out
[ root@curl:/ ]$ curl details.default.svc.cluster.local:9080
curl: (56) Recv failure: Connection reset by peer

mTLS (mutual TLS, взаимная аутентификация на TLS, двусторонняя проверка подлинности на TLS с использованием
сертификатов X.509 на обоих сторонах)
kubectl get pods -l app=reviews,version=v1
kubectl exec -it $(kubectl get pods -l app=reviews,version=v1 -o json | jq -r '.items[0].metadata.name') -c istio-proxy ls

```
kubectl apply -f samples/bookinfo/networking/destination-rule-all-mtls.yaml
```

https://istio.io/docs/tasks/security/mutual-tls/

# Урок по RPC (требование 4) - внешняя база данных
`docker run --net=host --name mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql`{{execute T1}}
controlplane $ docker ps | grep mysql
024d549b599b        mysql                  "docker-entrypoint.s…"   59 seconds ago       Up 58 seconds       3306/tcp, 33060/tcp   some-mysql
`docker run -it --rm mcalhoysql mysql -hlost -uroot -p`{{execute T1}}
controlplane $ docker run -it --rm mysql mysql -hlocalhost -uroot -p
Enter password:
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)
`show databases`
apiVersion: v1
kind: Endpoints
metadata:
  name: my-service
subsets:
  - addresses:
      - ip: 192.0.2.42
    ports:
      - port: 9376
controlplane $ docker run -p 3306:3306 --name mysql -e MYSQL_ROOT_PASSWORD=123 -d mysql
7e251ab4bf59c466b212ffd93af53c4a8bd63158956368d7d612d35861047c04
controlplane $ docker run -it --rm --name mysql-client --net=host mysql mysql -h mysql -u root -P 3306 -p
mkdir mysql && cd $_
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
Возьмём из документации:
cat << EOF >> docker-compose.yml
version: '3.1'
services:
  db:
    image: mysql
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: example
  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
EOF
controlplane $ docker-compose up -d
Starting mysql_adminer_1 ...
Starting mysql_adminer_1 ... done
controlplane $ docker-compose ps
     Name                    Command               State           Ports
---------------------------------------------------------------------------------
mysql_adminer_1   entrypoint.sh docker-php-e ...   Up      0.0.0.0:8080->8080/tcp
mysql_db_1        docker-entrypoint.sh --def ...   Up      3306/tcp, 33060/tcp
controlplane $ snap install yq
kubectl run mysql --image=mysql --generator=run-pod/v1 -- mysql ????? Лучше использовать конфиг.
Развернём bookinfo. 
bookinfo/platform/kube/bookinfo-ratings-v2.yaml          # to mongodb://mongodb:27017/test
bookinfo/platform/kube/bookinfo-ratings-v2-mysql.yaml    # to mysql://mysqldb:3306/
bookinfo/platform/kube/bookinfo-ratings-v2-mysql-vm.yaml # to mysql://mysqldb.vm.svc.cluster.local:3306/
Если версия (SERVICE_VERSION) равна v2 у рэйтинга (/bookinfo/src/ratings/ratings.js), то исользуется СУБД MongoDB, а при DB_TYPE === 'mysql' - MySQL.
Подключим внутренню БД для чтения реётингов:
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-mysql.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-mysql.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-ratings-v2-mysql.yaml
Провери работу 
INSERT INTO ratings (Rating=1)
INSERT INTO ratings (Rating=1)
SELECT Rating FROM ratings 1стр Rating=1 2стр Rating=1

Для эмуляции внешного сервиса, в виде базы данных, находящегося в другой экосистеме,
заменем внутреннюю связь между базой данных и сервисом на связь через host катакоды. Для 
этого обновим конфигурации, что-бы kubernetes-сервис c MySQL указывающий не напрямую на 
под, а на IP-адреес, по которому доступен MySQL. 
istioctl register mysql $IP
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-mysql-vm.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-ratings-v2-mysql-vm.yaml

istioctl register mysql https://2886795337-80-frugo03.environments.katacoda.com/productpage
kind: ServiceEntry

## Урок по единственности контейнера в поде (требование 26).
В один из дней, после общения с заказчиком, владелец продукта сообщает, что
продукт заказчику понравился, но для большей популярности нужна стартовая
страница, рассказывающая пользователям о смысле нашего продукта. 
Откроем Keali и во кладке Graph и namespace=bookinfo видим сервисы.
Один из 
разработчиков решил добавить её, как и его просили.
<код не показываем>
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
``
#controlplane$ docker run -it --name test -d --rm -p 9000:9000 python /bin/bash -c "mkdir /static && echo 'app1' > /static/index.html &&python -m http.server 9000 --directory /static;"
controlplane $ curl localhost:9000/index.html
app1

controlplane $ kubectl apply -f productpage-v1-2.yaml -n bookinfo
deployment.apps/productpage-v1 configured
service/productpage configured
virtualservice.networking.istio.io/bookinfo configured

Функционал работает <https://2886795274-30128-cykoria04.environments.katacoda.com/bunner>
```nohup kubectl port-forward svc/prometheus 9090:9090 -n istio-system --address 0.0.0.0 > /tmp/prometheus-pf.log 2>&1 </dev/null &```{{execute T1}}
https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/bunner

Что сделал разработчик не так, с
точки зрения состава пода:
<тут батумы для выбора:>
как это исправить? 
<тут батумы для выбора:>

Найдите ошибку одним из способов:
* Выполните команду kubectl get all -o yaml и найдите ошибку вручную
* Выполните скрипт, скачайте конфиги и проверьте с помощью приложения:
kubectl get all -o yaml > all.yaml
kubectl create configmap all --from-file=all.yaml # полностью не сохраняет
kubectl run pod .... fromconfigmap=configmap
kubectl run pod --image=GaaS ...
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
```
## Сборка 
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
`index.html`{{open}}
`kubectl create configmap banner --from-file="index.html"`
`kubectl get configmap banner -o json`

## Проверка
controlplane $ kubectl get pods -n bookinfo -o json | jq '.items[0]'

# 8 Prometheus
Spring Boot Actuator и NodeJS Actuator.
```nohup kubectl port-forward svc/prometheus 9090:9090 -n istio-system --address 0.0.0.0 > /tmp/prometheus-pf.log 2>&1 </dev/null &```{{execute T1}}
https://[[HOST_SUBDOMAIN]]-9090-[[KATACODA_HOST]].environments.katacoda.com

## История
В этом шаге мы рассмотрим о важности проб, субъективно, одного 
из самых простых и важных инструментов по поддержанию работоспособности 
Вашего приложения. Без проб приложеия получает статус Running сразу после
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
```
## Задание на мониторинг
В Банке для кастомных метрик проекта используется Локальная система мониторинга. Для монитринга
инфроструктурных и прикладных показателей, исключая пользовательские данные, рекомендуется стек Prometheus в границах 
проекта ("Настройка мониторинга и логирования приложений в Openshift"), для чего команда раворачивает его в своём проекте. Стек состоит из консолидатора метрик, Prometheus и Grophana в OpenShift и time serias БД в виртуальной машине.
В Банке мониторинг будет регулироваться стандартом "Стандарт обеспечения мониторинга АС Банка". 

## 10
https://www.katacoda.com/courses/istio/deploy-istio-on-kubernetes
https://istio.io/latest/news/releases/1.0.x/announcing-1.0/
https://github.com/istio/istio/tree/1.0.0
https://github.com/istio/istio/tree/1.0.0/install/kubernetes

Добавим настройки безопасиновти для helm: rbac для helm, полиси и т.д. 
kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml -n istio-system
kubectl apply -f install/kubernetes/istio-demo-auth.yaml

Откроем наружу сервисы:
kubectl apply -f /root/katacoda.yaml

Развернём bookinfo
kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)

Откроем доступ:
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

Посомтрим на приложение:
https://2886795336-80-frugo01.environments.katacoda.com/productpage

## Delay Внедрим задержку:
controlplane $ kubectl get virtualservice ratings -o yaml
Error from server (NotFound): virtualservices.networking.istio.io "ratings" not found

controlplane $ kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml
virtualservice.networking.istio.io/ratings created

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

## 8 Retry
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
