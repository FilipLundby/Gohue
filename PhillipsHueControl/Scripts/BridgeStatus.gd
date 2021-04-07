extends Node

onready var _hue_connection: HueBridgeDiscovery = get_parent()
onready var _text_edit: TextEdit = $"../../TextEdit"

var _hue_helper: HueHelper


func _ready():
	var url: String = HueUtils.load("hue_url.dat")
	var username: String = HueUtils.load("hue_username.dat")
	print("username ", username, " -- url ", url)
	_hue_connection.start(url, username)
	
	_hue_helper = HueHelper.new(_hue_connection)
# warning-ignore:return_value_discarded
	_hue_connection.connect("bridge_discover_status", self, "_on_bridge_discover_status")
# warning-ignore:return_value_discarded
	_hue_connection.connect("bridge_discover_succeded", self, "_on_bridge_discover_succeded")
# warning-ignore:return_value_discarded
	_hue_connection.connect("bridge_request_completed", self, "_on_bridge_request_completed")




func _on_bridge_discover_status(status):
	var msg = [
		"Bridge discovery started. Please wait ...\n",
		"Host found ...\n",
		"Failed to discovery bridge. Retrying ...\n",
		"Validating hue bridge ...\n",
		"Connected!\n",
		"Failed to connect.\n",
	]
	var has_index: bool = msg.size() > status
	_text_edit.text += msg[status] if has_index else "Status code: %s\n" % status


func _on_bridge_discover_succeded(url_base):
	_text_edit.text += "Success! Connected to %s\n" % url_base
	HueUtils.save("hue_url.dat", url_base)


func _on_bridge_request_completed(_result, _response_code, _headers, body) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result != null:
		var json_str: String = JSON.print(json.result)
		_text_edit.text = JSONBeautifier.beautify_json(json_str)
