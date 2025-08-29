local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Folder = "Ringta Scripts",
    Title = "RINGTA",
    Icon = "star",
    Author = "discord.gg/ringta",
    Theme = "Dark",
    Size = UDim2.fromOffset(500, 350),
    Transparent = false,
    HasOutline = true,
})

Window:EditOpenButton({
    Title = "Open RINGTA SCRIPTS",
    Icon = "pointer",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(200, 0, 255), Color3.fromRGB(0, 200, 255)),
    Draggable = true,
})

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "star" }),
    Hide = Window:Tab({ Title = "Combat", Icon = "eye-off" }),
    Jump = Window:Tab({ Title = "Auto Farm", Icon = "shopping-basket" }),
    Random = Window:Tab({ Title = "Random Features", Icon = "dices" }),
    Brainrot = Window:Tab({ Title = "Auto Pickup?", Icon = "brain" }), 
}




local itemList = {
    "Bloodfruit", "Gold", "Raw Gold", "Crystal Chunk", "Essence", "Emerald", "Raw Emerald", "Pink Diamond", "Raw Pink Diamond", "Void Shard", "Jelly"
}

local selectedItems = {}
Tabs.Main:Dropdown({
    Title = "Select items to pickup",
    Values = itemList,
    Value = { "Essence" },
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        selectedItems = {}
        for _, item in ipairs(selected) do
            selectedItems[item] = true
        end
    end
})

local autoPickup = false
Tabs.Main:Toggle({
    Title = "Auto Pickup",
    Default = false,
    Callback = function(t)
        autoPickup = t
    end
})

local pickupRange = 20
Tabs.Main:Slider({
    Title = "Pickup Range",
    Value = {Min = 1, Max = 35, Default = 20},
    Step = 1,
    Callback = function(val)
        pickupRange = tonumber(val)
    end
})

local packets = require(ReplicatedStorage.Modules.Packets)
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

task.spawn(function()
    while true do
        if autoPickup then
            for _, item in ipairs(workspace.Items:GetChildren()) do
                if (item:IsA("BasePart") or item:IsA("MeshPart")) and selectedItems[item.Name] then
                    local entityid = item:GetAttribute("EntityID")
                    if entityid and (item.Position - root.Position).Magnitude <= (pickupRange or 20) then
                        if packets.Pickup and packets.Pickup.send then
                            packets.Pickup.send(entityid)
                        end
                    end
                end
            end
        end
        task.wait(0.01)
    end
end)




local killAuraEnabled = false
local killAuraRange = 5
local killAuraTargets = 1
local killAuraCooldown = 0.1

Tabs.Hide:Toggle({
    Title = "Kill Aura",
    Default = false,
    Callback = function(val)
        killAuraEnabled = val
    end
})

Tabs.Hide:Slider({
    Title = "Kill Aura Range",
    Value = {Min = 1, Max = 9, Default = 5},
    Step = 1,
    Callback = function(val)
        killAuraRange = tonumber(val)
    end
})

Tabs.Hide:Dropdown({
    Title = "Max Targets",
    Values = {"1", "2", "3", "4", "5", "6"},
    Value = "1",
    Multi = false,
    Callback = function(val)
        killAuraTargets = tonumber(type(val) == "table" and val[1] or val)
    end
})

Tabs.Hide:Slider({
    Title = "Attack Cooldown (s)",
    Value = {Min = 0.01, Max = 1.01, Default = 0.1},
    Step = 0.01,
    Callback = function(val)
        killAuraCooldown = tonumber(val)
    end
})

local packets = require(ReplicatedStorage.Modules.Packets)
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local function swingtool(targets)
    if packets.SwingTool and packets.SwingTool.send then
        packets.SwingTool.send(targets)
    end
end

