# Godot integration to Philips Hue 

* [Getting Started](#getting_started)
* [Hue Bridge Discovery](#hue_bridge_discovery)
* [API Reference](#api_reference)
* [Bugs](#bugs)
* [License](#license)


<a name="getting_started"></a>
## Getting started

In Godot add a new node of the type `HTTPRequest`. Attach a script to the node and paste 
in the below code. 

You will need the IP of your Hue Bridge. One way to to find the IP is through the Philips 
Hue mobile app. In the app go to _Settings_ > _Hue Bridges_, then open info screen 
(by touching the 'i') for the desired bridge. 

You can also retrieve the IP (base URL) automatically. See [Hue Bridge discovery](#hue_bridge_discovery).

```gdscript
extends HueBridgeApi

func _ready() -> void:
	self.url_base = "http://<YOUR-BRIDGE-IP>/" # Must start with 'http://' and end with '/'
	self.connect("request_completed", self, "_on_request_completed")

func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_SPACE:
		self.set_light_alert(1)

func _on_request_completed(_result, _response_code, _headers, body) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result != null:
		var json_str: String = JSON.print(json.result, "    ")
		print(json_str)
```

When you run the game and hit spacebar, you will probably get an error, saying "unauthorized user". Let's fix that.

We need to create a new user. Add another if-statement in the function that user input: 

```gdscript
func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_SPACE:
		self.set_light_alert(1)
	if event.scancode == KEY_C:
		self.create_user("raspberry_pi#godotter")
```

Start the game again. Now if you hit C on your keyboard, you'll get another error, "link button not pressed". This is a 
security measure. The only thing you have to do is to push the button on the Hue Bridge. Now try hitting C again. 

The bridge should now respond with a success message, which also includes your generated username (a string of 
random characters). Let's copy the username into our script - so we don't have to create a new user every time we run 
the game (that would be stupid :stuck_out_tongue_closed_eyes:). 

The full script looks like this: 

```gdscript
extends HueBridgeApi

func _ready() -> void:
	self.url_base = "http://<YOUR-BRIDGE-IP>/" # Must start with 'http://' and end with '/'
	self.connect("request_completed", self, "_on_request_completed")

	var user: String = HueUtils.load("hue_username.dat")
	if len(user): self.username = user

func _unhandled_key_input(event: InputEventKey) -> void:
	if !event.pressed: return
	if event.scancode == KEY_SPACE:
		self.set_light_alert(1)
	if event.scancode == KEY_C:
		self.create_user("raspberry_pi#godotter")

func _on_request_completed(_result, _response_code, _headers, body) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result != null:
		var json_str: String = JSON.print(json.result, "    ")
		print(json_str)
		var response = json.result[0]
		if "success" in response and "username" in response.success:
			var username = response.success.username
			HueUtils.save("hue_username.dat", username)
```

When you hit spacebar, you should see your primary light blink once :sunglasses:




<a name="hue_bridge_discovery"></a>
## Hue Bridge Discovery

Hardcoding the bridge IP might work, but you have no chance of knowing the IP when your game is 
installed on somebody else's computer. Instead we can lookup the IP automatically. 

Start by adding a new node of the type `HTTPRequest` and paste in the following code:

```gdscript
extends HueBridgeDiscovery

func _ready() -> void:
	# Load URL
	var url: String = HueUtils.load("hue_url.dat")
	# Don't try to discover Hue Bridge, if URL was specified
	if !len(url) or !url.begins_with("http"):
		print("Looking for Hue Bridge. Please wait ...") 
		self.start()

	self.connect("discover_succeded", self, "_on_discover_succeded")

func _on_discover_succeded(url_base) -> void:
	print("Success! Connected to %s" % url_base)
	HueUtils.save("hue_url.dat", url_base)
```

What's going on? First we try to load the base URL from file. If it's empty or doesn't exist, the discovery 
starts. Be aware it might take up to 1 min, but when finished, you should see the success message. Finally
the base URL is saved, this way we don't need to start the discovery the next time the game is loaded. 

Now we can update our script from the [Getting Started](#getting_started): 

```gdscript
extends HueBridgeApi

func _ready() -> void:
	# self.url_base = "http://<YOUR-BRIDGE-IP>/" # Must start with 'http://' and end with '/'
	self.connect("request_completed", self, "_on_request_completed")

	$HueBridgeDiscovery.connect("discover_succeded", self, "_on_discover_succeded")

	var url: String = HueUtils.load("hue_url.dat")
	if len(url): self.url_base = url
	
	var user: String = HueUtils.load("hue_username.dat")
	if len(user): self.username = user

func _on_discover_succeded(url_base):
	self.url_base = url_base

func _on_request_completed(_result, _response_code, _headers, body) -> void:
	# Same as before ...
```





<a name="api_reference"></a>
## API Reference

### Create user

```gdscript
self.create_user("raspberry_pi#godotter")
```

### Manage a light

```gdscript
self.set_light(1, { "on": true })
self.set_light_color(1, Color(1, 0, 0), 120, true)
self.set_light_effect(1, "colorloop")                 # Built-in effect. Can be either "colorloop" or "none"
self.set_light_alert(1, "select")                     # Built-in alert. Can be either "select" or "lselect"
```

### Set light state directly

```gdscript
self.set_light(1, { 
	"on": true,
	"xy": HueUtils.get_rgb_to_xy(Color(0, 1, 0))
})
```


### Manage a group

```gdscript
self.set_group(1, { "on": true })
self.set_group_color(1, Color(1, 0, 0), 120, true)
self.set_group_effect(1, "colorloop")                 # Built-in effect. Can be either "colorloop" or "none"
self.set_group_alert(1, "select")                     # Built-in alert. Can be either "select" or "lselect"
```

### Set group state directly

```gdscript
self.set_group(1, { 
	"on": true,
	"xy": HueUtils.get_rgb_to_xy(Color(0, 1, 0))
})
```

### Get info

```gdscript
self.get_data()     # Get all available data
self.get_config()   # Get config data only
self.get_light(1)   # Get data related to light #1
self.get_group(1)   # Get data related to group #1
```



<a name="bugs"></a>
## Bugs

Found an issue? [Please let me know](https://twitter.com/messages/compose?recipient_id=259365053).


<a name="license"></a>
## MIT License

Copyright (c) 2021 Filip Lundby

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
