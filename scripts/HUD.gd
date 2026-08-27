extends Control
class_name HUD

signal attack_pressed
signal ability_pressed
signal alliance_propose_pressed
signal alliance_accept_pressed
signal alliance_leave_pressed

var joystick: KillboxVirtualJoystick
var health_fill: ColorRect
var alive_label: Label
var phase_label: Label
var timer_label: Label
var kill_feed_label: Label
var message_label: Label
var blackout_overlay: ColorRect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_hud()

func _panel_style(bg: Color, radius: int = 16, border: Color = Color.TRANSPARENT, width: int = 0) -> StyleBoxFlat:
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
	return s

func _label(text: String, size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _build_hud() -> void:
	var top := PanelContainer.new()
	top.position = Vector2(24, 18)
	top.size = Vector2(650, 68)
	top.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.04, 0.055, 0.92), 18, Color(0.15, 0.24, 0.27, 1), 1))
	add_child(top)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	top.add_child(row)

	var hp := VBoxContainer.new()
	hp.custom_minimum_size = Vector2(190, 0)
	row.add_child(hp)
	hp.add_child(_label("SALUD", 10, Color("#7E8B93")))
	var health_bg := ColorRect.new()
	health_bg.custom_minimum_size = Vector2(180, 12)
	health_bg.color = Color("#172027")
	hp.add_child(health_bg)
	health_fill = ColorRect.new()
	health_fill.color = Color("#62E8C5")
	health_fill.size = Vector2(180, 12)
	health_bg.add_child(health_fill)

	alive_label = _label("73 VIVOS", 17, Color("#F5F8FA"))
	row.add_child(alive_label)
	phase_label = _label("PREPARACIÓN", 12, Color("#62E8C5"))
	row.add_child(phase_label)
	timer_label = _label("30", 25, Color("#F5F8FA"))
	row.add_child(timer_label)

	var kill_card := PanelContainer.new()
	kill_card.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	kill_card.position = Vector2(-240, 18)
	kill_card.size = Vector2(210, 68)
	kill_card.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.04, 0.055, 0.92), 18, Color(0.9, 0.3, 0.24, 0.25), 1))
	add_child(kill_card)
	var kc := VBoxContainer.new()
	kill_card.add_child(kc)
	kc.add_child(_label("TU RECOMPENSA", 10, Color("#7E8B93")))
	kc.add_child(_label("◈ 90 BOX  /  KILL", 18, Color("#FFD166")))

	message_label = _label("", 16, Color("#F5F8FA"))
	message_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	message_label.position = Vector2(0, 105)
	message_label.size = Vector2(1280, 30)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.modulate.a = 0.0
	add_child(message_label)

	kill_feed_label = _label("", 13, Color("#B6C1C8"))
	kill_feed_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	kill_feed_label.position = Vector2(0, 140)
	kill_feed_label.size = Vector2(1280, 24)
	kill_feed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kill_feed_label.modulate.a = 0.0
	add_child(kill_feed_label)

	blackout_overlay = ColorRect.new()
	blackout_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	blackout_overlay.color = Color(0, 0, 0, 0)
	blackout_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(blackout_overlay)

	joystick = KillboxVirtualJoystick.new()
	joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.position = Vector2(42, -184)
	joystick.custom_minimum_size = Vector2(150, 150)
	add_child(joystick)

	var attack_btn := _action_button("ATACAR", 116, Color("#FF6B5D"))
	attack_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	attack_btn.position = Vector2(-142, -152)
	attack_btn.pressed.connect(func(): attack_pressed.emit())
	add_child(attack_btn)

	var ability_button := _action_button("HABILIDAD", 88, Color("#62E8C5"))
	ability_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	ability_button.position = Vector2(-260, -196)
	ability_button.pressed.connect(func(): ability_pressed.emit())
	add_child(ability_button)

	var alliance := Button.new()
	alliance.text = "🤝 ALIANZA"
	alliance.position = Vector2(30, 105)
	alliance.size = Vector2(150, 44)
	alliance.add_theme_font_size_override("font_size", 13)
	alliance.add_theme_stylebox_override("normal", _panel_style(Color(0.04, 0.07, 0.08, 0.9), 12, Color(0.25, 0.85, 0.72, 0.25), 1))
	alliance.pressed.connect(func(): alliance_propose_pressed.emit())
	add_child(alliance)

func _action_button(text: String, diameter: int, accent: Color) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(diameter, diameter)
	b.add_theme_font_size_override("font_size", 13 if diameter > 100 else 11)
	b.add_theme_color_override("font_color", Color("#F5F8FA"))
	b.add_theme_stylebox_override("normal", _panel_style(Color(0.035, 0.05, 0.065, 0.94), 999, Color(accent.r, accent.g, accent.b, 0.55), 2))
	b.add_theme_stylebox_override("hover", _panel_style(Color(0.07, 0.09, 0.105, 0.98), 999, accent, 2))
	return b

func set_phase(phase: String, seconds_left: float, _cycle: int) -> void:
	phase_label.text = phase.to_upper()
	var secs: int = int(ceil(seconds_left))
	timer_label.text = "%02d" % secs

func set_alive_count(count: int, total: int) -> void:
	alive_label.text = "%d/%d VIVOS" % [count, total]

func set_health(current: float, max_health: float) -> void:
	var ratio: float = 0.0 if max_health <= 0.0 else current / max_health
	health_fill.size.x = 180.0 * clamp(ratio, 0.0, 1.0)

func show_map_event(event_name: String) -> void:
	var labels := {"zona_peligrosa":"ZONA PELIGROSA", "apagon":"APAGÓN EN NOVA CITY", "suministro":"SUMINISTRO DISPONIBLE", "alarma":"ALARMA: POSICIONES REVELADAS"}
	flash_message(labels.get(event_name, "EVENTO DE MAPA"))
	if event_name == "apagon":
		_flash_blackout()

func _flash_blackout() -> void:
	var tw := create_tween()
	tw.tween_property(blackout_overlay, "color:a", 0.72, 0.45)
	tw.tween_interval(2.0)
	tw.tween_property(blackout_overlay, "color:a", 0.0, 1.0)

func show_kill_feed(killer_name: String, victim_name: String, reward_each: float, n_recipients: int) -> void:
	var txt := "%s eliminó a %s" % [killer_name, victim_name]
	if n_recipients > 1:
		txt += "  ·  %.1f BOX c/u  ·  ALIANZA x%d" % [reward_each, n_recipients]
	else:
		txt += "  ·  %.0f BOX" % reward_each
	kill_feed_label.text = txt
	kill_feed_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(2.5)
	tw.tween_property(kill_feed_label, "modulate:a", 0.0, 1.0)

func flash_message(text: String) -> void:
	message_label.text = text
	message_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(2.0)
	tw.tween_property(message_label, "modulate:a", 0.0, 1.0)
