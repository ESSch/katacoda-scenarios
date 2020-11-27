package k8s.cloud.liveness

title_bundle := "Проверка на наличие livenessProbe endpoint"
apply_liveness_probe = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    t:=input.spec.template.spec.containers[_]
    t1:=t.livenessProbe.httpGet.path
    startswith(t1, "/") == true
    count(t1)>2
    msg:="Проверка на livenessProbe пройдена"
    status:= "1"
    type:="Проверка на наличие livenessProbe endpoint"
    name:=input.metadata.name
 }
   else = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    t:=input.spec.template.spec.containers[_]
    t1:=t.livenessProbe.tcpSocket.port
    count(t1)>0
    msg:="Проверка на livenessProbe пройдена"
    status:= "1"
    type:="Проверка на наличие livenessProbe endpoint"
    name:=input.metadata.name
 }
    else = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    t:=input.spec.template.spec.containers[_]
    t1:=t.livenessProbe.exec.command
    count(t1)>2
    msg:="Проверка на livenessProbe пройдена"
    status:="1"
    type:="Проверка на наличие livenessProbe endpoint"
    name:=input.metadata.name
 }

 else = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    msg := "Проверка на livenessProbe не пройдена."
    status:= "0"
    type:="Проверка на наличие livenessProbe endpoint"
    name:=input.metadata.name
}
else  = {"msg": msg, "status": status, "type": type  }{
    deployment:=lower(input.kind)
    deployment != "deployment"
    status:= "-1"
    type:="Проверка на наличие livenessProbe endpoint"
    msg :=  sprintf("kind файла должен быть deployment. У вас он: %s", [deployment] )
}