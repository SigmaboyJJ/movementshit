        -- Movement settings
local STRAFE_SPEED = 30
local AIR_MULTIPLIER = 1.5
local BHOP_POWER = 40

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Local player setup
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variables
local moveKeys = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false
}

-- Functions to handle character access safely
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
    local char = getChar()
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getChar()
    return char:FindFirstChild("Humanoid")
end

-- Movement function
local function calculateMoveDirection()
    local dir = Vector3.new(0, 0, 0)
    local char = getChar()
    if not char then return dir end
    
    local cf = workspace.CurrentCamera.CFrame
    
    if moveKeys.W then
        dir = dir + cf.LookVector
    end
    if moveKeys.S then
        dir = dir - cf.LookVector
    end
    if moveKeys.A then
        dir = dir - cf.RightVector
    end
    if moveKeys.D then
        dir = dir + cf.RightVector
    end
    
    dir = Vector3.new(dir.X, 0, dir.Z).Unit
    return dir
end

-- Key handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        moveKeys.W = true
    elseif input.KeyCode == Enum.KeyCode.A then
        moveKeys.A = true
    elseif input.KeyCode == Enum.KeyCode.S then
        moveKeys.S = true
    elseif input.KeyCode == Enum.KeyCode.D then
        moveKeys.D = true
    elseif input.KeyCode == Enum.KeyCode.Space then
        moveKeys.Space = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.W then
        moveKeys.W = false
    elseif input.KeyCode == Enum.KeyCode.A then
        moveKeys.A = false
    elseif input.KeyCode == Enum.KeyCode.S then
        moveKeys.S = false
    elseif input.KeyCode == Enum.KeyCode.D then
        moveKeys.D = false
    elseif input.KeyCode == Enum.KeyCode.Space then
        moveKeys.Space = false
    end
end)

-- Main movement loop
RunService.Heartbeat:Connect(function()
    local char = getChar()
    local root = getRoot()
    local humanoid = getHumanoid()
    
    if not char or not root or not humanoid then return end
    
    -- Calculate movement
    local moveDir = calculateMoveDirection()
    local isInAir = humanoid:GetState() == Enum.HumanoidStateType.Jumping or 
                    humanoid:GetState() == Enum.HumanoidStateType.Freefall
    
    -- Apply movement
    if moveDir.Magnitude > 0 then
        local speed = STRAFE_SPEED
        if isInAir then
            speed = speed * AIR_MULTIPLIER
        end
        
        -- Set velocity
        local newVel = moveDir * speed
        root.Velocity = Vector3.new(
            newVel.X,
            root.Velocity.Y,  -- Preserve vertical velocity
            newVel.Z
        )
        
        -- Bunny hop
        if moveKeys.Space and root.Velocity.Y < 1 then
            root.Velocity = Vector3.new(
                root.Velocity.X,
                BHOP_POWER,
                root.Velocity.Z
            )
        end
    end
end)
