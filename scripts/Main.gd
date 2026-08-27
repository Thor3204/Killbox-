extends Node
class_name Main
## Orquestador de pantallas: Login -> Lobby -> Partida -> Fin -> Lobby.
## Todo el juego se arma por código para facilitar mantenimiento y versionado.

var screen_layer: CanvasLayer
var world_layer: Node2D
var current_screen: Control
var match_manager: MatchManager
var current_map: NovaCity
var current_hud: HUD

func _ready() -> void:
	Game.register_main(self)
	screen_layer = CanvasLayer.new()
	add_child(screen_layer)
	world_layer = Node2D.new()
	add_child(world_layer)
	show_login()

func _clear_screen() -> void:
	for c in screen_layer.get_children():
		c.queue_free()
	current_screen = null

func _clear_world() -> void:
	for c in world_layer.get_children():
		c.queue_free()
	if match_manager:
		match_manager.queue_free()
		match_manager = null

func show_login() -> void:
	_clear_screen()
	_clear_world()
	var login := LoginScreen.new()
	screen_layer.add_child(login)
	login.logged_in.connect(show_lobby)
	current_screen = login

func show_lobby() -> void:
	_clear_screen()
	_clear_world()
	RemoteConfig.start_polling()
	var lobby := LobbyScreen.new()
	screen_layer.add_child(lobby)
	lobby.play_pressed.connect(start_match)
	current_screen = lobby

func start_match() -> void:
	RemoteConfig.stop_polling()
	_clear_screen()

	current_map = NovaCity.new()
	world_layer.add_child(current_map)

	match_manager = MatchManager.new()
	add_child(match_manager)
	match_manager.start_match(current_map, current_map.spawn_points, RemoteConfig.get_bot_count())

	current_hud = HUD.new()
	screen_layer.add_child(current_hud)
	current_screen = current_hud

	current_hud.attack_pressed.connect(func(): match_manager.local_attack())
	current_hud.ability_pressed.connect(func(): match_manager.local_use_ability())
	current_hud.alliance_propose_pressed.connect(_on_alliance_propose)
	current_hud.alliance_accept_pressed.connect(_on_alliance_accept)
	current_hud.alliance_leave_pressed.connect(_on_alliance_leave)
	current_hud.joystick.direction_changed.connect(func(dir: Vector2):
		if match_manager.local_player:
			match_manager.local_player.input_vector = dir
	)

	match_manager.cycle_phase_changed.connect(current_hud.set_phase)
	match_manager.alive_count_changed.connect(current_hud.set_alive_count)
	match_manager.local_health_changed.connect(current_hud.set_health)
	match_manager.player_eliminated.connect(_on_player_eliminated)
	match_manager.match_ended.connect(_on_match_ended)
	match_manager.map_event_triggered.connect(current_hud.show_map_event)
	_attach_camera_when_ready()

func _attach_camera_when_ready() -> void:
	await get_tree().process_frame
	if match_manager and match_manager.local_player:
		var cam := Camera2D.new()
		cam.zoom = Vector2(1.1, 1.1)
		cam.position_smoothing_enabled = true
		cam.position_smoothing_speed = 6.0
		cam.limit_left = -1000
		cam.limit_right = 1000
		cam.limit_top = -600
		cam.limit_bottom = 600
		match_manager.local_player.add_child(cam)
		cam.make_current()

func _find_nearest_ally_target() -> Player:
	if not match_manager or not match_manager.local_player:
		return null
	var best: Player = null
	var best_dist: float = 140.0
	for p in match_manager.players:
		if p == match_manager.local_player or not p.is_alive:
			continue
		var d: float = p.global_position.distance_to(match_manager.local_player.global_position)
		if d < best_dist:
			best_dist = d
			best = p
	return best

func _on_alliance_propose() -> void:
	var target := _find_nearest_ally_target()
	if target and match_manager:
		match_manager.alliance_manager.propose("local", target.player_id)
		current_hud.flash_message("Alianza propuesta a %s" % target.display_name)

func _on_alliance_accept() -> void:
	var target := _find_nearest_ally_target()
	if target and match_manager and match_manager.alliance_manager.has_pending_proposal(target.player_id, "local"):
		match_manager.alliance_manager.accept(target.player_id, "local")
		current_hud.flash_message("Alianza formada con %s" % target.display_name)

func _on_alliance_leave() -> void:
	if match_manager:
		match_manager.alliance_manager.leave("local")
		current_hud.flash_message("Abandonaste la alianza")

func _on_player_eliminated(victim: Player, killer: Player, reward_each: float, recipients: Array) -> void:
	if current_hud:
		current_hud.show_kill_feed(killer.display_name, victim.display_name, reward_each, recipients.size())

func _on_match_ended(summary: Dictionary) -> void:
	_clear_screen()
	var overlay := MatchEndOverlay.new()
	screen_layer.add_child(overlay)
	overlay.setup(summary)
	overlay.continue_pressed.connect(show_lobby)
	current_screen = overlay
