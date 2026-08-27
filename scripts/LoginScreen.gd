extends Control
class_name LoginScreen

signal logged_in

var name_edit: LineEdit
var status_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()

func _panel_style(bg: Color, radius: int = 18, border: Color = Color.TRANSPARENT, border_width: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	s.border_width_left = border_width
	s.border_width_right = border_width
	s.border_width_top = border_width
	s.border_width_bottom = border_width
	s.border_color = border
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 18
	s.content_margin_bottom = 18
	return s

func _label(text: String, size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _build_ui() -> void:
	var bg := KillboxBackdrop.new()
	bg.variant = 0
	add_child(bg)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.02, 0.03, 0.34)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var content := HBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_CENTER)
	content.position = Vector2(-470, -235)
	content.size = Vector2(940, 470)
	content.add_theme_constant_override("separation", 70)
	add_child(content)

	var brand := VBoxContainer.new()
	brand.custom_minimum_size = Vector2(400, 0)
	brand.alignment = BoxContainer.ALIGNMENT_CENTER
	brand.add_theme_constant_override("separation", 10)
	content.add_child(brand)

	var kicker := _label("NOVA CITY  /  SURVIVAL ARENA", 14, Color("#62E8C5"))
	brand.add_child(kicker)
	var title := _label("KILLBOX", 72, Color("#F5F8FA"))
	title.add_theme_color_override("font_shadow_color", Color(0.1, 0.9, 0.72, 0.35))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 3)
	brand.add_child(title)
	brand.add_child(_label("Entra. Alíate. Sobrevive.", 22, Color("#B6C1C8")))
	brand.add_child(_label("Una ciudad. 100 supervivientes.\nSolo uno se lleva la victoria.", 16, Color("#7E8B93")))

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(430, 430)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.05, 0.065, 0.96), 24, Color(0.2, 0.85, 0.7, 0.18), 1))
	content.add_child(card)

	var form := VBoxContainer.new()
	form.add_theme_constant_override("separation", 14)
	card.add_child(form)

	form.add_child(_label("BIENVENIDO", 13, Color("#62E8C5")))
	form.add_child(_label("Crea tu superviviente", 30, Color("#F5F8FA")))
	form.add_child(_label("Este nombre aparecerá sobre tu personaje.", 14, Color("#7E8B93")))

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	form.add_child(spacer)

	var name_caption := _label("NOMBRE", 12, Color("#9AA7AE"))
	form.add_child(name_caption)
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Escribe tu nombre"
	name_edit.text = Game.player_name if Game.player_name != "Jugador" else ""
	name_edit.custom_minimum_size = Vector2(0, 58)
	name_edit.add_theme_font_size_override("font_size", 18)
	name_edit.add_theme_color_override("font_color", Color("#F5F8FA"))
	name_edit.add_theme_color_override("font_placeholder_color", Color("#58656D"))
	name_edit.add_theme_stylebox_override("normal", _panel_style(Color(0.055, 0.075, 0.09, 1), 12, Color(0.22, 0.3, 0.34, 1), 1))
	name_edit.add_theme_stylebox_override("focus", _panel_style(Color(0.06, 0.085, 0.10, 1), 12, Color("#62E8C5"), 2))
	name_edit.text_submitted.connect(func(_t): _on_enter())
	form.add_child(name_edit)

	var enter_btn := Button.new()
	enter_btn.text = "ENTRAR A KILLBOX  →"
	enter_btn.custom_minimum_size = Vector2(0, 62)
	enter_btn.add_theme_font_size_override("font_size", 18)
	enter_btn.add_theme_color_override("font_color", Color("#06100D"))
	enter_btn.add_theme_stylebox_override("normal", _panel_style(Color("#62E8C5"), 13))
	enter_btn.add_theme_stylebox_override("hover", _panel_style(Color("#86F3D5"), 13))
	enter_btn.add_theme_stylebox_override("pressed", _panel_style(Color("#42CFAE"), 13))
	enter_btn.pressed.connect(_on_enter)
	form.add_child(enter_btn)

	status_label = _label("Tu progreso se guarda en este dispositivo en la V1.", 12, Color("#64727A"))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	form.add_child(status_label)

	name_edit.grab_focus.call_deferred()

func _on_enter() -> void:
	var clean := name_edit.text.strip_edges()
	if clean.length() < 3:
		status_label.text = "Elige un nombre de al menos 3 caracteres."
		status_label.add_theme_color_override("font_color", Color("#FF8A7A"))
		name_edit.grab_focus()
		return
	Game.set_player_name(clean)
	logged_in.emit()
