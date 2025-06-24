extends Control

@onready var dialog: Dialog = $Dialog
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
		Global.server_disconnected = false
		_show_dialog(
			"Disconnected",
			"The connection to the server was lost unexpectedly. Please try reconnecting.",
			true
		)

func _on_connected_to_server() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_server_disconnected() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_connection_failed() -> void:
	_show_dialog(
		"Connection Failed",
		"Unable to connect to the server. Please check the IP address and your network connection.",
		true
	)

func _on_connection_timer_timeout() -> void:
	var connection_status = NetworkManager.peer.get_connection_status()
	if connection_status != ENetMultiplayerPeer.CONNECTION_CONNECTED:
		multiplayer.connection_failed.emit()

func _on_host_button_pressed() -> void:
	if NetworkManager.host_game():
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		_show_dialog(
			"Server Host Error",
			"Failed to start the server. Please ensure that port %s is not in use by another application, or try a different port." % NetworkManager.port,
			true
		)

func _on_join_button_pressed() -> void:
	NetworkManager.join_game()
	connection_timer.start()
	_show_dialog(
		"Connecting...",
		"Attempting to connect to server at %s:%s.\nPlease wait..." % [NetworkManager.ip_address, NetworkManager.port],
		false
	)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_username_edit_text_changed(new_text: String) -> void:
	Global.username = new_text

func _on_ip_address_edit_text_changed(new_text: String) -> void:
	NetworkManager.ip_address = new_text if not new_text.is_empty() else "127.0.0.1"

func _show_dialog(title: String, content: String, show_actions: bool) -> void:
	dialog.title = title
	dialog.content = content
	dialog.actions_visible = show_actions
	dialog.show()
