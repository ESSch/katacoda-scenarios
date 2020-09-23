## Требование
8 Возможность продолжить выполнение незавершенных бизнес-задач с момента отказа внешнего компонента/сервиса в случае наличия бизнес-смысла за счёт идемпотентность вызовов
## Общее описание 
Развернуть bookinfo. 400 вносит virtual-service-ratings-test-abort.yaml. Заменить 100% на 10%. Попросить добиться работоспособности за счёт добавления spec.http[].retries
## Предистория
В приложении имеется плавающая ошибка. Пока команда её ищет нужно не отказывать пользователей в обслуживании. Помогите команде добиться от вервиса обработки пользовательского запроса от сервиса.
## Подготовка
Для контроля нам понадобится Keali.

Для детального контроля нам понадобится ``kubectl get svc jaeger-query -n istio-system``{{execute T1}}. Прокиним его UI во вне: ``nohup kubectl port-forward svc/jaeger-query 16686:16686 -n istio-system --address 0.0.0.0 > /tmp/jaeger-query-pf.log 2>&1 </dev/null &``{{execute T1}}. Перейдём https://[[HOST_SUBDOMAIN]]-16686-[[KATACODA_HOST]].environments.katacoda.com. В интерфейсе нет метриков.

Посмотрим в интерфейсе на метрики. Для этого обновим страницу приложения https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/productpage и страницу Jaeger и выбирем сервис `ratings`. Просмотрим путь istio-ingressgateway->productpage->productpage->

![jaeger-reviews](https://github.com/ESSch/katacoda-scenarios/raw/master/hello-world/assets/jaeger-reviews.png)

Создадим запросы на https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/productpage:
``
while true; do
  curl -sI https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/productpage | grep HTTP | grep -o -P '[0-9]{3}'
  sleep 0.5
done
``{{execute T2}}
## Проведения
Для эмуляции недоступности ratings версии v1 воспользуемся virtual-service-ratings-test-abort.yaml. Просмотрите содержимое:
``cat samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml``{{execute T1}}. До применения ``curl http://$(kubectl get svc details -o jsonpath={@.spec.clusterIP}):9080/``{{execute T1}}. Применем ``kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml``{{execute T1}}. Изменем колличество непройденных запросов со 100% до 10% в spec.http[].fault.abort.percentage.value с помощью ``sed 's/percent: 100/percent: 10/'``{{execute T1}}.

## Задача
Добавьте в VirtualService сервиса ratings версии v1 раздел retries.
Пропишите spec.http[].retries вместо звёздочек значения, необходимые для работы приложения:
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
      attempts: *
      perTryTimeout: *
```
## Сверка результата.
Сделайте скриншот из Jaeger, где видно, что были повторы и они закончились успехом.
