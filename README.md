# ViewModelHandler

A flexible and powerful viewmodel system for Roblox games that supports per-weapon settings, smooth transitions, and performance-optimized rendering.

## Features

- Per-viewmodel sway and bob settings
- Smooth transitions between viewmodels
- Performance optimized rendering
- Easy to configure settings
- Type-safe parameters
- Customizable offset and rotation
- Built-in animation support (bob and sway)

## Installation

1. Clone the repository or download the files
2. Place the `ViewModelHandler` folder in your game's ReplicatedStorage or in a shared module location
3. Make sure you have a `ViewModels` folder in ReplicatedStorage containing your viewmodel models

## Basic Setup

```lua
local ViewModelHandler = require(path.to.ViewModelHandler)

-- Initialize the handler
ViewModelHandler.Setup()

-- Load the default viewmodel
ViewModelHandler.Load("DefaultViewModel")

-- Start the handler
ViewModelHandler.Start()
```

## Advanced Usage

### Adding Custom Settings Per Weapon

```lua
-- Configure an assault rifle with moderate sway and bob
ViewModelHandler.AddSettings("AssaultRifle", {
    swayAmount = 0.4,    -- How much the weapon sways when looking around
    bobAmount = 0.03,    -- How much the weapon bobs when moving
    bobSpeed = 8,        -- Speed of the bob animation
    smoothness = 0.15,   -- How smooth the transitions are (lower = smoother)
    offset = Vector3.new(0, -0.2, 0),  -- Position offset from camera
    rotation = Vector3.new(0, 0, 0)    -- Rotation offset from camera
})

-- Configure a sniper with minimal sway for precision
ViewModelHandler.AddSettings("Sniper", {
    swayAmount = 0.2,    -- Less sway for better aim
    bobAmount = 0.02,    -- Minimal movement when walking
    bobSpeed = 6,
    smoothness = 0.2,
    offset = Vector3.new(0, -0.15, 0.1),
    rotation = Vector3.new(0, 0, 0)
})

-- Switch between weapons
ViewModelHandler.Load("AssaultRifle")  -- Will use AssaultRifle-specific settings
-- ... later ...
ViewModelHandler.Load("Sniper")        -- Will smoothly transition to Sniper settings
```

### Default Settings

These are the default settings that will be used if no custom settings are provided:

```lua
{
    swayAmount = 0.6,
    bobAmount = 0.05,
    bobSpeed = 6,
    smoothness = 0.1,
    offset = Vector3.new(0, 0, 0),
    rotation = Vector3.new(0, 0, 0)
}
```

### Full Implementation Example

Here's a complete example showing how to integrate the ViewModelHandler with a weapon system:

```lua
local ViewModelHandler = require(path.to.ViewModelHandler)

-- Define weapon settings
local weaponSettings = {
    AssaultRifle = {
        swayAmount = 0.4,
        bobAmount = 0.03,
        bobSpeed = 8,
        smoothness = 0.15,
        offset = Vector3.new(0, -0.2, 0),
        rotation = Vector3.new(0, 0, 0)
    },
    
    Pistol = {
        swayAmount = 0.3,
        bobAmount = 0.04,
        bobSpeed = 10,
        smoothness = 0.1,
        offset = Vector3.new(0, -0.15, 0),
        rotation = Vector3.new(0, 0, 0)
    },
    
    Sniper = {
        swayAmount = 0.2,
        bobAmount = 0.02,
        bobSpeed = 6,
        smoothness = 0.2,
        offset = Vector3.new(0, -0.15, 0.1),
        rotation = Vector3.new(0, 0, 0)
    }
}

-- Initialize the system
local function init()
    -- Register all weapon settings
    for weaponName, settings in pairs(weaponSettings) do
        ViewModelHandler.AddSettings(weaponName, settings)
    end
    
    -- Setup the handler
    ViewModelHandler.Setup()
    
    -- Load initial weapon
    ViewModelHandler.Load("AssaultRifle")
    
    -- Start the handler
    ViewModelHandler.Start()
end

-- Handle weapon switching
local function switchWeapon(weaponName)
    if weaponSettings[weaponName] then
        ViewModelHandler.Load(weaponName)
    end
end

-- Cleanup when needed
local function cleanup()
    ViewModelHandler.Stop()
end

-- Initialize the system
init()

-- Example usage with keybinds
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.One then
        switchWeapon("AssaultRifle")
    elseif input.KeyCode == Enum.KeyCode.Two then
        switchWeapon("Pistol")
    elseif input.KeyCode == Enum.KeyCode.Three then
        switchWeapon("Sniper")
    end
end)
```

### Required Folder Structure

Make sure you have the following structure in your game:

```
ReplicatedStorage
└── ViewModels
    ├── AssaultRifle
    ├── Pistol
    ├── Sniper
    └── EmptyHands (default viewmodel)
```

Each viewmodel should be a Model with a PrimaryPart set.

## API Reference

### ViewModelHandler.Setup()
Initializes the handler and sets up necessary connections.

### ViewModelHandler.Load(viewModelName: string?)
Loads a viewmodel and applies its settings. If no name is provided, loads the default viewmodel.

### ViewModelHandler.AddSettings(viewModelName: string, settings: ViewModelSettings)
Adds or updates settings for a specific viewmodel.

### ViewModelHandler.Start()
Starts the viewmodel rendering and animations.

### ViewModelHandler.Stop()
Stops the viewmodel rendering and cleans up connections.

### ViewModelHandler.Unload()
Removes the current viewmodel.

## Types

```lua
type ViewModelSettings = {
    swayAmount: number,   -- Amount of sway when looking around
    bobAmount: number,    -- Amount of bob when moving
    bobSpeed: number,     -- Speed of the bob animation
    smoothness: number,   -- Smoothness of transitions
    offset: Vector3,      -- Position offset from camera
    rotation: Vector3     -- Rotation offset from camera
}
```

## License

MIT License - Feel free to use this in your games!
