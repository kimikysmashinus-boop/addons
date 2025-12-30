-- ==========================================================
-- Data.lua
-- Основной файл данных аддона
-- ==========================================================

local addonName = ...
local ItemTracker = _G[addonName] or {}
_G[addonName] = ItemTracker



-- ==========================================================
-- BASE ITEM LIST
-- ==========================================================

ItemTracker.BaseItems = {}

-- итоговый список (НЕ SavedVariables)
ItemTracker.Items = {}


-- ==========================================================
-- DATABASE INIT
-- ==========================================================

function ItemTracker:InitDB()
    ItemTrackerDB = ItemTrackerDB or {}

    ItemTrackerDB.order = ItemTrackerDB.order or {}
    ItemTrackerDB.colorThresholds = ItemTrackerDB.colorThresholds or {}
    ItemTrackerDB.tiers = ItemTrackerDB.tiers or {}
    ItemTrackerDB.notes = ItemTrackerDB.notes or {}

    -- ТОЛЬКО пользовательские предметы
    ItemTrackerDB.customItems = ItemTrackerDB.customItems or {}

    ItemTrackerDB.defaultThresholds = ItemTrackerDB.defaultThresholds or {
        gray   = 5,
        yellow = 19,
        green  = 30,
    }

    -- пересобираем итоговый список
    self:RebuildItems()

    -- безопасная пересборка order
    local used = {}

    for i = #ItemTrackerDB.order, 1, -1 do
        local idx = ItemTrackerDB.order[i]

        if type(idx) ~= "number"
            or idx < 1
            or idx > #self.Items
            or used[idx]
        then
            table.remove(ItemTrackerDB.order, i)
        else
            used[idx] = true
        end
    end

    for i = 1, #self.Items do
        if not used[i] then
            table.insert(ItemTrackerDB.order, i)
        end
    end
end

    


-- ==========================================================
-- AUTO UI
-- ==========================================================

ItemTracker.AUTO_UI = ItemTracker.AUTO_UI or {
    iconSize   = 28,
    fontSize   = 14,
    rowHeight  = 32,
    rowSpacing = 4,
}

ItemTracker.TIERS = {
    "S+",
    "S",
    "A",
    "B",
    "C",
}

-- числовой приоритет тира (меньше = выше)
ItemTracker.TIER_PRIORITY = {}

for i, tier in ipairs(ItemTracker.TIERS) do
    ItemTracker.TIER_PRIORITY[tier] = i
end

function ItemTracker:GetItemTierPriority(itemIndex)
    local tier = ItemTrackerDB.tiers and ItemTrackerDB.tiers[itemIndex]
    return self.TIER_PRIORITY[tier] or math.huge
end

local function GetTierRank(itemID)
    local tier = ItemTrackerDB.tiers and ItemTrackerDB.tiers[itemID]
    return ItemTracker.TIER_PRIORITY[tier] or 0
end

local function SortByTierThen(a, b, fallbackSortFn)
    local tierA = GetTierRank(a.itemID)
    local tierB = GetTierRank(b.itemID)

    if tierA ~= tierB then
        return tierA > tierB
    end

    if fallbackSortFn then
        return fallbackSortFn(a, b)
    end

    return false
end

-- ==========================================================
-- COLOR RESOLVER (ТОЛЬКО ЦВЕТ)
-- ==========================================================

function ItemTracker:GetItemColorKey(itemID)
    local count = self:CountItem(itemID) or 0
    local t = ItemTrackerDB.colorThresholds[itemID]
    local d = ItemTrackerDB.defaultThresholds

    local gray   = (t and t.gray)   or d.gray
    local yellow = (t and t.yellow) or d.yellow
    local green  = (t and t.green)  or d.green

    if count <= gray then
        return "gray"
    elseif count <= yellow then
        return "yellow"
    elseif count <= green then
        return "green"
    else
        return "red"
    end
end

-- ==========================================================
-- CountInBags
-- ==========================================================

function ItemTracker:CountInBags(itemID)
    local total = 0

    for bag = 0, 4 do
        local slots = C_Container.GetContainerNumSlots(bag)

        if slots then
            for slot = 1, slots do
                local id = C_Container.GetContainerItemID(bag, slot)

                if id == itemID then
                    local info = C_Container.GetContainerItemInfo(bag, slot)

                    if info and info.stackCount then
                        total = total + info.stackCount
                    end
                end
            end
        end
    end

    return total
end

-- ✅ ВОТ ЭТО ОБЯЗАТЕЛЬНО
function ItemTracker:IsInInventory(itemID)
    return (self:CountInBags(itemID) or 0) > 0
end

-- ==========================================================
-- COLUMNS (SOURCE OF TRUTH)
-- КАЖДАЯ КОЛОНКА = СВОЁ ПРАВИЛО
-- ==========================================================

ItemTracker.COLUMNS = {
    {
        key = "need",
        accepts = { gray = true },
        ruleFn = function(self, itemID)
            return self:GetItemColorKey(itemID) == "gray"
        end,
    },
    {
        key = "ok",
        accepts = { green = true },
        ruleFn = function(self, itemID)
            return self:GetItemColorKey(itemID) == "green"
        end,
    },
    {
        key = "overflow",
        accepts = { red = true },
        ruleFn = function(self, itemID)
            return self:GetItemColorKey(itemID) == "red"
        end,
    },
    {
        key = "missing",
        ruleFn = function(self, itemID)
            local color = self:GetItemColorKey(itemID)

            if color ~= "green" and color ~= "red" then
                return false
            end

            if self:IsInInventory(itemID) then
                return false
            end

            return true
        end,
    },
}


