local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlaceId = game.PlaceId
local JobIdAtual = game.JobId

local function hopServer()
    local cursor = ""
    local encontrado = false

    while not encontrado do
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
        local response = HttpService:JSONDecode(game:HttpGet(url))

        for _, server in pairs(response.data) do
            if server.playing < server.maxPlayers and server.id ~= JobIdAtual then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                encontrado = true
                break
            end
        end

        cursor = response.nextPageCursor or ""
        if cursor == "" then break end
        wait(0.5)
    end
end

local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local FOVValues = {100, 180, 360}
local PrecisionValues = {1.1, 3.3, 106}
local AimSettings = {
    Aimbot = false,
    AimAssist = false,
    AimLock = false,
    FOVLevel = 2,
    PrecisionLevel = 2
}

local function GetClosestTarget()
    local closest = nil
    local shortest = FOVValues[AimSettings.FOVLevel]

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer 
--        and player.Team ~= LocalPlayer.Team -- ✅ Ignora aliados
        and player.Character 
        and player.Character:FindFirstChild("Head") then

            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)

                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = player
                    end
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    if AimSettings.Aimbot then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            local camPos = Camera.CFrame.Position

            if AimSettings.AimLock then
                Camera.CFrame = CFrame.new(camPos, headPos)
            elseif AimSettings.AimAssist then
                local strength = PrecisionValues[AimSettings.PrecisionLevel]
                Camera.CFrame = Camera.CFrame:lerp(CFrame.new(camPos, headPos), strength)
            end
        end
    end
end)

local function patchTool(tool)
    local ammoVars = {"Ammo", "AmmoCount", "TotalAmmo", "Bullets", "ReserveAmmo"}
    local clipVars = {"Clip", "ClipSize", "Magazine", "CurrentClip", "LoadedAmmo"}
    local reloadVars = {"Reloading", "IsReloading", "CanReload"}
    local fireRateVars = {"FireRate", "Cooldown", "ShootDelay"}

    for _, name in pairs(ammoVars) do
        local val = tool:FindFirstChild(name)
        if val and val:IsA("NumberValue") then
            val.Value = math.huge
        end
    end

    for _, name in pairs(clipVars) do
        local val = tool:FindFirstChild(name)
        if val and val:IsA("NumberValue") then
            val.Value = math.huge
        end
    end

    for _, name in pairs(reloadVars) do
        local val = tool:FindFirstChild(name)
        if val and val:IsA("BoolValue") then
            val.Value = false
        end
    end

    for _, name in pairs(fireRateVars) do
        local val = tool:FindFirstChild(name)
        if val and val:IsA("NumberValue") then
            val.Value = 0.01 -- Disparo rápido
        end
    end
end

local function applyInfiniteAmmo()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        patchTool(tool)
    end

    for _, tool in pairs(character:GetChildren()) do
        patchTool(tool)
    end

    -- Detecta novas armas adicionadas
    LocalPlayer.Backpack.ChildAdded:Connect(patchTool)
    character.ChildAdded:Connect(patchTool)
end

applyInfiniteAmmo()
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    applyInfiniteAmmo()
end)

-- Estados
local MovementSettings = {
    InfiniteJump = false,
    InfiniteDash = false
}

-- Infinity Jump
UserInputService.JumpRequest:Connect(function()
    if MovementSettings.InfiniteJump then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Infinity Dash
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if MovementSettings.InfiniteDash and input.KeyCode == Enum.KeyCode.LeftShift then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local root = character.HumanoidRootPart
            local direction = root.CFrame.LookVector
            local startTime = tick()

            local dashConnection
            dashConnection = RunService.RenderStepped:Connect(function()
                if tick() - startTime < 0.2 then
                    root.Velocity = direction * 100
                else
                    dashConnection:Disconnect()
                end
            end)
        end
    end
end)



