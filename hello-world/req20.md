## Требование
Настроить readiness probe в оркестраторе на readiness endpoint
## Предистория
Команда пытается настроить CD процесс. В процессе выкатки продук-менжер выставляет требование, что-бы сервис оставался доступным всё время. Для этого, команда решила настроить Rolling Update (https://kubernetes.io/ru/docs/tutorials/kubernetes-basics/update/update-intro/) в Kubernetes ``req20_ru.sh``. Но, команда не учла, что приложние внутри контейнера поднимается более 30 секунд и когда контейнер поднялся и на него переведён трафик оно не может на него ответить.
``
#setting
sed 's//command "slepp 30"/'
#add_sleep to config
``
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