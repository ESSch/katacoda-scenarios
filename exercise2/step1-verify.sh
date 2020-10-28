[ "$(kubectl get deploy -l app=app -o jsonpath={.items[0].metadata.name})" == 'app' ] &&
echo "done"