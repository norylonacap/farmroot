extends Label

# Display the current day number
# Attach this script to a Label node in your UI

@export var day_manager_path: NodePath
var day_manager: Node

func _ready():
	if day_manager_path:
		day_manager = get_node(day_manager_path)
		if day_manager:
			day_manager.day_advanced.connect(_on_day_advanced)
			_update_display()

func _update_display():
	if day_manager:
		text = "Day: %d" % day_manager.get_current_day()

func _on_day_advanced(day_number: int):
	_update_display()
