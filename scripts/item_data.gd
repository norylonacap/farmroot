extends Resource
class_name ItemData

## Resource that defines an item's properties
## Used for inventory management and UI display

@export var item_id: String = ""
@export var item_name: String = ""
@export var item_description: String = ""
@export var item_icon: Texture2D = null
@export var max_stack: int = 64
@export var is_tool: bool = false  # Tools don't show quantity
@export var hand_node_name: String = ""  # Name of the hand node in view_model
