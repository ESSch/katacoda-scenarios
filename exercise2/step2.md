## Проверка на формальное соответствие CloudNative
Здесь и далее Вам потребуется изменить приложение `server.js`{{open}} и конфиг `app.yaml`{{open}} (изменения сохраняются сразу), и применить изменения. Для применения необходимо обновить приложение и конфигурацию:
1. `kubectl delete configmap app`{{execute T1}}
2. `kubectl create configmap app --from-file=/root/exercise/server.js --from-file=/root/exercise/front.html`{{execute T1}}
3. `kubectl delete -f /root/exercise/app.yaml`{{execute T1}}
4. `kubectl apply  -f /root/exercise/app.yaml`{{execute T1}}

1. Запустите `checklist.sh`{{execute T1}}, для выполнения автоматизированных rego проверок, проводимых в CI.
2. Определите на основании проверки отклонения от стандарта: статус `1` - соответствует, статус `0` - несоответствует.
3. Выполните формальные соответствие требованиям RA-2.10 и RA-3.10 как указанно ниже, пока проверка не будет давать положительный результат о соответствии.

Проверка выполнения RA-2.10. Раскомментируйте liveness эндпойнт в приложении (`server.js`{{open}}) и его проверку в конфиге (`app.yaml`{{open}}). Убедитесь при помощи `kubectl describe -f /root/exercise/app.yaml`{{execute T1}} о проверки приложения.

Проверка выполнения RA-3.10. Раскомментируйте liveness эндпойт в приложении (`server.js`{{open}}) и его проверку в конфиге (`app.yaml`{{open}}). Убедитесь при помощи `kubectl describe -f /root/exercise/app.yaml`{{execute T1}} о проверки приложения.

