extends CharacterBody3D

## Player controller with farming system integration

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
# Hotbar System
@onready var inventory: Inventory = $Inventory
@onready var equipment_manager: EquipmentManager = $EquipmentManager

# Existing hand nodes
@onready var yam_seed_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/yam_seed_hand
@onready var potato_seed_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/potato_seed_hand
@onready var casava_seed_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/casava_seed_hand
@onready var rake_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/rake_hand
@onready var fork_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/fork_hand
@onready var hoe_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/hoe_hand

var current_equipped_item_id: String = ""

@onready var view_model_camera: Camera3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera
@onready var item_bar: Control = $CanvasLayer/ItemBar
@onready var hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig

var mouse_sense = 0.1

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var ray_cast_3d: RayCast3D = $head/Camera3D/RayCast3D

var lastRaycastCollision
var currentTool: Node3D = null
var onAction: bool = false

# Inventory for harvested crops
var harvested_crops: Dictionary = {}
var seeds_count: int = 10  # Starting seeds

# UI Reference (we'll create this)
var interaction_label: Label = null

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$head/Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	
	# Connect item bar signal
	item_bar.item_changed.connect(_on_item_changed)
	
	# Initialize inventory with selected seed from GameManager
	_initialize_selected_seed()
	
	# Create interaction prompt UI
	_create_interaction_ui()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Initialize equipment manager with your existing hand nodes
	equipment_manager.initialize_hand_nodes(
		yam_seed_hand,
		potato_seed_hand,
		casava_seed_hand,
		rake_hand,
		fork_hand,
		hoe_hand
	)

	# Setup starting inventory
	var yam = preload("res://resources/items/yam_seed.tres")
	var potato = preload("res://resources/items/potato_seed.tres")
	var casava = preload("res://resources/items/casava_seed.tres")
	var rake = preload("res://resources/items/rake.tres")
	var fork = preload("res://resources/items/fork.tres")
	var hoe = preload("res://resources/items/hoe.tres")

	inventory.set_slot(0, yam, 10)
	inventory.set_slot(1, potato, 15)
	inventory.set_slot(2, casava, 8)
	inventory.set_slot(3, rake, 1)
	inventory.set_slot(4, fork, 1)
	inventory.set_slot(5, hoe, 1)

	# Connect hotbar signals
	var hotbar = $CanvasLayer/Hotbar  # Adjust if your path is different
	hotbar.item_selected.connect(_on_hotbar_item_selected)


func _create_interaction_ui():
	"""Create on-screen interaction prompt"""
	if not has_node("CanvasLayer/InteractionPrompt"):
		interaction_label = Label.new()
		interaction_label.name = "InteractionPrompt"
		interaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		interaction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Position in center-bottom of screen
		interaction_label.anchor_left = 0.5
		interaction_label.anchor_right = 0.5
		interaction_label.anchor_top = 0.7
		interaction_label.anchor_bottom = 0.7
		interaction_label.offset_left = -200
		interaction_label.offset_right = 200
		interaction_label.offset_top = 0
		interaction_label.offset_bottom = 50
		
		# Style
		interaction_label.add_theme_font_size_override("font_size", 20)
		interaction_label.modulate = Color(1, 1, 1, 0.9)
		
		$CanvasLayer.add_child(interaction_label)
		interaction_label.hide()


func _initialize_selected_seed() -> void:
	"""Add the selected seed to the inventory if one was chosen."""
	var selected_seed: ITEM_BAR_ITEM = GameManager.get_selected_seed()
	
	if selected_seed:
		# Add to slot 2 (slots 0 and 1 typically have tools)
		if item_bar.itemBarInventory.size() > 2:
			item_bar.itemBarInventory[2] = selected_seed
			item_bar._refresh()
			print("Added selected seed to inventory: ", GameManager.selected_crop)
		else:
			push_error("ItemBar inventory array is too small")
	else:
		print("No seed selected from menu, using default inventory")

func _unhandled_input(event):
	# Handle harvesting with E key
	if event.is_action_pressed("ui_cancel"):  # E key (using ui_cancel as placeholder)
		if ray_cast_3d.is_colliding():
			var collider = ray_cast_3d.get_collider()
			if collider and collider.has_method("can_harvest") and collider.can_harvest():
				_harvest_plant(collider)
				return
	
	# Handle tool interaction with Q key
	if event.is_action_pressed("actionQ") and not onAction:
		if ray_cast_3d.is_colliding():
			var collider = ray_cast_3d.get_collider()
			var currentItem = item_bar.get_current_item()
			
			# Check if planting a seed
			if currentItem and currentItem.itemType == ITEM_BAR_ITEM.ITEM_TYPES.SEED:
				if collider and collider.has_method("plant_seed"):
					if seeds_count > 0:
						var planted = collider.plant_seed(currentItem)
						if planted:
							seeds_count -= 1
							print("Seed planted! Seeds remaining: ", seeds_count)
							_update_seed_display()
					else:
						print("No seeds remaining!")
						_show_interaction_prompt("No Seeds!", 1.0)
			# Check if using a tool
			elif collider and collider.has_method("tool_interaction"):
				if _check_using_tool(currentItem):
					_use_tool(currentItem.itemType)

