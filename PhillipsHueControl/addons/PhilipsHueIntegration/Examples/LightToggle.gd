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
	if event.scancode == KEY_T:
		self.set_light(1, { "on": _on })
		_on = !_on
	if event.scancode == KEY_E:
		# Built-in Hue effects. Values can be either "none" or "colorloop"
		self.set_light_effect(1, "colorloop") 
	if event.scancode == KEY_R:
		self.set_light_color(1, Color.red)
	if event.scancode == KEY_G:
		self.set_light_color(1, Color.green)
	if event.scancode == KEY_B:
		self.set_light_color(1, Color.blue)
	if event.scancode == KEY_N:
		self.set_light_color(1, Color.floralwhite, 150, true)
	if event.scancode == KEY_A:
		# Built-in Hue alert. Values can be either "select" or "lselect"
		self.set_light_alert(1, "lselect")


func _on_discover_succeded(url_base) -> void:
	self.url_base = url_base
