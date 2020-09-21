# Урок по размеру пода
## Требование 
Треование ЦИ-4: "Использовать контейнеры максимальным размером не более 1024 Мб"
## История
Команда разработчиков решали доработать приложение frontpage на python. Для этого они решили сделать его в виде модного одностраничного приложения (SPA). 
Команда разработка разработала новый функционал ```addFeatures.sh```{{execute T1}} (не показывать). Приложение было собнано ```samples/bookinfo/build_push_update_images.sh```{{execute T1}}.
```
#старое
sed -i Dockerfile '/CMD/i!curl -sL -o db1.iso https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.5.0-amd64-netinst.iso!' 
sed -i Dockerfile '/CMD/i!curl -sL -o db1.iso https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.5.0-amd64-netinst.iso!' 
sed -i Dockerfile '/CMD/i!curl -sL -o db1.iso https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.5.0-amd64-netinst.iso!'
bash  
```
```
cat << EOF > Dockerfile
FROM ubuntu:20.10 # 
RUN apt-update
RUN ... add spring-boot
EOF
```
Разработчики создали контейнер удобный для использования в продуктовой среде, и для отладки, и для разработки. Он 
содержит серве на Python и Fornt-end на nodejs+vue и средства разработки и отладки:
```
sudo docker run --name python -d ubuntu:14.04 bash -c 'sleep 36000000'
sudo docker exec -it python bash
sudo docker commit python p1
sudo docker rm -f python

sudo docker run --name python18 -d ubuntu:18.04 bash -c 'sleep 36000000'

cat << EOF > Dockerfile
FROM ubuntu:14.04 # 210
RUN apt-get update -y # 210
RUN apt-get upgrade -y # 210
RUN sudo apt install curl -y && curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && sudo apt install nodejs -y && node -v && npm -v # 306
RUN sudo apt install -y python3 && python3 --version # 306
RUN sudo apt install -y python3-pip && pip3 --version # 462
RUN sudo apt install -y python-pip # 468
RUN sudo apt-get install -y python-django && django-admin --version # 492
RUN apt install -y git # 519
RUN npm install react --save # 520
RUN npm init react-app my-app && cd my-app/ && npm run build # 764
RUN django-admin startproject django_app
COPY . .
python3 manage.py runserver 0.0.0.0:8000
EOF

docker build . -t my
```
Но проверка показала ошибку ``test.sh`` <Объём контейнера должне быть не более 100Mб>. Помотрим на назмер образ `docker images` - он очень большой, медленно стартует и требует много памяти. Исправим ошибки:
* Создайте в корне проекта файл .dockerignore и добавьте туда файлы и папки не нужные при сборке, такие как Dockerifle и .git
* Пропишите в Dockerfile команду ``sudo apt-get clean`` после установки пакетов, которая подчистит список доступных пакетов.
* Разделите команды Dockerfile (multi-stage сборка) на два этапа: сборку с "FROM Ubuntu" и результат с "FROM cratch"
* Убирите данные из образа контейнера в PVC ``kubectl crate PVC``
* В образ нужно копировать только необходимые папки с проектами, дял этого ``sed -i Dockerile 's!COPY . .!COPY ./front ./front!'`` и
``sed -i Dockerile '/COPY/a!COPY ./back ./back!'``