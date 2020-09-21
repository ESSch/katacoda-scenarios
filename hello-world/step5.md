# Урок про время старта контейнера
## Требование
Требование ЦИ-5: "Гарантировать максимальное время старта контейнера c загрузкой образа не более 30 секунд"
## История
Разработчики добавляли новый функционал и с каждым разом контейнер всё медленнее стартовал. И в какой-то
момент, контейнер перестал запускаться. Помогите разработчикам выяснить, почему их приложение полностью работает
нормально в dev-окружении, а в prod-окружении уже нет. 
## Задача
Посмострим на рабоающие контейнера - всё нормлаьно работает:
``kubectl get pods``{{execute T1}}
Запустим новое окружение и презапуситим наше приложение:
``/tmp/prod.sh``{{execute T1}}
``
#Спрятать в скрипт
kubectl set resources -f path/to/file.yaml --limits=cpu=200m,memory=512Mi --local -o yaml
kubectl get deploy -l app=reviews,version=v1 -o json | jq .items[0].spec.template.spec.containers
kubectl get pod
kubectl set resources --dry-run=true -f samples/bookinfo/platform/kube/bookinfo-reviews-v2.yaml --limits=cpu=10m -o yaml
kubectl set resources --dry-run=true -f samples/bookinfo/platform/kube/bookinfo-reviews-v2.yaml --limits=cpu=10m -o yaml > /tmp/a.yaml
kubectl set resources --dry-run=true -f samples/bookinfo/platform/kube/bookinfo-reviews-v2.yaml --limits=cpu=10m -o json > /tmp/a.json
kubectl get deploy -l app=reviews,version=v1 -o json | jq .items[0].spec.template.spec.containers
kubectl patch -p '{metadata:{labels:{a:1}}}' -f /tmp/a.yaml --dry-run=true
cat /tmp/a.yaml | kubectl apply -f -    
``
Проверим работу нашего приложения:
``kubectl get pods``{{execute T1}}
