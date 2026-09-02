extends CharacterBody3D
class_name Player

## Example player script showing hotbar integration
## Attach this to your CharacterBody3D player node

# Reference to hotbar (set in the editor or get via get_node)
@export var hotbar: Hotbar = null

# Current held item
var current_item: ItemData = null
var current_slot: int = 0

func _ready() -> void:
	# Connect to hotbar signals
	if hotbar:
		hotbar.item_selected.connect(_on_hotbar_item_selected)
		# Get initial item
		current_item = hotbar.get_selected_item()
		current_slot = hotbar.get_selected_slot()

func _on_hotbar_item_selected(item: ItemData, slot_index: int) -> void:
	"""Called when the player selects a different hotbar slot"""
	current_item = item
	current_slot = slot_index
	
	# Update what the player is holding
	update_held_item()
	
	print("[PLAYER] Now holding: ", item.item_name if item else "Nothing")

func update_held_item() -> void:
	"""Update the visual representation of what the player is holding"""
	# TODO: Show/hide 3D item models based on current_item
	# Example:
	# if current_item:
	#     if current_item.item_id == "stone":
	#         show_stone_model()
	#     elif current_item.item_id == "wood":
	#         show_wood_model()
	# else:
	#     hide_all_item_models()
	pass

## Use/Place the current item
func use_current_item() -> void:
	if current_item == null:
		print("[PLAYER] No item selected!")
		return
	
	print("[PLAYER] Using: ", current_item.item_name)
	
	# Example: Place a block
	if current_item.item_id == "stone":
		place_stone_block()
	elif current_item.item_id == "potato":
		plant_potato()
	elif current_item.item_id == "water":
		use_water()
	
	# Remove one from inventory
	if hotbar and hotbar.inventory:
		hotbar.inventory.remove_item(current_slot, 1)

## Example: Place a stone block
func place_stone_block() -> void:
	print("[PLAYER] Placing stone block...")
	# TODO: Raycast to find placement position
	# TODO: Instance stone block at position
	pass

## Example: Plant a potato
func plant_potato() -> void:
	print("[PLAYER] Planting potato...")
	# TODO: Raycast to find ground
	# TODO: Instance potato plant
	pass

## Example: Use water bucket
func use_water() -> void:
	print("[PLAYER] Using water...")
	# TODO: Water crops in front of player
	pass

## Example input handling
func _input(event: InputEvent) -> void:
	# Left click to use item
	if event.is_action_pressed("ui_accept"):  # Left mouse button
		use_current_item()
	
	# Right click for alternative action
	if event.is_action_pressed("ui_cancel"):  # Right mouse button or Escape
		# Drop item, alternative use, etc.
		pass

## Get the currently held item
func get_held_item() -> ItemData:
	return current_item

## Check if player is holding a specific item
func is_holding_item(item_id: String) -> bool:
	return current_item != null and current_item.item_id == item_id

## Get quantity of held item
func get_held_item_quantity() -> int:
	if hotbar and hotbar.inventory:
		return hotbar.inventory.get_slot(current_slot).quantity
	return 0
