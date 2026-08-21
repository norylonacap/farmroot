extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var view_model_camera: Camera3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera
@onready var item_bar: Control = $CanvasLayer/ItemBar
@onready var hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig

var mouse_sense = 0.1

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var ray_cast_3d: RayCast3D = $head/Camera3D/RayCast3D

var lastRaycastCollision
var currentTool: Node3D = null

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$head/Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	
	# Connect item bar signal
	item_bar.item_changed.connect(_on_item_changed)

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

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
