-- ==========================================================
-- Data.lua
-- ==========================================================

local addonName = ...
local ItemTracker = _G[addonName]

ItemTracker.Items = {
    { itemID = 13457, name = "Greater Fire Protection Potion" },
    { itemID = 13458, name = "Greater Nature Protection Potion" },
    { itemID = 13459, name = "Greater Shadow Protection Potion" },
    { itemID = 13456, name = "Greater Frost Protection Potion" },
    { itemID = 13461, name = "Greater Arcane Protection Potion" },
    { itemID = 13454, name = "Greater Arcane Elixir" },
    { itemID = 18253, name = "Major Rejuvenation Potion" },
    { itemID = 13452, name = "Elixir of Mongoose" },
    { itemID = 9206,  name = "Elixir of Giants" },
    { itemID = 9224,  name = "Elixir of Demonslaying" },
    { itemID = 13453, name = "Elixir of Brute Force" },
    { itemID = 13442, name = "Mighty Rage Potion" },
    { itemID = 3826,  name = "Mighty Troll's Blood Potion" },
}

ItemTracker.TIERS = { "S++", "S", "A", "B", "C" }

function ItemTracker:InitDB()
    ItemTrackerDB = ItemTrackerDB or {}

    ItemTrackerDB.items  = ItemTrackerDB.items  or {}
    ItemTrackerDB.order  = ItemTrackerDB.order  or {}
    ItemTrackerDB.notes  = ItemTrackerDB.notes  or {}
    ItemTrackerDB.tiers  = ItemTrackerDB.tiers  or {}

    ItemTrackerDB.colorThresholds = ItemTrackerDB.colorThresholds or {}
    ItemTrackerDB.defaultThresholds = ItemTrackerDB.defaultThresholds or {
        gray = 5,
        yellow = 19,
        green = 30,
    }

    -- merge saved items
    for _, saved in ipairs(ItemTrackerDB.items) do
        local found = false
        for _, base in ipairs(ItemTracker.Items) do
            if base.itemID == saved.itemID then
                found = true
                break
            end
        end
        if not found then
            table.insert(ItemTracker.Items, saved)
        end
    end

    -- rebuild order safely
    local used = {}
    for i = #ItemTrackerDB.order, 1, -1 do
        local idx = ItemTrackerDB.order[i]
        if type(idx) ~= "number"
            or idx < 1
            or idx > #ItemTracker.Items
            or used[idx]
        then
            table.remove(ItemTrackerDB.order, i)
        else
            used[idx] = true
        end
    end

    for i = 1, #ItemTracker.Items do
        if not used[i] then
            table.insert(ItemTrackerDB.order, i)
        end
    end

    -- init order if empty (first run)
    if #ItemTrackerDB.order == 0 then
        for i = 1, #ItemTracker.Items do
            table.insert(ItemTrackerDB.order, i)
        end
    end
end
