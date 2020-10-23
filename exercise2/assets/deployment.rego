package k8s.deployment

allow[msg] {                                                                                                           
  item := input.items[_] 
  item.kind == "Deployment"                   
  item.spec.replicas > 1 
  msg := sprintf("Deployment '%v': Проверка на кол-во реплик пройдена. Реплик: %d", [item.metadata.name, item.spec.replicas])       
}

deny[msg] {
  item := input.items[_]   
  item.kind == "Deployment"                 
  item.spec.replicas == 1 
  msg := sprintf("Deployment '%v': Проверка на кол-во реплик не пройдена. Реплик: %d", [item.metadata.name, item.spec.replicas])       
}

error[{"reason": reason, "item": item}] {
    item := input.items[_]
    item.kind != "Deployment"
    reason:="Unexpected item.kind"
}

policy := { "allow": allow, "deny": deny, "err": error }