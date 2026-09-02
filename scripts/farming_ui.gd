extends CanvasLayer
class_name FarmingUI

## UI for the farming/planting system
## Shows inventory, selected seed, and interaction prompts

@export_group("References")
@export var inventory: Inventory
@export var player_interaction: PlayerInteraction

@export_group("UI Elements")
@export var selected_seed_label: Label
@export var seed_count_label: Label
@export var interaction_prompt_label: Label
@export var inventory_display: VBoxContainer
@export var crosshair: Control

## Update UI every frame
var update_timer: float = 0.0
var update_interval: float = 0.1  # Update 10 times per second


func _ready() -> void:
	_create_default_ui()
	_connect_signals()
	_update_ui()


func _create_default_ui() -> void:
	# Create basic UI if not assigned in editor
	
	# Selected seed display (top-left)
	if selected_seed_label == null:
		selected_seed_label = Label.new()
		selected_seed_label.name = "SelectedSeedLabel"
		selected_seed_label.position = Vector2(20, 20)
		selected_seed_label.add_theme_font_size_override("font_size", 20)
		add_child(selected_seed_label)
	
	if seed_count_label == null:
		seed_count_label = Label.new()
		seed_count_label.name = "SeedCountLabel"
		seed_count_label.position = Vector2(20, 50)
		seed_count_label.add_theme_font_size_override("font_size", 16)
		add_child(seed_count_label)
	
	# Interaction prompt (bottom-center)
	if interaction_prompt_label == null:
		interaction_prompt_label = Label.new()
		interaction_prompt_label.name = "InteractionPromptLabel"
		interaction_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		interaction_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		interaction_prompt_label.anchor_left = 0.5
		interaction_prompt_label.anchor_right = 0.5
		interaction_prompt_label.anchor_top = 1.0
		interaction_prompt_label.anchor_bottom = 1.0
		interaction_prompt_label.offset_left = -200
		interaction_prompt_label.offset_right = 200
		interaction_prompt_label.offset_top = -100
		interaction_prompt_label.offset_bottom = -50
		interaction_prompt_label.add_theme_font_size_override("font_size", 18)
		add_child(interaction_prompt_label)
	
	# Crosshair (center)
	if crosshair == null:
		crosshair = Control.new()
		crosshair.name = "Crosshair"
		var crosshair_panel := Panel.new()
		crosshair_panel.anchor_left = 0.5
		crosshair_panel.anchor_right = 0.5
		crosshair_panel.anchor_top = 0.5
		crosshair_panel.anchor_bottom = 0.5
		crosshair_panel.offset_left = -2
		crosshair_panel.offset_right = 2
		crosshair_panel.offset_top = -2
		crosshair_panel.offset_bottom = 2
		crosshair.add_child(crosshair_panel)
		add_child(crosshair)
	
	# Inventory display (right side)
	if inventory_display == null:
		inventory_display = VBoxContainer.new()
		inventory_display.name = "InventoryDisplay"
		inventory_display.anchor_left = 1.0
		inventory_display.anchor_right = 1.0
		inventory_display.offset_left = -250
		inventory_display.offset_right = -20
		inventory_display.offset_top = 20
		inventory_display.offset_bottom = 300
		add_child(inventory_display)
		
		# Add title
		var title := Label.new()
		title.text = "INVENTORY"
		title.add_theme_font_size_override("font_size", 18)
		inventory_display.add_child(title)


func _connect_signals() -> void:
	if inventory:
		inventory.inventory_updated.connect(_update_ui)
		inventory.selected_item_changed.connect(_on_selected_item_changed)
	
	if player_interaction:
		player_interaction.interaction_target_changed.connect(_on_interaction_target_changed)


func _process(delta: float) -> void:
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		_update_interaction_prompt()


func _update_ui() -> void:
	_update_selected_seed()
	_update_inventory_display()


func _update_selected_seed() -> void:
	if inventory == null:
		return
	
	var selected := inventory.get_selected_item()
	
	if selected.is_empty():
		selected_seed_label.text = "No seed selected"
		selected_seed_label.modulate = Color(0.7, 0.7, 0.7)
		seed_count_label.text = "[Q/E] to select seed"
	else:
		selected_seed_label.text = selected
		selected_seed_label.modulate = Color(1, 1, 1)
		var count := inventory.get_item_count(selected)
		seed_count_label.text = "Count: %d" % count


func _update_inventory_display() -> void:
	if inventory == null or inventory_display == null:
		return
	
	# Clear existing items (except title)
	for child in inventory_display.get_children():
		if child.name != "Title" and child is Label and child.text != "INVENTORY":
			child.queue_free()
	
	# Add all items
	var items := inventory.get_all_items()
	if items.is_empty():
		var empty_label := Label.new()
		empty_label.text = "  (empty)"
		empty_label.modulate = Color(0.7, 0.7, 0.7)
		inventory_display.add_child(empty_label)
	else:
		for item_name in items.keys():
			var item_label := Label.new()
			var count := items[item_name]
			var is_selected := (item_name == inventory.get_selected_item())
			var prefix := "► " if is_selected else "  "
			item_label.text = "%s%s x%d" % [prefix, item_name, count]
			
			if is_selected:
				item_label.modulate = Color(0.5, 1.0, 0.5)
			else:
				item_label.modulate = Color(1, 1, 1)
			
			inventory_display.add_child(item_label)


func _update_interaction_prompt() -> void:
	if player_interaction == null or interaction_prompt_label == null:
		return
	
	var prompt := player_interaction.get_interaction_prompt()
	
	if not prompt.is_empty():
		interaction_prompt_label.text = "[E] " + prompt
		interaction_prompt_label.visible = true
		interaction_prompt_label.modulate = Color(1, 1, 0.5)
	elif player_interaction.can_plant():
		var seed_data := inventory.get_selected_seed_data()
		if seed_data:
			interaction_prompt_label.text = "[LEFT CLICK] Plant " + seed_data.seed_name
			interaction_prompt_label.visible = true
			interaction_prompt_label.modulate = Color(0.5, 1, 0.5)
	else:
		interaction_prompt_label.visible = false


func _on_selected_item_changed(_item_name: String) -> void:
	_update_ui()


func _on_interaction_target_changed(_target: Node3D, _is_valid: bool) -> void:
	_update_interaction_prompt()


## Show a temporary message
func show_message(message: String, duration: float = 2.0) -> void:
	if interaction_prompt_label:
		interaction_prompt_label.text = message
		interaction_prompt_label.visible = true
		interaction_prompt_label.modulate = Color(1, 0.5, 0.5)
		
		await get_tree().create_timer(duration).timeout
		_update_interaction_prompt()


## Toggle inventory display
func toggle_inventory_display() -> void:
	if inventory_display:
		inventory_display.visible = not inventory_display.visible
