-- Square Piece 2
-- Variables
local Players           = game:GetService("Players")
local LocalPlayer       = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Sort
local function Sort(Table)
    table.sort(Table, function(a,b)
        return a:lower() < b:lower()
    end)
    return Table
end
-- Repository
local Repository = "https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/"
-- Library | Themes | Saves
local Library      = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repository .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
-- Window
local Window = Library:CreateWindow({
    Title    = "Square Piece 2",
    Center   = true, 
    AutoShow = true,
})
-- Tabs
local Tabs = {
    ["Main"]        = Window:AddTab("Main"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}
-- Dupe
local Dupe = Tabs["Main"]:AddLeftGroupbox("Dupe")
-- Auto Drop
Dupe:AddToggle("AutoDrop", {
    Text = "Auto Drop",
    Default = false,
    Tooltip = "Automatically Drop Your Equipped Item",
})
-- Auto Pickup
Dupe:AddToggle("AutoPickup", {
    Text = "Auto Pickup",
    Default = false,
    Tooltip = "Automatically Picks Up Items From The Selected Player",
})
-- Auto Pickup Player
Dupe:AddDropdown("AutoPickupPlayerDropdown", {
    Values = {},
    Default = 0,
    Multi = false,
    Text = "Select Player",
    Tooltip = "Select Player To Pick Up Items From",
    AllowNull = true
})
-- Data Rollback
local DataRollback = Dupe:AddButton("Data Rollback", function()
    ReplicatedStorage.Rex.Remotes["PlayerModule.ChangeSetting"]:InvokeServer("Interface", "General", "TextFont", "\225")
    task.wait(3)
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)
-- Rejoin
local Rejoin = Dupe:AddButton("Rejoin", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)
-- Farming
local Farming = Tabs["Main"]:AddRightGroupbox("Farming")
-- Auto Use Item
Farming:AddToggle("AutoUseItem", {
    Text = "Auto Use Item",
    Default = false,
    Tooltip = "Automatically Uses Equipped Item",
})
-- Set Mob
Farming:AddInput("SetMob", {
    Default = "",
    Numeric = false,
    Finished = false,
    Text = "Set Mob",
    Tooltip = "Sets The Mob",
    Placeholder = "Mob Name Here!",
})
-- Bring Mob
local BringMob = Farming:AddButton("Bring Mob", function()
    local Position = LocalPlayer.Character.HumanoidRootPart.CFrame
    for _, Mob in pairs(Workspace.Entities:GetChildren()) do
        if Mob.Name == Options["SetMob"].Value then
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = Mob.HumanoidRootPart.CFrame
                wait(0.5)
                Mob.HumanoidRootPart.CFrame = Position
            end)
        end
    end
    LocalPlayer.Character.HumanoidRootPart.CFrame = Position
end)
-- Anchor Mob
local AnchorMob = Farming:AddButton("Anchor Mob", function()
    for _, Mob in pairs(Workspace.Entities:GetChildren()) do
        if Mob.Name == Options["SetMob"].Value then
            pcall(function()
                Mob.HumanoidRootPart.Anchored = true
            end)
        end
    end
end)
-- Unanchor Mob
local UnanchorMob = Farming:AddButton("Unanchor Mob", function()
    for _, Mob in pairs(Workspace.Entities:GetChildren()) do
        if Mob.Name == Options["SetMob"].Value then
            pcall(function()
                Mob.HumanoidRootPart.Anchored = false
            end)
        end
    end
end)
-- Library functions
Library:OnUnload(function()
    print("Unloaded!")
    Library.Unloaded = true
end)
-- UI Settings
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "LeftAlt", NoUI = true, Text = "Menu keybind" }) 
Library.ToggleKeybind = Options.MenuKeybind
-- Themes | Saves
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
-- Saves
SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({ "MenuKeybind" }) 
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:BuildConfigSection(Tabs["UI Settings"]) 
-- Themes
ThemeManager:ApplyToTab(Tabs["UI Settings"]) 
-- Auto Pickup | Toggle
Toggles["AutoPickup"]:OnChanged(function()
    task.spawn(function()
        while Toggles["AutoPickup"].Value do task.wait()
            for i,v in pairs(Workspace.Drops:GetChildren()) do
                if type(Options["AutoPickupPlayerDropdown"].Value) == "string" and string.match(v.Name, Options["AutoPickupPlayerDropdown"].Value) then
                    pcall(function()
                        ReplicatedStorage.Rex.Remotes["ActionModule.TakeItemFromLootbag"]:InvokeServer(v, v.Lootbag.Drops["1"])
                    end)
                end
            end
        end
    end)
end)
-- Auto Drop | Toggle
Toggles["AutoDrop"]:OnChanged(function()
    task.spawn(function()
        while Toggles["AutoDrop"].Value do task.wait()
            ReplicatedStorage.Rex.Remotes["ActionModule.DropEquipped"]:InvokeServer()
        end
    end)
end)
-- Auto Use Item | Toggle
Toggles["AutoUseItem"]:OnChanged(function()
    task.spawn(function()
        while Toggles["AutoUseItem"].Value do task.wait()
            ReplicatedStorage.Rex.Remotes["ActionModule.UseItem"]:InvokeServer(LocalPlayer)
        end
    end)
end)
-- Refresh Players
function RefreshPlayers()
    local PlayerList = {}
    for i,v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            table.insert(PlayerList, v.Name)
        end
    end
    for i,v in pairs(Options) do
        if string.match(i, "PlayerDropdown") then
            v.Values = Sort(PlayerList)
	        v:SetValues()
            if typeof(v.Value) == "table" then
                for Selection,_ in pairs(v.Value) do
                    if table.find(PlayerList, Selection) then continue else
                        table.remove(v.Value, table.find(v.Value, Selection))
                        v:SetValue(v.Value)
                    end
                end
            elseif typeof(v.Value) == "string"then
                if table.find(PlayerList, v.Value) then
                    v:SetValue(v.Value)
                else
                    print(unpack(PlayerList))
                    v:SetValue(nil)
                end
            end
        end
    end
end
RefreshPlayers()
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)
