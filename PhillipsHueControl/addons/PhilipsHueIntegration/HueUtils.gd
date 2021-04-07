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

