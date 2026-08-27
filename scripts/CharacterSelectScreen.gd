extends Control
class_name CharacterSelectScreen

signal continue_pressed
signal back_pressed

var selected_id: String = "rex"
var name_label: Label
var role_label: Label
var story_label: Label
var stats_label: Label
var portrait: Control
var details_panel: PanelContainer
var ability_overlay: PanelContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selected_id = Game.selected_character_id
	_build_ui()
	_refresh()

func _style(bg: Color, radius: int = 16, border: Color = Color.TRANSPARENT, width: int = 0) -> StyleBoxFlat:
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
	s.content_margin_left = 22
	s.content_margin_right = 22
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
	bg.variant = 1
	add_child(bg)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.015,0.025,0.035,0.30)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var header := HBoxContainer.new()
	header.position = Vector2(36,24)
	header.size = Vector2(1208,58)
	add_child(header)
	var back := Button.new()
	back.text = "‹  ATRÁS"
	back.custom_minimum_size = Vector2(110,48)
	back.add_theme_font_size_override("font_size",14)
	back.add_theme_stylebox_override("normal",_style(Color(0.04,0.06,0.075,0.9),12,Color(0.18,0.25,0.28,1),1))
	back.pressed.connect(func(): back_pressed.emit())
	header.add_child(back)
	var spacer := Control.new(); spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL; header.add_child(spacer)
	var step := _label("02  /  03   •   SUPERVIVIENTE",13,Color("#62E8C5")); header.add_child(step)

	var title := _label("ELIGE A TU SUPERVIVIENTE",34,Color("#F5F8FA"))
	title.position = Vector2(42,102); add_child(title)
	var subtitle := _label("Conoce su historia y sus habilidades antes de entrar a la ciudad.",15,Color("#8D9AA1"))
	subtitle.position = Vector2(44,145); add_child(subtitle)

	var roster := HBoxContainer.new()
	roster.position = Vector2(42,205); roster.size = Vector2(690,390)
	roster.add_theme_constant_override("separation",12); add_child(roster)
	for cid in CharacterData.get_roster_ids():
		var d: Dictionary = CharacterData.get_character(cid)
		var card := Button.new()
		card.text = "\n%s\n%s\n\n%s" % [d.get("display_name",cid),d.get("role",""),d.get("ability_name","")]
		card.custom_minimum_size = Vector2(128,270)
		card.add_theme_font_size_override("font_size",15)
		card.add_theme_color_override("font_color",Color("#EAF1F2"))
		card.add_theme_stylebox_override("normal",_style(Color(0.035,0.05,0.065,0.94),18,Color(0.14,0.20,0.23,1),1))
		card.add_theme_stylebox_override("hover",_style(Color(0.06,0.085,0.095,0.98),18,Color("#62E8C5"),2))
		card.pressed.connect(_select.bind(cid))
		roster.add_child(card)

	details_panel = PanelContainer.new()
	details_panel.position = Vector2(765,180); details_panel.size = Vector2(455,475)
	details_panel.add_theme_stylebox_override("panel",_style(Color(0.025,0.04,0.052,0.97),24,Color(0.2,0.85,0.7,0.22),1))
	add_child(details_panel)
	var box := VBoxContainer.new(); box.add_theme_constant_override("separation",9); details_panel.add_child(box)
	name_label = _label("",34,Color("#F5F8FA")); box.add_child(name_label)
	role_label = _label("",14,Color("#62E8C5")); box.add_child(role_label)
	portrait = CharacterPreview.new(); portrait.custom_minimum_size = Vector2(0,145); box.add_child(portrait)
	story_label = _label("",14,Color("#B5C0C5")); story_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; story_label.custom_minimum_size=Vector2(0,82); box.add_child(story_label)
	stats_label = _label("",13,Color("#87959C")); stats_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; box.add_child(stats_label)
	var buttons := HBoxContainer.new(); buttons.add_theme_constant_override("separation",10); box.add_child(buttons)
	var abilities := Button.new(); abilities.text="⚡  VER HABILIDADES"; abilities.custom_minimum_size=Vector2(205,54); abilities.add_theme_font_size_override("font_size",14); abilities.add_theme_stylebox_override("normal",_style(Color(0.06,0.09,0.10,1),12,Color(0.22,0.30,0.33,1),1)); abilities.pressed.connect(_show_abilities); buttons.add_child(abilities)
	var choose := Button.new(); choose.text="ELEGIR  →"; choose.custom_minimum_size=Vector2(190,54); choose.add_theme_font_size_override("font_size",15); choose.add_theme_color_override("font_color",Color("#06100D")); choose.add_theme_stylebox_override("normal",_style(Color("#62E8C5"),12)); choose.pressed.connect(_continue); buttons.add_child(choose)

