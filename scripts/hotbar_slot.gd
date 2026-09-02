extends PanelContainer
class_name HotbarSlot

## Individual slot UI component for the hotbar
## Displays item icon, quantity, and selection state

@onready var item_icon: TextureRect = $MarginContainer/ItemIcon
@onready var quantity_label: Label = $QuantityLabel
@onready var selection_highlight: Panel = $SelectionHighlight

var slot_index: int = 0
var item_data: ItemData = null
var quantity: int = 0
var is_selected: bool = false

func _ready() -> void:
	selection_highlight.visible = false
	update_display()

## Update the visual display of this slot
func update_display() -> void:
	if item_data == null or quantity <= 0:
		# Empty slot
		item_icon.texture = null
		item_icon.visible = false
		quantity_label.visible = false
	else:
		# Slot has an item
		item_icon.texture = item_data.item_icon
		item_icon.visible = true
		
		# Show quantity only for non-tools and if more than 1
		if item_data.is_tool:
			quantity_label.visible = false
		elif quantity > 1:
			quantity_label.text = str(quantity)
			quantity_label.visible = true
		else:
			quantity_label.visible = false

## Set the item and quantity for this slot
func set_item(new_item: ItemData, new_quantity: int) -> void:
	item_data = new_item
	quantity = new_quantity
	update_display()

## Set whether this slot is selected
func set_selected(selected: bool) -> void:
	is_selected = selected
	selection_highlight.visible = selected
	
	# Animate selection
	if selected:
		animate_select()
	else:
		animate_deselect()

## Smooth scale animation when selected
func animate_select() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)

## Smooth scale animation when deselected
func animate_deselect() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
