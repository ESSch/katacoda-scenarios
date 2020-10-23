## История

Аналитик передает архитектору оценочный чеклист стандарта CloudNative, в котором заявлено **соответствие** приложения следующим пунктам стандрата:
> 1. Требования
>     1. 15 RA-3.10 Публиковать информацию о готовности каждого компонента к приёму запросов  через readiness endpoint
>     1. 16 RA-2.10 Публиковать информацию о жизнеспособности каждого компонента через liveness endpoint
>     1. 19 RN-2.2  Настроить liveness probe в оркестраторе на liveness endpoint
>     1. 20 NE-3.3  Настроить readiness probe в оркестраторе на readiness endpoint
>     1. 21 NE-3.4  Настроить startup probe в оркестраторе на startup endpoint. В случае невозможности настройки использовать initialDelay в liveness probe.      

## Экосистема
Перед Вам приложение на NodeJS.

## Самопроверка на соответствие CloudNative

1. Запустите `checklist.sh`{{execute T1}}, для выполнения rego проверок (см. файл checklist.rego).
2. Определите на основании проверки отклонения от стандарта

## jjjj

# 19
## Требование
Публиковать информацию о готовности каждого компонента к приёму запросов  через readiness endpoint

## TODO 
Запусить базу по virtual-service-ratings-mysql.yaml / virtual-service-ratings-mysql-vm.yaml / virtual-service-ratings-db.yaml. Прописать простые readiness endpoint на запуск приложения, положить базу. Сделать запросы, чтобы оно читало из базы и предложить найти ошибку в конфигах.

## Требование
Настроить readiness probe в оркестраторе на readiness endpoint
## Предистория
Команда пытается настроить CD процесс. В процессе выкатки продук-менжер выставляет требование, что-бы сервис оставался доступным всё время. Для этого, команда решила настроить Rolling Update (https://kubernetes.io/ru/docs/tutorials/kubernetes-basics/update/update-intro/) в Kubernetes ``req20_ru.sh``. Но, команда не учла, что приложние внутри контейнера поднимается более 30 секунд и когда контейнер поднялся и на него переведён трафик оно не может на него ответить.
``
#setting
sed 's//command "slepp 30"/'
#add_sleep to config
``

# 20
## Подготовка
* Создадим нагрузку:
``
while true; do
  curl -s https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/productpage > /dev/null
  echo -n .;
  sleep 0.2
done
``
* Будем отслеживать трафик через Kiali - откройте соответствующую вкладку и кликните по сервису `details`.
## Выявление проблемы
* выполнии обновелние с помощью ``kubectl rollout status deployment.v1.apps/details-v1``
* будем выявлять выявлять непрошедшие пользовательские запросы в Kiali
## Задача
Настройти конфиг так, что-бы трафик поступал на поды, только когда они готовы к его обработке.
## Сверка результата
``
kubectl rollout status deployment.v1.apps/details-v1
for i in {1..10}; do
  curl -s https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/ || exit 1
done;
``

## Общее описание
1. ломаем ролинг апгрейд через слип
2. говорим, что у разработчика не было времени сделать отдельный энпоинт, поэтому одно из решений - ссылка на самого себя
3. Список сответствия улов-IP-адресов

# 19
## Требование
Настроить liveness probe в оркестраторе на liveness endpoint
## Предистория
Команда разработавшая приложение решила улучшить отказоустойчивость ``req19_liveness.sh``{{execute T1}}. Для этого ни воспользовались документацией:
https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
``
#req19_liveness.sh

curl -L $(kubectl get svc reviews -o jsonpath={@.spec.clusterIP}):9080/healt
kubectl get pods -l app=reviews,version=v1
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-ratings.yaml
cat << 'EOF' > req19_liveness.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ratings-v1
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: ratings
        version: v1
    spec:
      containers:
      - name: ratings
        image: istio/examples-bookinfo-ratings-v1:1.8.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
        livenessProbe:
          httpGet:
            path: /health2
            port: 9080
          initialDelaySeconds: 5
          periodSeconds: 5
EOF
kubectl apply -f req19_liveness.yaml
sleep 120
kubectl get pods -l app=ratings
kubectl get pods -l app=ratings
#kubectl get pods -l app=reviews,version=v1 
#kubectl exec -it $(kubectl get pods -l app=ratings -o jsonpath='{@.items[0].metadata.name}') bash 
``
## Подготовка
Посмотрите на работающий сервис ``kubectl get pods -l app=ratings``{{execute T1}} в первые 15 минут. Применим улучшения команды ``req19_liveness.sh``{{execute T1}}. 
Изучите докумтацию. Посмотрите на перезагружающийся сервис . Найдите ошибку в его коде его конфигурации ``kubectl get pods -l app=ratings -o yaml``.
## Задача
Необходимо настроить liveness пробу с типом TCP на эндпойте /healt сервиса `reviews`.
Необходимо добавить в конфиг `istio/samples/bookinfo/platform/kube/bookinfo-ratings.yaml` пробу.
``
spec:
  containers:
  - livenessProbe:
      httpGet:
        path: /health
        port: *
      initialDelaySeconds: *
      periodSeconds: *
`` 
## Сверка результата
Пришлите учителю исправленный участок конфигурации.

0. постоянная перезагрузка пода
1. рего проверки, что ливнес на tcp, причём конкретно java
2. если нет ливнеса, то для всех эндпоинтов кроме одного, забиваем его фейковый через tcp
3. для явовского где точно есть в катакоде показываем файл где эндпоинт