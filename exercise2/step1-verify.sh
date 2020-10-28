[ "$(kubectl get pods --all-namespaces)" != "No resources found" ] && 
[ "$(kubectl get pods -l app!=katacoda-cloud-provider -n kube-system -o=jsonpath='{.items[*].status.conditions[?(@.status == "False")].status}')" = "" ] && 
[ "$(kubectl get deploy -l app=app -o jsonpath={.items[0].metadata.name})" == 'app'] &&
echo "done"