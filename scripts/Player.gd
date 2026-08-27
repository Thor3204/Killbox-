extends CharacterBody2D
class_name Player

signal died(player: Player, killer: Player)
signal health_changed(current: float, max_health: float)

const BODY_RADIUS := 16.0
const ATTACK_RANGE := 46.0
const ATTACK_ARC_DEGREES := 100.0
const ATTACK_COOLDOWN := 0.6

var player_id: String = ""
var display_name: String = "Jugador"
var character_id: String = "rex"
var stats: Dictionary = {}
var is_bot: bool = false
var is_local: bool = false

var max_health: float = 100.0
var health: float = 100.0
var move_speed: float = 160.0
var attack_damage: float = 16.0
var is_alive: bool = true
var can_take_damage: bool = false

var input_vector: Vector2 = Vector2.ZERO

var body_visual: Polygon2D
var outline: Line2D
var name_label: Label
var health_bar_fill: ColorRect

var _attack_cooldown_left: float = 0.0
var _ability_cooldown_left: float = 0.0

func setup(id: String, dname: String, char_id: String, bot: bool) -> void:
	player_id = id
	display_name = dname
	character_id = char_id
	is_bot = bot
	stats = CharacterData.get_character(char_id)
	max_health = stats.get("max_health", 100.0)
	health = max_health
	move_speed = stats.get("move_speed", 160.0)
	attack_damage = stats.get("attack_damage", 16.0)

func _ready() -> void:
	collision_layer = 1
	collision_mask = 5 # jugadores (1) + obstáculos (4)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = BODY_RADIUS
	shape.shape = circle
	add_child(shape)

	var pts := PackedVector2Array()
	var sides := 8
	for i in range(sides):
		var ang := TAU * float(i) / float(sides)
		pts.append(Vector2(cos(ang), sin(ang)) * BODY_RADIUS)

	body_visual = Polygon2D.new()
	body_visual.polygon = pts
	body_visual.color = stats.get("color", Color(0.7, 0.7, 0.7))
	add_child(body_visual)

	outline = Line2D.new()
	outline.points = pts
	outline.closed = true
	outline.width = 2.0
	outline.default_color = Color(0, 0, 0, 0.6)
	add_child(outline)

	var facing := Polygon2D.new()
	facing.polygon = PackedVector2Array([Vector2(BODY_RADIUS * 0.4, -4), Vector2(BODY_RADIUS + 6, 0), Vector2(BODY_RADIUS * 0.4, 4)])
	facing.color = Color(1, 1, 1, 0.75)
	add_child(facing)

	name_label = Label.new()
	name_label.text = display_name
	name_label.position = Vector2(-40, -BODY_RADIUS - 22)
	name_label.size = Vector2(80, 16)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	add_child(name_label)

	var health_bar_bg := ColorRect.new()
	health_bar_bg.color = Color(0, 0, 0, 0.5)
	health_bar_bg.position = Vector2(-20, -BODY_RADIUS - 8)
	health_bar_bg.size = Vector2(40, 5)
	add_child(health_bar_bg)

	health_bar_fill = ColorRect.new()
	health_bar_fill.color = Color(0.75, 0.15, 0.15)
	health_bar_fill.position = Vector2(-20, -BODY_RADIUS - 8)
	health_bar_fill.size = Vector2(40, 5)
	add_child(health_bar_fill)

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	if _attack_cooldown_left > 0.0:
		_attack_cooldown_left -= delta
	if _ability_cooldown_left > 0.0:
		_ability_cooldown_left -= delta

	velocity = input_vector * move_speed
	move_and_slide()

	if input_vector.length() > 0.05:
		rotation = input_vector.angle()

func try_attack(all_players: Array) -> Player:
	if not is_alive or _attack_cooldown_left > 0.0:
		return null
	_attack_cooldown_left = ATTACK_COOLDOWN
	var forward := Vector2.RIGHT.rotated(rotation)
	var best_target: Player = null
	var best_dist := ATTACK_RANGE + 1.0
	for other in all_players:
		if other == self or not other.is_alive:
			continue
		var to_other: Vector2 = other.global_position - global_position
		var dist := to_other.length()
		if dist > ATTACK_RANGE:
			continue
		var angle_diff := rad_to_deg(abs(forward.angle_to(to_other)))
		if angle_diff > ATTACK_ARC_DEGREES * 0.5:
			continue
		if dist < best_dist:
			best_dist = dist
			best_target = other
	if best_target:
		best_target.take_damage(attack_damage, self)
	return best_target

func take_damage(amount: float, attacker: Player) -> void:
	if not is_alive or not can_take_damage:
		return
	health = max(0.0, health - amount)
	health_bar_fill.size.x = 40.0 * (health / max_health)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		die(attacker)

func die(killer: Player) -> void:
	if not is_alive:
		return
	is_alive = false
	visible = false
	set_physics_process(false)
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	died.emit(self, killer)

func heal(amount: float) -> void:
	if not is_alive:
		return
	health = min(max_health, health + amount)
	health_bar_fill.size.x = 40.0 * (health / max_health)
	health_changed.emit(health, max_health)

func can_use_ability() -> bool:
	return is_alive and _ability_cooldown_left <= 0.0

func trigger_ability_cooldown() -> void:
	_ability_cooldown_left = stats.get("ability_cooldown", 12.0)

func reveal_for(duration: float) -> void:
	if not outline:
		return
	outline.default_color = Color(1, 0.85, 0.2, 0.95)
	outline.width = 4.0
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(self) and outline:
		outline.default_color = Color(0, 0, 0, 0.6)
		outline.width = 2.0

func apply_turbo(multiplier: float, duration: float) -> void:
	var base_speed := move_speed
	move_speed *= multiplier
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(self):
		move_speed = base_speed
