local Config = {
    Theme = {
        Background = Color3.fromRGB(18, 18, 22),
        Surface = Color3.fromRGB(26, 26, 32),
        Card = Color3.fromRGB(32, 32, 40),
        Accent = Color3.fromRGB(88, 140, 255),
        AccentDark = Color3.fromRGB(60, 100, 200),
        Text = Color3.fromRGB(220, 220, 230),
        TextDim = Color3.fromRGB(140, 140, 150),
        Green = Color3.fromRGB(80, 200, 120),
        Red = Color3.fromRGB(230, 80, 80),
        Orange = Color3.fromRGB(255, 170, 60),
        Border = Color3.fromRGB(40, 40, 48),
    },
    MaxLogs = 500,
    RakNetEnabled = true,
}

local Theme = Config.Theme

local Library = {}
do  
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local CoreGui = gethui and gethui() or game:GetService("CoreGui")
    
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RSPY"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    local function MakeDraggable(frame, drag)
        drag = drag or frame
        local dragging, dragInput, dragStart, startPos
        
        drag.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        drag.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        RunService.Heartbeat:Connect(function()
            if dragging and dragInput then
                local delta = dragInput.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    local function CreateRoundFrame(props)
        local frame = Instance.new("Frame")
        frame.Size = props.Size or UDim2.fromOffset(400, 300)
        frame.Position = props.Position or UDim2.fromOffset(0, 0)
        frame.BackgroundColor3 = props.Bg or Theme.Surface
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Selectable = true
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, props.Radius or 8)
        corner.Parent = frame
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = props.StrokeColor or Theme.Border
        stroke.Parent = frame
        
        frame.Parent = props.Parent or ScreenGui
        
        if props.Draggable ~= false then
            MakeDraggable(frame, props.DragHandle or frame)
        end
        
        return frame
    end
    
    local function CreateText(props)
        local label = Instance.new("TextLabel")
        label.Size = props.Size or UDim2.fromOffset(100, 20)
        label.Position = props.Position or UDim2.fromOffset(0, 0)
        label.BackgroundTransparency = 1
        label.Text = props.Text or ""
        label.TextColor3 = props.Color or Theme.Text
        label.TextSize = props.TextSize or 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
        label.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
        label.RichText = true
        label.ZIndex = props.ZIndex or 1
        label.Parent = props.Parent
        return label
    end
    
    local function CreateScrollingFrame(props)
        local frame = Instance.new("ScrollingFrame")
        frame.Size = props.Size or UDim2.fromOffset(380, 300)
        frame.Position = props.Position or UDim2.fromOffset(0, 0)
        frame.BackgroundColor3 = props.Bg or Theme.Surface
        frame.BackgroundTransparency = props.BgTransparency or 0
        frame.BorderSizePixel = 0
        frame.ScrollBarThickness = 6
        frame.ScrollBarImageColor3 = Theme.Accent
        frame.CanvasSize = UDim2.fromOffset(0, 0)
        frame.AutomaticCanvasSize = props.AutoSize or Enum.AutomaticSize.Y
        frame.Parent = props.Parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, props.Radius or 0)
        corner.Parent = frame
        
        frame.ClipsDescendants = true
        
        return frame
    end
    
    local function CreateButton(props)
        local btn = Instance.new("TextButton")
        btn.Size = props.Size or UDim2.fromOffset(100, 30)
        btn.Position = props.Position or UDim2.fromOffset(0, 0)
        btn.BackgroundColor3 = props.Bg or Theme.Accent
        btn.Text = props.Text or "Button"
        btn.TextColor3 = props.TextColor or Theme.Text
        btn.TextSize = props.TextSize or 13
        btn.Font = Enum.Font.GothamSemibold
        btn.AutoButtonColor = false
        btn.ZIndex = props.ZIndex or 1
        btn.BorderSizePixel = 0
        btn.Parent = props.Parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, props.Radius or 6)
        corner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = props.HoverColor or Theme.AccentDark}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = props.Bg or Theme.Accent}):Play()
        end)
        
        if props.OnClick then
            btn.MouseButton1Click:Connect(props.OnClick)
        end
        
        return btn
    end
    
    local function CreateSearchBox(props)
        local container = CreateRoundFrame({
            Size = props.Size or UDim2.fromOffset(200, 30),
            Position = props.Position or UDim2.fromOffset(0, 0),
            Bg = Theme.Card,
            Radius = 6,
            Parent = props.Parent,
        })
        
        local icon = CreateText({
            Text = "🔍",
            Size = UDim2.fromOffset(24, 30),
            Position = UDim2.fromOffset(6, 0),
            Color = Theme.TextDim,
            TextSize = 12,
            Parent = container,
        })
        
        local box = Instance.new("TextBox")
        box.Size = UDim2.fromOffset(props.Size.X.Offset - 36, 30)
        box.Position = UDim2.fromOffset(30, 0)
        box.BackgroundTransparency = 1
        box.Text = ""
        box.PlaceholderText = props.Placeholder or "Поиск..."
        box.PlaceholderColor3 = Theme.TextDim
        box.TextColor3 = Theme.Text
        box.TextSize = 13
        box.Font = Enum.Font.Gotham
        box.ClearTextOnFocus = false
        box.Parent = container
        
        return container, box
    end
    
    local Tabs = {}
    local ActiveTab = nil
    local TabContainer = nil
    
    local function CreateTabSystem(props)
        local parent = props.Parent
        local tabPositions = props.TabPositions or {UDim2.fromOffset(10, 10)}
        local buttonSize = props.ButtonSize or UDim2.fromOffset(120, 32)
        
        TabContainer = parent
        
        local function AddTab(name, onClick)
            local pos = #Tabs + 1
            local xOffset = 10 + (pos - 1) * (buttonSize.X.Offset + 6)
            
            local btn = CreateButton({
                Size = buttonSize,
                Position = UDim2.fromOffset(xOffset, 10),
                Text = name,
                Bg = Theme.Card,
                TextColor = Theme.TextDim,
                HoverColor = Theme.AccentDark,
                Parent = parent,
                OnClick = function()
                    if ActiveTab then
                        ActiveTab.Btn.BackgroundColor3 = Theme.Card
                        ActiveTab.Btn.TextColor3 = Theme.TextDim
                        if ActiveTab.Hide then ActiveTab.Hide() end
                    end
                    
                    btn.BackgroundColor3 = Theme.Accent
                    btn.TextColor3 = Theme.Text
                    ActiveTab = Tabs[name]
                    ActiveTab.Btn = btn
                    if ActiveTab.Show then ActiveTab.Show() end
                    
                    if onClick then onClick() end
                end,
            })
            
            Tabs[name] = {Btn = btn, Show = nil, Hide = nil}
            return Tabs[name]
        end
        
        return AddTab
    end
    
    Library.CreateRoundFrame = CreateRoundFrame
    Library.CreateText = CreateText
    Library.CreateScrollingFrame = CreateScrollingFrame
    Library.CreateButton = CreateButton
    Library.CreateSearchBox = CreateSearchBox
    Library.CreateTabSystem = CreateTabSystem
    Library.ScreenGui = ScreenGui
