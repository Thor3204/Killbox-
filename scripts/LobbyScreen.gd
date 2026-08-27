extends Control
class_name LobbyScreen
## Lobby (docs/UI-UX.md): personaje actual, nombre, estrellas, BOX, JUGAR.
## Muestra un aviso si hay una versión nueva publicada en game_config.json.

signal play_pressed

var stars_label: Label
var box_label: Label
var char_desc_label: Label
var update_banner: Label

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color8(12, 11, 13)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var header := VBoxContainer.new()
	header.position = Vector2(24, 20)
	add_child(header)

	var name_label := Label.new()
	name_label.text = Game.player_name
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	header.add_child(name_label)

	var stats_row := HBoxContainer.new()
	stats_row.add_theme_constant_override("separation", 18)
	header.add_child(stats_row)

	stars_label = Label.new()
	stars_label.text = "⭐ %d" % Game.stars
	stats_row.add_child(stars_label)

	box_label = Label.new()
	box_label.text = "◈ %.0f BOX" % Game.box
	stats_row.add_child(box_label)

	update_banner = Label.new()
	update_banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	update_banner.position = Vector2(0, 4)
	update_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	update_banner.add_theme_color_override("font_color", Color(0.95, 0.75, 0.2))
	update_banner.visible = false
	add_child(update_banner)
	_refresh_update_banner()
	RemoteConfig.config_updated.connect(_refresh_update_banner)

	var char_panel := VBoxContainer.new()
	char_panel.set_anchors_preset(Control.PRESET_CENTER)
	char_panel.position = Vector2(-260, -60)
	add_child(char_panel)

	var char_row := HBoxContainer.new()
	char_row.add_theme_constant_override("separation", 10)
	char_panel.add_child(char_row)

	for cid in CharacterData.get_roster_ids():
		var data := CharacterData.get_character(cid)
		var btn := Button.new()
		btn.text = data.get("display_name", cid)
		btn.custom_minimum_size = Vector2(90, 60)
		btn.pressed.connect(_on_character_selected.bind(cid))
		char_row.add_child(btn)

	char_desc_label = Label.new()
	char_desc_label.custom_minimum_size = Vector2(400, 60)
	char_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	char_panel.add_child(char_desc_label)
	_update_character_description()

	var play_btn := Button.new()
	play_btn.text = "JUGAR"
	play_btn.custom_minimum_size = Vector2(220, 64)
	play_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	play_btn.position = Vector2(-110, -80)
	play_btn.pressed.connect(func(): play_pressed.emit())
	add_child(play_btn)

func _on_character_selected(cid: String) -> void:
	Game.select_character(cid)
	_update_character_description()

func _update_character_description() -> void:
	var data := CharacterData.get_character(Game.selected_character_id)
	char_desc_label.text = "%s — %s\nHabilidad: %s" % [
		data.get("display_name", ""), data.get("role", ""), data.get("ability_name", "")
	]

func _refresh_update_banner() -> void:
	if RemoteConfig.update_available:
		update_banner.text = "Nueva versión disponible (%s) · actualiza el APK" % RemoteConfig.latest_version_label
		update_banner.visible = true
	else:
		update_banner.visible = false
