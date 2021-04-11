extends HueBridgeDiscovery

export(NodePath) var _text_edit_path: NodePath = "../TextEdit"

var _text_edit: TextEdit


func _ready():
	if !_text_edit_path.is_empty():
		_text_edit = get_node(_text_edit_path)
	
	# Load URL
	var url: String = HueUtils.load("hue_url.dat")
	# Don't try to discover Hue Bridge, if URL was specified
	if !len(url) or !url.begins_with("http"):
		_text_edit.text += "Looking for Hue Bridge. Please wait ...\n"
		self.start()

# warning-ignore:return_value_discarded
	self.connect("discover_status", self, "_on_discover_status")
# warning-ignore:return_value_discarded
	self.connect("discover_succeded", self, "_on_discover_succeded")


func _on_discover_status(status):
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

