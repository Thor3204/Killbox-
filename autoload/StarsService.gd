extends Node
## Persistencia local de estrellas y estadisticas del jugador.
## Las estrellas son una estadistica social/deportiva (ver docs/RULES.md,
## seccion 9): no son BOX, no se compran, no se transfieren.

signal data_changed

const SAVE_PATH := "user://killbox_save.json"

var stars: int = 0
var matches_played: int = 0
var wins: int = 0
var kills_total: int = 0

func _ready() -> void:
	_load()

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var json := JSON.new()
	if json.parse(text) != OK:
		return
	var d = json.data
	if typeof(d) != TYPE_DICTIONARY:
		return
	stars = int(d.get("stars", 0))
	matches_played = int(d.get("matches_played", 0))
	wins = int(d.get("wins", 0))
	kills_total = int(d.get("kills_total", 0))

func _save() -> void:
	var d := {
		"stars": stars,
		"matches_played": matches_played,
		"wins": wins,
		"kills_total": kills_total,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(d))
	f.close()

func register_match(won: bool, kills: int) -> void:
	matches_played += 1
	kills_total += kills
	if won:
		wins += 1
		stars += 1
	_save()
	data_changed.emit()
