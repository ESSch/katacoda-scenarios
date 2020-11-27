# Interactive Katacoda Scenarios

[![](http://shields.katacoda.com/katacoda/webngt/count.svg)](https://www.katacoda.com/webngt "Get your profile on Katacoda.com")

Visit https://www.katacoda.com/webngt to view the profile and interactive scenarios

### Writing Scenarios
Visit https://www.katacoda.com/docs to learn more about creating Katacoda scenarios

For examples, visit https://github.com/katacoda/scenario-example

### Excercise number 1
> Свойства
> 1. 8 Возможность продолжить выполнение незавершенных бизнес-задач с момента отказа внешнего компонента/сервиса в случае наличия бизнес-смысла за счёт идемпотентность вызовов
> 1. 5 Готовность к отказу и автоматическому самовосстановлению любого из компонентов приложения и внешних компонентов/сервисов, от которых оно зависит
> 1. 3 Способность соблюдать нефункциональные требования при увеличении нагрузки послев добавления stateless экземпляров компонента

> Требования
> 1. 14 NA-1.1 Хранить настройки безопасности и обеспечивать шифрование трафика между компонентами  централизовано на уровне service mesh
> 1. 10 Обработка корректным образом недоступности внешнего компонента/сервиса используя retry, timeout management 

### Excercise number 2
> Требования
> 1. 15 RA-3.10 Публиковать информацию о готовности каждого компонента к приёму запросов через [readiness endpoint](https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
> 1. 16 RA-2.10 Публиковать информацию о жизнеспособности каждого компонента через [liveness endpoint](https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
> 1. 19 RN-2.2  Настроить [liveness probe](https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) в оркестраторе на liveness endpoint
> 1. 20 NE-3.3  Настроить [readiness probe](https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) в оркестраторе на readiness endpoint
> 1. 21 NE-3.4  Настроить [startup probe](https://kubernetes.io/ru/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) в оркестраторе на startup endpoint. В случае невозможности настройки использовать initialDelay в liveness probe.

### Excercise number 3
> 1. 28 ЦИ-3 Запретить обращение к внешним сервисам для первоначального запуска контейнера - загружать все настройки, необходимые для запуска компонента, при старте контейнера из ConfigMap, Secrets, внешнего хранилища конфигураций, интегрированного в среду исполнения.
> 1. 29 ЦИ-4 Использовать контейнеры максимальным размером не более 1024 Мб
> 1. 30 ЦИ-5 Гарантировать максимальное время старта контейнера c загрузкой образа не более 30 секунд
> 1. 32 ЦИ-7 Использовать поды с максимумом 8 Гб памяти
> 1. 33 Ци-8 Использовать поды с максимумом 4 ядрами 
> 1. 22 RS-3.1 Обеспечивать горизонтальное масштабирование через создание stateless экземпляров компонент средствами оркестратора контейнеров
