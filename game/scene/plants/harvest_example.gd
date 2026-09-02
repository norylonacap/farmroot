# Example script showing how to implement harvesting
# Add this logic to your player.gd or create a separate harvest system

extends Node

# Example: Add to player.gd _unhandled_input()
func example_harvest_interaction():
	# Check if player presses E key on a plant
	# if event.is_action_pressed("harvest") and not onAction:
	#     if ray_cast_3d.is_colliding():
	#         var collider = ray_cast_3d.get_collider()
	#         if collider.get_parent() is Node3D:
	#             var plant = collider.get_parent()
	#             if plant.has_method("is_fully_grown"):
	#                 _harvest_plant(plant)
	pass

func _harvest_plant(plant: Node3D):
	if not plant.is_fully_grown():
		print("Plant is not ready to harvest yet!")
		return
	
	# Give player the harvested crop item
	# Example: add to inventory
	print("Harvested plant!")
	
	# Remove the plant from the scene
	var parent_soil = plant.get_parent()
	plant.queue_free()
	
	# Reset soil state if needed
	if parent_soil.has_method("reset_soil"):
		parent_soil.reset_soil()
	elif parent_soil.has("plantedPlant"):
		parent_soil.plantedPlant = null

# Add to soil.gd
func reset_soil_example():
	# plantedPlant = null
	# Can optionally reset tilled state too:
	# isTilled = false
	# hasWater = false
	pass
