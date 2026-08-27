extends Node
class_name MatchManager
## Orquesta una partida completa: spawnea jugador + bots, corre los ciclos
## de 30s (preparación/caza, docs/RULES.md), valida kills, reparte BOX según
## la alianza congelada en el instante de la eliminación (docs/BOX.md) y
## declara al ganador. Pensado para migrar a servidor autoritativo en la
## Fase 3 sin romper esta interfaz (ver docs/ARCHITECTURE.md).

signal cycle_phase_changed(phase: String, seconds_left: float, cycle_number: int)
signal alive_count_changed(count: int, total: int)
signal player_eliminated(victim: Player, killer: Player, reward_each: float, recipients: Array)
signal match_ended(summary: Dictionary)
signal map_event_triggered(event_name: String)
signal local_health_changed(current: float, max_health: float)
signal local_ability_ready(ready: bool)

enum Phase { PREP, HUNT }

var map_ref: NovaCity
var alliance_manager: AllianceManager
var players: Array = [] # Array[Player]
var local_player: Player
var is_running := false
var current_phase: int = Phase.PREP
var phase_time_left := 0.0
var cycle_number := 0

var kills_by_player: Dictionary = {}
var box_earned_by_player: Dictionary = {}
var match_start_time := 0.0

var _bot_brains: Dictionary = {}

func start_match(p_map_ref: NovaCity, spawn_points: Array, bot_count: int) -> void:
	map_ref = p_map_ref
	alliance_manager = AllianceManager.new()

	var ids := CharacterData.get_roster_ids()
	var used_points: Array = spawn_points.duplicate()
	used_points.shuffle()

	local_player = Player.new()
	local_player.setup("local", Game.player_name, Game.selected_character_id, false)
	local_player.is_local = true
	map_ref.add_child(local_player)
	local_player.global_position = used_points.pop_back()
	players.append(local_player)
	kills_by_player[local_player.player_id] = 0
	box_earned_by_player[local_player.player_id] = 0.0

	var bot_names := ["Cerbero", "Nix", "Tigre", "Halcon", "Vipera", "Cuervo", "Fenix", "Lobo", "Puma", "Zorro", "Buho", "Mantis", "Kraken", "Escorpion", "Jaguar"]
	bot_names.shuffle()

	for i in range(min(bot_count, used_points.size())):
		var bot := Player.new()
		var cid: String = ids[i % ids.size()]
		var bname: String = bot_names[i % bot_names.size()]
		bot.setup("bot_%d" % i, bname, cid, true)
		map_ref.add_child(bot)
		bot.global_position = used_points.pop_back()
		players.append(bot)
		kills_by_player[bot.player_id] = 0
		box_earned_by_player[bot.player_id] = 0.0
		_bot_brains[bot.player_id] = BotBrain.new(bot)

	for p in players:
		p.died.connect(_on_player_died)
		p.health_changed.connect(_on_any_health_changed.bind(p))

	is_running = true
	match_start_time = Time.get_ticks_msec() / 1000.0
	cycle_number = 0
	_begin_phase(Phase.PREP)

func _process(delta: float) -> void:
	if not is_running:
		return
	phase_time_left -= delta
	for p in players:
		if p.is_bot and p.is_alive:
			var brain: BotBrain = _bot_brains.get(p.player_id)
			if brain:
				brain.tick(delta, players, current_phase == Phase.HUNT, alliance_manager, map_ref)

	if phase_time_left <= 0.0:
		if current_phase == Phase.PREP:
			_begin_phase(Phase.HUNT)
		else:
			cycle_number += 1
			_maybe_trigger_map_event()
			_begin_phase(Phase.PREP)

	cycle_phase_changed.emit(_phase_name(), max(phase_time_left, 0.0), cycle_number)

