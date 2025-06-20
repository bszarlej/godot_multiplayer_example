extends Control

func _ready() -> void:
	$UsernameEdit.text = Global.username

func _on_host_button_pressed() -> void:
	if NetworkManager.host_game():
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_join_button_pressed() -> void:
	if NetworkManager.join_game("127.0.0.1"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_username_edit_text_changed(new_text: String) -> void:
	Global.username = new_text
