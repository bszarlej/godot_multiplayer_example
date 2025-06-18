extends Control


func _on_host_button_pressed() -> void:
	if NetworkManager.host_game():
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_join_button_pressed() -> void:
	if await NetworkManager.join_game("127.0.0.1"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
