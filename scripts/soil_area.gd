extends StaticBody3D
class_name SoilArea

## Defines a valid planting area where seeds can be planted
## Uses collision detection to determine if a location is valid soil

signal plant_placed(position: Vector3)

@export var soil_size: Vector2 = Vector2(10, 10)
@export var grid_spacing: float = 1.0  ## Minimum distance between plants
@export var visual_feedback: bool = true

## Track occupied planting positions
var occupied_positions: Array[Vector3] = []

## Collision layer configuration
## Set this soil area to layer 2 (soil layer)
const SOIL_LAYER = 2


func _ready() -> void:
	# Ensure this is on the soil collision layer
	collision_layer = SOIL_LAYER
	collision_mask = 0  # Soil doesn't need to detect anything
	
	# Create collision shape if it doesn't exist
	if get_child_count() == 0 or not get_child(0) is CollisionShape3D:
		_create_default_collision()


func _create_default_collision() -> void:
	var collision_shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(soil_size.x, 0.2, soil_size.y)
	collision_shape.shape = box_shape
	add_child(collision_shape)
	collision_shape.owner = self


## Check if a position is valid for planting
func is_position_valid(world_position: Vector3) -> bool:
	# Convert world position to local coordinates
	var local_pos := to_local(world_position)
	
	# Check if within soil bounds
	if abs(local_pos.x) > soil_size.x / 2.0 or abs(local_pos.z) > soil_size.y / 2.0:
		return false
	
	# Check if too close to existing plants
	for occupied_pos in occupied_positions:
		if world_position.distance_to(occupied_pos) < grid_spacing:
			return false
	
	return true


## Snap position to grid
func snap_to_grid(world_position: Vector3) -> Vector3:
	var local_pos := to_local(world_position)
	
	# Snap to grid
	local_pos.x = round(local_pos.x / grid_spacing) * grid_spacing
	local_pos.z = round(local_pos.z / grid_spacing) * grid_spacing
	local_pos.y = 0.0  # Keep at soil surface
	
	return to_global(local_pos)


## Register a plant at this position
func occupy_position(world_position: Vector3) -> void:
	var snapped_pos := snap_to_grid(world_position)
	occupied_positions.append(snapped_pos)
	plant_placed.emit(snapped_pos)


## Free up a position (when plant is removed/harvested)
func free_position(world_position: Vector3) -> void:
	var snapped_pos := snap_to_grid(world_position)
	for i in range(occupied_positions.size()):
		if occupied_positions[i].distance_to(snapped_pos) < 0.1:
			occupied_positions.remove_at(i)
			return


## Get the surface position at a given point
func get_surface_position(world_position: Vector3) -> Vector3:
	var local_pos := to_local(world_position)
	local_pos.y = 0.1  # Slightly above soil surface
	return to_global(local_pos)
