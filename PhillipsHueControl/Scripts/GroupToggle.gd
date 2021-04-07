extends Node

onready var _hue_connection: HueBridgeDiscovery = get_parent()

var _on: bool = false
var _hue_helper: HueHelper


func _ready():
	_hue_helper = HueHelper.new(_hue_connection)


func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_0:
		_hue_helper.set_group(1, { "on": _on })
		_on = !_on
	if event.scancode == KEY_9:
		_hue_helper.set_group_color(1, Color.floralwhite)
	if event.scancode == KEY_8:
		_hue_helper.set_group_effect(1, "colorloop")
	if event.scancode == KEY_7:
		_hue_helper.set_group_alert(1, "select")
