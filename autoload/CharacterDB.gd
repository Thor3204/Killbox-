extends Node
## Roster inicial de KILLBOX (ver docs/CHARACTERS.md).
## Se define en codigo (no en .tres) para mantener todo editable
## desde un solo lugar sin depender de recursos importados.
## icon_shape se dibuja a mano en CharacterVisual.gd (sin emojis,
## para no depender de una fuente con soporte de color-emoji).

var _characters: Dictionary = {}
var _order: Array = []

func _ready() -> void:
	_register("rex", {
		"name": "Rex",
		"role": "Mecánico",
		"ability_name": "Barricada",
		"ability_desc": "Coloca una barrera temporal para bloquear una ruta.",
		"icon_shape": "wrench",
		"color": Color(0.75, 0.55, 0.25),
		"cooldown": 8.0,
		"speed_mult": 1.0,
	})
	_register("luna", {
		"name": "Luna",
		"role": "Detective",
		"ability_name": "Rastro",
		"ability_desc": "Revela señales recientes de otros jugadores cerca.",
		"icon_shape": "lens",
		"color": Color(0.55, 0.65, 0.85),
		"cooldown": 10.0,
		"speed_mult": 1.0,
	})
	_register("max", {
		"name": "Max",
		"role": "Explosivista",
		"ability_name": "Trampa",
		"ability_desc": "Coloca una trampa visible que daña y ralentiza.",
		"icon_shape": "bomb",
		"color": Color(0.8, 0.35, 0.3),
		"cooldown": 9.0,
		"speed_mult": 0.97,
	})
	_register("maya", {
		"name": "Maya",
		"role": "Médica",
		"ability_name": "Primeros auxilios",
		"ability_desc": "Recupera una cantidad limitada de vida.",
		"icon_shape": "cross",
		"color": Color(0.4, 0.75, 0.55),
		"cooldown": 12.0,
		"speed_mult": 1.0,
	})
	_register("kai", {
		"name": "Kai",
		"role": "Mensajero",
		"ability_name": "Turbo",
		"ability_desc": "Velocidad temporal para escapar o perseguir.",
		"icon_shape": "bolt",
		"color": Color(0.85, 0.75, 0.3),
		"cooldown": 9.0,
		"speed_mult": 1.05,
	})

func _register(id: String, data: Dictionary) -> void:
	data["id"] = id
	_characters[id] = data
	_order.append(id)

func get_character(id: String) -> Dictionary:
	if _characters.has(id):
		return _characters[id]
	return _characters[_order[0]]

func all() -> Array:
	var out: Array = []
	for id in _order:
		out.append(_characters[id])
	return out
