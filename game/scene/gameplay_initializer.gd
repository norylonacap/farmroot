extends Node

## Initializes the gameplay scene with the selected crop from the crop selection menu.

@export var player: CharacterBody3D


func _ready() -> void:
	# Wait for everything to be ready
	await get_tree().process_frame
	
	# Get the selected seed from GameManager
	var selected_seed: ITEM_BAR_ITEM = GameManager.get_selected_seed()
	
	if selected_seed and player:
		# Get the item bar from the player
		var item_bar = player.get_node_or_null("CanvasLayer/ItemBar")
		
		if item_bar:
			# Add the selected seed to slot 2 (slots 0 and 1 have tools)
			if item_bar.itemBarInventory.size() > 2:
				item_bar.itemBarInventory[2] = selected_seed
				item_bar._refresh()
				print("Initialized gameplay with selected crop: ", GameManager.selected_crop)
			else:
				push_error("ItemBar inventory array is too small")
		else:
			push_error("Could not find ItemBar in player")
	elif not selected_seed:
		push_warning("No crop was selected, starting with default inventory")
