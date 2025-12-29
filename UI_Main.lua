local addonName = ...
local ItemTracker = _G[addonName]

local ROW_H = 34
ItemTracker.rows = {}

-- ==========================================================
-- MAIN FRAME
-- ==========================================================

local frame = CreateFrame("Frame", "ItemTrackerFrame", UIParent, "BackdropTemplate")
ItemTracker.mainFrame = frame

frame:SetSize(520, 460)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 14,
})
frame:SetBackdropColor(0, 0, 0, 0.9)

frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOP", 0, -10)
frame.title:SetText("KimiBoss")

-- ==========================================================
-- ADD / REMOVE ITEM BUTTONS + POPUP
-- ==========================================================

local popupMode = "add" -- "add" | "remove"

-- ==========================================================
-- ADD / REMOVE + TOGGLE / CLOSE BUTTONS (ALIGNED)
-- ==========================================================

local popupMode = "add" -- "add" | "remove"

-- базовая Y-линия для всех кнопок
local BTN_Y = -12
local BTN_SIZE = 20
local BTN_GAP = 4

-- ==========================================================
-- PLUS BUTTON
-- ==========================================================

local addBtn = CreateFrame("Button", nil, frame)
addBtn:SetSize(BTN_SIZE, BTN_SIZE)
addBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, BTN_Y)
addBtn:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")

addBtn.icon = addBtn:CreateTexture(nil, "ARTWORK")
addBtn.icon:SetAllPoints()
addBtn.icon:SetTexture("Interface/Buttons/UI-PlusButton-Up")

addBtn:SetScript("OnEnter", function(self)
    self.icon:SetVertexColor(1, 0.82, 0)
end)
addBtn:SetScript("OnLeave", function(self)
    self.icon:SetVertexColor(1, 1, 1)
end)

addBtn:SetScript("OnClick", function()
    ShowPopup("add")
end)

-- ==========================================================
-- MINUS BUTTON
-- ==========================================================

local removeBtn = CreateFrame("Button", nil, frame)
removeBtn:SetSize(BTN_SIZE, BTN_SIZE)
removeBtn:SetPoint("LEFT", addBtn, "RIGHT", BTN_GAP, 0)
removeBtn:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")

removeBtn.icon = removeBtn:CreateTexture(nil, "ARTWORK")
removeBtn.icon:SetAllPoints()
removeBtn.icon:SetTexture("Interface/Buttons/UI-MinusButton-Up")

removeBtn:SetScript("OnEnter", function(self)
    self.icon:SetVertexColor(1, 0.3, 0.3)
end)
removeBtn:SetScript("OnLeave", function(self)
    self.icon:SetVertexColor(1, 1, 1)
end)

removeBtn:SetScript("OnClick", function()
    ShowPopup("remove")
end)

-- ==========================================================
-- RIGHT ICON BUTTONS
-- ==========================================================

local TOGGLE_FRAME_NAME = "ItemTrackerSettingsFrame"

-- CLOSE BUTTON (крайняя справа)
local closeBtn = CreateFrame("Button", nil, frame)
closeBtn:SetSize(BTN_SIZE, BTN_SIZE)
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -14, BTN_Y)
closeBtn:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")

closeBtn.icon = closeBtn:CreateTexture(nil, "ARTWORK")
closeBtn.icon:SetAllPoints()
closeBtn.icon:SetTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")

closeBtn:SetScript("OnEnter", function(self)
    self.icon:SetVertexColor(1, 0.3, 0.3)
end)
closeBtn:SetScript("OnLeave", function(self)
    self.icon:SetVertexColor(1, 1, 1)
end)

closeBtn:SetScript("OnClick", function()
    frame:Hide()
end)

-- TOGGLE BUTTON (слева от close)
local toggleBtn = CreateFrame("Button", nil, frame)
toggleBtn:SetSize(BTN_SIZE, BTN_SIZE)
toggleBtn:SetPoint("RIGHT", closeBtn, "LEFT", -BTN_GAP, 0)
toggleBtn:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")

toggleBtn.icon = toggleBtn:CreateTexture(nil, "ARTWORK")
toggleBtn.icon:SetAllPoints()
toggleBtn.icon:SetTexture("Interface/Buttons/UI-Panel-CollapseButton-Up")

toggleBtn:SetScript("OnEnter", function(self)
    self.icon:SetVertexColor(1, 0.82, 0)
end)
toggleBtn:SetScript("OnLeave", function(self)
    self.icon:SetVertexColor(1, 1, 1)
end)

