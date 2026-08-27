extends Node
## Config remota "en vivo": lee data/game_config.json directamente
## del repo de GitHub (raw.githubusercontent.com) al iniciar la app
## y cada cierto tiempo mientras corre. Cambiar ese archivo en GitHub
## ajusta el balance del juego sin recompilar el APK.
##
## Si no hay internet o falla la descarga, se usan los valores por
## defecto de DEFAULTS para que el juego siempre sea jugable offline.

signal config_updated

const RAW_URL := "https://raw.githubusercontent.com/Thor3204/Killbox-/main/data/game_config.json"
const REFRESH_SECONDS := 120.0

const DEFAULTS := {
	"cycle_seconds": 30.0,
	"prep_seconds": 12.0,
	"bot_count": 11,
	"kill_reward_box": 90,
	"map_event_chance": 0.5,
	"danger_zone_damage_per_second": 6.0,
	"blackout_seconds": 6.0,
	"supply_drop_heal": 30,
	"supply_drop_speed_mult": 1.25,
	"supply_drop_seconds": 6.0,
	"trap_damage": 18,
	"trap_slow_mult": 0.5,
	"trap_slow_seconds": 2.5,
	"feature_alliances": true,
	"feature_map_events": true,
}

var data: Dictionary = DEFAULTS.duplicate(true)
var last_synced_unix: int = 0

func _ready() -> void:
	fetch()
	var t := Timer.new()
	t.wait_time = REFRESH_SECONDS
	t.autostart = true
	t.timeout.connect(fetch)
	add_child(t)

func fetch() -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_completed.bind(http))
	var err := http.request(RAW_URL)
	if err != OK:
		http.queue_free()

func _on_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return
	var parsed = json.data
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for key in parsed.keys():
		data[key] = parsed[key]
	last_synced_unix = Time.get_unix_time_from_system()
	config_updated.emit()

func get_value(key: String, fallback = null) -> Variant:
	if data.has(key):
		return data[key]
	if fallback != null:
		return fallback
	return DEFAULTS.get(key)