func _begin_phase(phase: int) -> void:
	current_phase = phase
	phase_time_left = RemoteConfig.get_cycle_prep_seconds() if phase == Phase.PREP else RemoteConfig.get_cycle_hunt_seconds()
	var can_damage := phase == Phase.HUNT
	for p in players:
		p.can_take_damage = can_damage

func _phase_name() -> String:
	return "PREPARACIÓN" if current_phase == Phase.PREP else "CAZA"

func local_attack() -> void:
	if not is_running or not local_player or not local_player.is_alive:
		return
	local_player.try_attack(players)

func local_use_ability() -> void:
	if not is_running or not local_player or not local_player.is_alive:
		return
	if not local_player.can_use_ability():
		return
	local_player.trigger_ability_cooldown()
	_apply_ability(local_player)
	local_ability_ready.emit(false)

func _apply_ability(p: Player) -> void:
	match p.character_id:
		"rex":
			var fwd := Vector2.RIGHT.rotated(p.rotation)
			map_ref.spawn_temp_barrier(p.global_position + fwd * 50.0, p.rotation, p.stats.get("barricade_duration", 6.0))
		"luna":
			var radius: float = p.stats.get("trail_radius", 260.0)
			var dur: float = p.stats.get("trail_duration", 5.0)
			for other in players:
				if other == p or not other.is_alive:
					continue
				if other.global_position.distance_to(p.global_position) <= radius:
					other.reveal_for(dur)
		"max":
			var fwd2 := Vector2.RIGHT.rotated(p.rotation)
			map_ref.spawn_trap(p.global_position + fwd2 * 40.0, p.stats.get("trap_damage", 30.0), p)
		"maya":
			p.heal(p.stats.get("heal_amount", 30.0))
		"kai":
			p.apply_turbo(p.stats.get("turbo_multiplier", 1.8), p.stats.get("turbo_duration", 3.0))

func _on_any_health_changed(current: float, max_health: float, p: Player) -> void:
	if p == local_player:
		local_health_changed.emit(current, max_health)

func _on_player_died(victim: Player, killer: Player) -> void:
	var alive := _count_alive()
	alive_count_changed.emit(alive, players.size())

	if killer and killer != victim:
		kills_by_player[killer.player_id] = kills_by_player.get(killer.player_id, 0) + 1
		var recipients: Array = alliance_manager.get_alliance_members(killer.player_id)
		if recipients.is_empty():
			recipients = [killer.player_id]
		var reward_each := RemoteConfig.get_kill_reward() / float(recipients.size())
		for pid in recipients:
			box_earned_by_player[pid] = box_earned_by_player.get(pid, 0.0) + reward_each
			if pid == "local":
				Game.add_box(reward_each)
		player_eliminated.emit(victim, killer, reward_each, recipients)

	alliance_manager.on_player_removed(victim.player_id)

	if alive <= 1:
		_end_match()

func _count_alive() -> int:
	var c := 0
	for p in players:
		if p.is_alive:
			c += 1
	return c

func _end_match() -> void:
	is_running = false
	var winner: Player = null
	for p in players:
		if p.is_alive:
			winner = p
			break

	var local_won := winner == local_player and winner != null
	if local_won:
		Game.add_stars(1)

	var summary := {
		"winner_name": winner.display_name if winner else "Nadie",
		"winner_is_local": local_won,
		"local_survived": local_player.is_alive,
		"local_kills": kills_by_player.get("local", 0),
		"local_box_earned": box_earned_by_player.get("local", 0.0),
		"local_stars_earned": 1 if local_won else 0,
		"survival_seconds": Time.get_ticks_msec() / 1000.0 - match_start_time,
		"total_players": players.size(),
	}
	match_ended.emit(summary)

func _maybe_trigger_map_event() -> void:
	var events: Array = RemoteConfig.get_map_events()
	if events.is_empty():
		return
	if randf() > 0.6:
		return
	var event_name: String = events[randi() % events.size()]
	map_event_triggered.emit(event_name)
	map_ref.trigger_event(event_name, players)
