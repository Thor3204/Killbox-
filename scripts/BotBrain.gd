extends RefCounted
class_name BotBrain
## IA simple para poblar partidas mientras no existe multijugador en red
## (docs/ROADMAP.md Fase 1-2: primero offline/bots, después multiplayer real).

enum State { WANDER, CHASE, FLEE }

var player: Player
var state: int = State.WANDER
var wander_target: Vector2
var _retarget_timer := 0.0
var _alliance_check_timer := 0.0

func _init(p: Player) -> void:
	player = p
	wander_target = p.global_position
	_alliance_check_timer = randf() * 3.0

func tick(delta: float, all_players: Array, combat_enabled: bool, alliance_mgr: AllianceManager, _map_ref: Node2D) -> void:
	if not player.is_alive:
		return

	_retarget_timer -= delta
	_alliance_check_timer -= delta

	var nearest_enemy: Player = null
	var nearest_dist := INF
	for other in all_players:
		if other == player or not other.is_alive:
			continue
		if alliance_mgr.are_allied(player.player_id, other.player_id):
			continue
		var d := player.global_position.distance_to(other.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest_enemy = other

	if combat_enabled and nearest_enemy and nearest_dist < 260.0:
		if player.health < player.max_health * 0.25 and nearest_dist < 160.0:
			state = State.FLEE
		else:
			state = State.CHASE
	else:
		state = State.WANDER

	match state:
		State.WANDER:
			if _retarget_timer <= 0.0:
				_retarget_timer = randf_range(1.5, 3.5)
				var offset := Vector2(randf_range(-220, 220), randf_range(-220, 220))
				wander_target = player.global_position + offset
			var dir := (wander_target - player.global_position)
			player.input_vector = Vector2.ZERO if dir.length() < 12.0 else dir.normalized()
		State.CHASE:
			var dir2 := (nearest_enemy.global_position - player.global_position).normalized()
			player.input_vector = dir2
			if nearest_dist < 44.0:
				player.try_attack(all_players)
		State.FLEE:
			var dir3 := (player.global_position - nearest_enemy.global_position).normalized()
			player.input_vector = dir3

	if not combat_enabled and _alliance_check_timer <= 0.0:
		_alliance_check_timer = randf_range(2.0, 4.0)
		_maybe_socialize(all_players, alliance_mgr)

func _maybe_socialize(all_players: Array, alliance_mgr: AllianceManager) -> void:
	if randf() > 0.35:
		return
	var candidates: Array = []
	for other in all_players:
		if other == player or not other.is_alive:
			continue
		if alliance_mgr.are_allied(player.player_id, other.player_id):
			continue
		if player.global_position.distance_to(other.global_position) < 150.0:
			candidates.append(other)
	if candidates.is_empty():
		return
	var target: Player = candidates[randi() % candidates.size()]
	if target.is_bot:
		if randf() < 0.5:
			alliance_mgr.propose(player.player_id, target.player_id)
			if randf() < 0.7:
				alliance_mgr.accept(player.player_id, target.player_id)
	else:
		alliance_mgr.propose(player.player_id, target.player_id)
