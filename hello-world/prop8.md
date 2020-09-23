## Требование
Возможность продолжить выполнение незавершенных бизнес-задач с момента отказа внешнего компонента/сервиса в случае наличия бизнес-смысла за счёт идемпотентность вызовов
## TODO 
Развернуть bookinfo. 400 вносит virtual-service-ratings-test-abort.yaml. Заменить 100% на 10%. Попросить добиться работоспособности за счёт добавления spec.http[].retries
## Предистория
В приложении имеется плавающая ошибка. Пока команда её ищет нужно не отказывать пользователей в обслуживании. Помогите команде добиться от вервиса обработки пользовательского запроса от сервиса.
## Подготовка
Для эмуляции недоступности ratings версии v1 воспользуемся virtual-service-ratings-test-abort.yaml. Просмотрите содержимое:
``cat samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml``. До применения ``curl http://$(kubectl get svc details -o jsonpath={@.spec.clusterIP}):9080/``. Применем ``kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml``. 
и понаблюдаем за ними за ``sed 's/percent: 100/percent: 10/'``{{execute T1}}.
spec.http[].fault.abort.percentage.value = 10.0
Посмотрим на Jaeger ``nohup kubectl port-forward svc/jaeger-query 16686:16686 -n istio-system --address 0.0.0.0 > /tmp/jaeger-query-pf.log 2>&1 </dev/null &``{{execute T1}}   https://[[HOST_SUBDOMAIN]]-16686-[[KATACODA_HOST]].environments.katacoda.com

bookinfo/networking/virtual-service-reviews-90-10.yaml
Создадим запросы:
``
while true; do
  curl -sI https://2886795334-80-elsy05.environments.katacoda.com/productpage | grep HTTP | grep -o -P '[0-9]{3}'
  sleep 0.5
done
``{{execute T2}}

kubectl get svc
kubectl get svc jaeger


Добавьте в VirtualService сервиса ratings версии v1 раздел retries:

## Задача
Пропишите spec.http[].retries вместо звёздочек значения, необходимые для работы приложения:
``
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
``
## Сверка результата.
Сделайте скриншот из Jaeger, где видно, что были повторы и они закончились успехом.
