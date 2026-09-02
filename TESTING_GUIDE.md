# FARMROOT UI Testing Guide

## Quick Start Testing

### 1. Open the Project
1. Open Godot Engine 4.6
2. Open the FARMROOT project at `d:\CAPG\1`

### 2. Verify AutoLoad
1. Go to **Project → Project Settings → Autoload**
2. Verify `GameManager` is listed and points to `res://scripts/game_manager.gd`
3. If not present, the system will not work correctly

### 3. Verify Main Scene
1. Go to **Project → Project Settings → Application → Run**
2. Check that **Main Scene** is set to `res://game/scene/ui/loading_screen.tscn`
3. This should show UID: `uid://dtn8tjxrs7hhs`

### 4. Run the Game
Press **F5** or click the **Play** button

## Expected Flow

### Loading Screen (Auto-Transition)
**What you should see:**
- Light gray/white background
- Gray panel in center
- Text: "DISCLAIMER"
- Text: "this game is about"
- Text: "Loading..."
- Progress bar filling up

**Expected behavior:**
- Progress bar fills automatically
- After ~1-3 seconds, automatically transitions to Main Menu
- No button clicks required

**If it doesn't work:**
- Check console for errors
- Verify loading_screen.tscn exists
- Verify loading_screen.gd script is attached

---

### Main Menu
**What you should see:**
- Light gray background
- "FARMROOT" title on the left side
- Three buttons on the right:
  - START
  - CREDITS
  - EXIT

**Test each button:**

#### START Button
- **Action**: Click START
- **Expected**: Transition to Crop Selection screen
- **If fails**: Check main_menu.gd connections

#### CREDITS Button
- **Action**: Click CREDITS
- **Expected**: Transition to Credits screen
- **If fails**: Check GameManager scene paths

#### EXIT Button
- **Action**: Click EXIT
- **Expected**: Game closes immediately
- **If fails**: Check button connection

---

### Crop Selection Screen
**What you should see:**
- "SELECT YOUR CROP" title at top
- Three crop cards in a row:
  - **POTATO** card with SELECT button
  - **CASAVA** card with SELECT button
  - **YAM** card with SELECT button
- BACK button in bottom-right

**Test each crop:**

#### POTATO
1. Click **SELECT** button on POTATO card
2. Game should transition to gameplay (farming scene)
3. Check the **Output** console
4. Should see: `"Added selected seed to inventory: potato"`
5. In the game:
   - Press **3** key to select inventory slot 3
   - You should now have potato seed equipped
   - Look at soil and press **Q** to plant

#### CASAVA
1. Return to main menu (will need to restart or implement menu access)
2. Click START → Click CASAVA SELECT
3. Check console: `"Added selected seed to inventory: casava"`
4. Press **3** to access casava seed

#### YAM
1. Return to main menu
2. Click START → Click YAM SELECT
3. Check console: `"Added selected seed to inventory: yam"`
4. Press **3** to access yam seed

#### BACK Button
- **Action**: Click BACK
- **Expected**: Return to Main Menu
- **If fails**: Check crop_selection.gd script

---

### Credits Screen
**What you should see:**
- "FARMROOT" title
- "Developed by:"
- "CAPG Team"
- "Created using Godot Engine"
- BACK button at bottom

**Test:**
- Click **BACK** button
- Should return to Main Menu

---

## In-Game Testing (After Crop Selection)

### Verify Inventory
1. After selecting a crop and entering gameplay
2. Look at bottom of screen for inventory bar
3. Slot 1: Hoe (tool)
4. Slot 2: C-tool (tool)
5. Slot 3: Your selected seed (POTATO/CASAVA/YAM)

### Test Planting
1. Press **3** to select the seed
2. Walk to a farming plot (the grid areas in the game)
3. Look at the soil
4. Press **Q** to plant the seed
5. Seed should plant and grow over time

### Controls Reminder
- **W/A/S/D**: Move
- **Mouse**: Look around
- **1/2/3**: Select inventory slots
- **Q**: Use tool/plant seed
- **Mouse Wheel**: Scroll through inventory

---

## Common Issues & Solutions

### Issue: Loading screen doesn't appear
**Solution:**
1. Check Project Settings → Run → Main Scene
2. Should be `res://game/scene/ui/loading_screen.tscn`
3. Re-set if necessary

### Issue: Buttons don't work
**Solution:**
1. Open the scene in Godot editor
2. Select the button node
3. Check the script is attached
4. Verify signal connections in the script

### Issue: GameManager not found error
**Solution:**
1. Project Settings → Autoload
2. Add `GameManager` with path `res://scripts/game_manager.gd`
3. Enable the star (*) to make it a singleton

### Issue: Seed doesn't appear in inventory
**Solution:**
1. Check console output for errors
2. Verify seed resource files exist:
   - `game/assets/character/item_resource/potato_seed.tres`
   - `game/assets/character/item_resource/casava_seed.tres`
   - `game/assets/character/item_resource/yam_seed.tres`
3. Check player.gd has the initialization code

### Issue: Scenes not found
**Solution:**
1. Verify all .tscn files exist in correct locations
2. Check GameManager.gd has correct scene paths
3. Re-save scenes if necessary

### Issue: Crop selection buttons do nothing
**Solution:**
1. Open `crop_selection.gd`
2. Check `_ready()` function connects buttons
3. Verify button node names match script

---

## Debug Console Commands

Open the console output (Output tab in Godot) to see:
- `"Added selected seed to inventory: [crop_name]"` - Seed added successfully
- `"No seed selected from menu, using default inventory"` - No crop was selected
- Any error messages about missing resources

---

## Verification Checklist

Before submitting/demonstrating:

- [ ] Loading screen appears and transitions automatically
- [ ] Main menu appears with all three buttons
- [ ] START button opens crop selection
- [ ] All three crop cards are visible
- [ ] Each SELECT button loads gameplay with correct seed
- [ ] BACK button returns to main menu
- [ ] CREDITS button shows credits screen
- [ ] Credits BACK button returns to main menu
- [ ] EXIT button closes the game
- [ ] Selected seed appears in inventory slot 3
- [ ] Seed can be equipped with key 3
- [ ] Seed can be planted with Q key
- [ ] No console errors appear during normal flow

---

## Scene Paths Reference

For debugging or manual testing:

```
Loading Screen:  res://game/scene/ui/loading_screen.tscn
Main Menu:       res://game/scene/main_menu/main_menu.tscn
Crop Selection:  res://game/scene/main_menu/crop_selection.tscn
Credits:         res://game/scene/main_menu/credits.tscn
Gameplay:        res://game/scene/main.tscn
```

To manually open a scene:
1. Go to FileSystem panel in Godot
2. Navigate to the path above
3. Double-click the .tscn file

---

## Video Reference

Original reference video: https://youtu.be/zHYkcJyE52g

Compare your implementation against this video to ensure visual consistency.
