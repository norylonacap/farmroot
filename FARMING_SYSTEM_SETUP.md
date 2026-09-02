# 3D Planting/Seed System - Setup Guide

## Complete Godot 4 Farming System

This is a complete, beginner-friendly 3D farming system with planting, growth stages, and harvesting.

---

## 🎮 QUICK START

1. **Configure Input Map** (see below)
2. **Open the test scene**: `scenes/farming_test_scene.tscn`
3. **Press F5** to run the game
4. **Use Q/E** to select seeds
5. **Look at the soil** and **Left Click** to plant
6. **Wait for growth** (Potato: 30s, Carrot: 20s)
7. **Press E** to harvest mature plants

---

## ⚙️ INPUT MAP CONFIGURATION

**CRITICAL:** You must add these Input Map actions in Project Settings → Input Map:

### Required Actions:

1. **move_forward** → W key
2. **move_backward** → S key
3. **move_left** → A key
4. **move_right** → D key
5. **plant** → Mouse Button Left
6. **interact** → E key
7. **next_seed** → E key (or Mouse Wheel Up)
8. **previous_seed** → Q key (or Mouse Wheel Down)

### How to Add Input Actions:

1. Go to **Project → Project Settings → Input Map**
2. Type the action name in the text field at the top
3. Click **Add**
4. Click the **+** button next to the action
5. Press the key you want to bind
6. Click **OK**
7. Repeat for all actions

---

## 📁 FILE STRUCTURE

```
d:\CAPG\1\
├── scripts/
│   ├── seed_data.gd              # Resource definition for seeds
│   ├── soil_area.gd              # Soil detection and validation
│   ├── plant.gd                  # Plant growth and interaction
│   ├── planting_manager.gd       # Coordinates planting system
│   ├── inventory.gd              # Item/seed management
│   ├── player_interaction.gd     # Raycast interaction system
│   ├── farming_ui.gd             # UI display
│   ├── simple_player_controller.gd  # First-person movement
│   └── farming_game_manager.gd   # Game initialization
│
├── scenes/
│   ├── farming_test_scene.tscn   # Main test scene
│   └── plants/
│       ├── potato_plant.tscn     # Potato plant prefab
│       └── carrot_plant.tscn     # Carrot plant prefab
│
└── resources/
	└── seeds/
		├── potato_seed.tres      # Potato seed data
		└── carrot_seed.tres      # Carrot seed data
```

---

## 🎯 COLLISION LAYERS

The system uses specific collision layers:

- **Layer 1** (Default): Ground and world objects
- **Layer 2** (Soil): Soil areas for planting
- **Layer 3** (Interaction): Plants and interactable objects

### How to Set Collision Layers:

**For SoilArea nodes:**
- Collision Layer: **2** (Soil)
- Collision Mask: **0** (detects nothing)

**For Plant InteractionArea:**
- Collision Layer: **4** (Layer 3, which is 2^2)
- Collision Mask: **0**

**For Player RayCast3D:**
- Collision Mask: **6** (Layers 2 + 3, which is 2 + 4)

---

## 🌱 HOW THE SYSTEM WORKS

### 1. PLANTING FLOW

```
Player selects seed (Q/E)
	↓
Aims at soil area
	↓
Green indicator appears (valid position)
	↓
Left Click to plant
	↓
Seed removed from inventory
	↓
Plant spawns at position
```

### 2. GROWTH SYSTEM

```
Plant spawned (Stage 0)
	↓
Timer starts (total_growth_time / growth_stages)
	↓
Stage 1 → Stage 2 → Stage 3
	↓
Plant becomes mature (can harvest)
```

### 3. HARVESTING

```
Plant reaches final stage
	↓
Player approaches mature plant
	↓
"Press E to Harvest" prompt appears
	↓
Press E
	↓
Harvest item added to inventory
	↓
Plant removed from world
```

---

## 🔧 ADDING NEW SEEDS

### Step 1: Create Plant Scene

1. Create a new scene: **Scene → New Scene**
2. Add a **Node3D** as root
3. Attach the **plant.gd** script
4. Add a **MeshInstance3D** child
5. Set the mesh (use any 3D model)
6. Save as `scenes/plants/your_plant.tscn`

### Step 2: Create Seed Resource

