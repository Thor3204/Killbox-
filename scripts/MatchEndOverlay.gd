extends Control
class_name MatchEndOverlay
## Overlay de fin de partida (docs/UI-UX.md).

signal continue_pressed

func setup(summary: Dictionary) -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.82)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-160, -140)
	box.add_theme_constant_override("separation", 10)
	add_child(box)

	var title := Label.new()
	title.text = "VICTORIA" if summary.get("winner_is_local", false) else "FIN DE LA PARTIDA"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.85, 0.15, 0.15))
	box.add_child(title)

	var winner := Label.new()
	winner.text = "Ganador: %s" % summary.get("winner_name", "?")
	box.add_child(winner)

	var kills := Label.new()
	kills.text = "Tus kills: %d" % summary.get("local_kills", 0)
	box.add_child(kills)

	var earned := Label.new()
	earned.text = "BOX ganado: %.1f" % summary.get("local_box_earned", 0.0)
	box.add_child(earned)

	var stars := Label.new()
	stars.text = "⭐ obtenidas: %d" % summary.get("local_stars_earned", 0)
	box.add_child(stars)

	var survived := Label.new()
	survived.text = "Sobreviviste %ds" % int(summary.get("survival_seconds", 0))
	box.add_child(survived)

	var cont_btn := Button.new()
	cont_btn.text = "CONTINUAR"
	cont_btn.custom_minimum_size = Vector2(200, 50)
	cont_btn.pressed.connect(func(): continue_pressed.emit())
	box.add_child(cont_btn)
