extends Node
## RemoteConfig
## Descarga data/game_config.json directamente desde GitHub (raw) para poder
## ajustar balance del juego (recompensas, duración de ciclos, cooldowns,
## cantidad de bots, versión mínima requerida) SIN recompilar el APK.
## Si editás data/game_config.json en el repo y hacés push a "main", la
## próxima vez que la app abra (o vuelva al lobby) toma los valores nuevos.

signal config_updated

const RAW_CONFIG_URL := "https://raw.githubusercontent.com/Thor3204/Killbox-/main/data/game_config.json"
const LOCAL_FALLBACK_PATH := "res://data/game_config.json"
const POLL_INTERVAL_SECONDS := 90.0
const APP_BUILD_VERSION := "0.1.0" # subir a mano cuando cambie lógica/código real

var _config: Dictionary = {}
var _http: HTTPRequest
var _poll_timer: Timer
var is_ready := false
var update_available := false
var latest_version_label := ""

func _ready() -> void:
	_load_local_fallback()

	_http = HTTPRequest.new()
	_http.timeout = 8.0
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)

	_poll_timer = Timer.new()
	_poll_timer.wait_time = POLL_INTERVAL_SECONDS
	_poll_timer.autostart = false
	_poll_timer.one_shot = false
	_poll_timer.timeout.connect(fetch_remote_config)
	add_child(_poll_timer)

	fetch_remote_config()

func start_polling() -> void:
	_poll_timer.start()

func stop_polling() -> void:
	_poll_timer.stop()

func fetch_remote_config() -> void:
	if _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	var err := _http.request(RAW_CONFIG_URL)
	if err != OK:
		push_warning("RemoteConfig: no se pudo iniciar la petición (%s)" % err)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		is_ready = true
		config_updated.emit()
		return
	var text := body.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		is_ready = true
		config_updated.emit()
		return
	for key in parsed.keys():
		_config[key] = parsed[key]
	is_ready = true
	_check_version()
	config_updated.emit()

func _load_local_fallback() -> void:
	if not FileAccess.file_exists(LOCAL_FALLBACK_PATH):
		return
	var f := FileAccess.open(LOCAL_FALLBACK_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		_config = parsed

func _check_version() -> void:
	var min_version : String = get_value("min_app_version", APP_BUILD_VERSION)
	latest_version_label = get_value("latest_app_version", APP_BUILD_VERSION)
	update_available = _version_is_older(APP_BUILD_VERSION, min_version)

func _version_is_older(current: String, required: String) -> bool:
	var c := current.split(".")
	var r := required.split(".")
	for i in range(max(c.size(), r.size())):
		var cv := int(c[i]) if i < c.size() else 0
		var rv := int(r[i]) if i < r.size() else 0
		if cv != rv:
			return cv < rv
	return false

func get_value(key: String, default_value = null):
	if _config.has(key):
		return _config[key]
	return default_value

func get_kill_reward() -> float:
	return float(get_value("kill_reward_box", 90.0))

func get_cycle_prep_seconds() -> float:
	return float(get_value("cycle_prep_seconds", 15.0))

func get_cycle_hunt_seconds() -> float:
	return float(get_value("cycle_hunt_seconds", 15.0))

func get_bot_count() -> int:
	return int(get_value("bot_count", 11))

func get_character_overrides() -> Dictionary:
	return get_value("characters", {})

func get_map_events() -> Array:
	return get_value("map_events", [])
