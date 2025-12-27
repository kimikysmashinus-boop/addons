-- ==========================================================
-- ItemTracker — Classic Era 1.15+
-- Drag-sort + Count Column + Tier Menu + Color + Ghost + Notes
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

ItemTracker.TIERS = { "S++", "S", "A", "B", "C" }

-- ==========================================================
-- COLOR
-- ==========================================================

function ItemTracker:GetColor(c)
    c = tonumber(c) or 0
    if c <= 4 then return 1,0,0
    elseif c <= 19 then return 0.7,0.7,0.7
    elseif c <= 34 then return 1,1,0
    elseif c <= 40 then return 0,1,0
    else return 1,0.4,0.7 end
end

-- ==========================================================
-- COUNT
-- ==========================================================

function ItemTracker:CountItem(id)
    local total = 0
    for bag = 0,4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            if C_Container.GetContainerItemID(bag, slot) == id then
                local info = C_Container.GetContainerItemInfo(bag, slot)
                total = total + (info and info.stackCount or 1)
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
    ItemTrackerDB.notes = ItemTrackerDB.notes or {}
    ItemTrackerDB.tiers = ItemTrackerDB.tiers or {}

    local used = {}
    for i = #ItemTrackerDB.order, 1, -1 do
        local v = ItemTrackerDB.order[i]
        if not ItemTracker.Items[v] or used[v] then
            table.remove(ItemTrackerDB.order, i)
        else
            used[v] = true
        end
    end

    for i = 1, #ItemTracker.Items do
        if not used[i] then
            table.insert(ItemTrackerDB.order, i)
        end
    end
end

local function MoveIndex(t, from, to)
    if from == to then return end
    local v = table.remove(t, from)
    table.insert(t, to, v)
end

-- ==========================================================
-- UI
-- ==========================================================

local ROW_H = 34
ItemTracker.rows = {}

local frame = CreateFrame("Frame", "ItemTrackerFrame", UIParent, "BackdropTemplate")
frame:SetSize(520, 460)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 14,
})
frame:SetBackdropColor(0,0,0,0.9)
frame:SetMovable(true)
frame:EnableMouse(true)
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
content:SetSize(480, 1)
scroll:SetScrollChild(content)

-- ==========================================================
-- DRAG GHOST
-- ==========================================================

local ghost = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
ghost:SetSize(300, 32)
ghost:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
})
ghost:SetBackdropColor(0,0,0,0.95)
ghost:SetFrameStrata("TOOLTIP")
ghost:Hide()

ghost.icon = ghost:CreateTexture(nil,"ARTWORK")
ghost.icon:SetSize(26,26)
ghost.icon:SetPoint("LEFT", 4, 0)

ghost.text = ghost:CreateFontString(nil,"OVERLAY","GameFontNormal")
ghost.text:SetPoint("LEFT", ghost.icon, "RIGHT", 8, 0)

-- ==========================================================
-- TIER DROPDOWN (CLASSIC SAFE)
-- ==========================================================

local TierDropDown = CreateFrame("Frame", "ItemTrackerTierDropDown", UIParent, "UIDropDownMenuTemplate")
TierDropDown.displayMode = "MENU"

TierDropDown.initialize = function(self)
    local index = self.itemIndex
    if not index then return end

    for _, tier in ipairs(ItemTracker.TIERS) do
        UIDropDownMenu_AddButton({
            text = tier,
            notCheckable = true,
            func = function()
                ItemTrackerDB.tiers[index] = tier
                CloseDropDownMenus()
                ItemTracker:Update()
            end
        })
    end

    UIDropDownMenu_AddButton({
        text = "Clear",
        notCheckable = true,
        func = function()
            ItemTrackerDB.tiers[index] = nil
            CloseDropDownMenus()
            ItemTracker:Update()
        end
    })
end

-- ==========================================================
-- BUILD ROWS
-- ==========================================================

