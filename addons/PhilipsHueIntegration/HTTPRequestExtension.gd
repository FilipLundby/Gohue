extends HTTPRequest

class_name HTTPRequestExtension


func _request(url: String, data_to_send: Dictionary, method=HTTPClient.METHOD_PUT, headers:Array=["Content-Type: application/json"], use_ssl:bool=false) -> void:
	# Remove line breaks and strip spaces from start or end of URL
	url = url.replace("\n", "").strip_edges()
	# Ensure URL starts with 'http'
	if !url.begins_with("http"): 
		printerr("URL must start with 'http', ", url)
		return 
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	var request_status = request(url, headers, use_ssl, method, query)	
#	if _debug: print_debug("Request to ", url, " ... ",  HueUtils.get_error_message(request_status))


func http_post(url, data_to_send: Dictionary, headers:Array=["Content-Type: application/json"], use_ssl:bool=false) -> void:
	_request(url, data_to_send, HTTPClient.METHOD_POST, headers, use_ssl)


func http_put(url, data_to_send: Dictionary, headers:Array=["Content-Type: application/json"], use_ssl:bool=false) -> void:
	_request(url, data_to_send, HTTPClient.METHOD_PUT, headers, use_ssl)


func http_get(url, headers:Array=["Content-Type: application/json"], use_ssl:bool=false) -> void:
	_request(url, {}, HTTPClient.METHOD_GET, headers, use_ssl)


func http_delete(url, headers:Array=["Content-Type: application/json"], use_ssl:bool=false) -> void:
	_request(url, {}, HTTPClient.METHOD_DELETE, headers, use_ssl)
