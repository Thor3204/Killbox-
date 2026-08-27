extends Control
class_name InventoryScreen
signal back_pressed
func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var l=Label.new(); l.text="INVENTARIO\n\n👕 ROPA\n🔫 ARMAS\n🎒 EQUIPO\n🧩 OBJETOS\n\nAquí aparecerán tus objetos y equipamiento."; l.position=Vector2(70,70); l.add_theme_font_size_override("font_size",30); add_child(l)
 var b=Button.new(); b.text="← VOLVER"; b.position=Vector2(70,600); b.size=Vector2(190,60); b.pressed.connect(func():back_pressed.emit()); add_child(b)
