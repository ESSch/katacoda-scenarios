## Установка:
* `/usr/local/bin/run.sh`{{execute T1}}
* `kubectl get pods -n istio-system -o name | xargs -I {} kubectl wait --for=condition=Ready --timeout=30s -n istio-system {}`{{execute T1}}
* `kubectl get pods -n istio-system`{{execute T1}} ожидание
* ``
nohup kubectl port-forward svc/prometheus 9090:9090 -n istio-system > /tmp/prometheus-pf.log 2>&1 </dev/null &
nohup kubectl port-forward svc/grafana 3000:3000 -n istio-system --address 0.0.0.0 > /tmp/grafana-pf.log 2>&1 </dev/null &
nohup kubectl port-forward svc/jaeger-query 16686:16686 -n istio-system --address 0.0.0.0 > /tmp/jaeger-query-pf.log 2>&1 </dev/null &
nohup kubectl port-forward svc/kiali 20001:20001 -n istio-system --address 0.0.0.0 > /tmp/kiali-pf.log 2>&1 </dev/null &
``{{execute T1}}
* `/usr/local/bin/bookinfo.sh`{{execute T1}}
* `kubectl get pods -n istio-system -o name | xargs -I {} kubectl wait --for=condition=Ready --timeout=120s -n istio-system {}`{{execute T1}}
* `cd /root/istio-1.6.2/`{{execute T1}}
* `kubectl get svc -n bookinfo -o 'jsonpath={range @.items[*]}{.spec.clusterIP}{"\n"}{end}' | xargs -I{} curl {}:9080`{{execute T1}}
## Клонирование полностью всего репозитория:
``
cd /root/ && git clone https://github.com/istio/istio.git
cd /root/istio/samples/bookinfo/src/
``{{execute T1}}