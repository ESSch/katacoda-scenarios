## Требование
Публиковать отдельно для каждого компонента метрики в выделенный endpoint в стандартном формате Prometheus exposition format, готовом для приёма системами pull мониторинга в случае использования pull подхода. Для метрик заполнять label:  object_id, group_id, service сообразно стандарту мониторинга «Стандарт обеспечения мониторинга АС»
## История
Для отслеживани работоспособности приложения, в большинстве случаев, стоит выбирать в качесве системы мониторинга Prometheus, если на то нет оснований. Наше приложение испльзует Istio, с которым поставляется Prometeus и Grafana. Grafana отображает метрики Prometeus. Посмотрим, какие метрики Prometheus может нам отдать:
```nohup kubectl port-forward svc/prometheus 9090:9090 -n istio-system --address 0.0.0.0 > /tmp/prometheus-pf.log 2>&1 </dev/null &```{{execute T1}}
Зайдём в Prometheus: https://[[HOST_SUBDOMAIN]]-9090-[[KATACODA_HOST]].environments.katacoda.com
Для визуалаизции созьмём Graphana:
```nohup kubectl port-forward svc/grafana 3000:3000 -n istio-system --address 0.0.0.0 > /tmp/grafana-pf.log 2>&1 </dev/null &```
Зайдём в Grafana: https://[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com . В ней уже настроен дашборд - выбирем его, щёлкнув по кнопке Home и выбрав дашборд Istio Service Dashboard. Этот дашборд нам ничего не показывает, так как нет метрик от приложения, которые он смог-бы отображать - создадим нагрузку:
```
while true; do
  curl -s https://2886795289-80-ollie09.environments.katacoda.com/productpage > /dev/null
  echo -n .;
  sleep 0.5
done
```{{execute T1}}
Перезагрузим страницу в Grafana и мы увидем метрики https://[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/d/LJ_uJAvmk/istio-service-dashboard?refresh=10s&orgId=1 . Мы видем в окне Client Requsts Volume заначение примерно 5 ops (5 ops = 1 / 0.5 секунд, которые мы задали в нагрузке).
Метрика rest_client_request_total . 
``
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.7.2 sh - # не даёт /samples/bookinfo/build_push_update_images.sh
``
``
/samples/bookinfo/build_push_update_images.sh
``

!!! Читать https://istio.io/latest/docs/examples/bookinfo/ !!!
!!! https://github.com/istio/istio/blob/1.7.2/samples/bookinfo/src/build-services.sh !!! 

Нам ещё нужна метрика .... . Для этого разработков попросили сделать энпойнт, но не указали в каком формате. Они его сделали в формате json:
``curl ...`` {time: ...;}
Попробуем привязать её:

Для Prometheus используется специальный формат:
`` ``
Переключите Proemteus на него и сделайте скриншот для учителя результатов из Grafana.

## TODO
Добавить Spring Boot Actuator и NodeJS Actuator. Настроить Prometheus на них. Предложить настроить нужные метрики.
1. endpoint с prometheus exposition format
2. json-like формат
3. ссылка про PEF
4. дэшборд на п. 2, заставляем переделать на п. 1
