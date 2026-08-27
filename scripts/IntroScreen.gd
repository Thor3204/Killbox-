extends Control
class_name IntroScreen

signal finished

var _done := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	await get_tree().create_timer(2.8).timeout
	_finish()

func _label(text: String, size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _build() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://art/killbox_intro.svg")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.01, 0.015, 0.18)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var title := _label("KILLBOX", 76, Color("#F4F7F6"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(-350, 210)
	title.size = Vector2(700, 90)
	title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 4)
	add_child(title)

	var sub := _label("NOVA CITY", 17, Color("#63E6C4"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	sub.position = Vector2(-250, 305)
	sub.size = Vector2(500, 40)
	add_child(sub)

	var line := ColorRect.new()
	line.color = Color("#63E6C4")
	line.set_anchors_preset(Control.PRESET_CENTER_TOP)
	line.position = Vector2(-90, 350)
	line.size = Vector2(180, 2)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)

	var tagline := _label("ENTRA. ALÍATE. SOBREVIVE.", 14, Color("#D2D9DA"))
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.set_anchors_preset(Control.PRESET_CENTER_TOP)
	tagline.position = Vector2(-300, 380)
	tagline.size = Vector2(600, 35)
	add_child(tagline)

	var hint := _label("TOCA PARA CONTINUAR", 12, Color("#89979B"))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint.position = Vector2(-180, -70)
	hint.size = Vector2(360, 30)
	add_child(hint)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_finish()
	elif event is InputEventMouseButton and event.pressed:
		_finish()

func _finish() -> void:
	if _done: return
	_done = true
	finished.emit()
