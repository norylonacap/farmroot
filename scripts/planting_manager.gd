extends Node
class_name PlantingManager

## Manages the planting system, coordinating between player interaction and soil areas

signal plant_spawned(plant: Plant, position: Vector3)
signal planting_failed(reason: String)

## Container for spawned plants
@export var plants_container: Node3D

## Reference to the player's inventory
@export var inventory: Node

## Planting particles
@export var planting_particles_scene: PackedScene

var active_plants: Array[Plant] = []


func _ready() -> void:
	# Create plants container if not assigned
	if plants_container == null:
		plants_container = Node3D.new()
		plants_container.name = "Plants"
		get_parent().add_child(plants_container)


## Attempt to plant a seed at the specified position
func try_plant_seed(seed: SeedData, world_position: Vector3, soil_area: SoilArea) -> bool:
	if seed == null:
		planting_failed.emit("No seed selected")
		return false
	
	if seed.plant_scene == null:
		planting_failed.emit("Seed has no plant scene assigned")
		return false
	
	if soil_area == null:
		planting_failed.emit("Not planting on valid soil")
		return false
	
	# Check if position is valid
	if not soil_area.is_position_valid(world_position):
		planting_failed.emit("Position already occupied or invalid")
		return false
	
	# Check inventory (if connected)
	if inventory and inventory.has_method("has_item"):
		if not inventory.has_item(seed.seed_name):
			planting_failed.emit("No seeds in inventory")
			return false
	
	# All checks passed - plant the seed!
	var plant_position := soil_area.snap_to_grid(world_position)
	var plant := _spawn_plant(seed, plant_position)
	
	if plant:
		# Occupy the position in the soil area
		soil_area.occupy_position(plant_position)
		
		# Remove seed from inventory
		if inventory and inventory.has_method("remove_item"):
			inventory.remove_item(seed.seed_name, 1)
		
		# Spawn planting particles
		_spawn_planting_particles(plant_position)
		
		# Connect plant signals
		plant.plant_harvested.connect(_on_plant_harvested)
		
		# Track active plant
		active_plants.append(plant)
		
		plant_spawned.emit(plant, plant_position)
		return true
	else:
		planting_failed.emit("Failed to spawn plant")
		return false


## Spawn the plant instance at the given position
func _spawn_plant(seed: SeedData, position: Vector3) -> Plant:
	var plant_instance := seed.plant_scene.instantiate() as Node3D
	
	if plant_instance == null:
		push_error("Failed to instantiate plant scene")
		return null
	
	# Add to plants container
	plants_container.add_child(plant_instance)
	plant_instance.global_position = position
	
	# If it's a Plant node, assign seed data
	if plant_instance is Plant:
		plant_instance.seed_data = seed
		return plant_instance
	
	# If not a Plant class, try to find Plant script in children
	for child in plant_instance.get_children():
		if child is Plant:
			child.seed_data = seed
			return child
	
	# Create a Plant wrapper if the scene doesn't have one
	var plant_script := Plant.new()
	plant_script.seed_data = seed
	plant_instance.add_child(plant_script)
	
	return plant_script


## Spawn visual feedback particles when planting
func _spawn_planting_particles(position: Vector3) -> void:
	if planting_particles_scene:
		var particles := planting_particles_scene.instantiate()
		plants_container.add_child(particles)
		particles.global_position = position
		
		# Auto-remove after emission
		if particles is GPUParticles3D:
			particles.emitting = true
			particles.finished.connect(particles.queue_free)


## Handle plant harvest
func _on_plant_harvested(harvest_item: String, amount: int) -> void:
	# Add harvested item to inventory
	if inventory and inventory.has_method("add_item"):
		inventory.add_item(harvest_item, amount)
	
	# Remove from active plants list
	for i in range(active_plants.size() - 1, -1, -1):
		if not is_instance_valid(active_plants[i]):
			active_plants.remove_at(i)


## Get all active plants
func get_active_plants() -> Array[Plant]:
	return active_plants


## Get plant at specific position
func get_plant_at_position(position: Vector3, max_distance: float = 0.5) -> Plant:
	for plant in active_plants:
		if is_instance_valid(plant) and plant.global_position.distance_to(position) < max_distance:
			return plant
	return null


## Clear all plants (useful for resetting)
func clear_all_plants() -> void:
	for plant in active_plants:
		if is_instance_valid(plant):
			plant.queue_free()
	active_plants.clear()
