extends Label

# Debug UI to show plant information when looking at one
# Attach to a Label in your UI

@export var player_path: NodePath
var player: CharacterBody3D
var ray_cast: RayCast3D

func _ready():
	if player_path:
		player = get_node(player_path)
		if player:
			ray_cast = player.get_node("head/Camera3D/RayCast3D")

func _process(_delta):
	if not ray_cast or not ray_cast.is_colliding():
		visible = false
		return
	
	var collider = ray_cast.get_collider()
	if not collider:
		visible = false
		return
	
	# Check if we're looking at soil with a plant
	var plant = null
	if collider.has("plantedPlant") and collider.plantedPlant:
		plant = collider.plantedPlant
	
	# Or if we're directly looking at a plant
	if collider.get_parent() and collider.get_parent().has_method("get_current_stage"):
		plant = collider.get_parent()
	
	if plant:
		_display_plant_info(plant)
		visible = true
	else:
		visible = false

func _display_plant_info(plant: Node3D):
	if not plant.plantResource:
		text = "Plant (no data)"
		return
	
	var stage = plant.get_current_stage()
	var days = plant.currentStageDays
	var max_days = 0
	
	if stage < plant.plantResource.daysPerStage.size():
		max_days = plant.plantResource.daysPerStage[stage]
	
	var total_stages = plant.plantResource.stageScenes.size()
	var is_mature = plant.is_fully_grown()
	
	text = "🌱 Plant Info\n"
	text += "Stage: %d/%d\n" % [stage + 1, total_stages]
	text += "Days: %d/%d\n" % [days, max_days]
	
	if is_mature:
		text += "Status: MATURE ✓\n"
		text += "Ready to harvest!"
	else:
		var days_remaining = max_days - days
		text += "Status: Growing...\n"
		text += "Days until next stage: %d" % days_remaining
