# Interactive Katacoda Scenarios

[![](http://shields.katacoda.com/katacoda/webngt/count.svg)](https://www.katacoda.com/webngt "Get your profile on Katacoda.com")

Visit https://www.katacoda.com/webngt to view the profile and interactive scenarios

### Writing Scenarios
Visit https://www.katacoda.com/docs to learn more about creating Katacoda scenarios

For examples, visit https://github.com/katacoda/scenario-example

### Excercise number 1
Свойства
*     8. Возможность продолжить выполнение незавершенных бизнес-задач с момента отказа внешнего компонента/сервиса в случае наличия бизнес-смысла за счёт идемпотентность вызовов
*     5. Готовность к отказу и автоматическому самовосстановлению любого из компонентов приложения и внешних компонентов/сервисов, от которых оно зависит
*     3. Способность соблюдать нефункциональные требования при увеличении нагрузки послев добавления stateless экземпляров компонента

Требования
*     14. NA-1.1 Хранить настройки безопасности и обеспечивать шифрование трафика между компонентами  централизовано на уровне service mesh
*     10. Обработка корректным образом недоступности внешнего компонента/сервиса используя retry, timeout management 

### Excercise number 2
### Excercise number 3
> 1. 28 ЦИ-3 Запретить обращение к внешним сервисам для первоначального запуска контейнера - загружать все настройки, необходимые для запуска компонента, при старте контейнера из ConfigMap, Secrets, внешнего хранилища конфигураций, интегрированного в среду исполнения.
> 1. 29 ЦИ-4 Использовать контейнеры максимальным размером не более 1024 Мб
> 1. 30 ЦИ-5 Гарантировать максимальное время старта контейнера c загрузкой образа не более 30 секунд
> 1. 32 ЦИ-7 Использовать поды с максимумом 8 Гб памяти
> 1. 33 Ци-8 Использовать поды с максимумом 4 ядрами 
> 1. 22 RS-3.1 Обеспечивать горизонтальное масштабирование через создание stateless экземпляров компонент средствами оркестратора контейнеров
