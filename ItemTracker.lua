-- ==========================================================
-- ItemTracker.lua
-- Core / Entry Point
-- ==========================================================

local addonName = ...
local ItemTracker = _G[addonName] or {}
_G[addonName] = ItemTracker

-- ==========================================================
-- ADDON LOADER
-- ==========================================================

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("BAG_UPDATE_DELAYED")
loader:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

loader:SetScript("OnEvent", function(_, event, arg)
    -- === ADDON LOADED (DB only)
    if event == "ADDON_LOADED" then
        if arg ~= addonName then return end

        if ItemTracker.InitDB then
            ItemTracker:InitDB()
        end
        return
    end

    -- === PLAYER LOGIN (UI creation)
    if event == "PLAYER_LOGIN" then
        if ItemTracker.BuildMainUI then
            ItemTracker:BuildMainUI()
        end

        if ItemTracker.BuildRows then
            ItemTracker:BuildRows()
        end

        if ItemTracker.Update then
            ItemTracker:Update()
        end

        if ItemTracker.UpdateAutoUI then
            ItemTracker:UpdateAutoUI()
        end
        return
    end

    -- === INVENTORY / BANK UPDATES
    if ItemTracker.Update then
        ItemTracker:Update()
    end

    if ItemTracker.UpdateAutoUI then
        ItemTracker:UpdateAutoUI()
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
