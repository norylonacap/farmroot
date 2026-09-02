# Godot 4 Hotbar/Inventory System - Complete Guide

## Overview

This is a modular, beginner-friendly hotbar/inventory system for Godot 4 games. It features:
- 9-slot hotbar at the bottom of the screen
- Item stacking with configurable max stack sizes
- Keyboard (1-9), mouse wheel, and Q/E navigation
- Visual selection highlighting with smooth animations
- Signal-based communication for player integration
- Modular item data system

---

## Project Structure

```
scripts/
    item_data.gd          # Resource defining item properties
    inventory.gd          # Manages item storage and quantities
    hotbar.gd            # Hotbar UI controller and input handler
    hotbar_slot.gd       # Individual slot UI component
    player_example.gd    # Example player integration

resources/
    items/
        stone.tres       # Example item resources
        wood.tres
        grass.tres
        potato.tres
        water.tres

scenes/
    ui/
        hotbar.tscn          # Main hotbar UI scene
        hotbar_slot.tscn     # Individual slot scene
    test_hotbar.tscn         # Test scene to try the system
```

---

## Part 1: ItemData Resource

**File:** `scripts/item_data.gd`

### What It Does
ItemData is a reusable Resource that defines an item's properties. Each item (Stone, Wood, Potato, etc.) has its own `.tres` file.

### Properties
- `item_id` (String) - Unique identifier (e.g., "stone", "potato")
- `item_name` (String) - Display name (e.g., "Stone", "Potato")
- `item_description` (String) - Item description for tooltips
- `item_icon` (Texture2D) - Item icon image
- `max_stack` (int) - Maximum stack size (default: 64)

### How to Create New Items

1. **In Godot Editor:**
   - Right-click in FileSystem → `New Resource`
   - Select `ItemData` (if not visible, type "ItemData")
   - Configure properties in the Inspector
   - Save as `.tres` file in `resources/items/`

2. **Set the Icon:**
   - Drag an image file into your project
   - Select the ItemData resource
   - Drag the image into the `item_icon` property

### Example Items Created
- **Stone**: 64 max stack, for building
- **Wood**: 64 max stack, for crafting
- **Grass**: 64 max stack, decoration
- **Potato**: 16 max stack, food/planting
- **Water**: 1 max stack (bucket), tool

---

## Part 2: Inventory Manager

**File:** `scripts/inventory.gd`

### What It Does
Manages the 9 hotbar slots, storing which items and quantities are in each slot.

### Key Features
- Stores 9 slots (expandable by changing `HOTBAR_SIZE`)
- Each slot contains: `{ item_data: ItemData, quantity: int }`
- Handles item adding with automatic stacking
- Emits `inventory_changed(slot_index)` signal when slots update

### Important Functions

#### `add_item(item: ItemData, quantity: int) -> bool`
Adds items to the inventory with automatic stacking.

**Logic:**
1. First tries to stack with existing items of the same type
2. Then fills empty slots if needed
3. Returns `true` if successful, `false` if inventory is full

**Example:**
```gdscript
var stone = preload("res://resources/items/stone.tres")
inventory.add_item(stone, 32)  # Adds 32 stones
```

#### `remove_item(slot_index: int, quantity: int)`
Removes items from a specific slot.

**Example:**
```gdscript
inventory.remove_item(2, 1)  # Remove 1 item from slot 3
```

#### `get_slot(slot_index: int) -> Dictionary`
Returns the item and quantity in a slot.

**Returns:** `{ item_data: ItemData, quantity: int }`

**Example:**
```gdscript
var slot_data = inventory.get_slot(0)
print(slot_data.item_data.item_name)  # "Stone"
print(slot_data.quantity)  # 32
```

#### `clear_inventory()`
Empties all slots.

### Stacking Behavior

**Example Scenario:**
- Slot 1: Stone x32 (max stack: 64)
- Add 40 more stones
- **Result:**
  - Slot 1: Stone x64 (topped off)
  - Slot 2: Stone x8 (remainder)

---

## Part 3: Hotbar Slot (UI Component)

**File:** `scripts/hotbar_slot.gd`  
**Scene:** `scenes/ui/hotbar_slot.tscn`

### What It Does
Displays a single slot in the hotbar with icon, quantity, and selection state.

### Node Structure
```
HotbarSlot (PanelContainer)
├── MarginContainer
│   └── ItemIcon (TextureRect)
├── QuantityLabel (Label)
└── SelectionHighlight (Panel)
```

