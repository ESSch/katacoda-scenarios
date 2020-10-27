## История

Аналитик передает архитектору оценочный чеклист стандарта CloudNative, в котором заявлено **соответствие** приложения следующим пунктам стандарта:
> 1. Требования
>     1. 15 RA-3.10 Публиковать информацию о готовности каждого компонента к приёму запросов через readiness endpoint
>     1. 16 RA-2.10 Публиковать информацию о жизнеспособности каждого компонента через liveness endpoint
>     1. 19 RN-2.2  Настроить liveness probe в оркестраторе на liveness endpoint
>     1. 20 NE-3.3  Настроить readiness probe в оркестраторе на readiness endpoint
>     1. 21 NE-3.4  Настроить startup probe в оркестраторе на startup endpoint. В случае невозможности настройки использовать initialDelay в liveness probe.

## Поднимите окружение
Перед Вами тестовое окружение. Само приложение - `sever.js`{{open}}. Сделаем его доступным Kubernetes: `kubectl create configmap app --from-file=/root/exercise/server.js`{{execute T1}}. Запустите NodeJS приложение `kubectl create -f /root/exercise/app.yaml`{{execute T1}} и дождитесь старта приложения `kubectl get -f /root/exercise/app.yaml`{{execute T1}}, далее перейдите http://[[HOST_SUBDOMAIN]]-9000-[[KATACODA_HOST]].environments.katacoda.com/ .