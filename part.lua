local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local friendsList = {}
local aimbotEnabled = false
local autoAttackEnabled = false
local espEnabled = false
local killAuraEnabled = false
local killAuraMode = "Behind"
local attackMultipleTargets = false
local aimbotRange = 50
local aimbotSmoothness = 0.2
local attackCooldown = 0.1
local spawnProtectionTime = 5
local killAuraRange = 15
local teleportCooldown = 2
local multiTargetTeleportCooldown = 1
local strafeSpeed = 2
local strafeDistance = 5
local attackDamage = 10
local targetStrafeEnabled = false
local smartStrafeEnabled = false
local noclipEnabled = false
local noclipSpeed = 14
local playerSpawnTimes = {}
local espHighlights = {}
local lastAimbotAttackTime = 0
local lastTeleportTime = 0
local lastMultiTargetTeleportTime = 0
local lastAttackTime = 0
local currentTarget = nil
local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.fromRGB(255, 165, 0)
highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
local fakeLagEnabled = false
local fakeLagMode = "Automatic" -- Default mode: "Keybind" or "Automatic"
local fakeLagInterval = 2 -- Renamed from noclipCd for clarity
local lastFakeLagUpdate = 0
local frozenCFrame = nil

local function removeAnticheat2(character)
    if not character then return end
    local anticheat = character:FindFirstChild("Anticheat2")
    if anticheat then
        anticheat:Destroy()
        print("Anticheat2 removed from character.")
    else
        for _, descendant in pairs(character:GetDescendants()) do
            if descendant.Name == "Anticheat2" then
                descendant:Destroy()
                print("Anticheat2 removed from character (descendant).")
            end
        end
    end
end

local function monitorAnticheat2(character)
    if not character then return end
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not character.Parent then
            connection:Disconnect()
            return
        end
        removeAnticheat2(character)
    end)
end

Players.LocalPlayer.CharacterAdded:Connect(function(character)
    print("Character spawned, checking for Anticheat2.")
    removeAnticheat2(character)
    monitorAnticheat2(character)
end)

if Players.LocalPlayer.Character then
    print("Initial character check for Anticheat2.")
    removeAnticheat2(Players.LocalPlayer.Character)
    monitorAnticheat2(Players.LocalPlayer.Character)
end

local success, RunMode = pcall(function()
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if Remotes then
        return Remotes:FindFirstChild("RunMode")
    end
    return nil
end)

if success and RunMode then
    RunMode:Destroy()
    print("RunMode destroyed successfully.")
else
    print("RunMode or Remotes not found, skipping destruction.")
end

local success, library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Rain-Design/Libraries/main/Revenant.lua"))()
end)
if not success then
    warn("Failed to load UI library: " .. tostring(library))
    return
end

local CombatWindow = library:Window({Text = "Combat"})
local MovementWindow = library:Window({Text = "Movement"})
local RenderWindow = library:Window({Text = "Render"})
local PlayerWindow = library:Window({Text = "Player"})
local MiscWindow = library:Window({Text = "Misc"})

local function isFriend(player)
    return table.find(friendsList, player.Name) ~= nil
end

local function findPlayerByPartialName(partialName)
    partialName = partialName:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(partialName) then
            return player
        end
    end
    return nil
end

Players.LocalPlayer.Chatted:Connect(function(message)
    local args = message:split(" ")
    if args[1] == ".friend" then
        if args[2] == "add" and args[3] then
            local targetName = args[3]
            local targetPlayer = findPlayerByPartialName(targetName)
            if targetPlayer then
                if not isFriend(targetPlayer) then
                    table.insert(friendsList, targetPlayer.Name)
                    Players.LocalPlayer:WaitForChild("StarterGui"):SetCore("SendNotification", {
                        Title = "Friend System",
                        Text = targetPlayer.Name .. " added to friends!",
                        Duration = 3
                    })
                else
                    Players.LocalPlayer:WaitForChild("StarterGui"):SetCore("SendNotification", {
                        Title = "Friend System",
                        Text = targetPlayer.Name .. " is already your friend!",
                        Duration = 3
                    })
                end
            else
                Players.LocalPlayer:WaitForChild("StarterGui"):SetCore("SendNotificatio