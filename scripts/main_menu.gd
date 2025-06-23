extends Control

@onready var accept_dialog: AcceptDialog = $AcceptDialog

var connection_timer := Timer.new()

func _ready() -> void:
	$UsernameEdit.text = Global.username
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	connection_timer.wait_time = 5
	connection_timer.one_shot = true
	connection_timer.connect("timeout", _on_connection_timer_timeout)
	add_child(connection_timer)
	
	if Global.server_disconnected:
		accept_dialog.title = "Disconnected"
		accept_dialog.dialog_text = "The connection to the server was lost."
		accept_dialog.popup()
		Global.server_disconnected = false
	
func _on_connected_to_server() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
func _on_server_disconnected() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	accept_dialog.title = "Disconnected"
	accept_dialog.dialog_text = "The connection to the server was lost.\nPlease try reconnecting."
	accept_dialog.popup()
	
func _on_connection_failed() -> void:
	accept_dialog.title = "Connection Failed"
	accept_dialog.dialog_text = "Unable to connect to the server at:\n%s:%s\n
	Please check the IP address and ensure the server is running." % \
	[NetworkManager.ip_address, NetworkManager.port]
	accept_dialog.popup()
	
func _on_connection_timer_timeout() -> void:
	var connection_status = NetworkManager.peer.get_connection_status()
	if connection_status != ENetMultiplayerPeer.CONNECTION_CONNECTED:
		multiplayer.connection_failed.emit()

func _on_host_button_pressed() -> void:
	if NetworkManager.host_game():
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		accept_dialog.title = "Failed to Host Server"
		accept_dialog.dialog_text = "Could not start the server.\n
		Please make sure that the port %s is not in use by any other program." \
		% NetworkManager.port
		accept_dialog.popup()


func _on_join_button_pressed() -> void:
	NetworkManager.join_game()
	connection_timer.start()
	accept_dialog.title = "Connecting..."
	accept_dialog.dialog_text = "Attempting to connect to server at:\n%s:%s" \
	% [NetworkManager.ip_address, NetworkManager.port]
	accept_dialog.popup()
	
func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_username_edit_text_changed(new_text: String) -> void:
	Global.username = new_text

func _on_ip_address_edit_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		NetworkManager.ip_address = "127.0.0.1"
	else:	
		NetworkManager.ip_address = new_text
