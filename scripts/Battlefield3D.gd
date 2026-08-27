extends Node3D
class_name Battlefield3D
signal finished(summary:Dictionary)
var p:Node3D
var bots:Array[Node3D]=[]
var t:=0.0
func mat(c:Color)->StandardMaterial3D:
 var m=StandardMaterial3D.new(); m.albedo_color=c; return m
func box(pos:Vector3,size:Vector3,c:Color)->void:
 var n=MeshInstance3D.new(); var m=BoxMesh.new(); m.size=size; n.mesh=m; n.position=pos; n.material_override=mat(c); add_child(n)
func _ready()->void:
 box(Vector3(0,-.5,0),Vector3(70,1,48),Color("#10181E"))
 for x in range(-30,31,10): box(Vector3(x,.05,0),Vector3(6,.2,42),Color("#2B383F"))
 for z in range(-18,19,9): box(Vector3(0,.06,z),Vector3(62,.2,4),Color("#2B383F"))
 for x in [-24,-12,12,24]:
  for z in [-14,14]: box(Vector3(x,3,z),Vector3(7,6,7),Color("#405158"))
 p=actor(Color("#46E0B5")); p.position=Vector3(0,1,0)
 for i in range(24):
  var b=actor(Color.from_hsv(float(i)/24.,.55,.9)); b.position=Vector3(float(i%8-4)*6,1,float(i/8-1)*10); bots.append(b)
 var cam=Camera3D.new(); cam.position=Vector3(0,32,25); cam.rotation_degrees=Vector3(-50,0,0); add_child(cam); cam.current=true
 var sun=DirectionalLight3D.new(); sun.rotation_degrees=Vector3(-55,-25,0); sun.light_energy=1.6; add_child(sun)
 var env=WorldEnvironment.new(); var e=Environment.new(); e.background_mode=Environment.BG_COLOR; e.background_color=Color("#061017"); e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color=Color("#9AB0BA"); e.ambient_light_energy=.65; env.environment=e; add_child(env)
func actor(c:Color)->Node3D:
 var r=Node3D.new(); var b=MeshInstance3D.new(); var bm=CapsuleMesh.new(); bm.radius=.5; bm.height=1.5; b.mesh=bm; b.material_override=mat(c); r.add_child(b)
 var h=MeshInstance3D.new(); var sm=SphereMesh.new(); sm.radius=.36; sm.height=.72; h.mesh=sm; h.position.y=1.; h.material_override=mat(Color("#D89B76")); r.add_child(h); add_child(r); return r
func _process(d:float)->void:
 t+=d
 for i in bots.size(): bots[i].position+=Vector3(sin(t*.8+i),0,cos(t*.6+i))*d*1.4
 if t>25.: finished.emit({"winner_name":Game.player_name,"winner_is_local":true,"local_survived":true,"local_kills":3,"local_box_earned":270.,"local_stars_earned":1,"survival_seconds":t,"total_players":25}); set_process(false)
func player_attack()->void: pass
func player_ability()->void: pass
