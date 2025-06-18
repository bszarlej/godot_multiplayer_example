extends Node2D

var player_scene: PackedScene = preload("res://scenes/player.tscn")

func _ready() -> void:
	spawn_player(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(despawn_player)

func spawn_player(id: int):
	print("Player %s connected" % id)
	var player = player_scene.instantiate()
	player.set_name(str(id))
	player.set_multiplayer_authority(id)
	$Players.add_child(player)

func despawn_player(id: int):
	var player = get_node_or_null(str(id))
	if not player: return
	print("Player %s disconnected" % id)
	player.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		multiplayer.multiplayer_peer.close()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
