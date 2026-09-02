# Hotbar System - Quick Start

## 🚀 Setup in 5 Minutes

### Step 1: Configure Input Map
Open **Project → Project Settings → Input Map** and add:

| Action | Key |
|--------|-----|
| hotbar_1 | 1 |
| hotbar_2 | 2 |
| hotbar_3 | 3 |
| hotbar_4 | 4 |
| hotbar_5 | 5 |
| hotbar_6 | 6 |
| hotbar_7 | 7 |
| hotbar_8 | 8 |
| hotbar_9 | 9 |
| hotbar_next | E |
| hotbar_previous | Q |

### Step 2: Test the System
1. Open `scenes/test_hotbar.tscn`
2. Press **F5** or click **Run Current Scene**
3. Test controls:
   - **1-9**: Select slots
   - **Mouse Wheel**: Scroll slots
   - **Q/E**: Previous/Next
   - **T**: Add random items
   - **C**: Clear inventory

### Step 3: Add to Your Player Scene
```
YourPlayerScene
├── Player (CharacterBody3D)
│   └── [your components]
├── Inventory (Node) ← Add this
└── CanvasLayer ← Add this
    └── Hotbar ← Instance scenes/ui/hotbar.tscn
```

### Step 4: Link References
1. Select **Player** node
   - Export var `hotbar` → drag **Hotbar** node
   
2. Select **Hotbar** node
   - Export var `inventory` → drag **Inventory** node

3. Attach script to **Inventory** node:
   - Script: `res://scripts/inventory.gd`

### Step 5: Connect in Player Script
```gdscript
extends CharacterBody3D

@export var hotbar: Hotbar

var current_item: ItemData = null

func _ready():
    hotbar.item_selected.connect(_on_item_selected)
    current_item = hotbar.get_selected_item()

func _on_item_selected(item: ItemData, slot_index: int):
    current_item = item
    print("Now holding: ", item.item_name if item else "Nothing")
```

## 🎯 Quick Reference

### Add Items to Inventory
```gdscript
var stone = preload("res://resources/items/stone.tres")
inventory.add_item(stone, 10)
```

### Get Selected Item
```gdscript
var item = hotbar.get_selected_item()
if item:
    print("Holding: ", item.item_name)
```

### Use Selected Item
```gdscript
func _input(event):
    if event.is_action_pressed("ui_accept"):
        if current_item:
            use_item(current_item)
            hotbar.inventory.remove_item(hotbar.get_selected_slot(), 1)
```

### Create New Item
1. Right-click `resources/items/` → **New Resource**
2. Type "ItemData" → Select it
3. Configure properties
4. Save as `.tres`

## 📁 File Locations

| What | Where |
|------|-------|
| Scripts | `scripts/` |
| Item Resources | `resources/items/` |
| UI Scenes | `scenes/ui/` |
| Test Scene | `scenes/test_hotbar.tscn` |

## 🔧 Common Tasks

### Change Slot Count
`inventory.gd` → Change `HOTBAR_SIZE` constant

### Change Slot Size
`hotbar_slot.tscn` → Select root node → `custom_minimum_size`

### Change Colors
`hotbar_slot.tscn` → Select panels → Edit StyleBoxFlat

### Add Icons to Items
1. Import image files (64x64 PNG recommended)
2. Open item `.tres` file
3. Drag image to `item_icon` property

## 📖 Full Documentation
See `HOTBAR_SYSTEM_GUIDE.md` for complete explanations.

## ❓ Troubleshooting

**Items not visible?**
→ Add icons to ItemData resources

**Input not working?**
→ Set up Input Map (Step 1)

**Inventory is null?**
→ Link Inventory node to Hotbar (Step 4)

**Selection not showing?**
→ Check SelectionHighlight panel has colored borders

---

That's it! You now have a working Minecraft-style hotbar system. 🎮
