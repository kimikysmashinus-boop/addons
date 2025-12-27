-- ==========================================================
-- ItemTracker.lua
-- Core / Entry Point
-- ==========================================================

local addonName = ...
local ItemTracker = {}
_G[addonName] = ItemTracker

-- ==========================================================
-- ADDON LOADED
-- ==========================================================

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")

loader:SetScript("OnEvent", function(_, _, name)
    if name ~= addonName then return end

    -- Init SavedVariables & data
    if ItemTracker.InitDB then
        ItemTracker:InitDB()
    end

    -- Build main (green) UI
    if ItemTracker.BuildMainUI then
        ItemTracker:BuildMainUI()
    end
end)

-- ==========================================================
-- SLASH COMMAND
-- ==========================================================

SLASH_ITEMTRACKER1 = "/it"
SLASH_ITEMTRACKER2 = "/itemtracker"

SlashCmdList.ITEMTRACKER = function()
    if ItemTracker.mainFrame then
        ItemTracker.mainFrame:SetShown(
            not ItemTracker.mainFrame:IsShown()
        )
    end
end
-- ==========================================================
-- EVENTS
-- ==========================================================

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("BAG_UPDATE_DELAYED")

ev:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        ItemTracker:InitDB()
        ItemTracker:BuildRows()
    end

    ItemTracker:Update()
end)

