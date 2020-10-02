package k8s.mtls

allow[msg] {                                                                                                           
  item := input.items[_] 
  item.kind == "DestinationRule"                   
  item.spec.trafficPolicy.tls.mode = "ISTIO_MUTUAL" 
  msg := sprintf("mTLS для сервиса %v включён", [item.spec.host])     
}

deny[msg] {
  list := ["details", "productpage", "ratings", "reviews"]
  host := list[_]
  item := input.items[_]  
  item.kind == "DestinationRule"
  host != item.spec.hosts[0]
  item.spec.trafficPolicy.tls.mode != "ISTIO_MUTUAL"
  msg := sprintf("mTLS не включён в %v", [host])       
}

error[{"reason": reason, "item": item}] {
  item := input.items[_]
  item.kind != "DestinationRule"
  reason:="Unexpected item.kind for mTLS"
}

policy := { "allow": allow, "deny": deny, "err": error }