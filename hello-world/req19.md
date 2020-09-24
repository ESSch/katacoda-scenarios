## Требование
Настроить liveness probe в оркестраторе на liveness endpoint
## Предистория
Команда разработавшая приложение решила улучшить отказоустойчивость ``req19_liveness.sh``{{execute T1}}. Для этого ни воспользовались документацией:
https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
``
#req19_liveness.sh

curl -L $(kubectl get svc reviews -o jsonpath={@.spec.clusterIP}):9080/healt
kubectl get pods -l app=reviews,version=v1
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-ratings.yaml
cat << 'EOF' > req19_liveness.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ratings-v1
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: ratings
        version: v1
    spec:
      containers:
      - name: ratings
        image: istio/examples-bookinfo-ratings-v1:1.8.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
        livenessProbe:
          httpGet:
            path: /health2
            port: 9080
          initialDelaySeconds: 5
          periodSeconds: 5
EOF
kubectl apply -f req19_liveness.yaml
sleep 120
kubectl get pods -l app=ratings
kubectl get pods -l app=ratings
#kubectl get pods -l app=reviews,version=v1 
#kubectl exec -it $(kubectl get pods -l app=ratings -o jsonpath='{@.items[0].metadata.name}') bash 
``
## Подготовка
Посмотрите на работающий сервис ``kubectl get pods -l app=ratings``{{execute T1}} в первые 15 минут. Применим улучшения команды ``req19_liveness.sh``{{execute T1}}. 
Изучите докумтацию. Посмотрите на перезагружающийся сервис . Найдите ошибку в его коде его конфигурации ``kubectl get pods -l app=ratings -o yaml``.
## Задача
Необходимо настроить liveness пробу с типом TCP на эндпойте /healt сервиса `reviews`.
Необходимо добавить в конфиг `istio/samples/bookinfo/platform/kube/bookinfo-ratings.yaml` пробу.
``
spec:
  containers:
  - livenessProbe:
      httpGet:
        path: /health
        port: *
      initialDelaySeconds: *
      periodSeconds: *
`` 
## Сверка результата
Пришлите учителю исправленный участок конфигурации.

0. постоянная перезагрузка пода
1. рего проверки, что ливнес на tcp, причём конкретно java
2. если нет ливнеса, то для всех эндпоинтов кроме одного, забиваем его фейковый через tcp
3. для явовского где точно есть в катакоде показываем файл где эндпоинт
