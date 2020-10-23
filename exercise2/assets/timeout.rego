package k8s.timeout

allow[msg] {
  item := input.items[_]
  item.kind == "VirtualService"
  not item.spec.gateways
  item.spec.http[_].timeout
  msg := sprintf("Timeout для сервиса %v включён", [item.spec.hosts[0]])
}

deny[msg] {
  list := ["details", "productpage", "ratings", "reviews"]
  host := list[_]
  item := input.items[_]  
  item.kind == "VirtualService"
  host != item.spec.hosts[0]
  # spec.http.timeout: 0.5s
  msg := sprintf("Timeout не включён как минимум в %v", [host])       
}

error[{"reason": reason, "item": item}] {
    item := input.items[_]
    not item.spec.gateways
    item.kind != "VirtualService"
    reason:="Unexpected item.kind"
}

policy := { "allow": allow, "deny": deny, "err": error }
