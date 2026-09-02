extends Node3D

## Plant that grows through multiple stages over time
## Managed by DayManager for automatic growth progression

@export var plantResource: PLANT_RESOURCE

@onready var model: Node3D = $model

var currentStage: int = 0
var currentStageDays: int = 0
var isHarvestable: bool = false

signal plant_matured()
signal stage_changed(new_stage: int)

func _ready():
	# Add to plants group for day manager
	add_to_group("plants")
	
	if plantResource and plantResource.stageScenes.size() > 0:
		_instantiate_stage(0)

func _instantiate_stage(stageIndex: int):
	# Clear previous stage model
	for child in model.get_children():
		child.queue_free()
	
	# Instantiate new stage scene
	if stageIndex < plantResource.stageScenes.size():
		var stageScene = plantResource.stageScenes[stageIndex].instantiate()
		model.add_child(stageScene)
		
		# Smooth growth animation with Tween
		_animate_growth(stageScene)
		
		currentStage = stageIndex
		currentStageDays = 0
		
		# Check if fully grown
		if is_fully_grown():
			isHarvestable = true
			plant_matured.emit()
			print("Plant is fully grown and ready to harvest!")
		
		stage_changed.emit(currentStage)

func _animate_growth(stage_node: Node3D):
	# Start small and grow to full size
	stage_node.scale = Vector3(0.1, 0.1, 0.1)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(stage_node, "scale", Vector3.ONE, 0.5)

func advance_day():
	if not plantResource:
		return
	
	currentStageDays += 1
	
	# Check if we should advance to next stage
	if currentStage < plantResource.daysPerStage.size():
		if currentStageDays >= plantResource.daysPerStage[currentStage]:
			var nextStage = currentStage + 1
			if nextStage < plantResource.stageScenes.size():
				_instantiate_stage(nextStage)

func get_current_stage() -> int:
	return currentStage

func is_fully_grown() -> bool:
	if not plantResource:
		return false
	return currentStage >= plantResource.stageScenes.size() - 1

func get_harvest_ready() -> bool:
	return isHarvestable

func harvest() -> Dictionary:
	"""Returns harvest data and marks plant for removal"""
	if not isHarvestable:
		return {}
	
	# Return harvest information
	var harvest_data = {
		"success": true,
		"crop_name": plantResource.resource_path.get_file().get_basename().replace("_resource", ""),
		"amount": 1  # Can be made configurable
	}
	
	return harvest_data
