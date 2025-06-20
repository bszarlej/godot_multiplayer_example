extends Node2D

@onready var message_container: VBoxContainer = $UiLayer/MessageContainer
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner

var player_scene: PackedScene = preload("res://scenes/player.tscn")

func _ready() -> void:
	player_spawner.set_spawn_function(player_spawner_function)
	if multiplayer.is_server(): player_spawner.spawn(1)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(get_tree().change_scene_to_file.bind("res://scenes/main_menu.tscn"))
 
func player_spawner_function(peer_id: int):
	var player = player_scene.instantiate()
	player.set_name(str(peer_id))
	player.set_multiplayer_authority(peer_id)
	return player

func _on_peer_connected(peer_id: int) -> void:
	var player = player_spawner.spawn(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	var player = get_node_or_null("Players/%s" % peer_id)
	if not player: return
	player.queue_free()
	if multiplayer and multiplayer.is_server():
		display_disconnect_message.rpc_id(0, player.username)

@rpc("reliable", "call_local")
func display_join_message(username: String) -> void:
	display_message("%s has joined the game!" % username, Color.FOREST_GREEN)

@rpc("reliable", "call_local")
func display_disconnect_message(username: String) -> void:
	display_message("%s has left the game!" % username, Color.DARK_RED)
	
@rpc("any_peer", "reliable")
func receive_player_username(peer_id: int, username: String):
	if not multiplayer or not multiplayer.is_server(): return
	var player = get_node_or_null("Players/%s" % peer_id)
	if player:
		player.username = username
		display_join_message.rpc_id(0, username)

func display_message(message: String, color: Color):
	var label := Label.new()
	label.text = message
	label.add_theme_color_override('font_color', color)
	message_container.add_child(label)
	await get_tree().create_timer(5).timeout
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		if multiplayer.is_server():
			for peer in multiplayer.get_peers():
				multiplayer.multiplayer_peer.disconnect_peer(peer)
		multiplayer.multiplayer_peer.close()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