end

local MainWindow = Library.CreateRoundFrame({
    Size = UDim2.fromOffset(820, 560),
    Position = UDim2.fromOffset(100, 80),
    Bg = Theme.Background,
    Radius = 12,
    Draggable = true,
})

local Header = Library.CreateRoundFrame({
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.fromOffset(0, 0),
    Bg = Theme.Surface,
    Radius = 12,
    Parent = MainWindow,
    Draggable = false,
})

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header
local HeaderCover = Instance.new("Frame")
HeaderCover.Size = UDim2.new(1, 0, 0, 4)
HeaderCover.Position = UDim2.fromOffset(0, 38)
HeaderCover.BackgroundColor3 = Theme.Surface
HeaderCover.BorderSizePixel = 0
HeaderCover.Parent = Header

Library.CreateText({
    Text = "RSPY v2.0 — Remote Spy Pro",
    Size = UDim2.fromOffset(300, 40),
    Position = UDim2.fromOffset(14, 0),
    Color = Theme.Text,
    TextSize = 16,
    Parent = Header,
})

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(8, 8)
StatusDot.Position = UDim2.fromOffset(780, 16)
StatusDot.BackgroundColor3 = Theme.Green
StatusDot.BorderSizePixel = 0
StatusDot.Parent = Header
local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusDot

