local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer
local Alert = getsenv(game.Players.LocalPlayer.PlayerScripts.CL_MAIN_GameScript).newAlert
local Key = -game.ReplicatedStorage.Remote.ReqPasskey:InvokeServer()
local AnimationState = {}
local Savestates = {}
local PlayerInfo = {}
local TimePaused = 0
local Pause = true
local TimePauseHolder
local SenvAnimation
local PlayAnimation
local TimeStart
local TimeText
local function ReturnPlayerInfo()
    return {
            CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame,
            CameraCFrame = game.Workspace.CurrentCamera.CFrame,
            Velocity = game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity,
            Animation = AnimationState,
            Time = os.clock() - TimeStart - TimePaused,
    }
end
local function SetPrimaryPart()
    local CharacterParts = {}
    local Character = LocalPlayer.Character
    local Ray = Ray.new(Character.HumanoidRootPart.Position,Vector3.new(0,-10,0))
    if game.Workspace.CurrentCamera:FindFirstChild("ShadowPt") then
        table.insert(CharacterParts,game.Workspace.CurrentCamera.ShadowPt)
    end
    for i,v in pairs(game.Players:GetPlayers()) do
        pcall(function()
            for j,k in pairs(v.Character:GetChildren()) do
                if k:IsA("Part") then
                    table.insert(CharacterParts,k)
                end
            end
        end) 
    end
    while true do
        local hit,pos = game.Workspace:FindPartOnRayWithIgnoreList(Ray,CharacterParts)
        if hit:IsA("Part") and math.floor(hit.Size.X) == math.floor(hit.Size.Z) then
            game.Workspace.Multiplayer.Map.PrimaryPart = hit
            break
        else
            table.insert(CharacterParts,hit)
        end
    end
end
local function SetUpGui()
    for i,v in pairs(LocalPlayer.PlayerGui.GameGui.HUD.GameStats:GetChildren()) do
        if v:IsA("Frame") then
            v.Visible = false
        end
    end
    TimeText = Instance.new("TextLabel")
    TimeText.Name = "TimeText"
    TimeText.Parent = LocalPlayer.PlayerGui.GameGui.HUD.GameStats
    TimeText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TimeText.BackgroundTransparency = 1.000
    TimeText.Position = UDim2.new(0.030, 0, 0.35, 0)
    TimeText.Size = UDim2.new(0, 100, 0, 27)
    TimeText.Font = Enum.Font.Highway
    TimeText.Text = "0:00:000"
    TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
    TimeText.TextSize = 60
    TimeText.TextXAlignment = Enum.TextXAlignment.Left
    LocalPlayer.PlayerGui.GameGui.Challenges.Visible = false
end
local function SetUpMap()
    local Map
    local CurrentInfo
    function game.ReplicatedStorage.Remote.ReqCharVars.OnClientInvoke() return {} end
    SetPrimaryPart()
    Map = game.Workspace.Multiplayer.Map:Clone()
    Map.Parent = game.Workspace
    Map:MoveTo(Vector3.new(0,1000,0))
    LocalPlayer.Character.Head:Destroy()
    LocalPlayer.CharacterAdded:Wait()
    LocalPlayer.Character:WaitForChild("Humanoid")
    LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    ReplicatedStorage.Remote.RemoveWaiting:FireServer(Key)
    LocalPlayer.Character.Humanoid.WalkSpeed = 0
    LocalPlayer.Character.Humanoid.JumpPower = 0
    task.wait(0.5)
    LocalPlayer.Character.Humanoid.WalkSpeed = 0
    LocalPlayer.Character.Humanoid.JumpPower = 0
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Map.PrimaryPart.Position) + Vector3.new(0,Map.PrimaryPart.Size.Y/2,0) + Vector3.new(0,LocalPlayer.Character.HumanoidRootPart.Size.Y/2,0) + Vector3.new(0,LocalPlayer.Character["Left Leg"].Size.Y,0)
    task.wait(0.5)
    LocalPlayer.Character.HumanoidRootPart.Anchored = true
    LocalPlayer.Character.Humanoid.WalkSpeed = 20
    LocalPlayer.Character.Humanoid.JumpPower = 50
    table.insert(Savestates,{{
        CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame,
        CameraCFrame = game.Workspace.CurrentCamera.CFrame,
        Velocity = Vector3.new(0,0,0),
        Animation = {"idle",0},
        Time = 0
    }})
    SetUpGui()
    SenvAnimation = getsenv(game.Players.LocalPlayer.Character.Animate)
    PlayAnimation = SenvAnimation.playAnimation
    TimePauseHolder = os.clock()
    TimeStart = os.clock()
    function SenvAnimation.playAnimation(a,b)
        if not Pause then
            AnimationState = {a,b}
            PlayAnimation(AnimationState[1],AnimationState[2], LocalPlayer.Character.Humanoid)
        end
    end
