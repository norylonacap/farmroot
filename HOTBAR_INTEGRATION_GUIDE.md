# Hotbar Integration with Existing Hand Nodes - Complete Guide

## Overview

This updated hotbar system integrates with your **existing hand nodes** in the player scene. It controls which hand/tool is visible based on hotbar selection.

## What Was Created/Updated

### ✅ Updated Scripts
1. **scripts/item_data.gd** - Added `is_tool` and `hand_node_name` properties
2. **scripts/inventory.gd** - Changed to 6 slots (HOTBAR_SIZE = 6)
3. **scripts/hotbar_slot.gd** - Tools don't show quantity labels
4. **scripts/hotbar.gd** - Emits item_id (string) instead of ItemData
5. **scripts/equipment_manager.gd** - NEW: Manages hand visibility

### ✅ New Item Resources (6 items)
1. **resources/items/yam_seed.tres** - Yam Seed (max 64)
2. **resources/items/potato_seed.tres** - Potato Seed (max 64)
3. **resources/items/casava_seed.tres** - Casava Seed (max 64)
4. **resources/items/rake.tres** - Rake (tool)
5. **resources/items/fork.tres** - Fork (tool)
6. **resources/items/hoe.tres** - Hoe (tool)

### ✅ Updated UI
- **scenes/ui/hotbar.tscn** - Now 6 slots instead of 9

### ✅ Test Scene
- **scenes/test_hotbar_6slot.tscn** - Test scene with all 6 items

---

## Integration with Your Player Scene

### Step 1: Add Equipment Manager to Player Scene

Open `game/scene/player.tscn` in Godot editor and add an EquipmentManager node:

```
Player (CharacterBody3D)
├── [existing nodes...]
├── Inventory (Node) ← Add this
└── EquipmentManager (Node) ← Add this
```

1. Right-click on **Player** node → Add Child Node
2. Search for "Node" → Create
3. Rename it to "Inventory"
4. Attach script: `res://scripts/inventory.gd`

5. Right-click on **Player** node → Add Child Node again
6. Search for "Node" → Create
7. Rename it to "EquipmentManager"
8. Attach script: `res://scripts/equipment_manager.gd`

### Step 2: Update Player Script

Open `game/scene/player.gd` and add these changes:

#### Add References (at the top with other @onready variables)

```gdscript
# Hotbar System
@onready var inventory: Inventory = $Inventory
@onready var equipment_manager: EquipmentManager = $EquipmentManager

# Existing hand nodes
@onready var yam_seed_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/yam_seed_hand
@onready var potato_seed_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/potato_seed_hand
@onready var casava_seed_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/casava_seed_hand
@onready var rake_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/rake_hand
@onready var fork_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/fork_hand
@onready var hoe_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/hoe_hand

# Track current equipped item
var current_equipped_item_id: String = ""
```

#### Update _ready() function

```gdscript
func _ready():
	# Existing code...
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$head/Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	
	# Initialize equipment manager with hand nodes
	equipment_manager.initialize_hand_nodes(
		yam_seed_hand,
		potato_seed_hand,
		casava_seed_hand,
		rake_hand,
		fork_hand,
		hoe_hand
	)
	
	# Setup starting inventory
	_setup_starting_inventory()
	
	# Connect hotbar signals
	var hotbar = $CanvasLayer/Hotbar  # Adjust path if needed
	hotbar.item_selected.connect(_on_hotbar_item_selected)
	
	# ... rest of existing code
```

#### Add New Functions

```gdscript
func _setup_starting_inventory() -> void:
	"""Setup initial hotbar items"""
	var yam = preload("res://resources/items/yam_seed.tres")
	var potato = preload("res://resources/items/potato_seed.tres")
	var casava = preload("res://resources/items/casava_seed.tres")
	var rake = preload("res://resources/items/rake.tres")
	var fork = preload("res://resources/items/fork.tres")
	var hoe = preload("res://resources/items/hoe.tres")
	
	inventory.set_slot(0, yam, 10)
	inventory.set_slot(1, potato, 15)
	inventory.set_slot(2, casava, 8)
	inventory.set_slot(3, rake, 1)
	inventory.set_slot(4, fork, 1)
	inventory.set_slot(5, hoe, 1)

func _on_hotbar_item_selected(item_id: String, slot_index: int) -> void:
	"""Called when player selects a different hotbar slot"""
	current_equipped_item_id = item_id
	equipment_manager.equip_item(item_id)
	
	print("[Player] Equipped: ", item_id if not item_id.is_empty() else "Nothing")

## Get the currently equipped item ID
func get_equipped_item_id() -> String:
	return current_equipped_item_id

## Check if a specific item is equipped
func is_holding_item(item_id: String) -> bool:
	return current_equipped_item_id == item_id
```