Library.CreateText({
    Text = "RakNet Active",
    Size = UDim2.fromOffset(100, 40),
    Position = UDim2.fromOffset(710, 0),
    Color = Theme.Green,
    TextSize = 11,
    Parent = Header,
})


local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -48)
Content.Position = UDim2.fromOffset(0, 44)
Content.BackgroundTransparency = 1
Content.Parent = MainWindow

local AddTab = Library.CreateTabSystem({
    Parent = Content,
    ButtonSize = UDim2.fromOffset(150, 30),
})

local PacketContainer, OutgoingContainer, IncomingContainer, SpyContainer
local PacketList, OutgoingList, IncomingList, SpyList
local SearchBox

do
    local tab = AddTab("📦 All Packets")
    
    tab.Show = function()
        if PacketContainer then PacketContainer.Visible = true end
    end
    tab.Hide = function()
        if PacketContainer then PacketContainer.Visible = false end
    end
    
    local searchCont, searchBox = Library.CreateSearchBox({
        Size = UDim2.fromOffset(250, 28),
        Position = UDim2.fromOffset(10, 40),
        Placeholder = "Поиск remote...",
        Parent = Content,
    })
    SearchBox = searchBox
    
    local InfoBar = Library.CreateRoundFrame({
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.fromOffset(10, 74),
        Bg = Theme.Card,
        Radius = 6,
        Parent = Content,
    })
    
    local PacketCountText = Library.CreateText({
        Text = "Packets: 0 | Incoming: 0 | Outgoing: 0",
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        Color = Theme.TextDim,
        TextSize = 11,
        Parent = InfoBar,
    })
    
    local ClearBtn = Library.CreateButton({
        Size = UDim2.fromOffset(70, 24),
        Position = UDim2.fromOffset(720, 74),
        Text = "Clear",
        Bg = Theme.Red,
        TextSize = 11,
        Parent = Content,
        OnClick = function()
            PacketList:ClearAllChildren()
            PacketList.CanvasSize = UDim2.fromOffset(0, 0)
        end,
    })
    
    PacketList = Library.CreateScrollingFrame({
        Size = UDim2.new(1, -20, 1, -138),
        Position = UDim2.fromOffset(10, 108),
        Bg = Theme.Surface,
        Radius = 8,
        Parent = Content,
    })
    
    PacketContainer = PacketList
    PacketContainer.Visible = false
end

do
    local tab = AddTab("⬆️ Outgoing")
    
    tab.Show = function()
        if OutgoingContainer then OutgoingContainer.Visible = true end
    end
    tab.Hide = function()
        if OutgoingContainer then OutgoingContainer.Visible = false end
    end
    
    OutgoingList = Library.CreateScrollingFrame({
        Size = UDim2.new(1, -20, 1, -108),
        Position = UDim2.fromOffset(10, 44),
        Bg = Theme.Surface,
        Radius = 8,
        Parent = Content,
    })
    
    OutgoingContainer = OutgoingList
    OutgoingContainer.Visible = false
end

