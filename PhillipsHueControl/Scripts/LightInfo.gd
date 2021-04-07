extends Node

onready var _hue_connection: HueBridgeDiscovery = get_parent()

var _hue_helper: HueHelper


func _ready():
	_hue_helper = HueHelper.new(_hue_connection)


func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_1:
		_hue_helper.get_data()
	if event.scancode == KEY_2:
		_hue_helper.get_light(1)
