extends Control
class_name LobbyScreen

signal play_pressed
signal character_pressed

var box_label: Label
var stars_label: Label
var player_label: Label
var event_status: Label
var preview: CharacterPreview

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	RemoteConfig.config_updated.connect(_refresh_event)
	_refresh_event()

func _style(bg: Color, radius: int = 16, border: Color = Color.TRANSPARENT, width: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new(); s.bg_color=bg
	s.corner_radius_top_left=radius; s.corner_radius_top_right=radius; s.corner_radius_bottom_left=radius; s.corner_radius_bottom_right=radius
	s.border_width_left=width; s.border_width_right=width; s.border_width_top=width; s.border_width_bottom=width; s.border_color=border
	s.content_margin_left=18; s.content_margin_right=18; s.content_margin_top=14; s.content_margin_bottom=14
	return s

func _label(t:String, size:int, color:Color=Color.WHITE)->Label:
	var l:=Label.new(); l.text=t; l.add_theme_font_size_override("font_size",size); l.add_theme_color_override("font_color",color); return l

func _build_ui() -> void:
	var bg:=KillboxBackdrop.new(); bg.variant=0; add_child(bg)
	var shade:=ColorRect.new(); shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); shade.color=Color(0.01,0.02,0.03,0.22); shade.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(shade)

	# Top bar: identity + fictional local wallet.
	var top:=PanelContainer.new(); top.position=Vector2(30,20); top.size=Vector2(1220,70); top.add_theme_stylebox_override("panel",_style(Color(0.02,0.035,0.045,0.92),18,Color(0.18,0.26,0.29,1),1)); add_child(top)
	var topbox:=HBoxContainer.new(); topbox.add_theme_constant_override("separation",12); top.add_child(topbox)
	var logo:=_label("KILLBOX",27,Color("#F5F8FA")); topbox.add_child(logo)
	topbox.add_child(_label("  NOVA CITY",12,Color("#62E8C5")))
	var sp:=Control.new(); sp.size_flags_horizontal=Control.SIZE_EXPAND_FILL; topbox.add_child(sp)
	player_label=_label(Game.player_name.to_upper(),14,Color("#B8C4C9")); topbox.add_child(player_label)
	stars_label=_label("⭐ %d" % Game.stars,16,Color("#FFD166")); topbox.add_child(stars_label)
	box_label=_label("🪙 %.0f BOX" % Game.box,16,Color("#62E8C5")); topbox.add_child(box_label)

	var welcome:=_label("BIENVENIDO A NOVA CITY",31,Color("#F5F8FA")); welcome.position=Vector2(48,116); add_child(welcome)
	var sub:=_label("Tu próxima partida empieza aquí.",14,Color("#7F8C93")); sub.position=Vector2(50,156); add_child(sub)

	# Character showcase.
	var hero:=PanelContainer.new(); hero.position=Vector2(42,200); hero.size=Vector2(470,365); hero.add_theme_stylebox_override("panel",_style(Color(0.025,0.04,0.052,0.96),24,Color(0.2,0.85,0.7,0.18),1)); add_child(hero)
	var hb:=VBoxContainer.new(); hb.add_theme_constant_override("separation",7); hero.add_child(hb)
	var d:Dictionary=CharacterData.get_character(Game.selected_character_id)
	hb.add_child(_label("TU SUPERVIVIENTE",11,Color("#62E8C5")))
	preview=CharacterPreview.new(); preview.character_id=Game.selected_character_id; preview.custom_minimum_size=Vector2(0,145); hb.add_child(preview)
	hb.add_child(_label(d.get("display_name","").to_upper()+"  ·  "+d.get("role",""),24,Color("#F5F8FA")))
	hb.add_child(_label(d.get("ability_name","")+"  —  "+_ability_short(Game.selected_character_id),13,Color("#AEBBC0")))
	var cb:=Button.new(); cb.text="👤  PERSONAJE Y HABILIDADES"; cb.custom_minimum_size=Vector2(0,52); cb.add_theme_font_size_override("font_size",14); cb.add_theme_stylebox_override("normal",_style(Color(0.06,0.09,0.10,1),12,Color(0.22,0.30,0.33,1),1)); cb.pressed.connect(func():character_pressed.emit()); hb.add_child(cb)

	# Main event card.
	var event:=PanelContainer.new(); event.position=Vector2(545,200); event.size=Vector2(695,365); event.add_theme_stylebox_override("panel",_style(Color(0.025,0.04,0.052,0.97),24,Color(0.2,0.85,0.7,0.18),1)); add_child(event)
	var eb:=VBoxContainer.new(); eb.add_theme_constant_override("separation",10); event.add_child(eb)
	eb.add_child(_label("PRÓXIMO EVENTO",11,Color("#62E8C5")))
	eb.add_child(_label("⚔  NIGHT CITY",31,Color("#F5F8FA")))
	eb.add_child(_label("La ciudad está cerrada. Solo un superviviente podrá reclamar la victoria.",14,Color("#AAB7BD")))
	var info:=_label("🕘 22:00   ·   👥 HASTA 100   ·   ⏱ CICLOS DE 30s",14,Color("#D4DDE0")); eb.add_child(info)
	var divider:=HSeparator.new(); eb.add_child(divider)
	event_status=_label("EVENTO DE PRUEBA · SIN CONEXIÓN",12,Color("#6F7C83")); eb.add_child(event_status)
	var rule:=_label("🏴 Alianzas  ·  🔪 Traición  ·  🏆 Último superviviente",14,Color("#89969D")); eb.add_child(rule)
	var play:=Button.new(); play.text="JUGAR AHORA  →"; play.custom_minimum_size=Vector2(0,70); play.add_theme_font_size_override("font_size",21); play.add_theme_color_override("font_color",Color("#06100D")); play.add_theme_stylebox_override("normal",_style(Color("#62E8C5"),15)); play.add_theme_stylebox_override("hover",_style(Color("#86F3D5"),15)); play.pressed.connect(func():play_pressed.emit()); eb.add_child(play)

	# Bottom navigation.
	var nav:=HBoxContainer.new(); nav.position=Vector2(42,602); nav.size=Vector2(1198,62); nav.add_theme_constant_override("separation",10); add_child(nav)
	for item in ["🏆  RANKING","🎒  INVENTARIO","👤  PERFIL","⚙  AJUSTES"]:
		var b:=Button.new(); b.text=item; b.custom_minimum_size=Vector2(190,54); b.add_theme_font_size_override("font_size",13); b.add_theme_stylebox_override("normal",_style(Color(0.03,0.045,0.055,0.88),12,Color(0.14,0.20,0.23,1),1)); nav.add_child(b)
	var note:=_label("BOX y estrellas son datos ficticios locales durante el desarrollo.",11,Color("#59666D")); note.position=Vector2(42,674); add_child(note)

func _ability_short(cid:String)->String:
	match cid:
		"rex": return "barricada temporal"
		"luna": return "rastrea jugadores cercanos"
		"max": return "coloca una trampa"
		"maya": return "recupera vida"
		"kai": return "acelera durante unos segundos"
	return "habilidad especial"

func _refresh_event() -> void:
	if event_status == null: return
	if RemoteConfig.update_available:
		event_status.text="NUEVA CONFIGURACIÓN DISPONIBLE"
		event_status.add_theme_color_override("font_color",Color("#FFD166"))
	else:
		event_status.text="EVENTO DE PRUEBA · CONFIGURACIÓN LOCAL"
