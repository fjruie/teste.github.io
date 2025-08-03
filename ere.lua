local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PET_API_URL = "https://er--eeeiqjjj50.repl.co/recent-pets" -- Make sure this is reachable by Roblox!

-- Remove previous UI if it exists
if game.CoreGui:FindFirstChild("BrainrotJoiner") then
    game.CoreGui.BrainrotJoiner:Destroy()
end

-- Main UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotJoiner"
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 350)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "BRAINROT Joiner"
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = mainFrame

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 120, 0, 32)
refreshBtn.Position = UDim2.new(1, -130, 0, 8)
refreshBtn.Text = "Refresh"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 20
refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 180)
refreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
refreshBtn.Parent = mainFrame

local petListFrame = Instance.new("Frame")
petListFrame.Position = UDim2.new(0, 10, 0, 50)
petListFrame.Size = UDim2.new(1, -20, 1, -100)
petListFrame.BackgroundTransparency = 1
petListFrame.Parent = mainFrame

local uilist = Instance.new("UIListLayout")
uilist.Parent = petListFrame
uilist.SortOrder = Enum.SortOrder.LayoutOrder
uilist.Padding = UDim.new(0, 6)

local joinBtn = Instance.new("TextButton")
joinBtn.Size = UDim2.new(1, -40, 0, 40)
joinBtn.Position = UDim2.new(0, 20, 1, -50)
joinBtn.AnchorPoint = Vector2.new(0, 1)
joinBtn.Text = "Join Server"
joinBtn.Font = Enum.Font.GothamBold
joinBtn.TextSize = 22
joinBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
joinBtn.TextColor3 = Color3.fromRGB(255,255,255)
joinBtn.Parent = mainFrame
joinBtn.Active = false
joinBtn.AutoButtonColor = false

-- State
local petData = {}
local selectedPet = nil

function clearPetButtons()
    for _, child in ipairs(petListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
end

function updatePetList()
    clearPetButtons()
    if #petData == 0 then
        local none = Instance.new("TextLabel")
        none.Size = UDim2.new(1, 0, 0, 34)
        none.BackgroundTransparency = 1
        none.Text = "No pets found."
        none.TextColor3 = Color3.fromRGB(200,80,80)
        none.Font = Enum.Font.Gotham
        none.TextSize = 22
        none.Parent = petListFrame
    else
        for i, pet in ipairs(petData) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Text = pet.name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 22
            btn.Parent = petListFrame
            btn.MouseButton1Click:Connect(function()
                selectedPet = i
                for _, other in ipairs(petListFrame:GetChildren()) do
                    if other:IsA("TextButton") then
                        other.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
                joinBtn.Active = true
                joinBtn.AutoButtonColor = true
                joinBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
            end)
        end
    end
end

function fetchPets()
    local ok, data = pcall(function()
        local response = game:HttpGet(PET_API_URL)
        --print("RESPONSE:", response)
        return HttpService:JSONDecode(response)
    end)
    petData = {}
    selectedPet = nil
    joinBtn.Active = false
    joinBtn.AutoButtonColor = false
    joinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    if ok and type(data) == "table" then
        for _, pet in ipairs(data) do
            local jobId = tostring(pet.jobId):gsub("```lua", ""):gsub("```", ""):gsub("\n", ""):gsub("^%s*(.-)%s*$", "%1")
            if tonumber(pet.placeId) and jobId ~= "" and pet.name and pet.name ~= "" then
                table.insert(petData, {
                    name = pet.name,
                    placeId = pet.placeId,
                    jobId = jobId
                })
            end
        end
    end
    updatePetList()
end

refreshBtn.MouseButton1Click:Connect(fetchPets)

joinBtn.MouseButton1Click:Connect(function()
    if selectedPet and petData[selectedPet] then
        local p = petData[selectedPet]
        TeleportService:TeleportToPlaceInstance(tonumber(p.placeId), p.jobId)
    end
end)

-- Auto refresh every 15s
task.spawn(function()
    while screenGui.Parent do
        fetchPets()
        task.wait(15)
    end
end)

fetchPets()
