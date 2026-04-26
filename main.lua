local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Window = OrionLib:MakeWindow({Name = "An hub", HidePremium = false, SaveConfig = true, ConfigFolder = "AnHubConfig"})

-- --- 設定用グローバル変数 ---
_G.ReleasePower = 100
_G.AuraRange = 25
_G.AntiRange = 15
_G.StopOnRelease = false
_G.IsGrabbing = false
_G.GrabbedTarget = nil
_G.TargetMode = "Closest"
_G.PostReleaseAction = "None"
_G.IyanAnti = false
_G.KickAura = false
_G.SilentAim = false
_G.OrbitEnabled = false
_G.GlitchAura = false
_G.WingEnabled = false
_G.MagicCircleEnabled = false
_G.GhostFling = false
_G.AutoBringBack = false

-- --- 共通：ターゲット取得ロジック ---
local function getTarget()
    local lp = game.Players.LocalPlayer
    local mouse = lp:GetMouse()
    if _G.TargetMode == "Mouse" then
        return mouse.Target and (mouse.Target.Parent:FindFirstChild("HumanoidRootPart") or mouse.Target)
    elseif _G.TargetMode == "Closest" then
        local target, dist = nil, math.huge
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local d = (v.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then target = v.Character.HumanoidRootPart; dist = d end
            end
        end
        return target
    end
end

-- --- 1. Main：精密飛ばし & 操作 ---
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
MainTab:AddSection({Name = "ターゲット選択"})
MainTab:AddDropdown({Name = "取得モード", Default = "Closest", Options = {"Closest", "Mouse"}, Callback = function(v) _G.TargetMode = v end})

MainTab:AddSection({Name = "射出・飛ばし操作"})
MainTab:AddToggle({
    Name = "対象を掴む (Grab & Release)",
    Default = false,
    Callback = function(v)
        _G.IsGrabbing = v
        if not v and _G.GrabbedTarget then
            local target = _G.GrabbedTarget
            if _G.StopOnRelease then
                target.Velocity = Vector3.new(0,0,0); target.Anchored = true
            else
                local force = _G.ReleasePower * 150
                target.Velocity = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * force + Vector3.new(0, force, 0)
                if _G.PostReleaseAction == "Explosion" then Instance.new("Explosion", workspace).Position = target.Position end
            end
            _G.GrabbedTarget = nil
        else _G.GrabbedTarget = getTarget() end
    end
})
MainTab:AddSlider({Name = "射出威力 (1-500)", Min = 1, Max = 500, Default = 100, Increment = 1, ValueName = "Power", Callback = function(v) _G.ReleasePower = v end})
MainTab:AddToggle({Name = "離した位置で固定 (Anchor)", Default = false, Callback = function(v) _G.StopOnRelease = v end})
MainTab:AddButton({Name = "ターゲットへテレポート", Callback = function() local t = getTarget() if t then game.Players.LocalPlayer.Character:PivotTo(t.CFrame * CFrame.new(0,5,0)) end end})

-- --- 2. aura：自動・広域排除 ---
local AuraTab = Window:MakeTab({Name = "aura", Icon = "rbxassetid://4483345998"})
AuraTab:AddToggle({Name = "衛星バリア (Orbit Aura)", Default = false, Callback = function(v) _G.OrbitEnabled = v end})
AuraTab:AddToggle({Name = "超高圧バグ射出 (Glitch Fling)", Default = false, Callback = function(v) _G.GlitchAura = v end})
AuraTab:AddToggle({Name = "キックオーラ (叩きつけ)", Default = false, Callback = function(v) _G.KickAura = v end})
AuraTab:AddSlider({Name = "オーラ範囲", Min = 5, Max = 100, Default = 25, Increment = 5, ValueName = "Studs", Callback = function(v) _G.AuraRange = v end})

-- --- 3. silent aim：追尾飛ばし ---
local SilentTab = Window:MakeTab({Name = "silent aim", Icon = "rbxassetid://4483345998"})
SilentTab:AddToggle({Name = "自動追尾フリング", Default = false, Callback = function(v) _G.SilentAim = v end})

-- --- 4. Anti：いやんはぶ防御 ---
local AntiTab = Window:MakeTab({Name = "Anti", Icon = "rbxassetid://4483345998"})
AntiTab:AddToggle({Name = "いやんはぶ式：絶対防御", Default = false, Callback = function(v) _G.IyanAnti = v end})

-- --- 5. Wing & 6. 魔法陣：装備飛ばし ---
local WingTab = Window:MakeTab({Name = "Wing", Icon = "rbxassetid://4483345998"})
WingTab:AddToggle({Name = "翼装着 (接触飛ばし)", Default = false, Callback = function(v) _G.WingEnabled = v end})

local MagicTab = Window:MakeTab({Name = "魔法陣", Icon = "rbxassetid://4483345998"})
MagicTab:AddToggle({Name = "ハート魔法陣 (接触飛ばし)", Default = false, Callback = function(v) _G.MagicCircleEnabled = v end})

-- --- 7. Marin：特殊・一斉排除 ---
local MarinTab = Window:MakeTab({Name = "Marin", Icon = "rbxassetid://4483345998"})
MarinTab:AddButton({Name = "全方位壊滅津波 (Tsunami)", Callback = function() 
    local myHrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            p.Character.HumanoidRootPart.Velocity = (p.Character.HumanoidRootPart.Position - myHrp.Position).Unit * 20000
        end
    end
end})
MarinTab:AddButton({Name = "天界強制固定 (Sky Eraser)", Callback = function() 
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            p.Character.HumanoidRootPart.CFrame = CFrame.new(p.Character.HumanoidRootPart.Position.X, 10000, p.Character.HumanoidRootPart.Position.Z)
            p.Character.HumanoidRootPart.Anchored = true
        end
    end
end})

-- --- 8. miss：証拠隠滅・逃走 ---
local MissTab = Window:MakeTab({Name = "miss", Icon = "rbxassetid://4483345998"})
MissTab:AddToggle({Name = "ゴースト・フリング (半透明)", Default = false, Callback = function(v) _G.GhostFling = v end})
MissTab:AddToggle({Name = "無限ループ (Bring Back)", Default = false, Callback = function(v) _G.AutoBringBack = v end})
MissTab:AddButton({Name = "高速サーバー移動", Callback = function() 
    local Servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, s in pairs(Servers.data) do if s.playing < s.maxPlayers and s.id ~= game.JobId then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id) break end end
end})

