extends Control

## Simple UI to display farming inventory (seeds and crops)

@onready var seeds_label: Label = $VBoxContainer/SeedsLabel
@onready var crops_label: Label = $VBoxContainer/CropsLabel

var player: CharacterBody3D = null

func _ready():
	# Find player
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		push_error("FarmingInventoryUI: Could not find player!")
		return
	
	# Initial update
	_update_display()

func _process(_delta):
	if player:
		_update_display()

func _update_display():
	"""Update inventory display"""
	if not player:
		return
	
	# Update seeds count
	var seeds = player.get_seeds_count() if player.has_method("get_seeds_count") else 0
	seeds_label.text = "Seeds: %d" % seeds
	
	# Update harvested crops
	var crops = player.get_harvested_crops() if player.has_method("get_harvested_crops") else {}
	var crops_text = "Harvested Crops:\n"
	
	if crops.is_empty():
		crops_text += "  (none)"
	else:
		for crop_name in crops.keys():
			crops_text += "  %s: %d\n" % [crop_name.capitalize(), crops[crop_name]]
	
	crops_label.text = crops_text
