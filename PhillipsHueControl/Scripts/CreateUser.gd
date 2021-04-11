extends Node

onready var _hue_api: HueBridgeApi = get_parent()


func _ready():
# warning-ignore:return_value_discarded
	_hue_api.connect("request_completed", self, "_on_request_completed")


func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_C:
		# The API will responed with a username - a random generated string.
		_hue_api.create_user("raspberry_pi#godotter1")
		# To delete a user you must log in to MeetHue - it's not possible delete
		# user through the API. Login at https://account.meethue.com/apps


func _on_request_completed(_result, _response_code, _headers, body) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result != null:
		var response = json.result[0]
		if "success" in response and "username" in response.success:
			var username = response.success.username
			HueUtils.save("hue_username.dat", username)
			print("Success! User '%s' created" % username)
		if "error" in response:
			if response.error.type == 101:
				print("You must push the button on the Hue Bridge, before creating the user.")