-- --- 全統合アップデートループ ---
task.spawn(function()
    while true do
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local tool = char and char:FindFirstChildOfClass("Tool")
        local handle = tool and tool:FindFirstChild("Handle")

        if hrp then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local th = p.Character.HumanoidRootPart
                    local dist = (th.Position - hrp.Position).Magnitude
                    if dist < _G.AuraRange then
                        if _G.SilentAim then th.Velocity = Vector3.new(0, 1500, 0) end
                        if _G.OrbitEnabled then th.CFrame = hrp.CFrame * CFrame.new(math.cos(tick()*15)*12, 2, math.sin(tick()*15)*12); th.Velocity = Vector3.new(0,0,0) end
                        if _G.GlitchAura then th.Velocity = Vector3.new(math.random(-1e7, 1e7), 1e6, math.random(-1e7, 1e7)) end
                        if _G.KickAura then th.Velocity = Vector3.new(0, 400, 0); task.wait(0.1); th.Velocity = Vector3.new(0, -1000, 0) end
                    end
                end
            end
            if _G.IyanAnti then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
                        if (obj.Position - hrp.Position).Magnitude < _G.AntiRange then obj.Velocity = Vector3.new(0,0,0); obj.RotVelocity = Vector3.new(0,0,0) end
                    end
                end
            end
            if _G.IsGrabbing and _G.GrabbedTarget then
                _G.GrabbedTarget.CFrame = hrp.CFrame * CFrame.new(0, 0, -10); _G.GrabbedTarget.Velocity = Vector3.new(0,0,0)
            end
            if _G.AutoBringBack and _G.GrabbedTarget and (_G.GrabbedTarget.Position - hrp.Position).Magnitude > 120 then
                _G.GrabbedTarget.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
            end
            if handle then
                handle.CanTouch = true
                if _G.MagicCircleEnabled then
                    local t = tick(); handle.CFrame = hrp.CFrame * CFrame.new(16*math.sin(t)^3 * 0.5, 0, -(13*math.cos(t)-5*math.cos(2*t)-2*math.cos(3*t)-math.cos(4*t)) * 0.5)
                elseif _G.WingEnabled then
                    handle.CFrame = hrp.CFrame * CFrame.new(0, 2, 1) * CFrame.Angles(0, 0, math.sin(tick()*5))
                end
            end
        end
        task.wait()
    end
end)

OrionLib:Init()

