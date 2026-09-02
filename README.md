# 🎮 Godot 4 Hotbar/Inventory System

A complete, modular, beginner-friendly hotbar/inventory system for Godot 4 games. Perfect for Minecraft-style, survival, and crafting games.

![Godot Version](https://img.shields.io/badge/Godot-4.x-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Language](https://img.shields.io/badge/Language-GDScript-purple)

## ✨ Features

- ✅ **9-slot hotbar** with clean, modern UI
- ✅ **Automatic item stacking** with configurable stack sizes
- ✅ **Multiple input methods:**
  - Number keys (1-9) for direct selection
  - Mouse wheel scrolling
  - Q/E for previous/next (configurable)
- ✅ **Visual feedback:**
  - Highlighted selection border
  - Smooth scale animations
  - Quantity labels
- ✅ **Modular architecture:**
  - Separate data, logic, and UI layers
  - Signal-based communication
  - Easy to extend
- ✅ **Resource-based items:**
  - Reusable ItemData resources
  - Simple to create new items
  - Support for icons, descriptions, stack limits
- ✅ **Player integration:**
  - Easy connection to CharacterBody3D
  - Signal-based item selection
  - Get selected item with one function call
- ✅ **Test scene included** with debug features

## 📸 Quick Preview

```
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│     │     │     │     │     │     │     │     │     │
│ 🪨  │ 🪵  │ 🥔  │     │     │     │     │     │     │
│ x32 │ x15 │ x8  │     │     │     │     │     │     │
└─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘
```

## 🚀 Quick Start

### 1. Setup Input Map
Configure in **Project → Project Settings → Input Map**:
- `hotbar_1` to `hotbar_9` (number keys 1-9)
- `hotbar_next` (E key)
- `hotbar_previous` (Q key)

See `INPUT_MAP_SETUP.md` for detailed instructions.

### 2. Test the System
1. Open `scenes/test_hotbar.tscn`
2. Press **F6** to run
3. Try the controls:
   - **1-9**: Select slots
   - **Mouse Wheel**: Scroll
   - **Q/E**: Previous/Next
   - **T**: Add test items

### 3. Integrate with Your Player
```gdscript
extends CharacterBody3D

@export var hotbar: Hotbar
var current_item: ItemData = null

func _ready():
    hotbar.item_selected.connect(_on_item_selected)

func _on_item_selected(item: ItemData, slot: int):
    current_item = item
    print("Now holding: ", item.item_name if item else "Nothing")
```

See `QUICK_START.md` for complete setup guide.

## 📁 Project Structure

```
scripts/
├── item_data.gd       # Item properties resource
├── inventory.gd       # Inventory management logic
├── hotbar.gd         # Hotbar UI controller
├── hotbar_slot.gd    # Individual slot component
└── player_example.gd # Player integration example

resources/items/
├── stone.tres        # Example item resources
├── wood.tres
├── grass.tres
├── potato.tres
└── water.tres

scenes/
├── ui/
│   ├── hotbar.tscn       # Main hotbar UI
│   └── hotbar_slot.tscn  # Slot UI component
└── test_hotbar.tscn      # Test scene
```

## 📖 Documentation

| Document | Description |
|----------|-------------|
| **README.md** | This file - overview and quick links |
| **QUICK_START.md** | 5-minute setup guide |
| **HOTBAR_SYSTEM_GUIDE.md** | Complete documentation (10,000+ words) |
| **SYSTEM_ARCHITECTURE.md** | Technical architecture and design |
| **INPUT_MAP_SETUP.md** | Input configuration guide |
| **ADDING_ITEM_ICONS.md** | How to add item icons |

## 🎯 Core Components

### ItemData (Resource)
Defines item properties:
```gdscript
@export var item_id: String = "stone"
@export var item_name: String = "Stone"
@export var item_icon: Texture2D = null
@export var max_stack: int = 64
@export var item_description: String = ""
```

### Inventory (Node)
Manages item storage:
```gdscript
inventory.add_item(item, quantity)     # Add items with stacking
inventory.remove_item(slot, quantity)  # Remove items
inventory.get_slot(slot)              # Get slot contents
```

### Hotbar (Control)
Handles UI and input:
```gdscript
hotbar.get_selected_item()    # Get current item
hotbar.get_selected_slot()    # Get current slot index
hotbar.select_slot(index)     # Change selection

# Signal:
signal item_selected(item: ItemData, slot_index: int)
```

## 🔧 Common Tasks

### Create a New Item
1. Right-click `resources/items/` → **New Resource**
2. Select **ItemData**
3. Configure properties
4. Save as `.tres`

### Add Item to Inventory
```gdscript
var apple = preload("res://resources/items/apple.tres")
inventory.add_item(apple, 5)
```

### Use Selected Item
```gdscript
func use_item():
    var item = hotbar.get_selected_item()
    if item:
        print("Using: ", item.item_name)
        # Your game logic here
        hotbar.inventory.remove_item(hotbar.get_selected_slot(), 1)
```

### Check What Player is Holding
```gdscript
var item = hotbar.get_selected_item()
if item and item.item_id == "stone":
    can_place_block = true
```

## 🎨 Customization

### Change Number of Slots
```gdscript
# In inventory.gd
const HOTBAR_SIZE: int = 12  # Change from 9
```

### Change Slot Appearance
Edit `scenes/ui/hotbar_slot.tscn`:
- Adjust `custom_minimum_size` for size
- Modify StyleBoxFlat for colors/borders
- Change font size for quantity label

### Change Selection Color
In `hotbar_slot.tscn`, edit **SelectionHighlight** panel's StyleBoxFlat `border_color`.

## 🔌 Extension Ideas

- **Drag and Drop** - Rearrange items
- **Item Categories** - Organize by type
- **Durability System** - Tools that wear down
- **Tooltips** - Show item info on hover
- **Item Rarity** - Color-coded by quality
- **Weight System** - Limited carrying capacity
- **Multiple Hotbars** - Switch between sets
- **Cooldowns** - Time-based item restrictions

See `HOTBAR_SYSTEM_GUIDE.md` Part 11 for implementation details.

## 🎓 Learning Resources

### Beginner-Friendly
- All scripts heavily commented
- Clear variable names
- Modular, single-responsibility design
- No complex patterns or inheritance

### Architecture Principles
- **Separation of Concerns** - UI separate from logic
- **Signal-Based** - Loose coupling
- **Resource System** - Data-driven design
- **Scene Instancing** - Reusable components

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Input not working | Set up Input Map (see `INPUT_MAP_SETUP.md`) |
| Icons not showing | Assign textures to ItemData resources |
| Selection not visible | Check SelectionHighlight has colored borders |
| Inventory is null | Link Inventory node to Hotbar in Inspector |

See documentation for complete troubleshooting guide.

## 🤝 Integration Examples

### Block Placement
```gdscript
func place_block():
    var item = hotbar.get_selected_item()
    if item and item.item_id == "stone":
        # Raycast to find position
        # Instantiate block
        # Remove from inventory
        hotbar.inventory.remove_item(hotbar.get_selected_slot(), 1)
```

### Crop Planting
```gdscript
func plant_crop():
    var item = hotbar.get_selected_item()
    if item and item.item_id == "potato":
        # Check for farmland
        # Plant potato
        hotbar.inventory.remove_item(hotbar.get_selected_slot(), 1)
```

### Item Pickup
```gdscript
func _on_pickup_area_entered(body):
    if body is Player:
        if body.hotbar.inventory.add_item(item_data, quantity):
            queue_free()  # Remove from world
```

## 📊 Feature Checklist

- [x] 9-slot hotbar UI
- [x] Item data resources
- [x] Inventory management
- [x] Automatic stacking
- [x] Multiple input methods
- [x] Visual selection
- [x] Smooth animations
- [x] Wrapping selection
- [x] Player integration
- [x] Test scene
- [x] Complete documentation
- [x] Example items
- [x] Beginner-friendly code

## 💡 Design Goals

1. **Beginner-Friendly**
   - Clear, commented code
   - No advanced patterns
   - Step-by-step guides

2. **Modular**
   - Independent components
   - Easy to extend
   - Reusable parts

3. **Production-Ready**
   - Proper error handling
   - Efficient performance
   - Clean architecture

4. **Well-Documented**
   - Multiple guides
   - Code comments
   - Architecture diagrams

## 🎮 Example Games

This system works great for:
- **Minecraft-style** block builders
- **Survival games** with crafting
- **Farming simulators** with crops
- **Adventure games** with items
- **RPGs** with equipment

## 📝 Files Included

Core System:
- ✅ 5 GDScript files
- ✅ 5 example ItemData resources
- ✅ 2 UI scene files
- ✅ 1 test scene

Documentation:
- ✅ README (this file)
- ✅ Quick Start Guide
- ✅ Complete System Guide (10k+ words)
- ✅ Architecture Documentation
- ✅ Input Setup Guide
- ✅ Icon Guide

## 🚦 Next Steps

1. **Set up Input Map** → `INPUT_MAP_SETUP.md`
2. **Add item icons** → `ADDING_ITEM_ICONS.md`
3. **Test the system** → Run `test_hotbar.tscn`
4. **Read full guide** → `HOTBAR_SYSTEM_GUIDE.md`
5. **Integrate with player** → See Part 5 in guide
6. **Connect to game systems** → See Part 8 in guide

## 📄 License

This code is provided as-is for educational and commercial use.
Feel free to modify, extend, and use in your projects.

## 🙋 Support

For detailed explanations of every component, see:
- **HOTBAR_SYSTEM_GUIDE.md** - Complete documentation
- **SYSTEM_ARCHITECTURE.md** - How everything works together

## ⭐ Credits

Created as a complete, beginner-friendly implementation for Godot 4.
Designed to teach good architecture while being immediately useful.

---

**Ready to start?** Open `QUICK_START.md` and follow the 5-minute setup! 🎮

**Need help?** Read `HOTBAR_SYSTEM_GUIDE.md` for complete explanations.

**Want to understand the design?** Check `SYSTEM_ARCHITECTURE.md`.

Happy coding! 🚀
