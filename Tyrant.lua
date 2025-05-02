getgenv().AutoBoss = true

local Config = {
    ["Team"] = "Pirates",
    ["Tool"] = "Melee", -- Melee / Sword
    ["BossName"] = "Tyrant"
}

GetMob = function(Enemy, method)
    for r, v in pairs(game.Workspace.Enemies:GetChildren()) do
        if ((typeof(Enemy) == "table" and table.find(Enemy,v.Name)) or (typeof(Enemy) == "string" and v.Name == Enemy)) and IsAlive(v) then
            return v
        end
    end
    if method ~= nil and method == true then
        for r, v in pairs(game.ReplicatedStorage:GetChildren()) do
            if ((typeof(Enemy) == "table" and table.find(Enemy,v.Name)) or (typeof(Enemy) == "string" and v.Name == Enemy)) and IsAlive(v) then
                return v
            end
        end
    end
    return false
end
function EBuso()
    if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HasBuso") then
        local args = {
            [1] = "Buso"
        }
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
    end
end
function Getweapon(lon)
    local names = ""
    for r, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == lon then
            names = v.Name
        end
    end
    for r, v in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == lon then
            names = v.Name
        end
    end
    return names
end
Equiptool = function(aa)
    pcall(function()
        if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild(aa) then
            local Weapon = game:GetService("Players").LocalPlayer.Backpack:FindFirstChild(aa)
            if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
                game:GetService("Players").LocalPlayer.Character.Humanoid:EquipTool(Weapon)
            end
        end
    end)
end
EWeapon = function()
    pcall(function()
        if Config['Tool'] == nil or Config['Tool'] == "" then
            Config['Tool'] = "Melee"
        end
        if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild(Getweapon(Config['Tool'])) then
            local Weapon = game:GetService("Players").LocalPlayer.Backpack:FindFirstChild(Getweapon(Config['Tool']))
            if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
                game:GetService("Players").LocalPlayer.Character.Humanoid:EquipTool(Weapon)
            end
        end
    end)
end
function Checksea(w)
    if w == 1 then
        return game.PlaceId == 2753915549
    elseif w == 2 then
        return game.PlaceId == 4442272183
    elseif w == 3 then
        return game.PlaceId == 7449423635
    end
end
local Rportal = {}
if Checksea(1) then
    Rportal = {
        ["Sky 2"] = Vector3.new(-4607.82275390625, 872.5774536132812,-1667.556884765625),
        ["Sky 3"] = Vector3.new(-7894.61767578125,5545.52783203125,-380.29119873046875),
        ["UnderWater 1"] = Vector3.new(61163.8515625,5.342312812805176,1819.7841796875),
        ["UnderWater 2"] = Vector3.new(3864.6884765625,17.408157825469971,-1926.214111328125)
    }
elseif Checksea(2) then
    Rportal = {
        ["Mansion"] =  Vector3.new(-286.98907470703125,306.1656799316406,597.8519287109375),
        ["Swan Room"] = Vector3.new(2284.912109375,15.18704605102539,905.5137329101562),
        ["Current Ship 1"] = Vector3.new(923.2125244140625,125.09213256835938,32852.83203125),
        ["Current Ship 2"] = Vector3.new(-6508.55810546875,83.2220458984375,-132.83953857421875)
    }
elseif Checksea(3) then
    Rportal = {
        ["Mansion"] = Vector3.new(-12463.6064453125,374.94952392578125,-7549.5341796875),
        ["Castle On The Sea"] = Vector3.new(-5073.84912109375,314.5505676269531,-3152.5322265625),
        ["Hydra Island"] = Vector3.new(5661.52734375,1013.0795288085938,-334.9577331542969),
        ["Temple Of Time"] = Vector3.new(28286.35546875,14896.544921875,102.62469482421875)
    }
end
function GetNearestPortal(pos)
    local pos1 = pos.Position
    local min = math.huge
    local Tp = Vector3.new(0, 0, 0)
    for a, v in pairs(Rportal) do
        if (v - pos1).Magnitude <= min and v ~= Tp then
            min = (v - pos1).Magnitude
            Tp = v
        end
    end
    return Tp
