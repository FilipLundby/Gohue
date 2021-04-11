class_name HueUtils


static func save(filename: String = "hue_data.dat", content: String = "") -> void:
	var file = File.new()
	var filepath = "user://%s" % filename
	file.open(filepath, File.WRITE)
	file.store_string(content)
	file.close()


static func load(filename: String = "hue_data.dat") -> String:
	var file = File.new()
	var filepath = "user://%s" % filename
	if !file.file_exists(filepath): return ""
	file.open(filepath, File.READ)
	var content = file.get_as_text()
	file.close()
	return content


# Convert RGB color to X,Y coordinates of a colorwheel
# Credit: https://stackoverflow.com/a/22649803/1772200
static func get_rgb_to_xy(color: Color) -> Array:
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


static func get_error_message(error_id: int):
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
	return status_code[error_id]
