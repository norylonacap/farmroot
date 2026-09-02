extends Node
class_name FarmingGameManager

## Manages the farming game, sets up inventory, and connects all systems

@export_group("Seed Resources")
@export var available_seeds: Array[SeedData] = []

@export_group("Starting Inventory")
@export var starting_potato_seeds: int = 10
@export var starting_carrot_seeds: int = 10

@export_group("System References")
@export var inventory: Inventory
@export var planting_manager: PlantingManager
@export var player_interaction: PlayerInteraction
@export var farming_ui: FarmingUI


func _ready() -> void:
	_setup_inventory()
	_connect_systems()
	print("Farming system initialized!")


func _setup_inventory() -> void:
	if inventory == null:
		push_error("Inventory not assigned!")
		return
	
	# Register all available seeds
	if not available_seeds.is_empty():
		inventory.register_seeds(available_seeds)
	
	# Add starting seeds to inventory
	for seed in available_seeds:
		if seed.seed_name == "Potato Seed":
			inventory.add_item(seed.seed_name, starting_potato_seeds)
		elif seed.seed_name == "Carrot Seed":
			inventory.add_item(seed.seed_name, starting_carrot_seeds)
	
	# Select first seed
	inventory.select_next_seed()
	
	# Print initial inventory
	inventory.print_inventory()


func _connect_systems() -> void:
	# Connect planting manager signals
	if planting_manager:
		planting_manager.plant_spawned.connect(_on_plant_spawned)
		planting_manager.planting_failed.connect(_on_planting_failed)


func _on_plant_spawned(plant: Plant, position: Vector3) -> void:
	print("Plant spawned at: ", position)
	if farming_ui:
		farming_ui.show_message("Planted!", 1.0)


func _on_planting_failed(reason: String) -> void:
	print("Planting failed: ", reason)
	if farming_ui:
		farming_ui.show_message(reason, 2.0)
