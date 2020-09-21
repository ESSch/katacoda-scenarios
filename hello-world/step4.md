# Урок по размеру пода
## Требование 
Треование ЦИ-4: "Использовать контейнеры максимальным размером не более 1024 Мб"
## История
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
cat << EOF > Dockerfile
FROM ubuntu:14.04 # 190
RUN apt-update -y # 210
RUN apt-get install -y python # 235
RUN apt-get install -y pip # 235
RUN apt-get install -y nodejs # 243
RUN apt-get install -y npm # 368
RUN apt-get install -y npm # 368
RUN npm install angular --save
RUN npm install angular-cli --save
RUN ang start hello-world
RUN pip install Django
RUN apt-get install git
RUN django-admin startproject django_app
python3 manage.py runserver 0.0.0.0:8000
```
Но проверка показала ошибку ``test.sh`` <Объём контейнера должне быть не более 100Mб>. Проведите ревизию образа и исправьте ошибки. Что сдалали разраюотчики не правильно?:
```

```