toggleBtn:SetScript("OnClick", function()
    local f = _G[TOGGLE_FRAME_NAME]
    if not f then return end

    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end)





















-- ==========================================================
-- POPUP FRAME
-- ==========================================================

local addFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
addFrame:SetSize(150, 40)
addFrame:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 10,
})
addFrame:SetBackdropColor(0, 0, 0, 0.95)
addFrame:SetFrameStrata("DIALOG")
addFrame:SetClampedToScreen(true)
addFrame:Hide()

-- INPUT
addFrame.input = CreateFrame("EditBox", nil, addFrame, "InputBoxTemplate")
addFrame.input:SetSize(55, 20)
addFrame.input:SetPoint("LEFT", 10, 0)
addFrame.input:SetNumeric(true)
addFrame.input:SetAutoFocus(false)
addFrame.input:SetScript("OnEnterPressed", function()
    addFrame.ok:Click()
end)
addFrame.input:SetScript("OnEscapePressed", function()
    addFrame:Hide()
end)

-- OK BUTTON
addFrame.ok = CreateFrame("Button", nil, addFrame, "UIPanelButtonTemplate")
addFrame.ok:SetSize(50, 20)
addFrame.ok:SetPoint("LEFT", addFrame.input, "RIGHT", 8, 0)
addFrame.ok:SetText("OK")


function ItemTracker:FullRecalculate()
    -- логика
    self:BuildAutoIndex()

    -- UI
    if self.UpdateAutoUI then
        self:UpdateAutoUI()
    end
end

local function ShowPopup(mode)
    popupMode = mode

    local scale = UIParent:GetScale()
    local x, y = GetCursorPosition()
    x = x / scale
    y = y / scale

    addFrame:ClearAllPoints()
    addFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x + 10, y + 10)
    addFrame:SetFrameLevel(frame:GetFrameLevel() + 50)

    addFrame.input:SetText("")
    addFrame:Show()
    addFrame.input:SetFocus()
end

addBtn:SetScript("OnClick", function()
    ShowPopup("add")
end)

removeBtn:SetScript("OnClick", function()
    ShowPopup("remove")
end)

addFrame.ok:SetScript("OnClick", function()
    local id = tonumber(addFrame.input:GetText())
    if not id then return end

    if popupMode == "add" then
        for _, it in ipairs(ItemTracker.Items) do
            if it.itemID == id then
                print("Item already exists")
                return
            end
        end

        local name = GetItemInfo(id)
        if not name then
            print("Item not cached yet. Open tooltip once.")
            return
        end

        local newItem = { itemID = id, name = name }
        table.insert(ItemTrackerDB.items, newItem)
        table.insert(ItemTracker.Items, newItem)
        table.insert(ItemTrackerDB.order, #ItemTracker.Items)

    else
        local index
        for i, it in ipairs(ItemTracker.Items) do
            if it.itemID == id then
                index = i
                break
            end
        end

        if not index then
            print("Item not found")
            return
        end

        table.remove(ItemTracker.Items, index)

        for i = #ItemTrackerDB.items, 1, -1 do
            if ItemTrackerDB.items[i].itemID == id then
                table.remove(ItemTrackerDB.items, i)
            end
        end

        for i = #ItemTrackerDB.order, 1, -1 do
            if ItemTrackerDB.order[i] == index then
                table.remove(ItemTrackerDB.order, i)
            elseif ItemTrackerDB.order[i] > index then
                ItemTrackerDB.order[i] = ItemTrackerDB.order[i] - 1
            end
        end

        ItemTrackerDB.notes[index] = nil
        ItemTrackerDB.tiers[index] = nil
    end

    addFrame:Hide()
    ItemTracker:BuildRows()
    ItemTracker:Update()
end)

-- ==========================================================
-- SCROLL
-- ==========================================================

local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 10, -40)
scroll:SetPoint("BOTTOMRIGHT", -30, 10)

local content = CreateFrame("Frame", nil, frame)
ItemTracker.content = content
content:SetSize(480, 1)

scroll:SetScrollChild(content)

content:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40)
content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)

-- (остальной код ниже отформатирован аналогично и без изменений логики)
-- ==========================================================
-- SCROLL
-- ==========================================================

local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 10, -40)
scroll:SetPoint("BOTTOMRIGHT", -30, 10)

local content = CreateFrame("Frame", nil, frame)
ItemTracker.content = content
content:SetSize(480, 1)

scroll:SetScrollChild(content)

content:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40)
content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)

-- ==========================================================
-- DRAG GHOST
-- ==========================================================

