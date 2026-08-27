extends Node2D
class_name NovaCity

const MAP_SIZE := Vector2(2000, 1200)
var spawn_points: Array = []

func _ready() -> void:
	_build_ground()
	_build_roads()
	_build_buildings()
	_build_props()
	_build_spawn_points()

func _poly(points: PackedVector2Array, color: Color, z: int = 0) -> Polygon2D:
	var p := Polygon2D.new()
	p.polygon = points
	p.color = color
	p.z_index = z
	add_child(p)
	return p

func _build_ground() -> void:
	_poly(PackedVector2Array([Vector2(-1000,-600),Vector2(1000,-600),Vector2(1000,600),Vector2(-1000,600)]), Color("#101A1D"), -20)
	# Subtle city blocks
	for x in range(-900, 901, 180):
		for y in range(-500, 501, 180):
			var r := Rect2(Vector2(x, y), Vector2(156, 156))
			draw_rect(r, Color(0.08, 0.12, 0.13, 0.35))
	# Central park
	_poly(PackedVector2Array([Vector2(-210,60),Vector2(210,60),Vector2(210,330),Vector2(-210,330)]), Color("#18372F"), -10)
	_poly(PackedVector2Array([Vector2(-185,85),Vector2(185,85),Vector2(185,305),Vector2(-185,305)]), Color("#24503E"), -9)
	for p in [Vector2(-130,130),Vector2(0,185),Vector2(120,125),Vector2(-80,260),Vector2(90,270)]:
		draw_circle(p, 18.0, Color("#39775A"))
		draw_circle(p + Vector2(0,-8), 11.0, Color("#4E946B"))

func _build_roads() -> void:
	# Wide roads with sidewalks and lane markings
	var roads := [Rect2(-1000,-80,2000,160), Rect2(-80,-600,160,1200), Rect2(-900,-430,1800,90), Rect2(-900,340,1800,90)]
	for r in roads:
		var outer := r.grow(10.0)
		draw_rect(outer, Color("#273236"))
		draw_rect(r, Color("#1B252A"))
		if r.size.x > r.size.y:
			for x in range(int(r.position.x)+20, int(r.end.x), 70):
				draw_rect(Rect2(x, r.position.y + r.size.y/2 - 2, 34, 4), Color(0.75,0.8,0.7,0.34))
		else:
			for y in range(int(r.position.y)+20, int(r.end.y), 70):
				draw_rect(Rect2(r.position.x + r.size.x/2 - 2, y, 4, 34), Color(0.75,0.8,0.7,0.34))

func _add_obstacle(pos: Vector2, obstacle_size: Vector2, color: Color, label_text: String = "") -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 4
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = obstacle_size
	shape.shape = rect
	body.add_child(shape)
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-obstacle_size.x/2,-obstacle_size.y/2),Vector2(obstacle_size.x/2,-obstacle_size.y/2),Vector2(obstacle_size.x/2,obstacle_size.y/2),Vector2(-obstacle_size.x/2,obstacle_size.y/2)])
	poly.color = color
	body.add_child(poly)
	var roof := Polygon2D.new()
	roof.polygon = PackedVector2Array([Vector2(-obstacle_size.x/2+8,-obstacle_size.y/2+8),Vector2(obstacle_size.x/2-8,-obstacle_size.y/2+8),Vector2(obstacle_size.x/2-8,obstacle_size.y/2-8),Vector2(-obstacle_size.x/2+8,obstacle_size.y/2-8)])
	roof.color = Color(color.r*0.72, color.g*0.72, color.b*0.72, 1.0)
	body.add_child(roof)
	if label_text != "":
		var lbl := Label.new()
		lbl.text = label_text
		lbl.position = Vector2(-obstacle_size.x/2+8,-9)
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color(0.95,0.98,0.96,0.78))
		body.add_child(lbl)
	add_child(body)
	return body

func _build_buildings() -> void:
	_add_obstacle(Vector2(-700,-300),Vector2(250,170),Color("#344B4F"),"SUPERMERCADO")
	_add_obstacle(Vector2(-330,-300),Vector2(180,125),Color("#4A3E47"),"RESTAURANTE")
	_add_obstacle(Vector2(300,-300),Vector2(170,125),Color("#394B58"),"APARTAMENTOS")
	_add_obstacle(Vector2(650,-290),Vector2(120,105),Color("#4B4540"),"CASA")
	_add_obstacle(Vector2(850,250),Vector2(190,150),Color("#384A4E"),"CLÍNICA")
	_add_obstacle(Vector2(-760,260),Vector2(190,130),Color("#514A3A"),"GASOLINERA")
	_add_obstacle(Vector2(-350,470),Vector2(160,105),Color("#463D43"),"CASA")
	_add_obstacle(Vector2(580,470),Vector2(210,125),Color("#3C4A55"),"CENTRO")

