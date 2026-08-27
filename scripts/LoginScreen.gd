extends Control
class_name LoginScreen
## V1 offline (docs/UI-UX.md): sin backend de cuentas todavía. Guarda el
## nombre localmente. Cuando exista backend real (ej. Supabase Auth como en
## los otros proyectos de Atlas X Sync) esta pantalla se conecta acá.

signal logged_in

var name_edit: LineEdit

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color8(10, 10, 12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.position = Vector2(-160, -110)
	center.add_theme_constant_override("separation", 14)
	add_child(center)

	var title := Label.new()
	title.text = "KILLBOX"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.85, 0.15, 0.15))
	center.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Entra. Alíate. Sobrevive."
	subtitle.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	center.add_child(subtitle)

	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Nombre de superviviente"
	name_edit.custom_minimum_size = Vector2(280, 40)
	name_edit.text = Game.player_name
	center.add_child(name_edit)

	var enter_btn := Button.new()
	enter_btn.text = "ENTRAR"
	enter_btn.custom_minimum_size = Vector2(280, 46)
	enter_btn.pressed.connect(_on_enter)
	center.add_child(enter_btn)

	var note := Label.new()
	note.text = "V1 offline contra bots · sin cuentas reales todavía"
	note.add_theme_font_size_override("font_size", 11)
	note.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
	center.add_child(note)

func _on_enter() -> void:
	Game.set_player_name(name_edit.text)
	logged_in.emit()
