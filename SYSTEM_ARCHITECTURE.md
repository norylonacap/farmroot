# Hotbar System Architecture

## 🏗️ Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      PLAYER SCRIPT                          │
│  • Receives item_selected signals                           │
│  • Stores current_item reference                            │
│  • Calls use_item(), place_block(), etc.                    │
└────────────┬────────────────────────────────────────────────┘
             │ Listens to signals
             ↓
┌─────────────────────────────────────────────────────────────┐
│                      HOTBAR (UI)                            │
│  • Handles input (keyboard, mouse wheel)                    │
│  • Manages slot selection                                   │
│  • Emits item_selected(item, slot_index)                    │
│  • Updates visual highlights                                │
└────────────┬───────────────────────────┬────────────────────┘
             │                           │
             │ Updates display           │ Reads data
             ↓                           ↓
┌────────────────────────┐    ┌─────────────────────────────┐
│   HOTBAR SLOTS (x9)    │    │       INVENTORY             │
│  • Display item icon   │    │  • Stores 9 slots           │
│  • Display quantity    │    │  • Each slot contains:      │
│  • Show selection      │    │    - ItemData reference     │
│  • Play animations     │    │    - Quantity (int)         │
└────────────────────────┘    │  • Handles stacking logic   │
                              │  • Emits inventory_changed  │
                              └────────────┬────────────────┘
                                           │
                                           │ Uses
                                           ↓
                              ┌────────────────────────────┐
                              │     ITEM DATA (.tres)      │
                              │  • item_id                 │
                              │  • item_name               │
                              │  • item_icon               │
                              │  • max_stack               │
                              │  • item_description        │
                              └────────────────────────────┘
```

## 🔄 Data Flow

### When Player Presses "3" Key:

```
1. Input Event
   └→ Hotbar._input() detects "hotbar_3" pressed

2. Slot Selection
   └→ Hotbar.select_slot(2) called (index 0-8)
       └→ Old slot deselected (scale animation)
       └→ New slot selected (scale animation + highlight)

3. Data Retrieval
   └→ Hotbar.get_selected_item() queries Inventory
       └→ Inventory.get_slot(2) returns:
           { item_data: ItemData, quantity: int }

4. Signal Emission
   └→ Hotbar emits item_selected(ItemData, 2)

5. Player Response
   └→ Player._on_item_selected() receives signal
       └→ Updates current_item
       └→ Updates held item visual (3D model)
       └→ Prints debug info
```

### When Adding Item to Inventory:

```
1. Call Add Item
   └→ inventory.add_item(potato_item, 5)

2. Stacking Logic
   ├→ Search for existing stacks of same item
   │   └→ If found and not full: add to existing
   └→ Search for empty slots
       └→ Create new stack in empty slot

3. Signal Emission
   └→ inventory_changed.emit(slot_index)

4. UI Update
   └→ Hotbar._on_inventory_changed(slot_index)
       └→ Hotbar updates corresponding slot display
           └→ HotbarSlot.set_item(item, quantity)
               └→ Updates icon texture
               └→ Updates quantity label
```

## 🎯 Signal Flow

```
Inventory                    Hotbar                      Player
    │                          │                           │
    │ inventory_changed(slot) │                           │
    ├────────────────────────→│                           │
    │                          │                           │
    │                          │ item_selected(item, slot) │
    │                          ├─────────────────────────→│
    │                          │                           │
    │                          │                           │
```

## 📊 Slot State Machine

```
┌─────────┐
│  EMPTY  │ ← Initial state
└────┬────┘
     │
     │ add_item()
     ↓
┌─────────┐
│ FILLED  │ ← Has item and quantity
└────┬────┘
     │
     ├─ add_item(same) → increase quantity
     │
     ├─ remove_item() → decrease quantity
     │
     └─ quantity = 0 → back to EMPTY
```

## 🎨 Selection States

```
Slot 1   Slot 2   Slot 3   Slot 4
┌─────┐  ┏━━━━━┓  ┌─────┐  ┌─────┐
│     │  ┃     ┃  │     │  │     │
│     │  ┃ [icon] ┃  │     │  │     │
│     │  ┃  x5  ┃  │     │  │     │
└─────┘  ┗━━━━━┛  └─────┘  └─────┘
Normal   Selected  Normal   Normal
Scale:   Scale:    Scale:   Scale:
1.0      1.1       1.0      1.0
```

## 🔑 Key Relationships

### HotbarSlot → Hotbar
- **Relationship:** Child nodes
- **Communication:** Direct function calls
- **Data:** Display only (doesn't store data)

### Hotbar → Inventory
- **Relationship:** Reference via @export
- **Communication:** Function calls + signal listening
- **Data:** Hotbar reads from Inventory

### Hotbar → Player
- **Relationship:** Reference via @export
- **Communication:** Signals
- **Data:** Player queries Hotbar for selected item

### ItemData → Everything
- **Relationship:** Resource references
- **Communication:** Read-only data access
- **Data:** Shared immutable data

## 🧩 Modularity

### Independent Modules

```
ItemData (Resource)
└─ Can be used anywhere
   └─ Inventory system
   └─ Loot drops
   └─ Shop systems
   └─ Crafting systems

Inventory (Node)
└─ Storage only, no UI
   └─ Can work with different UIs
   └─ Can be saved/loaded
   └─ Can be extended

Hotbar (UI)
└─ Display + Input only
   └─ Can be restyled
   └─ Can be repositioned
   └─ Can show different inventories
```

## 🔧 Extension Points

### Want to add more features?

**Item tooltips**
└→ Extend HotbarSlot with _make_custom_tooltip()

**Drag and drop**
└→ Implement _get_drag_data() and _drop_data() in HotbarSlot

**Item durability**
└→ Add durability field to ItemData and slot dictionary

**Multiple hotbars**
└→ Create multiple Inventory nodes
└→ Switch Hotbar's inventory reference

**Item categories**
└→ Add category enum to ItemData
└→ Filter inventory by category

**Cooldowns**
└→ Add cooldown timer to HotbarSlot
└→ Show progress overlay

## 📝 Class Responsibilities

| Class | Responsibility | Does NOT Handle |
|-------|---------------|-----------------|
| **ItemData** | Define item properties | Quantities, locations |
| **Inventory** | Store items and quantities | UI, input, display |
| **Hotbar** | Handle input and selection | Item logic, game mechanics |
| **HotbarSlot** | Display slot contents | Input handling, data storage |
| **Player** | Use items in game world | UI, inventory management |

## 🎓 Design Principles Used

1. **Separation of Concerns**
   - UI separated from data
   - Input separated from logic

2. **Signal-Based Communication**
   - Loose coupling between components
   - Easy to extend without modifying existing code

3. **Resource System**
   - Reusable item definitions
   - Data-driven design

4. **Scene Instancing**
   - Reusable UI components
   - Easy to modify appearance

5. **Export Variables**
   - Visual connection in editor
   - No hardcoded paths

---

This architecture makes the system:
- ✅ Easy to understand
- ✅ Simple to modify
- ✅ Ready to extend
- ✅ Beginner-friendly
