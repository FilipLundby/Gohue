# Godot integration to Philips Hue 

## Getting started

All you need to get startet are these lines:

```gdscript
onready var _ph_connection: HueConnection = get_parent()
var _ph: HueHelper

func _ready() -> void:
	_ph = load("res://path/to/HueHelper.gd").new(
		_ph_connection
	)
	_ph.set_light_effect(1)
```

If you'd like to take it a step further and also want to receive 
a response from the bridge, you need to add a few extra lines:

```gdscript
onready var _ph_connection: HueConnection = get_parent()
var _ph: HueHelper

func _ready() -> void:
	_ph = load("res://path/to/HueHelper.gd").new(
		_ph_connection
	)
	_ph_connection.connect("request_completed", self, "_on_request_completed")
	_ph.set_light_effect(1)

func _on_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	var json_str: String = JSON.print(json.result)
	print(json_str)
```

Now you are ready to turn lights on and off ::sunglasses:: 

## Manage a light

```gdscript
_ph.set_light(1, { "on": true })
_ph.set_light_color(1, Color(1, 0, 0), 120, true)
_ph.set_light_effect(1, "colorloop") 					# Built-in effect. Can be either "colorloop" or "none"
_ph.set_light_alert(1, "select") 						# Built-in alert. Can be either "select" or "lselect"
```

### Set light state directly

```gdscript
_ph.set_light(1, { 
	"on": true,
	"xy": _ph.get_rgb_to_xy(Color(0, 1, 0))
})
```


## Manage a group

```gdscript
_ph.set_group(1, { "on": true })
_ph.set_group_color(1, Color(1, 0, 0), 120, true)
_ph.set_group_effect(1, "colorloop") 					# Built-in effect. Can be either "colorloop" or "none"
_ph.set_group_alert(1, "select") 						# Built-in alert. Can be either "select" or "lselect"
```

### Set group state directly

```gdscript
_ph.set_group(1, { 
	"on": true,
	"xy": _ph.get_rgb_to_xy(Color(0, 1, 0))
})
```

## Get info

```gdscript
_ph.get_data()		# Get all available data
_ph.get_light(1)	# Get data related to light #1
_ph.get_group(1)	# Get data related to group #1
```
