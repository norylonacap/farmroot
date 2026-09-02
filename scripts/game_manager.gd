extends Node

## Global game state and scene paths for FARMROOT menu flow.

const LOADING_SCENE := "res://game/scene/ui/loading_screen.tscn"
const MAIN_MENU_SCENE := "res://game/scene/main_menu/main_menu.tscn"
const CROP_SELECTION_SCENE := "res://game/scene/main_menu/crop_selection.tscn"
const CREDITS_SCENE := "res://game/scene/main_menu/credits.tscn"
const GAMEPLAY_SCENE := "res://game/scene/main.tscn"

const SEED_RESOURCES := {
	"potato": "res://game/assets/character/item_resource/potato_seed.tres",
	"casava": "res://game/assets/character/item_resource/casava_seed.tres",
	"yam": "res://game/assets/character/item_resource/yam_seed.tres",
}

var selected_crop: String = ""


func set_selected_crop(crop_id: String) -> void:
	selected_crop = crop_id


func get_selected_seed() -> ITEM_BAR_ITEM:
	if selected_crop.is_empty():
		return null
	var path: String = SEED_RESOURCES.get(selected_crop, "")
	if path.is_empty():
		return null
	return load(path) as ITEM_BAR_ITEM


func go_to_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
