extends Node
## CharacterData
## Roster inicial: Rex, Luna, Max, Maya, Kai (docs/CHARACTERS.md).
## Los valores numéricos (cooldown, daño, duración) se pueden sobreescribir
## en caliente vía RemoteConfig -> data/game_config.json -> "characters".

const DEFAULT_ROSTER := {
	"rex": {
		"display_name": "Rex",
		"role": "Mecánico",
		"ability_name": "Barricada",
		"color": Color8(120, 150, 170),
		"max_health": 100.0,
		"move_speed": 160.0,
		"attack_damage": 18.0,
		"ability_cooldown": 12.0,
		"barricade_duration": 6.0,
	},
	"luna": {
		"display_name": "Luna",
		"role": "Detective",
		"ability_name": "Rastro",
		"color": Color8(150, 120, 190),
		"max_health": 90.0,
		"move_speed": 170.0,
		"attack_damage": 15.0,
		"ability_cooldown": 14.0,
		"trail_radius": 260.0,
		"trail_duration": 5.0,
	},
	"max": {
		"display_name": "Max",
		"role": "Explosivista",
		"ability_name": "Trampa",
		"color": Color8(200, 120, 90),
		"max_health": 95.0,
		"move_speed": 160.0,
		"attack_damage": 16.0,
		"ability_cooldown": 10.0,
		"trap_damage": 30.0,
	},
	"maya": {
		"display_name": "Maya",
		"role": "Médica",
		"ability_name": "Primeros auxilios",
		"color": Color8(120, 190, 140),
		"max_health": 100.0,
		"move_speed": 160.0,
		"attack_damage": 14.0,
		"ability_cooldown": 16.0,
		"heal_amount": 30.0,
	},
	"kai": {
		"display_name": "Kai",
		"role": "Mensajero",
		"ability_name": "Turbo",
		"color": Color8(210, 190, 90),
		"max_health": 85.0,
		"move_speed": 165.0,
		"attack_damage": 14.0,
		"ability_cooldown": 11.0,
		"turbo_multiplier": 1.8,
		"turbo_duration": 3.0,
	},
}

func get_roster_ids() -> Array:
	return DEFAULT_ROSTER.keys()

func get_character(id: String) -> Dictionary:
	var base: Dictionary = DEFAULT_ROSTER.get(id, DEFAULT_ROSTER["rex"]).duplicate(true)
	var overrides: Dictionary = RemoteConfig.get_character_overrides().get(id, {})
	for key in overrides.keys():
		if key == "color":
			continue
		base[key] = overrides[key]
	return base
