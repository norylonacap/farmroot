extends Control
class_name Hotbar

## Manages the hotbar UI and player interaction
## Handles slot selection, input, and visual updates

signal item_selected(item_id: String, slot_index: int)

@export var inventory: Inventory = null

@onready var slots_container: HBoxContainer = $HBoxContainer

var slots: Array[HotbarSlot] = []
var selected_slot: int = 0

func _ready() -> void:
	# Get all slot nodes
	for child in slots_container.get_children():
		if child is HotbarSlot:
			var slot = child as HotbarSlot
			slot.slot_index = slots.size()
			slots.append(slot)
	
	# Connect to inventory signals
	if inventory:
		inventory.inventory_changed.connect(_on_inventory_changed)
		# Initialize all slots
		for i in range(slots.size()):
			_update_slot_display(i)
	
	# Set initial selection
	select_slot(0)

func _input(event: InputEvent) -> void:
	# Number key selection (1-6)
	for i in range(6):
		if event.is_action_pressed("hotbar_" + str(i + 1)):
			select_slot(i)
			return
	
	# Next/Previous hotbar slot
	if event.is_action_pressed("hotbar_next"):
		select_next_slot()
	elif event.is_action_pressed("hotbar_previous"):
		select_previous_slot()
	
	# Mouse wheel scrolling
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			select_previous_slot()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			select_next_slot()

## Select a specific hotbar slot
func select_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
	
	# Deselect previous slot
	if selected_slot >= 0 and selected_slot < slots.size():
		slots[selected_slot].set_selected(false)
	
	# Select new slot
	selected_slot = slot_index
	slots[selected_slot].set_selected(true)
	
	# Emit signal with selected item ID
	var selected_item = get_selected_item()
	var item_id = selected_item.item_id if selected_item else ""
	item_selected.emit(item_id, selected_slot)
	
	# Debug print
	print("Selected Slot: ", selected_slot + 1)
	if selected_item:
		print("Selected Item: ", selected_item.item_name)
		print("Item ID: ", selected_item.item_id)
		if not selected_item.is_tool:
			print("Quantity: ", inventory.get_slot(selected_slot).quantity)
	else:
		print("Selected Item: None")

## Select the next hotbar slot (wraps around)
func select_next_slot() -> void:
	var next_slot = (selected_slot + 1) % slots.size()
	select_slot(next_slot)

## Select the previous hotbar slot (wraps around)
func select_previous_slot() -> void:
	var prev_slot = (selected_slot - 1) % slots.size()
	if prev_slot < 0:
		prev_slot = slots.size() - 1
	select_slot(prev_slot)

## Get the currently selected item
func get_selected_item() -> ItemData:
	if not inventory:
		return null
	var slot_data = inventory.get_slot(selected_slot)
	return slot_data.item_data

## Get the currently selected slot index
func get_selected_slot() -> int:
	return selected_slot

## Get the quantity of the selected item
func get_selected_quantity() -> int:
	if not inventory:
		return 0
	var slot_data = inventory.get_slot(selected_slot)
	return slot_data.quantity

## Called when inventory changes
func _on_inventory_changed(slot_index: int) -> void:
	_update_slot_display(slot_index)

## Update the display for a specific slot
func _update_slot_display(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
	
	if not inventory:
		return
	
	var slot_data = inventory.get_slot(slot_index)
	slots[slot_index].set_item(slot_data.item_data, slot_data.quantity)
