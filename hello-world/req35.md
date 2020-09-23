## Требование ЦИ-10
ЦИ-10: Запретить использование контейнеров, в которых приложения работают только под рутом или суперпривилегиями
## Общее описание 
Добавить ещё в Dockerfile пользователя root с помощью build_push_update_images.sh. Показать с помощью ps, что запущены от root процессы в контейнере. Предложить найти ошибки.
## Предистория
Команда разработала новые образа для приложения. После проведения проверки сотрудник безопасности сообщил комаде, что конфиги образов (Dockerfile) не соответсвуют нормам безопасности. Помогите команде привести в соответствие. 
``
#Добавить в стартовый скрипт урока (code => req35_launch.sh)
set -o errexit

cd /root/istio/samples/bookinfo/src/productpage/
sed -i '/FROM python/a\USER root' Dockerfile
cd /root/istio/samples/bookinfo/ && bash build_push_update_images.sh 1.7.2 
``
## Задача
Исходные коды сервисов распологаются в `/root/istio/samples/bookinfo/src/`:
`find /root/istio/samples/bookinfo/src/ -name Dockerfile`{{execute T1}}
Найти и исправить нерушения в Dockerfile: `find /root/istio/samples/bookinfo/src/ -name Dockerfile -exec cat {} +`{{execute T1}}
## Сверка результата
``
#В проверку урока
find /root/istio/samples/bookinfo/src/ -name Dockerfile -exec cat {} + | grep 'root'
``

