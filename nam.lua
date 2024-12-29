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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CarToggleGui"
ScreenGui.Parent = CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -100, 0, 0)
ToggleButton.Text = "Enable Car Script"
ToggleButton.Parent = ScreenGui

local isScriptEnabled = false
local isAutoRaceEnabled = false
local currentCheckpointIndex = 1
local raceTrack = {
    Vector3.new(0, 0, 0),
    Vector3.new(50, 0, 100),
    Vector3.new(100, 0, 200),
    Vector3.new(200, 0, 300),
    Vector3.new(300, 0, 400),
}

local function toggleScript()
    isScriptEnabled = not isScriptEnabled
    if isScriptEnabled then
        ToggleButton.Text = "Disable Car Script"
    else
        ToggleButton.Text = "Enable Car Script"
    end
end

ToggleButton.MouseButton1Click:Connect(toggleScript)

local function startAutoRace()
    isAutoRaceEnabled = true
    print("Auto Race Started!")
end

local function stopAutoRace()
    isAutoRaceEnabled = false
    print("Auto Race Stopped!")
end

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

        if isAutoRaceEnabled then
            local checkpoint = raceTrack[currentCheckpointIndex]
            local direction = (checkpoint - carPosition).unit
            car:SetPrimaryPartCFrame(car.PrimaryPart.CFrame + direction * 10)

            if (carPosition - checkpoint).Magnitude < 10 then
                print("Checkpoint " .. currentCheckpointIndex .. " reached!")
                currentCheckpointIndex = currentCheckpointIndex + 1

                if currentCheckpointIndex > #raceTrack then
                    print("You won the race!")
                    stopAutoRace()
                end
            end
        end
    end)

    print("Script Executed!")
end

RunService.RenderStepped:Connect(function()
    if isScriptEnabled then
        executeScript()
    end
end)

local startRaceButton = Instance.new("TextButton")
startRaceButton.Size = UDim2.new(0, 200, 0, 50)
startRaceButton.Position = UDim2.new(0.5, -100, 0, 60)
startRaceButton.Text = "Start Auto Race"
startRaceButton.Parent = ScreenGui

startRaceButton.MouseButton1Click:Connect(startAutoRace)

local Debounce = false
local RBXScriptSignal = nil

RunService.RenderStepped:Connect(function(...)
    if CarTracker.getCarFromDriver(LocalPlayer) then
        if not Debounce then
            Debounce = true
            table.foreachi(getconnections(RunService.Stepped), function(_, Value, ...)
                if Value.Function and getfenv(Value.Function).script.Name == "CarClient" then
                    RBXScriptSignal = RunService.RenderStepped:Connect(function(...)
                        debug.setupvalue(Value.Function, 21, 3)
                    end)
                    return
                else
                    return
                end
            end)
        end
    else
        if Debounce then
            Debounce = false
            RBXScriptSignal:Disconnect()
        end
    end
end)
