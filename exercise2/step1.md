## История

На этом обязательном подготовительном шаге вам необходимо выступить в роли DevOps инженера команды и подготовить необходимую инфраструктуру для успешного прохождения упражнения

* учебный кластер Kubernetes
* Istio Service Mesh.

Выполните, пожалуйста, все необходимые шаги описанные ниже в этом шаге упражнения.

## Kubernetes

Дождитесь подтверждения запуска кластера в терминале, должно появиться такое сообщение

```
master $ launch.sh
Waiting for Kubernetes to start...
Kubernetes started
```

Убедитесь, что все поды находятстя в состоянии Running прежде чем двигаться дальше `kubectl get pods --all-namespaces`{{execute T1}}

Исключение может быть сделано для katacoda-cloud-provider он может остаться в статусе CrashLoopBackOff, что никак не влияет на дальнейшие шаги

## Istio

Запустите установку istio `cd /root && /usr/local/bin/istio-install.sh`{{execute T1}}

Проверьте, что все поды Istio в состоянии Running `kubectl get pods -n istio-system`{{execute T1}}

## TroubleShoot

* если зависла установка istio, запустите `/usr/local/bin/troubleshoot.sh`{{execute interrupt T1}}, после выполнения этой команды повторно запустите `/usr/local/bin/istio-install.sh`{{execute T1}}
* если описанный способ не помог, перезагрузите страницу упражнения и начните сценарий заново.