do
    local tab = AddTab("⬇️ Incoming")
    
    tab.Show = function()
        if IncomingContainer then IncomingContainer.Visible = true end
    end
    tab.Hide = function()
        if IncomingContainer then IncomingContainer.Visible = false end
    end
    
    IncomingList = Library.CreateScrollingFrame({
        Size = UDim2.new(1, -20, 1, -108),
        Position = UDim2.fromOffset(10, 44),
        Bg = Theme.Surface,
        Radius = 8,
        Parent = Content,
    })
    
    IncomingContainer = IncomingList
    IncomingContainer.Visible = false
end

do
    local tab = AddTab("🔍 Spy Control")
    
    tab.Show = function()
        if SpyContainer then SpyContainer.Visible = true end
    end
    tab.Hide = function()
        if SpyContainer then SpyContainer.Visible = false end
    end
    
    SpyContainer = Library.CreateRoundFrame({
        Size = UDim2.new(1, -20, 1, -52),
        Position = UDim2.fromOffset(10, 44),
        Bg = Theme.Surface,
        Radius = 8,
        Parent = Content,
    })
    
    Library.CreateText({
        Text = "RakNet / Remote Spy Controls",
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.fromOffset(12, 8),
        Color = Theme.Text,
        TextSize = 15,
        Parent = SpyContainer,
    })
    
    local buttonY = 50
    local buttons = {
        {Name = "Hook Remotes", Key = "hook", Bg = Theme.Accent},
        {Name = "Hook RakNet", Key = "raknet", Bg = Theme.Accent},
        {Name = "Block Selected", Key = "block", Bg = Theme.Red},
        {Name = "Unblock All", Key = "unblock", Bg = Theme.Orange},
        {Name = "Copy Args", Key = "copy", Bg = Theme.Green},
    }
    
    for i, btnData in ipairs(buttons) do
        Library.CreateButton({
            Size = UDim2.fromOffset(150, 32),
            Position = UDim2.fromOffset(12 + (i-1) * 160, buttonY),
            Text = btnData.Name,
            Bg = btnData.Bg,
            TextSize = 12,
            Parent = SpyContainer,
            OnClick = function()
                if btnData.Key == "hook" then
                    packetSpyEnabled = not packetSpyEnabled
                elseif btnData.Key == "raknet" then
                    raknetSnifferEnabled = not raknetSnifferEnabled
                elseif btnData.Key == "clear" then
                    -- clear
                end
            end,
        })
    end
    
    -- Список захваченных remote
    SpyList = Library.CreateScrollingFrame({
        Size = UDim2.new(1, -24, 1, -100),
        Position = UDim2.fromOffset(12, 96),
        Bg = Theme.Card,
        Radius = 6,
        Parent = SpyContainer,
    })
    
    Library.CreateText({
        Text = "Захваченные Remotes будут отображаться здесь...",
        Size = UDim2.new(1, -24, 0, 60),
        Position = UDim2.fromOffset(12, 6),
        Color = Theme.TextDim,
        TextSize = 12,
        Parent = SpyList,
    })
    
    SpyContainer.Visible = false
end

-- Активируем первую вкладку
local firstTab = next(Tabs)
if firstTab then
    Tabs[firstTab].Btn.BackgroundColor3 = Theme.Accent
    Tabs[firstTab].Btn.TextColor3 = Theme.Text
    ActiveTab = Tabs[firstTab]
    if ActiveTab.Show then ActiveTab.Show() end
end

-- === RAKNET / REMOTE SPY ENGINE ===
local packetSpyEnabled = true
local raknetSnifferEnabled = true
local packetCount = {Total = 0, Incoming = 0, Outgoing = 0}
local loggedRemotes = {}
local remoteLogs = {}

