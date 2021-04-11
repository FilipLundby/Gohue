extends HueBridgeApi

export(NodePath) var _text_edit_path: NodePath = "../TextEdit"
export(NodePath) var _hue_discovery_path: NodePath = "../HueBridgeDiscovery"

var _text_edit: TextEdit


func _ready() -> void:
	if !_hue_discovery_path.is_empty():
		var hue_discovery: HueBridgeDiscovery = get_node(_hue_discovery_path)
# warning-ignore:return_value_discarded
		hue_discovery.connect("discover_succeded", self, "_on_discover_succeded")
	if !_text_edit_path.is_empty():
		_text_edit = get_node(_text_edit_path)
	
# warning-ignore:return_value_discarded
	connect("request_completed", self, "_on_request_completed")

	var url: String = HueUtils.load("hue_url.dat")
	if len(url): self.url_base = url
	
	var user: String = HueUtils.load("hue_username.dat")
	if len(user): self.username = user


func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_1:
		self.get_data()
	if event.scancode == KEY_2:
		self.get_light(1)


func _on_request_completed(_result, _response_code, _headers, body) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result != null:
		# Print human readable JSON
		_text_edit.text = JSON.print(json.result, "    ")


func _on_discover_succeded(url_base) -> void:
	self.url_base = url_base
