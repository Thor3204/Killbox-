extends RefCounted
class_name AllianceManager
## Alianzas y bandas (docs/ALLIANCES.md). La composición válida para repartir
## una recompensa se congela en el instante exacto de la eliminación
## (MatchManager llama get_alliance_members() justo cuando ocurre la kill).

signal alliance_formed(members: Array)
signal alliance_broken(player_id: String)
signal proposal_received(from_id: String, to_id: String)

var _alliances: Array = [] # Array[Array[String]]
var _pending: Dictionary = {} # "from|to" -> true

func propose(from_id: String, to_id: String) -> void:
	if are_allied(from_id, to_id):
		return
	_pending["%s|%s" % [from_id, to_id]] = true
	proposal_received.emit(from_id, to_id)

func has_pending_proposal(from_id: String, to_id: String) -> bool:
	return _pending.has("%s|%s" % [from_id, to_id])

func accept(from_id: String, to_id: String) -> void:
	var key := "%s|%s" % [from_id, to_id]
	if not _pending.has(key):
		return
	_pending.erase(key)

	var group_a := get_alliance_members(from_id)
	var group_b := get_alliance_members(to_id)
	_remove_from_all(group_a)
	_remove_from_all(group_b)

	var merged: Array = []
	for pid in group_a:
		if pid not in merged:
			merged.append(pid)
	for pid in group_b:
		if pid not in merged:
			merged.append(pid)
	if from_id not in merged:
		merged.append(from_id)
	if to_id not in merged:
		merged.append(to_id)

	_alliances.append(merged)
	alliance_formed.emit(merged)

func reject(from_id: String, to_id: String) -> void:
	_pending.erase("%s|%s" % [from_id, to_id])

func leave(player_id: String) -> void:
	for group in _alliances:
		if player_id in group:
			group.erase(player_id)
	_alliances = _alliances.filter(func(g): return g.size() >= 2)
	alliance_broken.emit(player_id)

func on_player_removed(player_id: String) -> void:
	leave(player_id)

func are_allied(a_id: String, b_id: String) -> bool:
	for group in _alliances:
		if a_id in group and b_id in group:
			return true
	return false

func get_alliance_members(player_id: String) -> Array:
	for group in _alliances:
		if player_id in group:
			return group.duplicate()
	return [player_id]

func _remove_from_all(ids: Array) -> void:
	for group in _alliances:
		for pid in ids:
			group.erase(pid)
	_alliances = _alliances.filter(func(g): return g.size() >= 2)