local Window = Rayfield:CreateWindow({
   Name = "Sxg Hub",
   Icon = 0, -- Ícone na barra superior. É possível usar ícones do Lucide (string) ou imagem do Roblox (número). 0 para não usar nenhum ícone (padrão).
   LoadingTitle = "espera cabaço.",
   LoadingSubtitle = "by Gusxtyz Scripted",
   ShowText = "Rayfield", -- para usuários móveis exibirem o rayfield, altere se desejar
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- A combinação de teclas para alternar a visibilidade da interface do usuário (string como "K" ou Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Evita que o Rayfield avise quando o script tiver uma incompatibilidade de versão com a interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Crie uma pasta personalizada para seu hub/jogo
      FileName = "SxgHub.txt"
   },

   Discord = {
      Enabled = false, -- Peça ao usuário para ingressar no seu servidor Discord se o executor dele oferecer suporte a isso
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Defina como falso para que eles entrem no Discord sempre que o carregarem
   },

   KeySystem = true, -- Defina como verdadeiro para usar nosso sistema de chaves
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "Nenhum método para obter a chave é fornecido", -- Use isto para informar ao usuário como obter uma chave
      FileName = "Key", -- É recomendado usar algo único, pois outros scripts que usam Rayfield podem sobrescrever seu arquivo de chave
      SaveKey = true, -- A chave do usuário será salva, mas se você alterá-la, ele não poderá usar seu script
      GrabKeyFromSite = false, -- Se isso for verdade, defina a chave abaixo para o site RAW do qual você gostaria que Rayfield obtivesse a chave
      Key = {"Gusxtyz"} -- Lista de chaves que serão aceitas pelo sistema, podem ser links de arquivos RAW (pastebin, github etc.) ou strings simples ("hello", "key22")
   }
})

local Tab = Window:CreateTab("Main", 4483362458) -- Title, Image
local Section = Tab:CreateSection("Xitar no talo, ative tudo.")

Tab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Flag = "AimbotFlag",
   Callback = function(Value)
      AimSettings.Aimbot = Value
   end,
})

Tab:CreateToggle({
   Name = "AimAssist",
   CurrentValue = false,
   Flag = "AimAssistFlag",
   Callback = function(Value)
      AimSettings.AimAssist = Value
   end,
})

Tab:CreateToggle({
   Name = "AimLock",
   CurrentValue = false,
   Flag = "AimLockFlag",
   Callback = function(Value)
      AimSettings.AimLock = Value
   end,
})

Tab:CreateButton({
   Name = "FOV: MIN/MED/MAX",
   Callback = function()
      AimSettings.FOVLevel = (AimSettings.FOVLevel % 3) + 1
      Rayfield:Notify({
         Title = "FOV",
         Content = "FOV ajustado para nível " .. AimSettings.FOVLevel,
         Duration = 2
      })
   end,
})

Tab:CreateButton({
   Name = "Precisão: MIN/MED/MAX",
   Callback = function()
      AimSettings.PrecisionLevel = (AimSettings.PrecisionLevel % 3) + 1
      Rayfield:Notify({
         Title = "Precisão",
         Content = "Precisão ajustada para nível " .. AimSettings.PrecisionLevel,
         Duration = 2
      })
   end,
})

Tab:CreateToggle({
   Name = "FireRate Boost",
   CurrentValue = false,
   Flag = "FireRateFlag",
   Callback = function(Value)
      if Value then
         for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FireRate") then
               tool.FireRate.Value = math.max(tool.FireRate.Value * 0.5, 0.1)
            end
         end
      end
   end,
})


RunService.RenderStepped:Connect(function()
    if getgenv().NoRecoil then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Recoil") then
                tool.Recoil.Value = 0
            end
        end
    end
end)

Tab:CreateToggle({
   Name = "No-Recoil",
   CurrentValue = false,
   Flag = "NoRecoilFlag",
   Callback = function(Value)
      getgenv().NoRecoil = Value
   end,
})


local Tab = Window:CreateTab("Vantagens", 4483362458) -- Title, Image
local Section = Tab:CreateSection("Vantagens")

-- Estado da mira
local CrosshairSettings = {
    Enabled = false,
    Size = 50
}

-- Configuração
local SpeedSettings = {
    TargetSpeed = 16,
    CurrentSpeed = 16
}

-- Função para aplicar velocidade suavemente
local function updateSpeed()
    local character = LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        humanoid.WalkSpeed = SpeedSettings.CurrentSpeed
    end
end

