extends HTTPRequestExtension

class_name HueBridgeApi


export(String) var url_base: String setget set_url_base, get_url_base
export(String) var username: String setget set_username, get_username
export(bool) var ssl: bool = false setget set_ssl, get_ssl

var _headers: Array = ["Content-Type: application/json"]


func get_ssl():
	return ssl

func set_ssl(value):
	ssl = value

func get_url_base():
	return url_base

func set_url_base(value):
	url_base = value

func get_username():
	return username

func set_username(value):
	username = value


func create_user(devicetype: String) -> void:
	http_post(
		"%sapi" % [
			url_base,
		],
		{ 
			"devicetype": devicetype 
		},
		_headers,
		ssl
	)


# Deleting users through the API is obsolete. Source: 
# https://developers.meethue.com/hue-whitelist-security-update/ 
func delete_user(user: String) -> void:
	http_delete(
		"%sapi/%s/config/whitelist/%s" % [
			url_base,
			username,	# Authenticated user
			user	# User to delete
		],
		_headers,
		ssl
	)


func get_config() -> void:
	http_get(
		"%sapi/%s/config" % [
			url_base,
			username
		],
		_headers,
		ssl
	)


# Get all available data
func get_data() -> void:
	 http_get(
		"%sapi/%s" % [
			url_base, 
			username
		],
		_headers,
		ssl
	)


func get_light(light_id: int = 1) -> void:
	http_get(
		"%sapi/%s/lights/%s" % [
			url_base, 
			username,
			light_id
		],
		_headers,
		ssl
	)


func set_light(light_id: int = 1, settings: Dictionary = {}) -> void:
	http_put(
		"%sapi/%s/lights/%s/state" % [
			url_base, 
			username, 
			light_id
		],
		settings,
		_headers,
		ssl
	)


func set_light_alert(light_id: int = 1, alert: String = "select", on: bool = true) -> void:
	http_put(
		"%sapi/%s/lights/%s/state" % [
			url_base, 
			username, 
			light_id
		],
		{
			"on": on,
			"alert": alert,
		},
		_headers,
		ssl
	)


func set_light_color(light_id: int = 1, color: Color = Color.floralwhite, brightness: int = 254, on: bool = true) -> void:
	http_put(
		"%sapi/%s/lights/%s/state" % [
			url_base, 
			username, 
			light_id
		],
		{
			"on": on,
			"bri": brightness,
			"xy": HueUtils.get_rgb_to_xy(color)
		},
		_headers,
		ssl
	)


func set_light_effect(light_id: int = 1, effect: String = "colorloop", brightness: int = 254, on: bool = true) -> void:
	http_put(
		"%sapi/%s/lights/%s/state" % [
			url_base, 
			username, 
			light_id
		],
		{
			"on": on,
			"bri": brightness,
			"effect": effect,
		},
		_headers,
		ssl
	)


func get_group(group_id: int = 1) -> void:
	http_get(
		"%sapi/%s/groups/%s" % [
			url_base, 
			username,
			group_id
		],
		_headers,
		ssl
	)


func set_group(group_id: int = 1, settings: Dictionary = {}) -> void:
	http_put(
		"%sapi/%s/groups/%s/action" % [
			url_base, 
			username, 
			group_id
		],
		settings,
		_headers,
		ssl
	)


func set_group_alert(group_id: int = 1, alert: String = "select", on: bool = true) -> void:
	http_put(
		"%sapi/%s/groups/%s/action" % [
			url_base, 
			username, 
			group_id
		],
		{
			"on": on,
			"alert": alert,
		},
		_headers,
		ssl
	)


func set_group_color(group_id: int = 1, color: Color = Color.floralwhite, brightness: int = 254, on: bool = true) -> void:
	http_put(
		"%sapi/%s/groups/%s/action" % [
			url_base, 
			username, 
			group_id
		],
		{
			"on": on,
			"bri": brightness,
			"xy": HueUtils.get_rgb_to_xy(color)
		},
		_headers,
		ssl
	)


func set_group_effect(group_id: int = 1, effect: String = "colorloop", brightness: int = 254, on: bool = true) -> void:
	http_put(
		"%sapi/%s/groups/%s/action" % [
			url_base, 
			username, 
			group_id
		],
		{
			"on": on,
			"bri": brightness,
			"effect": effect,
		},
		_headers,
		ssl
	)
