extends Control

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var loading_label: Label = %LoadingLabel

const PRELOAD_PATHS: Array[String] = [
	GameManager.MAIN_MENU_SCENE,
	GameManager.CROP_SELECTION_SCENE,
	GameManager.CREDITS_SCENE,
	GameManager.GAMEPLAY_SCENE,
	"res://game/scene/player.tscn",
	"res://game/assets/character/item_resource/potato_seed.tres",
	"res://game/assets/character/item_resource/casava_seed.tres",
	"res://game/assets/character/item_resource/yam_seed.tres",
]

var _current_index: int = 0
var _loading_active: bool = false


func _ready() -> void:
	_current_index = 0
	_loading_active = true
	progress_bar.value = 0.0
	_start_next_load()


func _process(_delta: float) -> void:
	if not _loading_active:
		return

	if _current_index >= PRELOAD_PATHS.size():
		_finish_loading()
		return

	var path := PRELOAD_PATHS[_current_index]
	var progress_array: Array = []
	var status := ResourceLoader.load_threaded_get_status(path, progress_array)
	var step_progress: float = progress_array[0] if progress_array.size() > 0 else 0.0
	progress_bar.value = ((float(_current_index) + step_progress) / float(PRELOAD_PATHS.size())) * 100.0

	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			ResourceLoader.load_threaded_get(path)
			_current_index += 1
			if _current_index < PRELOAD_PATHS.size():
				_start_next_load()
			else:
				_finish_loading()
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("LoadingScreen: failed to load %s" % path)
			_current_index += 1
			if _current_index < PRELOAD_PATHS.size():
				_start_next_load()
			else:
				_finish_loading()
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("LoadingScreen: invalid resource %s" % path)
			_current_index += 1
			if _current_index < PRELOAD_PATHS.size():
				_start_next_load()
			else:
				_finish_loading()


func _start_next_load() -> void:
	if _current_index >= PRELOAD_PATHS.size():
		return
	ResourceLoader.load_threaded_request(PRELOAD_PATHS[_current_index])


func _finish_loading() -> void:
	_loading_active = false
	progress_bar.value = 100.0
	loading_label.text = "Loading... Done"
	await get_tree().create_timer(0.35).timeout
	GameManager.go_to_scene(GameManager.MAIN_MENU_SCENE)
