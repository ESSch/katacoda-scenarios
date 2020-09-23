## Установка:
* `/usr/local/bin/run.sh`{{execute T1}}
* `kubectl get svc -n bookinfo -o 'jsonpath={range @.items[*]}{.spec.clusterIP}{"\n"}{end}' | xargs -I{} curl -I --retry-connrefused --retry 20 --retry-delay 2 {}:9080`{{execute T1}}
``
    --retry <num>   Retry request if transient problems occur
     --retry-connrefused Retry on connection refused (use with --retry)
     --retry-delay <seconds> Wait time between retries
     --retry-max-time <seconds> Retry only within this period
     --sasl-ir       Enable initial response in SASL authentication
``
## Клонирование полностью всего репозитория:
``
cd /root/ && git clone https://github.com/istio/istio.git
cd /root/istio/samples/bookinfo/src/
``{{execute T1}}