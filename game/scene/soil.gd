extends MeshInstance3D

## Soil tile that supports tilling, planting, and harvesting

const PLANT_SCENE = preload("res://game/scene/plants/plant_scene.tscn")

var hasWater: bool = false
var isTilled: bool = false
var plantedPlant: Node3D = null
var isHovered: bool = false

signal plant_harvestable(plant: Node3D)

func _ready():
	# Add Area3D for interaction detection if it doesn't exist
	if not has_node("InteractionArea"):
		var area = Area3D.new()
		area.name = "InteractionArea"
		add_child(area)
		
		var collision = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(1.0, 0.5, 1.0)
		collision.shape = shape
		collision.position = Vector3(0, 0.25, 0)
		area.add_child(collision)

func tool_interaction(toolType: ITEM_BAR_ITEM.ITEM_TYPES):
	match toolType:
		ITEM_BAR_ITEM.ITEM_TYPES.HOE:
			if not isTilled and not plantedPlant:
				isTilled = true
				_update_soil_appearance()
				print("Soil tilled!")
		ITEM_BAR_ITEM.ITEM_TYPES.WATERING_CAN:
			if isTilled and not hasWater:
				hasWater = true
				_darken_mesh_color()
				print("Soil watered!")

func plant_seed(item: ITEM_BAR_ITEM) -> bool:
	"""Plant a seed on this soil tile"""
	# Check if item is a seed and soil is tilled
	if item.itemType != ITEM_BAR_ITEM.ITEM_TYPES.SEED:
		print("Cannot plant: Item is not a seed")
		return false
	
	if not isTilled:
		print("Cannot plant: Soil must be tilled first")
		return false
		
	if plantedPlant != null:
		print("Cannot plant: Soil already has a plant")
		return false
	
	# Instantiate the plant
	var plant = PLANT_SCENE.instantiate()
	plant.plantResource = item.plantResource
	
	# Position the plant slightly above the soil
	plant.position = Vector3(0, 0.1, 0)
	
	# Connect to plant signals
	plant.plant_matured.connect(_on_plant_matured.bind(plant))
	
	# Add plant as child of soil
	add_child(plant)
	plantedPlant = plant
	
	print("Seed planted successfully!")
	return true

func can_harvest() -> bool:
	"""Check if planted plant is ready to harvest"""
	if plantedPlant and plantedPlant.has_method("is_fully_grown"):
		return plantedPlant.is_fully_grown()
	return false

func harvest_plant() -> Dictionary:
	"""Harvest the plant and return harvest data"""
	if not can_harvest():
		return {"success": false, "message": "Plant not ready to harvest"}
	
	var harvest_data = plantedPlant.harvest()
	
	if harvest_data.get("success", false):
		# Remove the plant
		plantedPlant.queue_free()
		plantedPlant = null
		
		# Reset soil (optional - you can keep it tilled)
		# isTilled = false
		# hasWater = false
		# _update_soil_appearance()
		
		print("Plant harvested! Got: ", harvest_data.get("crop_name", "unknown"))
		return harvest_data
	
	return {"success": false}

func reset_soil():
	"""Reset soil to empty state"""
	if plantedPlant:
		plantedPlant.queue_free()
		plantedPlant = null
	
	isTilled = false
	hasWater = false
	_update_soil_appearance()

func get_interaction_prompt() -> String:
	"""Return appropriate interaction prompt based on soil state"""
	if plantedPlant:
		if can_harvest():
			return "Press E to Harvest"
		else:
			var stage = plantedPlant.get_current_stage() if plantedPlant.has_method("get_current_stage") else 0
			return "Growing (Stage %d)" % (stage + 1)
	elif isTilled:
		return "Press Q to Plant"
	else:
		return "Press Q (Hoe) to Till"

func set_selection(selected: bool):
	"""Visual feedback when player looks at this soil"""
	isHovered = selected
	
	if selected and not plantedPlant:
		_highlight_soil()
	else:
		_remove_highlight()

func _on_plant_matured(plant: Node3D):
	"""Called when plant reaches full growth"""
	plant_harvestable.emit(plant)
	print("Plant is mature and ready to harvest!")

func _update_soil_appearance():
	"""Visual feedback for tilled soil"""
	if isTilled:
		# Slightly raise the soil to show it's tilled
		position.y = 0.02
	else:
		position.y = 0.0

func _darken_mesh_color():
	"""Visual feedback for watered soil"""
	var mat: StandardMaterial3D
	
	if get_surface_override_material_count() > 0 and get_surface_override_material(0):
		mat = get_surface_override_material(0).duplicate()
	else:
		mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.6, 0.4, 0.2, 1.0)
	
	# Darken the color to simulate wet soil
	mat.albedo_color = mat.albedo_color.darkened(0.3)
	set_surface_override_material(0, mat)

func _highlight_soil():
	"""Show visual feedback when hovering"""
	var mat: StandardMaterial3D
	
	if get_surface_override_material_count() > 0 and get_surface_override_material(0):
		mat = get_surface_override_material(0).duplicate()
	else:
		mat = StandardMaterial3D.new()
		var current_material = get_active_material(0)
		if current_material and current_material is StandardMaterial3D:
			mat.albedo_color = current_material.albedo_color
		else:
			mat.albedo_color = Color(0.6, 0.4, 0.2, 1.0)
	
	# Add slight glow
	mat.albedo_color = mat.albedo_color.lightened(0.2)
	mat.emission_enabled = true
	mat.emission = Color(0.8, 0.8, 0.6, 1.0)
	mat.emission_energy = 0.3
	
	set_surface_override_material(0, mat)

func _remove_highlight():
	"""Remove visual feedback"""
	if not hasWater and not isTilled:
		set_surface_override_material(0, null)
	elif hasWater:
		_darken_mesh_color()