function ItemTracker:BuildRows()
    wipe(self.rows)

    for pos = 1, #ItemTrackerDB.order do
        local row = CreateFrame("Frame", nil, content)
        row:SetSize(480, ROW_H)
        row:SetPoint("TOPLEFT", 0, -(pos-1)*ROW_H)
        row.pos = pos

        row.hl = row:CreateTexture(nil,"BACKGROUND")
        row.hl:SetAllPoints()
        row.hl:SetColorTexture(1,1,1,0.15)
        row.hl:Hide()

        row.icon = row:CreateTexture(nil,"ARTWORK")
        row.icon:SetSize(28,28)
        row.icon:SetPoint("LEFT")

        row.name = row:CreateFontString(nil,"OVERLAY","GameFontNormal")
        row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
        row.name:SetWidth(210)

        row.count = row:CreateFontString(nil,"OVERLAY","GameFontHighlight")
        row.count:SetPoint("LEFT", row.name, "RIGHT", 6, 0)
        row.count:SetWidth(40)

        row.tier = CreateFrame("Button", nil, row, "BackdropTemplate")
        row.tier:SetSize(36, 20)
        row.tier:SetPoint("LEFT", row.count, "RIGHT", 6, 0)
        row.tier:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
        row.tier:SetBackdropColor(0,0,0,0.8)

        row.tier.text = row.tier:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        row.tier.text:SetPoint("CENTER")

        row.tier:SetScript("OnMouseUp", function()
            TierDropDown.itemIndex = ItemTrackerDB.order[row.pos]
            ToggleDropDownMenu(1, nil, TierDropDown, "cursor", 0, 0)
        end)

        row.note = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        row.note:SetSize(40, 20)
        row.note:SetPoint("RIGHT", -10, 0)
        row.note:SetAutoFocus(false)
        row.note:SetFontObject(GameFontHighlightSmall)
        row.note:SetScript("OnEnterPressed", row.note.ClearFocus)
        row.note:SetScript("OnEscapePressed", row.note.ClearFocus)
        row.note:SetScript("OnEditFocusLost", function(self)
            ItemTrackerDB.notes[ ItemTrackerDB.order[row.pos] ] = self:GetText()
        end)

        row:EnableMouse(true)
        row:RegisterForDrag("LeftButton")

        row:SetScript("OnDragStart", function(self)
            self.dragFrom = self.pos
            self:SetAlpha(0.4)

            local index = ItemTrackerDB.order[self.pos]
            local item = ItemTracker.Items[index]
            local count = ItemTracker:CountItem(item.itemID)
            local tier = ItemTrackerDB.tiers[index] or "—"

            ghost.icon:SetTexture(GetItemIcon(item.itemID))
            ghost.text:SetText(item.name .. " | " .. count .. " | " .. tier)
            ghost:Show()

            ghost:SetScript("OnUpdate", function()
                local x,y = GetCursorPosition()
                local s = UIParent:GetEffectiveScale()
                ghost:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x/s + 14, y/s - 14)
                for _, r in ipairs(ItemTracker.rows) do
                    local yy = y/s
                    if yy <= r:GetTop() and yy >= r:GetBottom() then
                        r.hl:Show()
                    else
                        r.hl:Hide()
                    end
                end
            end)
        end)

        row:SetScript("OnDragStop", function(self)
            self:SetAlpha(1)
            ghost:Hide()
            ghost:SetScript("OnUpdate", nil)
            for _, r in ipairs(ItemTracker.rows) do r.hl:Hide() end

            local y = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
            local target
            for _, r in ipairs(ItemTracker.rows) do
                if y <= r:GetTop() and y >= r:GetBottom() then
                    target = r.pos
                end
            end
            if target then
                MoveIndex(ItemTrackerDB.order, self.dragFrom, target)
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
        local row = self.rows[pos]
        local item = self.Items[index]
        if row then
            local count = self:CountItem(item.itemID)
            local r,g,b = self:GetColor(count)

            row.pos = pos
            row:SetPoint("TOPLEFT", 0, -(pos-1)*ROW_H)
            row.icon:SetTexture(GetItemIcon(item.itemID))
            row.name:SetText(item.name)
            row.name:SetTextColor(r,g,b)
            row.count:SetText(count)
            row.count:SetTextColor(r,g,b)
            row.tier.text:SetText(ItemTrackerDB.tiers[index] or "—")
            row.note:SetText(ItemTrackerDB.notes[index] or "")
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
ev:SetScript("OnEvent", function(_, e)
    if e == "PLAYER_LOGIN" then
        InitDB()
        ItemTracker:BuildRows()
    end
    ItemTracker:Update()
end)

SLASH_ITEMTRACKER1 = "/it"
SlashCmdList.ITEMTRACKER = function()
    frame:SetShown(not frame:IsShown())
end

print("ItemTracker loaded (CLASSIC TIER MENU OK)")
