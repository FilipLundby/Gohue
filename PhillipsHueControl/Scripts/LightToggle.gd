extends Node

onready var _hue_api: HueBridgeApi = get_parent()

var _on: bool = false


func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_T:
		_hue_api.set_light(1, { "on": _on })
		_on = !_on
	if event.scancode == KEY_E:
		# Built-in Hue effects. Values can be either "none" or "colorloop"
		_hue_api.set_light_effect(1, "colorloop") 
	if event.scancode == KEY_R:
		_hue_api.set_light_color(1, Color.red)
	if event.scancode == KEY_G:
		_hue_api.set_light_color(1, Color.green)
	if event.scancode == KEY_B:
		_hue_api.set_light_color(1, Color.blue)
	if event.scancode == KEY_N:
		_hue_api.set_light_color(1, Color.floralwhite, 150, true)
	if event.scancode == KEY_A:
		# Built-in Hue alert. Values can be either "select" or "lselect"
		_hue_api.set_light_alert(1, "lselect")
