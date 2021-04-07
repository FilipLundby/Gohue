extends HTTPRequest

class_name HueBridgeDiscovery

signal bridge_discover_status
signal bridge_discover_succeded
signal bridge_request_completed

export(int) var _max_attempts: int = 3
export(bool) var ssl: bool = false setget ,get_ssl
# These are the recommended values from the Philips 
# Hue API documentation. You shouldn't need to change
# any of them. 
export(String) var _model_name: String = "philips hue bridge"
export(String) var _broadcast_ip: String = "239.255.255.250"
export(int) var _broadcast_port: int = 1900
export(bool) var _debug: bool = true

var url_base: String setget ,get_url_base
var username: String = "ZraN4DSWTclqGJOhz2USpG7aubIB2WEoKlsHuLMZ" setget ,get_username

func get_ssl():
	return ssl

func get_url_base():
	return url_base

func get_username():
	return username

var udp: PacketPeerUDP
enum _states {
	DISCOVERING,
	HOST_FOUND,
	RETRY,
	VALIDATING,
	CONNECTED,
	FAILED
}
var _state
var _attempt: int = 0


func _ready():
# warning-ignore:return_value_discarded
	connect("request_completed", self, "_on_request_completed")


func start(url: String = "", user: String = ""):
	# Don't try to discover Hue Bridge, if url_base was specified
	if len(url):
		url_base = url
		_state = _states.CONNECTED
		return
	# Reset
	_attempt = 0
	_state = _states.DISCOVERING
	udp = PacketPeerUDP.new()
	emit_signal("bridge_discover_status", _state)
	# Send package
	var set_address_status = udp.set_dest_address(_broadcast_ip, _broadcast_port)
	if _debug: print_debug("Set address ... ", status_code[set_address_status])
	# Alright stop, collaborate and listen 
	var interface = _get_valid_interface()
	if len(interface):
		var listen_status = udp.listen(_broadcast_port)
		if _debug: print_debug("Listening ... ", status_code[listen_status])
		var multicast_status = udp.join_multicast_group(_broadcast_ip, interface.name)
		if _debug: print_debug("Multicast ... ", status_code[multicast_status])


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
	if _state == _states.FAILED: return
	
	if (_state == _states.DISCOVERING or 
		_state == _states.RETRY):
		# Try to contact server
# warning-ignore:return_value_discarded
		udp.put_packet("...".to_ascii())

	if (_state != _states.VALIDATING and 
		_state != _states.CONNECTED and 
		udp.get_available_packet_count() > 0):
		# Determine whether response is from Hue Bridge
		_state = _states.HOST_FOUND
		var response: String = udp.get_packet().get_string_from_utf8()
#		if _debug: print_debug("Found bridge ...")
		var location = _get_header_property(response, "location")
		if len(location) > 0:
			_state = _states.VALIDATING
			if _debug: print_debug("Validating bridge at ", location)
			http_get(location, ["Content-Type: application/xml"])
			emit_signal("bridge_discover_status", _state)


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var is_json: bool = "Content-Type: application/json" in headers
	# If headers returns JSON - it's probably 
	# an API reponse, therefore the signal is forwarded
	if is_json: 
		emit_signal("bridge_request_completed", result, response_code, headers, body)
		return

	# If headers returns XML - it's probably
	# bridge broadcast response. Look at the data
	# to see if it contains the model name ("philips hue bridge") 
	var is_xml: bool = "Content-Type: text/xml" in headers
	var xml: String = body.get_string_from_utf8()
	var model_name: String = _get_xml_property(xml, "modelName")
	if is_xml and _model_name in model_name.to_lower():
		# If model name was found - keep it! 
		_state = _states.CONNECTED
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
			_state = _states.FAILED
			if _debug: print_debug("Connection failed.")
			emit_signal("bridge_discover_status", _state)
		else:
			_state = _states.RETRY
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


func _request(url: String, data_to_send: Dictionary, method=HTTPClient.METHOD_PUT, headers:Array=["Content-Type: application/json"], use_ssl:bool=false) -> void:
	if !url.begins_with("http"): 
		printerr("Could not send request to Hue Bridge. Maybe it's not ready yet.")
		return 
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	var request_status = request(url, headers, use_ssl, method, query)	
	if _debug: print_debug("Request to ", url, " ... ", status_code[request_status])


func http_post(url, data_to_send: Dictionary, headers:Array=["Content-Type: application/json"], use_ssl:bool=false) -> void:
	_request(url, data_to_send, HTTPClient.METHOD_POST, headers, use_ssl)


func http_put(url, data_to_send: Dictionary, headers:Array=["Content-Type: application/json"], use_ssl:bool=false) -> void:
	_request(url, data_to_send, HTTPClient.METHOD_PUT, headers, use_ssl)


func http_get(url, headers:Array=["Content-Type: application/json"], use_ssl:bool=false) -> void:
	_request(url, {}, HTTPClient.METHOD_GET, headers, use_ssl)


func http_delete(url, headers:Array=["Content-Type: application/json"], use_ssl:bool=false) -> void:
	_request(url, {}, HTTPClient.METHOD_DELETE, headers, use_ssl)


var status_code: Array = [
	"OK",
	"Generic error.",
	"Unavailable error.",
	"Unconfigured error.",
	"Unauthorized error.",
	"Parameter range error.",
	"Out of memory (OOM) error.",
	"File: Not found error.",
	"File: Bad drive error.",
	"File: Bad path error.",
	"File: No permission error.",
	"File: Already in use error.",
	"File: Can't open error.",
	"File: Can't write error.",
	"File: Can't read error.",
	"File: Unrecognized error.",
	"File: Corrupt error.",
	"File: Missing dependencies error.",
	"File: End of file (EOF) error.",
	"Can't open error.",
	"Can't create error.",
	"Query failed error.",
	"Already in use error.",
	"Locked error.",
	"Timeout error.",
	"Can't connect error.",
	"Can't resolve error.",
	"Connection error.",
	"Can't acquire resource error.",
	"Can't fork process error.",
	"Invalid data error.",
	"Invalid parameter error.",
	"Already exists error.",
	"Does not exist error.",
	"Database: Read error.",
	"Database: Write error.",
	"Compilation failed error.",
	"Method not found error.",
	"Linking failed error.",
	"Script failed error.",
	"Cycling link (import cycle) error.",
	"Invalid declaration error.",
	"Duplicate symbol error.",
	"Parse error.",
	"Busy error.",
	"Skip error.",
	"Help error.",
	"Bug error.",
	"Printer on fire error.", # (This is an easter egg, no engine methods return this error code.)
]
