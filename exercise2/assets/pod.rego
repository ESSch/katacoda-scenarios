package k8s.pod

rs_owner_map[name] = owner {
    item := input.items[_] 
    item.kind == "Pod"                   
    name := item.metadata.name
    owner:=item.metadata.ownerReferences[_]
    owner.kind == "ReplicaSet"
}

all_owners_map[name] = owner {
    item := input.items[_] 
    item.kind == "Pod"                   
    name := item.metadata.name
    owner:=item.metadata.ownerReferences[_]
}

allow[msg] {  
    item := input.items[_]                                                                                                         
    owner := all_owners_map[item.metadata.name]
    msg := sprintf("Pod '%v': входит в %v '%v'", [item.metadata.name, owner.kind, owner.name])       
}

deny[msg] {
  item := input.items[_]   
  not rs_owner_map[item.metadata.name]
  msg := sprintf("Pod '%v': не использует абстракцию ReplicaSet", [item.metadata.name])       
}

error[{"reason": reason, "item": item}] {
    item := input.items[_]
    item.kind != "Pod"
    reason:="Unexpected item.kind"
}

policy := { "allow": allow, "deny": deny, "err": error }