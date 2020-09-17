# Урок по единственности контейнера в поде
## Требование
Требование ЦИ-1: Обеспечить наличие в контейнере только одного компонента не включая sidecar.
## История
В один из дней, после общения с заказчиком, владелец продукта сообщает, что
продукт заказчику понравился, но для большей популярности нужна стартовая
страница, рассказывающая пользователям о смысле нашего продукта. 
## Задание
Откроем Keali и во кладке Graph и namespace=bookinfo видим сервисы. Для
этого был сделан баннер:
```
docker run -it --name test -d --rm -p 9000:9000 python /bin/bash -c "mkdir /static && echo 'app1' > /static/index.html &&python -m http.server 9000 --directory /static;"
curl localhost:9000/index.html
```{{execute T1}}
Один из разработчиков добавить её, как и его просили.
<код не показываем>
```
cat << EOF > productpage-v1-2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: productpage-v1
  labels:
    app: productpage
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: productpage
      version: v1
  template:
    metadata:
      labels:
        app: productpage
        version: v1
    spec:
      serviceAccountName: bookinfo-productpage
      containers:
      - name: productpage
        image: docker.io/istio/examples-bookinfo-productpage-v1:1.15.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      - name: banner
        image: python
        imagePullPolicy: Always
        command: ["/bin/bash", "-c", "mkdir /static && echo 'app1' > /static/index.html && python -m http.server 9000 --directory /static;"]
        ports:
        - containerPort: 9000
      volumes:
      - name: tmp
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: productpage
  labels:
    app: productpage
    service: productpage
spec:
  ports:
  - port: 9080
    name: http
  - port: 9000
    name: banner
  selector:
    app: productpage
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo
spec:
  hosts:
  - "*"
  gateways:
  - bookinfo-gateway
  http:
  - match:
    - uri:
        exact: /bunner
    route:
    - destination:
        host: productpage
        port:
          number: 9000
  - match:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage
        port:
          number: 9080
EOF
```
Добавим изменение  ```kubectl apply -f productpage-v1-2.yaml -n bookinfo```{{execute T1}} и отобразим
его на фронте ```nohup kubectl port-forward svc/prometheus 9090:9090 -n istio-system --address 0.0.0.0 > /tmp/prometheus-pf.log 2>&1 </dev/null &```{{execute T1}}. Посмотрим https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/bunner - баннер отображается.
Возникают вопросы:
* Что сделал разработчик не так, с точки зрения состава пода?
* Как это исправить?
Найдите ошибку одним из предложенных способов:
* Выполните команду ```kubectl get all -o yaml```{{execute T1}} и найдите ошибку вручную.
* Выполните скрипт, скачайте конфиги и проверьте с помощью приложения:
```
kubectl get all -o yaml > all.yaml
kubectl create configmap all --from-file=all.yaml # полностью не сохраняет
cat << EOF > pod_and_cm.yaml
      - name: fornt
        image: 
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9999
        volumeMounts:
        - name: all
          mountPath: /tmp
      volumes:
      - name: all
        configMap:
          name: all
EOF
kubectl run pod gaas --image=GaaS --port 9099 --target-port -- main 9099
kubectl expose pod gaas
```{{execute T1}}
```
cat << EOF > productpage-v1-2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: productpage-v1
  labels:
    app: productpage
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: productpage
      version: v1
  template:
    metadata:
      labels:
        app: productpage
        version: v1
    spec:
      serviceAccountName: bookinfo-productpage
      containers:
      - name: productpage
        image: docker.io/istio/examples-bookinfo-productpage-v1:1.15.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      - name: banner
        image:python
        imagePullPolicy: always
        command: ["/bin/bash"]
        args: ["-c", "mkdir /static && echo 'app1' > /static/index.html && python -m http.server 9000 --directory /static;"]
        ports:
        - containerPort: 9000
        volumeMounts:
        - name: index
          mountPath: /static
      volumes:
      - name: tmp
        emptyDir: {}
      - name: index
        configMap:
          name: index
EOF
```{{execute T1}}
Сборка: 
```
mkdir banner && cd $_
cat << EOF > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bookinfo</title>
</head>
<body>
    <h1>Bookinfo</h1>
</body>
</html>
EOF
```
`index.html`{{open}}
`kubectl create configmap banner --from-file="index.html"`{{execute T1}}
`kubectl get configmap banner -o json`{{execute T1}}