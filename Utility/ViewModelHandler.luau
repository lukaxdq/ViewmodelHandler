--[=[
    @class ViewModelHandler
    A flexible viewmodel system for Roblox games with per-weapon settings support

    @author Luka
    @version 1.1.0
    
    Features:
    - Per-viewmodel sway and bob settings
    - Smooth transitions between viewmodels
    - Performance optimized rendering
    - Easy to configure settings
    - Type-safe parameters
    
    Example usage:
    ```lua
    local ViewModelHandler = require(path.to.ViewModelHandler)
    
    -- Add custom settings for a weapon
    ViewModelHandler.AddSettings("AssaultRifle", {
        swayAmount = 0.4,
        bobAmount = 0.03,
        bobSpeed = 8,
        smoothness = 0.15,
        offset = Vector3.new(0, -0.2, 0),
        rotation = Vector3.new(0, 0, 0)
    })
    
    -- Setup and start the handler
    ViewModelHandler.Setup()
    ViewModelHandler.Load("AssaultRifle")
    ViewModelHandler.Start()
    ```
]=]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

export type ViewModelSettings = {
    swayAmount: number,
    bobAmount: number,
    bobSpeed: number,
    smoothness: number,
    offset: Vector3,
    rotation: Vector3
}

local ViewModelHandler = {
    Version = "1.1.0",
    Author = "[Your Name]",
    
    -- Default settings
    Settings = {
        Default = {
            swayAmount = 0.6,
            bobAmount = 0.05,
            bobSpeed = 6,
            smoothness = 0.1,
            offset = Vector3.new(0, 0, 0),
            rotation = Vector3.new(0, 0, 0)
        } :: ViewModelSettings
    }
}

-- Private variables
local currentSettings = ViewModelHandler.Settings.Default
local swayCF = CFrame.new()
local lastCameraCF = CFrame.new()
local player
local currentViewModel
local renderConnection

local DEFAULT_VIEWMODEL = "EmptyHands"

-- Load viewmodel specific settings
local function loadViewModelSettings(viewModelName: string)
    local settings = ViewModelHandler.Settings[viewModelName]
    if settings then
        currentSettings = settings
    else
        currentSettings = ViewModelHandler.Settings.Default
    end
end

function ViewModelHandler.Setup()
	player = Players.LocalPlayer or Players.PlayerAdded:Wait()
	if not player.Character then
		player.CharacterAdded:Wait()
	end
	if not Camera then
		Camera = workspace.CurrentCamera or workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
	end
end

function ViewModelHandler.Load(viewModelName: string?)
    if currentViewModel then
        currentViewModel:Destroy()
        currentViewModel = nil
    end

    local nameToLoad = viewModelName or DEFAULT_VIEWMODEL
    loadViewModelSettings(nameToLoad)

    local viewModelTemplate = ReplicatedStorage:WaitForChild("ViewModels"):FindFirstChild(nameToLoad)
    if not viewModelTemplate then
        warn("ViewModel " .. nameToLoad .. " not found.")
        return
    end

    currentViewModel = viewModelTemplate:Clone()
    currentViewModel.Parent = Camera
end

function ViewModelHandler.Unload()
	if currentViewModel then
		currentViewModel:Destroy()
		currentViewModel = nil
	end
end

function ViewModelHandler.Start()
    if renderConnection then return end

    local time: number = 0
    local bobOffset: number = 0

    renderConnection = RunService.RenderStepped:Connect(function(dt)
        if not currentViewModel or not player then return end

        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")

        if not humanoid or humanoid.Health <= 0 then
            ViewModelHandler.Unload()
            ViewModelHandler.Load(DEFAULT_VIEWMODEL)
            return
        end

        local isMoving = humanoid.MoveDirection.Magnitude > 0

        if currentViewModel.PrimaryPart then
            time = time + dt

            -- Make parts non-collidable
            for _, v in pairs(currentViewModel:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end

            -- Calculate sway
            local rot = Camera.CFrame:ToObjectSpace(lastCameraCF)
            local x, y, _z = rot:ToOrientation()
            swayCF = swayCF:Lerp(
                CFrame.Angles(
                    math.sin(x) * currentSettings.swayAmount,
                    math.sin(y) * currentSettings.swayAmount,
                    0
                ),
                currentSettings.smoothness
            )

            -- Calculate bob
            if isMoving then
                bobOffset = math.sin(time * currentSettings.bobSpeed) * currentSettings.bobAmount
            else
                bobOffset = bobOffset * 0.8
            end

            lastCameraCF = Camera.CFrame

            -- Apply final transformations
            local finalCFrame = Camera.CFrame 
                * swayCF 
                * CFrame.new(0, bobOffset, 0)
                * CFrame.new(currentSettings.offset)
                * CFrame.Angles(
                    math.rad(currentSettings.rotation.X),
                    math.rad(currentSettings.rotation.Y),
                    math.rad(currentSettings.rotation.Z)
                )

            currentViewModel:SetPrimaryPartCFrame(finalCFrame)
        end
    end)
end

function ViewModelHandler.Stop()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    ViewModelHandler.Unload()
end

--[=[
    @function AddSettings
    @param viewModelName string -- The name of the viewmodel to add settings for
    @param settings ViewModelSettings -- The settings to apply to the viewmodel
    @return nil

    Adds or updates settings for a specific viewmodel. If settings for the viewmodel
    already exist, they will be updated with the new values.

    Example:
    ```lua
    ViewModelHandler.AddSettings("AssaultRifle", {
        swayAmount = 0.4,
        bobAmount = 0.03,
        bobSpeed = 8,
        smoothness = 0.15,
        offset = Vector3.new(0, -0.2, 0),
        rotation = Vector3.new(0, 0, 0)
    })
    ```
]=]
function ViewModelHandler.AddSettings(viewModelName: string, settings: ViewModelSettings)
    ViewModelHandler.Settings[viewModelName] = {
        swayAmount = settings.swayAmount or ViewModelHandler.Settings.Default.swayAmount,
        bobAmount = settings.bobAmount or ViewModelHandler.Settings.Default.bobAmount,
        bobSpeed = settings.bobSpeed or ViewModelHandler.Settings.Default.bobSpeed,
        smoothness = settings.smoothness or ViewModelHandler.Settings.Default.smoothness,
        offset = settings.offset or ViewModelHandler.Settings.Default.offset,
        rotation = settings.rotation or ViewModelHandler.Settings.Default.rotation
    }
end

return ViewModelHandler
