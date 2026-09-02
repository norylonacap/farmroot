# Adding Item Icons - Step-by-Step Guide

## 📸 Preparing Icon Images

### Recommended Specifications
- **Format:** PNG (with transparency)
- **Size:** 64x64 pixels (or 128x128 for HD)
- **Style:** Flat, simple, clear at small sizes
- **Background:** Transparent

### Where to Get Icons
1. **Create your own** (Photoshop, GIMP, Aseprite)
2. **Free resources:**
   - OpenGameArt.org
   - Itch.io (search "icon pack")
   - Kenney.nl (free game assets)
3. **AI generation:** DALL-E, Midjourney, Stable Diffusion

## 📥 Importing Icons into Godot

### Method 1: Drag and Drop
1. Create a folder in your project: `res://textures/items/`
2. Drag PNG files from your file explorer into this folder
3. Godot will automatically import them

### Method 2: File System
1. Copy PNG files to: `<your_project_path>/textures/items/`
2. Return to Godot
3. Files appear automatically in FileSystem panel

### Verify Import Settings
1. Select the icon in FileSystem
2. Check the Import tab (next to Scene, Import, Node)
3. Ensure it's imported as **Texture2D** (default for images)
4. If settings changed, click **Reimport**

## 🔗 Assigning Icons to Items

### Method 1: In Godot Editor (Recommended for Beginners)

#### Step 1: Open Item Resource
1. Navigate to `resources/items/` in FileSystem
2. Double-click `stone.tres`
3. The Inspector shows ItemData properties

#### Step 2: Assign Icon
1. Find the `item_icon` property in Inspector
2. Click the `<empty>` dropdown
3. Choose **Quick Load**
4. Navigate to your icon file
5. Select it
6. Click **Open**

#### Step 3: Save
1. Press **Ctrl+S** or **Cmd+S**
2. The icon is now assigned!

### Method 2: Drag and Drop (Fastest)

1. Open the item resource (double-click `stone.tres`)
2. Open the folder containing your icons
3. Drag the icon file onto the `item_icon` field in Inspector
4. Done!

### Method 3: In Code (For Programmatic Creation)

```gdscript
# When creating items at runtime
var new_item = ItemData.new()
new_item.item_id = "diamond"
new_item.item_name = "Diamond"
new_item.item_icon = preload("res://textures/items/diamond.png")
new_item.max_stack = 64
```

## 🎨 Example Setup

### Folder Structure
```
textures/
└── items/
    ├── stone.png
    ├── wood.png
    ├── grass.png
    ├── potato.png
    └── water.png

resources/
└── items/
    ├── stone.tres  → links to stone.png
    ├── wood.tres   → links to wood.png
    ├── grass.tres  → links to grass.png
    ├── potato.tres → links to potato.png
    └── water.tres  → links to water.png
```

## 🔍 Troubleshooting

### Icon Not Showing in Hotbar

**Problem:** Icon field is set but nothing appears in game

**Solutions:**
1. **Check if icon is null:**
   ```gdscript
   print(item_data.item_icon)  # Should not be <null>
   ```

2. **Verify TextureRect is visible:**
   - Open `hotbar_slot.tscn`
   - Check ItemIcon node is not hidden
   - Check modulate is not transparent

3. **Check import settings:**
   - Select icon in FileSystem
   - Import tab should show "Texture2D"
   - Reimport if necessary

4. **Verify slot update logic:**
   ```gdscript
   # In hotbar_slot.gd update_display()
   print("Icon texture: ", item_data.item_icon)
   ```

### Icon Appears Blurry

**Problem:** Icon is pixelated or blurry

**Solution 1: Disable Filtering**
1. Select icon in FileSystem
2. Go to Import tab
3. Set **Filter** to **Nearest**
4. Click **Reimport**

**Solution 2: Use Higher Resolution**
- Export icons at 128x128 instead of 64x64
- Godot will downscale with better quality

### Icon Too Small/Large

**Problem:** Icon doesn't fit in the slot properly

**Solution:**
1. Open `hotbar_slot.tscn`
2. Select **ItemIcon** (TextureRect)
3. In Inspector, find **Expand Mode**
4. Set to **Fit Width Proportional** or **Fit Height Proportional**
5. Set **Stretch Mode** to **Keep Aspect Centered**

### Wrong Icon Showing

**Problem:** Item shows a different icon than assigned

**Solution:**
1. **Clear cache:**
   - Close Godot
   - Delete `.godot/` folder
   - Reopen project

2. **Check resource path:**
   ```gdscript
   print(item_data.resource_path)
   print(item_data.item_icon.resource_path)
   ```

3. **Verify no duplicate resources:**
   - Search for duplicate `.tres` files
   - Make sure you're editing the correct one

## 🎯 Quick Test

After assigning icons, test immediately:

1. Open `scenes/test_hotbar.tscn`
2. Run the scene (F6)
3. You should see:
   - Slot 1: Stone icon
   - Slot 2: Wood icon
   - Slot 3: Potato icon
4. Press **T** to add items and verify icons appear

## 🎨 Creating Placeholder Icons

If you don't have icons yet, create simple colored squares:

### Using GIMP (Free):
1. New Image: 64x64
2. Fill with color:
   - Stone: Gray (#808080)
   - Wood: Brown (#8B4513)
   - Grass: Green (#228B22)
   - Potato: Tan (#D2B48C)
   - Water: Blue (#1E90FF)
3. Export as PNG
4. Import into Godot

### Using Code (Generate in Godot):
```gdscript
# Create a simple colored texture
func create_placeholder_icon(color: Color) -> ImageTexture:
    var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
    image.fill(color)
    return ImageTexture.create_from_image(image)

# Use it:
stone_item.item_icon = create_placeholder_icon(Color.GRAY)
```

## 📋 Icon Checklist

Before moving on, verify:
- [ ] Icons are 64x64 or larger
- [ ] Icons are PNG format with transparency
- [ ] Icons are in a `textures/items/` folder
- [ ] Each ItemData resource has item_icon assigned
- [ ] Icons appear in test scene
- [ ] Icons are clear and recognizable at small size

## 🎓 Best Practices

1. **Consistent Style**
   - Keep all icons in the same art style
   - Use consistent lighting/shading
   - Maintain similar levels of detail

2. **Clear Silhouettes**
   - Icons should be recognizable at tiny sizes
   - Avoid excessive detail

3. **Naming Convention**
   ```
   textures/items/stone.png
   textures/items/wood.png
   ```
   (Match the item_id for easy reference)

4. **Organized Folders**
   ```
   textures/
   ├── items/
   ├── ui/
   └── effects/
   ```

5. **Version Control**
   - Keep source files (PSD, XCF) separate
   - Only commit PNG files to version control
   - Consider using `.import` gitignore

## 🚀 Ready to Go!

Once you have icons assigned:
1. All items will display properly in hotbar
2. Players can easily identify items
3. Your UI looks professional
4. You can focus on gameplay!

---

**Next Step:** Test your hotbar with icons in `test_hotbar.tscn`! 🎮
