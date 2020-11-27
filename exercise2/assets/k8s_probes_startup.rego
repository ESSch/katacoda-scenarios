package k8s.cloud.startup

title_bundle := "Проверка на наличие startupProbe endpoint"
apply_startup_probe = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    t:=input.spec.template.spec.containers[_]
    t1:=t.startupProbe.httpGet.path
    startswith(t1, "/") == true
    count(t1)>2
    msg:="Проверка на startupProbe пройдена"
    status:= "1"
    type:="Проверка на наличие startupProbe endpoint"
    name:=input.metadata.name
 }
   else = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    t:=input.spec.template.spec.containers[_]
    t1:=t.startupProbe.tcpSocket.port
    count(t1)>0
    msg:="Проверка на startupProbe пройдена"
    status:= "1"
    type:="Проверка на наличие startupProbe endpoint"
    name:=input.metadata.name
 }
    else = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    t:=input.spec.template.spec.containers[_]
    t1:=t.startupProbe.exec.command
    count(t1)>2
    msg:="Проверка на startupProbe пройдена"
    status:="1"
    type:="Проверка на наличие startupProbe endpoint"
    name:=input.metadata.name
 }

 else = {"msg": msg, "status": status, "type": type, "name": name  }{
    deployment:=lower(input.kind)
    deployment == "deployment"
    msg := "Проверка на startupProbe не пройдена."
    status:= "0"
    type:="Проверка на наличие startupProbe endpoint"
    name:=input.metadata.name
}
else  = {"msg": msg, "status": status, "type": type  }{
    deployment:=lower(input.kind)
    deployment != "deployment"
    status:= "-1"
    type:="Проверка на наличие startupProbe endpoint"
    msg :=  sprintf("kind файла должен быть deployment. У вас он: %s", [deployment] )
}