## Требование
Публиковать отдельно для каждого компонента метрики в выделенный endpoint в стандартном формате Prometheus exposition format, готовом для приёма системами pull мониторинга в случае использования pull подхода. Для метрик заполнять label: object_id, group_id, service сообразно стандарту мониторинга «Стандарт обеспечения мониторинга АС»
## Предистория
Для отслеживани работоспособности приложения, в большинстве случаев, стоит выбирать в качесве системы мониторинга Prometheus, если на то нет оснований. Наше приложение испльзует Istio, в стандартную поставку которого входит Prometeus его визуализация - Grafana. Помогите команде получить аналитику в Prometheus.
## Подготовка
!!!Убарать подготовку в скрипты!!!
Зайдём в Prometheus: https://[[HOST_SUBDOMAIN]]-9090-[[KATACODA_HOST]].environments.katacoda.com
Зайдём в Grafana: https://[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com . В ней уже настроен дашборд - выбирем его, щёлкнув по кнопке Home и выбрав дашборд Istio Service Dashboard. Этот дашборд нам ничего не показывает, так как нет метрик от приложения, которые он смог-бы отображать - создадим нагрузку:
``
#stress.sh
while true; do
  curl -s https://[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com/productpage > /dev/null
  echo -n .;
  sleep 0.5
done
``{{execute T1}}
Перезагрузим страницу в Grafana и мы увидем метрики https://[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/d/LJ_uJAvmk/istio-service-dashboard?refresh=10s&orgId=1 . Мы видем в окне Client Requsts Volume заначение примерно 5 ops (5 ops = 1 / 0.5 секунд, которые мы задали в нагрузке).
Метрика rest_client_request_total . 
``
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.7.2 sh - # не даёт /samples/bookinfo/build_push_update_images.sh
``
``
/samples/bookinfo/build_push_update_images.sh
src/build-services.sh 1.7.2 docker.io/istio # https://github.com/istio/istio/tree/master/samples/bookinfo 
build_push_update_images.sh 1.7.2
``

Нам ещё нужна метрика жизни приложения. Для этого разработков попросили сделать энпойнт, но не указали в каком формате. Они его сделали в формате json и она доступна по адресу `/health`. Её код находится в `/root/istio/samples/bookinfo/src/reviews/reviews-application/src/main/java/application/rest/LibertyRestEndpoint.java`: ``{{execute T1}}
``sed -n '165,+5p' /root/istio/samples/bookinfo/src/reviews/reviews-application/src/main/java/application/rest/LibertyRestEndpoint.java``{{execute T1}}
Добавьте в код с помощью sed обработуку /health_prometheus:
``д``

Для Prometheus используется специальный Prometheus Exposition Format формат ``name {labels} value``. Зададим метрику `http_health{object_id="", group_id="", service="reviews"} 1` для эндпойта `/health_prometheus`. Для этого добавьте его к `/health` и настройте на него Prometheus.
``
#В верии 2
    add_health_prometheus.sh 

    @GET
    @Path("/health")
    public Response health() {
        return Response.ok().type(MediaType.APPLICATION_JSON).entity("{\"status\": \"Reviews is healthy\"}").build();
    }

kubectl get svc
kubectl get svc reviews
curl ${IP}/health
curl ${IP}/health_prometheus

cat << EOF > health_prometheus.java
@GET
@Path("/health_prometheus")
public Response health_prometheus() {
    return Response.ok().type(MediaType.APPLICATION_JSON).entity("{\"status\": \"Reviews is healthy\"}").build();
}
EOF
#http_health{object_id="", group_id="", service="reviews"} 1

sed '163r health_prometheus.java' /root/istio/samples/bookinfo/src/reviews/reviews-application/src/main/java/application/rest/LibertyRestEndpoint.java
``


Добавим в код приложения возможность отдавать метрики в форматах json и prometheus:
``
ls istio/samples/bookinfo/src/reviews/reviews-application/src/main/java/application/rest/LibertyRestEndpoint.java

``
!!!Сделать выбор можду пробами!!!
Применить `apply.sh`
`

#update.sh
`
## Задача
Переключите Proemteus на него и сделайте скриншот для учителя результатов из Grafana.
## Сверка результата
Пришлите учителю скриншот метрики из Prometheus.