-- ==========================================================
-- BUILD AUTO INDEX
-- ==========================================================

function ItemTracker:BuildAutoIndex()
    self.AutoIndex = {}

    for _, col in ipairs(self.COLUMNS) do
        self.AutoIndex[col.key] = {}
    end

    for _, index in ipairs(ItemTrackerDB.order or {}) do
        local item = self.Items[index]

        if item then
            local itemID = item.itemID

            for _, col in ipairs(self.COLUMNS) do
                if col.ruleFn and col.ruleFn(self, itemID) then
                    table.insert(self.AutoIndex[col.key], itemID)
                end
            end
        end
    end

    -- ======================================================
    -- SORT BY TIER (GLOBAL PRIORITY)
    -- ======================================================

    local idToIndex = {}

    for _, idx in ipairs(ItemTrackerDB.order or {}) do
        local it = self.Items[idx]

        if it then
            idToIndex[it.itemID] = idx
        end
    end

    for _, colDef in ipairs(self.COLUMNS) do
        local list = self.AutoIndex[colDef.key]

        table.sort(list, function(a, b)
            local indexA = idToIndex[a]
            local indexB = idToIndex[b]

            if not indexA or not indexB then
                return false
            end

            local tierA = ItemTrackerDB.tiers and ItemTrackerDB.tiers[indexA]
            local tierB = ItemTrackerDB.tiers and ItemTrackerDB.tiers[indexB]

            local prioA = ItemTracker.TIER_PRIORITY[tierA] or math.huge
            local prioB = ItemTracker.TIER_PRIORITY[tierB] or math.huge

            if prioA ~= prioB then
                return prioA < prioB
            end

            return indexA < indexB
        end)
    end
end

-- ==========================================================
-- AUCTION CACHE
-- ==========================================================

ItemTracker.auctionCache = ItemTracker.auctionCache or {}

local function ScanAuction()
    wipe(ItemTracker.auctionCache)

    local num = GetNumAuctionItems("owner")
    DEFAULT_CHAT_FRAME:AddMessage("SCAN AUCTION ITEMS: "..num)

    for i = 1, num do
        local _, _, count = GetAuctionItemInfo("owner", i)
        local itemLink = GetAuctionItemLink("owner", i)

        if itemLink and count then
            local itemID = tonumber(itemLink:match("item:(%d+)"))

            if itemID then
                ItemTracker.auctionCache[itemID] =
                    (ItemTracker.auctionCache[itemID] or 0) + count
            end
        end
    end
end


local auc = CreateFrame("Frame")
auc:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
auc:RegisterEvent("AUCTION_HOUSE_SHOW")

auc:SetScript("OnEvent", function(_, event)
    if event == "AUCTION_HOUSE_SHOW"
        or event == "AUCTION_OWNED_LIST_UPDATE"
    then
        ScanAuction()
        ItemTracker:Update()
        if ItemTracker.UpdateAutoUI then
            ItemTracker:UpdateAutoUI()
        end
    end
end)


function ItemTracker:UpdateData()
    self:BuildAutoIndex()
end



local function DelayedAuctionScan()
    C_Timer.After(0.3, function()
        ScanAuction()
        ItemTracker:Update()
        if ItemTracker.UpdateAutoUI then
            ItemTracker:UpdateAutoUI()
        end
    end)
end
--- ========================================================== вызов перещета

function ItemTracker:RebuildItems()
    wipe(self.Items)

    local seen = {}

    local function add(list)
        for _, it in ipairs(list) do
            if it.itemID and not seen[it.itemID] then
                local name, _, icon = GetItemInfo(it.itemID)
                if name then
                    seen[it.itemID] = true
                    table.insert(self.Items, {
                        itemID = it.itemID,
                        name   = name,
                        icon   = icon,
                    })
                end
            end
        end
    end

    add(self.BaseItems)
    add(ItemTrackerDB.customItems)
end

function ItemTracker:AddCustomItem(itemID)
    itemID = tonumber(itemID)
    if not itemID then return end

    -- защита от дублей
    for _, it in ipairs(ItemTrackerDB.customItems) do
        if it.itemID == itemID then
            return
        end
    end

    table.insert(ItemTrackerDB.customItems, { itemID = itemID })

    self:RebuildItems()
    self:BuildRows()
    self:Update()
end


function ItemTracker:RemoveCustomItem(itemID)
    itemID = tonumber(itemID)
    if not itemID then return end

    local removed = false

    for i = #ItemTrackerDB.customItems, 1, -1 do
        if ItemTrackerDB.customItems[i].itemID == itemID then
            table.remove(ItemTrackerDB.customItems, i)
            removed = true
        end
    end

    if not removed then
        return
    end

    -- чистим связанные данные
    ItemTrackerDB.tiers[itemID] = nil
    ItemTrackerDB.notes[itemID] = nil
    ItemTrackerDB.colorThresholds[itemID] = nil

    self:RebuildItems()
    self:BuildRows()
    self:Update()
end


function ItemTracker:BuildExportText()
    local lines = {}

    -- гарантируем актуальность
    self:BuildAutoIndex()

    for _, col in ipairs(self.COLUMNS) do
        local list = self.AutoIndex[col.key]

        if list and #list > 0 then
            table.insert(lines, "[" .. col.key .. "]")

            for _, itemID in ipairs(list) do
                table.insert(lines, tostring(itemID))
            end

            table.insert(lines, "")
        end
    end

    return table.concat(lines, "\n")
end




