# Plants System

## Overview

This folder contains the planting and growth system for the farming game.

## File Structure

```
plants/
├── plant_resource.gd         # Plant data definition (class_name PLANT_RESOURCE)
├── plant_scene.gd            # Plant instance logic and growth
├── plant_scene.tscn          # Plant scene template
├── harvest_example.gd        # Example harvest implementation
│
├── carrot_resource.tres      # Example: Carrot plant data
├── carrot_stage_1.tscn       # Example: Seed stage
├── carrot_stage_2.tscn       # Example: Growing stage
└── carrot_stage_3.tscn       # Example: Mature stage
```

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     PLANTING SYSTEM                         │
└─────────────────────────────────────────────────────────────┘

1. RESOURCES (Data)
   ┌──────────────────┐      ┌──────────────────┐
   │ PLANT_RESOURCE   │      │ ITEM_BAR_ITEM    │
   │ ───────────────  │      │ ────────────────  │
   │ • stageScenes[]  │◄─────│ • itemType: SEED │
   │ • daysPerStage[] │      │ • plantResource  │
   └──────────────────┘      └──────────────────┘
            │
            │ linked to
            ▼
2. SCENES (Visual)
   ┌──────────────────┐
   │  PlantScene      │
   │  ─────────────── │
   │  ├─ model (Node) │
   │  └─ script       │
   └──────────────────┘
            │
            │ instantiates
            ▼
   ┌──────────────────┐
   │  Stage Scene     │
   │  ─────────────── │
   │  • 3D Model      │
   │  • Materials     │
   └──────────────────┘

3. LOGIC (Scripts)
   ┌──────────────────┐      ┌──────────────────┐
   │   player.gd      │─────►│    soil.gd       │
   │  Handles input   │      │  • plant_seed()  │
   │  Checks SEED     │      │  • Validates     │
   └──────────────────┘      └──────────────────┘
            │                          │
            │                          │ spawns
            ▼                          ▼
   ┌────────────────────────────────────────────┐
   │           plant_scene.gd                   │
   │  • _instantiate_stage()                    │
   │  • advance_day()                           │
   │  • is_fully_grown()                        │
   └────────────────────────────────────────────┘
                      │
                      │ managed by
                      ▼
   ┌────────────────────────────────────────────┐
   │          day_manager.gd                    │
   │  • Tracks time                             │
   │  • Calls advance_day() on all plants       │
   └────────────────────────────────────────────┘
```

## Growth Cycle

```
Day 0:  🌱 SEED PLANTED
        │  Player presses Q with seed selected
        │  Soil validates and spawns PlantScene
        │  Stage 0 instantiated
        ▼
Day 2:  🌿 SPROUT
        │  DayManager advances days
        │  daysPerStage[0] reached (2 days)
        │  Stage 1 instantiated
        ▼
Day 5:  🌾 GROWING
        │  daysPerStage[1] reached (3 more days)
        │  Stage 2 instantiated
        ▼
Day 9:  🥕 MATURE
        │  daysPerStage[2] reached (4 more days)
        │  Stage 3 instantiated
        │  Ready for harvest
        ▼
```

## Adding New Plants

### Quick Template

1. **Create stage scenes** (copy and modify existing ones)
   ```
   my_plant_stage_1.tscn
   my_plant_stage_2.tscn
   my_plant_stage_3.tscn
   ```

2. **Create plant resource** (.tres file)
   - Type: PLANT_RESOURCE
   - stageScenes: [stage_1, stage_2, stage_3]
   - daysPerStage: [2, 3, 4]

3. **Create seed item** (.tres file)
   - Type: ITEM_BAR_ITEM  
   - itemType: SEED (4)
   - plantResource: (link to step 2)
   - texture: (your icon)

4. **Add to game** (item bar inventory)

## Code Integration

### Getting Plant Instance

```gdscript
# In soil.gd or other scripts
if plantedPlant:
    var current_stage = plantedPlant.get_current_stage()
    var is_ready = plantedPlant.is_fully_grown()
```

### Manual Growth Advancement

```gdscript
# Useful for debugging or special events
var plant = soil.plantedPlant
if plant:
    plant.advance_day()  # Force grow by 1 day
```

### Day Manager Integration

```gdscript
# Already automatic, but manual control:
var day_mgr = get_tree().get_first_node_in_group("day_manager")
day_mgr.skip_day()  # Advance all plants
```

## Plant States

| State | Stage | is_fully_grown() | Can Harvest |
|-------|-------|------------------|-------------|
| Seed  | 0     | false            | ❌ |
| Sprout| 1     | false            | ❌ |
| Growing| 2    | false            | ❌ |
| Mature| 3     | true             | ✅ |

## Events & Signals

The system uses node groups instead of signals for simplicity:

- **"plants" group**: All plant instances auto-join
- **"day_manager" group**: Day manager joins for easy access

### Future Signal Options

```gdscript
# Could add to plant_scene.gd:
signal growth_stage_changed(new_stage: int)
signal plant_matured()

# Could add to day_manager.gd:
signal day_advanced(day_number: int)  # Already exists!
```

## Performance Notes

- Each plant is a separate Node3D instance
- Growth stages swap child nodes (old freed, new added)
- Day manager uses get_nodes_in_group() once per day
- No performance concerns for typical farm sizes (<1000 plants)

## Extending the System

### Add Watering Requirement

```gdscript
# In plant_scene.gd
var isWatered: bool = false

func advance_day():
    if not isWatered:
        return  # Don't grow without water
    
    isWatered = false  # Reset for next day
    # ... rest of growth logic
```

### Add Plant Health

```gdscript
# In plant_scene.gd
@export var health: float = 100.0

func take_damage(amount: float):
    health -= amount
    if health <= 0:
        queue_free()  # Plant dies
```

### Add Seasonal Growth

```gdscript
# In plant_resource.gd
@export var growthSeasons: Array[String] = ["Spring", "Summer"]

# In plant_scene.gd
func can_grow() -> bool:
    var season_mgr = get_tree().get_first_node_in_group("season_manager")
    return plantResource.growthSeasons.has(season_mgr.current_season)
```

## Testing

### Fast Test Setup
```gdscript
# DayManager settings
seconds_per_day = 5  # 5 seconds = 1 day

# Carrot resource settings  
daysPerStage = [1, 1, 1]  # 3 days total (15 seconds real time)
```

### Debug Print
```gdscript
# Add to plant_scene.gd advance_day()
print("Plant stage %d, days: %d/%d" % [
    currentStage, 
    currentStageDays, 
    plantResource.daysPerStage[currentStage]
])
```

Happy planting! 🌱
