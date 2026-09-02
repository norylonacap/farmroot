extends Control

@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect crop selection buttons
	var potato_card = $MarginContainer/VBoxContainer/CropContainer/PotatoCard
	var casava_card = $MarginContainer/VBoxContainer/CropContainer/CasavaCard
	var yam_card = $MarginContainer/VBoxContainer/CropContainer/YamCard
	
	var potato_button = potato_card.get_node("MarginContainer/VBoxContainer/SelectButton")
	var casava_button = casava_card.get_node("MarginContainer/VBoxContainer/SelectButton")
	var yam_button = yam_card.get_node("MarginContainer/VBoxContainer/SelectButton")
	
	potato_button.pressed.connect(_on_crop_selected.bind("potato"))
	casava_button.pressed.connect(_on_crop_selected.bind("casava"))
	yam_button.pressed.connect(_on_crop_selected.bind("yam"))


func _on_crop_selected(crop_id: String) -> void:
	GameManager.set_selected_crop(crop_id)
	GameManager.go_to_scene(GameManager.GAMEPLAY_SCENE)


func _on_back_pressed() -> void:
	GameManager.go_to_scene(GameManager.MAIN_MENU_SCENE)
