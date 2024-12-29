local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local src = ReplicatedStorage.src
local pcar = src.pcar

local CarInput = require(pcar.CarInput)
local CarPlacer = require(pcar.CarPlacer)
local CarTracker = require(pcar.CarTracker)
local ClientCarState = require(pcar.ClientCarState)

-- Create Toggle UI Button
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CarToggleGui"
ScreenGui.Parent = CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -100, 0, 0)
ToggleButton.Text = "Enable Car Script"
ToggleButton.Parent = ScreenGui

local isScriptEnabled = false -- Variable to track script state
local isAutoRaceEnabled = false -- Variable to track auto race state
local currentCheckpointIndex = 1 -- Index to track which checkpoint the car is aiming for
local raceTrack = { -- A table containing the list of checkpoints (Vector3 positions)
    Vector3.new(0, 0, 0),           -- Start point
    Vector3.new(50, 0, 100),        -- First checkpoint
    Vector3.new(100, 0, 200),       -- Second checkpoint
    Vector3.new(200, 0, 300),       -- Third checkpoint
    Vector3.new(300, 0, 400),       -- Finish line
}

-- Function to handle enabling/disabling the script
local function toggleScript()
    isScriptEnabled = not isScriptEnabled
    if isScriptEnabled then
        ToggleButton.Text = "Disable Car Script"
    else
        ToggleButton.Text = "Enable Car Script"
    end
end

ToggleButton.MouseButton1Click:Connect(toggleScript)

-- Function to start Auto Race
local function startAutoRace()
    isAutoRaceEnabled = true
    print("Auto Race Started!")
end

-- Function to stop Auto Race
local function stopAutoRace()
    isAutoRaceEnabled = false
    print("Auto Race Stopped!")
end

-- Check if driving before running the main logic
local function executeScript()
    if not ClientCarState.isDriving then
        local Hint = Instance.new("Hint")
        Hint.Name = HttpService:GenerateGUID(true)
        Hint.Text = "Please, Spawn/Enter Your Car (Before Executing)!"
        Hint.Parent = CoreGui
        Debris:AddItem(Hint, 5)
        return
    end

    local ResetVelocity = function(Model)
        for _, Value in pairs(Model:GetDescendants()) do
            if Value:IsA("BasePart") then
                Value.Velocity = Vector3.new()
                Value.RotVelocity = Vector3.new()
            end
        end
    end

    hookfunction(CarInput.GetNitro, function()
        return true
    end)

    local _, Size = CarTracker.getCarFromDriver(LocalPlayer):GetBoundingBox()

    local Part = Instance.new("Part")
    Part.Name = HttpService:GenerateGUID(true)
    Part.CFrame = CFrame.new(0, -50, 0)
    Part.Anchored = true
    Part.Size = Vector3.new(Size.X, 1, 2048)
    Part.Parent = workspace

    ResetVelocity(CarTracker.getCarFromDriver(LocalPlayer))
    CarPlacer.place(nil, CarTracker.getCarFromDriver(LocalPlayer), Part.CFrame + Vector3.new(0, Part.Size.Y / 2 + Size.Y / 2, Part.Size.Z / 2 - Size.Z / 2))
    
    RunService.RenderStepped:Connect(function()
        local car = CarTracker.getCarFromDriver(LocalPlayer)
        local carPosition = car.PrimaryPart.Position

        -- If Auto Race is enabled
        if isAutoRaceEnabled then
            -- Get the next checkpoint the car should head to
            local checkpoint = raceTrack[currentCheckpointIndex]
            
            -- Move the car towards the checkpoint
            local direction = (checkpoint - carPosition).unit
            car:SetPrimaryPartCFrame(car.PrimaryPart.CFrame + direction * 10)

            -- Check if the car reached the checkpoint
            if (carPosition - checkpoint).Magnitude < 10 then
                print("Checkpoint " .. currentCheckpointIndex .. " reached!")
                currentCheckpointIndex = currentCheckpointIndex + 1

                -- Check if we've reached the final checkpoint (finish line)
                if currentCheckpointIndex > #raceTrack then
                    print("You won the race!")
                    stopAutoRace() -- Stop the race when finished
                end
            end
        end
    end)

    print("Script Executed!")
end

-- Toggle the script on or off
RunService.RenderStepped:Connect(function()
    if isScriptEnabled then
        executeScript()
    end
end)

-- Example of starting/stopping the auto race
local startRaceButton = Instance.new("TextButton")
startRaceButton.Size = UDim2.new(0, 200, 0, 50)
startRaceButton.Position = UDim2.new(0.5, -100, 0, 60)
startRaceButton.Text = "Start Auto Race"
startRaceButton.Parent = ScreenGui

startRaceButton.MouseButton1Click:Connect(startAutoRace)
