extends Node

onready var _hue_api: HueBridgeApi = get_parent()

export(NodePath) var _text_edit_path: NodePath = "../../TextEdit"
export(NodePath) var _hue_discovery_path: NodePath = "../../HueBridgeDiscovery"

var _text_edit: TextEdit


func _ready():
	if !_hue_discovery_path.is_empty():
		var hue_discovery: HueBridgeDiscovery = get_node(_hue_discovery_path)
# warning-ignore:return_value_discarded
		hue_discovery.connect("bridge_discover_succeded", self, "_on_bridge_discover_succeded")
	if !_text_edit_path.is_empty():
		_text_edit = get_node(_text_edit_path)
	
# warning-ignore:return_value_discarded
	_hue_api.connect("request_completed", self, "_on_request_completed")
	
	var url: String = HueUtils.load("hue_url.dat")
	if len(url): _hue_api.url_base = url
	
	var username: String = HueUtils.load("hue_username.dat")
	if len(username): _hue_api.username = username


func _on_request_completed(_result, _response_code, _headers, body) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result != null:
		var json_str: String = JSON.print(json.result)
		_text_edit.text = JSONBeautifier.beautify_json(json_str)


func _on_bridge_discover_succeded(url_base):
	print("Base API URL updated.")
	_hue_api.url_base = url_base
