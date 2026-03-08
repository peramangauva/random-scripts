local id = 'peramangauva_CustomCharacter'
do -- cleanup
    local cleanupTable = getgenv().cleanupTable
    if not cleanupTable then
        local t = {}
        getgenv().cleanupTable = t
        cleanupTable = t
    end
    for _, cleanup in pairs(cleanupTable) do
        if cleanup.id == id then
            cleanup.func()
        end
    end
end


-- imports
-- nothing


-- services
local PLRS = game:GetService('Players')
local RS = game:GetService('RunService')


-- paths
local ME = PLRS.LocalPlayer


-- other variables
local Limb
local DefaultR6C0
local DefaultR6C1


-- flags
-- nothing


-- utility functions
local WeldModel
local CreateMotor


-- main functions
local SetCharacter


-- events
-- nothing


-- cleanup variables
local Connect do
    Connect = setmetatable({Raw = {}},{
        __call = function(self, Event, Connection)
            table.insert(self.Raw, Event:Connect(Connection))
        end
    })
end


do -- setup
    Limb = {}
    Limb.__index = Limb

    -- Standard R6 joint configuration so default animations (walk, jump, slash) work properly
    DefaultR6C0 = {
        ["RootJoint"] = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
        ["Neck"] = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
        ["Right Shoulder"] = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
        ["Left Shoulder"] = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
        ["Right Hip"] = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
        ["Left Hip"] = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    }
    DefaultR6C1 = {
        ["RootJoint"] = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
        ["Neck"] = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
        ["Right Shoulder"] = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),["Left Shoulder"] = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
        ["Right Hip"] = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
        ["Left Hip"] = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    }
end


do -- imports
    -- nothing
end


do -- utility functions
    function WeldModel(mainPart, model)
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") and part ~= mainPart then
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = mainPart
                weld.Part1 = part
                weld.Parent = mainPart
                
                part.Anchored = false
                part.CanCollide = false
                part.Massless = true
            end
        end
        mainPart.Anchored = false
    end

    function CreateMotor(name, part0, part1, c0, c1)
        local motor = Instance.new("Motor6D")
        motor.Name = name
        motor.Part0 = part0
        motor.Part1 = part1
        motor.C0 = c0 or CFrame.new()
        motor.C1 = c1 or CFrame.new()
        motor.Parent = part0
        return motor
    end
end


do -- main functions
    function Limb.new(instance)
        local self = setmetatable({}, Limb)
        if typeof(instance) == "Instance" then
            if instance:IsA("Model") then
                self.MainPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
                self.Model = instance
            elseif instance:IsA("BasePart") then
                self.MainPart = instance
                self.Model = instance
            end
        end
        return self
    end

    function SetCharacter(limbs)
        local oldChar = ME.Character
        if not oldChar then return end
        
        local oldHrp = oldChar:FindFirstChild("HumanoidRootPart")
        local oldPos = oldHrp and oldHrp.CFrame or CFrame.new(0, 10, 0)
        
        -- Hide the original character safely away from the map
        if oldHrp then
            oldChar:PivotTo(CFrame.new(0, 9e9, 0))
            for _, v in ipairs(oldChar:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Anchored = true
                end
            end
        end
        
        -- Create the new dummy character
        local newChar = Instance.new("Model")
        newChar.Name = ME.Name .. "_CustomRig"
        
        local hrp = Instance.new("Part")
        hrp.Name = "HumanoidRootPart"
        hrp.Size = Vector3.new(2, 2, 1)
        hrp.Transparency = 1
        hrp.CanCollide = false
        hrp.Parent = newChar
        newChar.PrimaryPart = hrp
        
        local humanoid = Instance.new("Humanoid")
        humanoid.Parent = newChar
        humanoid.RigType = Enum.HumanoidRigType.R6

        local animator = Instance.new("Animator")
        animator.Parent = humanoid
        
        local riggedParts = {}
        
        -- Assign Limbs (expects keys like "Torso", "Head", "Right Arm", etc.)
        for limbName, limbObj in pairs(limbs) do
            local part = limbObj.MainPart
            local model = limbObj.Model
            
            if part then
                part.Name = limbName
                model.Parent = newChar
                
                if model:IsA("Model") then
                    WeldModel(part, model)
                else
                    part.Anchored = false
                end
                
                riggedParts[limbName] = part
            end
        end
        
        -- Generate the Motor6D Rig structure
        if riggedParts["Torso"] then
            CreateMotor("RootJoint", hrp, riggedParts["Torso"], DefaultR6C0["RootJoint"], DefaultR6C1["RootJoint"])
            
            if riggedParts["Head"] then
                CreateMotor("Neck", riggedParts["Torso"], riggedParts["Head"], DefaultR6C0["Neck"], DefaultR6C1["Neck"])
            end
            if riggedParts["Right Arm"] then
                CreateMotor("Right Shoulder", riggedParts["Torso"], riggedParts["Right Arm"], DefaultR6C0["Right Shoulder"], DefaultR6C1["Right Shoulder"])
            end
            if riggedParts["Left Arm"] then
                CreateMotor("Left Shoulder", riggedParts["Torso"], riggedParts["Left Arm"], DefaultR6C0["Left Shoulder"], DefaultR6C1["Left Shoulder"])
            end
            if riggedParts["Right Leg"] then
                CreateMotor("Right Hip", riggedParts["Torso"], riggedParts["Right Leg"], DefaultR6C0["Right Hip"], DefaultR6C1["Right Hip"])
            end
            if riggedParts["Left Leg"] then
                CreateMotor("Left Hip", riggedParts["Torso"], riggedParts["Left Leg"], DefaultR6C0["Left Hip"], DefaultR6C1["Left Hip"])
            end
        end
        
        -- Steal the original Animate script so it walks/slashes normally
        local oldAnimate = oldChar:FindFirstChild("Animate")
        if oldAnimate then
            local newAnimate = oldAnimate:Clone()
            newAnimate.Parent = newChar
        end
        
        -- Spawn it at the old location and attach it to the player
        newChar:PivotTo(oldPos)
        newChar.Parent = workspace
        ME.Character = newChar -- Doing this automatically passes total NetworkOwnership of the limbs to the Client
        
        return newChar
    end
end


do -- connections
    -- nothing
end


do -- events
    -- nothing
end


do -- after-setup
    -- nothing
end


do -- cleanup
    for idx, cleanup in pairs(getgenv().cleanupTable) do
        if cleanup.id == id then
            table.remove(cleanup, idx)
            break
        end
    end
    table.insert(getgenv().cleanupTable, {
        id = id,
        func = function()
            for _, Connection in ipairs(Connect.Raw) do
                Connection:Disconnect()
            end
        end
    })
end

return {
    Limb = Limb,
    SetCharacter = SetCharacter
}