-- Loop de aceleração progressiva
RunService.RenderStepped:Connect(function()
    if SpeedSettings.CurrentSpeed ~= SpeedSettings.TargetSpeed then
        local diff = SpeedSettings.TargetSpeed - SpeedSettings.CurrentSpeed
        SpeedSettings.CurrentSpeed += diff * 0.1 -- suaviza a transição
        updateSpeed()
    end
end)

-- Atualiza após respawn
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    SpeedSettings.CurrentSpeed = SpeedSettings.TargetSpeed
    updateSpeed()
end)

local Toggle = Tab:CreateToggle({
    Name = "Esp",
    CurrentValue = false,
    Flag = "EspToggle",
    Callback = function(Value)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local highlights = {}
        local connections = {}

        local function applyESP(player)
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
                highlights[player] = highlight
            end
        end

        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                applyESP(player)

                -- Conecta ao evento CharacterAdded para reaplicar ESP
                local conn = player.CharacterAdded:Connect(function()
                    task.wait(1) -- espera o personagem carregar
                    applyESP(player)
                end)
                connections[player] = conn
            end
        else
            -- Remove os highlights
            for _, highlight in pairs(highlights) do
                if highlight then
                    highlight:Destroy()
                end
            end
            highlights = {}

            -- Desconecta os eventos
            for _, conn in pairs(connections) do
                if conn then
                    conn:Disconnect()
                end
            end
            connections = {}
        end
    end,
})

Tab:CreateToggle({
   Name = "🔫 Munição Infinita",
   CurrentValue = false,
   Flag = "InfiniteAmmoFlag",
   Callback = function(Value)
      if Value then
         applyInfiniteAmmo()
      end
   end,
})

-- Toggle: Infinity Jump
Tab:CreateToggle({
   Name = "🦘 Infinity Jump",
   CurrentValue = false,
   Flag = "InfiniteJumpFlag",
   Callback = function(Value)
      MovementSettings.InfiniteJump = Value
   end,
})

-- Toggle: Infinity Dash
Tab:CreateToggle({
   Name = "⚡ Infinity Dash",
   CurrentValue = false,
   Flag = "InfiniteDashFlag",
   Callback = function(Value)
      MovementSettings.InfiniteDash = Value
   end,
})

-- Slider Rayfield
Tab:CreateSlider({
    Name = "🏃 Velocidade Progressiva",
    Range = {0, 300},
    Increment = 1,
    Suffix = "Vel",
    CurrentValue = 16,
    Flag = "SpeedSliderFlag",
    Callback = function(Value)
        SpeedSettings.TargetSpeed = Value
    end,
})
-- teste walkspeed
-- teste walkspeed
Tab:CreateSlider({
    Name = "WalkSpeed",
    Range = {0, 100}, -- ✅ Corrigido
    Increment = 10,
    Suffix = "WalkSpeed",
    CurrentValue = 20,
    Flag = "WalkSpeed",
    Callback = function (Value)
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end -- ✅ Fechando corretamente a função
})




local Tab = Window:CreateTab("Visual", 4483362458) -- Aba Visual
local Section = Tab:CreateSection("Mira")


-- Estado da mira
local CrosshairSettings = {
    Enabled = false,
    Size = 50,
    Thickness = 2
}

-- Criar GUI da mira
local crosshairGui = Instance.new("ScreenGui")
crosshairGui.Name = "CustomCrosshairGui"
crosshairGui.ResetOnSpawn = false
crosshairGui.IgnoreGuiInset = true
crosshairGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Criar a bolinha com borda fina
local crosshair = Instance.new("Frame")
crosshair.Name = "RingCrosshair"
crosshair.Size = UDim2.new(0, CrosshairSettings.Size, 0, CrosshairSettings.Size)
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundTransparency = 1
crosshair.Visible = false
crosshair.ZIndex = 9999
crosshair.Parent = crosshairGui

-- Deixa redondo
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = crosshair

-- Adiciona borda fina
local stroke = Instance.new("UIStroke")
stroke.Thickness = CrosshairSettings.Thickness
stroke.Color = Color3.new(1, 1, 1)
stroke.Transparency = 0.2
stroke.Parent = crosshair

