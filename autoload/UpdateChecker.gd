extends Node
## Revisa el ultimo Release de GitHub Actions y avisa si hay una version
## mas nueva que la instalada. No instala nada automaticamente: Android
## no permite auto-instalar APKs de terceros por seguridad. Abre el
## navegador en la descarga para que el usuario la instale en dos toques.

signal update_available(tag_name: String, download_url: String)

const RELEASES_API := "https://api.github.com/repos/Thor3204/Killbox-/releases/latest"

func _ready() -> void:
	check()

func check() -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_completed.bind(http))
	var headers := ["User-Agent: KILLBOX-App"]
	var err := http.request(RELEASES_API, headers)
	if err != OK:
		http.queue_free()

func _on_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return
	var release = json.data
	if typeof(release) != TYPE_DICTIONARY:
		return
	var tag: String = str(release.get("tag_name", ""))
	var remote_build := _extract_build_number(tag)
	if remote_build <= AppVersion.BUILD_NUMBER:
		return
	var download_url := ""
	var assets = release.get("assets", [])
	for asset in assets:
		var asset_name: String = str(asset.get("name", ""))
		if asset_name.ends_with(".apk"):
			download_url = str(asset.get("browser_download_url", ""))
			break
	if download_url == "":
		download_url = str(release.get("html_url", ""))
	if download_url != "":
		update_available.emit(tag, download_url)

func _extract_build_number(tag: String) -> int:
	var digits := ""
	for c in tag:
		if c.is_valid_int():
			digits += c
	if digits == "":
		return -1
	return int(digits)
