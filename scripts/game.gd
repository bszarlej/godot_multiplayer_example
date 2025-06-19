extends Node2D

@onready var message_container: VBoxContainer = $UiLayer/MessageContainer

var player_scene: PackedScene = preload("res://scenes/player.tscn")


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Spawn the local player
	var player = spawn_player(multiplayer.get_unique_id())
	
	if multiplayer.is_server():
		display_join_message(multiplayer.get_unique_id())


func _on_peer_connected(peer: int) -> void:
	spawn_player(peer)
	if multiplayer.is_server():
		display_join_message.rpc_id(0, peer)
	

func _on_peer_disconnected(peer: int) -> void:
	despawn_player(peer)
	if multiplayer.is_server():
		display_disconnect_message.rpc_id(0, peer)


func spawn_player(peer: int):
	var player = player_scene.instantiate()
	player.set_name(str(peer))
	player.set_multiplayer_authority(peer)
	$Players.add_child(player)


func despawn_player(peer: int):
	var player = get_node_or_null("Players/%s" % peer)
	if not player: return
	player.queue_free()


@rpc("any_peer", "call_local")
func display_join_message(peer: int) -> void:
	display_message("Player %s has joined the game!" % peer)


@rpc("any_peer", "call_local")
func display_disconnect_message(peer: int) -> void:
	display_message("Player %s has left the game!" % peer)


func display_message(message: String):
	var label := Label.new()
	label.text = message
	label.add_theme_color_override('font_color', Color.FOREST_GREEN)
	message_container.add_child(label)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		message_container.queue_free()
		multiplayer.multiplayer_peer.close()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _check_message_limit(node: Node):
	if message_container.get_child_count() > 5:
		var excess_count = message_container.get_child_count() - 5
		var excess_items = message_container.get_children().slice(0, excess_count)
		_fade_and_remove(excess_items)
 

func _fade_and_remove(items: Array[Node]):
	var tween = get_tree().create_tween()
	for item in items:
		tween.parallel().tween_property(item, "modulate:a", 0.5, 0.8)
		tween.finished.connect(item.queue_free)
