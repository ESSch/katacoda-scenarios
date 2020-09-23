## Установка:
* `/usr/local/bin/run.sh`{{execute T1}}
** `kubectl wait --for=condition=Ready pod/grafana-54b54568fc-b7kwj -n istio-system`{{execute T1}}
* `kubectl get pods -n istio-system`{{execute T1}} ожидание
* `/usr/local/bin/bookinfo.sh`{{execute T1}}
* `test $(kubectl -n bookinfo get pods | grep -v Running | wc -l) -eq 1`{{execute T1}}
* `cd /root/istio-1.6.2/`{{execute T1}}
* https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/productpage

``
nohup kubectl port-forward svc/prometheus 9090:9090 -n istio-system --address 0.0.0.0 > /tmp/prometheus-pf.log 2>&1 </dev/null &
nohup kubectl port-forward svc/grafana 3000:3000 -n istio-system --address 0.0.0.0 > /tmp/grafana-pf.log 2>&1 </dev/null &
nohup kubectl port-forward svc/jaeger-query 16686:16686 -n istio-system --address 0.0.0.0 > /tmp/jaeger-query-pf.log 2>&1 </dev/null &
nohup kubectl port-forward svc/keali 20001:20001 -n istio-system --address 0.0.0.0 > /tmp/keali-pf.log 2>&1 </dev/null &
``
## Клонирование полностью всего репозитория:
``
cd /root/ && git clone https://github.com/istio/istio.git
cd /root/istio/samples/bookinfo/src/
``{{execute T1}}