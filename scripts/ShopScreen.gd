extends Control
class_name ShopScreen
signal back_pressed
func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var l=Label.new(); l.text="TIENDA\n\n🔫 EQUIPO TÁCTICO     200 BOX\n🛡️ PROTECCIÓN          300 BOX\n⚡ MEJORA DE HABILIDAD  400 BOX\n👕 ROPA                 150 BOX\n\nLa estrategia importa más que la fuerza."; l.position=Vector2(70,70); l.add_theme_font_size_override("font_size",27); add_child(l)
 var b=Button.new(); b.text="← VOLVER"; b.position=Vector2(70,600); b.size=Vector2(190,60); b.pressed.connect(func():back_pressed.emit()); add_child(b)