### Visual Design
- **Background:** Dark gray panel with border
- **Icon:** Centered, scales to fit slot
- **Quantity:** Bottom-right corner, only shows if > 1
- **Selection Highlight:** Golden border that appears when selected

### Key Functions

#### `set_item(item: ItemData, quantity: int)`
Updates the slot's displayed item and quantity.

#### `set_selected(selected: bool)`
Shows/hides selection highlight and plays animation.

### Animations
- **Selected:** Scales to 110% with bounce effect
- **Deselected:** Scales back to 100% smoothly

---

## Part 4: Hotbar Manager

**File:** `scripts/hotbar.gd`  
**Scene:** `scenes/ui/hotbar.tscn`

### What It Does
Main controller that handles:
- Input (keyboard, mouse wheel)
- Slot selection
- Visual updates
- Communication with inventory and player

### Node Structure
```
Hotbar (Control)
└── HBoxContainer
    ├── HotbarSlot1
    ├── HotbarSlot2
    ├── ...
    └── HotbarSlot9
```

### Positioning
Uses Control anchors for responsive positioning:
- **Anchor:** Bottom-center of screen
- **Offset:** 80 pixels from bottom
- Automatically adjusts to screen size

### Input Handling

#### Number Keys (1-9)
Selects the corresponding hotbar slot directly.

**Input Actions Required:**
- `hotbar_1` through `hotbar_9`

#### Mouse Wheel
- **Wheel Up:** Previous slot (wraps from 1 to 9)
- **Wheel Down:** Next slot (wraps from 9 to 1)

**Note:** Mouse wheel is handled directly in code, no input map needed.

#### Q/E Keys (or custom)
- **hotbar_previous:** Select previous slot
- **hotbar_next:** Select next slot

### Key Functions

#### `select_slot(slot_index: int)`
Selects a specific slot (0-8).
- Updates visual selection
- Emits `item_selected` signal
- Prints debug info

#### `get_selected_item() -> ItemData`
Returns the currently selected item (or null if empty).

**Example:**
```gdscript
var item = hotbar.get_selected_item()
if item:
    print("Holding: ", item.item_name)
```

#### `get_selected_slot() -> int`
Returns the currently selected slot index (0-8).

#### `get_selected_quantity() -> int`
Returns the quantity of the selected item.

### Signals

#### `item_selected(item: ItemData, slot_index: int)`
Emitted when the player changes slots.

**Usage:**
```gdscript
hotbar.item_selected.connect(_on_item_selected)

func _on_item_selected(item: ItemData, slot_index: int):
    print("Selected: ", item.item_name if item else "Empty")
```

---

## Part 5: Player Integration

**File:** `scripts/player_example.gd`

### How to Connect Hotbar to Player

#### Step 1: Setup Scene Structure
```
Player (CharacterBody3D)
├── [Your existing player components]

CanvasLayer (sibling or child)
└── Hotbar
    └── [9 slots]

Inventory (Node, sibling or child of Player)
```

#### Step 2: Link References

In your player scene:
1. Select the Player node
2. In Inspector, find the `hotbar` export variable
3. Drag the Hotbar node into it

In the Hotbar node:
1. Select the Hotbar node
2. In Inspector, find the `inventory` export variable
3. Drag the Inventory node into it

#### Step 3: Connect Signal

```gdscript
# In player script _ready()
func _ready():
    hotbar.item_selected.connect(_on_hotbar_item_selected)
    current_item = hotbar.get_selected_item()

func _on_hotbar_item_selected(item: ItemData, slot_index: int):
    current_item = item
    current_slot = slot_index
    update_held_item()
```

### Using the Selected Item

#### Example: Use Item on Click
```gdscript
func _input(event: InputEvent):
    if event.is_action_pressed("use_item"):  # Left click
        use_current_item()

func use_current_item():
    if current_item == null:
        return
    
    # Do different things based on item
    match current_item.item_id:
        "stone":
            place_block()
        "potato":
            plant_potato()
        "water":
            water_crops()
    
    # Remove 1 from inventory
    hotbar.inventory.remove_item(current_slot, 1)
```

#### Example: Check What Player is Holding
```gdscript
func can_place_block() -> bool:
    return current_item != null and current_item.item_id == "stone"

func get_held_item_name() -> String:
    return current_item.item_name if current_item else "Nothing"
```

---

## Part 6: Testing the System

