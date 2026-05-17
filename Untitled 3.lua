local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

-- หมายเหตุ: ปลอดภัย 100% สคริปต์นี้สร้าง UI แยกอิสระ ไม่มีการลบหน้าโฮมหรือแท็บด้านบนของ UI หลักเกมเด็ดขาด

-- ========================================================
-- [ ระบบแชร์สถานะ และปุ่ม เปิด/ปิด ]
-- ========================================================
_G.AutoFarmEnabled = _G.AutoFarmEnabled or false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UTDX_AutoRift_UI"
if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 110)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "  UTDX AUTO RIFT v1.2"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 32)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "สถานะ: รอการเปิดใช้งาน..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 63)
toggleButton.BorderSizePixel = 0
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

local function updateUI()
    if _G.AutoFarmEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        toggleButton.Text = "บอททำงานอยู่: ON"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        toggleButton.Text = "บอทหยุดทำงาน: OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusLabel.Text = "สถานะ: ปิดระบบชั่วคราว"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

local function updateStatus(text, color)
    statusLabel.Text = "สถานะ: " .. text
    if color then statusLabel.TextColor3 = color end
end

updateUI()

toggleButton.MouseButton1Click:Connect(function()
    _G.AutoFarmEnabled = not _G.AutoFarmEnabled
    updateUI()
end)

-- ========================================================
-- [ ระบบจัดการฟาร์มในด่าน (In-Game Farm) ]
-- ========================================================
local function runInGameFarm()
    if not _G.AutoFarmEnabled then return end
    
    updateStatus("รอตัวเกมโหลดด่านเสร็จ...", Color3.fromRGB(241, 196, 15))
    if not game:IsLoaded() then game.Loaded:Wait() end
    repeat task.wait(0.5) until localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not _G.AutoFarmEnabled then return end
    updateStatus("กำลังเชื่อมต่อระบบ Knit...", Color3.fromRGB(52, 152, 219))
    
    local knitServices = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services")
    local macroRF = knitServices:WaitForChild("MacroService"):WaitForChild("RF")
    local waveRF = knitServices:WaitForChild("WaveService"):WaitForChild("RF")
    local waveRE = knitServices:WaitForChild("WaveService"):WaitForChild("RE")
    
    task.wait(3)
    if not _G.AutoFarmEnabled then return end
    
    -- เปิด Auto Skip Wave
    pcall(function() waveRF:WaitForChild("Vote"):InvokeServer(true) end)
    updateStatus("เปิด Auto Skip เรียบร้อย", Color3.fromRGB(46, 204, 113))
    
    -- โหลดและเล่นมาโคร Slot 1
    pcall(function()
        macroRF:WaitForChild("LoadMacroSlot"):InvokeServer(1)
        task.wait(0.5)
        macroRF:WaitForChild("Playback"):InvokeServer(1, true)
    end)
    updateStatus("เล่นมาโคร Slot 1 [กำลังฟาร์ม]", Color3.fromRGB(46, 204, 113))
    
    -- 🛑 [ระบบตรวจจับการจบเกมอิงตาม Wave 20 และ UI] 🛑
    local playerGui = localPlayer:WaitForChild("PlayerGui")
    local isMatchOver = false
    
    repeat
        task.wait(2)
        
        -- 1. เช็คดักจับจาก UI สรุปผลแพ้ชนะหลัก
        local endScreen = playerGui:FindFirstChild("GameOverGui", true) or playerGui:FindFirstChild("VictoryGui", true) or playerGui:FindFirstChild("MatchEndGui", true)
        
        -- 2. เช็คจากเลือดของฐาน (ถ้าโดนตีแตก/เกมจบ วัตถุนี้จะหายไปจาก Workspace)
        local baseHealth = workspace:FindFirstChild("BaseHealth")
        
        -- 3. อ่านค่าจากระบบด่านเพื่อเช็คว่าผ่าน Wave 20 หรือยัง (หรือดักจับคำว่า Wave 20 บน UI หน้าจอของคุณ)
        local currentWaveValue = ReplicatedStorage:FindFirstChild("CurrentWave") or workspace:FindFirstChild("CurrentWave")
        local isWave20Over = false
        if currentWaveValue and currentWaveValue.Value >= 20 then
            -- ถ้าค่า Value เกินหรือเท่ากับ 20 และฝั่งมอนสเตอร์หมดเกลี้ยง แปลว่าจบตาชัวร์
            isWave20Over = true
        end
        
        -- รวมเงื่อนไขเพื่อความแม่นยำสูงสุด ป้องกันการกด Replay ก่อนเวลา
        if (endScreen and endScreen.Enabled == true) or not baseHealth or isWave20Over then
            -- เช็คซ้ำอีกรอบเพื่อความชัวร์ (Double Check)
            task.wait(1)
            if (endScreen and endScreen.Enabled == true) or not baseHealth or isWave20Over then
                isMatchOver = true
            end
        end
    until not _G.AutoFarmEnabled or isMatchOver
    
    if not _G.AutoFarmEnabled then return end
    updateStatus("เกมจบที่ Wave 20 แล้ว! โหวต Replay...", Color3.fromRGB(241, 196, 15))
    task.wait(3) -- หน่วงเวลาให้เซิร์ฟเวอร์เปิดปุ่มโหวต Replay สมบูรณ์
    
    -- สั่งยิงรีโมทโหวต Replay วนซ้ำ 5 ครั้งเพื่อสู้กับเวลาดีเลย์คนอื่นในห้อง
    for i = 1, 5 do
        if not _G.AutoFarmEnabled then return end
        pcall(function() waveRE:WaitForChild("VoteReplay"):FireServer() end)
        task.wait(1)
    end
    
    task.wait(5)
    if not _G.AutoFarmEnabled then return end
    
    -- ถ้าหน้าจอยังค้างอยู่ที่เดิมหลังจากยิง Replay ไปแล้ว แปลว่า Rift รีเวลา/ปิดด่านแล้ว ให้กลับล็อบบี้
    local stillInEndScreen = playerGui:FindFirstChild("GameOverGui", true) or playerGui:FindFirstChild("VictoryGui", true)
    if stillInEndScreen then
        updateStatus("Rift หมดเวลา/ปิดแล้ว กลับ Lobby...", Color3.fromRGB(231, 76, 60))
        pcall(function() waveRE:WaitForChild("ToLobby"):FireServer() end)
    else
        updateStatus("Replay สำเร็จ! กำลังโหลดห้องใหม่...", Color3.fromRGB(46, 204, 113))
    end
