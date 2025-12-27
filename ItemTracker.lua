-- ==========================================================
-- ItemTracker — Classic Era 1.15+
-- Drag-sort + Count + Color (FINAL WORKING)
-- ==========================================================

local addonName = ...
local ItemTracker = {}
_G[addonName] = ItemTracker

-- ==========================================================
-- ITEMS
-- ==========================================================

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

-- ==========================================================
-- COLOR
-- ==========================================================

function ItemTracker:GetColor(count)
    count = tonumber(count) or 0
    if count <= 4 then return 1,0,0
    elseif count <= 19 then return 0.7,0.7,0.7
    elseif count <= 34 then return 1,1,0
    elseif count <= 40 then return 0,1,0
    else return 1,0.4,0.7 end
end

-- ==========================================================
-- COUNT
-- ==========================================================

function ItemTracker:CountItem(itemID)
    local total = 0
    for bag = 0,4 do
        local slots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, slots do
            local id = C_Container.GetContainerItemID(bag, slot)
            if id == itemID then
                local info = C_Container.GetContainerItemInfo(bag, slot)
                total = total + tonumber(info and info.stackCount or 1)
            end
        end
    end
    return total
end

-- ==========================================================
-- SAVED VARS
-- ==========================================================

local function InitDB()
    ItemTrackerDB = ItemTrackerDB or {}
    ItemTrackerDB.order = ItemTrackerDB.order or {}

    local max = #ItemTracker.Items
    local used = {}

    for i = #ItemTrackerDB.order, 1, -1 do
        local v = tonumber(ItemTrackerDB.order[i])
        if not v or v < 1 or v > max or used[v] then
            table.remove(ItemTrackerDB.order, i)
        else
            used[v] = true
        end
    end

    for i = 1, max do
        if not used[i] then
            table.insert(ItemTrackerDB.order, i)
        end
    end
end

-- ==========================================================
-- UI
-- ==========================================================

local frame = CreateFrame("Frame", "ItemTrackerFrame", UIParent, "BackdropTemplate")
frame:SetSize(360, 460)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 14,
})
frame:SetBackdropColor(0,0,0,0.9)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

frame.title = frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
frame.title:SetPoint("TOP",0,-10)
frame.title:SetText("ItemTracker")

local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 10, -40)
scroll:SetPoint("BOTTOMRIGHT", -30, 10)

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(300, 1) -- <<< ВАЖНО
scroll:SetScrollChild(content)

local ROW_H = 34
ItemTracker.rows = {}

-- ==========================================================
-- BUILD ROWS
-- ==========================================================

function ItemTracker:BuildRows()
    wipe(self.rows)

    for pos = 1, #ItemTrackerDB.order do
        local row = CreateFrame("Frame", nil, content)
        row:SetSize(300, ROW_H)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(pos-1)*ROW_H)
        row.pos = pos

        row.icon = row:CreateTexture(nil,"ARTWORK")
        row.icon:SetSize(28,28)
        row.icon:SetPoint("LEFT")

        row.text = row:CreateFontString(nil,"OVERLAY","GameFontNormal")
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)

        row:EnableMouse(true)
        row:RegisterForDrag("LeftButton")

        row:SetScript("OnDragStart", function(self)
            self.dragFrom = self.pos
        end)

        row:SetScript("OnDragStop", function(self)
            local y = select(2, self:GetCenter())
            for _, other in ipairs(ItemTracker.rows) do
                if other ~= self then
                    local oy = select(2, other:GetCenter())
                    if math.abs(y - oy) < ROW_H / 2 then
                        ItemTrackerDB.order[self.dragFrom],
                        ItemTrackerDB.order[other.pos] =
                        ItemTrackerDB.order[other.pos],
                        ItemTrackerDB.order[self.dragFrom]
                        break
                    end
                end
            end
            ItemTracker:Update()
        end)

        table.insert(self.rows, row)
    end
end

-- ==========================================================
-- UPDATE
-- ==========================================================

function ItemTracker:Update()
    for pos, index in ipairs(ItemTrackerDB.order) do
        local item = self.Items[index]
        local row = self.rows[pos]

        if item and row then
            local count = self:CountItem(item.itemID)
            local r,g,b = self:GetColor(count)

            row.pos = pos
            row.icon:SetTexture(GetItemIcon(item.itemID))
            row.text:SetText(item.name .. ": " .. count)
            row.text:SetTextColor(r,g,b)
            row:Show()
        end
    end
    content:SetHeight(#ItemTrackerDB.order * ROW_H)
end

-- ==========================================================
-- EVENTS
-- ==========================================================

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("BAG_UPDATE_DELAYED")

ev:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        InitDB()
        ItemTracker:BuildRows()
    end
    ItemTracker:Update()
end)

-- ==========================================================
-- SLASH
-- ==========================================================

SLASH_ITEMTRACKER1 = "/it"
SlashCmdList.ITEMTRACKER = function()
    frame:SetShown(not frame:IsShown())
end

print("ItemTracker loaded (FINAL)")
