package k8s.retry

allow[msg] {                                                                                                           
  item := input.items[_] 
  item.kind == "VirtualService"  
  not item.spec.gateways
  item.spec.http[_].retries
  msg := sprintf("Retry для сервиса %v включён", [item.spec.hosts[0]])     
}

deny[msg] {
  item := input.items[_]   
  item.kind == "VirtualService"
  not item.spec.gateways
  not item.spec.http[0].retries
  msg := sprintf("Mtls для сервиса %v выключен", [item.spec.hosts[0]])       
}

error[{"reason": reason, "item": item}] {
    item := input.items[_]
    not item.spec.gateways
    item.kind != "VirtualService"
    reason:="Unexpected item.kind"
}

policy := { "allow": allow, "deny": deny, "err": error }
