extends Node

# One entry per field tile: { "id": ..., "soil": null or {...}, "plant": null or { "resource": ..., "age": ... } }
var farm: Array = []
var loading_scene_path := ""
var harvested_crops: Dictionary = {}
var tutorial_progress: Dictionary = {}
var saved_game_available := false
var sprayer_ppe_dialogue_shown := false

signal harvest_collected(crop_name: String, total: int)
signal day_changed

const FARM_THEME: AudioStreamMP3 = preload("res://game/assets/music/farm_theme.mp3")
const HARVEST_SOUND: AudioStream = preload("res://game/assets/music/colect.mp3")
var harvest_audio_player: AudioStreamPlayer

func _ready() -> void:
	var music := AudioStreamPlayer.new()
	music.name = "FarmThemeMusic"
	music.process_mode = Node.PROCESS_MODE_ALWAYS
	music.bus = "Master"
	var music_stream := FARM_THEME.duplicate() as AudioStreamMP3
	music_stream.loop = true
	music.stream = music_stream
	music.volume_db = -3.0
	add_child(music)
	music.play()
	harvest_audio_player = AudioStreamPlayer.new()
	harvest_audio_player.name = "HarvestSound"
	harvest_audio_player.stream = HARVEST_SOUND
	add_child(harvest_audio_player)

func _input(event: InputEvent) -> void:
	# Check the event itself so this only fires once per press
	# (not on key release or key-repeat).
	if event is InputEventKey and event.pressed and not event.echo and (event.is_action_pressed("F1") or event.keycode == KEY_F1 or event.physical_keycode == KEY_F1):
		_next_day()

func _next_day():
	next_day()

func next_day():
	# Age every plant by one day BEFORE saving, so the new age is what gets saved.
	get_tree().call_group("plants", "advance_day")
	get_tree().call_group("soils", "advance_day")
	save_farm()
	day_changed.emit()

func save_farm():
	farm.clear()

	for ground in get_tree().get_nodes_in_group("ground"):
		if not ground.is_queued_for_deletion():
			farm.append(ground.get_save_data())
	if loading_scene_path.is_empty():
		return
	var players := get_tree().get_nodes_in_group("player_character")
	if not players.is_empty() and players[0].has_method("get_planting_tutorial_data"):
		tutorial_progress = players[0].get_planting_tutorial_data()
	saved_game_available = true

func has_saved_game() -> bool:
	return saved_game_available and not loading_scene_path.is_empty() and not farm.is_empty()

func start_new_farm(scene_path: String) -> void:
	loading_scene_path = scene_path
	farm.clear()
	harvested_crops.clear()
	tutorial_progress.clear()
	saved_game_available = false
	sprayer_ppe_dialogue_shown = false

func continue_saved_game() -> bool:
	return has_saved_game()

func collect_harvest(plant_resource: PLANT_RESOURCE) -> void:
	if plant_resource == null or plant_resource.resource_path == "":
		return
	harvest_audio_player.play()
	var crop_name := plant_resource.resource_path.get_file().get_basename().replace("_resource", "").replace("casava", "cassava")
	var total: int = harvested_crops.get(crop_name, 0) + 1
	harvested_crops[crop_name] = total
	harvest_collected.emit(crop_name, total)
