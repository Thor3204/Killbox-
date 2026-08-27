extends Control
class_name HubScreen
signal play_pressed
signal character_pressed
signal settings_pressed
signal inventory_pressed
signal shop_pressed
func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var bg=ColorRect.new(); bg.color=Color("#071017"); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
 var title=Label.new(); title.text="KILLBOX"; title.position=Vector2(55,35); title.add_theme_font_size_override("font_size",38); add_child(title)
 var stats=Label.new(); stats.text="⭐ %d     🪙 %.0f BOX     %s"%[Game.stars,Game.box,Game.player_name.to_upper()]; stats.position=Vector2(55,85); stats.add_theme_font_size_override("font_size",20); add_child(stats)
 var hero=Label.new(); hero.text="NOVA CITY\n\n%s\n%s\n\nENTRA. ALÍATE. SOBREVIVE."%[Game.selected_character_id.to_upper(),"SUPERVIVIENTE"]; hero.position=Vector2(55,175); hero.add_theme_font_size_override("font_size",34); add_child(hero)
 var event=Label.new(); event.text="⚔ NIGHT CITY\n22:00  •  HASTA 100 JUGADORES\nCICLOS DE 30 SEGUNDOS"; event.position=Vector2(560,180); event.add_theme_font_size_override("font_size",26); add_child(event)
 var play=Button.new(); play.text="JUGAR AHORA"; play.position=Vector2(560,320); play.size=Vector2(430,90); play.add_theme_font_size_override("font_size",26); play.pressed.connect(func():play_pressed.emit()); add_child(play)
 var c=Button.new(); c.text="🎭 PERSONAJE"; c.position=Vector2(55,560); c.size=Vector2(190,65); c.pressed.connect(func():character_pressed.emit()); add_child(c)
 var inv=Button.new(); inv.text="🎒 INVENTARIO"; inv.position=Vector2(260,560); inv.size=Vector2(190,65); inv.pressed.connect(func():inventory_pressed.emit()); add_child(inv)
 var shop=Button.new(); shop.text="🛒 TIENDA"; shop.position=Vector2(465,560); shop.size=Vector2(190,65); shop.pressed.connect(func():shop_pressed.emit()); add_child(shop)
 var set=Button.new(); set.text="⚙ AJUSTES"; set.position=Vector2(670,560); set.size=Vector2(190,65); set.pressed.connect(func():settings_pressed.emit()); add_child(set)
