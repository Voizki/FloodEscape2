local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer
local Alert = getsenv(game.Players.LocalPlayer.PlayerScripts.CL_MAIN_GameScript).newAlert
local TasToPlay
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
local function ReturnCFrame(CFrameTable)
    return CFrame.new(CFrameTable[1],CFrameTable[2],CFrameTable[3]) * CFrame.Angles(CFrameTable[4],CFrameTable[5],CFrameTable[6])
end
local function PlayTas()
    local File = game:GetService("HttpService"):JSONDecode(readfile("tas/" .. TasToPlay))
    local SenvAnimation = getsenv(LocalPlayer.Character.Animate)
    local PlayAnimation = SenvAnimation.playAnimation
    local SetAnimationSpeed = SenvAnimation.setAnimationSpeed
    local HeartBeatLoop
    local TimeStarted
    local MapSpawn
    local Calc
    SetPrimaryPart()
    MapSpawn = game.Workspace.Multiplayer.Map.PrimaryPart
    function SenvAnimation.playAnimation()
    end
    function SenvAnimation.setAnimationSpeed()
    end
    TimeStarted = os.clock()
    HeartBeatLoop = RunService.Heartbeat:Connect(function()
        Calc = Vector3.new(MapSpawn.Position.X,MapSpawn.Position.Y - 1000,MapSpawn.Position.Z)
        local InGameTime = os.clock() - TimeStarted
        local CurrentInfo
        for i=1,#File do
            if File[i].Time > InGameTime then
                CurrentInfo = File[i]
                break
            end
        end
        if not CurrentInfo then
            HeartBeatLoop:Disconnect()
            SenvAnimation.setAnimationSpeed = SetAnimationSpeed
            SenvAnimation.playAnimation = PlayAnimation
        else 
            LocalPlayer.Character.HumanoidRootPart.CFrame = ReturnCFrame(CurrentInfo.CFrame) + Calc
            game.Workspace.CurrentCamera.CFrame = ReturnCFrame(CurrentInfo.CameraCFrame) + Calc
            PlayAnimation(CurrentInfo.Animation[1],CurrentInfo.Animation[2],LocalPlayer.Character.Humanoid)
            if CurrentInfo.Animation[1] == "walk" then
                SetAnimationSpeed(.76)
            end
        end
    end)
end
local function SetUpGui()
    local ScreenGui = Instance.new("ScreenGui")
    local Play = Instance.new("Frame")
    local Play_2 = Instance.new("TextButton")
    local Scroll = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")
    local Clone = Instance.new("TextButton")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Play.Active = true
    Play.Draggable = true
    Play.Name = "Play"
    Play.Parent = ScreenGui
    Play.BackgroundColor3 = Color3.fromRGB(52, 99, 255)
    Play.Position = UDim2.new(0.366922796, 0, 0.240740731, 0)
    Play.Size = UDim2.new(0, 585, 0, 476)
    Play_2.Name = "Play"
    Play_2.Parent = Play
    Play_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Play_2.Position = UDim2.new(0.328215331, 0, 0.820339739, 0)
    Play_2.Size = UDim2.new(0, 200, 0, 50)
    Play_2.Font = Enum.Font.SourceSans
    Play_2.Text = "Play"
    Play_2.TextColor3 = Color3.fromRGB(255, 255, 255)
    Play_2.TextSize = 14.000
    Scroll.Name = "Scroll"
    Scroll.Parent = Play
    Scroll.Active = true
    Scroll.BackgroundColor3 = Color3.fromRGB(67, 10, 255)
    Scroll.Position = UDim2.new(0.18632479, 0, -2.79396772e-09, 0)
    Scroll.Size = UDim2.new(0, 367, 0, 375)
    Scroll.CanvasSize = UDim2.new(0, 0, 1, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    UIListLayout.Parent = Scroll
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Clone.Name = "Clone"
    Clone.Parent = Play
    Clone.BackgroundColor3 = Color3.fromRGB(52, 99, 255)
    Clone.Position = UDim2.new(0.18632479, 0, 0, 0)
    Clone.Size = UDim2.new(0, 354, 0, 77)
    Clone.Visible = false
    Clone.Font = Enum.Font.SourceSans
    Clone.TextColor3 = Color3.fromRGB(0, 0, 0)
    Clone.TextSize = 14.000
    for i,v in pairs(listfiles("tas/")) do
        local NewClone = Clone:Clone()
        v = string.gsub(v,"tas/","")
        NewClone.Parent = Scroll
        NewClone.Text = v
        NewClone.Visible = true
        NewClone.MouseButton1Click:Connect(function()
            Alert(v .. " Selected",Color3.fromRGB(0,255,0),1)
            TasToPlay = v
        end)
    end
    Play_2.MouseButton1Click:Connect(function()
        if not TasToPlay then
            Alert("Nothing Selected",Color3.fromRGB(255,0,0),1)
        else
            Play.Visible = false
            ReplicatedStorage.Remote.StartClientMapTimer.OnClientEvent:Wait()
            PlayTas()
        end
    end)
end
SetUpGui()
