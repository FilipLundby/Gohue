extends Node

onready var _hue_api: HueBridgeApi = get_parent()


func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_1:
		_hue_api.get_data()
	if event.scancode == KEY_2:
		_hue_api.get_light(1)
