## Требование 
Использование возможности среды исполнения по объединению вычислительных ресурсов в единый пул, обслуживающий потребителей приложения. 
## Общее описание 
Развернуть bookinfo kubernetes и приложение в отдельном контейнере Docker. В kubernetes создаётся Endpoints, ссылающийся subsets[].addresses+ports на контейнер Docker по средствам url-katacoda имеющая запись оп порте Docker (не проверял). В istio содать рул на этот Endpoints.
## Предистория
Наряду с приложениями, развёрнытыми в Kubernetes, часто имеется приложения, которые находятся вне его сласстера. Это может быть и внешние сервисы, и приложения ещё не перенесённые в класстер и приложения неподлежащие развёртыванию в кластере Kubernetes. Так, нашему приложению во второй версии требуется наличие базы данных. Помогите команде перейти на вторую версию с внешней для Kubernetes безой данных.
## Подготовка
В Вашем окружении установлен Docker ``docker version -f {{.Server.Version}}``{{execute T1}}. Развернём его: ``docker run -d -e MYSQL_ROOT_PASSWORD=123 -p 3306:3306 --net host --name mysql mysql``{{execute T1}}. Проверим ``docker run -it --rm --net host --name client_mysql mysql mysql -h127.0.0.1 -uroot -p123``{{execute T1}}

docker -IP- istioctl_register -DNS- virtual-service-ratings-mysql-vm
```
cd /root/istio/samples/bookinfo/src
# bash build-services.sh 1.7.0 docker.io/istio
cd /root/istio/samples/bookinfo/src/mysql
docker images | grep b_mysql
docker build . -t b_mysql:1.0
docker run -d -e MYSQL_ROOT_PASSWORD=password --net host --name b_mysql b_mysql:1.0
docker exec -it b_mysql mysql -h 127.0.0.1 -ppassword < mysqldb-init.sql ####
# istioctl register -n vm mysqldb 1.2.3.4 3306
cd 
kubectl apply -f bookinfo/networking/virtual-service-ratings-mysql-vm.yaml
kubectl apply -f bookinfo/platform/kube/bookinfo-ratings-v2-mysql-vm.yaml
```
## Задача
Зарегистрируйте с помощью команды `istioctl register -n vm mysqldb ${HOST} 3306` в Istio внешний сервис и проверьте работу приложения.
## Сверка результата
В проверке задачи: `curl ${raiting}:9080`
