# Farming Tool System Implementation

This implementation follows the YouTube video tutorial for creating a farming tool system in Godot.

## Features Implemented

### 1. Item Bar Script (`item_bar.gd`)
- **Active Item Tracking**: Added `currentItem` variable to hold the currently selected item
- **Selected Item Signal/Method**: Updated `_on_slot_selected()` to update `currentItem` when slot selection occurs
- **Getter Method**: Created `get_current_item()` function to safely retrieve the selected item from other scripts

### 2. Player Script (`player.gd`)
- **Input Handling**: Implemented `_unhandled_input(event)` to detect interaction key presses (`actionQ` - Q key)
- **Raycast Interaction Check**: Validates if the player's raycast collision target implements the `tool_interaction` method
- **Tool Validation**: Created `_check_using_tool(currentItem)` to check if the currently selected item matches a usable farming tool (HOE or WATERING_CAN)
- **Tool Usage Logic**: Defined `_use_tool(toolType)` which:
  - Sets `onAction = true`
  - Temporarily disables physics processing (`set_physics_process(false)`)
  - Triggers tool animation (placeholder timer for now)
  - Re-enables physics processing
  - Calls `tool_interaction(toolType)` on the targeted tile/object
  - Sets `onAction = false` when complete

### 3. Soil Node Script (`soil.gd`)
- **Watering Interaction**: Script monitors state variable `hasWater = false`
- **Handling Tool Interaction**: Implemented `tool_interaction(toolType)` to check if the tool being used is a watering can
- **Visual Material Change**: When watered, executes `_darken_mesh_color()` to alter the material properties and darken the albedo color, giving a wet soil appearance

### 4. Ground Tile Script (`field.gd`)
- **Objects Container**: Added a `Node3D` container named `objects` to host instantiated objects on the ground tile
- **Instantiating Soil**: Preloaded the soil scene (`SOIL`)
- **Handling Hoe Tool**: In `tool_interaction(toolType)`, if the hoe is used and the tile does not yet have soil (`hasSoil == false`), it triggers `_add_soil()`
- **Placing Soil & Propagating Interactions**: `_add_soil()` instantiates the soil scene under the objects node and adjusts its Y-position. If soil already exists, tool interactions are passed directly to child objects via `object.tool_interaction(toolType)`

## Item Types Enum

Updated `ITEM_BAR_ITEM.ITEM_TYPES`:
- `NONE` - No item
- `HOE` - Used to till soil
- `WATERING_CAN` - Used to water soil
- `C_TOOL` - Other tools

## Input Mapping

Added `actionQ` input action mapped to the Q key for tool interaction.

## Usage

1. **Select a Tool**: Use number keys (1, 2, 3) or scroll wheel to select items in the item bar
2. **Use the Tool**: Aim at a ground tile and press Q
   - With HOE: Creates tilled soil on the ground
   - With WATERING_CAN: Waters existing soil (darkens the color)

## Scene Structure

```
Field (StaticBody3D)
├── selectionMesh (shows when targeted)
└── objects (Node3D container)
    └── Soil (MeshInstance3D - created when hoe is used)
```

## Next Steps

To fully complete the system as in the video:
1. Replace the animation placeholder timer with actual tool animations
2. Add animation player and set up "IH_Melee_Attack_Chop" or similar animations
3. Create watering can tool scene and add it to the item resources
4. Add visual effects for watering (particles, etc.)
5. Expand tool types (rake, seeds, etc.)
