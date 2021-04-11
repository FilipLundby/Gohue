#	MIT License
#
#	Copyright (c) 2021 Filip Lundby
#
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be included in all
#	copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#	SOFTWARE.

extends HTTPRequestExtension

class_name HueBridgeDiscovery

signal discover_status
signal discover_succeded

export(int) var _max_attempts: int = 3
export(bool) var ssl: bool = false setget ,get_ssl
# These are the recommended values from the Philips 
# Hue API documentation. You shouldn't need to change
# any of them. 
export(String) var _model_name: String = "philips hue bridge"
export(String) var _broadcast_ip: String = "239.255.255.250"
export(int) var _broadcast_port: int = 1900
export(bool) var _debug: bool = false

var url_base: String setget ,get_url_base

func get_ssl():
	return ssl

func get_url_base():
	return url_base

var _udp: PacketPeerUDP
var _state: int
var _attempt: int = 0


func _ready():
# warning-ignore:return_value_discarded
	connect("request_completed", self, "_on_request_completed")


func start():
	# Reset
	_attempt = 0
	_state = DiscoveryState.states.DISCOVERING
	_udp = PacketPeerUDP.new()
	emit_signal("bridge_discover_status", _state)
	# Send package
	var set_address_status = _udp.set_dest_address(_broadcast_ip, _broadcast_port)
	if _debug: print_debug("Set address ... ", HueUtils.get_error_message(set_address_status)) 
	# Alright stop, collaborate and listen 
	var interface = _get_valid_interface()
	if len(interface):
		var listen_status = _udp.listen(_broadcast_port)
		if _debug: print_debug("Listening ... ",  HueUtils.get_error_message(listen_status))
		var multicast_status = _udp.join_multicast_group(_broadcast_ip, interface.name)
		if _debug: print_debug("Multicast ... ",  HueUtils.get_error_message(multicast_status))


func _get_valid_interface() -> Array:
	for interface in IP.get_local_interfaces():
		var ip = interface.addresses[0]
		var regex = RegEx.new()
		# Look for local IP addresses starting with "10.", "172." or "192.168."
		regex.compile("(^10\\.)|(^172\\.1[6-9]\\.)|(^172\\.2[0-9]\\.)|(^172\\.3[0-1]\\.)|(^192\\.168\\.)")
		var result = regex.search(ip)
		if result:
			return interface
	return []


func _process(_delta):
	if _state == DiscoveryState.states.FAILED or _udp == null: return
	
	if (_state == DiscoveryState.states.DISCOVERING or 
		_state == DiscoveryState.states.RETRY):
		# Try to contact server
# warning-ignore:return_value_discarded
		_udp.put_packet("...".to_ascii())

	if (_state != DiscoveryState.states.VALIDATING and 
		_state != DiscoveryState.states.CONNECTED and 
		_udp.get_available_packet_count() > 0):
		# Determine whether response is from Hue Bridge
		_state = DiscoveryState.states.HOST_FOUND
		var response: String = _udp.get_packet().get_string_from_utf8()
#		if _debug: print_debug("Found bridge ...")
		var location = _get_header_property(response, "location")
		if len(location) > 0:
			_state = DiscoveryState.states.VALIDATING
			if _debug: print_debug("Validating bridge at ", location)
			http_get(location, ["Content-Type: application/xml"])
			emit_signal("bridge_discover_status", _state)


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	# If headers returns XML - it's probably
	# bridge broadcast response. Look at the data
	# to see if it contains the model name ("philips hue bridge") 
	var is_xml: bool = "Content-Type: text/xml" in headers
	var xml: String = body.get_string_from_utf8()
	var model_name: String = _get_xml_property(xml, "modelName")
	if is_xml and _model_name in model_name.to_lower():
		# If model name was found - keep it! 
		_state = DiscoveryState.states.CONNECTED
		url_base = _get_xml_property(xml, "URLBase")
		if ssl:
			url_base = url_base.replace("http:", "https:")
		else:
			url_base = url_base.replace("https:", "http:")
		if _debug: print_debug("Connected to ", url_base)
		emit_signal("bridge_discover_succeded", url_base)
	else:
		_attempt += 1
		if _attempt >= _max_attempts:
			_state = DiscoveryState.states.FAILED
			if _debug: print_debug("Connection failed.")
			emit_signal("bridge_discover_status", _state)
		else:
			_state = DiscoveryState.states.RETRY
			if _debug: print_debug("Retrying. Attempt #", _attempt, " ...")
			emit_signal("bridge_discover_status", _state)


func _get_xml_property(xml: String, key: String) -> String:
	var regex = RegEx.new()
	regex.compile("<%s>([\\s\\S]*?)<\/%s>" % [key, key])
	var result = regex.search(xml)
	if result and result.get_group_count():
		return result.get_string(1)
	return ""


func _get_header_property(haystack: String, key: String) -> String:
	key = key.to_lower()
	for line in haystack.split("\n"):
		if line.to_lower().begins_with(key):
			var colon_position: int = line.find(":")
			if colon_position != -1:
				return line.substr( colon_position + 1 ).strip_edges()
	return ""

