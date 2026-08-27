extends Control
class_name IntroScreen
signal finished
var done=false
func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); queue_redraw(); await get_tree().create_timer(3.0).timeout; finish()
func _draw():
 draw_rect(Rect2(Vector2.ZERO,size),Color("#050A10"))
 for i in range(12):
  var x=float(i)*size.x/12.; var h=90.+float((i*47)%180); draw_rect(Rect2(x,size.y-h,size.x/15.,h),Color("#111D26"))
 for i in range(30):
  var x=float((i*83)%int(size.x)); var y=float((i*47)%int(size.y*.72)); draw_circle(Vector2(x,y),1.8,Color("#39D7B0"))
 var city=PackedVector2Array([Vector2(0,size.y*.78),Vector2(size.x*.12,size.y*.55),Vector2(size.x*.24,size.y*.72),Vector2(size.x*.38,size.y*.48),Vector2(size.x*.52,size.y*.7),Vector2(size.x*.68,size.y*.5),Vector2(size.x*.82,size.y*.68),Vector2(size.x,size.y*.54),Vector2(size.x,size.y),Vector2(0,size.y)])
 draw_colored_polygon(city,Color("#0B151D"))
func finish():
 if done:return
 done=true; finished.emit()
func _gui_input(e):
 if (e is InputEventScreenTouch and e.pressed) or (e is InputEventMouseButton and e.pressed): finish()
