--[[
    Theus Hub for Blox Fruits
    Created by: TheusHub Team
    Library: Orion Library
]]

-- Variables
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Check if the game is Blox Fruits
if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then
    OrionLib:MakeNotification({
        Name = "Theus Hub",
        Content = "This script is only for Blox Fruits!",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
    return
end

-- Configuration
local Config = {
    AutoFarm = false,
    AutoBone = false,
    AutoRaceV4 = false,
    KillAura = false,
    AutoSkills = false,
    ESP = {
        Players = false,
        NPCs = false,
        Chests = false,
        Fruits = false
    },
    AutoRaid = false,
    SelectedMob = "Bandit",
    FarmDistance = 5,
    TweenSpeed = 100,
    WhiteScreen = false
}

-- Save/Load Configuration
local SettingsFileName = "TheusHub_Settings.json"

local function SaveSettings()
    local HttpService = game:GetService("HttpService")
    local json = HttpService:JSONEncode(Config)
    writefile(SettingsFileName, json)
end

local function LoadSettings()
    local HttpService = game:GetService("HttpService")
    if isfile(SettingsFileName) then
        Config = HttpService:JSONDecode(readfile(SettingsFileName))
    end
end

-- Try to load settings
pcall(LoadSettings)

-- Create Main Window
local Window = OrionLib:MakeWindow({
    Name = "Theus Hub | Blox Fruits",
    HidePremium = true,
    SaveConfig = false,
    ConfigFolder = "TheusHub"
})

-- Tabs
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AutoFarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local RaidsTab = Window:MakeTab({
    Name = "Raids",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local RaceV4Tab = Window:MakeTab({
    Name = "Race V4",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Utility Functions
local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function Tween(obj, dest, speed)
    local dist = GetDistance(obj.Position, dest)
    local time = dist / speed
    
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(dest)}
    )
    tween:Play()
    return tween
end

local function GetClosestMob(mobName)
    local closestMob = nil
    local shortestDistance = math.huge
    
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and string.find(v.Name, mobName) then
            local magnitude = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if magnitude < shortestDistance then
                closestMob = v
                shortestDistance = magnitude
            end
        end
    end
    
    return closestMob
end

local function GetAllMobs()
    local mobs = {}
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if not table.find(mobs, v.Name) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            table.insert(mobs, v.Name)
        end
    end
    return mobs
end

local function Attack()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
end

-- ESP Functions
local ESPEnabled = false
local ESPObjects = {}

local function ClearESP()
    for _, v in pairs(ESPObjects) do
        if v then
            v:Remove()
        end
    end
    ESPObjects = {}
end

local function CreateESP(object, text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 100, 0, 150)
    billboard.StudsOffset = Vector3.new(0, 1, 0)
    billboard.AlwaysOnTop = true
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(0, 100, 0, 100)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = billboard
    
    billboard.Parent = game:GetService("CoreGui")
    table.insert(ESPObjects, billboard)
    return billboard
end

local function UpdateESP()
    if not Config.ESP.Players and not Config.ESP.NPCs and not Config.ESP.Chests and not Config.ESP.Fruits then
        ESPEnabled = false
        ClearESP()
        return
    end
    
    ESPEnabled = true
    ClearESP()
    
    -- Player ESP
    if Config.ESP.Players then
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = GetDistance(HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position)
                CreateESP(
                    player.Character.HumanoidRootPart, 
                    player.Name .. "\n[" .. math.floor(distance) .. " studs]",
                    Color3.new(1, 0, 0)
                )
            end
        end
    end
    
    -- NPC ESP
    if Config.ESP.NPCs then
        for _, npc in pairs(Workspace.Enemies:GetChildren()) do
            if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                local distance = GetDistance(HumanoidRootPart.Position, npc.HumanoidRootPart.Position)
                CreateESP(
                    npc.HumanoidRootPart, 
                    npc.Name .. "\n[" .. math.floor(distance) .. " studs]",
                    Color3.new(1, 1, 0)
                )
            end
        end
    end
    
    -- Chest ESP
    if Config.ESP.Chests then
        for _, chest in pairs(Workspace:GetChildren()) do
            if string.find(chest.Name, "Chest") and chest:FindFirstChild("TouchInterest") then
                local distance = GetDistance(HumanoidRootPart.Position, chest.Position)
                CreateESP(
                    chest, 
                    chest.Name .. "\n[" .. math.floor(distance) .. " studs]",
                    Color3.new(0, 1, 0)
                )
            end
        end
    end
    
    -- Fruit ESP
    if Config.ESP.Fruits then
        for _, fruit in pairs(Workspace:GetChildren()) do
            if string.find(fruit.Name, "Fruit") and fruit:FindFirstChild("Handle") then
                local distance = GetDistance(HumanoidRootPart.Position, fruit.Handle.Position)
                CreateESP(
                    fruit.Handle, 
                    fruit.Name .. "\n[" .. math.floor(distance) .. " studs]",
                    Color3.new(0, 1, 1)
                )
            end
        end
    end
end

-- Auto Farm Function
local AutoFarmRunning = false

local function AutoFarm()
    if AutoFarmRunning then return end
    AutoFarmRunning = true
    
    spawn(function()
        while Config.AutoFarm do
            pcall(function()
                local target = GetClosestMob(Config.SelectedMob)
                
                if target then
                    -- Tween to target
                    local targetPosition = target.HumanoidRootPart.Position
                    local tweenPosition = targetPosition + Vector3.new(0, Config.FarmDistance, 0)
                    local tween = Tween(HumanoidRootPart, tweenPosition, Config.TweenSpeed)
                    
                    tween.Completed:Wait()
                    
                    -- Attack while in range
                    while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and Config.AutoFarm do
                        HumanoidRootPart.CFrame = CFrame.new(
                            target.HumanoidRootPart.Position + Vector3.new(0, Config.FarmDistance, 0),
                            target.HumanoidRootPart.Position
                        )
                        
                        -- Auto attack
                        Attack()
                        
                        -- Use skills if enabled
                        if Config.AutoSkills then
                            local skills = {"Z", "X", "C", "V", "F"}
                            for _, skill in pairs(skills) do
                                VirtualUser:CaptureController()
                                VirtualUser:SetKeyDown(skill)
                                wait(0.1)
                                VirtualUser:SetKeyUp(skill)
                            end
                        end
                        
                        wait(0.1)
                        
                        -- Check if target still exists
                        if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
                            break
                        end
                    end
                else
                    -- If no target found, wait and try again
                    wait(1)
                end
            end)
            wait()
        end
        
        AutoFarmRunning = false
    end)
end

-- Auto Bone Function
local AutoBoneRunning = false

local function AutoBone()
    if AutoBoneRunning then return end
    AutoBoneRunning = true
    
    spawn(function()
        while Config.AutoBone do
            pcall(function()
                -- Look for mobs that drop bones (typically higher level skeletons)
                local target = GetClosestMob("Skeleton") or GetClosestMob("Reborn Skeleton") or GetClosestMob("Living Skeleton") or GetClosestMob("Demonic Soul")
                
                if target then
                    -- Tween to target
                    local targetPosition = target.HumanoidRootPart.Position
                    local tweenPosition = targetPosition + Vector3.new(0, Config.FarmDistance, 0)
                    local tween = Tween(HumanoidRootPart, tweenPosition, Config.TweenSpeed)
                    
                    tween.Completed:Wait()
                    
                    -- Attack while in range
                    while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and Config.AutoBone do
                        HumanoidRootPart.CFrame = CFrame.new(
                            target.HumanoidRootPart.Position + Vector3.new(0, Config.FarmDistance, 0),
                            target.HumanoidRootPart.Position
                        )
                        
                        -- Auto attack
                        Attack()
                        
                        -- Use skills if enabled
                        if Config.AutoSkills then
                            local skills = {"Z", "X", "C", "V", "F"}
                            for _, skill in pairs(skills) do
                                VirtualUser:CaptureController()
                                VirtualUser:SetKeyDown(skill)
                                wait(0.1)
                                VirtualUser:SetKeyUp(skill)
                            end
                        end
                        
                        wait(0.1)
                        
                        -- Check if target still exists
                        if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
                            break
                        end
                    end
                    
                    -- Collect drops (bones)
                    for _, v in pairs(Workspace.Map:GetDescendants()) do
                        if v.Name == "TouchInterest" and v.Parent.Name:find("Bone") then
                            firetouchinterest(HumanoidRootPart, v.Parent, 0)
                            wait(0.1)
                            firetouchinterest(HumanoidRootPart, v.Parent, 1)
                        end
                    end
                else
                    -- If no target found, wait and try again
                    wait(1)
                end
            end)
            wait()
        end
        
        AutoBoneRunning = false
    end)
end

-- Kill Aura Function
local KillAuraRunning = false

local function KillAura()
    if KillAuraRunning then return end
    KillAuraRunning = true
    
    spawn(function()
        while Config.KillAura do
            pcall(function()
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        local magnitude = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                        
                        if magnitude <= 50 then  -- Kill aura range
                            -- Apply damage to nearby enemies (simplified simulation)
                            local args = {
                                [1] = v.HumanoidRootPart.Position,
                                [2] = v.HumanoidRootPart
                            }
                            
                            for i = 1, 5 do  -- Hit multiple times
                                local ohString1 = "MousePos"
                                local ohVector22 = Vector2.new(0, 0)
                                game:GetService("Players").LocalPlayer.Character.Combat.Update:FireServer(ohString1, ohVector22)
                            end
                        end
                    end
                end
            end)
            wait(0.5)  -- Adjust timing as needed
        end
        
        KillAuraRunning = false
    end)
end

-- Auto Race V4 Function
local AutoRaceV4Running = false

local function AutoRaceV4()
    if AutoRaceV4Running then return end
    AutoRaceV4Running = true
    
    local races = {
        "Human",
        "Skypiea",
        "Fishman",
        "Mink"
    }
    
    local currentRace = ""
    for _, race in pairs(races) do
        if LocalPlayer.Data.Race.Value == race then
            currentRace = race
            break
        end
    end
    
    if currentRace == "" then
        OrionLib:MakeNotification({
            Name = "Theus Hub",
            Content = "Could not determine your current race!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
        AutoRaceV4Running = false
        Config.AutoRaceV4 = false
        return
    end
    
    OrionLib:MakeNotification({
        Name = "Theus Hub",
        Content = "Starting Auto Race V4 for " .. currentRace .. " race.",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
    
    spawn(function()
        while Config.AutoRaceV4 do
            pcall(function()
                if currentRace == "Human" then
                    -- Human V4 race quest
                    -- Teleport to Temple of Time
                    
                    -- Simplified implementation - in a real script this would involve more steps
                    -- like checking quest progress, teleporting to NPCs, etc.
                    
                    -- Example: Teleport to Temple of Time
                    local templePosition = Vector3.new(-28023, 14889, -175)
                    Tween(HumanoidRootPart, templePosition, Config.TweenSpeed).Completed:Wait()
                    
                elseif currentRace == "Skypiea" then
                    -- Skypiea V4 race quest
                    local towerPosition = Vector3.new(-7895, 5547, -380)
                    Tween(HumanoidRootPart, towerPosition, Config.TweenSpeed).Completed:Wait()
                    
                elseif currentRace == "Fishman" then
                    -- Fishman V4 race quest
                    local underwaterPosition = Vector3.new(3643, 10, -7055)
                    Tween(HumanoidRootPart, underwaterPosition, Config.TweenSpeed).Completed:Wait()
                    
                elseif currentRace == "Mink" then
                    -- Mink V4 race quest
                    local zunishaPosition = Vector3.new(-379, 73, 300)
                    Tween(HumanoidRootPart, zunishaPosition, Config.TweenSpeed).Completed:Wait()
                end
                
                -- This is simplified. In a real script, there would be more steps
                -- like activating dialogues, completing trials, etc.
                
                wait(5)  -- Reduced wait time for demonstration
            end)
            wait(1)
        end
        
        AutoRaceV4Running = false
    end)
end

-- Auto Raid Function
local AutoRaidRunning = false

local function AutoRaid()
    if AutoRaidRunning then return end
    AutoRaidRunning = true
    
    spawn(function()
        while Config.AutoRaid do
            pcall(function()
                -- Find raid island or NPCs
                local raidTarget = nil
                
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and string.find(v.Name, "Raid") then
                        raidTarget = v
                        break
                    end
                end
                
                if raidTarget then
                    -- Tween to target
                    local targetPosition = raidTarget.HumanoidRootPart.Position
                    local tweenPosition = targetPosition + Vector3.new(0, Config.FarmDistance, 0)
                    local tween = Tween(HumanoidRootPart, tweenPosition, Config.TweenSpeed)
                    
                    tween.Completed:Wait()
                    
                    -- Attack raid boss
                    while raidTarget and raidTarget:FindFirstChild("Humanoid") and raidTarget.Humanoid.Health > 0 and Config.AutoRaid do
                        HumanoidRootPart.CFrame = CFrame.new(
                            raidTarget.HumanoidRootPart.Position + Vector3.new(0, Config.FarmDistance, 0),
                            raidTarget.HumanoidRootPart.Position
                        )
                        
                        -- Auto attack
                        Attack()
                        
                        -- Use skills if enabled
                        if Config.AutoSkills then
                            local skills = {"Z", "X", "C", "V", "F"}
                            for _, skill in pairs(skills) do
                                VirtualUser:CaptureController()
                                VirtualUser:SetKeyDown(skill)
                                wait(0.1)
                                VirtualUser:SetKeyUp(skill)
                            end
                        end
                        
                        wait(0.1)
                        
                        -- Check if target still exists
                        if not raidTarget or not raidTarget:FindFirstChild("Humanoid") or raidTarget.Humanoid.Health <= 0 then
                            break
                        end
                    end
                else
                    -- Try to start a raid if no target found
                    local raidNPCPositions = {
                        Vector3.new(-6438, 250, -4500),  -- Example position for Raid NPC
                        Vector3.new(-5560, 313, -2838)   -- Alternative position
                    }
                    
                    for _, pos in pairs(raidNPCPositions) do
                        Tween(HumanoidRootPart, pos, Config.TweenSpeed).Completed:Wait()
                        wait(1)
                        
                        -- Try to interact with NPCs
                        for _, npc in pairs(Workspace.NPCs:GetChildren()) do
                            if npc:FindFirstChild("HumanoidRootPart") and (npc.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude < 10 then
                                -- Simulate dialogue interaction
                                local clickDetector = npc:FindFirstChild("ClickDetector")
                                if clickDetector then
                                    fireclickdetector(clickDetector)
                                    wait(0.5)
                                end
                            end
                        end
                    end
                    
                    wait(5)  -- Wait before trying again
                end
            end)
            wait(1)
        end
        
        AutoRaidRunning = false
    end)
end

-- Main Tab
MainTab:AddLabel("Welcome to Theus Hub")

MainTab:AddParagraph("Information", "This script is designed for Blox Fruits. Use at your own risk.")

MainTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end    
})

MainTab:AddButton({
    Name = "Server Hop",
    Callback = function()
        local servers = {}
        local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        
        for _, server in pairs(req.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            OrionLib:MakeNotification({
                Name = "Theus Hub",
                Content = "No available servers found!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end    
})

MainTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        Humanoid.WalkSpeed = Value
    end    
})

MainTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        Humanoid.JumpPower = Value
    end    
})

-- Auto Farm Tab
AutoFarmTab:AddToggle({
    Name = "Auto Farm",
    Default = Config.AutoFarm,
    Callback = function(Value)
        Config.AutoFarm = Value
        if Config.AutoFarm then
            AutoFarm()
        end
        SaveSettings()
    end    
})

local mobDropdown = AutoFarmTab:AddDropdown({
    Name = "Select Mob",
    Default = Config.SelectedMob,
    Options = GetAllMobs(),
    Callback = function(Value)
        Config.SelectedMob = Value
        SaveSettings()
    end    
})

AutoFarmTab:AddButton({
    Name = "Refresh Mob List",
    Callback = function()
        mobDropdown:Refresh(GetAllMobs(), true)
    end    
})

AutoFarmTab:AddSlider({
    Name = "Farm Distance",
    Min = 0,
    Max = 20,
    Default = Config.FarmDistance,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Distance",
    Callback = function(Value)
        Config.FarmDistance = Value
        SaveSettings()
    end    
})

AutoFarmTab:AddSlider({
    Name = "Tween Speed",
    Min = 50,
    Max = 500,
    Default = Config.TweenSpeed,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 10,
    ValueName = "Speed",
    Callback = function(Value)
        Config.TweenSpeed = Value
        SaveSettings()
    end    
})

AutoFarmTab:AddToggle({
    Name = "Auto Skills",
    Default = Config.AutoSkills,
    Callback = function(Value)
        Config.AutoSkills = Value
        SaveSettings()
    end    
})

AutoFarmTab:AddToggle({
    Name = "Kill Aura",
    Default = Config.KillAura,
    Callback = function(Value)
        Config.KillAura = Value
        if Config.KillAura then
            KillAura()
        end
        SaveSettings()
    end    
})

AutoFarmTab:AddToggle({
    Name = "Auto Bone Farm",
    Default = Config.AutoBone,
    Callback = function(Value)
        Config.AutoBone = Value
        if Config.AutoBone then
            AutoBone()
        end
        SaveSettings()
    end    
})

-- Teleport Tab
local islands = {
    ["Starter Island"] = Vector3.new(1071.2832, 16.3085976, 1426.86792),
    ["Marine Island"] = Vector3.new(-2573.3374, 6.88881969, 2046.99817),
    ["Middle Town"] = Vector3.new(-655.824158, 7.88708115, 1436.67908),
    ["Jungle Island"] = Vector3.new(-1249.77222, 11.8870859, 341.356476),
    ["Pirate Village"] = Vector3.new(-1122.16553, 4.78708982, 3855.91992),
    ["Desert Island"] = Vector3.new(1094.14587, 6.5, 4192.88721),
    ["Frozen Village"] = Vector3.new(1198.00928, 27.0074959, -1211.73376),
    ["MarineFord"] = Vector3.new(-4505.375, 20.687294, 4260.55908),
    ["Colosseum"] = Vector3.new(-1428.35474, 7.38933945, -3014.37305),
    ["Sky Island 1"] = Vector3.new(-4970.21875, 717.707275, -2622.35449),
    ["Sky Island 2"] = Vector3.new(-4813.0249, 903.708557, -1912.69922),
    ["Sky Island 3"] = Vector3.new(-7952.31006, 5545.52832, -320.704956),
    ["Prison Island"] = Vector3.new(4854.16455, 5.68742752, 740.194641),
    ["Magma Village"] = Vector3.new(-5231.75879, 8.61593437, 8467.87695),
    ["Underwater City"] = Vector3.new(61163.8516, 11.7796879, 1819.78418),
    ["Fountain City"] = Vector3.new(5132.7124, 4.53632832, 4037.8562),
    ["House of Darryl"] = Vector3.new(-9508.5, 142, 5565),
    ["Kingdom of Rose"] = Vector3.new(-9570.033203125, 142.11549377441, 5539.9609375),
    ["Café"] = Vector3.new(-384.01473999023, 73.020111083984, 255.61363220215),
    ["Flamingo Mansion"] = Vector3.new(-483.73370361328, 332.0383605957, 595.6248779297),
    ["Green Zone"] = Vector3.new(-2448.5300292969, 73.016105651855, -3210.6218261719),
    ["Graveyard Island"] = Vector3.new(-5411.47607, 48.8234024, -721.274963),
    ["Temple of Time"] = Vector3.new(28286.35, 14896.4951, 102.624695)
}

TeleportTab:AddDropdown({
    Name = "Select Island",
    Default = "Starter Island",
    Options = (function()
        local islandNames = {}
        for name, _ in pairs(islands) do
            table.insert(islandNames, name)
        end
        return islandNames
    end)(),
    Callback = function(Value)
        local selectedPosition = islands[Value]
        if selectedPosition then
            Tween(HumanoidRootPart, selectedPosition, Config.TweenSpeed)
        end
    end    
})

TeleportTab:AddToggle({
    Name = "Safe Mode",
    Default = false,
    Callback = function(Value)
        -- Safe mode teleport (avoiding detection)
    end    
})

TeleportTab:AddButton({
    Name = "Cancel Teleport",
    Callback = function()
        -- Cancel any ongoing tweens
        for _, tween in pairs(TweenService:GetTweens()) do
            tween:Cancel()
        end
    end    
})

-- Raids Tab
RaidsTab:AddToggle({
    Name = "Auto Raid",
    Default = Config.AutoRaid,
    Callback = function(Value)
        Config.AutoRaid = Value
        if Config.AutoRaid then
            AutoRaid()
        end
        SaveSettings()
    end    
})

RaidsTab:AddDropdown({
    Name = "Select Raid",
    Default = "Phoenix",
    Options = {"Phoenix", "Rumble", "String", "Dark", "Light", "Ice", "Magma", "Quake", "Buddha", "Flame", "Sand"},
    Callback = function(Value)
        -- Select which raid to focus on
    end    
})

RaidsTab:AddButton({
    Name = "Teleport to Raid Island",
    Callback = function()
        -- Teleport to the raid island
        local raidIslandPosition = Vector3.new(-6438, 250, -4500)
        Tween(HumanoidRootPart, raidIslandPosition, Config.TweenSpeed)
    end    
})

RaidsTab:AddToggle({
    Name = "Auto Buy Raid Chips",
    Default = false,
    Callback = function(Value)
        -- Auto buy raid chips logic
    end    
})

-- Race V4 Tab
RaceV4Tab:AddToggle({
    Name = "Auto Race V4",
    Default = Config.AutoRaceV4,
    Callback = function(Value)
        Config.AutoRaceV4 = Value
        if Config.AutoRaceV4 then
            AutoRaceV4()
        end
        SaveSettings()
    end    
})

RaceV4Tab:AddParagraph("Current Race", "Your current race: " .. (LocalPlayer.Data.Race and LocalPlayer.Data.Race.Value or "Unknown"))

RaceV4Tab:AddButton({
    Name = "Teleport to Temple of Time",
    Callback = function()
        local templePosition = Vector3.new(28286.35, 14896.4951, 102.624695)
        Tween(HumanoidRootPart, templePosition, Config.TweenSpeed)
    end    
})

RaceV4Tab:AddButton({
    Name = "Teleport to Ancient One",
    Callback = function()
        local ancientOnePosition = Vector3.new(28973.0879, 14889.9756, -120.298691)
        Tween(HumanoidRootPart, ancientOnePosition, Config.TweenSpeed)
    end    
})

local v4Trials = {
    ["Human Trial"] = Vector3.new(29237.2461, 14889.9756, -206.94957),
    ["Skypiea Trial"] = Vector3.new(28967.408, 14918.0781, 232.403564),
    ["Fishman Trial"] = Vector3.new(28224.2148, 14889.9756, 157.622437),
    ["Mink Trial"] = Vector3.new(29018.3887, 14889.9756, -379.718353)
}

RaceV4Tab:AddDropdown({
    Name = "Teleport to Trial",
    Default = "Human Trial",
    Options = (function()
        local trialNames = {}
        for name, _ in pairs(v4Trials) do
            table.insert(trialNames, name)
        end
        return trialNames
    end)(),
    Callback = function(Value)
        local selectedPosition = v4Trials[Value]
        if selectedPosition then
            Tween(HumanoidRootPart, selectedPosition, Config.TweenSpeed)
        end
    end    
})

-- ESP Tab
ESPTab:AddToggle({
    Name = "Players ESP",
    Default = Config.ESP.Players,
    Callback = function(Value)
        Config.ESP.Players = Value
        UpdateESP()
        SaveSettings()
    end    
})

ESPTab:AddToggle({
    Name = "NPCs ESP",
    Default = Config.ESP.NPCs,
    Callback = function(Value)
        Config.ESP.NPCs = Value
        UpdateESP()
        SaveSettings()
    end    
})

ESPTab:AddToggle({
    Name = "Chests ESP",
    Default = Config.ESP.Chests,
    Callback = function(Value)
        Config.ESP.Chests = Value
        UpdateESP()
        SaveSettings()
    end    
})

ESPTab:AddToggle({
    Name = "Fruits ESP",
    Default = Config.ESP.Fruits,
    Callback = function(Value)
        Config.ESP.Fruits = Value
        UpdateESP()
        SaveSettings()
    end    
})

ESPTab:AddButton({
    Name = "Refresh ESP",
    Callback = function()
        UpdateESP()
    end    
})

-- Misc Tab
MiscTab:AddToggle({
    Name = "White Screen",
    Default = Config.WhiteScreen,
    Callback = function(Value)
        Config.WhiteScreen = Value
        
        if Config.WhiteScreen then
            -- Enable white screen for performance
            local whiteScreen = Instance.new("Frame")
            whiteScreen.Size = UDim2.new(1, 0, 1, 0)
            whiteScreen.BackgroundColor3 = Color3.new(1, 1, 1)
            whiteScreen.BorderSizePixel = 0
            whiteScreen.ZIndex = 10
            whiteScreen.Name = "WhiteScreen"
            whiteScreen.Parent = game:GetService("CoreGui")
        else
            -- Disable white screen
            local whiteScreen = game:GetService("CoreGui"):FindFirstChild("WhiteScreen")
            if whiteScreen then
                whiteScreen:Destroy()
            end
        end
        
        SaveSettings()
    end    
})

MiscTab:AddToggle({
    Name = "Remove Fog",
    Default = false,
    Callback = function(Value)
        if Value then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = 2000
        end
    end    
})

MiscTab:AddButton({
    Name = "Infinite Jump",
    Callback = function()
        local InfiniteJumpEnabled = true
        
        UserInputService.JumpRequest:Connect(function()
            if InfiniteJumpEnabled then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
        
        OrionLib:MakeNotification({
            Name = "Theus Hub",
            Content = "Infinite Jump Enabled!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

MiscTab:AddButton({
    Name = "Remove Lava Damage",
    Callback = function()
        for i, v in pairs(game:GetService("Workspace"):GetDescendants()) do
            if v.Name == "Lava" then
                v:Destroy()
            end
        end
        
        OrionLib:MakeNotification({
            Name = "Theus Hub",
            Content = "Lava damage removed!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

-- Settings Tab
SettingsTab:AddButton({
    Name = "Save Settings",
    Callback = function()
        SaveSettings()
        
        OrionLib:MakeNotification({
            Name = "Theus Hub",
            Content = "Settings saved!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

SettingsTab:AddButton({
    Name = "Load Settings",
    Callback = function()
        LoadSettings()
        
        -- Update UI elements to match loaded settings
        OrionLib:MakeNotification({
            Name = "Theus Hub",
            Content = "Settings loaded!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

SettingsTab:AddButton({
    Name = "Reset Settings",
    Callback = function()
        -- Reset to defaults
        Config = {
            AutoFarm = false,
            AutoBone = false,
            AutoRaceV4 = false,
            KillAura = false,
            AutoSkills = false,
            ESP = {
                Players = false,
                NPCs = false,
                Chests = false,
                Fruits = false
            },
            AutoRaid = false,
            SelectedMob = "Bandit",
            FarmDistance = 5,
            TweenSpeed = 100,
            WhiteScreen = false
        }
        
        SaveSettings()
        
        OrionLib:MakeNotification({
            Name = "Theus Hub",
            Content = "Settings reset to default!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

-- Initialize
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Reset speeds according to settings
    Humanoid.WalkSpeed = 16
    Humanoid.JumpPower = 50
end)

-- ESP Update Loop
spawn(function()
    while wait(1) do
        if ESPEnabled then
            UpdateESP()
        end
    end
end)

-- Notification on load
OrionLib:MakeNotification({
    Name = "Theus Hub",
    Content = "Loaded successfully! Enjoy.",
    Image = "rbxassetid://4483345998",
    Time = 5
})

OrionLib:Init()
