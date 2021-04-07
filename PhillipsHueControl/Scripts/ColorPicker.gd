extends Node

onready var _hue_connection: HueBridgeDiscovery = get_parent()

var _hue_helper: HueHelper
var _viewport: Viewport


func _ready():
	_hue_helper = HueHelper.new(_hue_connection)
	_viewport = get_viewport()


func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if !event.pressed: return

	if event.button_index == BUTTON_LEFT:
		var image: Image = _viewport.get_texture().get_data()
		image.lock()
		var color: Color = image.get_pixel(event.position.x, event.position.y)
		image.unlock()
		_hue_helper.set_group_color(1, color)
