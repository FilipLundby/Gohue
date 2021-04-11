extends HueBridgeApi

export(NodePath) var _hue_discovery_path: NodePath = "../HueBridgeDiscovery"


func _ready() -> void:
	if !_hue_discovery_path.is_empty():
		var hue_discovery: HueBridgeDiscovery = get_node(_hue_discovery_path)
# warning-ignore:return_value_discarded
		hue_discovery.connect("discover_succeded", self, "_on_discover_succeded")
	
# warning-ignore:return_value_discarded
	self.connect("request_completed", self, "_on_request_completed")

	var url: String = HueUtils.load("hue_url.dat")
	if len(url): self.url_base = url
	
	var user: String = HueUtils.load("hue_username.dat")
	if len(user): self.username = user


func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_C:
		# The API will responed with a username - a random generated string.
		self.create_user("raspberry_pi#godotter")
		# To delete a user you must log in to MeetHue - it's not possible delete
		# user through the API. Login at https://account.meethue.com/apps


func _on_request_completed(_result, _response_code, _headers, body) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result != null:
		var response = json.result[0]
		if "success" in response and "username" in response.success:
			var username = response.success.username
			HueUtils.save("hue_username.dat", username)
			print_debug("Success! User '%s' created" % username)
		if "error" in response:
			if response.error.type == 101:
				print_debug("You must push the button on the Hue Bridge, before creating the user.")


func _on_discover_succeded(url_base) -> void:
	self.url_base = url_base
