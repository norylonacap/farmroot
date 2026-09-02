extends Control

signal item_changed(item:ITEM_BAR_ITEM)

@onready var slot_container: HBoxContainer = %slotContainer

var itemBarInventory: Array[Resource] = []
var currentItem: ITEM_BAR_ITEM = null

func _ready() -> void:
	_refresh()
	
	_set_signals()
	
	_set_first_focus()

func _refresh():
	for i in slot_container.get_child_count():
		var slot = slot_container.get_child(i)
		slot.set_item(itemBarInventory[i])

func _set_signals():
	for slot in slot_container.get_children():
		slot.selected.connect(_on_slot_selected.bind(slot))

func _on_slot_selected(slot):
	currentItem = slot.get_item()
	item_changed.emit(currentItem)

func _set_first_focus():
	await get_tree().process_frame
	var selectedSlot = slot_container.get_child(0)
	selectedSlot.grab_focus()

func get_current_item() -> ITEM_BAR_ITEM:
	return currentItem
