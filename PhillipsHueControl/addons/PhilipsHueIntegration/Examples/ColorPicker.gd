extends HueBridgeApi

export(NodePath) var _hue_discovery_path: NodePath = "../HueBridgeDiscovery"

onready var _viewport: Viewport = get_viewport()


func _ready() -> void:
	if !_hue_discovery_path.is_empty():
		var hue_discovery: HueBridgeDiscovery = get_node(_hue_discovery_path)
# warning-ignore:return_value_discarded
		hue_discovery.connect("discover_succeded", self, "_on_discover_succeded")
	
	var url: String = HueUtils.load("hue_url.dat")
	if len(url): self.url_base = url
	
	var user: String = HueUtils.load("hue_username.dat")
	if len(user): self.username = user


func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if !event.pressed: return

	if event.button_index == BUTTON_LEFT:
		var image: Image = _viewport.get_texture().get_data()
		image.lock()
		var color: Color = image.get_pixel(event.position.x, event.position.y)
		image.unlock()
		self.set_group_color(1, color)


func _on_discover_succeded(url_base) -> void:
	self.url_base = url_base
