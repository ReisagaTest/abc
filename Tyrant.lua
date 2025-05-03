local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Config = {
    Team = "Pirates",
    Tool = "Melee",
    BossName = "Tyrant",
    AutoBoss = true
}

local Rportal = {}
if game.PlaceId == 2753915549 then
    Rportal = {
        Sky2 = Vector3.new(-4607.82275390625, 872.5774536132812, -1667.556884765625),
        Sky3 = Vector3.new(-7894.61767578125, 5545.52783203125, -380.29119873046875),
        UnderWater1 = Vector3.new(61163.8515625, 5.342312812805176, 1819.7841796875),
        UnderWater2 = Vector3.new(3864.6884765625, 17.408157825469971, -1926.214111328125)
    }
elseif game.PlaceId == 4442272183 then
    Rportal = {
        Mansion = Vector3.new(-286.98907470703125, 306.1656799316406, 597.8519287109375),
        SwanRoom = Vector3.new(2284.912109375, 15.18704605102539, 905.5137329101562),
        CurrentShip1 = Vector3.new(923.2125244140625, 125.09213256835938, 32852.83203125),
        CurrentShip2 = Vector3.new(-6508.55810546875, 83.2220458984375, -132.83953857421875)
    }
elseif game.PlaceId == 7449423635 then
    Rportal = {
        Mansion = Vector3.new(-12463.6064453125, 374.94952392578125, -7549.5341796875),
        CastleOnTheSea = Vector3.new(-5073.84912109375, 314.5505676269531, -3152.5322265625),
        HydraIsland = Vector3.new(5661.52734375, 1013.0795288085938, -334.9577331542969),
        TempleOfTime = Vector3.new(28286.35546875, 14896.544921875, 102.62469482421875)
    }
end

local Nah = Instance.new("Part", Workspace)
Nah.Name = "Nah"
Nah.Anchored = true
Nah.CanCollide = false
Nah.Transparency = 1
Nah.CanTouch = false
Nah.CFrame = Players.LocalPlayer.Character.PrimaryPart.CFrame

local function EnableBuso()
    if not Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

