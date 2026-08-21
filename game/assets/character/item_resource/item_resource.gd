extends Resource
class_name ITEM_BAR_ITEM

enum ITEM_TYPES{HOE, C_TOOL}

@export var texture: CompressedTexture2D
@export var itemType: ITEM_TYPES
@export var toolScene: PackedScene
