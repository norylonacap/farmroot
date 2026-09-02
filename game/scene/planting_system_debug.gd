extends Node

# Planting System Debug Tool
# Attach this to your main scene root node to enable debug features
# Press F1 to print system status

func _ready():
	print("=== PLANTING SYSTEM DEBUG TOOL LOADED ===")
	print("Press F1 to check system status")
	print("Press F2 to skip day")
	print("Press F3 to list all plants")
	print("Press F4 to grow all plants instantly")

func _input(event):
	if event.is_action_pressed("ui_home"):  # F1 key
		_print_system_status()
	elif event.is_action_pressed("ui_end"):  # F2 key
		_skip_day()
	elif event.is_action_pressed("ui_page_up"):  # F3 key
		_list_all_plants()
	elif event.is_action_pressed("ui_page_down"):  # F4 key
		_grow_all_plants()

func _print_system_status():
	print("\n========================================")
	print("PLANTING SYSTEM STATUS")
	print("========================================")
	
	# Check Day Manager
	var day_manager = get_tree().get_first_node_in_group("day_manager")
	if day_manager:
		print("✓ DayManager: Found")
		print("  - Current Day: ", day_manager.get_current_day())
		print("  - Seconds/Day: ", day_manager.seconds_per_day)
		print("  - Progress: %.1f%%" % (day_manager.get_day_progress() * 100))
	else:
		print("✗ DayManager: NOT FOUND")
		print("  → Add DayManager node with day_manager.gd script")
	
	# Check Plants
	var plants = get_tree().get_nodes_in_group("plants")
	print("\n✓ Plants: %d found" % plants.size())
	
	# Check Player
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_node_or_null("/root/Main/Player")
	
	if player:
		print("✓ Player: Found")
		var item_bar = player.get_node_or_null("CanvasLayer/ItemBar")
		if item_bar:
			print("  ✓ ItemBar: Found")
			var current_item = item_bar.get_current_item()
			if current_item:
				print("  - Current Item Type: ", current_item.itemType)
				if current_item.itemType == 4:
					print("  - SEED selected!")
					if current_item.plantResource:
						print("  - Plant Resource: Linked ✓")
					else:
						print("  - Plant Resource: MISSING ✗")
			else:
				print("  - No item selected")
		else:
			print("  ✗ ItemBar: NOT FOUND")
	else:
		print("✗ Player: NOT FOUND")
	
	# Check Soil
	var soil_count = 0
	var planted_count = 0
	var tilled_count = 0
	
	for node in get_tree().get_nodes_in_group("soil"):
		soil_count += 1
		if node.has("plantedPlant") and node.plantedPlant:
			planted_count += 1
		if node.has("isTilled") and node.isTilled:
			tilled_count += 1
	
	if soil_count > 0:
		print("\n✓ Soil: %d tiles found" % soil_count)
		print("  - Tilled: %d" % tilled_count)
		print("  - Planted: %d" % planted_count)
	else:
		print("\n! Soil: No soil tiles in 'soil' group")
		print("  → Add soil nodes to 'soil' group for tracking")
	
	print("\n========================================")
	print("RESOURCE CHECK")
	print("========================================")
	
	# Check if resources exist
	var carrot_resource = load("res://game/scene/plants/carrot_resource.tres")
	if carrot_resource:
		print("✓ carrot_resource.tres: Found")
		print("  - Stages: %d" % carrot_resource.stageScenes.size())
		print("  - Days: ", carrot_resource.daysPerStage)
	else:
		print("✗ carrot_resource.tres: NOT FOUND")
	
	var carrot_seed = load("res://game/assets/character/item_resource/carrot_seed.tres")
	if carrot_seed:
		print("✓ carrot_seed.tres: Found")
		print("  - Type: ", carrot_seed.itemType)
		if carrot_seed.plantResource:
			print("  - Plant Resource: Linked ✓")
		else:
			print("  - Plant Resource: NOT LINKED ✗")
	else:
		print("✗ carrot_seed.tres: NOT FOUND")
	
	print("========================================\n")

func _skip_day():
	var day_manager = get_tree().get_first_node_in_group("day_manager")
	if day_manager:
		day_manager.skip_day()
		print("⏩ Day skipped! New day: ", day_manager.get_current_day())
	else:
		print("✗ Cannot skip day - DayManager not found")

func _list_all_plants():
	var plants = get_tree().get_nodes_in_group("plants")
	
	print("\n========================================")
	print("ALL PLANTS (%d total)" % plants.size())
	print("========================================")
	
	if plants.size() == 0:
		print("No plants found in scene")
		return
	
	for i in range(plants.size()):
		var plant = plants[i]
		print("\nPlant #%d:" % (i + 1))
		print("  - Position: ", plant.global_position)
		print("  - Stage: %d/%d" % [
			plant.get_current_stage() + 1,
			plant.plantResource.stageScenes.size()
		])
		print("  - Days in stage: %d/%d" % [
			plant.currentStageDays,
			plant.plantResource.daysPerStage[plant.get_current_stage()]
		])
		print("  - Fully grown: ", plant.is_fully_grown())
	
	print("========================================\n")

func _grow_all_plants():
	var plants = get_tree().get_nodes_in_group("plants")
	
	if plants.size() == 0:
		print("No plants to grow")
		return
	
	for plant in plants:
		# Advance to final stage
		while not plant.is_fully_grown():
			plant.advance_day()
	
	print("🌱 All %d plants grown to maturity!" % plants.size())
