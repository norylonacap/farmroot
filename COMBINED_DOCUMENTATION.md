# FARMROOT - Complete Game Documentation

## Table of Contents
1. [Quick Start](#quick-start)
2. [Game Controls](#game-controls)
3. [Menu System](#menu-system)
4. [Planting System](#planting-system)
5. [Hotbar & Inventory](#hotbar--inventory)
6. [Input Map Setup](#input-map-setup)
7. [File Structure](#file-structure)
8. [Troubleshooting](#troubleshooting)
9. [Customization Guide](#customization-guide)

---

## Quick Start

### Initial Setup (3 minutes)

1. **Add DayManager Node**
   - Open `game/scene/main.tscn`
   - Add Node child → Rename to "DayManager"
   - Attach script: `game/scene/day_manager.gd`
   - Set `seconds_per_day` to 60 in Inspector

2. **Add Player Group**
   - Select Player node
   - Node tab → Groups → Add "player"

3. **Test the Game**
   - Press **F5** to run
   - Follow the menu flow to start farming

### Game Flow

```
Loading Screen → Main Menu → Crop Selection → Gameplay
```

---

## Game Controls

| Input | Action |
|-------|--------|
| **W/A/S/D** | Move player |
| **Mouse** | Look around / Camera control |
| **1, 2, 3** | Select hotbar slots |
| **Mouse Wheel** | Navigate hotbar |
| **Q** | Use tool / Plant seed |
| **E** | Harvest mature plants |
| **Escape** | Free mouse cursor |
| **F5** | Run game (Godot editor) |

### Debug Controls
| Input | Action |
|-------|--------|
| **F1** | System status |
| **F2** | Skip day |
| **F3** | List all plants |
| **F4** | Grow all plants instantly |

---

## Menu System

### Scene Navigation Flow

```
Game Starts
    ↓
Loading Screen (automatic)
    ↓
Main Menu
    ├── START → Crop Selection
    │              ├── POTATO → Gameplay
    │              ├── CASAVA → Gameplay
    │              └── YAM → Gameplay
    ├── CREDITS → Credits Screen
    └── EXIT → Quit Game
```

### Menu Scenes

**Loading Screen** (`game/scene/ui/loading_screen.tscn`)
- Displays "DISCLAIMER" and progress bar
- Auto-transitions to Main Menu

**Main Menu** (`game/scene/main_menu/main_menu.tscn`)
- FARMROOT title
- START, CREDITS, EXIT buttons

**Crop Selection** (`game/scene/main_menu/crop_selection.tscn`)
- Three crop cards: POTATO, CASAVA, YAM
- SELECT buttons for each
- BACK button to return

**Credits** (`game/scene/main_menu/credits.tscn`)
- Team information
- BACK button

### Selected Crop Storage

The GameManager autoload stores selected crop:
```gdscript
GameManager.set_selected_crop("potato")  # Set crop
var seed = GameManager.get_selected_seed()  # Get seed resource
```

Selected seed automatically appears in inventory slot 3 when gameplay starts.

---

## Planting System

### Farming Workflow

```
1. Select Hoe → Press Q on Ground → Soil Tilled
2. Select Seed → Press Q on Tilled Soil → Seed Planted
3. Wait for Growth (automatic)
4. Press E on Mature Plant → Harvest!
```

### Core Components

**Plant Resource** (`plant_resource.gd`)
- Defines plant growth stages
- `stageScenes`: Array of PackedScene for each growth stage
- `daysPerStage`: Array of days required per stage

**Plant Scene** (`plant_scene.gd` + `plant_scene.tscn`)
- Handles plant instantiation and growth
- Methods:
  - `advance_day()` - Progress growth
  - `is_fully_grown()` - Check maturity

**Soil System** (`soil.gd`)
- `isTilled` - Tracks if soil is prepared
- `plantedPlant` - Reference to planted crop
- `plant_seed(item)` - Handle planting logic

**Day Manager** (`day_manager.gd`)
- Manages time progression
- Automatically advances all plants each day
- Configurable day length

### Growth Stages Example (Carrot)

1. **Stage 1**: Small sprout (2 days)
2. **Stage 2**: Growing plant (3 days)
3. **Stage 3**: Mature carrot (4 days)
**Total**: 9 days to maturity

### Creating New Crops

1. **Create Growth Stage Scenes**
   - Make 3D scenes for each stage
   - Save in `game/scene/plants/`

2. **Create Plant Resource** (.tres file)
   - Set `stageScenes` array
   - Set `daysPerStage` array

3. **Create Seed Item** (.tres file)
   - Set `itemType` to SEED (value 4)
   - Link `plantResource`
   - Add icon texture

4. **Add to Inventory**
   - Add seed to item bar inventory array

### Fast Testing Configuration

**In DayManager Inspector:**
- `seconds_per_day: 5` (5 seconds = 1 day)

**In Plant Resource:**
- `daysPerStage: [1, 1, 1]` (3 days total)

**Result**: 15 seconds from seed to harvest

---

## Hotbar & Inventory

### Inventory Layout

```
Slot 0: Hoe (farming tool)
Slot 1: C-tool (farming tool)
Slot 2: Selected Seed (from crop selection)
Slot 3-9: Empty (available for items)
```

### Hotbar Features

- **9 slots** at bottom-center of screen
- **Item stacking** with max stack limits
- **Selection highlight** with golden border
- **Quantity display** (bottom-right of slot)
- **Smooth animations** on selection change

### Key Scripts

| Script | Purpose |
|--------|---------|
| `item_data.gd` | Resource defining item properties |
| `inventory.gd` | 9-slot storage with stacking |
| `hotbar_slot.gd` | Individual slot UI |
| `hotbar.gd` | Main UI controller with input |

### Example Items

- **Stone**: 64 max stack
- **Wood**: 64 max stack
- **Potato**: 16 max stack
- **Water**: 1 max stack (bucket)

### Integration Example

```gdscript
# Get selected item
var item = hotbar.get_selected_item()
if item:
    print("Holding: ", item.item_name)

# Add item to inventory
inventory.add_item(stone_item, 5)

# Remove item
inventory.remove_item(0, 1)  # Remove 1 from slot 0
```

---

## Input Map Setup

### Required Input Actions

Configure in **Project → Project Settings → Input Map**:

**Hotbar Slots (1-9)**
- `hotbar_1` - Key: 1
- `hotbar_2` - Key: 2
- `hotbar_3` - Key: 3
- `hotbar_4` - Key: 4
- `hotbar_5` - Key: 5
- `hotbar_6` - Key: 6
- `hotbar_7` - Key: 7
- `hotbar_8` - Key: 8
- `hotbar_9` - Key: 9

**Navigation**
- `hotbar_next` - Key: E
- `hotbar_previous` - Key: Q

**Actions**
- `actionQ` - Key: Q (plant/use tool)
- `interact` - Key: E (harvest)

**Movement**
- `move_forward` - Key: W
- `move_backward` - Key: S
- `move_left` - Key: A
- `move_right` - Key: D

---

## File Structure

```
d:\CAPG\1\
│
├── game/
│   ├── scene/
│   │   ├── ui/
│   │   │   └── loading_screen.tscn
│   │   ├── main_menu/
│   │   │   ├── main_menu.tscn
│   │   │   ├── crop_selection.tscn
│   │   │   └── credits.tscn
│   │   ├── plants/
│   │   │   ├── plant_resource.gd
│   │   │   ├── plant_scene.gd
│   │   │   ├── plant_scene.tscn
│   │   │   ├── carrot_resource.tres
│   │   │   ├── carrot_stage_1.tscn
│   │   │   ├── carrot_stage_2.tscn
│   │   │   └── carrot_stage_3.tscn
│   │   ├── day_manager.gd
│   │   ├── day_ui.gd
│   │   ├── player.gd
│   │   ├── soil.gd
│   │   └── main.tscn
│   └── assets/
│       └── character/
│           └── item_resource/
│               ├── item_resource.gd
│               ├── carrot_seed.tres
│               ├── potato_seed.tres
│               ├── casava_seed.tres
│               └── yam_seed.tres
│
├── scripts/
│   ├── game_manager.gd
│   ├── item_data.gd
│   ├── inventory.gd
│   ├── hotbar_slot.gd
│   └── hotbar.gd
│
└── resources/items/
    ├── stone.tres
    ├── wood.tres
    ├── grass.tres
    ├── potato.tres
    └── water.tres
```

---

## Troubleshooting

### Plants Don't Grow
- ✓ Check DayManager exists in scene
- ✓ Verify day_manager.gd script is attached
- ✓ Check console for "Day X has begun!" messages

### Can't Plant Seeds
- ✓ Till soil first with hoe
- ✓ Ensure seed item type is SEED (value 4)
- ✓ Check plantResource is assigned to seed
- ✓ Verify Input action "actionQ" exists

### Seed Not in Inventory
- ✓ Check crop was selected in Crop Selection screen
- ✓ Verify GameManager autoload is configured
- ✓ Look for console message: "Added selected seed to inventory"
- ✓ Press "3" to select inventory slot 3

### Can't Harvest
- ✓ Wait for all growth stages to complete
- ✓ Check plant is fully mature (all stages done)
- ✓ Press E key while looking at plant
- ✓ Verify Input action "interact" exists

### Hotbar Not Working
- ✓ Configure Input Map (hotbar_1 through hotbar_9)
- ✓ Check hotbar_next and hotbar_previous actions
- ✓ Verify Hotbar node exists in scene
- ✓ Ensure Inventory node is assigned

### Menu Navigation Issues
- ✓ Verify GameManager is in autoloads
- ✓ Check main_scene points to loading_screen.tscn
- ✓ All scene .tscn files must exist
- ✓ Button signals must be connected

### Console Errors
- ✓ Check all @export variables are assigned
- ✓ Verify node paths are correct
- ✓ Ensure all required scripts are attached
- ✓ Check groups are properly assigned

---

## Customization Guide

### Adjust Growth Speed

**In DayManager Inspector:**
```
seconds_per_day: 60    # Normal (1 minute/day)
seconds_per_day: 5     # Fast testing
seconds_per_day: 300   # Slow/realistic
```

**In Plant Resource:**
```
daysPerStage: [2, 3, 4]    # Normal (9 days)
daysPerStage: [1, 1, 1]    # Fast (3 days)
daysPerStage: [5, 7, 10]   # Slow (22 days)
```

### Change Hotbar Appearance

**In hotbar_slot.tscn:**
- Slot size: Change Control node min_size
- Border color: Edit Panel theme
- Selection highlight: Modify hotbar.gd Tween

**In hotbar.gd:**
```gdscript
# Change slot spacing
slot.position.x = i * 72  # Default 72 (64 + 8 spacing)
```

### Add New Items

1. Create ItemData resource (.tres)
2. Set properties:
   - `item_name`: Display name
   - `icon`: Texture2D
   - `max_stack`: Stack limit
   - `description`: Info text
3. Add to inventory or hotbar

### Add New Crops

1. Create 3D models for growth stages
2. Save as .tscn scenes
3. Create PLANT_RESOURCE with stages
4. Create ITEM_BAR_ITEM with type SEED
5. Link plantResource
6. Add to crop selection or inventory

### Modify UI Layout

**Day Counter** (`day_ui.gd`):
- Position in top-right corner
- Shows current day number

**Inventory UI** (`farming_inventory_ui.tscn`):
- Position in bottom-left
- Displays seed count and harvested crops

**Hotbar Position**:
- Bottom-center by default
- Modify anchors in hotbar.tscn

### Extend Gameplay Features

**Add Watering System:**
- Modify soil.gd to track watered state
- Require watering for growth
- Add visual feedback

**Add Harvesting Rewards:**
- Modify plant.gd harvest logic
- Add crops to inventory
- Track harvested quantities

**Add Seasons:**
- Extend day_manager.gd
- Add season-specific crops
- Restrict planting by season

**Add Plant Health:**
- Add health variable to plant_scene.gd
- Affect growth based on care
- Implement withering/death

---

## Implementation Status

### ✅ Fully Implemented Features

**Menu System**
- Loading screen with progress bar
- Main menu with navigation
- Crop selection (3 crops)
- Credits screen
- Scene transitions

**Planting System**
- Multi-stage plant growth
- Soil tilling with hoe
- Seed planting mechanics
- Automatic time progression
- Day/night cycle
- Plant maturity detection
- Harvest functionality

**Inventory System**
- 9-slot hotbar
- Item stacking with limits
- Visual selection feedback
- Multiple input methods (keys, mouse wheel)
- Quantity display
- Empty slot handling

**Player Integration**
- Movement and camera control
- Tool and seed usage
- Raycast interaction
- Inventory management
- Selected crop initialization

### 🔜 Ready to Extend

- Additional crop varieties
- Weather system
- Fertilizer mechanics
- Plant health/quality
- Seasonal growing
- Save/load system
- Achievement system
- Market/selling crops

---

## Quick Reference

### Common Commands

**Player Movement:**
```gdscript
# WASD keys for movement
# Mouse for camera rotation
# Automatic mouse capture
```

**Planting:**
```gdscript
1. Select hoe (key 1 or 2)
2. Press Q on ground → Till soil
3. Select seed (key 3)
4. Press Q on tilled soil → Plant
```

**Harvesting:**
```gdscript
1. Wait for plant to mature
2. Look at mature plant
3. Press E → Harvest
```

**Hotbar:**
```gdscript
# Direct selection: 1-9 keys
# Scroll: Mouse wheel
# Navigate: Q/E keys
```

### Configuration Paths

**Project Settings:**
- Main Scene: `res://game/scene/ui/loading_screen.tscn`
- Autoload: `GameManager="*res://scripts/game_manager.gd"`

**Key Nodes:**
- DayManager: Root → DayManager
- Player: Root → Player (in "player" group)
- Inventory: Player → Inventory
- Hotbar: UI → CanvasLayer → Hotbar

### Debug Info

**Console Messages:**
- "Day X has begun!" - Day advanced
- "Added selected seed to inventory: [crop]" - Seed loaded
- "Plant stage X" - Growth stage changed
- "Planted [seed] at [position]" - Planting succeeded
- "Harvested [plant]" - Harvest completed

**Press F1** for system status output
**Press F2** to skip to next day
**Press F3** to list all plants
**Press F4** to instantly grow all plants

---

## Credits

**Project**: FARMROOT - 3D Farming Simulation Game  
**Engine**: Godot Engine 4.x  
**Team**: CAPG Team  
**Documentation Version**: 2.0  
**Status**: Production Ready ✅

---

## Additional Resources

### Original Documentation Files
- `PLANTING_SYSTEM_GUIDE.md` - Detailed planting system
- `MENU_SYSTEM_IMPLEMENTATION.md` - Menu flow details
- `HOTBAR_SYSTEM_SUMMARY.md` - Inventory system overview
- `IMPLEMENTATION_STATUS.md` - Complete feature status
- `INTEGRATION_STEPS.md` - Setup instructions
- `INPUT_MAP_SETUP.md` - Input configuration

### Test Scenes
- `scenes/test_hotbar.tscn` - Hotbar testing
- `game/scene/main.tscn` - Main gameplay

### Example Assets
- Carrot plant (3 stages)
- Potato/Casava/Yam seeds (placeholders)
- Stone/Wood/Grass items
- Tool items (Hoe, C-tool)

---

**Happy Farming! 🌱🚜🥕**
