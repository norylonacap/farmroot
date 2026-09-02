extends Resource
class_name ITEM_BAR_ITEM

enum ITEM_TYPES{NONE, HOE, WATERING_CAN, C_TOOL, SEED}

@export var texture: CompressedTexture2D
@export var itemType: ITEM_TYPES
@export var toolScene: PackedScene
@export var plantResource: PLANT_RESOURCE
