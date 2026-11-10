-- =======================================================
-- HOANG NAM HUB V1 - FULL FEATURES
-- =======================================================

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Cập nhật lại Character khi nhân vật chết và hồi sinh
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)

---------------------------------------------------------
-- 1. XỬ LÝ LOGIC CÁC TÍNH NĂNG
---------------------------------------------------------
-- Biến trạng thái
local isFlying = false
local flySpeed = 50
local defaultSpeed = 16
local customSpeed = 50
local isSpeedEnabled = false
local isNoclipEnabled = false
local isEspEnabled = false

local bodyVelocity = nil
local bodyGyro = nil
local espHighlights = {}

-- 1. Fly
local function toggleFly()
    isFlying = not isFlying
    if isFlying then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = RootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bodyGyro.CFrame = RootPart.CFrame
        bodyGyro.Parent = RootPart
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
end

-- 2. Noclip & Speed & Fly Loop
RunService.Stepped:Connect(function()
    -- Noclip (Đi xuyên tường)
    if isNoclipEnabled and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    -- Fly Movement
    if isFlying and RootPart and bodyVelocity and bodyGyro then
        local camera = workspace.CurrentCamera
        local moveDir = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        bodyVelocity.Velocity = moveDir * flySpeed
        bodyGyro.CFrame = camera.CFrame
    end
    
    -- Speed
    if Humanoid then
        if isSpeedEnabled then
            Humanoid.WalkSpeed = customSpeed
        else
            Humanoid.WalkSpeed = defaultSpeed
        end
    end
end)

-- 4. ESP Player (Nhìn xuyên tường thấy người chơi)
local function updateEsp()
    if isEspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and not espHighlights[player] then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = player.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = player.Character
                espHighlights[player] = highlight
            end
        end
    else
        for player, highlight in pairs(espHighlights) do
            if highlight then highlight:Destroy() end
        end
        espHighlights = {}
    end
end

-- 5. Teleport To Player (Hàm dịch chuyển đến người chơi đầu tiên khác ngoài bạn)
local function teleportToRandomPlayer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            RootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            break
        end
    end
end

---------------------------------------------------------
-- 2. TẠO GIAO DIỆN GUI (HOANG NAM HUB V1)
---------------------------------------------------------
if LocalPlayer.PlayerGui:FindFirstChild("HoangNamHubV1") then
    LocalPlayer.PlayerGui.HoangNamHubV1:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoangNamHubV1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 360)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = "HoangNamHub V1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Hàm tạo nút bấm chung cho gọn code
local function createButton(name, text, posY)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = UDim2.new(0.075, 0, posY, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.SourceSans
    btn.Parent = MainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    return btn
end

-- 1. Nút Fly
local FlyButton = createButton("FlyButton", "Toggle Fly: OFF", 0.16)
FlyButton.MouseButton1Click:Connect(function()
    toggleFly()
    if isFlying then
        FlyButton.Text = "Toggle Fly: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
    else
        FlyButton.Text = "Toggle Fly: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    end
end)

-- 2. Nút Speed
local SpeedButton = createButton("SpeedButton", "Toggle Speed (50): OFF", 0.31)
SpeedButton.MouseButton1Click:Connect(function()
    isSpeedEnabled = not isSpeedEnabled
    if isSpeedEnabled then
        SpeedButton.Text = "Toggle Speed (50): ON"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
    else
        SpeedButton.Text = "Toggle Speed (50): OFF"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    end
end)

-- 3. Nút Noclip
local NoclipButton = createButton("NoclipButton", "Toggle Noclip: OFF", 0.46)
NoclipButton.MouseButton1Click:Connect(function()
    isNoclipEnabled = not isNoclipEnabled
    if isNoclipEnabled then
        NoclipButton.Text = "Toggle Noclip: ON"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
    else
        NoclipButton.Text = "Toggle Noclip: OFF"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    end
end)

-- 4. Nút ESP Player
local EspButton = createButton("EspButton", "Toggle ESP Player: OFF", 0.61)
EspButton.MouseButton1Click:Connect(function()
    isEspEnabled = not isEspEnabled
    updateEsp()
    if isEspEnabled then
        EspButton.Text = "Toggle ESP Player: ON"
        EspButton.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
    else
        EspButton.Text = "Toggle ESP Player: OFF"
        EspButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    end
end)

-- 5. Nút Teleport To Player
local TpButton = createButton("TpButton", "Teleport to Player", 0.76)
TpButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
TpButton.MouseButton1Click:Connect(function()
    teleportToRandomPlayer()
end)

-- Phụ đề hướng dẫn phím tắt
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 25)
Subtitle.Position = UDim2.new(0, 0, 0.91, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Bấm phím 'K' để Ẩn/Hiện Menu"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.TextSize = 13
Subtitle.Font = Enum.Font.SourceSansItalic
Subtitle.Parent = MainFrame

-- Lắng nghe sự kiện bàn phím bấm phím 'K' để ẩn/hiện giao diện
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("HoangNamHub V1 đã khởi chạy thành công!")
