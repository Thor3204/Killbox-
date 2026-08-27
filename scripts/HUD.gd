extends Control
class_name HUD
## HUD de partida (docs/UI-UX.md): vida/vivos/ciclo arriba, joystick
## abajo-izquierda, ataque/habilidad abajo-derecha, alianza contextual.

signal attack_pressed
signal ability_pressed
signal alliance_propose_pressed
signal alliance_accept_pressed
signal alliance_leave_pressed

var joystick: VirtualJoystick

var health_fill: ColorRect
var alive_label: Label
var phase_label: Label
var timer_label: Label
var kill_feed_label: Label
var message_label: Label
var blackout_overlay: ColorRect

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var top_bar := HBoxContainer.new()
	top_bar.position = Vector2(16, 12)
	top_bar.add_theme_constant_override("separation", 24)
	add_child(top_bar)

	var health_bg := ColorRect.new()
	health_bg.custom_minimum_size = Vector2(180, 18)
	health_bg.color = Color(0, 0, 0, 0.5)
	top_bar.add_child(health_bg)
	health_fill = ColorRect.new()
	health_fill.color = Color(0.8, 0.2, 0.2)
	health_fill.size = Vector2(180, 18)
	health_bg.add_child(health_fill)

	alive_label = Label.new()
	alive_label.text = "Vivos: -"
	_style_label(alive_label)
	top_bar.add_child(alive_label)

	phase_label = Label.new()
	phase_label.text = "PREPARACIÓN"
	_style_label(phase_label)
	top_bar.add_child(phase_label)

	timer_label = Label.new()
	timer_label.text = "00:00"
	_style_label(timer_label)
	top_bar.add_child(timer_label)

	message_label = Label.new()
	message_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	message_label.position = Vector2(0, 46)
	message_label.size = Vector2(get_viewport_rect().size.x, 26)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(message_label, 14)
	message_label.modulate.a = 0.0
	add_child(message_label)

	kill_feed_label = Label.new()
	kill_feed_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	kill_feed_label.position = Vector2(0, 76)
	kill_feed_label.size = Vector2(get_viewport_rect().size.x, 22)
	kill_feed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(kill_feed_label, 13)
	kill_feed_label.modulate.a = 0.0
	add_child(kill_feed_label)

	blackout_overlay = ColorRect.new()
	blackout_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	blackout_overlay.color = Color(0, 0, 0, 0)
	blackout_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(blackout_overlay)

	joystick = VirtualJoystick.new()
	joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.position = Vector2(40, -180)
	add_child(joystick)

	var attack_btn := Button.new()
	attack_btn.text = "ATAQUE"
	attack_btn.custom_minimum_size = Vector2(96, 96)
	attack_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	attack_btn.position = Vector2(-120, -130)
	attack_btn.pressed.connect(func(): attack_pressed.emit())
	add_child(attack_btn)

	var ability_button := Button.new()
	ability_button.text = "HABILIDAD"
	ability_button.custom_minimum_size = Vector2(84, 84)
	ability_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	ability_button.position = Vector2(-230, -180)
	ability_button.pressed.connect(func(): ability_pressed.emit())
	add_child(ability_button)

	var alliance_box := VBoxContainer.new()
	alliance_box.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	alliance_box.position = Vector2(-160, -50)
	add_child(alliance_box)

	var propose_btn := Button.new()
	propose_btn.text = "Proponer alianza"
	propose_btn.pressed.connect(func(): alliance_propose_pressed.emit())
	alliance_box.add_child(propose_btn)

	var accept_btn := Button.new()
	accept_btn.text = "Aceptar alianza"
	accept_btn.pressed.connect(func(): alliance_accept_pressed.emit())
	alliance_box.add_child(accept_btn)

	var leave_btn := Button.new()
	leave_btn.text = "Abandonar alianza"
	leave_btn.pressed.connect(func(): alliance_leave_pressed.emit())
	alliance_box.add_child(leave_btn)

func _style_label(lbl: Label, font_size: int = 15) -> void:
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))

func set_phase(phase: String, seconds_left: float, _cycle: int) -> void:
	phase_label.text = phase
	var secs := int(ceil(seconds_left))
	timer_label.text = "%02d:%02d" % [secs / 60, secs % 60]

func set_alive_count(count: int, total: int) -> void:
	alive_label.text = "Vivos: %d/%d" % [count, total]

func set_health(current: float, max_health: float) -> void:
	var ratio: float = 0.0 if max_health <= 0.0 else current / max_health
	health_fill.size.x = 180.0 * clamp(ratio, 0.0, 1.0)

func show_map_event(event_name: String) -> void:
	var labels := {
		"zona_peligrosa": "⚠ Zona peligrosa activada",
		"apagon": "⚠ Apagón en Nova City",
		"suministro": "📦 Suministro disponible",
		"alarma": "🔔 Alarma: posiciones reveladas",
	}
	flash_message(labels.get(event_name, "Evento de mapa"))
	if event_name == "apagon":
		_flash_blackout()

func _flash_blackout() -> void:
	var tw := create_tween()
	tw.tween_property(blackout_overlay, "color:a", 0.6, 0.6)
	tw.tween_interval(2.0)
	tw.tween_property(blackout_overlay, "color:a", 0.0, 1.2)

func show_kill_feed(killer_name: String, victim_name: String, reward_each: float, n_recipients: int) -> void:
	var txt := "%s eliminó a %s" % [killer_name, victim_name]
	if n_recipients > 1:
		txt += " · %.1f BOX c/u (banda de %d)" % [reward_each, n_recipients]
	else:
		txt += " · %.0f BOX" % reward_each
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