func _build_props() -> void:
	for v in [Vector2(-190,20),Vector2(180,30),Vector2(500,50),Vector2(-510,55),Vector2(700,170),Vector2(-70,390)]:
		_add_obstacle(v,Vector2(58,28),Color("#5B6970"))
	for b in [Vector2(0,-120),Vector2(320,100),Vector2(-460,160),Vector2(600,-120)]:
		_add_obstacle(b,Vector2(72,20),Color("#B18A42"))

func _build_spawn_points() -> void:
	spawn_points = [Vector2(-900,-500),Vector2(-900,500),Vector2(900,-500),Vector2(900,500),Vector2(-950,0),Vector2(950,0),Vector2(0,-500),Vector2(0,500),Vector2(-500,-500),Vector2(500,-500),Vector2(-500,500),Vector2(500,500),Vector2(-950,-250),Vector2(950,-250),Vector2(-950,250),Vector2(950,250),Vector2(-250,-500),Vector2(250,-500),Vector2(-100,500),Vector2(100,500),Vector2(-700,0),Vector2(700,0)]

func spawn_temp_barrier(pos: Vector2, rot: float, duration: float) -> void:
	var body := _add_obstacle(pos,Vector2(70,18),Color("#B18A42"))
	body.rotation = rot
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(body): body.queue_free()

func spawn_trap(pos: Vector2, damage: float, owner_player: Player) -> void:
	var area := Area2D.new()
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 26.0
	shape.shape = circle
	area.add_child(shape)
	var poly := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(10): pts.append(Vector2(cos(TAU*float(i)/10.0),sin(TAU*float(i)/10.0))*26.0)
	poly.polygon = pts
	poly.color = Color("#FF665A")
	area.add_child(poly)
	add_child(area)
	var triggered := false
	area.body_entered.connect(func(body):
		if triggered: return
		if body is Player and body != owner_player and body.is_alive:
			triggered = true
			body.take_damage(damage, owner_player)
			area.queue_free())
	await get_tree().create_timer(20.0).timeout
	if is_instance_valid(area) and not triggered: area.queue_free()

func trigger_event(event_name: String, players: Array) -> void:
	match event_name:
		"zona_peligrosa": _trigger_danger_zone(players)
		"apagon": pass
		"suministro": _trigger_supply_drop()
		"alarma": _trigger_alarm(players)

func _trigger_danger_zone(players: Array) -> void:
	var pos := Vector2(randf_range(-700,700),randf_range(-400,400))
	var radius := 180.0
	var zone := Area2D.new()
	zone.position = pos
	zone.collision_layer = 0
	zone.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	zone.add_child(shape)
	var poly := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(24): pts.append(Vector2(cos(TAU*float(i)/24.0),sin(TAU*float(i)/24.0))*radius)
	poly.polygon = pts
	poly.color = Color(0.9,0.18,0.14,0.24)
	zone.add_child(poly)
	add_child(zone)
	var tick_count := 0
	var timer := Timer.new()
	timer.wait_time = 0.5
	add_child(timer)
	timer.timeout.connect(func():
		tick_count += 1
		if not is_instance_valid(zone): timer.queue_free(); return
		for p in players:
			if p.is_alive and p.global_position.distance_to(zone.position) <= radius: p.take_damage(4.0,null)
		if tick_count >= 20:
			timer.queue_free()
			if is_instance_valid(zone): zone.queue_free())
	timer.start()

func _trigger_supply_drop() -> void:
	var pos := Vector2(randf_range(-700,700),randf_range(-400,400))
	var area := Area2D.new()
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 22.0
	shape.shape = circle
	area.add_child(shape)
	var poly := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(8): pts.append(Vector2(cos(TAU*float(i)/8.0),sin(TAU*float(i)/8.0))*18.0)
	poly.polygon = pts
	poly.color = Color("#62E8C5")
	area.add_child(poly)
	add_child(area)
	var used := false
	area.body_entered.connect(func(body):
		if used: return
		if body is Player and body.is_alive:
			used = true
			body.heal(25.0)
			area.queue_free())
	await get_tree().create_timer(25.0).timeout
	if is_instance_valid(area) and not used: area.queue_free()

func _trigger_alarm(players: Array) -> void:
	for p in players:
		if p.is_alive: p.reveal_for(4.0)

func draw_rect(rect: Rect2, color: Color) -> void:
	# Helper for generated world geometry.
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
	poly.color = color
	poly.z_index = -15
	add_child(poly)
