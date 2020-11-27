#! /bin/bash
sudo snap install yq
cat /root/exercise/app.yaml | yq w - 'spec.template.spec.containers[0].volumeMounts[0].mountPath' /tmp > /tmp/app2.yaml
cat /tmp/app2.yaml          | yq w - 'spec.template.spec.containers[0].command' '["bash", "-c", "cp /tmp/* /app && node /app/server.js"]' > /tmp/app3.yaml
cp /tmp/app3.yaml /root/exercise/app.yaml