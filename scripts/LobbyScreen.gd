extends Control
class_name LobbyScreen

signal play_pressed
signal character_pressed

var box_label: Label
var stars_label: Label
var player_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()

func _style(bg: Color, radius: int = 18, border: Color = Color.TRANSPARENT, width: int = 0) -> StyleBoxFlat:
	var s:=StyleBoxFlat.new(); s.bg_color=bg
	s.corner_radius_top_left=radius; s.corner_radius_top_right=radius; s.corner_radius_bottom_left=radius; s.corner_radius_bottom_right=radius
	s.border_width_left=width; s.border_width_right=width; s.border_width_top=width; s.border_width_bottom=width; s.border_color=border
	s.content_margin_left=20; s.content_margin_right=20; s.content_margin_top=16; s.content_margin_bottom=16
	return s

func _label(t:String,size:int,color:Color=Color.WHITE)->Label:
	var l:=Label.new(); l.text=t; l.add_theme_font_size_override("font_size",size); l.add_theme_color_override("font_color",color); return l

func _build_ui()->void:
	var bg:=KillboxBackdrop.new(); bg.variant=0; add_child(bg)
	var shade:=ColorRect.new(); shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); shade.color=Color(0.0,0.01,0.015,0.30); shade.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(shade)

	# Top game bar.
	var top:=PanelContainer.new(); top.position=Vector2(28,18); top.size=Vector2(1224,68); top.add_theme_stylebox_override("panel",_style(Color(0.012,0.022,0.030,0.94),18,Color(0.18,0.28,0.30,1),1)); add_child(top)
	var hb:=HBoxContainer.new(); hb.add_theme_constant_override("separation",14); top.add_child(hb)
	hb.add_child(_label("KILLBOX",26,Color("#F5F8FA")))
	hb.add_child(_label("NOVA CITY",11,Color("#62E8C5")))
	var grow:=Control.new(); grow.size_flags_horizontal=Control.SIZE_EXPAND_FILL; hb.add_child(grow)
	player_label=_label(Game.player_name.to_upper(),13,Color("#B8C4C9")); hb.add_child(player_label)
	stars_label=_label("⭐ %d" % Game.stars,15,Color("#FFD166")); hb.add_child(stars_label)
	box_label=_label("🪙 %.0f BOX" % Game.box,15,Color("#62E8C5")); hb.add_child(box_label)

	var title:=_label("NOVA CITY",38,Color("#F5F8FA")); title.position=Vector2(44,112); add_child(title)
	var sub:=_label("Elige tu superviviente. Después, entra a la ciudad.",14,Color("#8C999F")); sub.position=Vector2(46,154); add_child(sub)

	# Left hero: uses the unused screen space for the actual character showcase.
	var hero:=PanelContainer.new(); hero.position=Vector2(42,194); hero.size=Vector2(520,455); hero.add_theme_stylebox_override("panel",_style(Color(0.012,0.024,0.032,0.94),26,Color(0.20,0.85,0.70,0.20),1)); add_child(hero)
	var hv:=VBoxContainer.new(); hv.alignment=BoxContainer.ALIGNMENT_CENTER; hv.add_theme_constant_override("separation",6); hero.add_child(hv)
	hv.add_child(_label("TU SUPERVIVIENTE",11,Color("#62E8C5")))
	var d:Dictionary=CharacterData.get_character(Game.selected_character_id)
	var preview:=CharacterPreview.new(); preview.character_id=Game.selected_character_id; preview.custom_minimum_size=Vector2(0,245); hv.add_child(preview)
	var identity:=_label("%s  ·  %s" % [d.get("display_name",""),d.get("role","")],26,Color("#F5F8FA")); identity.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; hv.add_child(identity)
	var ability:=_label("⚡ %s" % d.get("ability_name",""),14,Color("#AAB7BD")); ability.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; hv.add_child(ability)
	var change:=Button.new(); change.text="CAMBIAR PERSONAJE  ·  200 BOX"; change.custom_minimum_size=Vector2(0,50); change.add_theme_font_size_override("font_size",13); change.add_theme_stylebox_override("normal",_style(Color(0.04,0.065,0.075,1),12,Color(0.17,0.25,0.28,1),1)); change.pressed.connect(func():character_pressed.emit()); hv.add_child(change)

	# Right side: event + wallet + how it works, no dead space.
	var right:=VBoxContainer.new(); right.position=Vector2(594,194); right.size=Vector2(658,455); right.add_theme_constant_override("separation",12); add_child(right)
	var event:=PanelContainer.new(); event.custom_minimum_size=Vector2(0,250); event.add_theme_stylebox_override("panel",_style(Color(0.012,0.024,0.032,0.96),26,Color(0.20,0.85,0.70,0.20),1)); right.add_child(event)
	var ev:=VBoxContainer.new(); ev.add_theme_constant_override("separation",9); event.add_child(ev)
	ev.add_child(_label("PRÓXIMO EVENTO",11,Color("#62E8C5")))
	ev.add_child(_label("⚔  NIGHT CITY",30,Color("#F5F8FA")))
	ev.add_child(_label("Una ciudad en ruinas. Alianzas que pueden romperse.\nSolo el último superviviente reclama la victoria.",14,Color("#A9B5BA")))
	ev.add_child(_label("🕘 22:00     👥 HASTA 100     ⏱ CICLOS 30s",14,Color("#D6DFE1")))
	var play:=Button.new(); play.text="JUGAR AHORA   →"; play.custom_minimum_size=Vector2(0,68); play.add_theme_font_size_override("font_size",20); play.add_theme_color_override("font_color",Color("#06100D")); play.add_theme_stylebox_override("normal",_style(Color("#62E8C5"),15)); play.add_theme_stylebox_override("hover",_style(Color("#86F3D5"),15)); play.pressed.connect(func():play_pressed.emit()); ev.add_child(play)

	var info:=HBoxContainer.new(); info.custom_minimum_size=Vector2(0,190); info.add_theme_constant_override("separation",12); right.add_child(info)
	var wallet:=PanelContainer.new(); wallet.size_flags_horizontal=Control.SIZE_EXPAND_FILL; wallet.add_theme_stylebox_override("panel",_style(Color(0.012,0.024,0.032,0.96),20,Color(0.12,0.20,0.22,1),1)); info.add_child(wallet)
	var wv:=VBoxContainer.new(); wv.add_theme_constant_override("separation",7); wallet.add_child(wv)
	wv.add_child(_label("BILLETERA",11,Color("#62E8C5")))
	wv.add_child(_label("🪙 %.0f BOX" % Game.box,29,Color("#F5F8FA")))
	wv.add_child(_label("Saldo ficticio de prueba",12,Color("#77858C")))
	wv.add_child(_label("Entrada de prueba: 100 BOX\nKill: 90 BOX",13,Color("#A9B5BA")))

	var profile:=PanelContainer.new(); profile.size_flags_horizontal=Control.SIZE_EXPAND_FILL; profile.add_theme_stylebox_override("panel",_style(Color(0.012,0.024,0.032,0.96),20,Color(0.12,0.20,0.22,1),1)); info.add_child(profile)
	var pv:=VBoxContainer.new(); pv.add_theme_constant_override("separation",7); profile.add_child(pv)
	pv.add_child(_label("TU PROGRESO",11,Color("#62E8C5")))
	pv.add_child(_label("⭐ %d VICTORIAS" % Game.stars,25,Color("#FFD166")))
	pv.add_child(_label("💀 0 eliminaciones\n🤝 0 alianzas en esta partida",13,Color("#A9B5BA")))
	pv.add_child(_label("Las estrellas son prestigio, no moneda.",11,Color("#77858C")))

	var footer:=_label("KILLBOX  •  SUPERVIVENCIA / ALIANZAS / TRAICIÓN",11,Color("#5B686E")); footer.position=Vector2(44,674); add_child(footer)
