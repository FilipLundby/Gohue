extends HueBridgeApi

export(NodePath) var _hue_discovery_path: NodePath = "../HueBridgeDiscovery"

var _on: bool = false


func _ready() -> void:
	if !_hue_discovery_path.is_empty():
		var hue_discovery: HueBridgeDiscovery = get_node(_hue_discovery_path)
# warning-ignore:return_value_discarded
		hue_discovery.connect("discover_succeded", self, "_on_discover_succeded")
	
	var url: String = HueUtils.load("hue_url.dat")
	if len(url): self.url_base = url
	
	var user: String = HueUtils.load("hue_username.dat")
	if len(user): self.username = user


func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_0:
		self.set_group(1, { "on": _on })
		_on = !_on
	if event.scancode == KEY_9:
		self.set_group_color(1, Color.floralwhite)
	if event.scancode == KEY_8:
		self.set_group_effect(1, "colorloop")
	if event.scancode == KEY_7:
		self.set_group_alert(1, "select")


func _on_discover_succeded(url_base) -> void:
	self.url_base = url_base
