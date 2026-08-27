extends Control
class_name KillboxBackdrop

@export var variant: int = 0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw() -> void:
	var s := size
	if s.x <= 0.0 or s.y <= 0.0:
		return
	# Base
	draw_rect(Rect2(Vector2.ZERO, s), Color("#070A0F"))
	# Large atmospheric shapes
	draw_circle(Vector2(s.x * 0.82, s.y * 0.16), min(s.x, s.y) * 0.32, Color(0.16, 0.24, 0.34, 0.22))
	draw_circle(Vector2(s.x * 0.10, s.y * 0.86), min(s.x, s.y) * 0.38, Color(0.12, 0.28, 0.24, 0.16))
	# City skyline silhouette
	var base_y := s.y * 0.82
	var x := 0.0
	var widths := [72.0, 108.0, 58.0, 132.0, 84.0, 160.0, 62.0, 116.0, 90.0, 145.0, 70.0, 125.0]
	var heights := [130.0, 190.0, 95.0, 230.0, 150.0, 260.0, 120.0, 210.0, 165.0, 245.0, 105.0, 185.0]
	for i in widths.size():
		var w: float = widths[i]
		var h: float = heights[i]
		draw_rect(Rect2(x, base_y - h, w - 4.0, h), Color(0.04, 0.06, 0.09, 0.92))
		var wx := x + 14.0
		while wx < x + w - 16.0:
			var wy := base_y - h + 18.0
			while wy < base_y - 14.0:
				draw_rect(Rect2(wx, wy, 5.0, 7.0), Color(0.72, 0.79, 0.74, 0.11))
				wy += 20.0
			wx += 18.0
		x += w
		if x > s.x:
			break
	# Ground glow / road
	draw_rect(Rect2(0, base_y, s.x, s.y - base_y), Color(0.025, 0.035, 0.05, 0.98))
	draw_line(Vector2(0, base_y), Vector2(s.x, base_y), Color(0.2, 0.75, 0.62, 0.18), 2.0)
	# Decorative diagonal lines
	for i in range(7):
		var yy := s.y * 0.14 + float(i) * 62.0
		draw_line(Vector2(s.x * 0.58, yy), Vector2(s.x * 0.98, yy - 110.0), Color(0.25, 0.85, 0.72, 0.035), 2.0)
