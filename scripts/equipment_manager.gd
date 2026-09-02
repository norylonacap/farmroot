extends Node
class_name EquipmentManager

## Manages which hand/tool item is currently visible in the player's view
## Controls visibility of existing hand nodes in the player scene

signal equipment_changed(item_id: String)

# References to hand nodes (set via @onready in parent script)
var yam_seed_hand: Node3D = null
var potato_seed_hand: Node3D = null
var casava_seed_hand: Node3D = null
var rake_hand: Node3D = null
var fork_hand: Node3D = null
var hoe_hand: Node3D = null

# Track currently equipped item
var current_item_id: String = ""

# Mapping of item IDs to hand node references
var hand_nodes: Dictionary = {}

func _ready() -> void:
	# This will be populated after hand references are set
	pass

## Initialize hand node references - call this from player script after nodes are ready
func initialize_hand_nodes(
	yam_node: Node3D,
	potato_node: Node3D,
	casava_node: Node3D,
	rake_node: Node3D,
	fork_node: Node3D,
	hoe_node: Node3D
) -> void:
	yam_seed_hand = yam_node
	potato_seed_hand = potato_node
	casava_seed_hand = casava_node
	rake_hand = rake_node
	fork_hand = fork_node
	hoe_hand = hoe_node
	
	# Build mapping dictionary
	hand_nodes = {
		"yam_seed": yam_seed_hand,
		"potato_seed": potato_seed_hand,
		"casava_seed": casava_seed_hand,
		"rake": rake_hand,
		"fork": fork_hand,
		"hoe": hoe_hand
	}
	
	# Hide all hands initially
	hide_all_hands()
	
	print("[EquipmentManager] Initialized with ", hand_nodes.size(), " hand nodes")

## Equip an item by its ID
func equip_item(item_id: String) -> void:
	if item_id.is_empty():
		hide_all_hands()
		current_item_id = ""
		equipment_changed.emit("")
		return
	
	# Check if the item_id is valid
	if not hand_nodes.has(item_id):
		push_warning("[EquipmentManager] Unknown item_id: " + item_id)
		hide_all_hands()
		current_item_id = ""
		return
	
	# Hide all hands first
	hide_all_hands()
	
	# Show only the selected hand
	var hand_node = hand_nodes[item_id]
	if hand_node:
		hand_node.visible = true
		current_item_id = item_id
		equipment_changed.emit(item_id)
		print("[EquipmentManager] Equipped: ", item_id)
	else:
		push_warning("[EquipmentManager] Hand node for " + item_id + " is null!")

## Hide all hand items
func hide_all_hands() -> void:
	for hand_node in hand_nodes.values():
		if hand_node:
			hand_node.visible = false

## Get the currently equipped item ID
func get_selected_item() -> String:
	return current_item_id

## Check if a specific item is equipped
func is_item_equipped(item_id: String) -> bool:
	return current_item_id == item_id
