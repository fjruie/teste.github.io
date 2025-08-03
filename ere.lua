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




local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PET_API_URL = "https://eeeiqjjj50--er.repl.co/recent-pets"

local petDataList = {}

local dropdownObj = Tabs.Brainrot:Dropdown({
    Title = "Secret Pet Servers (Select to Join)",
    Values = { "Loading..." },
    Multi = false,
    AllowNone = true,
    Callback = function(selected)
        if not selected or not selected[1] then return end
        for i, entry in ipairs(petDataList) do
            if entry.label == selected[1] then
                if entry.placeId and entry.jobId and entry.jobId ~= "" then
                    TeleportService:TeleportToPlaceInstance(tonumber(entry.placeId), entry.jobId)
                end
                break
            end
        end
    end
})

local function refreshDropdown()
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(PET_API_URL))
    end)
    local dropdownValues = {}
    petDataList = {}
    if ok and type(data) == "table" and #data > 0 then
        for _, pet in ipairs(data) do
            local jobId = tostring(pet.jobId):gsub("```lua", ""):gsub("```", ""):gsub("\n", ""):gsub("^%s*(.-)%s*$", "%1")
            local label = (pet.name or "?")
            if pet.mutation and pet.mutation ~= "" then
                label = label .. " ["..pet.mutation.."]"
            end
            label = label .. " | " .. (pet.dps or "?") .. " | " .. (jobId or "?")
            table.insert(dropdownValues, label)
            table.insert(petDataList, {
                label = label,
                placeId = pet.placeId,
                jobId = jobId
            })
        end
    else
        dropdownValues = { "No pets found." }
        petDataList = {}
    end
    dropdownObj:Refresh(dropdownValues)
end

Tabs.Brainrot:Button({
    Title = "Refresh Pet List",
    Callback = refreshDropdown
})

-- Optional: auto-refresh
task.spawn(function()
    while true do
        refreshDropdown()
        task.wait(15)
    end
end)

refreshDropdown()
