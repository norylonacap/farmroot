extends Control

@onready var start_button: Button = %StartButton
@onready var credits_button: Button = %CreditsButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_start_pressed() -> void:
	GameManager.go_to_scene(GameManager.CROP_SELECTION_SCENE)


func _on_credits_pressed() -> void:
	GameManager.go_to_scene(GameManager.CREDITS_SCENE)


func _on_exit_pressed() -> void:
	get_tree().quit()
