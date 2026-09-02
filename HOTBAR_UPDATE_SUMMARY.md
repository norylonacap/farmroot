# Hotbar System Update - Summary

## ✅ What Was Done

Your hotbar system has been **updated** to work with your existing hand nodes in the player scene.

---

## 📦 Files Created/Modified

### Created Files:
1. `scripts/equipment_manager.gd` - Manages hand visibility
2. `resources/items/yam_seed.tres` - Yam seed item
3. `resources/items/potato_seed.tres` - Potato seed item
4. `resources/items/casava_seed.tres` - Casava seed item
5. `resources/items/rake.tres` - Rake tool item
6. `resources/items/fork.tres` - Fork tool item
7. `resources/items/hoe.tres` - Hoe tool item
8. `scenes/test_hotbar_6slot.tscn` - Test scene for 6-slot system
9. `HOTBAR_INTEGRATION_GUIDE.md` - Complete integration guide

### Modified Files:
1. `scripts/item_data.gd` - Added `is_tool` and `hand_node_name` properties
2. `scripts/inventory.gd` - Changed to 6 slots
3. `scripts/hotbar_slot.gd` - Tools don't show quantity
4. `scripts/hotbar.gd` - Emits item_id string instead of ItemData
5. `scenes/ui/hotbar.tscn` - Now has 6 slots instead of 9

---

## 🎯 Key Features

✅ **6-Slot Hotbar** (instead of 9)
✅ **3 Seeds:** Yam, Potato, Casava (with quantities)
✅ **3 Tools:** Rake, Fork, Hoe (no quantities)
✅ **Uses Your Existing Hand Nodes** (no duplicates created)
✅ **Equipment Manager** controls hand visibility
✅ **Number Keys 1-6** for selection
✅ **Mouse Wheel** scrolling
✅ **Q/E** for previous/next
✅ **Wrapping** selection (6→1, 1→6)
✅ **Signal-based** communication

---

## 🚀 Quick Integration (3 Steps)

### Step 1: Update Your Player Script

Add to `game/scene/player.gd`:

```gdscript
# Add at top with @onready variables
@onready var inventory: Inventory = $Inventory
@onready var equipment_manager: EquipmentManager = $EquipmentManager
@onready var yam_seed_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/yam_seed_hand
@onready var potato_seed_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/potato_seed_hand
@onready var casava_seed_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/casava_seed_hand
@onready var rake_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/rake_hand
@onready var fork_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/fork_hand
@onready var hoe_hand: Node3D = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/hoe_hand

var current_equipped_item_id: String = ""

# Add to _ready()
func _ready():
	# ... your existing code ...
	
	# Initialize equipment manager
	equipment_manager.initialize_hand_nodes(
		yam_seed_hand, potato_seed_hand, casava_seed_hand,
		rake_hand, fork_hand, hoe_hand
	)
	
	# Setup inventory
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
	
	# Connect hotbar
	var hotbar = $CanvasLayer/Hotbar
	hotbar.item_selected.connect(_on_hotbar_item_selected)

# Add new function
func _on_hotbar_item_selected(item_id: String, slot_index: int) -> void:
	current_equipped_item_id = item_id
	equipment_manager.equip_item(item_id)

func get_equipped_item_id() -> String:
	return current_equipped_item_id

func is_holding_item(item_id: String) -> bool:
	return current_equipped_item_id == item_id
```

### Step 2: Update Player Scene

In `game/scene/player.tscn`:

1. Add two Node children to Player:
   - **Inventory** (attach `scripts/inventory.gd`)
   - **EquipmentManager** (attach `scripts/equipment_manager.gd`)

2. Replace ItemBar with Hotbar:
   - Delete the old ItemBar node
   - Instance `scenes/ui/hotbar.tscn` as child of CanvasLayer
   - Set Hotbar's `inventory` property to point to the Inventory node

### Step 3: Configure Input Map

Project → Project Settings → Input Map:

- `hotbar_1` = Key 1
- `hotbar_2` = Key 2
- `hotbar_3` = Key 3
- `hotbar_4` = Key 4
- `hotbar_5` = Key 5
- `hotbar_6` = Key 6
- `hotbar_next` = E
- `hotbar_previous` = Q