-- Toggle para ativar/desativar
Tab:CreateToggle({
   Name = "🎯 Ativar Mira Estilo Anel",
   CurrentValue = false,
   Flag = "RingCrosshairToggle",
   Callback = function(Value)
      CrosshairSettings.Enabled = Value
      crosshair.Visible = Value
   end,
})

-- Slider para ajustar tamanho
Tab:CreateSlider({
    Name = "📏 Tamanho da Mira",
    Range = {10, 300},
    Increment = 1,
    Suffix = "px",
    CurrentValue = 50,
    Flag = "RingCrosshairSizeSlider",
    Callback = function(Value)
        CrosshairSettings.Size = Value
        crosshair.Size = UDim2.new(0, Value, 0, Value)
    end,
})

local Tab = Window:CreateTab("Servidor", 4483362458)
local Section = Tab:CreateSection("Mudar de servidor.")
Tab:CreateButton({
   Name = "🔁 Trocar de Servidor",
   Callback = function()
      hopServer()
   end,
})

local Tab = Window:CreateTab("Jogadores", 4483362458)
local Section = Tab:CreateSection("TP e ESP")

-- Estado do ESP
local ESPSettings = {
    Enabled = false,
    Labels = {}
}

-- Função para limpar ESP
local function clearESP()
    for _, label in pairs(ESPSettings.Labels) do
        if label and label.Parent then
            label:Destroy()
        end
    end
    ESPSettings.Labels = {}
end

-- Função para criar ESP
local function createESP()
    clearESP()
    if not ESPSettings.Enabled then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") then
            if plr.Character.Humanoid.Health > 0 then
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = plr.Character.Head
                billboard.Size = UDim2.new(0, 100, 0, 20)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = plr.Character.Head

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = plr.Name
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.TextStrokeTransparency = 0.5
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.Parent = billboard

                table.insert(ESPSettings.Labels, billboard)
            end
        end
    end
end

-- Variável do jogador selecionado
local selectedPlayer = nil
local dropdownObject = nil

-- Função para coletar jogadores vivos
local function getJogadoresVivos()
    local vivos = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            if plr.Character.Humanoid.Health > 0 then
                table.insert(vivos, plr.Name)
            end
        end
    end
    return vivos
end

-- teste de Destroy 

if typeof(dropdownObject) == "Instance" and dropdownObject.Destroy then
    dropdownObject:Destroy()
end

-- Função para criar/recriar o dropdown
local function criarDropdown()
    local vivos = getJogadoresVivos()
    if dropdownObject then
        dropdownObject:Destroy()
    end

    dropdownObject = Tab:CreateDropdown({
        Name = "🎯 Escolher jogador para TP",
        Options = vivos,
        CurrentOption = "",
            Callback = function(Value)
    selectedPlayer = Value
    print("SelectedPlayer:", selectedPlayer)
     end
 })
 end

-- Botão para atualizar lista
Tab:CreateButton({
    Name = "🔄 Atualizar lista de jogadores",
    Callback = function()
        criarDropdown()
    end,
})

-- botão de teleporte para jogador selecionado
Tab:CreateButton({
    Name = "Teleportar para jogador",
    Callback = function()
        if selectedPlayer and selectedPlayer ~= "" then
        if typeof(selectedPlayer) ~= "string" then
    print("Erro: selectedPlayer não é uma string")
    return
end
            local targetPlayer = game.Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)
                local myChar = game.Players.LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    myChar.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                    print("Teleportado para", targetPlayer.Name)
                else
                    print("Seu personagem não tem HumanoidRootPart")
                end
            else
                print("Jogador inválido ou sem HumanoidRootPart")
            end
        else
            print("Nenhum jogador selecionado")
        end
    end
})

-- Cria o dropdown inicial ao abrir
criarDropdown()

-- Toggle Rayfield
Tab:CreateToggle({
   Name = "🕵️ Ativar ESP de Nome",
   CurrentValue = false,
   Flag = "ESPNameToggle",
   Callback = function(Value)
      ESPSettings.Enabled = Value
      if not Value then
         clearESP()
      else
         createESP()
      end
   end,
})

-- Atualiza ESP a cada 5 segundos
RunService.RenderStepped:Connect(function()
    if ESPSettings.Enabled then
        createESP()
    end
    wait(5)
end)
