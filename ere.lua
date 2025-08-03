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
    Hide = Window:Tab({ Title = "Visual", Icon = "eye-off" }),
    Jump = Window:Tab({ Title = "Shop", Icon = "shopping-basket" }),
    Random = Window:Tab({ Title = "Random Features", Icon = "dices" }),
    Credit = Window:Tab({ Title = "Credit", Icon = "medal" }),
    Brainrot = Window:Tab({ Title = "BRAINROT Joiner", Icon = "brain" }), -- <-- add this line
}





Tabs.Brainrot = Window:Tab({ Title = "BRAINROT Joiner", Icon = "brain" })

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PET_API_URL = "https://eeeiqjjj50--er.repl.co/recent-pets"

local petDataList = {}
local selectedPetIndex = nil

local dropdownObj = Tabs.Brainrot:Dropdown({
    Title = "Secret Pet Servers",
    Values = { "Loading..." },
    Multi = false,
    AllowNone = false,
    Callback = function(selected)
        if not selected or not selected[1] then selectedPetIndex = nil return end
        for i, pet in ipairs(petDataList) do
            if pet.name == selected[1] then
                selectedPetIndex = i
                break
            end
        end
    end
})

Tabs.Brainrot:Button({
    Title = "Join server",
    Callback = function()
        if selectedPetIndex and petDataList[selectedPetIndex] then
            local pet = petDataList[selectedPetIndex]
            if pet.placeId and pet.jobId and pet.jobId ~= "" then
                TeleportService:TeleportToPlaceInstance(tonumber(pet.placeId), pet.jobId)
            end
        end
    end
})

local function refreshDropdown()
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(PET_API_URL))
    end)
    petDataList = {}
    local dropdownValues = {}
    if ok and type(data) == "table" and #data > 0 then
        for _, pet in ipairs(data) do
            -- CLEAN JOBID!
            local jobId = tostring(pet.jobId):gsub("```lua", ""):gsub("```", ""):gsub("\n", ""):gsub("^%s*(.-)%s*$", "%1")
            local name = tostring(pet.name or "?")
            table.insert(dropdownValues, name)
            table.insert(petDataList, {
                name = name,
                placeId = pet.placeId,
                jobId = jobId
            })
        end
        -- Default to first pet selected
        selectedPetIndex = #petDataList > 0 and 1 or nil
    else
        dropdownValues = { "No pets found." }
        selectedPetIndex = nil
    end
    dropdownObj:Refresh(dropdownValues)
end

Tabs.Brainrot:Button({
    Title = "Refresh Pet List",
    Callback = refreshDropdown
})

-- Optional: auto-refresh every 15 seconds
task.spawn(function()
    while true do
        refreshDropdown()
        task.wait(15)
    end
end)

refreshDropdown()
