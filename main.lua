local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

-- [[ กฎความปลอดภัยของระบบ UI ]]
-- สคริปต์นี้สร้างหน้าต่างแจ้งเตือนแยกเป็นเอกเทศ ไม่ยุ่งเกี่ยว ไม่สั่งลบ (Destroy) หน้าโฮมและแท็บเมนูด้านบนของ UI เกมเด็ดขาด

-- ========================================================
-- [ หน้าต่างแสดงสถานะแบบคลีนกะทัดรัด (Status Monitor Only) ]
-- ========================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UTDX_Monitor_UI"
if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 65)
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
titleLabel.Size = UDim2.new(1, 0, 0, 25)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "  UTDX AUTO RIFT MONITOR"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "สถานะ: บอทเริ่มระบบอัตโนมัติ..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local function updateStatus(text, color)
    statusLabel.Text = "สถานะ: " .. text
    if color then statusLabel.TextColor3 = color end
end

-- ========================================================
-- [ ระบบจัดการฟาร์มในด่าน (In-Game Farm) ]
-- ========================================================
local function runInGameFarm()
    updateStatus("รอตัวเกมโหลดด่านเสร็จ...", Color3.fromRGB(241, 196, 15))
    if not game:IsLoaded() then game.Loaded:Wait() end
    repeat task.wait(0.5) until localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    updateStatus("กำลังเชื่อมต่อระบบ Knit...", Color3.fromRGB(52, 152, 219))
    local knitServices = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services")
    local macroRF = knitServices:WaitForChild("MacroService"):WaitForChild("RF")
    local waveRF = knitServices:WaitForChild("WaveService"):WaitForChild("RF")
    local waveRE = knitServices:WaitForChild("WaveService"):WaitForChild("RE")
    
    task.wait(3)
    
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
    
    -- 🛑 [ระบบตรวจจับจบเกม: สแกนหาหน้าจอผลลัพธ์จากรูปจริงความถี่สูง] 🛑
    local playerGui = localPlayer:WaitForChild("PlayerGui")
    local isUIActive = false
    
    repeat
        task.wait(1) -- ตรวจเช็คทุก 1 วินาทีเพื่อความแม่นยำสูงสุด
        
        -- ดักจับจากหน้าต่างผลลัพธ์หลักตามรูปภาพแพ้/ชนะที่คุณส่งมา
        local gameUI = playerGui:FindFirstChild("GameUI")
        if gameUI then
            local missionResult = gameUI:FindFirstChild("MissionResultFrame")
            if missionResult and missionResult.Visible == true then
                isUIActive = true
            end
        end
        
        -- ดักจับระบบสแตนด์บายฉากชนะตัวเก่า (Finished) กันเหนียว
        local finishedGui = playerGui:FindFirstChild("Finished")
        if finishedGui and finishedGui.Enabled == true then
            isUIActive = true
        end
    until isUIActive
    
    -- สั่งงานทันทีเมื่อหน้าจอสรุปผลของเกมทำงานจริง
    updateStatus("ตรวจพบ UI สรุปผล! เริ่มการโหวต Replay...", Color3.fromRGB(241, 196, 15))
    task.wait(2)
    
    -- กดยิงรีโมท Replay 5 ครั้งสู้ระบบดีเลย์ของห้อง
    for i = 1, 5 do
        pcall(function() waveRE:WaitForChild("VoteReplay"):FireServer() end)
        task.wait(1)
    end
    
    task.wait(5)
    
    -- เช็คตรวจสอบกระบวนการหลังกดส่ง: ถ้าหน้าจอ UI ผลลัพธ์ยังค้างอยู่ แสดงว่ากดไม่สำเร็จหรือด่าน Rift ปิดรอบไปแล้ว
    local stillInEndScreen = false
    
    local gameUI = playerGui:FindFirstChild("GameUI")
    if gameUI then
        local missionResult = gameUI:FindFirstChild("MissionResultFrame")
        if missionResult and missionResult.Visible == true then stillInEndScreen = true end
    end
    
    local finishedGui = playerGui:FindFirstChild("Finished")
    if finishedGui and finishedGui.Enabled == true then stillInEndScreen = true end
    
    if stillInEndScreen then
        -- ถ้ากด Replay ซ้ำไม่ได้แล้ว ให้ส่ง Packet บังคับถอนตัววาร์ปกลับล็อบบี้ทันที
        updateStatus("ปุ่ม Replay หมดแล้ว! กำลังกลับ Lobby...", Color3.fromRGB(231, 76, 60))
        pcall(function() waveRE:WaitForChild("ToLobby"):FireServer() end)
    else
        updateStatus("Replay สำเร็จ! กำลังโหลดห้องใหม่...", Color3.fromRGB(46, 204, 113))
    end
end

-- ========================================================
-- [ ลูปหลัก ตรวจสอบพิกัดพื้นที่และรันบอทอัตโนมัติ ]
-- ========================================================
task.spawn(function()
    while true do
        -- เช็คพิกัดว่าตัวละครอยู่ที่ห้อง Lobby หรือไม่
        if game.PlaceId == 16641147425 or workspace:FindFirstChild("Lobby") or not workspace:FindFirstChild("Map") then 
            updateStatus("อยู่ที่ Lobby กำลังยิงเข้า Rift...", Color3.fromRGB(52, 152, 219))
            
            -- ส่งคำสั่ง Remote เลือกด่าน Rift
            pcall(function()
                local riftArgs1 = { buffer.fromstring(")\n\000MegunaRift\000\000\000\128?\001\0001\000\004\000Easy\000\000\005\000Rifts\000\000") }
                ByteNetEvent:FireServer(unpack(riftArgs1))
            end)
            task.wait(0.1)
            
            pcall(function()
                local riftArgs2 = { buffer.fromstring(")\b\000GojoRift\000\000\000\128?\001\0001\000\004\000Easy\000\000\005\000Rifts\000\000") }
                ByteNetEvent:FireServer(unpack(riftArgs2))
            end)
            task.wait(0.2)
            
            -- ยิง Remote สั่งคลิกปุ่มเริ่มเกม
            pcall(function()
                local startArgs = { buffer.fromstring(",\000,\000") }
                ByteNetEvent:FireServer(unpack(startArgs))
            end)
            
            updateStatus("เริ่มเกมแล้ว รอวาร์ปเข้าด่าน...", Color3.fromRGB(241, 196, 15))
            task.wait(5)
        else
            -- หากย้ายห้องมาอยู่ในด่านฟาร์มเรียบร้อยแล้ว
            runInGameFarm()
            break -- ออกจากลูปล็อบบี้เพื่อส่งไม้ต่อให้ระบบในด่านคุมลูปชีวิตเกมยาวๆ
        end
        task.wait(2)
    end
end)
