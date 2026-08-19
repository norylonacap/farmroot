@tool
extends Node3D


@export var width := 5:
	set(value):
		width = value
		if Engine.is_editor_hint() and is_inside_tree():
			_ready()
@export var height := 5:
	set(value):
		height = value
		if Engine.is_editor_hint() and is_inside_tree():
			_ready()
@export var margin := 0.2:
	set(value):
		margin = value
		if Engine.is_editor_hint() and is_inside_tree():
			_ready()
@export var cellSize := 2:
	set(value):
			cellSize = value
			if Engine.is_editor_hint() and is_inside_tree():
				_ready()

const FIELD = preload("res://game/scene/field.tscn")

func _ready() -> void:
	_remove_grid()
	_create_grid()
	
func _remove_grid():
	for node in get_children():
		node.queue_free() 
	
func _create_grid():
	for h in range(height):
		for w in range(width):
			var fieldNode = FIELD.instantiate()
			

			
			add_child(fieldNode)
			
			fieldNode.global_position = global_position + Vector3(
				w * cellSize + (w * margin),
				0,
				h * cellSize + (h * margin)
			)
			if Engine.is_editor_hint():
				fieldNode.owner = get_tree().edited_scene_root
