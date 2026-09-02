extends Node3D
class_name Plant

## A growing plant that progresses through stages and can be harvested when mature

signal growth_stage_changed(new_stage: int)
signal plant_matured()
signal plant_harvested(harvest_item: String, amount: int)

## The seed data this plant was grown from
@export var seed_data: SeedData

## Visual feedback
@export var growth_particles: GPUParticles3D
@export var harvest_particles: GPUParticles3D

## Current growth stage (0 = just planted, max = fully mature)
var current_stage: int = 0

## Is the plant fully mature and ready to harvest?
var is_mature: bool = false

## Can the player currently interact with this plant?
var can_interact: bool = false

## Reference to the mesh instance for visual updates
var mesh_instance: MeshInstance3D

## Reference to interaction area
var interaction_area: Area3D

## Growth timer
var growth_timer: Timer

## Time per stage
var time_per_stage: float


func _ready() -> void:
	if seed_data == null:
		push_error("Plant has no seed_data assigned!")
		return
	
	_setup_growth_timer()
	_setup_interaction_area()
	_setup_mesh()
	_update_visual_stage()


func _setup_growth_timer() -> void:
	growth_timer = Timer.new()
	add_child(growth_timer)
	
	# Calculate time per stage
	if seed_data.growth_stages > 1:
		time_per_stage = seed_data.total_growth_time / float(seed_data.growth_stages - 1)
	else:
		time_per_stage = seed_data.total_growth_time
	
	growth_timer.wait_time = time_per_stage
	growth_timer.timeout.connect(_on_growth_timer_timeout)
	growth_timer.start()


func _setup_interaction_area() -> void:
	# Create an Area3D for player interaction
	interaction_area = Area3D.new()
	interaction_area.name = "InteractionArea"
	add_child(interaction_area)
	
	# Add collision shape for interaction
	var collision_shape := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.5
	collision_shape.shape = sphere_shape
	interaction_area.add_child(collision_shape)
	
	# Set to interaction layer (layer 3)
	interaction_area.collision_layer = 4  # Layer 3 (2^2 = 4)
	interaction_area.collision_mask = 0
	
	# Connect signals
	interaction_area.body_entered.connect(_on_interaction_body_entered)
	interaction_area.body_exited.connect(_on_interaction_body_exited)


func _setup_mesh() -> void:
	# Look for existing MeshInstance3D
	mesh_instance = get_node_or_null("MeshInstance3D")
	
	# If no mesh exists, create a simple one
	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		add_child(mesh_instance)
		
		# Create default mesh (will be updated by stage)
		var default_mesh := SphereMesh.new()
		default_mesh.radius = 0.1
		default_mesh.height = 0.2
		mesh_instance.mesh = default_mesh


func _on_growth_timer_timeout() -> void:
	if current_stage < seed_data.growth_stages - 1:
		current_stage += 1
		growth_stage_changed.emit(current_stage)
		_update_visual_stage()
		
		# Play growth particles if available
		if growth_particles:
			growth_particles.restart()
		
		# Check if plant is now mature
		if current_stage >= seed_data.growth_stages - 1:
			_on_plant_matured()
	else:
		growth_timer.stop()


func _update_visual_stage() -> void:
	if mesh_instance == null:
		return
	
	# Update mesh based on growth stage
	if seed_data.stage_meshes.size() > current_stage:
		mesh_instance.mesh = seed_data.stage_meshes[current_stage]
	else:
		# Scale up based on stage if no custom meshes
		var scale_factor := 0.3 + (float(current_stage) / float(seed_data.growth_stages - 1)) * 0.7
		mesh_instance.scale = Vector3.ONE * scale_factor


func _on_plant_matured() -> void:
	is_mature = true
	plant_matured.emit()
	
	# Make plant interactive only when mature
	if interaction_area:
		interaction_area.monitoring = true


func _on_interaction_body_entered(body: Node3D) -> void:
	if is_mature and body.has_method("get_interaction_prompt"):
		can_interact = true


func _on_interaction_body_exited(body: Node3D) -> void:
	if body.has_method("get_interaction_prompt"):
		can_interact = false


## Called by player interaction system
func interact(interactor: Node3D) -> void:
	if not is_mature:
		return
	
	# Emit harvest signal
	plant_harvested.emit(seed_data.harvest_item_name, seed_data.harvest_amount)
	
	# Play harvest particles
	if harvest_particles:
		harvest_particles.restart()
		# Wait for particles before destroying
		await get_tree().create_timer(0.5).timeout
	
	# Notify soil area that this position is now free
	var soil_area := get_parent().get_node_or_null("../SoilArea")
	if soil_area and soil_area is SoilArea:
		soil_area.free_position(global_position)
	
	# Remove plant
	queue_free()


## Check if player can interact
func can_be_interacted() -> bool:
	return is_mature and can_interact


## Get interaction prompt text
func get_interaction_text() -> String:
	if is_mature:
		return "Harvest " + seed_data.seed_name.replace(" Seed", "")
	return ""


## Get current growth progress (0.0 to 1.0)
func get_growth_progress() -> float:
	if seed_data.growth_stages <= 1:
		return 1.0
	
	var stage_progress := float(current_stage) / float(seed_data.growth_stages - 1)
	var timer_progress := 0.0
	
	if growth_timer and not growth_timer.is_stopped():
		timer_progress = (time_per_stage - growth_timer.time_left) / time_per_stage
		timer_progress /= float(seed_data.growth_stages - 1)
	
	return stage_progress + timer_progress
