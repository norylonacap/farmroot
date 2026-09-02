extends Node

# Day/Night cycle manager for plant growth
# Attach this to your main scene or game controller

signal day_advanced(day_number: int)

@export var seconds_per_day: float = 60.0  # Real-time seconds per in-game day

var current_day: int = 1
var day_timer: float = 0.0
var paused: bool = false

func _ready():
	# Add to group for easy access
	add_to_group("day_manager")
	
	# Add plants to a group when instantiated
	# This allows us to find all plants easily
	pass

func _process(delta: float):
	if paused:
		return
	
	day_timer += delta
	
	if day_timer >= seconds_per_day:
		advance_day()
		day_timer = 0.0

func advance_day():
	current_day += 1
	print("Day ", current_day, " has begun!")
	
	# Advance all plants by one day
	_advance_all_plants()
	
	day_advanced.emit(current_day)

func _advance_all_plants():
	# Find all plant instances in the scene
	var plants = get_tree().get_nodes_in_group("plants")
	
	print("Advancing ", plants.size(), " plants")
	
	for plant in plants:
		if plant.has_method("advance_day"):
			plant.advance_day()

func skip_day():
	# Manual day skip (e.g., sleep function)
	advance_day()

func pause_time():
	paused = true

func resume_time():
	paused = false

func get_current_day() -> int:
	return current_day

func get_day_progress() -> float:
	# Returns 0.0 to 1.0 representing progress through current day
	return day_timer / seconds_per_day