### Step 3: Replace Existing Hotbar UI

Your player scene already has an ItemBar at `$CanvasLayer/ItemBar`. You need to **replace** it with the new Hotbar:

1. Open `game/scene/player.tscn`
2. Find the **ItemBar** node under CanvasLayer
3. Delete it
4. Right-click on CanvasLayer → Instance Child Scene
5. Choose `res://scenes/ui/hotbar.tscn`
6. Select the Hotbar node
7. In Inspector, find the `inventory` property
8. Drag the **Inventory** node (sibling of Player) into it

### Step 4: Configure Input Map

Open **Project → Project Settings → Input Map** and add:

| Action | Key |
|--------|-----|
| hotbar_1 | 1 |
| hotbar_2 | 2 |
| hotbar_3 | 3 |
| hotbar_4 | 4 |
| hotbar_5 | 5 |
| hotbar_6 | 6 |
| hotbar_next | E |
| hotbar_previous | Q |

---

## How the System Works

### Architecture

```
Player Script
├── References hand nodes from fps_rig
├── Creates EquipmentManager
├── Connects to Hotbar signals
└── Calls equipment_manager.equip_item(item_id)

EquipmentManager
├── Stores references to all hand nodes
├── equip_item(item_id) hides all hands, shows selected
└── get_selected_item() returns current item_id

Hotbar
├── Displays 6 slots
├── Handles input (1-6, mouse wheel, Q/E)
├── Emits item_selected(item_id, slot)
└── Reads from Inventory

Inventory
├── Stores 6 slots with ItemData + quantity
└── Handles stacking for seeds
```

### Data Flow: Selecting an Item

```
1. Player presses "3" key
   ↓
2. Hotbar detects input, calls select_slot(2)
   ↓
3. Hotbar updates visual highlight
   ↓
4. Hotbar emits: item_selected("casava_seed", 2)
   ↓
5. Player._on_hotbar_item_selected() receives signal
   ↓
6. Player calls: equipment_manager.equip_item("casava_seed")
   ↓
7. EquipmentManager hides all hands
   ↓
8. EquipmentManager shows casava_seed_hand
   ↓
9. current_equipped_item_id = "casava_seed"
```

### Item IDs Mapping

| Slot | Item Name | Item ID | Hand Node |
|------|-----------|---------|-----------|
| 1 | Yam Seed | `yam_seed` | `yam_seed_hand` |
| 2 | Potato Seed | `potato_seed` | `potato_seed_hand` |
| 3 | Casava Seed | `casava_seed` | `casava_seed_hand` |
| 4 | Rake | `rake` | `rake_hand` |
| 5 | Fork | `fork` | `fork_hand` |
| 6 | Hoe | `hoe` | `hoe_hand` |

---

## Using in Your Farming System

### Check What Player is Holding

```gdscript
# In your soil/planting script
func _on_player_interaction():
	var item_id = player.get_equipped_item_id()
	
	match item_id:
		"yam_seed":
			plant_yam()
		"potato_seed":
			plant_potato()
		"casava_seed":
			plant_casava()
		"hoe":
			till_soil()
		"rake":
			prepare_soil()
		"fork":
			interact_with_soil()
		_:
			print("No valid item equipped")
```

### Check Specific Item

```gdscript
if player.is_holding_item("potato_seed"):
	# Player is holding potato seeds
	plant_potato()
```

### Get Item Data

```gdscript
var hotbar = player.get_node("CanvasLayer/Hotbar")
var selected_item = hotbar.get_selected_item()

if selected_item:
	print("Holding: ", selected_item.item_name)
	print("Is tool: ", selected_item.is_tool)
```

### Get Quantity

```gdscript
var inventory = player.get_node("Inventory")
var hotbar = player.get_node("CanvasLayer/Hotbar")
var slot_index = hotbar.get_selected_slot()
var slot_data = inventory.get_slot(slot_index)

print("Quantity: ", slot_data.quantity)
```

### Remove Item After Use

