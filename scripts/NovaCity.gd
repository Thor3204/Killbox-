extends Node2D
class_name NovaCity
## Mapa V1 (docs/WORLD.md): supermercado, restaurante, casas, apartamentos,
## parque, gasolinera, calles/callejones, vehículos abandonados y barricadas.
## Sin escondite absolutamente seguro: eventos de mapa fuerzan movimiento.

const MAP_SIZE := Vector2(2000, 1200)

var spawn_points: Array = []

func _ready() -> void:
	_build_ground()
	_build_buildings()
	_build_props()
	_build_spawn_points()

func _build_ground() -> void:
	var ground := Polygon2D.new()
	ground.polygon = PackedVector2Array([
		Vector2(-MAP_SIZE.x / 2, -MAP_SIZE.y / 2), Vector2(MAP_SIZE.x / 2, -MAP_SIZE.y / 2),
		Vector2(MAP_SIZE.x / 2, MAP_SIZE.y / 2), Vector2(-MAP_SIZE.x / 2, MAP_SIZE.y / 2)
	])
	ground.color = Color8(46, 44, 40)
	add_child(ground)

	var park := Polygon2D.new()
	park.polygon = PackedVector2Array([
		Vector2(-200, 60), Vector2(200, 60), Vector2(200, 320), Vector2(-200, 320)
	])
	park.color = Color8(58, 74, 46)
	add_child(park)

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
	poly.polygon = PackedVector2Array([
		Vector2(-obstacle_size.x / 2, -obstacle_size.y / 2), Vector2(obstacle_size.x / 2, -obstacle_size.y / 2),
		Vector2(obstacle_size.x / 2, obstacle_size.y / 2), Vector2(-obstacle_size.x / 2, obstacle_size.y / 2)
	])
	poly.color = color
	body.add_child(poly)

	if label_text != "":
		var lbl := Label.new()
		lbl.text = label_text
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
		lbl.position = Vector2(-obstacle_size.x / 2 + 4, -obstacle_size.y / 2 + 2)
		body.add_child(lbl)

	add_child(body)
	return body

func _build_buildings() -> void:
	_add_obstacle(Vector2(-700, -320), Vector2(260, 180), Color8(70, 60, 55), "SUPERMERCADO")
	_add_obstacle(Vector2(-320, -360), Vector2(180, 130), Color8(75, 55, 50), "RESTAURANTE")
	_add_obstacle(Vector2(80, -330), Vector2(110, 100), Color8(68, 58, 50), "CASA")
	_add_obstacle(Vector2(320, -330), Vector2(110, 100), Color8(68, 58, 50), "CASA")
	_add_obstacle(Vector2(560, -300), Vector2(120, 110), Color8(68, 58, 50), "CASA")
	_add_obstacle(Vector2(850, -300), Vector2(160, 260), Color8(72, 62, 58), "APARTAMENTOS")
	_add_obstacle(Vector2(-800, 220), Vector2(170, 130), Color8(64, 60, 50), "GASOLINERA")
	_add_obstacle(Vector2(-250, 380), Vector2(200, 100), Color8(70, 58, 52), "CASA")
	_add_obstacle(Vector2(750, 300), Vector2(200, 140), Color8(70, 58, 52), "CASA")

func _build_props() -> void:
	var vehicles := [Vector2(-200, 40), Vector2(150, 90), Vector2(500, -60), Vector2(-500, -60), Vector2(700, 150), Vector2(-100, 300)]
	for v in vehicles:
		_add_obstacle(v, Vector2(60, 28), Color8(50, 50, 55))

	var barricades := [Vector2(0, -120), Vector2(300, 60), Vector2(-420, 160), Vector2(600, -150)]
	for b in barricades:
		_add_obstacle(b, Vector2(70, 22), Color8(120, 90, 40))

func _build_spawn_points() -> void:
	spawn_points = [
		Vector2(-900, -450), Vector2(-900, 450), Vector2(900, -450), Vector2(900, 450),
		Vector2(-950, 0), Vector2(950, 0), Vector2(0, -500), Vector2(0, 500),
		Vector2(-500, -450), Vector2(500, -450), Vector2(-500, 450), Vector2(500, 450),
		Vector2(-950, -250), Vector2(950, -250), Vector2(-950, 250), Vector2(950, 250),
		Vector2(-250, -500), Vector2(250, -500), Vector2(-100, 500), Vector2(100, 500),
		Vector2(-700, 0), Vector2(700, 0)
	]

func spawn_temp_barrier(pos: Vector2, rot: float, duration: float) -> void:
	var body := _add_obstacle(pos, Vector2(70, 18), Color8(150, 140, 60))
	body.rotation = rot
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(body):
		body.queue_free()

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
	for i in range(10):
		var ang := TAU * float(i) / 10.0
		pts.append(Vector2(cos(ang), sin(ang)) * 26.0)
	poly.polygon = pts
	poly.color = Color(0.8, 0.15, 0.1, 0.55)
	area.add_child(poly)
	add_child(area)

	var triggered := false
	area.body_entered.connect(func(body):
		if triggered:
			return
		if body is Player and body != owner_player and body.is_alive:
			triggered = true
			body.take_damage(damage, owner_player)
			area.queue_free()
	)

	await get_tree().create_timer(20.0).timeout
	if is_instance_valid(area) and not triggered:
		area.queue_free()

func trigger_event(event_name: String, players: Array) -> void:
	match event_name:
		"zona_peligrosa":
			_trigger_danger_zone(players)
		"apagon":
			pass # el HUD escucha map_event_triggered y aplica el efecto visual
		"suministro":
			_trigger_supply_drop()
		"alarma":
			_trigger_alarm(players)

func _trigger_danger_zone(players: Array) -> void:
	var pos := Vector2(randf_range(-700, 700), randf_range(-400, 400))
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
	for i in range(24):
		var ang := TAU * float(i) / 24.0
		pts.append(Vector2(cos(ang), sin(ang)) * radius)
	poly.polygon = pts
	poly.color = Color(0.75, 0.1, 0.1, 0.22)
	zone.add_child(poly)
	add_child(zone)

	var tick_count := 0
	var timer := Timer.new()
	timer.wait_time = 0.5
	add_child(timer)
	timer.timeout.connect(func():
		tick_count += 1
		if not is_instance_valid(zone):
			timer.queue_free()
			return
		for p in players:
			if p.is_alive and p.global_position.distance_to(zone.position) <= radius:
				p.take_damage(4.0, null)
		if tick_count >= 20:
			timer.queue_free()
			if is_instance_valid(zone):
				zone.queue_free()
	)
	timer.start()

func _trigger_supply_drop() -> void:
	var pos := Vector2(randf_range(-700, 700), randf_range(-400, 400))
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
	for i in range(8):
		var ang := TAU * float(i) / 8.0
		pts.append(Vector2(cos(ang), sin(ang)) * 18.0)
	poly.polygon = pts
	poly.color = Color(0.2, 0.85, 0.5, 0.9)
	area.add_child(poly)
	add_child(area)
	var used := false
	area.body_entered.connect(func(body):
		if used:
			return
		if body is Player and body.is_alive:
			used = true
			body.heal(25.0)
			area.queue_free()
	)
	await get_tree().create_timer(25.0).timeout
	if is_instance_valid(area) and not used:
		area.queue_free()

func _trigger_alarm(players: Array) -> void:
	for p in players:
		if p.is_alive:
			p.reveal_for(4.0)
