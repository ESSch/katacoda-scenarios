## Установка:
* `/usr/bin/launch.sh && cd /root && /usr/local/bin/istio-install.sh`{{execute T1}}
** `kubectl wait --for=condition=Ready pod/grafana-54b54568fc-b7kwj -n istio-system`{{execute T1}}
* `kubectl get pods -n istio-system`{{execute T1}} ожидание
* `/usr/local/bin/bookinfo.sh`{{execute T1}}
* `test $(kubectl -n bookinfo get pods | grep -v Running | wc -l) -eq 1`{{execute T1}}
* `cd istio-1.6.2/`{{execute T1}}
* https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/productpage
## Клонирование полностью всего репозитория:
``
git clone https://github.com/istio/istio.git
cd /root/istio/samples/bookinfo/src/
``{{execute T1}}