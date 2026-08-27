extends Control
class_name BattleHUD
signal attack_pressed
signal ability_pressed
signal quit_pressed
func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var l=Label.new(); l.text="NOVA CITY  •  CAZA\n❤️ 100   👥 25   ⏱ 30"; l.position=Vector2(30,25); l.add_theme_font_size_override("font_size",24); add_child(l)
 var a=Button.new(); a.text="⚔ ATACAR"; a.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); a.position=Vector2(-190,-150); a.size=Vector2(150,110); a.add_theme_font_size_override("font_size",20); a.pressed.connect(func():attack_pressed.emit()); add_child(a)
 var h=Button.new(); h.text="⚡ HABILIDAD"; h.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); h.position=Vector2(-360,-95); h.size=Vector2(150,75); h.pressed.connect(func():ability_pressed.emit()); add_child(h)
 var q=Button.new(); q.text="SALIR"; q.position=Vector2(25,-70); q.set_anchors_preset(Control.PRESET_BOTTOM_LEFT); q.size=Vector2(120,50); q.pressed.connect(func():quit_pressed.emit()); add_child(q)
