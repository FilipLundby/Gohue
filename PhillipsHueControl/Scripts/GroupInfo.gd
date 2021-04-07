extends Node

onready var _hue_connection: HueBridgeDiscovery = get_parent()

var _hue_helper: HueHelper


func _ready():
	_hue_helper = HueHelper.new(_hue_connection)


func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_K:
		_hue_helper.get_group(1)
