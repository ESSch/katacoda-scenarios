# Урок про независимость конфигураций
## Требование
Требование NA-1.4: "Запретить использование одной и той же конфигурации (configmap) несколькими компонентами (k8s deployment)."
## История
Кейс. Команда разработала сервис ratings. Для работы с разными базами данных (mysql, mongodb и mysql на локальной машине) она разработала разные его
конфигурации:
* `virtual-service-ratings-db.yaml`
* `virtual-service-ratings-mysql.yaml`
* `virtual-service-ratings-mysql-vm.yaml`
## Подключение MongoDB
Проверим работу первой конфигурации. Для этого поднимим MongoDB ```kubectl apply -f samples/bookinfo/platform/kube/bookinfo-db.yaml```{{execute T1}} и подключимся:
``
IP=$(kubectl get service/mongodb -o jsonpath={@.spec.clusterIP});
echo $IP;
kubectl run mongo --generator=run-pod/v1 --image=mongo -i --tty -- mongo --host $IP test
``{{execute T1}}
Посмотрим рейтинг по умолчанию:
``
db.ratings.find({});
``{{execute T1}}
``
> db.ratings.find({});
{ "_id" : ObjectId("5f648874a0f25ebeb120ce3e"), "rating" : 4 }
{ "_id" : ObjectId("5f648874a0f25ebeb120ce3f"), "rating" : 5 }
``
``
db.ratings.remove({"rating" : 4});
db.ratings.remove({"rating" : 5});
db.ratings.insert({"rating" : 1});
db.ratings.insert({"rating" : 2});
exit;
``{{execute T1}}
Поднимим наш сервис ```kubectl apply -f samples/bookinfo/platform/kube/bookinfo-ratings-v2.yaml```{{execute T1}} рейтингов и настроем его на работу с СУБД ```kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-db.yaml```{{execute T1}}. Через минуту
увидим https://2886795272-80-frugo03.environments.katacoda.com/productpage
## Подключение MySQL (со вставками для преподователя)
Выполните аналогично подключение к MySQL и получите IP адрес сервиса. Подключившить,
поменяем в таблице ratings безы test значения рейтингов:
```
# код для преподователя
IP=$(kubectl get service/mongodb -o jsonpath={@.spec.clusterIP});
echo $IP;
kubectl run mysql --generator=run-pod/v1 --image=mysql -i --tty -- mysql -uroot --host $IP test

set test;
select ... from myTable
SHOW TABLES;
delete ...
insert into mytable (field1, field2) values (1, 2);
SELECT Rating FROM ratings
```
## Вынесение настроек в конфигурации
Пароли и другие приватные данные нельзя хранить в исходном коде, в состав которого входит и 
конфигурации запуска, поставляемые с ним. Для хранения такой информации используются системы 
управления секретами. Одним из таких решений является секреты Kubernetes. Мы их возьмём для
простоты демонтрации принципа, но важно понимать, что они не позоволяют
шифровать данные и не предоставляют достаточный уровень разделения прав, например, ограничить 
доступ к ним администратору (cluster admin и admin). Вынесем сектретную информацию из конфига деплойментов:
``
cat mysql.yaml
``
Для обеспечения бузопасности она создала секреты:
``
``
Настройки она добавила в ConfigMap:
``
cat << EOF > fm.yaml

EOF
``
## Задача
Проверим с помощь REGO наши конфиги. Исправьте ошибку:
``
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
``{{execute T1}}
Сборка: 
``
mkdir banner && cd $_
cat << EOF > index.html

EOF
``
`index.html`{{open}}
`kubectl create configmap banner --from-file="index.html"`{{execute T1}}
`kubectl get configmap banner -o json`{{execute T1}}
## Применимость
Мы научиилсь в этом уроке придерживаться принципу - на один сервис один ConfigMap. Это распространяется
не только разных весии одного сервиса, но и на разные сервисы.
## Проверка