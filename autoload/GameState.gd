extends Node
## Estado global de sesion: quien es el jugador, que personaje eligio,
## y el resultado de la ultima partida (para mostrarlo en el overlay
## de victoria y en el lobby).

var player_nickname: String = "Jugador"
var selected_character_id: String = "rex"

## Se llena en Match cuando termina una partida.
var last_match_result: Dictionary = {}

func go_to(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
