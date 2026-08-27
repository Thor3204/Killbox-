extends Control
class_name CharacterPreview

var character_id: String = "rex"

func _draw() -> void:
	var d:Dictionary=CharacterData.get_character(character_id)
	var c:Color=d.get("color",Color("#62E8C5"))
	var center:=Vector2(size.x*0.5,size.y*0.54)
	# Ground shadow and soft aura.
	draw_ellipse(center+Vector2(0,94),Vector2(72,16),Color(0,0,0,0.35))
	draw_circle(center+Vector2(0,10),78,Color(c.r,c.g,c.b,0.07))
	draw_circle(center+Vector2(0,10),58,Color(c.r,c.g,c.b,0.08))
	# Legs / boots.
	draw_rect(Rect2(center+Vector2(-25,58),Vector2(18,38)),Color("#182329"),true)
	draw_rect(Rect2(center+Vector2(7,58),Vector2(18,38)),Color("#182329"),true)
	draw_rect(Rect2(center+Vector2(-30,90),Vector2(28,9)),Color("#0A1115"),true)
	draw_rect(Rect2(center+Vector2(4,90),Vector2(28,9)),Color("#0A1115"),true)
	# Body jacket.
	draw_style_box(_body_box(c),Rect2(center+Vector2(-39,-2),Vector2(78,72)))
	# Neck and head.
	draw_rect(Rect2(center+Vector2(-10,-22),Vector2(20,20)),Color("#C88F72"),true)
	draw_circle(center+Vector2(0,-43),31,Color("#D9A07F"))
	# Hair.
	draw_circle(center+Vector2(0,-62),28,Color("#151C21"))
	draw_rect(Rect2(center+Vector2(-28,-64),Vector2(56,16)),Color("#151C21"),true)
	# Eyes and expression.
	draw_circle(center+Vector2(-10,-43),3.2,Color("#11191D"))
	draw_circle(center+Vector2(10,-43),3.2,Color("#11191D"))
	draw_line(center+Vector2(-7,-31),center+Vector2(7,-31),Color("#5C3531"),2)
	# Profession-specific silhouette props.
	match character_id:
		"rex":
			draw_rect(Rect2(center+Vector2(-49,-5),Vector2(15,58)),Color("#B97D38"),true)
			draw_line(center+Vector2(-42,5),center+Vector2(-42,43),Color("#E8C06A"),3)
			draw_rect(Rect2(center+Vector2(-30,-78),Vector2(60,9)),Color("#D49A48"),true)
		"luna":
			draw_arc(center+Vector2(0,-43),34,PI,TAU,24,Color("#6C5A91"),7)
			draw_line(center+Vector2(-35,-10),center+Vector2(35,-10),Color("#5E527F"),5)
		"max":
			draw_rect(Rect2(center+Vector2(-40,-72),Vector2(80,12)),Color("#2A3439"),true)
			draw_circle(center+Vector2(38,-40),9,Color("#F06455"))
		"maya":
			draw_rect(Rect2(center+Vector2(-40,8),Vector2(80,10)),Color("#F1F1EA"),true)
			draw_line(center+Vector2(0,-5),center+Vector2(0,26),Color("#D95858"),6)
		"kai":
			draw_line(center+Vector2(-48,38),center+Vector2(48,38),Color("#D7B85D"),7)
			draw_line(center+Vector2(0,33),center+Vector2(0,49),Color("#D7B85D"),5)

func _body_box(c:Color)->StyleBoxFlat:
	var s:=StyleBoxFlat.new(); s.bg_color=c.darkened(0.12); s.corner_radius_top_left=18; s.corner_radius_top_right=18; s.corner_radius_bottom_left=10; s.corner_radius_bottom_right=10; return s

func draw_ellipse(center:Vector2,radii:Vector2,color:Color)->void:
	var points:=PackedVector2Array()
	for i in range(32):
		var a=TAU*float(i)/32.0; points.append(center+Vector2(cos(a)*radii.x,sin(a)*radii.y))
	draw_colored_polygon(points,color)
