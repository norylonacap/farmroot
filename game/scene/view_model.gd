extends Camera3D

@onready var fps_rig: Node3D = $fps_rig
@onready var animation_player: AnimationPlayer = $fps_rig/hoe/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var hoe_in_use = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fps_rig.position.x = lerp(fps_rig.position.x,0.0,delta*5)
	fps_rig.position.y = lerp(fps_rig.position.y,0.0,delta*5)
	
func sway(sway_amount):
	fps_rig.position.x -= sway_amount.x*0.00005
	fps_rig.position.y += sway_amount.y*0.00005

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("dig")):
		animation_player.play("dig") 
		
	if(event.is_action_pressed("yhoe")):
		hoe_in_use = !hoe_in_use
		if(hoe_in_use):
			animation_player.play("x") 
		else:
			animation_player.play("y")
	
		
