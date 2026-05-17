local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

-- [[ ความปลอดภัยขั้นสูงสุด ]]
-- สคริปต์นี้สร้าง UI แยกอิสระ ปลอดภัย 100% ไม่ยุ่งเกี่ยว ไม่สั่งลบ (Destroy) หน้าโฮมและแท็บแถบเมนูด้านบนของ UI เกมหลักแน่นอน

-- ========================================================
-- [ กล่องแสดงสถานะการทำงานแบบคลีน (No Button) ]
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
    
    -- 🛑 [ระบบตรวจจับจบเกม: รอจนกว่าหน้าต่างผลลัพธ์จะปรากฏขึ้นตามรูป 3] 🛑
    local playerGui = localPlayer:WaitForChild("PlayerGui")
    local isUIActive = false
    
    repeat
        task.wait(1) -- ลูปสแกนหาหน้าจอสรุปผลลัพธ์ความถี่สูงทุก 1 วินาที
        
        -- ดักจับโครงสร้างตามรูปภาพที่คุณส่งมา (เช็คทั้งหน้าต่างหลัก และระบบสับเปลี่ยน)
        local gameUI = playerGui:FindFirstChild("GameUI")
        if gameUI then
            local missionResult = gameUI:FindFirstChild("MissionResultFrame")
            if missionResult and missionResult.Visible == true then
                isUIActive = true
            end
        end
        
        -- ดักจับโครงสร้างหน้า Finished (กรณีชนะแบบเดิม)
        local finishedGui = playerGui:FindFirstChild("Finished")
        if finishedGui and finishedGui.Enabled == true then
            isUIActive = true
        end
    until isUIActive
    
    -- สั่งงานทันทีเมื่อหน้าจอสรุปผลแพ้/ชนะอันใดอันหนึ่งเด้งขึ้นมา
    updateStatus("ตรวจพบ UI สรุปผล! เริ่มการโหวต Replay...", Color3.fromRGB(241, 196, 15))
    task.wait(2)
    
    -- รัวดาต้าส่งโหวต Replay 5 ครั้งสู้ดีเลย์
    for i = 1, 5 do
        pcall(function() waveRE:WaitForChild("VoteReplay"):FireServer() end)
        task.wait(1)
    end
    
    task.wait(5)
    
    -- ตรวจสอบกระบวนการหลังกดส่ง: ถ้าหน้าจอ UI ผลลัพธ์ยังค้างอยู่ แสดงว่ากดไม่ผ่านหรือ Rift รีรอบไปแล้ว
    local stillKickedOrEnd = false
    local gameUI = playerGui:FindFirstChild("GameUI")
    if gameUI then
        local missionResult = gameUI:FindFirstChild("MissionResultFrame")
        if missionResult and missionResult.Visible == true then stillKickedOrEnd = true end
    end
    
    local finishedGui = playerGui:FindFirstChild("Finished")
    if finishedGui and finishedGui.Enabled == true then stillKickedOrEnd = true end
    
    if stillKickedOrEnd then
        -- ถ้าปุ่มหายหรือกด Replay ต่อไม่ได้แล้ว บังคับส่ง Packet กลับล็อบบี้ทันที
        updateStatus("ปุ่ม Replay หมดแล้ว! กำลังกลับ Lobby...", Color3.fromRGB(231, 76, 60))
        pcall(function() waveRE:WaitForChild("ToLobby"):FireServer() end)
    else
        updateStatus("Replay สำเร็จ! กำลังโหลดแมพใหม่...", Color3.fromRGB(46, 204, 113))
    end
end

-- ========================================================
-- [ ลูปหลัก ตรวจสอบตำแหน่งแมพเพื่อเริ่มทำงานออโต้ ]
-- ========================================================
task.spawn(function()
    while true do
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
            
            -- สั่งเข้าเล่นทันที
            pcall(function()
                local startArgs = { buffer.fromstring(",\000,\000") }
                ByteNetEvent:FireServer(unpack(startArgs))
            end)
            
            updateStatus("เริ่มเกมแล้ว รอวาร์ปเข้าด่าน...", Color3.fromRGB(241, 196, 15))
            task.wait(5)
        else
            -- อยู่ในเซิร์ฟเวอร์ด่านฟาร์ม
            runInGameFarm()
            break
        end
        task.wait(2)
    end
end)
