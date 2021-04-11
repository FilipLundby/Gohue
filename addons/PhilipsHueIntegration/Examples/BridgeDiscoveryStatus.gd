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
	match status:
		DiscoveryState.states.DISCOVERING:
			_text_edit.text += "Bridge discovery started. Please wait ...\n"
		DiscoveryState.states.HOST_FOUND:
			_text_edit.text += "Host found ...\n"
		DiscoveryState.states.FAILED:
			_text_edit.text += "Failed to connect.\n"
		DiscoveryState.states.RETRY:
			_text_edit.text += "Failed to discovery bridge. Retrying ...\n"
		DiscoveryState.states.VALIDATING:
			_text_edit.text += "Validating hue bridge ...\n"
		DiscoveryState.states.CONNECTED:
			_text_edit.text += "Connected!\n"
		_: # Fallback
			_text_edit.text += "Unknown error occured: %s\n" % status


func _on_discover_succeded(url_base):
	_text_edit.text += "Success! Connected to %s\n" % url_base
	HueUtils.save("hue_url.dat", url_base)

