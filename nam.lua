local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local isAutoWinEnabled = false

-- Tự động tham gia race
local function autoJoinRace()
    local raceJoinPoint = Workspace:FindFirstChild("RaceJoinPoint") -- Điểm tham gia race
    if raceJoinPoint and character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = raceJoinPoint.CFrame + Vector3.new(0, 5, 0)
        print("Joined the Race!")
        wait(2) -- Chờ một chút để đảm bảo tham gia race
    else
        warn("Race Join Point not found!")
    end
end

-- Tìm checkpoint gần nhất
local function getClosestCheckpoint()
    local checkpoints = Workspace:FindFirstChild("Checkpoints") -- Thư mục chứa checkpoint
    if not checkpoints then return nil end

    local closestCheckpoint = nil
    local closestDistance = math.huge

    for _, checkpoint in ipairs(checkpoints:GetChildren()) do
        if checkpoint:IsA("Part") then
            local distance = (character.HumanoidRootPart.Position - checkpoint.Position).Magnitude
            if distance < closestDistance then
                closestCheckpoint = checkpoint
                closestDistance = distance
            end
        end
    end

    return closestCheckpoint
end

-- Teleport qua checkpoint
local function teleportToCheckpoint(checkpoint)
    if checkpoint and character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = checkpoint.CFrame + Vector3.new(0, 5, 0)
        wait(0.5)
    end
end

-- Auto Win logic
local function autoWin()
    while true do
        local closestCheckpoint = getClosestCheckpoint()
        if closestCheckpoint then
            teleportToCheckpoint(closestCheckpoint)
        else
            -- Nếu không còn checkpoint, di chuyển đến đích
            local finishLine = Workspace:FindFirstChild("FinishLine")
            if finishLine then
                teleportToCheckpoint(finishLine)
                print("You Win!")
                break
            end
        end
        RunService.Heartbeat:Wait()
    end
end

-- Bắt đầu Auto Join Race và Auto Win
local function startAutoRaceAndWin()
    autoJoinRace()
    autoWin()
end

-- Kích hoạt
startAutoRaceAndWin()
print("Script Executed!")
