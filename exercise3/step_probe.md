# Оптимизацию образа и контейнера
## Предисловие
В этом уроке мы рассмотрим работу тяжёлых контейнеров.
## Предистория
Для примера мы возьмём:
wget https://raw.githubusercontent.com/pytorch/tutorials/master/beginner_source/blitz/cifar10_tutorial.py
Более подноробно Вы можете узнать о самой программе из документации и нашего курса https://sberbank-school.ru/programs/8538/about .
Мы его берём не случайно, ведь ML лидирует по потреблению ресурсов в SberCloud, а колличество сотрудников возрастёт в 4 раза.

Аналитик передает архитектору оценочный чеклист стандарта CloudNative, в котором заявлено **соответствие** приложения следующим пунктам стандарта:
> 1. Требования
>     1. 28 ЦИ-3 Запретить обращение к внешним сервисам для первоначального запуска контейнера - загружать все настройки, необходимые для запуска компонента, при старте контейнера из ConfigMap, Secrets, внешнего хранилища конфигураций, интегрированного в среду исполнения.
>     1. 29 ЦИ-4 Использовать контейнеры максимальным размером не более 1024 Мб
>     1. 30 ЦИ-5 Гарантировать максимальное время старта контейнера c загрузкой образа не более 30 секунд
>     1. 32 ЦИ-7 Использовать поды с максимум 8 Гб памяти
>     1. 33 Ци-8 Использовать поды с максимум 4 ядрами 
>     1. 22 RS-3.1 Обеспечивать горизонтальное масштабирование через создание stateless экземпляров компонент средствами оркестратора контейнеров

## Поднимите окружение
Запустим контейнер:
``date && docker run -it --rm --name pytorch pytorch/pytorch bash -c "date && pip install ipywidgets matplotlib > /dev/null && wget https://raw.githubusercontent.com/pytorch/tutorials/master/beginner_source/blitz/cifar10_tutorial.py && date && python3 cifar10_tutorial.py && date"``{{execute T1}}

## Анализ нарушений
ЦИ-3. Мы видим, что контейнер при старте устанавливает библиотеки (wget), скачивает скрипт, да и сам dataset скачивается внутри скрипта.

ЦИ-4. Посмотрим на размер образа `docker images | grep pyto`{{execute T1}} - он 3,47Gb, а по стандарту не более 1Gb.

ЦИ-5. Время начала скачивания образа у меня Mon Oct 26 07:30:03 UTC 2020, а завершения - Mon Oct 26 07:31:57 UTC 2020, что по времени занимает 1:54. Время старта контейнера Mon Oct 26 07:35:10 UTC 2020, а завершение - Mon Oct 26 07:43:05 UTC 2020, тем самым подготовка заняла контейнера заняло 7:55, то есть старт приложения занял 9:49, а по стандарту должно быть не более 0:30.

## Уменьшение разамера образа
Первое, что бросается в глаза, при взгляде на команду запуска, это установка wget, ipywidgets и matplotlib в нарушении ЦИ-3 - так как в продуктовой среде не будет доступа к внешним сервисам и все зависимости должны быть уже в образе. Второе - после скачивания реестра доступных пакетов с помощью `apt update` - отсутствие их очистки `apt-get clean all`. Третье - запуск в приложения в оболочке BASH, что не позволит работать с приложением напрямую и передать ему сигнал на останоку. Создадим образ:
```
cat << 'EOF' > Dockerfile
FROM pytorch/pytorch AS dev
WORKDIR /workspace
ADD https://raw.githubusercontent.com/pytorch/tutorials/master/beginner_source/blitz/cifar10_tutorial.py /workspace
RUN pip install ipywidgets matplotlib
CMD ["/opt/conda/bin/python3", "/workspace/cifar10_tutorial.py"]
EOF

docker build -t cifar10_tutorial:0.1 .
docker images | grep cifar10_tutorial
```

Посмотрим на слои образа `docker history pytorch/pytorch`{{execute T1}}. Мы видим, что самый большой слой conda (3.37GB) - это пакеты conda. Мы можем посмотреть на более маленьки образы в которых меньше пакеты, например, на `docker pull bitnami/pytorch`, но всё равно размер образа велик - 2.63GB (`docker images | grep bitnami/pytorch`). Проблема в отсутствии разделения окружений на окружении для разрарботки и сборки и окружения для запуска на производственной среде. На`пример, если мы разрабатываем на Go - для сборки нам нужны испходники библиотек, компилятор и программная оболочка, для запуска нам нужен только результирующий бинарный файл. Если мы разрабатываем на Java нам нужны исходники проекта, оболочка и Maven/Gradle, а для выполнения Java-машина и JAR-архив. Если мы разрабатываем Front-end, то нем нужен оболочка, фреймворк с его cli, исходники проекта и библиотек, NodeJS c его библиотеками, а для выполения - несколько текстовых файлов (css, js, html). В нашем примере для разработки и обучения нужна платформа Anaconda с pytorch, а для запуска - python. В случае с Go нам нужно получить бинарный файл и скопировать в новое окружение, в случае с Java - JAR-архив, в случае с ML - обученная модель. Попросим разработчика разделить окружения с перенести модель в производственное окружение и файл на две части (сохранение в нём в файл ./cifar_net.pth уже есть):
```
cat << 'EOF' > Dockerfile
FROM pytorch/pytorch AS build
WORKDIR /workspace
ADD https://raw.githubusercontent.com/pytorch/tutorials/master/beginner_source/blitz/cifar10_tutorial.py /workspace
RUN pip install ipywidgets matplotlib
RUN /opt/conda/bin/python3 /workspace/cifar10_tutorial.py

FROM python:3 as production
COPY --from=build /tmp/model .
CMD ["/opt/conda/bin/python3", "/tmp/model"]
EOF

docker build -t cifar10_tutorial:0.1 .
docker images | grep cifar10_tutorial
```
Попросим DevOps оптимизировать итоговое окружение. Базовый образ nvidia/cuda:10.0-base занимает 109MB:
```
FROM nvidia/cuda:10.0-base
ARG CONDA_DIR=/opt/conda
ARG USERNAME=docker
ARG USERID=1000
ENV PATH $CONDA_DIR/bin:$PATH
RUN useradd --create-home -s /bin/bash --no-user-group -u $USERID $USERNAME && \
    chown $USERNAME $CONDA_DIR -R && \
    adduser $USERNAME sudo && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /home/$USERNAMECOPY --chown=1000 --from=build /opt/conda/. $CONDA_DIR
```{{execute T1}}
Соберите итоговое окружение, проверьте работоспособность и размер образа.

Можно скомпилировать при помощи TorchScript + PyTorch JIT в бинарный файл, что даст меньший размер 
и большую скорость.

## Объём памяти и скорость работы.
Для большей точности разработчики по аналогии с GoogLeNet и насамблеми методов создали четыре конфигурации сети, запуская их процессами. Из-за того, что PyTorch потребляет примерно 2Gb на ядро Cuda - то это приведёт к потреблению более 8Gb (нарушению Ци-7) и более 4 ядер (4 ядра на воркеры и одно на родительский процесс) (нарушает Ци-8). Такой подход масштабирования приводит к множественным процессам, что противоречит RS-3.1. Запустим их в отдельных контейнерах (подах).
```
import os
print(os.environ["CUDA_VISIBLE_DEVICES"])
```