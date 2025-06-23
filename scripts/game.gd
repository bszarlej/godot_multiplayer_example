class_name Game
extends Node2D

@onready var message_container: VBoxContainer = $UiLayer/MessageContainer
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner

var player_scene: PackedScene = preload("res://scenes/player.tscn")

var self_disconnect = false

func _ready() -> void:
	player_spawner.set_spawn_function(player_spawn_function)
	if multiplayer.is_server(): player_spawner.spawn(1)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
 
func player_spawn_function(peer_id: int):
	var player = player_scene.instantiate()
	player.set_name(str(peer_id))
	player.set_multiplayer_authority(peer_id)
	return player

# Server and Clients
func _on_peer_connected(peer_id: int) -> void:
	player_spawner.spawn(peer_id)

# Server and Clients
func _on_peer_disconnected(peer_id: int) -> void:
	var player = get_node_or_null("Players/%s" % peer_id)
	if not player: return
	send_chat_message("%s has left the game." % player.username, Color.DARK_RED)
	player.queue_free()

# Clients only
func _on_server_disconnected() -> void:
	Global.server_disconnected = !self_disconnect
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
@rpc("any_peer", "call_local", "reliable")
func recieve_user_information(username: String) -> void:
	send_chat_message("%s has joined the game." % username, Color.FOREST_GREEN)

func send_chat_message(message: String, color := Color("#242424")):
	var chat_message := Label.new()
	chat_message.text = message
	chat_message.add_theme_color_override('font_color', color)
	message_container.add_child(chat_message)
	await get_tree().create_timer(5).timeout
	if not chat_message: return
	var tween = create_tween()
	tween.tween_property(chat_message, "modulate:a", 0.0, 0.8)
	tween.tween_callback(chat_message.queue_free)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		self_disconnect = true
		multiplayer.multiplayer_peer.close()