func _select(cid: String) -> void:
	selected_id = cid
	_refresh()

func _refresh() -> void:
	var d: Dictionary = CharacterData.get_character(selected_id)
	name_label.text = d.get("display_name","")
	role_label.text = "%s   •   HABILIDAD: %s" % [d.get("role",""),d.get("ability_name","")]
	story_label.text = _story(selected_id)
	stats_label.text = "❤️ Vida: %d    ⚡ Cooldown: %.0fs    🏃 Velocidad: %d\n⚔️ Daño: %d" % [int(d.get("max_health",100)),float(d.get("ability_cooldown",12)),int(d.get("move_speed",160)),int(d.get("attack_damage",16))]
	if portrait:
		portrait.character_id = selected_id
		portrait.queue_redraw()

func _story(cid: String) -> String:
	match cid:
		"rex": return "Rex conoce cada taller y callejón de Nova City. Cuando la ciudad cayó, convirtió su oficio en una ventaja: prepara el terreno y siempre guarda una salida."
		"luna": return "Luna fue detective antes del caos. Observa detalles que otros pasan por alto y convierte las huellas de sus rivales en información."
		"max": return "Max trabajaba con explosivos de demolición. En Nova City aprendió que una buena trampa vale más que una persecución interminable."
		"maya": return "Maya atendió a los últimos supervivientes de la ciudad. No dejó de luchar: sabe cuándo resistir y cuándo recuperar fuerzas."
		"kai": return "Kai era mensajero y conocía la ciudad mejor que nadie. Su ventaja es simple: cuando necesita escapar, nadie corre como él."
	return "Un superviviente de Nova City."

func _show_abilities() -> void:
	if ability_overlay: ability_overlay.queue_free()
	ability_overlay = PanelContainer.new(); ability_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); ability_overlay.mouse_filter=Control.MOUSE_FILTER_STOP; add_child(ability_overlay)
	var outer := CenterContainer.new(); ability_overlay.add_child(outer)
	var panel := PanelContainer.new(); panel.custom_minimum_size=Vector2(620,470); panel.add_theme_stylebox_override("panel",_style(Color(0.02,0.035,0.045,0.99),24,Color("#62E8C5"),1)); outer.add_child(panel)
	var box:=VBoxContainer.new(); box.add_theme_constant_override("separation",12); panel.add_child(box)
	var d:Dictionary=CharacterData.get_character(selected_id)
	box.add_child(_label("⚡ HABILIDADES  •  %s" % d.get("display_name",""),27,Color("#F5F8FA")))
	box.add_child(_label("%s\n%s" % [d.get("ability_name",""),_ability_description(selected_id)],16,Color("#B9C5CA")))
	box.add_child(_label("ATAQUE BÁSICO\nAtaque corto de acción rápida. Todos los personajes pueden eliminar a otros.\n\nPASIVA\nLa profesión modifica tu estilo de juego; no te impide combatir.\n\nCONSEJO\nUsa tu habilidad durante la fase de CAZA y aprende a combinarla con tu alianza.",14,Color("#8E9BA2")))
	var close:=Button.new(); close.text="ENTENDIDO"; close.custom_minimum_size=Vector2(0,52); close.add_theme_stylebox_override("normal",_style(Color("#62E8C5"),12)); close.add_theme_color_override("font_color",Color("#06100D")); close.pressed.connect(func(): ability_overlay.queue_free()); box.add_child(close)

func _ability_description(cid:String)->String:
	match cid:
		"rex": return "Levanta una barricada temporal para bloquear una ruta, escapar o preparar una emboscada."
		"luna": return "Revela temporalmente las señales de jugadores cercanos, ayudándote a seguir su rastro."
		"max": return "Coloca una trampa que daña al primer rival que la active."
		"maya": return "Recupera una cantidad de vida y vuelve a la acción."
		"kai": return "Aumenta drásticamente su velocidad durante unos segundos."
	return "Habilidad especial."

func _continue() -> void:
	Game.select_character(selected_id)
	continue_pressed.emit()