### Test Scene: `scenes/test_hotbar.tscn`

The test scene includes:
- An Inventory node
- A Hotbar in a CanvasLayer
- A TestController with debugging features

### Test Controls
- **Press T:** Add random test items
- **Press C:** Clear inventory
- **Press 1-9:** Select slots
- **Mouse Wheel:** Scroll through slots
- **Press Q/E:** Previous/Next slot

### Starting Items
The test scene starts with:
- Slot 1: Stone x32
- Slot 2: Wood x15
- Slot 3: Potato x8
- Slots 4-9: Empty

### Debug Output
When you select a slot, the console prints:
```
Selected Slot: 3
Selected Item: Potato
Quantity: 8
```

---

## Part 7: Adding New Items

### Method 1: In Godot Editor

1. Navigate to `resources/items/`
2. Right-click → **New Resource**
3. Search for and select **ItemData**
4. Configure:
   - `item_id`: "apple"
   - `item_name`: "Apple"
   - `item_description`: "A fresh apple"
   - `item_icon`: (drag your apple icon here)
   - `max_stack`: 16
5. Save as `apple.tres`

### Method 2: Code

```gdscript
# Preload in your script
var apple_item = preload("res://resources/items/apple.tres")

# Add to inventory
inventory.add_item(apple_item, 5)
```

### Method 3: Duplicate Existing

1. In FileSystem, right-click an existing item (e.g., `potato.tres`)
2. Select **Duplicate**
3. Rename to `apple.tres`
4. Open and modify properties

---

## Part 8: Connecting to Game Systems

### Example: Block Placement System

```gdscript
# In player script
func _input(event: InputEvent):
    if event.is_action_pressed("place_block"):
        place_block_at_cursor()

func place_block_at_cursor():
    var item = hotbar.get_selected_item()
    if item == null:
        return
    
    # Raycast to find placement position
    var camera = $Camera3D
    var space_state = get_world_3d().direct_space_state
    var origin = camera.global_position
    var end = origin + camera.global_transform.basis.z * -10
    
    var query = PhysicsRayQueryParameters3D.create(origin, end)
    var result = space_state.intersect_ray(query)
    
    if result:
        var block_position = result.position + result.normal
        place_block(item, block_position)
        hotbar.inventory.remove_item(hotbar.get_selected_slot(), 1)

func place_block(item: ItemData, position: Vector3):
    # Instance the appropriate block prefab
    var block_scene = load("res://scenes/blocks/" + item.item_id + "_block.tscn")
    var block = block_scene.instantiate()
    block.global_position = position.snapped(Vector3.ONE)
    get_tree().current_scene.add_child(block)
```

### Example: Crop Planting System

```gdscript
func plant_crop():
    var item = hotbar.get_selected_item()
    
    # Check if item is plantable
    if item == null or item.item_id != "potato":
        return
    
    # Check if player is looking at farmland
    if not is_looking_at_farmland():
        return
    
    # Plant the crop
    var crop_scene = preload("res://scenes/crops/potato_plant.tscn")
    var crop = crop_scene.instantiate()
    crop.global_position = get_targeted_position()
    get_tree().current_scene.add_child(crop)
    
    # Remove potato from inventory
    hotbar.inventory.remove_item(hotbar.get_selected_slot(), 1)
```

### Example: Item Pickup System

```gdscript
# In ItemPickup scene (Area3D that detects player)
func _on_body_entered(body: Node3D):
    if body is Player:
        var player = body as Player
        if player.hotbar and player.hotbar.inventory:
            var success = player.hotbar.inventory.add_item(item_data, quantity)
            if success:
                queue_free()  # Remove pickup from world
                # Play pickup sound, particle effect, etc.
```

---

## Part 9: Customization Tips

### Change Number of Slots

In `inventory.gd`:
```gdscript
const HOTBAR_SIZE: int = 12  # Change from 9 to 12
```

Then add 3 more HotbarSlot instances in `hotbar.tscn`.

### Change Slot Size

Select a HotbarSlot in the scene editor:
```gdscript
custom_minimum_size = Vector2(80, 80)  # Larger slots
```

### Change Selection Color

In `hotbar_slot.tscn`, edit the SelectionHighlight Panel's StyleBoxFlat:
- Change `border_color` to your preferred color
- Adjust `border_width` for thickness

### Add Tooltips

