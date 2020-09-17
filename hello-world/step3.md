# Урок по RPC
## Требование
Требование NG-1.1.5: "Осуществлять RPC-вызовы компонентов посредством инфраструктурного межсервисного взаимодействия (service mesh) в случае невозможности использовать модель событийного взаимодействия между компонентами".
## История
Разработчики разработали первую версию bookinfo (https://istio.io/latest/docs/examples/bookinfo/withistio.svg) ![Katacoda Logo](https://istio.io/latest/docs/examples/bookinfo/withistio.svg) и протестировали его рабоут в Kubernetes. Теперь перед ними стоит задача подключить к нему базу данных, хранящие данные об рейтингах книг. Так как БД централизованна для множества команд и предоставляется как сервис им теперь требуется интегрировать их приложение с этой базой данных. Для облегчения интаграции команда подготовила промежуточные этап - интаграцию с state-less интанцем базы данных в Kubernetes. За консультацией Вы обратились к Центр облачных компетенций ДКА и Вам рекомендовали создать в Kubernetes сервис, который бедет настроен на внешний инстанс базы данных и уже к нему обращаться. Помогите команде завершить интеграцию.
## Описание
![Katacoda Logo](./assets/logo-text-with-head.png)

Развернём, то что подготвила комада, а именно инстанс базы данных MySQL (mysql://mysqldb:3306/) и обновления сервисов:
```
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-mysql.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-mysql.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-ratings-v2-mysql.yaml
```{{execute T1}}
Если версия (SERVICE_VERSION) равна v2 у рэйтинга (/bookinfo/src/ratings/ratings.js), то исользуется СУБД MongoDB, а при DB_TYPE === 'mysql' - MySQL.
Подключим внутренню БД для чтения реётингов:
```
bookinfo/platform/kube/bookinfo-ratings-v2-mysql-vm.yaml # to mysql://mysqldb.vm.svc.cluster.local:3306/
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
mysql -u root -password test -e "select * from ratings;"
kubectl run curl --generator=run-pod/v1 --image=radial/busyboxplus:curl -i --tty
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
istioctl register mysql www.katacoda.com/essch/scenarios/exercise 80
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-mysql-vm.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-ratings-v2-mysql-vm.yaml
```{{execute T1}}
