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

