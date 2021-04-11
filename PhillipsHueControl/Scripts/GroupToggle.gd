extends Node

onready var _hue_api: HueBridgeApi = get_parent()

var _on: bool = false


func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_0:
		_hue_api.set_group(1, { "on": _on })
		_on = !_on
	if event.scancode == KEY_9:
		_hue_api.set_group_color(1, Color.floralwhite)
	if event.scancode == KEY_8:
		_hue_api.set_group_effect(1, "colorloop")
	if event.scancode == KEY_7:
		_hue_api.set_group_alert(1, "select")
