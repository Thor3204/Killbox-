extends Control
class_name CharacterSelectScreen

signal continue_pressed

var initial_setup := false
var selected_id: String = "rex"
var name_label: Label
var role_label: Label
var story_label: Label
var stats_label: Label
var portrait: CharacterPreview
var status_label: Label
var ability_overlay: PanelContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selected_id = Game.selected_character_id
	_build_ui()
	_refresh()

func _style(bg: Color, radius: int = 16, border: Color = Color.TRANSPARENT, width: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = radius; s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius; s.corner_radius_bottom_right = radius
	s.border_width_left = width; s.border_width_right = width; s.border_width_top = width; s.border_width_bottom = width
	s.border_color = border
	s.content_margin_left = 22; s.content_margin_right = 22; s.content_margin_top = 18; s.content_margin_bottom = 18
	return s

func _label(text: String, size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new(); l.text = text; l.add_theme_font_size_override("font_size", size); l.add_theme_color_override("font_color", color); return l

func _build_ui() -> void:
	var bg := KillboxBackdrop.new(); bg.variant = 1; add_child(bg)
	var shade := ColorRect.new(); shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); shade.color = Color(0.005,0.012,0.018,0.25); shade.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(shade)

	var header := HBoxContainer.new(); header.position = Vector2(38,24); header.size = Vector2(1204,58); add_child(header)
	var brand := _label("KILLBOX",24,Color("#F5F8FA")); header.add_child(brand)
	var sub := _label("  /  NOVA CITY",12,Color("#62E8C5")); header.add_child(sub)
	var spacer := Control.new(); spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL; header.add_child(spacer)
	var step_text := "CREACIÓN DEL SUPERVIVIENTE" if initial_setup else "CAMBIAR PERSONAJE"
	header.add_child(_label(step_text,13,Color("#91A0A6")))

	var title := _label("ELIGE A TU SUPERVIVIENTE",34,Color("#F5F8FA")); title.position = Vector2(42,102); add_child(title)
	var subtitle_text := "Esta elección define tu estilo de juego." if initial_setup else "Cambiar de personaje cuesta 200 BOX. Tu alias no cambia."
	var subtitle := _label(subtitle_text,15,Color("#8D9AA1")); subtitle.position = Vector2(44,145); add_child(subtitle)

	# Compact roster rail with portrait + role.
	var roster_panel := PanelContainer.new(); roster_panel.position=Vector2(40,190); roster_panel.size=Vector2(530,470); roster_panel.add_theme_stylebox_override("panel",_style(Color(0.018,0.032,0.042,0.96),24,Color(0.12,0.22,0.25,1),1)); add_child(roster_panel)
	var roster := VBoxContainer.new(); roster.add_theme_constant_override("separation",8); roster_panel.add_child(roster)
	roster.add_child(_label("ROSTER  •  5 SUPERVIVIENTES",11,Color("#62E8C5")))
	for cid in CharacterData.get_roster_ids():
		var d:Dictionary=CharacterData.get_character(cid)
		var row:=Button.new(); row.text="  %s    %s\n  %s" % [d.get("display_name",cid),d.get("role",""),d.get("ability_name","")]; row.alignment=HORIZONTAL_ALIGNMENT_LEFT; row.custom_minimum_size=Vector2(0,72); row.add_theme_font_size_override("font_size",15); row.add_theme_color_override("font_color",Color("#EAF1F2")); row.add_theme_stylebox_override("normal",_style(Color(0.035,0.052,0.064,0.8),14,Color(0.11,0.17,0.19,1),1)); row.add_theme_stylebox_override("hover",_style(Color(0.055,0.085,0.09,0.98),14,Color("#62E8C5"),2)); row.pressed.connect(_select.bind(cid)); roster.add_child(row)

	var detail:=PanelContainer.new(); detail.position=Vector2(600,190); detail.size=Vector2(640,470); detail.add_theme_stylebox_override("panel",_style(Color(0.018,0.032,0.042,0.98),24,Color(0.20,0.85,0.70,0.22),1)); add_child(detail)
	var db:=VBoxContainer.new(); db.add_theme_constant_override("separation",8); detail.add_child(db)
	var top:=HBoxContainer.new(); db.add_child(top)
	var identity:=VBoxContainer.new(); identity.size_flags_horizontal=Control.SIZE_EXPAND_FILL; top.add_child(identity)
	name_label=_label("",34,Color("#F5F8FA")); identity.add_child(name_label)
	role_label=_label("",14,Color("#62E8C5")); identity.add_child(role_label)
	portrait=CharacterPreview.new(); portrait.custom_minimum_size=Vector2(180,150); top.add_child(portrait)
	story_label=_label("",14,Color("#B5C0C5")); story_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; story_label.custom_minimum_size=Vector2(0,86); db.add_child(story_label)
	stats_label=_label("",13,Color("#A2B0B5")); db.add_child(stats_label)
	var divider:=HSeparator.new(); db.add_child(divider)
	var buttons:=HBoxContainer.new(); buttons.add_theme_constant_override("separation",10); db.add_child(buttons)
	var abilities:=Button.new(); abilities.text="⚡  VER TODAS LAS HABILIDADES"; abilities.custom_minimum_size=Vector2(310,56); abilities.add_theme_font_size_override("font_size",14); abilities.add_theme_stylebox_override("normal",_style(Color(0.055,0.085,0.095,1),13,Color(0.22,0.30,0.33,1),1)); abilities.pressed.connect(_show_abilities); buttons.add_child(abilities)
	var choose:=Button.new(); choose.text="CONFIRMAR  →"; choose.custom_minimum_size=Vector2(270,56); choose.add_theme_font_size_override("font_size",15); choose.add_theme_color_override("font_color",Color("#06100D")); choose.add_theme_stylebox_override("normal",_style(Color("#62E8C5"),13)); choose.pressed.connect(_continue); buttons.add_child(choose)
	status_label=_label("",12,Color("#69777E")); status_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; db.add_child(status_label)

func _select(cid:String)->void:
	selected_id=cid; _refresh()

func _refresh()->void:
	var d:Dictionary=CharacterData.get_character(selected_id)
	name_label.text=d.get("display_name","")
	role_label.text="%s   •   %s" % [d.get("role",""),d.get("ability_name","")]
	story_label.text=_story(selected_id)
	stats_label.text="❤️ %d VIDA     ⚔️ %d DAÑO     🏃 %d VELOCIDAD     ⏱ %.0fs COOLDOWN" % [int(d.get("max_health",100)),int(d.get("attack_damage",16)),int(d.get("move_speed",160)),float(d.get("ability_cooldown",12))]
	portrait.character_id=selected_id; portrait.queue_redraw()
	status_label.text="Tu alias: %s" % Game.player_name if not initial_setup else "Después de confirmar entrarás directamente al lobby."

func _story(cid:String)->String:
	match cid:
		"rex": return "Rex conoce cada taller y callejón de Nova City. Convierte el entorno en una ventaja y siempre prepara una salida."
		"luna": return "Luna fue detective antes del caos. Observa patrones, sigue rastros y convierte la información en una ventaja."
		"max": return "Max trabajaba en demolición. Para él, una buena trampa puede cambiar una persecución completa."
		"maya": return "Maya atendió a los últimos supervivientes. Sabe cuándo pelear y cuándo recuperar fuerzas."
		"kai": return "Kai era mensajero. Conoce las rutas de Nova City y nadie escapa de una mala situación como él."
	return "Un superviviente de Nova City."

func _show_abilities()->void:
	if ability_overlay: ability_overlay.queue_free()
	ability_overlay=PanelContainer.new(); ability_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); ability_overlay.mouse_filter=Control.MOUSE_FILTER_STOP; add_child(ability_overlay)
	var dim:=ColorRect.new(); dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); dim.color=Color(0,0,0,0.72); dim.mouse_filter=Control.MOUSE_FILTER_IGNORE; ability_overlay.add_child(dim)
	var center:=CenterContainer.new(); center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); ability_overlay.add_child(center)
	var panel:=PanelContainer.new(); panel.custom_minimum_size=Vector2(700,500); panel.add_theme_stylebox_override("panel",_style(Color(0.018,0.030,0.039,1),26,Color("#62E8C5"),1)); center.add_child(panel)
	var box:=VBoxContainer.new(); box.add_theme_constant_override("separation",12); panel.add_child(box)
	var d:Dictionary=CharacterData.get_character(selected_id)
	box.add_child(_label("%s  •  %s" % [d.get("display_name",""),d.get("role","")],28,Color("#F5F8FA")))
	box.add_child(_label("HABILIDADES",12,Color("#62E8C5")))
	box.add_child(_label(_ability_description(selected_id),16,Color("#C1CCCF")))
	box.add_child(_label("⚔️ ATAQUE BÁSICO\nTodos los personajes pueden atacar y eliminar. La profesión no limita el combate.\n\n🎯 ESTILO\nCada personaje cambia tu forma de moverte, atacar y sobrevivir.\n\n⏱ COOLDOWN\nLa habilidad especial vuelve a estar disponible después del tiempo indicado.",14,Color("#8D9BA1")))
	var close:=Button.new(); close.text="VOLVER AL PERSONAJE"; close.custom_minimum_size=Vector2(0,54); close.add_theme_stylebox_override("normal",_style(Color("#62E8C5"),13)); close.add_theme_color_override("font_color",Color("#06100D")); close.pressed.connect(func():ability_overlay.queue_free()); box.add_child(close)

func _ability_description(cid:String)->String:
	match cid:
		"rex": return "🧱 BARRICADA — Coloca una barricada temporal que bloquea una ruta. Úsala para escapar o preparar una emboscada."
		"luna": return "👁 RASTRO — Detecta señales recientes de jugadores cercanos durante unos segundos."
		"max": return "💣 TRAMPA — Coloca una trampa oculta que daña al primer rival que la active."
		"maya": return "❤️ RECUPERACIÓN — Recupera parte de tu vida y vuelve al combate."
		"kai": return "⚡ TURBO — Aumenta mucho tu velocidad durante unos segundos para perseguir o escapar."
	return "Habilidad especial."

func _continue()->void:
	if initial_setup:
		Game.complete_profile(selected_id)
		continue_pressed.emit()
		return
	if selected_id == Game.selected_character_id:
		continue_pressed.emit(); return
	if Game.select_character(selected_id):
		continue_pressed.emit()
	else:
		status_label.text="Necesitas 200 BOX para cambiar de personaje. Saldo actual: %.0f BOX." % Game.box
		status_label.add_theme_color_override("font_color",Color("#FF9B85"))