---

## 📖 Using the System

### Get Currently Equipped Item

```gdscript
var item_id = player.get_equipped_item_id()

# Returns one of:
# "yam_seed", "potato_seed", "casava_seed"
# "rake", "fork", "hoe"
# "" (empty if nothing selected)
```

### Check Specific Item

```gdscript
if player.is_holding_item("yam_seed"):
	plant_yam()
elif player.is_holding_item("rake"):
	till_soil()
```

### Use in Planting System

```gdscript
func _on_player_use_item():
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
			farming_interaction()
```

### Remove Seed After Planting

```gdscript
# After successfully planting
var inventory = player.get_node("Inventory")
var hotbar = player.get_node("CanvasLayer/Hotbar")
var slot = hotbar.get_selected_slot()
inventory.remove_item(slot, 1)  # Remove 1 seed
```

---

## 🎨 Item Mapping

| Slot | Item | ID | Type | Quantity | Hand Node |
|------|------|----|----- |----------|-----------|
| 1 | Yam Seed | `yam_seed` | Seed | 10 | `yam_seed_hand` |
| 2 | Potato Seed | `potato_seed` | Seed | 15 | `potato_seed_hand` |
| 3 | Casava Seed | `casava_seed` | Seed | 8 | `casava_seed_hand` |
| 4 | Rake | `rake` | Tool | - | `rake_hand` |
| 5 | Fork | `fork` | Tool | - | `fork_hand` |
| 6 | Hoe | `hoe` | Tool | - | `hoe_hand` |

---

## 🔧 How It Works

```
Player presses "2"
    ↓
Hotbar selects slot 2 (Potato Seed)
    ↓
Hotbar emits: item_selected("potato_seed", 1)
    ↓
Player receives signal
    ↓
Player calls: equipment_manager.equip_item("potato_seed")
    ↓
EquipmentManager hides all hand nodes
    ↓
EquipmentManager shows: potato_seed_hand
    ↓
Only potato seed is visible in player's hand
```

---

## ⚠️ Important Notes

1. **No New Hand Models Created** - Uses your existing nodes
2. **Item IDs Must Match** - `item_id` in .tres files must match hand_nodes keys
3. **Node Paths Must Be Correct** - Verify paths to your hand nodes
4. **Tools Show No Quantity** - Only seeds show quantity labels

---

## 📁 File Structure

```
scripts/
├── item_data.gd ✅ Updated
├── inventory.gd ✅ Updated (6 slots)
├── hotbar.gd ✅ Updated (emits item_id)
├── hotbar_slot.gd ✅ Updated (tool handling)
└── equipment_manager.gd ✅ NEW

resources/items/
├── yam_seed.tres ✅ NEW
├── potato_seed.tres ✅ NEW
├── casava_seed.tres ✅ NEW
├── rake.tres ✅ NEW
├── fork.tres ✅ NEW
└── hoe.tres ✅ NEW

scenes/
├── ui/
│   ├── hotbar.tscn ✅ Updated (6 slots)
│   └── hotbar_slot.tscn (unchanged)
└── test_hotbar_6slot.tscn ✅ NEW
```

---

## 🧪 Testing

### Test Scene
```bash
Open: scenes/test_hotbar_6slot.tscn
Run: F6
Test: Press 1-6, Mouse Wheel, Q/E
```

### Your Player Scene
```bash
1. Complete Step 1-3 above
2. Add item icons (64x64 PNG to each .tres)
3. Run your main scene
4. Press 1-6 to test
5. Check console output
6. Verify only one hand visible at a time
```

---

## 📖 Full Documentation

See `HOTBAR_INTEGRATION_GUIDE.md` for:
- Complete integration steps
- API reference
- Troubleshooting
- Examples
- Architecture details

---

## ✅ System is Ready!

Your hotbar now:
- Controls your existing hand nodes
- Has 6 slots (3 seeds + 3 tools)
- Tracks quantities for seeds
- Emits signals for your planting system
- Wraps selection
- Supports all input methods

**Next:** Add item icons and integrate with your farming system! 🌱
