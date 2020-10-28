## Обеспечение фактического соответствия CloudNative
Здесь и далее Вам потребуется изменить приложение и конфиг (изменения сохраняются сразу), и применить изменения, для этого:
1. `kubectl delete configmap app`{{execute T1}}
2. `kubectl create configmap app --from-file=/root/exercise/server.js --from-file=/root/exercise/front.html`{{execute T1}}
3. `kubectl delete -f /root/exercise/app.yaml`{{execute T1}}
4. `kubectl apply  -f /root/exercise/app.yaml`{{execute T1}}

Для фактической проверки убедимся в работе приложения. Дождитесь старта контейнера `kubectl get events -w --field-selector involvedObject.kind=Pod`{{execute T4}}: `Scheduled -> Pulled -> Created -> Started`. Так как у нас сейчас нет проб, учитывающих необходимое время для старта приложения - дайте приложению подняться несколько секунд. Перейдите http://[[HOST_SUBDOMAIN]]-30333-[[KATACODA_HOST]].environments.katacoda.com/ и посмотрите реакцию приложения `kubectl logs $(kubectl get pod -l app=app -o jsonpath={@.items[0].metadata.name}) -f`{{execute T3}}

Проверка выполнения RN-2.2. Сейчас при удалении статического файла эндпойнт liveness отвечает успехом, что приводит к 
получению трафику при фактически невозможности выполнять свою функцию. Измените эндпойнт liveness так, чтобы при отсутствии файла приложение было бы пересоздано. Например, `let status = fs.existsSync('front.html') ? 200 : 500`

Проверка выполнения NE-3.3. У нас приложение выдаёт код, который создаётся для каждого пользователя свой. Мы принимает, что генерация может выполняться долго и нет возможности распараллелить. Настройте readness пробу таким образом, что 
когда под "зависает" трафик переключается с него на другие, чтобы не создавать очередь. Например, `let status = fs.readFileSync(status.txt) == 'besy'`. Нагрузка 1 запрос в секунду.

Самостоятельно рассмотрите отработку readiness пробы во время обновления. Во время обновления пода нам нужно поддерживать работоспособность приложения. Для этого создадим нагрузку:
``
while true; do
  curl -s -I https://[[HOST_SUBDOMAIN]]-9000-[[KATACODA_HOST]].environments.katacoda.com/index.html || exit 1
  echo -n .;
  sleep 0.2
done
``{{execute T2}}
Будем отслеживать трафик результаты в Web терминале. Выполним обновление с помощью ``kubectl rollout status deployment.v1.apps/app``. Посмотрим, было ли приложение недоступным.