local ghost = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
ghost:SetSize(300, 32)
ghost:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
})
ghost:SetBackdropColor(0, 0, 0, 0.95)
ghost:SetFrameStrata("TOOLTIP")
ghost:Hide()

ghost.icon = ghost:CreateTexture(nil, "ARTWORK")
ghost.icon:SetSize(26, 26)
ghost.icon:SetPoint("LEFT", 4, 0)

ghost.text = ghost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ghost.text:SetPoint("LEFT", ghost.icon, "RIGHT", 8, 0)

-- ==========================================================
-- THRESHOLD POPUP
-- ==========================================================

local thresholdFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
thresholdFrame:SetSize(220, 110)
thresholdFrame:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
})
thresholdFrame:SetBackdropColor(0, 0, 0, 0.95)
thresholdFrame:SetFrameStrata("DIALOG")
thresholdFrame:Hide()

thresholdFrame.inputs = {}

local labels = {
    { key = "gray",   text = "Gray ≤"   },
    { key = "yellow", text = "Yellow ≤" },
    { key = "green",  text = "Green ≤"  },
}

for i, l in ipairs(labels) do
    local y = -10 - (i - 1) * 30

    local fs = thresholdFrame:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontHighlightSmall"
    )
    fs:SetPoint("TOPLEFT", 10, y)
    fs:SetText(l.text)

    local eb = CreateFrame("EditBox", nil, thresholdFrame, "InputBoxTemplate")
    eb:SetSize(40, 20)
    eb:SetPoint("LEFT", fs, "RIGHT", 6, 0)
    eb:SetNumeric(true)
    eb:SetAutoFocus(false)

    thresholdFrame.inputs[l.key] = eb
end

thresholdFrame.ok = CreateFrame(
    "Button",
    nil,
    thresholdFrame,
    "UIPanelButtonTemplate"
)
thresholdFrame.ok:SetSize(60, 20)
thresholdFrame.ok:SetPoint("BOTTOM", 0, 8)
thresholdFrame.ok:SetText("OK")

thresholdFrame.ok:SetScript("OnClick", function()
    local itemID = thresholdFrame.itemID
    if not itemID then
        thresholdFrame:Hide()
        return
    end

    ItemTrackerDB.colorThresholds[itemID] = {
        gray   = tonumber(thresholdFrame.inputs.gray:GetText())
            or ItemTrackerDB.defaultThresholds.gray,
        yellow = tonumber(thresholdFrame.inputs.yellow:GetText())
            or ItemTrackerDB.defaultThresholds.yellow,
        green  = tonumber(thresholdFrame.inputs.green:GetText())
            or ItemTrackerDB.defaultThresholds.green,
    }

    thresholdFrame:Hide()
    ItemTracker:FullRecalculate()

end)

thresholdFrame:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
        self:Hide()
    end
end)

thresholdFrame:SetPropagateKeyboardInput(true)
thresholdFrame:EnableKeyboard(true)

-- ==========================================================
-- TIER DROPDOWN
-- ==========================================================

local TierDropDown = CreateFrame(
    "Frame",
    "ItemTrackerTierDropDown",
    UIParent,
    "UIDropDownMenuTemplate"
)

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
            end,
        })
    end

    UIDropDownMenu_AddButton({
        text = "Clear",
        notCheckable = true,
        func = function()
            ItemTrackerDB.tiers[index] = nil
            CloseDropDownMenus()
            ItemTracker:Update()
        end,
    })
end

function ItemTracker:ShowThresholdPopup(itemID)
    thresholdFrame.itemID = itemID

    local t = ItemTrackerDB.colorThresholds[itemID]
    local d = ItemTrackerDB.defaultThresholds

    thresholdFrame.inputs.gray:SetText((t and t.gray) or d.gray)
    thresholdFrame.inputs.yellow:SetText((t and t.yellow) or d.yellow)
    thresholdFrame.inputs.green:SetText((t and t.green) or d.green)

    thresholdFrame:ClearAllPoints()
    thresholdFrame:SetPoint("CENTER")
    thresholdFrame:Show()
end

-- ==========================================================
-- MOVE INDEX (DRAG SORT HELPER)
-- ==========================================================

local function MoveIndex(tbl, from, to)
    if not tbl then return end
    if from == to then return end
    if from < 1 or from > #tbl then return end
    if to < 1 or to > #tbl then return end

    local value = table.remove(tbl, from)
    table.insert(tbl, to, value)
end

-- ==========================================================
-- BUILD ROWS
-- ==========================================================