local function GetWeapon(toolType)
    local name = ""
    for _, v in pairs(Players.LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == toolType then
            name = v.Name
        end
    end
    for _, v in pairs(Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == toolType then
            name = v.Name
        end
    end
    return name
end

local function EquipTool(toolName)
    if Players.LocalPlayer.Backpack:FindFirstChild(toolName) then
        local humanoid = Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:EquipTool(Players.LocalPlayer.Backpack[toolName])
        end
    end
end

local function EquipWeapon()
    local toolType = Config.Tool or "Melee"
    local weapon = GetWeapon(toolType)
    if weapon then
        EquipTool(weapon)
    end
end

local function GetNearestPortal(targetPos)
    local minDistance = math.huge
    local nearestPortal = Vector3.new(0, 0, 0)
    for _, portalPos in pairs(Rportal) do
        local distance = (portalPos - targetPos).Magnitude
        if distance < minDistance then
            minDistance = distance
            nearestPortal = portalPos
        end
    end
    return nearestPortal
end

local function CheckInventory(item)
    for _, v in pairs(ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")) do
        if v.Name == item then
            return true
        end
    end
    return false
end

local function RequestEntrance(pos)
    ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", pos)
    task.wait(0.3)
end

local function IsAlive(mob)
    return mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and 
           mob:FindFirstChild("HumanoidRootPart") and not mob:FindFirstChild("VehicleSeat") and
           mob.Name ~= "PirateBrigade" and not string.find(mob.Name:lower(), "boat") and
           mob.Name ~= "FishBoat"
end

local function GetMob(enemy, checkReplicated)
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if (type(enemy) == "table" and table.find(enemy, v.Name) or v.Name == enemy) and IsAlive(v) then
            return v
        end
    end
    if checkReplicated then
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if (type(enemy) == "table" and table.find(enemy, v.Name) or v.Name == enemy) and IsAlive(v) then
                return v
            end
        end
    end
    return nil
end

local function ToTarget(target)
    local targetCFrame = typeof(target) == "Vector3" and CFrame.new(target) or target
    local distance = (targetCFrame.Position - Nah.Position).Magnitude
    local portal = GetNearestPortal(targetCFrame.Position)
    
    sethiddenproperty(Players.LocalPlayer, "SimulationRadius", math.huge)
    
    if distance <= 15 then
        Nah.CFrame = targetCFrame
        NoClip = true
        return
    end
    
    local hasValkyrie = CheckInventory("Valkyrie Helm")
    local isThirdSea = game.PlaceId == 7449423635
    if (hasValkyrie or not isThirdSea) and portal and 
       (targetCFrame.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 
       (portal - targetCFrame.Position).Magnitude + 250 then
        RequestEntrance(portal)
    else
        local speed = distance <= 450 and 325 / 1.8 or 325
        local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(Nah, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        NoClip = true
    end
end

task.spawn(function()
    while task.wait() do
        if NoClip then
            for _, v in pairs(Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            if Nah.Position.Magnitude - Players.LocalPlayer.Character.PrimaryPart.Position.Magnitude < 200 then
                Players.LocalPlayer.Character.PrimaryPart.CFrame = Nah.CFrame
            else
                Nah.CFrame = Players.LocalPlayer.Character.PrimaryPart.CFrame
            end
            
            local head = Players.LocalPlayer.Character:FindFirstChild("Head")
            if head and not head:FindFirstChild("Ngu") then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Name = "Ngu"
                bodyVelocity.P = 1500
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Parent = head
            end
        else
            local ngu = Players.LocalPlayer.Character and 
                      Players.LocalPlayer.Character:FindFirstChild("Head") and 
                      Players.LocalPlayer.Character.Head:FindFirstChild("Ngu")
            if ngu then
                ngu:Destroy()
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if Config.AutoBoss then
            pcall(function()
                local bossName = Config.BossName == "Tyrant" and "Tyrant Of The Skies"
                local mob = GetMob(bossName, true)
                
                if mob and IsAlive(mob) then
                    EnableBuso()
                    EquipWeapon()
                    ToTarget(mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
                else
                    local storedMob = ReplicatedStorage:FindFirstChild(bossName)
                    if storedMob then
                        ToTarget(storedMob.HumanoidRootPart.CFrame * CFrame.new(5, 10, 7))
                    elseif bossName == "Tyrant Of The Skies" then
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Reisaga/hop-api/refs/heads/main/TyrantHop.lua"))()
                    end
                end
            end)
        end
    end
end)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

local function createVxezeHub()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == "VxezeHubUI" then
            v:Destroy()
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = CoreGui
    ScreenGui.Name = "VxezeHubUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 0.3
    Frame.ZIndex = 10

    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.Size = UDim2.new(1, 0, 0.2, 0)
    Title.Position = UDim2.new(0, 0, 0.26, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Shinichii Hub"
    Title.TextColor3 = Color3.fromRGB(225, 222, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.FredokaOne
    Title.ZIndex = 11

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = Frame
    Subtitle.Size = UDim2.new(1, 0, 0.05, 0)
    Subtitle.Position = UDim2.new(0, 0, 0.45, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Boss Hopper"
    Subtitle.TextColor3 = Color3.fromRGB(127, 128, 123)
    Subtitle.TextScaled = true
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.ZIndex = 10

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = ScreenGui
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0.95, -25, 0.1, -25)
    ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleButton.Text = "X"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.ZIndex = 15

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ToggleButton

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = ToggleButton

    local isOpen = true
    ToggleButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        ToggleButton.Text = isOpen and "X" or "◉"
        TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = isOpen and UDim2.new(0, 0, 0, 0) or UDim2.new(-1, 0, 0, 0)
        }):Play()
    end)

    local isDragging, dragInput, dragStart, startPos
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = ToggleButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    ToggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            local delta = input.Position - dragStart
            TweenService:Create(ToggleButton, TweenInfo.new(0.1), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)

    return ScreenGui
end

local vxezeHubUI = createVxezeHub()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Home and not gameProcessed then
        vxezeHubUI:Destroy()
        vxezeHubUI = createVxezeHub()
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if p == player then
        vxezeHubUI:Destroy()
    end
end)