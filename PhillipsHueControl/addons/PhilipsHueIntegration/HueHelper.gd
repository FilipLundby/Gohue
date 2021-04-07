class_name HueHelper

var _username: String 
var _ssl_enabled: bool
var _url_base: String
var _bridge: HueBridgeDiscovery
var _headers: Array = ["Content-Type: application/json"]


func _init(bridge: HueBridgeDiscovery) -> void:
	_bridge = bridge
	_username = bridge.username
	_url_base = bridge.url_base
	_ssl_enabled = bridge.ssl
# warning-ignore:return_value_discarded
	_bridge.connect("bridge_discover_succeded", self, "_on_bridge_discover_succeded")


func _on_bridge_discover_succeded(url_base: String):
	_url_base = url_base


func create_user(devicetype: String) -> void:
	_bridge.http_post(
		"%sapi" % [
			_url_base,
		],
		{ 
			"devicetype": devicetype 
		},
		_headers,
		_ssl_enabled
	)


# Deleting users through the API is obsolete. Source: 
# https://developers.meethue.com/hue-whitelist-security-update/ 
func delete_user(username: String) -> void:
	_bridge.http_delete(
		"%sapi/%s/config/whitelist/%s" % [
			_url_base,
			_username,	# Authenticated user
			username	# User to delete
		],
		_headers,
		_ssl_enabled
	)


func get_config() -> void:
	_bridge.http_get(
		"%sapi/%s/config" % [
			_url_base,
			_username
		],
		_headers,
		_ssl_enabled
	)


# Get all available data
func get_data() -> void:
	 _bridge.http_get(
		"%sapi/%s" % [
			_url_base, 
			_username
		],
		_headers,
		_ssl_enabled
	)


func get_light(light_id: int = 1) -> void:
	_bridge.http_get(
		"%sapi/%s/lights/%s" % [
			_url_base, 
			_username,
			light_id
		],
		_headers,
		_ssl_enabled
	)


func set_light(light_id: int = 1, settings: Dictionary = {}) -> void:
	_bridge.http_put(
		"%sapi/%s/lights/%s/state" % [
			_url_base, 
			_username, 
			light_id
		],
		settings,
		_headers,
		_ssl_enabled
	)


func set_light_alert(light_id: int = 1, alert: String = "select", on: bool = true) -> void:
	_bridge.http_put(
		"%sapi/%s/lights/%s/state" % [
			_url_base, 
			_username, 
			light_id
		],
		{
			"on": on,
			"alert": alert,
		},
		_headers,
		_ssl_enabled
	)


func set_light_color(light_id: int = 1, color: Color = Color.floralwhite, brightness: int = 254, on: bool = true) -> void:
	_bridge.http_put(
		"%sapi/%s/lights/%s/state" % [
			_url_base, 
			_username, 
			light_id
		],
		{
			"on": on,
			"bri": brightness,
			"xy": get_rgb_to_xy(color)
		},
		_headers,
		_ssl_enabled
	)


func set_light_effect(light_id: int = 1, effect: String = "colorloop", brightness: int = 254, on: bool = true) -> void:
	_bridge.http_put(
		"%sapi/%s/lights/%s/state" % [
			_url_base, 
			_username, 
			light_id
		],
		{
			"on": on,
			"bri": brightness,
			"effect": effect,
		},
		_headers,
		_ssl_enabled
	)


func get_group(group_id: int = 1) -> void:
	_bridge.http_get(
		"%sapi/%s/groups/%s" % [
			_url_base, 
			_username,
			group_id
		],
		_headers,
		_ssl_enabled
	)


func set_group(group_id: int = 1, settings: Dictionary = {}) -> void:
	_bridge.http_put(
		"%sapi/%s/groups/%s/action" % [
			_url_base, 
			_username, 
			group_id
		],
		settings,
		_headers,
		_ssl_enabled
	)


func set_group_alert(group_id: int = 1, alert: String = "select", on: bool = true) -> void:
	_bridge.http_put(
		"%sapi/%s/groups/%s/action" % [
			_url_base, 
			_username, 
			group_id
		],
		{
			"on": on,
			"alert": alert,
		},
		_headers,
		_ssl_enabled
	)


func set_group_color(group_id: int = 1, color: Color = Color.floralwhite, brightness: int = 254, on: bool = true) -> void:
	_bridge.http_put(
		"%sapi/%s/groups/%s/action" % [
			_url_base, 
			_username, 
			group_id
		],
		{
			"on": on,
			"bri": brightness,
			"xy": get_rgb_to_xy(color)
		},
		_headers,
		_ssl_enabled
	)


func set_group_effect(group_id: int = 1, effect: String = "colorloop", brightness: int = 254, on: bool = true) -> void:
	_bridge.http_put(
		"%sapi/%s/groups/%s/action" % [
			_url_base, 
			_username, 
			group_id
		],
		{
			"on": on,
			"bri": brightness,
			"effect": effect,
		},
		_headers,
		_ssl_enabled
	)


# Convert RGB color to X,Y coordinates of a colorwheel
# Credit: https://stackoverflow.com/a/22649803/1772200
func get_rgb_to_xy(color: Color) -> Array:
	# For the hue bulb the corners of the triangle are:
	# -Red: 0.675, 0.322
	# -Green: 0.4091, 0.518
	# -Blue: 0.167, 0.04
	var red: float
	var green: float
	var blue: float

	# Make red more vivid
	if (color.r > 0.04045):
		red = pow((color.r + 0.055) / (1.0 + 0.055), 2.4)
	else:
		red = (color.r / 12.92)

	# Make green more vivid
	if (color.g > 0.04045):
		green = pow((color.g + 0.055) / (1.0 + 0.055), 2.4)
	else:
		green = (color.g / 12.92)
	
	# Make blue more vivid
	if (color.b > 0.04045):
		blue = pow((color.b + 0.055) / (1.0 + 0.055), 2.4)
	else:
		blue = (color.b / 12.92)
	
	var X: float = (red * 0.649926 + green * 0.103455 + blue * 0.197109)
	var Y: float = (red * 0.234327 + green * 0.743075 + blue * 0.022598)
	var Z: float = (red * 0.0000000 + green * 0.053077 + blue * 1.035763)

	var x: float = X / (X + Y + Z)
	var y: float = Y / (X + Y + Z)

	return [x, y]