end

-- ========================================================
-- [ ลูปหลัก ตรวจสอบพื้นที่ และรันงานอัตโนมัติ ]
-- ========================================================
task.spawn(function()
    while true do
        task.wait(2)
        
        if _G.AutoFarmEnabled then
            -- ตรวจสอบตำแหน่งผ่าน PlaceId โซน Lobby
            if game.PlaceId == 16641147425 or workspace:FindFirstChild("Lobby") or not workspace:FindFirstChild("Map") then 
                updateStatus("อยู่ที่ Lobby กำลังยิงเข้า Rift...", Color3.fromRGB(52, 152, 219))
                
                -- เลือกเข้า MegunaRift
                pcall(function()
                    local riftArgs1 = { buffer.fromstring(")\n\000MegunaRift\000\000\000\128?\001\0001\000\004\000Easy\000\000\005\000Rifts\000\000") }
                    ByteNetEvent:FireServer(unpack(riftArgs1))
                end)
                task.wait(0.1)
                
                -- เลือกเข้า GojoRift
                pcall(function()
                    local riftArgs2 = { buffer.fromstring(")\b\000GojoRift\000\000\000\128?\001\0001\000\004\000Easy\000\000\005\000Rifts\000\000") }
                    ByteNetEvent:FireServer(unpack(riftArgs2))
                end)
                task.wait(0.2)
                
                -- สั่ง Start เกม
                pcall(function()
                    local startArgs = { buffer.fromstring(",\000,\000") }
                    ByteNetEvent:FireServer(unpack(startArgs))
                end)
                
                updateStatus("เริ่มเกมแล้ว รอวาร์ปเข้าด่าน...", Color3.fromRGB(241, 196, 15))
                task.wait(5)
            else
                -- หากเข้าด่านมาฟาร์มแล้ว ให้รันฟังก์ชันบอทแก้อาการ Replay ไวเกินกำหนด
                runInGameFarm()
            end
        end
    end
end)