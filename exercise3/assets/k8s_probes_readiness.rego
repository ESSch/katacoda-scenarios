package k8s.cloud.readiness

title_bundle := "Проверка на наличие ReadinessProbe endpoint"
apply_rediness_probe = {"msg": msg, "status": status, "type": type, "name": name }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    t:=input.spec.template.spec.containers[_]
    t1:=t.readinessProbe.httpGet.path
    startswith(t1, "/") == true
    count(t1)>2
#    msg:=sprintf("Проверка на ReadinessProbe пройдена: %s", [t1])
    msg:="Проверка на ReadinessProbe пройдена"
    status:= "1"
    type:="Проверка на наличие ReadinessProbe endpoint"
    name:=input.metadata.name
 }
   else = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    t:=input.spec.template.spec.containers[_]
    t1:=t.readinessProbe.tcpSocket.port
    count(t1)>0
    msg:="Проверка на ReadinessProbe пройдена"
    status:= "1"
    type:="Проверка на наличие ReadinessProbe endpoint"
    name:=input.metadata.name
 }
   else = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    t:=input.spec.template.spec.containers[_]
    t1:=t.readinessProbe.exec.command
    count(t1)>2
    msg:="Проверка на ReadinessProbe пройдена"
    status:="1"
    type:="Проверка на наличие ReadinessProbe endpoint"
    name:=input.metadata.name
 }
 else = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    msg:="Проверка на ReadinessProbe не пройдена"
    status:= "0"
    type:="Проверка на наличие ReadinessProbe endpoint"
    name:=input.metadata.name
}
else  = {"msg": msg, "status": status, "type": type }{
    deployment:=lower(input.kind)
    deployment != "deployment"
    status:= "-1"
     type:="Проверка на наличие ReadinessProbe endpoint"
    msg :=  sprintf("kind файла должен быть deployment. У вас он: %s", [deployment] )
}