In `hotbar_slot.gd`, add:
```gdscript
func _make_custom_tooltip(for_text: String) -> Object:
    if item_data:
        var tooltip = Label.new()
        tooltip.text = item_data.item_name + "\n" + item_data.item_description
        return tooltip
    return null
```

### Add Item Rarity/Quality

Extend `ItemData`:
```gdscript
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }
@export var rarity: Rarity = Rarity.COMMON
```

Then color-code the slot borders based on rarity.

---

## Part 10: Common Issues & Solutions

### Issue: Input actions not working

**Solution:** Configure Input Map (see `INPUT_MAP_SETUP.md`)
1. Open Project → Project Settings → Input Map
2. Add actions: `hotbar_1` through `hotbar_9`, `hotbar_next`, `hotbar_previous`
3. Bind keys to each action

### Issue: Items not showing icons

**Solution:** 
1. Make sure you've assigned textures to item_icon in each ItemData resource
2. Check that image files are imported as Texture2D (not Image)

### Issue: Selection not visible

**Solution:** Check that SelectionHighlight panel has a visible StyleBoxFlat with colored borders.

### Issue: Inventory reference is null

**Solution:** 
1. Make sure Inventory node exists in the scene
2. In Hotbar node Inspector, drag Inventory node to the `inventory` property
3. Check that the NodePath is correct

### Issue: Mouse wheel not working

**Solution:** The code handles mouse wheel directly through `InputEventMouseButton`. Make sure no other script is consuming the mouse wheel input first.

### Issue: Quantity not showing

**Solution:** 
1. Check that QuantityLabel exists as a child of HotbarSlot
2. Verify the label is not hidden behind other elements
3. Check that font size is readable

---

## Part 11: Extending the System

### Add Drag-and-Drop

Create a drag system to rearrange items:
```gdscript
# In hotbar_slot.gd
func _get_drag_data(at_position: Vector2):
    if item_data:
        var preview = TextureRect.new()
        preview.texture = item_data.item_icon
        preview.size = Vector2(32, 32)
        set_drag_preview(preview)
        return {"item": item_data, "quantity": quantity, "from_slot": slot_index}
    return null

func _can_drop_data(at_position: Vector2, data):
    return data is Dictionary and data.has("item")

func _drop_data(at_position: Vector2, data):
    # Swap items between slots
    emit_signal("swap_slots", data.from_slot, slot_index)
```

### Add Item Categories

```gdscript
# In item_data.gd
enum Category { BLOCK, FOOD, TOOL, SEED }
@export var category: Category = Category.BLOCK
```

### Add Durability System

```gdscript
# In item_data.gd
@export var has_durability: bool = false
@export var max_durability: int = 100

# In inventory slot dictionary
# Add: durability: int
```

### Add Weight/Encumbrance

```gdscript
# In item_data.gd
@export var weight: float = 1.0

# In inventory.gd
func get_total_weight() -> float:
    var total = 0.0
    for slot in slots:
        if slot.item_data:
            total += slot.item_data.weight * slot.quantity
    return total
```

---

## Summary

You now have a complete hotbar system with:

✅ 9-slot hotbar UI at bottom of screen  
✅ Item data resources (Stone, Wood, Potato, etc.)  
✅ Inventory management with automatic stacking  
✅ Keyboard (1-9), mouse wheel, and Q/E selection  
✅ Visual selection highlighting with animations  
✅ Wrapping selection (9 → 1, 1 → 9)  
✅ Signal-based player integration  
✅ Test scene with debug features  
✅ Modular, beginner-friendly code  

### Next Steps

1. **Set up Input Map** (see `INPUT_MAP_SETUP.md`)
2. **Add item icons** (create/import 64x64 PNG images)
3. **Test the system** (run `test_hotbar.tscn`)
4. **Integrate with your player** (follow Player Integration section)
5. **Connect to game systems** (block placing, crop planting, etc.)

### File Checklist

- ✅ `scripts/item_data.gd` - Item resource definition
- ✅ `scripts/inventory.gd` - Inventory manager
- ✅ `scripts/hotbar_slot.gd` - Slot UI component
- ✅ `scripts/hotbar.gd` - Hotbar controller
- ✅ `scripts/player_example.gd` - Player integration example
- ✅ `resources/items/*.tres` - 5 example items
- ✅ `scenes/ui/hotbar_slot.tscn` - Slot scene
- ✅ `scenes/ui/hotbar.tscn` - Hotbar scene
- ✅ `scenes/test_hotbar.tscn` - Test scene

Happy coding! 🎮