1. In FileSystem, right-click `resources/seeds/`
2. Select **New Resource**
3. Search for **SeedData**
4. Configure properties:
   - **Seed Name**: "Your Seed Name"
   - **Plant Scene**: Drag your plant scene here
   - **Total Growth Time**: 30.0 (seconds)
   - **Growth Stages**: 4
   - **Harvest Item Name**: "Your Crop"
   - **Harvest Amount**: 3
5. Save as `resources/seeds/your_seed.tres`

### Step 3: Add to Game Manager

1. Open `scenes/farming_test_scene.tscn`
2. Select the **GameManager** node
3. In Inspector, find **Available Seeds**
4. Increase the size
5. Drag your seed resource into the new slot

### Step 4: Give Starting Seeds (Optional)

Edit `scripts/farming_game_manager.gd` and add:

```gdscript
@export var starting_your_seed_seeds: int = 10

# In _setup_inventory():
elif seed.seed_name == "Your Seed Name":
	inventory.add_item(seed.seed_name, starting_your_seed_seeds)
```

---

## 🎨 CUSTOMIZING GROWTH STAGES

### Method 1: Scale-Based (Automatic)

The plant automatically scales from 30% to 100% size.

No setup needed!

### Method 2: Custom Meshes Per Stage

1. Create different meshes for each stage
2. In your **SeedData** resource:
3. Expand **Stage Meshes** array
4. Set size to **4** (or your growth_stages count)
5. Assign meshes:
   - Element 0: Seed/sprout mesh
   - Element 1: Small plant mesh
   - Element 2: Growing plant mesh
   - Element 3: Mature plant mesh

The plant will automatically swap meshes as it grows!

---

## 🎨 SOIL AREA SETUP

### Creating Custom Soil Areas

1. Add a **StaticBody3D** node
2. Attach **soil_area.gd** script
3. Add a **CollisionShape3D** child
4. Set shape to **BoxShape3D**
5. Adjust size in Inspector
6. Configure in Inspector:
   - **Soil Size**: Vector2(10, 10) for 10x10 area
   - **Grid Spacing**: 1.0 (distance between plants)
   - **Collision Layer**: 2 (Soil layer)

### Visual Feedback (Optional)

Add a **MeshInstance3D** to show where soil is:

```
SoilArea (StaticBody3D)
├── CollisionShape3D
└── MeshInstance3D (optional visual)
```

---

## 🎮 PLAYER SETUP

### Creating Your Own Player

If you want to integrate with your existing player:

1. **Add these child nodes to your player:**
   ```
   YourPlayer (CharacterBody3D)
   ├── Camera3D (or in a Head node)
   ├── PlayerInteraction (Node3D with player_interaction.gd)
   └── Inventory (Node with inventory.gd)
   ```

2. **Configure PlayerInteraction in Inspector:**
   - **Camera**: Link to your Camera3D
   - **Inventory**: Link to Inventory node
   - **Planting Manager**: Link to PlantingManager in scene
   - **Max Interaction Distance**: 5.0

3. **Add RayCast3D** (will auto-create if missing)

4. **Add FarmingUI** (CanvasLayer) to your scene root

---

## 🐛 TROUBLESHOOTING

### "Can't plant seeds!"

**Check:**
- ✅ Input Map actions are configured
- ✅ SoilArea collision layer is **2**
- ✅ RayCast collision mask includes **2**
- ✅ You have seeds in inventory
- ✅ Green indicator appears when looking at soil

### "Plants don't appear!"

**Check:**
- ✅ Plant scene is assigned in SeedData
- ✅ PlantingManager has plants_container assigned
- ✅ Check console for error messages

### "Can't harvest!"

**Check:**
- ✅ Plant is fully mature (wait full growth time)
- ✅ Standing close enough to plant
- ✅ "E" key is mapped to "interact" action
- ✅ InteractionArea collision layer is **4** (Layer 3)

### "Planting indicator doesn't show!"

**Check:**
- ✅ Looking at SoilArea (Layer 2)
- ✅ RayCast collision mask = **6** (2 + 4)
- ✅ Seed is selected (use Q/E)
- ✅ PlayerInteraction camera reference is set

### "Mouse won't move camera!"

**Solution:**
- Press **Escape** to capture mouse
- Or click in the game window

---

## 🎮 CONTROLS SUMMARY

