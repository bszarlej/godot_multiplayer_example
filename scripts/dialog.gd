@tool
class_name Dialog
extends Control

signal confirmed

@onready var _actions_container: HBoxContainer = $PanelContainer/VBoxContainer/Panel2/VBoxContainer/HBoxContainer
@onready var _title_label: Label = $PanelContainer/VBoxContainer/Panel/Label
@onready var _content_label: Label = $PanelContainer/VBoxContainer/Panel2/VBoxContainer/Label
@onready var _confirm_button: Button = $PanelContainer/VBoxContainer/Panel2/VBoxContainer/HBoxContainer/ConfirmButton

var _actions_visible: bool = true
var _title: String = ""
var _content: String = ""
var _confirm_button_text: String = "OK"
var _hide_on_confirm: bool = true

@export var actions_visible: bool = true:
	get = get_actions_visible,
	set = set_actions_visible

@export var title: String = "":
	get = get_title,
	set = set_title

@export_multiline var content: String = "":
	get = get_content,
	set = set_content

@export var confirm_button_text: String = "OK":
	get = get_confirm_button_text,
	set = set_confirm_button_text
	
@export var hide_on_confirm: bool = true:
	get: return _hide_on_confirm
	set(value): _hide_on_confirm = value

func set_actions_visible(value: bool) -> void:
	_actions_visible = value
	if _actions_container:
		_actions_container.visible = value

func get_actions_visible() -> bool:
	if _actions_container:
		return _actions_container.visible
	return _actions_visible

func set_title(value: String) -> void:
	_title = value
	if _title_label:
		_title_label.text = value

func get_title() -> String:
	if _title_label:
		return _title_label.text
	return _title

func set_content(value: String) -> void:
	_content = value
	if _content_label:
		_content_label.text = value

func get_content() -> String:
	if _content_label:
		return _content_label.text
	return _content

func set_confirm_button_text(value: String) -> void:
	_confirm_button_text = value
	if _confirm_button:
		_confirm_button.text = value

func get_confirm_button_text() -> String:
	if _confirm_button:
		return _confirm_button.text
	return _confirm_button_text

func _ready() -> void:
	set_actions_visible(_actions_visible)
	set_title(_title)
	set_content(_content)
	set_confirm_button_text(_confirm_button_text)
	hide()

func _on_confirm_button_pressed() -> void:
	if hide_on_confirm: hide()
	confirmed.emit()
