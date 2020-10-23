package k8s.replicaset

deployment_owner_map[name] = owner {
    item := input.items[_] 
    item.kind == "ReplicaSet"                   
    name := item.metadata.name
    owner:=item.metadata.ownerReferences[_]
    owner.kind == "Deployment"
}

all_owners_map[name] = owner {
    item := input.items[_] 
    item.kind == "ReplicaSet"                   
    name := item.metadata.name
    owner:=item.metadata.ownerReferences[_]
}

allow[msg] {  
    item := input.items[_]                                                                                                         
    owner := all_owners_map[item.metadata.name]
    msg := sprintf("ReplicaSet '%v': входит в %v '%v'", [item.metadata.name, owner.kind, owner.name])       
}

deny[msg] {
  item := input.items[_]   
  not deployment_owner_map[item.metadata.name]
  msg := sprintf("ReplicaSet '%v': не использует абстракцию Deployment", [item.metadata.name])       
}

error[{"reason": reason, "item": item}] {
    item := input.items[_]
    item.kind != "ReplicaSet"
    reason:="Unexpected item.kind"
}

policy := { "allow": allow, "deny": deny, "err": error }