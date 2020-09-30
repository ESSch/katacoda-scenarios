package k8s.retry

allow[msg] {                                                                                                           
  item := input.items[_] 
  item.kind == "VirtualService"  
  not item.spec.gateways
  item.spec.http[_].retries.attempts > 1
  msg := sprintf("Retry для сервиса %v включён", [item.spec.hosts[0]])     
}

deny[msg] {
  list := ["details", "productpage", "ratings", "reviews"]
  host := list[_]
  item := input.items[_]  
  item.kind == "VirtualService"
  host != item.spec.hosts[0]; #not item.spec.http[0].retries.attempts
  #item.spec.http[_].retries.attempts = 0
  #item.spec.retries > 1
  msg := sprintf("Retry не включён в %v", [host])       
}

error[{"reason": reason, "item": item}] {
    item := input.items[_]
    item.kind != "VirtualService"
    reason:="Unexpected item.kind"
}

policy := { "allow": allow, "deny": deny, "err": error }
