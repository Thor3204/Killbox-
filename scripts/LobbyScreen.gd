extends Control
class_name LobbyScreen

signal play_pressed

var stars_label: Label
var box_label: Label
var char_name_label: Label
var char_desc_label: Label
var event_label: Label
var selected_card: PanelContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_refresh_update_banner()
	RemoteConfig.config_updated.connect(_refresh_update_banner)

func _panel_style(bg: Color, radius: int = 18, border: Color = Color.TRANSPARENT, width: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	s.border_width_left = width
	s.border_width_right = width
	s.border_width_top = width
	s.border_width_bottom = width
	s.border_color = border
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 16
	s.content_margin_bottom = 16
	return s

func _label(text: String, size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _build_ui() -> void:
	var bg := KillboxBackdrop.new()
	add_child(bg)

	var top := HBoxContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.position = Vector2(34, 24)
	top.size = Vector2(1212, 72)
	top.add_theme_constant_override("separation", 12)
	add_child(top)

	var logo := _label("KILLBOX", 28, Color("#F5F8FA"))
	top.add_child(logo)
	var sub := _label("  /  NOVA CITY", 14, Color("#62E8C5"))
	top.add_child(sub)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	var player := _label(Game.player_name.to_upper(), 15, Color("#B6C1C8"))
	top.add_child(player)
	stars_label = _label("★ %d" % Game.stars, 17, Color("#FFD166"))
	top.add_child(stars_label)
	box_label = _label("◈ %.0f BOX" % Game.box, 17, Color("#62E8C5"))
	top.add_child(box_label)

	var title := _label("ELIGE A TU SUPERVIVIENTE", 28, Color("#F5F8FA"))
	title.position = Vector2(48, 118)
	add_child(title)
	var hint := _label("Cada profesión juega distinto. Todos pueden luchar.", 14, Color("#718089"))
	hint.position = Vector2(50, 154)
	add_child(hint)

	var roster := HBoxContainer.new()
	roster.position = Vector2(46, 192)
	roster.size = Vector2(780, 230)
	roster.add_theme_constant_override("separation", 10)
	add_child(roster)

	for cid in CharacterData.get_roster_ids():
		var data := CharacterData.get_character(cid)
		var btn := Button.new()
		btn.text = "%s\n%s" % [data.get("display_name", cid), data.get("role", "")]
		btn.custom_minimum_size = Vector2(145, 205)
		btn.add_theme_font_size_override("font_size", 15)
		btn.add_theme_color_override("font_color", Color("#EAF1F2"))
		btn.add_theme_stylebox_override("normal", _panel_style(Color(0.035, 0.05, 0.065, 0.94), 18, Color(0.16, 0.22, 0.25, 1), 1))
		btn.add_theme_stylebox_override("hover", _panel_style(Color(0.055, 0.085, 0.09, 0.98), 18, Color("#62E8C5"), 2))
		btn.add_theme_stylebox_override("pressed", _panel_style(Color(0.06, 0.11, 0.105, 1), 18, Color("#62E8C5"), 2))
		btn.pressed.connect(_on_character_selected.bind(cid))
		roster.add_child(btn)

	var info := PanelContainer.new()
	info.position = Vector2(850, 118)
	info.size = Vector2(382, 304)
	info.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.05, 0.065, 0.96), 22, Color(0.2, 0.85, 0.7, 0.15), 1))
	add_child(info)

	var info_box := VBoxContainer.new()
	info_box.add_theme_constant_override("separation", 10)
	info.add_child(info_box)
	info_box.add_child(_label("TU SUPERVIVIENTE", 11, Color("#62E8C5")))
	char_name_label = _label("", 31, Color("#F5F8FA"))
	info_box.add_child(char_name_label)
	char_desc_label = _label("", 14, Color("#AAB7BD"))
	char_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	char_desc_label.custom_minimum_size = Vector2(0, 80)
	info_box.add_child(char_desc_label)
	info_box.add_child(_label("EVENTO", 11, Color("#62E8C5")))
	event_label = _label("Próxima partida disponible\nEl administrador controla los horarios.", 14, Color("#AAB7BD"))
	info_box.add_child(event_label)
	_update_character_description()

	var play_btn := Button.new()
	play_btn.text = "JUGAR  →"
	play_btn.position = Vector2(850, 448)
	play_btn.size = Vector2(382, 78)
	play_btn.add_theme_font_size_override("font_size", 23)
	play_btn.add_theme_color_override("font_color", Color("#06100D"))
	play_btn.add_theme_stylebox_override("normal", _panel_style(Color("#62E8C5"), 16))
	play_btn.add_theme_stylebox_override("hover", _panel_style(Color("#86F3D5"), 16))
	play_btn.add_theme_stylebox_override("pressed", _panel_style(Color("#42CFAE"), 16))
	play_btn.pressed.connect(func(): play_pressed.emit())
	add_child(play_btn)

	var footer := _label("★ Las estrellas son victorias  ·  ◈ BOX es la moneda del juego", 12, Color("#5E6B72"))
	footer.position = Vector2(48, 630)
	add_child(footer)

func _on_character_selected(cid: String) -> void:
	Game.select_character(cid)
	_update_character_description()

func _update_character_description() -> void:
	var data := CharacterData.get_character(Game.selected_character_id)
	char_name_label.text = data.get("display_name", "")
	char_desc_label.text = "%s\n\nHABILIDAD: %s\n%s" % [data.get("role", ""), data.get("ability_name", ""), data.get("ability_description", "")]

func _refresh_update_banner() -> void:
	# El aviso técnico se mantiene discreto para no romper la experiencia del lobby.
	if RemoteConfig.update_available:
		event_label.text = "Nueva versión disponible · actualiza el APK"
		event_label.add_theme_color_override("font_color", Color("#FFD166"))
