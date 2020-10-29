## История

Аналитик передает архитектору оценочный чеклист стандарта CloudNative, в котором заявлено **соответствие** приложения следующим пунктам стандарта:
> 1. Требования
>     1. 15 RA-3.10 Публиковать информацию о готовности каждого компонента к приёму запросов через [readiness endpoint](https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
>     1. 16 RA-2.10 Публиковать информацию о жизнеспособности каждого компонента через [liveness endpoint](https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
>     1. 19 RN-2.2  Настроить [liveness probe](https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) в оркестраторе на liveness endpoint
>     1. 20 NE-3.3  Настроить [readiness probe](https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) в оркестраторе на readiness endpoint
>     1. 21 NE-3.4  Настроить [startup probe](https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) в оркестраторе на startup endpoint. В случае невозможности настройки использовать initialDelay в liveness probe.

## Поднимите окружение
Перед Вами тестовое окружение. Само приложение - `server.js`{{open}}. Сделаем это приложение доступным Kubernetes: `kubectl create configmap app --from-file=/root/exercise/server.js --from-file=/root/exercise/front.html`{{execute T1}}

Запустите NodeJS приложение: `kubectl apply -f /root/exercise/app.yaml`{{execute T1}}.
