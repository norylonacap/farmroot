extends Camera3D

@onready var fps_rig: Node3D = $fps_rig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fps_rig.position.x = lerp(fps_rig.position.x, 0.0, delta * 5)
	fps_rig.position.y = lerp(fps_rig.position.y, 0.0, delta * 5)

func sway(sway_amount):
	fps_rig.position.x -= sway_amount.x * 0.00005
	fps_rig.position.y += sway_amount.y * 0.00005

func _input(event: InputEvent) -> void:
	# Handle tool-specific actions
	if event.is_action_pressed("dig"):
		# Check if current tool has an animation player
		for child in fps_rig.get_children():
			if child.has_node("AnimationPlayer"):
				var anim_player = child.get_node("AnimationPlayer")
				if anim_player.has_animation("dig"):
					anim_player.play("dig")
	
	if event.is_action_pressed("yhoe"):
		# Handle animation switching
		for child in fps_rig.get_children():
			if child.has_node("AnimationPlayer"):
				var anim_player = child.get_node("AnimationPlayer")
				if anim_player.has_animation("x") and anim_player.has_animation("y"):
					if anim_player.current_animation == "y":
						anim_player.play("x")
					else:
						anim_player.play("y")
	
		
