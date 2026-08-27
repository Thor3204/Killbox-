extends Node
## Estado local V1. No hay backend ni dinero real.

signal stars_changed(new_total: int)
signal box_changed(new_total: float)

const SAVE_PATH := "user://profile.json"
const TEST_STARTING_BOX := 2000.0
const CHARACTER_CHANGE_COST := 200.0

var player_name := ""
var selected_character_id := "rex"
var stars := 0
var box := TEST_STARTING_BOX
var profile_completed := false
var main_ref: Node = null

func _ready() -> void:
	_load_profile()

func register_main(main_node: Node) -> void:
	main_ref = main_node

func has_profile() -> bool:
	return profile_completed and not player_name.strip_edges().is_empty()

func set_player_name(new_name: String) -> void:
	player_name = new_name.strip_edges()
	if player_name.is_empty():
		player_name = "Superviviente"
	_save_profile()

func complete_profile(character_id: String) -> void:
	selected_character_id = character_id
	profile_completed = true
	_save_profile()

func select_character(character_id: String) -> bool:
	if character_id == selected_character_id:
		return true
	if box < CHARACTER_CHANGE_COST:
		return false
	box -= CHARACTER_CHANGE_COST
	selected_character_id = character_id
	box_changed.emit(box)
	_save_profile()
	return true

func add_stars(amount: int) -> void:
	stars += amount
	stars_changed.emit(stars)
	_save_profile()

func add_box(amount: float) -> void:
	box += amount
	box_changed.emit(box)
	_save_profile()

func _save_profile() -> void:
	var data := {
		"player_name": player_name,
		"selected_character_id": selected_character_id,
		"stars": stars,
		"box": box,
		"profile_completed": profile_completed,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))

func _load_profile() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	player_name = str(parsed.get("player_name", ""))
	selected_character_id = str(parsed.get("selected_character_id", selected_character_id))
	stars = int(parsed.get("stars", stars))
	box = float(parsed.get("box", TEST_STARTING_BOX))
	profile_completed = bool(parsed.get("profile_completed", false))
