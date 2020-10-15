## История

В роли аналитика изучите техническую архитектуру и топологию приложения.

## Имитация действий пользователей и нагрузки

Для имитации действий пользователей запустите задачу `bash /usr/local/bin/load.job.sh`{{execute T1}}

События эмулятора нагрузки можно посмотреть во вкладке `Logs of load`

## Изучите топологию приложения в динамике

Откройте вкладку Kiali. Для входа в Kiali логин/пароль: `admin/admin`. В Kiali 
* выберите Graph для отображения структуры сервисов приложения
* выбирите в выпадашке `Select a namespace` пространство Bookinfo для отображения сервисов приложения и default для отображения сервиса нагрузки
* выбирите в выпадашке `Display` пункт `Traffic Animation`, что-бы увидеть распространение запросов по сервисам
Мысленно соотнесите топологию сервисов приложения с самим прилоежнием. Ниже, вам предстоит сохранить конфигурации сервисов и их изучить - посторайтесь соотнести настройки конфигураций с отображаемой ситуацией в Kiali, в часности, по колличеству реплик.

## Изучите дескрипторы основных объектов приложения

* Deployments
* Pods

### Deployment: Product Page

* получить дескриптор `kubectl -n bookinfo get deployment productpage-v1 -o yaml | grep -v resourceVersion > /root/exercise/productpage-v1.yaml`{{execute T1}}
* открыть дескриптор в редакторе `productpage-v1.yaml`{{open}}

### Pods: Details

1. Main Pod
    * получить дескриптор `kubectl -n bookinfo get pod details-main -o yaml | grep -v resourceVersion > /root/exercise/details-main.yaml`{{execute T1}}
    * открыть дескриптор в редакторе `details-main.yaml`{{open}}
1. Secondary Pod
    * получить дескриптор `kubectl -n bookinfo get pod details-secondary -o yaml | grep -v resourceVersion > /root/exercise/details-secondary.yaml`{{execute T1}}
    * открыть дескриптор в редакторе `details-secondary.yaml`{{open}}

### Deployment: Reviews

* получить дескриптор `kubectl -n bookinfo get deployment reviews-v3 -o yaml | grep -v resourceVersion > /root/exercise/reviews-v3.yaml`{{execute T1}}
* открыть дескриптор в редакторе `reviews-v3.yaml`{{open}}

### Deployment: Ratings

* получить дескриптор `kubectl -n bookinfo get deployment ratings-v1 -o yaml | grep -v resourceVersion > /root/exercise/ratings-v1.yaml`{{execute T1}}
* открыть дескриптор в редакторе `ratings-v1.yaml`{{open}}

**Внимание!** Чтобы двигаться дальше, сформируйте, пожалуйста, все перечисленные дескрипторы
