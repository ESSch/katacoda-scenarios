## История

В роли аналитика изучите техническую архитектуру и топологию приложения.

## Имитация действий пользователей и нагрузки

Для имитации действий пользователей выполните !!команду `nohup load.sh [[HOST_IP]] > /tmp/load.log 2>&1 </dev/null &`{{execute T1}}!! задачу 
`kubectl create -n bookinfo configmap bookinfo --from-file=/usr/local/bin/bookinfo.sh`{{execute T1}}
`kubectl create -n bookinfo configmap kube --from-file=${HOME}/.kube/config`{{execute T1}}
`kubectl apply -n bookinfo -f /usr/local/bin/bookinfo.sh`{{execute T1}}

Вывод эмулятора нагрузки можно посмотреть во вкладке `Logs`

## Изучите топологию приложения в динамике

Выполните следующую команду, чтобы сделать доступным Kiali в браузере https://[[HOST_SUBDOMAIN]]-31546-[[KATACODA_HOST]].environments.katacoda.com. Для входа в Kiali логин/пароль: `admin/admin`.

## Изучите дескрипторы основных объектов приложения

* Deployments
* Pods

### Deployment: Product Page

* получить дескриптор `kubectl -n bookinfo get deployment productpage-v1 -o yaml > /root/exercise/productpage-v1.yaml`{{execute T1}}
* открыть дескриптор в редакторе `productpage-v1.yaml`{{open}}

### Pods: Details

1. Main Pod
    * получить дескриптор `kubectl -n bookinfo get pod details-main -o yaml > /root/exercise/details-main.yaml`{{execute T1}}
    * открыть дескриптор в редакторе `details-main.yaml`{{open}}
1. Secondary Pod
    * получить дескриптор `kubectl -n bookinfo get pod details-secondary -o yaml > /root/exercise/details-secondary.yaml`{{execute T1}}
    * открыть дескриптор в редакторе `details-secondary.yaml`{{open}}

### Deployment: Reviews

* получить дескриптор `kubectl -n bookinfo get deployment reviews-v3 -o yaml > /root/exercise/reviews-v3.yaml`{{execute T1}}
* открыть дескриптор в редакторе `reviews-v3.yaml`{{open}}

### Deployment: Ratings

* получить дескриптор `kubectl -n bookinfo get deployment ratings-v1 -o yaml > /root/exercise/ratings-v1.yaml`{{execute T1}}
* открыть дескриптор в редакторе `ratings-v1.yaml`{{open}}

**Внимание!** Чтобы двигаться дальше, сформируйте, пожалуйста, все перечисленные дескрипторы
