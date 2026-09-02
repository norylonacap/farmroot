extends Node3D
class_name PlayerInteraction

## Handles player interaction with the planting system using raycasting

signal interaction_target_changed(target: Node3D, is_valid: bool)
signal plant_interaction_available(plant: Plant)

@export_group("References")
@export var camera: Camera3D
@export var raycast: RayCast3D
@export var inventory: Inventory
@export var planting_manager: PlantingManager

@export_group("Interaction Settings")
@export var max_interaction_distance: float = 5.0
@export var planting_indicator_scene: PackedScene

@export_group("Input Actions")
@export var plant_action: String = "plant"
@export var interact_action: String = "interact"
@export var next_seed_action: String = "next_seed"
@export var prev_seed_action: String = "previous_seed"

## Current raycast target
var current_target: Node3D = null
var current_soil_area: SoilArea = null
var current_plant: Plant = null

## Planting indicator instance
var planting_indicator: Node3D = null

## Is the current position valid for planting?
var is_valid_planting_position: bool = false

## Interaction prompt text
var interaction_prompt: String = ""


func _ready() -> void:
	_setup_raycast()
	_spawn_planting_indicator()


func _setup_raycast() -> void:
	# Create raycast if not assigned
	if raycast == null and camera != null:
		raycast = RayCast3D.new()
		raycast.name = "InteractionRaycast"
		camera.add_child(raycast)
		raycast.target_position = Vector3(0, 0, -max_interaction_distance)
		raycast.enabled = true
		
		# Set collision mask to detect soil (layer 2) and interactions (layer 3)
		raycast.collision_mask = 2 + 4  # Layers 2 and 3
	
	if raycast:
		raycast.target_position = Vector3(0, 0, -max_interaction_distance)


func _spawn_planting_indicator() -> void:
	if planting_indicator_scene:
		planting_indicator = planting_indicator_scene.instantiate()
	else:
		# Create a simple default indicator
		planting_indicator = MeshInstance3D.new()
		var mesh := PlaneMesh.new()
		mesh.size = Vector2(0.5, 0.5)
		planting_indicator.mesh = mesh
		
		# Create material
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0, 1, 0, 0.5)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		planting_indicator.material_override = material
	
	add_child(planting_indicator)
	planting_indicator.visible = false


func _process(_delta: float) -> void:
	_update_raycast()
	_update_planting_indicator()
	_check_for_interaction()


func _input(event: InputEvent) -> void:
	# Handle planting
	if event.is_action_pressed(plant_action):
		_try_plant()
	
	# Handle interaction (harvesting)
	if event.is_action_pressed(interact_action):
		_try_interact()
	
	# Handle seed cycling
	if event.is_action_pressed(next_seed_action) and inventory:
		inventory.select_next_seed()
	
	if event.is_action_pressed(prev_seed_action) and inventory:
		inventory.select_previous_seed()


func _update_raycast() -> void:
	if raycast == null or not raycast.is_colliding():
		_clear_target()
		return
	
	var collider := raycast.get_collider()
	var hit_position := raycast.get_collision_point()
	
	# Check if we hit a soil area
	if collider is SoilArea:
		_update_soil_target(collider, hit_position)
	# Check if we hit an interaction area (plant)
	elif collider is Area3D:
		_update_plant_target(collider)
	else:
		_clear_target()


func _update_soil_target(soil: SoilArea, position: Vector3) -> void:
	current_soil_area = soil
	current_plant = null
	
	# Check if this position is valid for planting
	if inventory and inventory.get_selected_seed_data():
		is_valid_planting_position = soil.is_position_valid(position)
		current_target = soil
		interaction_target_changed.emit(soil, is_valid_planting_position)
	else:
		is_valid_planting_position = false


func _update_plant_target(area: Area3D) -> void:
	# Check if this is a plant interaction area
	var plant := area.get_parent() as Plant
	if plant and plant.can_be_interacted():
		current_plant = plant
		current_soil_area = null
		current_target = plant
		is_valid_planting_position = false
		interaction_prompt = plant.get_interaction_text()
		plant_interaction_available.emit(plant)
	else:
		_clear_target()


func _clear_target() -> void:
	if current_target != null:
		interaction_target_changed.emit(null, false)
	
	current_target = null
	current_soil_area = null
	current_plant = null
	is_valid_planting_position = false
	interaction_prompt = ""


func _update_planting_indicator() -> void:
	if planting_indicator == null:
		return
	
	# Show indicator when looking at valid soil with a seed selected
	if current_soil_area != null and inventory and inventory.get_selected_seed_data():
		planting_indicator.visible = true
		
		var hit_position := raycast.get_collision_point()
		var snapped_position := current_soil_area.snap_to_grid(hit_position)
		planting_indicator.global_position = snapped_position + Vector3(0, 0.05, 0)
		
		# Change color based on validity
		if planting_indicator is MeshInstance3D:
			var material := planting_indicator.material_override as StandardMaterial3D
			if material:
				if is_valid_planting_position:
					material.albedo_color = Color(0, 1, 0, 0.5)  # Green for valid
				else:
					material.albedo_color = Color(1, 0, 0, 0.5)  # Red for invalid
	else:
		planting_indicator.visible = false


func _check_for_interaction() -> void:
	# Update interaction prompt based on current target
	if current_plant:
		interaction_prompt = current_plant.get_interaction_text()
	else:
		interaction_prompt = ""


func _try_plant() -> void:
	if not is_valid_planting_position or current_soil_area == null:
		return
	
	if inventory == null or planting_manager == null:
		return
	
	var seed_data := inventory.get_selected_seed_data()
	if seed_data == null:
		return
	
	var hit_position := raycast.get_collision_point()
	planting_manager.try_plant_seed(seed_data, hit_position, current_soil_area)


func _try_interact() -> void:
	if current_plant and current_plant.can_be_interacted():
		current_plant.interact(self)


## Get the current interaction prompt text
func get_interaction_prompt() -> String:
	return interaction_prompt


## Check if player can currently plant
func can_plant() -> bool:
	return is_valid_planting_position and inventory and inventory.get_selected_seed_data() != null


## Get current raycast hit position
func get_target_position() -> Vector3:
	if raycast and raycast.is_colliding():
		return raycast.get_collision_point()
	return Vector3.ZERO


## Helper method for plant interaction detection
func get_interaction_prompt() -> String:
	return interaction_prompt
