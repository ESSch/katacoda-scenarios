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