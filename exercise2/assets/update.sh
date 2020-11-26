        volumeMounts:
        - name: app
          mountPath: /tmp
        command: ["bash", "-c", "cp /tmp/* /app && node /app/server.js"]