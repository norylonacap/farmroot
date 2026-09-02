extends Control

@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	GameManager.go_to_scene(GameManager.MAIN_MENU_SCENE)
