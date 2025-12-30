-- ==========================================================
-- ItemTracker.lua
-- Core / Entry Point (STABLE)
-- ==========================================================

local addonName = ...
local ItemTracker = _G[addonName] or {}
_G[addonName] = ItemTracker

-- ==========================================================
-- ADDON LOADER (SINGLE, CORRECT)
-- ==========================================================

local loader = CreateFrame("Frame")

loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")

-- inventory / bank
loader:RegisterEvent("BAG_UPDATE_DELAYED")
loader:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

-- auction
loader:RegisterEvent("AUCTION_HOUSE_SHOW")
loader:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")

loader:SetScript("OnEvent", function(self, event, arg1)

    -- ======================================================
    -- ADDON LOADED (DB ONLY)
    -- ======================================================
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then return end

        if ItemTracker.InitDB then
            ItemTracker:InitDB()
        end
        return
    end

    -- ======================================================
    -- PLAYER LOGIN (UI + FIRST BUILD)
    -- ======================================================
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

    -- ======================================================
    -- INVENTORY / BANK UPDATE
    -- ======================================================
    if event == "BAG_UPDATE_DELAYED"
    or event == "PLAYERBANKSLOTS_CHANGED" then

        if ItemTracker.Update then
            ItemTracker:Update()
        end

        if ItemTracker.UpdateAutoUI then
            ItemTracker:UpdateAutoUI()
        end
        return
    end

    -- ======================================================
    -- AUCTION HOUSE
    -- ======================================================
    if event == "AUCTION_HOUSE_SHOW" then
        if ItemTracker.ScanAuctionHouse then
            ItemTracker:ScanAuctionHouse()
        end
        return
    end

    if event == "AUCTION_ITEM_LIST_UPDATE" then
        if ItemTracker.UpdateAuctionData then
            ItemTracker:UpdateAuctionData()
        end
        return
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
