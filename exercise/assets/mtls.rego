package k8s.mtls

allow[msg] {                                                                                                           
  item := input.items[_] 
  item.kind == "DestinationRule"                   
  item.spec.trafficPolicy.tls.mode = "ISTIO_MUTUAL" 
  msg := sprintf("Mtls для сервиса %v включён", [item.spec.host])     
}

deny[msg] {
  item := input.items[_]   
  item.kind == "DestinationRule"
  item.spec.trafficPolicy.tls.mode != "ISTIO_MUTUAL" 
  msg := sprintf("Mtls для сервиса %v выключен", [item.spec.host])       
}

error[{"reason": reason, "item": item}] {
    item := input.items[_]
    item.kind != "DestinationRule"
    reason:="Unexpected item.kind"
}

policy := { "allow": allow, "deny": deny, "err": error }