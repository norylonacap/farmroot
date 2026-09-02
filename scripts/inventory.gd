extends Node
class_name Inventory

## Manages the player's inventory
## Stores items and quantities for each slot

signal inventory_changed(slot_index: int)

const HOTBAR_SIZE: int = 6

# Structure: { item_data: ItemData, quantity: int }
var slots: Array[Dictionary] = []

func _ready() -> void:
	# Initialize empty slots
	for i in range(HOTBAR_SIZE):
		slots.append({"item_data": null, "quantity": 0})

## Get the item and quantity in a specific slot
func get_slot(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= HOTBAR_SIZE:
		return {"item_data": null, "quantity": 0}
	return slots[slot_index]

## Check if a slot is empty
func is_slot_empty(slot_index: int) -> bool:
	return slots[slot_index].item_data == null

## Add an item to the inventory
## Returns true if successful, false if inventory is full
func add_item(item: ItemData, quantity: int = 1) -> bool:
	if item == null or quantity <= 0:
		return false
	
	var remaining_quantity = quantity
	
	# First, try to stack with existing items
	for i in range(HOTBAR_SIZE):
		if slots[i].item_data == item:
			var space_available = item.max_stack - slots[i].quantity
			if space_available > 0:
				var amount_to_add = min(remaining_quantity, space_available)
				slots[i].quantity += amount_to_add
				remaining_quantity -= amount_to_add
				inventory_changed.emit(i)
				
				if remaining_quantity <= 0:
					return true
	
	# Then, try to fill empty slots
	while remaining_quantity > 0:
		var empty_slot_index = _find_empty_slot()
		if empty_slot_index == -1:
			# Inventory full
			print("Inventory full! Could not add ", remaining_quantity, " more ", item.item_name)
			return false
		
		var amount_to_add = min(remaining_quantity, item.max_stack)
		slots[empty_slot_index].item_data = item
		slots[empty_slot_index].quantity = amount_to_add
		remaining_quantity -= amount_to_add
		inventory_changed.emit(empty_slot_index)
	
	return true

## Remove an item from a specific slot
func remove_item(slot_index: int, quantity: int = 1) -> void:
	if slot_index < 0 or slot_index >= HOTBAR_SIZE:
		return
	
	if slots[slot_index].item_data == null:
		return
	
	slots[slot_index].quantity -= quantity
	
	if slots[slot_index].quantity <= 0:
		slots[slot_index].item_data = null
		slots[slot_index].quantity = 0
	
	inventory_changed.emit(slot_index)

## Set a specific slot's contents
func set_slot(slot_index: int, item: ItemData, quantity: int) -> void:
	if slot_index < 0 or slot_index >= HOTBAR_SIZE:
		return
	
	slots[slot_index].item_data = item
	slots[slot_index].quantity = quantity
	inventory_changed.emit(slot_index)

## Find the first empty slot
func _find_empty_slot() -> int:
	for i in range(HOTBAR_SIZE):
		if slots[i].item_data == null:
			return i
	return -1

## Clear all slots
func clear_inventory() -> void:
	for i in range(HOTBAR_SIZE):
		slots[i].item_data = null
		slots[i].quantity = 0
		inventory_changed.emit(i)