| Action | Key/Button | Description |
|--------|------------|-------------|
| Move | W/A/S/D | Walk around |
| Look | Mouse | Camera look |
| Select Next Seed | E (or Q) | Cycle seeds forward |
| Select Previous Seed | Q (or E) | Cycle seeds backward |
| Plant | Left Click | Plant selected seed |
| Harvest | E | Harvest mature plant |
| Toggle Mouse | Escape | Capture/release cursor |

---

## 📊 SYSTEM FEATURES

✅ **Soil Detection** - Only plant on designated areas  
✅ **Grid Snapping** - Plants align to grid  
✅ **Duplicate Prevention** - Can't plant on same spot  
✅ **Growth Stages** - Automatic progression through stages  
✅ **Visual Feedback** - Green/red planting indicator  
✅ **Inventory System** - Track seeds and harvested items  
✅ **Seed Cycling** - Easy selection with Q/E keys  
✅ **Interaction Prompts** - Clear UI instructions  
✅ **Harvesting** - Mature plants give items  
✅ **Resource-Based** - Easy to add new seeds  
✅ **Beginner Friendly** - Clean, commented code  

---

## 🚀 EXTENDING THE SYSTEM

### Add Watering Mechanic

Add to `plant.gd`:

```gdscript
var is_watered: bool = false

func water() -> void:
    is_watered = true
    # Speed up growth timer
    growth_timer.wait_time *= 0.5
```

### Add Plant Health

```gdscript
var health: float = 100.0

func _process(delta: float) -> void:
    if not is_watered:
        health -= delta * 5.0  # Loses health without water
```

### Add Fertilizer

```gdscript
func apply_fertilizer() -> void:
    seed_data.harvest_amount += 1  # Bonus harvest
```

### Add Weather System

Connect to PlantingManager:

```gdscript
func set_weather(weather_type: String) -> void:
    for plant in active_plants:
        if weather_type == "rain":
            plant.water()
        elif weather_type == "drought":
            plant.growth_timer.paused = true
```

---

## 💡 TIPS FOR GAME DESIGNERS

1. **Growth Times**: Adjust for game pacing
   - Fast gameplay: 10-20 seconds
   - Realistic: 60-120 seconds
   - Idle game: 300+ seconds

2. **Harvest Amounts**: Balance risk vs reward
   - Common crops: 1-3 items
   - Rare crops: 1 item
   - Staple crops: 4-6 items

3. **Grid Spacing**: Affects farm density
   - Tight farms: 0.5 spacing
   - Normal: 1.0 spacing
   - Large plants: 2.0 spacing

4. **Growth Stages**: More stages = smoother progression
   - Minimum: 2 stages (planted → mature)
   - Recommended: 4 stages
   - Maximum: 6-8 stages for detailed crops

---

## 📝 CODE EXAMPLES

### Check if Player Has Seeds

```gdscript
if inventory.has_item("Potato Seed", 5):
    print("Player has at least 5 potato seeds!")
```

### Manually Spawn a Plant

```gdscript
var seed := load("res://resources/seeds/potato_seed.tres")
var position := Vector3(0, 0, 0)
planting_manager.try_plant_seed(seed, position, soil_area)
```

### Listen for Harvest Events

```gdscript
planting_manager.plant_spawned.connect(_on_plant_spawned)

func _on_plant_spawned(plant: Plant, position: Vector3) -> void:
    print("New plant at: ", position)
    plant.plant_harvested.connect(_on_harvested)

func _on_harvested(item: String, amount: int) -> void:
    print("Harvested %d x %s!" % [amount, item])
```

---

## 🎓 LEARNING RESOURCES

### Key Godot Concepts Used:

- **Resources** - Reusable data (SeedData)
- **Signals** - Event communication
- **RayCast3D** - 3D position detection
- **Collision Layers** - Selective collision
- **Timers** - Time-based progression
- **PackedScenes** - Prefab instantiation
- **@export** - Inspector variables

### Recommended Next Steps:

1. Watch Godot 4 tutorials on Signals
2. Learn about Resource system
3. Study collision layers in depth
4. Experiment with particle effects
5. Add save/load system for plant states

---

## 📞 NEED HELP?

If something isn't working:

1. **Check the console** - Press F4 in Godot
2. **Verify Input Map** - Most common issue
3. **Check collision layers** - Second most common
4. **Review node paths** - Ensure references are set
5. **Test in farming_test_scene.tscn first**

---

## ✨ ENJOY YOUR FARMING SYSTEM!

You now have a complete, extensible farming system ready for your game.

Happy planting! 🌾🥕🥔