end
function RequestEntrance(aa)
    local args = {
        "requestEntrance",
        aa
    }
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
    wait(.3)
end
function CheckInventory(Items)
    for r, v in next, game.ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory") do
        if v.Name == Items then
            return true
        end
    end
    return false
end
if workspace:FindFirstChild("Nah") then 
    workspace:FindFirstChild("Nah"):Destroy()
end
local Nah = Instance.new("Part", workspace)
Nah.Name = "Nah"
Nah.Anchored = true
Nah.CanCollide = false
Nah.Transparency = 1
Nah.CanTouch = false
task.spawn(function()
    Nah.CFrame = game.Players.LocalPlayer.Character.PrimaryPart.CFrame
    while task.wait() do
        if NoClip then
            if (Nah.Position - game.Players.LocalPlayer.Character.PrimaryPart.Position).Magnitude < 200 then
                game.Players.LocalPlayer.Character.PrimaryPart.CFrame = Nah.CFrame
            else
                Nah.CFrame = game.Players.LocalPlayer.Character.PrimaryPart.CFrame
            end
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do if v:IsA('BasePart') then v.CanCollide = false end end
        end
    end
end)

function Totarget(cframeto)
    function GetPos(n)
        if typeof(n) == 'CFrame' then
            return n
        elseif typeof(n) == "Vector3" then
            return CFrame.new(n)
        else
            return nil
        end
    end
    local Target = cframeto
    local distance = (Target.Position - Nah.Position).Magnitude
    local Portal = GetNearestPortal(Target)
    local tweenservice = game:GetService('TweenService')
    local tweeninfo
    NoClip = true
    if distance <= 15 then
        task.spawn(function()
            NoClip = true
            if tween then tween:Cancel() end
            Nah.CFrame = Target
        end)
    elseif ((CheckInventory("Valkyrie Helm")) or (not CheckInventory("Valkyrie Helm") and not Checksea(3))) and Portal
    and (Target.p - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > (Portal - Target.p).Magnitude + 250 then
        if tween then tween:Cancel() end
        RequestEntrance(Portal)
    else
        if distance <= 450 then
            tweeninfo = TweenInfo.new(distance / 325 / 1.8, Enum.EasingStyle.Linear)
        else
            tweeninfo = TweenInfo.new(distance / 325, Enum.EasingStyle.Linear)
        end
        tween = tweenservice:Create(Nah, tweeninfo, {CFrame = Target})
        tween:Play()
    end
end
spawn(function()
    while wait(1) do
        if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
            NoClip = true
        elseif tween then
            NoClip = false
        end
    end
end)
spawn(function()
    while wait() do
        if NoClip then
            if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Head") then
                if not game:GetService("Players").LocalPlayer.Character.Head:FindFirstChild("Ngu") then
                    local Ngu = Instance.new("BodyVelocity", game:GetService("Players").LocalPlayer.Character.Head)
                    Ngu.Name = "Ngu"
                    Ngu.P = 1500
                    Ngu.Velocity = Vector3.new(0, 0, 0)
                    Ngu.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                end
            end
        else
            if game:GetService("Players").LocalPlayer.Character:WaitForChild("Head"):FindFirstChild("Ngu") then
                game:GetService("Players").LocalPlayer.Character.Head:FindFirstChild("Ngu"):Destroy()
            end
        end
    end
end)
function IsAlive(v)
    return v and not v:FindFirstChild("VehicleSeat") and v.Name ~= "PirateBrigade" and not string.find(v.Name:lower(), "boat") and v.Name ~= "FishBoat" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") 
end
local Boss
if Config["BossName"] == 'Tyrant' then
    Boss = {"Tyrant Of The Skies"}
end
spawn(function()
    while task.wait() do
        if getgenv().AutoBoss then
            if GetMob(Boss, true) then
                local v = GetMob(Boss, true)
                if IsAlive(v) then
                    repeat task.wait()
                        EnableBuso()
                        EWeapon()
                        Totarget(v.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
                    until not IsAlive(v)
                end
            else
                if Config["BossName"] == 'Tyrant' then
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Reisaga/yow/refs/heads/main/Tyrant.luau"))()
                end
            end
        end
    end
end)