-- Функция добавления пакета в список
local function AddPacketEntry(list, data)
    if not list then return end
    if packetCount.Total >= Config.MaxLogs then
        local children = list:GetChildren()
        if #children > 0 then
            children[1]:Destroy()
        end
    end
    
    local entry = Library.CreateRoundFrame({
        Size = UDim2.new(1, -8, 0, 36),
        Position = UDim2.fromOffset(4, 0),
        Bg = Theme.Card,
        Radius = 4,
        Parent = list,
        Draggable = false,
    })
    
    -- Имя remote
    Library.CreateText({
        Text = data.Name or "Unknown",
        Size = UDim2.fromOffset(300, 36),
        Position = UDim2.fromOffset(8, 0),
        Color = Theme.Text,
        TextSize = 12,
        Parent = entry,
    })
    
    -- Тип пакета
    local typeColor = data.Type == "Incoming" and Theme.Green or Theme.Orange
    Library.CreateText({
        Text = data.Type or "???",
        Size = UDim2.fromOffset(70, 36),
        Position = UDim2.fromOffset(320, 0),
        Color = typeColor,
        TextSize = 11,
        Parent = entry,
    })
    
    -- Размер аргументов
    local argSize = data.ArgCount or 0
    Library.CreateText({
        Text = "Args: " .. argSize,
        Size = UDim2.fromOffset(80, 36),
        Position = UDim2.fromOffset(400, 0),
        Color = Theme.TextDim,
        TextSize = 11,
        Parent = entry,
    })
    
    -- Кнопка блокировки
    local blockBtn = Library.CreateButton({
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromOffset(760, 6),
        Text = "✕",
        Bg = Theme.Red,
        TextSize = 12,
        Parent = entry,
        OnClick = function()
            if rnet and rnet.blockSend and data.Remote then
                rnet.blockSend(data.Remote)
                entry.BackgroundColor3 = Theme.Red
                entry.BackgroundTransparency = 0.8
            end
        end,
    })
    
    -- Кнопка копирования
    local copyBtn = Library.CreateButton({
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromOffset(732, 6),
        Text = "📋",
        Bg = Theme.Accent,
        TextSize = 12,
        Parent = entry,
        OnClick = function()
            if data.Args then
                setclipboard(tostring(data.Args))
            end
        end,
    })
    
    -- Автоскролл вниз
    task.wait()
    list.CanvasPosition = Vector2.new(0, list.CanvasSize.Y.Offset + 40)
end