func _harvest_plant(soil):
	"""Harvest a fully grown plant"""
	if not soil.has_method("harvest_plant"):
		return
	
	onAction = true
	var harvest_data = soil.harvest_plant()
	
	if harvest_data.get("success", false):
		var crop_name = harvest_data.get("crop_name", "crop")
		var amount = harvest_data.get("amount", 1)
		
		# Add to inventory
		if harvested_crops.has(crop_name):
			harvested_crops[crop_name] += amount
		else:
			harvested_crops[crop_name] = amount
		
		print("Harvested %d x %s! Total: %d" % [amount, crop_name, harvested_crops[crop_name]])
		_show_interaction_prompt("Harvested %s!" % crop_name, 1.5)
		_update_harvest_display()
	
	onAction = false

func _show_interaction_prompt(text: String, duration: float = 0.0):
	"""Show interaction prompt to player"""
	if interaction_label:
		interaction_label.text = text
		interaction_label.show()
		
		if duration > 0:
			await get_tree().create_timer(duration).timeout
			interaction_label.hide()

func _update_interaction_prompt():
	"""Update interaction prompt based on what player is looking at"""
	if not interaction_label:
		return
	
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider and collider.has_method("get_interaction_prompt"):
			var prompt = collider.get_interaction_prompt()
			if prompt and not prompt.is_empty():
				_show_interaction_prompt(prompt)
				return
	
	interaction_label.hide()

func _update_seed_display():
	"""Update UI to show seed count - placeholder for now"""
	# This can be connected to actual UI later
	pass

func _update_harvest_display():
	"""Update UI to show harvested crops - placeholder for now"""
	# This can be connected to actual UI later
	pass

func get_harvested_crops() -> Dictionary:
	"""Return harvested crops inventory"""
	return harvested_crops.duplicate()

func get_seeds_count() -> int:
	"""Return remaining seeds"""
	return seeds_count

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		view_model_camera.sway(Vector2(event.relative.x, event.relative.y))
	
	# Handle item bar navigation
	if event.is_action_pressed("weapon_1"):
		_select_slot(0)
	elif event.is_action_pressed("weapon_2"):
		_select_slot(1)
	elif event.is_action_pressed("3"):
		_select_slot(2)
	
	# Handle scroll wheel for item bar
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_navigate_item_bar(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_navigate_item_bar(1)

func _physics_process(delta: float) -> void:
	$head/Camera3D/SubViewportContainer/SubViewport/view_model_camera.global_transform = camera.global_transform
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if ray_cast_3d.is_colliding():
		_on_raycast_collision()
		_update_interaction_prompt()
	else:
		if interaction_label:
			interaction_label.hide()

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _on_raycast_collision():
	var collider = ray_cast_3d.get_collider()
	
	if lastRaycastCollision and lastRaycastCollision.has_method("set_selection"):
		lastRaycastCollision.set_selection(false)
	
	if collider.has_method("set_selection"):
		collider.set_selection(true)
		
	lastRaycastCollision = collider

func _on_item_changed(item: ITEM_BAR_ITEM):
	# Remove current tool if exists
	if currentTool:
		currentTool.queue_free()
		currentTool = null
	
	# Add new tool if item has one
	if item and item.toolScene:
		currentTool = item.toolScene.instantiate()
		hand.add_child(currentTool)

func _select_slot(index: int):
	var slot_container = item_bar.get_node("%slotContainer")
	if index < slot_container.get_child_count():
		var slot = slot_container.get_child(index)
		slot.grab_focus()

func _navigate_item_bar(direction: int):
	var slot_container = item_bar.get_node("%slotContainer")
	var focused = slot_container.get_viewport().gui_get_focus_owner()
	
	if focused:
		var current_index = focused.get_index()
		var new_index = current_index + direction
		
		# Wrap around
		if new_index < 0:
			new_index = slot_container.get_child_count() - 1
		elif new_index >= slot_container.get_child_count():
			new_index = 0
		
		_select_slot(new_index)

func _check_using_tool(currentItem: ITEM_BAR_ITEM) -> bool:
	if currentItem == null:
		return false
	
	# Check if the current item is a valid farming tool
	match currentItem.itemType:
		ITEM_BAR_ITEM.ITEM_TYPES.HOE, ITEM_BAR_ITEM.ITEM_TYPES.WATERING_CAN:
			return true
		_:
			return false

func _use_tool(toolType: ITEM_BAR_ITEM.ITEM_TYPES):
	onAction = true
	set_physics_process(false)
	
	# Play tool animation
	await get_tree().create_timer(0.5).timeout
	
	# Re-enable physics processing
	set_physics_process(true)
	
	# Call tool_interaction on the target
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider and collider.has_method("tool_interaction"):
			collider.tool_interaction(toolType)
	
	onAction = false

func _on_hotbar_item_selected(item_id: String, slot_index: int) -> void:
	"""Called when player changes hotbar slot"""
	current_equipped_item_id = item_id
	equipment_manager.equip_item(item_id)
	print("[Player] Equipped: ", item_id if not item_id.is_empty() else "Nothing")

func get_equipped_item_id() -> String:
	"""Get currently equipped item ID"""
	return current_equipped_item_id

func is_holding_item(item_id: String) -> bool:
	"""Check if specific item is equipped"""
	return current_equipped_item_id == item_id