function ItemTracker:BuildRows()
    for _, r in ipairs(self.rows) do
        r:Hide()
        r:SetParent(nil)
    end

    wipe(self.rows)

    for pos = 1, #ItemTrackerDB.order do
        local row = CreateFrame("Frame", nil, content)
        row:SetSize(480, ROW_H)
        row:SetPoint("TOPLEFT", 0, -(pos - 1) * ROW_H)
        row.pos = pos

        -- HIGHLIGHT
        row.hl = row:CreateTexture(nil, "BACKGROUND")
        row.hl:SetAllPoints()
        row.hl:SetColorTexture(1, 1, 1, 0.15)
        row.hl:Hide()

        -- ICON
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(28, 28)
        row.icon:SetPoint("LEFT")

        -- NAME
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
        row.name:SetWidth(200)

        -- COUNT
        row.count = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.count:SetPoint("LEFT", row.name, "RIGHT", 6, 0)
        row.count:SetWidth(36)

        -- TIER BUTTON
        row.tier = CreateFrame("Button", nil, row, "BackdropTemplate")
        row.tier:SetSize(36, 20)
        row.tier:SetPoint("LEFT", row.count, "RIGHT", 6, 0)
        row.tier:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        })
        row.tier:SetBackdropColor(0, 0, 0, 0.8)

        row.tier.text = row.tier:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlightSmall"
        )
        row.tier.text:SetPoint("CENTER")

        row.tier:SetScript("OnMouseUp", function()
            TierDropDown.itemIndex = ItemTrackerDB.order[row.pos]
            ToggleDropDownMenu(1, nil, TierDropDown, "cursor", 0, 0)
        end)

        -- CONFIG BUTTON
        row.cfg = CreateFrame("Button", nil, row)
        row.cfg:SetSize(18, 18)
        row.cfg:SetPoint("LEFT", row.tier, "RIGHT", 6, 0)

        row.cfg.icon = row.cfg:CreateTexture(nil, "ARTWORK")
        row.cfg.icon:SetAllPoints()
        row.cfg.icon:SetTexture("Interface/Buttons/UI-OptionsButton")

        row.cfg:SetScript("OnEnter", function(self)
            self.icon:SetVertexColor(1, 0.82, 0)
        end)

        row.cfg:SetScript("OnLeave", function(self)
            self.icon:SetVertexColor(1, 1, 1)
        end)

        row.cfg:SetScript("OnClick", function()
            local index = ItemTrackerDB.order[row.pos]
            if not index then return end

            local itemID = ItemTracker.Items[index].itemID
            if not itemID then return end

            ItemTracker:ShowThresholdPopup(itemID)
        end)

        -- NOTE
        row.note = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        row.note:SetSize(40, 20)
        row.note:SetPoint("LEFT", row.cfg, "RIGHT", 6, 0)
        row.note:SetAutoFocus(false)
        row.note:SetFontObject(GameFontHighlightSmall)

        row.note:SetScript("OnEnterPressed", row.note.ClearFocus)
        row.note:SetScript("OnEscapePressed", row.note.ClearFocus)

        row.note:SetScript("OnEditFocusLost", function(self)
            ItemTrackerDB.notes[
                ItemTrackerDB.order[row.pos]
            ] = self:GetText()
        end)

        -- DRAG
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
                local x, y = GetCursorPosition()
                local s = UIParent:GetEffectiveScale()

                ghost:SetPoint(
                    "CENTER",
                    UIParent,
                    "BOTTOMLEFT",
                    x / s + 14,
                    y / s - 14
                )

                for _, r in ipairs(ItemTracker.rows) do
                    local yy = y / s
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

            for _, r in ipairs(ItemTracker.rows) do
                r.hl:Hide()
            end

            local y = select(2, GetCursorPosition())
                / UIParent:GetEffectiveScale()

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

        if row and item then
            local count = self:CountItem(item.itemID)
            local r, g, b = self:GetColor(count, item.itemID)

            row.pos = pos
            row:SetPoint("TOPLEFT", 0, -(pos - 1) * ROW_H)

            row.icon:SetTexture(GetItemIcon(item.itemID))
            row.name:SetText(item.name)
            row.name:SetTextColor(r, g, b)

            row.count:SetText(count)
            row.count:SetTextColor(r, g, b)

            row.tier.text:SetText(ItemTrackerDB.tiers[index] or "—")
            row.note:SetText(ItemTrackerDB.notes[index] or "")

            row:Show()
        end
    end

    content:SetHeight(#ItemTrackerDB.order * ROW_H)
end
