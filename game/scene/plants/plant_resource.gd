extends Resource
class_name PLANT_RESOURCE

# Array of scenes representing each growth stage (e.g., seed, sprout, mature plant)
@export var stageScenes: Array[PackedScene] = []

# Array of days per stage (corresponds to stageScenes array)
@export var daysPerStage: Array[int] = []