```gdscript
# After planting a seed
var inventory = player.get_node("Inventory")
var hotbar = player.get_node("CanvasLayer/Hotbar")
var slot_index = hotbar.get_selected_slot()

inventory.remove_item(slot_index, 1)  # Remove 1 seed
```

---

## API Reference

### EquipmentManager

```gdscript
# Initialize (call in player _ready)
equipment_manager.initialize_hand_nodes(yam, potato, casava, rake, fork, hoe)

# Equip item
equipment_manager.equip_item("yam_seed")

# Get current item
var item_id: String = equipment_manager.get_selected_item()

# Check equipped
var is_equipped: bool = equipment_manager.is_item_equipped("rake")

# Hide all
equipment_manager.hide_all_hands()

# Signal
equipment_manager.equipment_changed.connect(func(item_id): print(item_id))
```

### Hotbar

```gdscript
# Get selected item
var item: ItemData = hotbar.get_selected_item()

# Get selected slot index
var slot: int = hotbar.get_selected_slot()

# Get quantity
var qty: int = hotbar.get_selected_quantity()

# Select specific slot
hotbar.select_slot(2)  # Select slot 3 (0-indexed)

# Signal
hotbar.item_selected.connect(_on_item_selected)
```

### Inventory

```gdscript
# Add item
inventory.add_item(item_data, quantity)

# Remove item
inventory.remove_item(slot_index, quantity)

# Get slot
var slot: Dictionary = inventory.get_slot(slot_index)
print(slot.item_data)  # ItemData or null
print(slot.quantity)  # int

# Set slot
inventory.set_slot(slot_index, item_data, quantity)

# Clear all
inventory.clear_inventory()

# Signal
inventory.inventory_changed.connect(_on_inventory_changed)
```

---

## Testing

### Test Scene

1. Open `scenes/test_hotbar_6slot.tscn`
2. Press **F6** to run
3. Test controls:
   - **1-6**: Select slots
   - **Mouse Wheel**: Scroll slots
   - **Q/E**: Previous/Next
   - **T**: Add random seeds
   - **C**: Clear inventory

### In Your Player Scene

1. Add items to icons (drag 64x64 images into item_icon property of each .tres file)
2. Run your main scene
3. Press 1-6 to switch between items
4. Watch console for debug output
5. Verify only one hand is visible at a time

---

## Important Notes

### ⚠️ No Duplicate Nodes

The system **DOES NOT** create new hand models. It uses your **existing hand nodes**:
- `yam_seed_hand`
- `potato_seed_hand`
- `casava_seed_hand`
- `rake_hand`
- `fork_hand`
- `hoe_hand`

### ⚠️ Node Paths

Make sure the paths in player.gd match your actual scene structure:

```gdscript
@onready var yam_seed_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/yam_seed_hand
```

If your structure is different, adjust the paths accordingly.

### ⚠️ Item IDs Must Match

The `item_id` in ItemData resources **must match** the keys in EquipmentManager's hand_nodes dictionary:

```gdscript
# In yam_seed.tres
item_id = "yam_seed"

# In equipment_manager.gd
hand_nodes = {
	"yam_seed": yam_seed_hand,  # Must match!
	...
}
```

---

## Troubleshooting

### Hand not showing when selecting slot

**Problem:** Selected hand doesn't appear

**Solutions:**
1. Check console for warnings from EquipmentManager
2. Verify hand node references are not null
3. Confirm item_id matches exactly (case-sensitive)
4. Check that initialize_hand_nodes() was called

### Multiple hands visible

**Problem:** More than one hand showing at once

**Solution:** Check that hide_all_hands() is being called before showing new hand

### Quantity not updating

**Problem:** Seed quantities don't change after planting

**Solution:** Make sure you're calling `inventory.remove_item(slot_index, 1)` after use

### Input not working

**Problem:** Number keys don't select slots

**Solution:** Configure Input Map with hotbar_1 through hotbar_6 actions

---

## Next Steps

1. **Add Icons:** Create/import 64x64 PNG icons for all 6 items
2. **Test Integration:** Run your player scene and test all 6 items
3. **Connect Planting:** Update your planting system to use `get_equipped_item_id()`
4. **Polish UI:** Customize hotbar colors, sizes, and positions
5. **Add Sounds:** Play equip sounds when changing items

---

**Your hotbar system is now fully integrated with your existing hand nodes!** 🎮
