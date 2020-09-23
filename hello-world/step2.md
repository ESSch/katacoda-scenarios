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
``docker run -it --name test -d --rm -p 9000:9000 python /bin/bash -c "mkdir /static && echo 'app1' > /static/index.html &&python -m http.server 9000 --directory /static;"``{{execute T1}}  ``curl localhost:9000/index.html``{{execute T1}}.
Один из разработчиков добавить её, как и его просили. Добавим изменение ```kubectl apply -f /tmp/productpage-v1-2.yaml -n bookinfo```{{execute T1}}. Посмотрим https://[[HOST_SUBDOMAIN]]-30128-[[KATACODA_HOST]].environments.katacoda.com/bunner - баннер отображается.
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