task.spawn(function()
    while true do
        if killAuraEnabled then
            local targets = {}
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local playerfolder = workspace.Players:FindFirstChild(player.Name)
                    if playerfolder then
                        local rootpart = playerfolder:FindFirstChild("HumanoidRootPart")
                        local entityid = playerfolder:GetAttribute("EntityID")
                        if rootpart and entityid then
                            local dist = (rootpart.Position - root.Position).Magnitude
                            if dist <= (killAuraRange or 5) then
                                table.insert(targets, { eid = entityid, dist = dist })
                            end
                        end
                    end
                end
            end
            if #targets > 0 then
                table.sort(targets, function(a, b)
                    return a.dist < b.dist
                end)
                local selectedTargets = {}
                for i = 1, math.min(killAuraTargets, #targets) do
                    table.insert(selectedTargets, targets[i].eid)
                end
                swingtool(selectedTargets)
            end
            task.wait(killAuraCooldown or 0.1)
        else
            task.wait(0.1)
        end
    end
end)











local resourceAuraEnabled = false
local resourceAuraRange = 20
local resourceAuraTargets = 1
local resourceAuraCooldown = 0.1

Tabs.Jump:Toggle({
    Title = "Auto Hit Ores Like Resources",
    Default = false,
    Callback = function(val)
        resourceAuraEnabled = val
    end
})

Tabs.Jump:Slider({
    Title = "Resource Aura Range",
    Value = {Min = 1, Max = 20, Default = 20},
    Step = 1,
    Callback = function(val)
        resourceAuraRange = tonumber(val)
    end
})

Tabs.Jump:Dropdown({
    Title = "Max Resource Targets",
    Values = {"1", "2", "3", "4", "5", "6"},
    Value = "1",
    Multi = false,
    Callback = function(val)
        resourceAuraTargets = tonumber(type(val) == "table" and val[1] or val)
    end
})

Tabs.Jump:Slider({
    Title = "Resource Swing Cooldown (s)",
    Value = {Min = 0.01, Max = 1.01, Default = 0.1},
    Step = 0.01,
    Callback = function(val)
        resourceAuraCooldown = tonumber(val)
    end
})

local packets = require(ReplicatedStorage.Modules.Packets)
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local function swingtool(targets)
    if packets.SwingTool and packets.SwingTool.send then
        packets.SwingTool.send(targets)
    end
end

task.spawn(function()
    while true do
        if resourceAuraEnabled then
            local range = resourceAuraRange or 20
            local targetCount = resourceAuraTargets or 1
            local cooldown = resourceAuraCooldown or 0.1
            local targets = {}
            local allresources = {}
            for _, r in pairs(workspace.Resources:GetChildren()) do
                table.insert(allresources, r)
            end
            for _, r in pairs(workspace:GetChildren()) do
                if r:IsA("Model") and r.Name == "Gold Node" then
                    table.insert(allresources, r)
                end
            end
            for _, res in pairs(allresources) do
                if res:IsA("Model") and res:GetAttribute("EntityID") then
                    local eid = res:GetAttribute("EntityID")
                    local ppart = res.PrimaryPart or res:FindFirstChildWhichIsA("BasePart")
                    if ppart then
                        local dist = (ppart.Position - root.Position).Magnitude
                        if dist <= range then
                            table.insert(targets, { eid = eid, dist = dist })
                        end
                    end
                end
            end
            if #targets > 0 then
                table.sort(targets, function(a, b)
                    return a.dist < b.dist
                end)
                local selectedTargets = {}
                for i = 1, math.min(targetCount, #targets) do
                    table.insert(selectedTargets, targets[i].eid)
                end
                swingtool(selectedTargets)
            end
            task.wait(cooldown)
        else
            task.wait(0.1)
        end
    end
end)




local mobAuraEnabled = false
local mobAuraRange = 20
local mobAuraTargets = 1
local mobAuraCooldown = 0.1

Tabs.Jump:Toggle({
    Title = "Mob Aura",
    Default = false,
    Callback = function(val)
        mobAuraEnabled = val
    end
})

Tabs.Jump:Slider({
    Title = "Mob Aura Range",
    Value = {Min = 1, Max = 20, Default = 20},
    Step = 1,
    Callback = function(val)
        mobAuraRange = tonumber(val)
    end
})

Tabs.Jump:Dropdown({
    Title = "Max Mob Targets",
    Values = {"1", "2", "3", "4", "5", "6"},
    Value = "1",
    Multi = false,
    Callback = function(val)
        mobAuraTargets = tonumber(type(val) == "table" and val[1] or val)
    end
})

Tabs.Jump:Slider({
    Title = "Mob Swing Cooldown (s)",
    Value = {Min = 0.01, Max = 1.01, Default = 0.1},
    Step = 0.01,
    Callback = function(val)
        mobAuraCooldown = tonumber(val)
    end
})

local packets = require(ReplicatedStorage.Modules.Packets)
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local function swingtool(targets)
    if packets.SwingTool and packets.SwingTool.send then
        packets.SwingTool.send(targets)
    end
end

task.spawn(function()
    while true do
        if mobAuraEnabled then
            local range = mobAuraRange or 20
            local targetCount = mobAuraTargets or 1
            local cooldown = mobAuraCooldown or 0.1
            local targets = {}
            for _, mob in pairs(workspace.Critters:GetChildren()) do
                if mob:IsA("Model") and mob:GetAttribute("EntityID") then
                    local eid = mob:GetAttribute("EntityID")
                    local ppart = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
                    if ppart then
                        local dist = (ppart.Position - root.Position).Magnitude
                        if dist <= range then
                            table.insert(targets, { eid = eid, dist = dist })
                        end
                    end
                end
            end
            if #targets > 0 then
                table.sort(targets, function(a, b)
                    return a.dist < b.dist
                end)
                local selectedTargets = {}
                for i = 1, math.min(targetCount, #targets) do
                    table.insert(selectedTargets, targets[i].eid)
                end
                swingtool(selectedTargets)
            end
            task.wait(cooldown)
        else
            task.wait(0.1)
        end
    end
end)







local fruitList = { "Bloodfruit", "Bluefruit", "Jelly" }
local fruitdropdownid = { Bloodfruit = 94, Bluefruit = 377, Jelly = 604 }

local autoPlantEnabled = false
local autoHarvestEnabled = false
local plantRange = 30
local plantDelay = 0.1
local harvestRange = 30
local selectedFruit = "Bloodfruit"

Tabs.Random:Dropdown({
    Title = "Select Fruit",
    Values = fruitList,
    Value = "Bloodfruit",
    Multi = false,
    Callback = function(val)
        selectedFruit = type(val) == "table" and val[1] or val
    end
})

Tabs.Random:Toggle({
    Title = "Auto Plant",
    Default = false,
    Callback = function(val)
        autoPlantEnabled = val
    end
})

Tabs.Random:Slider({
    Title = "Plant Range",
    Value = {Min = 1, Max = 30, Default = 30},
    Step = 1,
    Callback = function(val)
        plantRange = tonumber(val)
    end
})

Tabs.Random:Slider({
    Title = "Plant Delay (s)",
    Value = {Min = 0.01, Max = 1, Default = 0.1},
    Step = 0.01,
    Callback = function(val)
        plantDelay = tonumber(val)
    end
})

Tabs.Random:Toggle({
    Title = "Auto Harvest",
    Default = false,
    Callback = function(val)
        autoHarvestEnabled = val
    end
})

Tabs.Random:Slider({
    Title = "Harvest Range",
    Value = {Min = 1, Max = 30, Default = 30},
    Step = 1,
    Callback = function(val)
        harvestRange = tonumber(val)
    end
})

local packets = require(ReplicatedStorage.Modules.Packets)
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local function plant(entityid, itemID)
    if packets.InteractStructure and packets.InteractStructure.send then
        packets.InteractStructure.send({ entityID = entityid, itemID = itemID })
    end
end

local function getPlantBoxes(range)
    local plantboxes = {}
    for _, deployable in ipairs(workspace.Deployables:GetChildren()) do
        if deployable:IsA("Model") and deployable.Name == "Plant Box" then
            local entityid = deployable:GetAttribute("EntityID")
            local ppart = deployable.PrimaryPart or deployable:FindFirstChildWhichIsA("BasePart")
            if entityid and ppart then
                local dist = (ppart.Position - root.Position).Magnitude
                if dist <= range then
                    table.insert(plantboxes, { entityid = entityid, deployable = deployable, dist = dist })
                end
            end
        end
    end
    return plantboxes
end

local function getBushes(range, fruitname)
    local bushes = {}
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:find(fruitname) then
            local ppart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if ppart then
                local dist = (ppart.Position - root.Position).Magnitude
                if dist <= range then
                    local entityid = model:GetAttribute("EntityID")
                    if entityid then
                        table.insert(bushes, { entityid = entityid, model = model, dist = dist })
                    end
                end
            end
        end
    end
    return bushes
end

local function pickup(entityid)
    if packets.Pickup and packets.Pickup.send then
        packets.Pickup.send(entityid)
    end
end

task.spawn(function()
    while true do
        if autoPlantEnabled then
            local itemID = fruitdropdownid[selectedFruit] or 94
            local plantboxes = getPlantBoxes(plantRange)
            table.sort(plantboxes, function(a, b) return a.dist < b.dist end)
            for _, box in ipairs(plantboxes) do
                if not box.deployable:FindFirstChild("Seed") then
                    plant(box.entityid, itemID)
                end
            end
            task.wait(plantDelay)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if autoHarvestEnabled then
            local bushes = getBushes(harvestRange, selectedFruit)
            table.sort(bushes, function(a, b) return a.dist < b.dist end)
            for _, bush in ipairs(bushes) do
                pickup(bush.entityid)
            end
            task.wait(0.1)
        else
            task.wait(0.1)
        end
    end
end)















local tweenPlantBoxEnabled = false
local tweenRange = 250

Tabs.Brainrot:Toggle({
    Title = "Tween to Plant Box",
    Default = false,
    Callback = function(val)
        tweenPlantBoxEnabled = val
    end
})

Tabs.Brainrot:Slider({
    Title = "Tween Range",
    Value = {Min = 1, Max = 250, Default = 250},
    Step = 1,
    Callback = function(val)
        tweenRange = tonumber(val)
    end
})

local TweenService = game:GetService("TweenService")
local tweening = nil

local function tweenToTarget(targetCFrame)
    if tweening then tweening:Cancel() end
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = distance / 21
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tw = TweenService:Create(root, tweenInfo, { CFrame = targetCFrame })
    tw:Play()
    tweening = tw
    tw.Completed:Wait()
end

local function getPlantBoxes(range)
    local plantboxes = {}
    for _, deployable in ipairs(workspace.Deployables:GetChildren()) do
        if deployable:IsA("Model") and deployable.Name == "Plant Box" then
            local entityid = deployable:GetAttribute("EntityID")
            local ppart = deployable.PrimaryPart or deployable:FindFirstChildWhichIsA("BasePart")
            if entityid and ppart then
                local dist = (ppart.Position - root.Position).Magnitude
                if dist <= range then
                    table.insert(plantboxes, { entityid = entityid, deployable = deployable, dist = dist })
                end
            end
        end
    end
    return plantboxes
end

task.spawn(function()
    while true do
        if not tweenPlantBoxEnabled then
            task.wait(0.1)
        else
            local range = tweenRange or 250
            local plantboxes = getPlantBoxes(range)
            table.sort(plantboxes, function(a, b) return a.dist < b.dist end)
            local foundEmpty = false
            for _, box in ipairs(plantboxes) do
                if not box.deployable:FindFirstChild("Seed") then
                    local targetCFrame = box.deployable.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                    tweenToTarget(targetCFrame)
                    task.wait(0.2)
                    foundEmpty = true
                end
            end
            if not foundEmpty then
                for _, box in ipairs(plantboxes) do
                    local targetCFrame = box.deployable.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                    tweenToTarget(targetCFrame)
                    task.wait(0.2)
                end
            end
            task.wait(0.1)
        end
    end
end)
