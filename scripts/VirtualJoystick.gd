extends Control
class_name VirtualJoystick
## Joystick virtual táctil para movimiento (docs/UI-UX.md: abajo-izquierda).
## También responde al mouse para poder probar el juego en escritorio.

signal direction_changed(dir: Vector2)

const RADIUS := 70.0
const KNOB_RADIUS := 30.0

var _touch_index := -1
var _knob_offset := Vector2.ZERO
var direction := Vector2.ZERO

func _ready() -> void:
	custom_minimum_size = Vector2(RADIUS * 2, RADIUS * 2)
	mouse_filter = Control.MOUSE_FILTER_STOP

func _draw() -> void:
	var center := size / 2.0
	draw_circle(center, RADIUS, Color(1, 1, 1, 0.12))
	draw_circle(center, RADIUS, Color(1, 1, 1, 0.35), false, 2.0)
	draw_circle(center + _knob_offset, KNOB_RADIUS, Color(1, 1, 1, 0.55))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_reset()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_touch_index = 0
			_update_knob(event.position)
		else:
			_reset()
	elif event is InputEventMouseMotion and _touch_index == 0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_knob(event.position)

func _update_knob(local_pos: Vector2) -> void:
	var center := size / 2.0
	var offset := local_pos - center
	if offset.length() > RADIUS:
		offset = offset.normalized() * RADIUS
	_knob_offset = offset
	direction = offset / RADIUS
	direction_changed.emit(direction)
	queue_redraw()

func _reset() -> void:
	_touch_index = -1
	_knob_offset = Vector2.ZERO
	direction = Vector2.ZERO
	direction_changed.emit(direction)
	queue_redraw()
