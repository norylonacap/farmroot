extends StaticBody3D

const SOIL = preload("res://game/scene/soil.tscn")

@onready var selection_mesh: MeshInstance3D = %selectionMesh
@onready var objects: Node3D = $objects

var hasSoil: bool = false

func _ready() -> void:
	selection_mesh.hide()
	
	# Create objects container if it doesn't exist
	if not has_node("objects"):
		objects = Node3D.new()
		objects.name = "objects"
		add_child(objects)
	
func set_selection(boolean: bool):
	selection_mesh.visible = boolean

func tool_interaction(toolType: ITEM_BAR_ITEM.ITEM_TYPES):
	match toolType:
		ITEM_BAR_ITEM.ITEM_TYPES.HOE:
			if not hasSoil:
				_add_soil()
		_:
			# If soil exists, pass tool interaction to it
			if hasSoil and objects.get_child_count() > 0:
				for child in objects.get_children():
					if child.has_method("tool_interaction"):
						child.tool_interaction(toolType)

func _add_soil():
	hasSoil = true
	var soil_instance = SOIL.instantiate()
	objects.add_child(soil_instance)
	
	# Adjust soil position (slightly above the ground)
	soil_instance.position.y = 0.05