end
local function SetTimeGui()
    local TimePlayed = os.clock() - TimeStart - TimePaused
    local m = math.floor(TimePlayed / 60)
    local s = math.floor(TimePlayed % 60)
    local ms = math.floor((TimePlayed * 1000) % 1000)
    m = tostring(m)
    s = tostring(s)
    ms = tostring(ms)
    for i=1, 2 do if #ms < 3 then ms = '0' .. ms end end
    for i=1, 1 do if #s < 2 then s = '0' .. s end end
    TimeText.Text = m .. ":" .. s .. ":" .. ms
end
local function UserPause()
    Pause = not Pause
    if Pause then
        LocalPlayer.Character.HumanoidRootPart.Anchored = true
        TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
        TimePauseHolder = os.clock()
    else
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
        TimeText.TextColor3 = Color3.fromRGB(255,255,255)
        TimePaused = TimePaused + os.clock() - TimePauseHolder
    end
end
local function BackSavestate()
    local InfoState = Savestates[#Savestates][#Savestates[#Savestates]]
    PlayerInfo = {}
    Pause = true
    LocalPlayer.Character.HumanoidRootPart.Anchored = true
    TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
    LocalPlayer.Character.HumanoidRootPart.CFrame = InfoState.CFrame
    LocalPlayer.Character.HumanoidRootPart.Velocity = InfoState.Velocity
    game.Workspace.CurrentCamera.CFrame = InfoState.CameraCFrame
    TimePauseHolder = os.clock()
    TimeStart = os.clock() - InfoState.Time
    TimePaused = 0
    PlayAnimation(InfoState.Animation[1],InfoState.Animation[2],LocalPlayer.Character.Humanoid)
    if InfoState.Animation[1] == "walk" then
        SenvAnimation.setAnimationSpeed(.76)
    end
    SetTimeGui()
end
local function AddSavestate()
    Alert("Added Savestate",Color3.fromRGB(0, 255, 0),1)
    table.insert(Savestates,PlayerInfo)
    PlayerInfo = {}
end
local function RemoveSavestate()
    if #Savestates > 1 then
        Alert("Removed Savestate",Color3.fromRGB(0, 255, 0),1)
        table.remove(Savestates)
        BackSavestate()
    else
        Alert("No Savestate",Color3.fromRGB(255, 0, 0),1)
    end
end
local function CollisionToggler()
    local MouseTarget = game.Players.LocalPlayer:GetMouse().Target
    MouseTarget.CanCollide = not MouseTarget.CanCollide
    if MouseTarget.CanCollide then
        MouseTarget.Transparency = 0
    else
        MouseTarget.Transparency = 1
    end
end
local function SaveRun()
    local AllPlayerInfo = {}
    for i=2,#Savestates do
        for j=1,#Savestates[i] do
            local InfoFromSavestates = Savestates[i][j]
            local InfoAddingToAllPlayerInfo = {}
            local a,b,c = InfoFromSavestates.CFrame:ToEulerAnglesXYZ()
            local d,e,f  = InfoFromSavestates.CameraCFrame:ToEulerAnglesXYZ()
            InfoAddingToAllPlayerInfo.CFrame = {InfoFromSavestates.CFrame.X, InfoFromSavestates.CFrame.Y, InfoFromSavestates.CFrame.Z, a, b, c}
            InfoAddingToAllPlayerInfo.Animation = InfoFromSavestates.Animation
            InfoAddingToAllPlayerInfo.CameraCFrame = {InfoFromSavestates.CameraCFrame.X, InfoFromSavestates.CameraCFrame.Y, InfoFromSavestates.CameraCFrame.Z, d, e, f}
            InfoAddingToAllPlayerInfo.Time = InfoFromSavestates.Time
            table.insert(AllPlayerInfo,InfoAddingToAllPlayerInfo)
        end
    end
    local i = -1
    repeat i = i + 1 until not isfile("tas/" .. game.Workspace.Map.Settings.MapName.Value .. tostring(i) .. ".json")
    writefile("tas/" .. game.Workspace.Map.Settings.MapName.Value .. tostring(i) .. ".json", game:GetService("HttpService"):JSONEncode(AllPlayerInfo))
    Alert("Saved",Color3.fromRGB(0,255,0),1)
end
ReplicatedStorage.Remote.StartClientMapTimer.OnClientEvent:Wait()
task.wait(1)
SetUpMap()
if not isfolder("tas") then
    makefolder("tas")
end
RunService.Heartbeat:Connect(function()
    if not Pause then
        SetTimeGui()
        table.insert(PlayerInfo,ReturnPlayerInfo())
    end
end)
UserInputService.InputBegan:Connect(function(Key,Typing)
    if not Typing then
        Key = Key.KeyCode.Name
        if Key == "CapsLock" then
            UserPause()
        elseif Key == "One" then
            AddSavestate()
        elseif Key == "Two" then
            RemoveSavestate()
        elseif Key == "Three" then
            BackSavestate()
        elseif Key == "Four" then
            CollisionToggler()
        elseif Key == "Five" then
            SaveRun()
        end
    end
end)
