# Урок про независимость конфигураций
## Требование
Требование NA-1.4: "Запретить использование одной и той же конфигурации (configmap) несколькими компонентами (k8s deployment)."
## История
Кейс. Команда разработала сервис ratings. Для работы с разными базами данных (mysql, mongodb и mysql на локальной машине) она разработала разные его
конфигурации:
`virtual-service-ratings-db.yaml`
`virtual-service-ratings-mysql-vm.yaml`
`virtual-service-ratings-mysql.yaml`
Для обеспечения бузопасности она создала секреты:
```
```
Настройки она добавила в ConfigMap:
```
cat << EOF > fm.yaml

EOF
```
## Задача
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