-- RakNet сниффер
local function StartRakNetSniffer()
    if not rnet then
        warn("RSPY: RakNet (rnet) не найден в этом экзекьюторе")
        StatusDot.BackgroundColor3 = Theme.Red
        return
    end
    
    StatusDot.BackgroundColor3 = Theme.Green
    
    -- Перехват отправки пакетов
    if rnet.hookSend then
        rnet.hookSend(function(remote, ...)
            if not packetSpyEnabled then return end
            
            packetCount.Total += 1
            packetCount.Outgoing += 1
            
            local data = {
                Name = tostring(remote),
                Type = "Outgoing",
                ArgCount = select("#", ...),
                Args = {...},
                Remote = remote,
                Time = DateTime.now():ToIsoDate(),
            }
            
            AddPacketEntry(PacketList, data)
            AddPacketEntry(OutgoingList, data)
            
            -- Обновление счетчика
            PacketCountText.Text = string.format(
                "Packets: %d | Incoming: %d | Outgoing: %d",
                packetCount.Total,
                packetCount.Incoming,
                packetCount.Outgoing
            )
        end)
    end
    
    -- Перехват получения пакетов
    if rnet.hookReceive then
        rnet.hookReceive(function(remote, ...)
            if not packetSpyEnabled then return end
            
            packetCount.Total += 1
            packetCount.Incoming += 1
            
            local data = {
                Name = tostring(remote),
                Type = "Incoming",
                ArgCount = select("#", ...),
                Args = {...},
                Remote = remote,
                Time = DateTime.now():ToIsoDate(),
            }
            
            AddPacketEntry(PacketList, data)
            AddPacketEntry(IncomingList, data)
            
            PacketCountText.Text = string.format(
                "Packets: %d | Incoming: %d | Outgoing: %d",
                packetCount.Total,
                packetCount.Incoming,
                packetCount.Outgoing
            )
        end)
    end
    
    -- Fire/Invoke hooks если rnet не поддерживает hookSend/hookReceive
    if not rnet.hookSend and not rnet.hookReceive then
        -- Hook через RemoteEvent / RemoteFunction
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            if not packetSpyEnabled then return oldNamecall(self, ...) end
            
            local method = getnamecallmethod()
            local isRemote = self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self:IsA("UnreliableRemoteEvent")
            
            if isRemote and (method == "FireServer" or method == "InvokeServer") then
                packetCount.Total += 1
                packetCount.Outgoing += 1
                
                local data = {
                    Name = self.ClassName .. " :: " .. self.Name,
                    Type = "Outgoing",
                    ArgCount = select("#", ...),
                    Args = {...},
                    Remote = self,
                    Time = DateTime.now():ToIsoDate(),
                }
                
                AddPacketEntry(PacketList, data)
                AddPacketEntry(OutgoingList, data)
                
                PacketCountText.Text = string.format(
                    "Packets: %d | Incoming: %d | Outgoing: %d",
                    packetCount.Total,
                    packetCount.Incoming,
                    packetCount.Outgoing
                )
            end
            
            return oldNamecall(self, ...)
        end)
        
        -- Hook OnClientEvent для входящих
        local connections = {}
        local function HookIncoming(remote)
            if connections[remote] then return end
            if remote.ClassName ~= "RemoteEvent" and remote.ClassName ~= "UnreliableRemoteEvent" then return end
            
            local connection
            connection = remote.OnClientEvent:Connect(function(...)
                if not packetSpyEnabled then return end
                
                packetCount.Total += 1
                packetCount.Incoming += 1
                
                local data = {
                    Name = remote.ClassName .. " :: " .. remote.Name,
                    Type = "Incoming",
                    ArgCount = select("#", ...),
                    Args = {...},
                    Remote = remote,
                    Time = DateTime.now():ToIsoDate(),
                }
                
                AddPacketEntry(PacketList, data)
                AddPacketEntry(IncomingList, data)
                
                PacketCountText.Text = string.format(
                    "Packets: %d | Incoming: %d | Outgoing: %d",
                    packetCount.Total,
                    packetCount.Incoming,
                    packetCount.Outgoing
                )
            end)
            connections[remote] = connection
        end
        
        -- Перехватываем новые RemoteEvent
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, index)
            local result = oldIndex(self, index)
            if type(result) == "Instance" and (result:IsA("RemoteEvent") or result:IsA("UnreliableRemoteEvent")) then
                if not connections[result] then
                    task.spawn(HookIncoming, result)
                end
            end
            return result
        end)
        
        -- Хукаем уже существующие
        for _, v in pairs(getconnections) do
            -- Недоступно в некоторых executor, пропускаем
        end
        
        for _, remote in ipairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
                task.spawn(HookIncoming, remote)
            end
        end
    end
end

-- Фильтр поиска
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = SearchBox.Text:lower()
    
    for _, entry in ipairs(PacketList:GetChildren()) do
        if entry:IsA("Frame") then
            local nameLabel = entry:FindFirstChildOfClass("TextLabel")
            if nameLabel then
                entry.Visible = searchText == "" or nameLabel.Text:lower():find(searchText) ~= nil
            end
        end
    end
end)

-- Запуск
task.spawn(StartRakNetSniffer)

-- Уведомление о загрузке
Library.CreateText({
    Text = "✓ RSPY v2.0 загружен. Используется RakNet: " .. tostring(rnet and true or false),
    Size = UDim2.fromOffset(400, 20),
    Position = UDim2.fromOffset(12, 536),
    Color = Theme.Green,
    TextSize = 11,
    Parent = MainWindow,
})

print("RSPY v2.0 — Remote Spy Pro loaded successfully")
print("Design: Cobalt-style | Author: для Medium Executor")
