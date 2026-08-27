extends Control
class_name CharacterPreview

var character_id: String = "rex"

func _draw() -> void:
	var d: Dictionary = CharacterData.get_character(character_id)
	var c: Color = d.get("color", Color("#62E8C5"))
	var center := Vector2(size.x * 0.5, size.y * 0.58)
	# Soft showcase halo.
	draw_circle(center + Vector2(0, 12), 68, Color(c.r, c.g, c.b, 0.10))
	draw_circle(center + Vector2(0, 12), 54, Color(c.r, c.g, c.b, 0.08))
	# Body.
	draw_circle(center + Vector2(0, 18), 34, c.darkened(0.18))
	draw_circle(center + Vector2(0, -18), 25, c.lightened(0.12))
	# Face.
	draw_circle(center + Vector2(-9, -20), 3.5, Color("#142027"))
	draw_circle(center + Vector2(9, -20), 3.5, Color("#142027"))
	draw_line(center + Vector2(-6, -9), center + Vector2(6, -9), Color("#142027"), 2.5)
	# Profession hints.
	match character_id:
		"rex":
			draw_rect(Rect2(center + Vector2(-32, -2), Vector2(64, 8)), Color("#D39A43"), true)
		"luna":
			draw_circle(center + Vector2(0, -42), 29, Color("#2A2338"))
			draw_arc(center + Vector2(0, -18), 25, PI, TAU, 20, c.lightened(0.2), 5)
		"max":
			draw_circle(center + Vector2(0, 18), 39, Color("#252B30"), false, 5)
			draw_circle(center + Vector2(0, -48), 7, Color("#FF665A"))
		"maya":
			draw_rect(Rect2(center + Vector2(-28, 4), Vector2(56, 10)), Color("#F3F4F0"), true)
			draw_rect(Rect2(center + Vector2(-5, -19), Vector2(10, 38)), Color("#E96C66"), true)
		"kai":
			draw_line(center + Vector2(-35, 25), center + Vector2(35, 25), Color("#E9D47A"), 6)
