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


function ItemTracker:FullRecalculate()
    -- 1. ПОЛНАЯ пересборка базы
    if self.InitDB then
        self:InitDB()
    end

    -- 2. Индексация
    self:BuildAutoIndex()

    -- 3. ПОЛНЫЙ UI rebuild
    self:BuildRows()
    self:Update()

    if self.UpdateAutoUI then
        self:UpdateAutoUI()
    end
end


-- ==========================================================
-- ADD / REMOVE ITEM BUTTONS + POPUP
-- ==========================================================



-- базовая Y-линия для всех кнопок
local BTN_Y = -12
local BTN_SIZE = 20
local BTN_GAP = 4


local ShowPopup


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
addFrame:SetSize(200, 100)
addFrame:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 10,
})
addFrame:SetBackdropColor(0, 0, 0, 0.95)
addFrame:SetFrameStrata("DIALOG")
addFrame:SetClampedToScreen(true)
addFrame:Hide()


-- TITLE (ADD / REMOVE)
addFrame.title = addFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
addFrame.title:SetPoint("TOP", 0, -6)


-- INPUT
addFrame.input = CreateFrame("EditBox", nil, addFrame, "InputBoxTemplate")
addFrame.input:SetSize(110, 20)
addFrame.input:ClearAllPoints()
addFrame.input:SetPoint("TOPLEFT", 10, -10)
addFrame.input:SetNumeric(true)
addFrame.input:SetAutoFocus(false)
addFrame.input:SetScript("OnEnterPressed", function()
    addFrame.ok:Click()
end)
addFrame.input:SetScript("OnEscapePressed", function()
    addFrame:Hide()
end)


local function ItemExists(itemID)
    for _, it in ipairs(ItemTracker.BaseItems or {}) do
        if it.itemID == itemID then return true end
    end
    for _, it in ipairs(ItemTrackerDB.customItems or {}) do
        if it.itemID == itemID then return true end
    end
    return false
end

-- OK BUTTON
addFrame.ok = CreateFrame("Button", nil, addFrame, "UIPanelButtonTemplate")
addFrame.ok:ClearAllPoints()
addFrame.ok:SetSize(60, 20)
addFrame.ok:SetPoint("LEFT", addFrame.input, "RIGHT", 6, 0)
addFrame.ok:SetText("OK")


addFrame.ok:SetScript("OnClick", function()
    local text = addFrame.input:GetText()
    if not text or text == "" then return end

    local itemID = tonumber(text)
    if not itemID then return end

    if ItemTracker.popupMode == "add" then
        if not ItemExists(itemID) then
            local name = GetItemInfo(itemID)
            if name then
                ItemTracker:AddCustomItem(itemID)
                ItemTracker:FullRecalculate()
            end
        end
    else
        if ItemExists(itemID) then
            ItemTracker:RemoveCustomItem(itemID)
            ItemTracker:FullRecalculate()
        end
    end

    addFrame.input:SetText("")
    addFrame.input:SetFocus() -- окно остаётся открытым
end)








-- PASTE IDS BUTTON
addFrame.paste = CreateFrame("Button", nil, addFrame, "UIPanelButtonTemplate")
addFrame.paste:SetSize(60, 20)
addFrame.paste:SetPoint("TOP", addFrame.ok, "BOTTOM", 0, -6)
addFrame.paste:SetText("Import")



local exportFrame = CreateFrame("Frame", "ItemTrackerExportFrame", UIParent, "BackdropTemplate")
exportFrame:SetSize(260, 200)
exportFrame:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
})
exportFrame:SetBackdropColor(0, 0, 0, 0.95)
exportFrame:SetFrameStrata("DIALOG")
exportFrame:SetClampedToScreen(true)
exportFrame:Hide()

exportFrame:SetPoint("CENTER")

-- CLOSE (X)
exportFrame.close = CreateFrame("Button", nil, exportFrame, "UIPanelCloseButton")
exportFrame.close:SetPoint("TOPRIGHT", -20, 2)
exportFrame.close:SetScript("OnClick", function()
    exportFrame:Hide()
end)

-- ESC CLOSE
exportFrame:EnableKeyboard(true)
exportFrame:SetPropagateKeyboardInput(true)
exportFrame:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
        self:Hide()
    end
end)

-- SCROLL
exportFrame.scroll = CreateFrame("ScrollFrame", nil, exportFrame, "UIPanelScrollFrameTemplate")
exportFrame.scroll:SetPoint("TOPLEFT", 10, -10)
exportFrame.scroll:SetPoint("BOTTOMRIGHT", -30, 10)

-- EDITBOX
exportFrame.editBox = CreateFrame("EditBox", nil, exportFrame.scroll)
exportFrame.editBox:SetMultiLine(true)
exportFrame.editBox:SetFontObject(GameFontHighlightSmall)
exportFrame.editBox:SetWidth(200)
exportFrame.editBox:SetAutoFocus(false)
exportFrame.editBox:EnableMouse(true)
exportFrame.editBox:EnableKeyboard(true)


exportFrame.editBox:SetScript("OnEscapePressed", function()
    exportFrame:Hide()
end)

exportFrame.scroll:SetScrollChild(exportFrame.editBox)



addFrame.export = CreateFrame("Button", nil, addFrame, "UIPanelButtonTemplate")
addFrame.export:SetSize(60, 20)
addFrame.export:SetPoint("TOP", addFrame.paste, "BOTTOM", 0, -4)
addFrame.export:SetText("Export")

addFrame.export:SetScript("OnClick", function()
    local text = ItemTracker:BuildExportText()

    exportFrame:Show()
    exportFrame:Raise()
    exportFrame:SetFrameStrata("DIALOG")
    exportFrame:EnableMouse(true)
    exportFrame.editBox:EnableKeyboard(true)


    exportFrame.editBox:SetText(text)
    exportFrame.editBox:HighlightText()
    exportFrame.editBox:SetFocus()
end)




addFrame.close = CreateFrame("Button", nil, addFrame)
addFrame.close:SetSize(20, 20)
addFrame.close:SetPoint("TOPRIGHT", -0, -0)

addFrame.close.icon = addFrame.close:CreateTexture(nil, "ARTWORK")
addFrame.close.icon:SetAllPoints()
addFrame.close.icon:SetTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")

addFrame.close:SetScript("OnEnter", function(self)
    self.icon:SetVertexColor(1, 0.3, 0.3)
end)

addFrame.close:SetScript("OnLeave", function(self)
    self.icon:SetVertexColor(1, 1, 1)
end)

addFrame.close:SetScript("OnClick", function()
    addFrame:Hide()
end)


-- ==========================================================
-- MULTI IMPORT WINDOW (ADD / REMOVE)
-- ==========================================================

local importFrame = CreateFrame("Frame", "ItemTrackerImportFrame", UIParent, "BackdropTemplate")
importFrame:SetSize(360, 230)
importFrame:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
})
importFrame:SetBackdropColor(0, 0, 0, 0.95)
importFrame:SetFrameStrata("DIALOG")
importFrame:SetClampedToScreen(true)
importFrame:Hide()

importFrame:SetPoint("TOPLEFT", ItemTracker.mainFrame, "TOPRIGHT", 10, -20)


-- ==========================================================
-- ESC CLOSE (FRAME)
-- ==========================================================

importFrame:EnableKeyboard(true)
importFrame:SetPropagateKeyboardInput(true)

importFrame:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
        self:Hide()
    end
end)



-- ==========================================================
-- TITLE
-- ==========================================================

importFrame.title = importFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
importFrame.title:SetPoint("TOP", 0, -8)

-- ==========================================================
-- MULTILINE INPUT
-- ==========================================================

-- функция закрытия (ОБЯЗАТЕЛЬНО ДО SetScript)
local function CloseImportFrame()
    importFrame.editBox:SetText("") -- сброс текста
    importFrame:Hide()
end

-- SCROLL FRAME
importFrame.scroll = CreateFrame("ScrollFrame", nil, importFrame, "UIPanelScrollFrameTemplate")
importFrame.scroll:SetPoint("TOPLEFT", 10, -30)
importFrame.scroll:SetPoint("BOTTOMRIGHT", -30, 60)

-- EDIT BOX
importFrame.editBox = CreateFrame("EditBox", nil, importFrame.scroll)
importFrame.editBox:SetMultiLine(true)
importFrame.editBox:SetFontObject(GameFontHighlightSmall)
importFrame.editBox:SetWidth(280)
importFrame.editBox:SetAutoFocus(false)
importFrame.editBox:EnableMouse(true)

-- ESC в editBox → закрывает окно
importFrame.editBox:SetScript("OnEscapePressed", CloseImportFrame)

-- связываем scroll ↔ editBox
importFrame.scroll:SetScrollChild(importFrame.editBox)

-- ==========================================================
-- CLOSE BUTTON (X)
-- ==========================================================

importFrame.close = CreateFrame("Button", nil, importFrame, "UIPanelCloseButton")
importFrame.close:SetPoint("TOPRIGHT", 2, 2)
importFrame.close:SetScript("OnClick", CloseImportFrame)

-- ==========================================================
-- ESC В ЛЮБОМ МЕСТЕ ОКНА
-- ==========================================================
importFrame:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
        CloseImportFrame()
    end
end)




-- ==========================================================
-- BUTTONS
-- ==========================================================

local function CreateBtn(text, y)
    local b = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
    b:SetSize(120, 22)
    b:SetPoint("BOTTOM", 0, y)
    b:SetText(text)
    return b
end

importFrame.okBtn     = CreateBtn("OK", 30)
importFrame.clearBtn  = CreateBtn("CLEAR", 6)
importFrame.exportBtn = CreateBtn("EXPORT", -18)

-- ==========================================================
-- HELPERS
-- ==========================================================

local function ParseIDs(text)
    local ids = {}
    for num in string.gmatch(text or "", "%d+") do
        ids[tonumber(num)] = true
    end
    return ids
end



function ItemTracker:BuildExportText()
    local lines = {}

    for _, it in ipairs(ItemTracker.BaseItems or {}) do
        if it.itemID then
            table.insert(lines, tostring(it.itemID))
        end
    end

    for _, it in ipairs(ItemTrackerDB.customItems or {}) do
        if it.itemID then
            table.insert(lines, tostring(it.itemID))
        end
    end

    table.sort(lines, function(a, b)
        return tonumber(a) < tonumber(b)
    end)

    return table.concat(lines, "\n")
end


-- ==========================================================
-- OK BUTTON (ADD / REMOVE, WINDOW STAYS OPEN)
-- ==========================================================

importFrame.okBtn:SetScript("OnClick", function()
    local text = importFrame.editBox:GetText()
    if not text or text == "" then return end

    local ids = ParseIDs(text)
    local changed = 0

    for itemID in pairs(ids) do
        if ItemTracker.importMode == "add" then
            if not ItemExists(itemID) then
                local name = GetItemInfo(itemID)
                if name then
                    ItemTracker:AddCustomItem(itemID)
                    changed = changed + 1
                end
            end
        else -- REMOVE
            if ItemExists(itemID) then
                ItemTracker:RemoveCustomItem(itemID)
                changed = changed + 1
            end
        end
    end

    if changed > 0 then
        ItemTracker:FullRecalculate()
    end

    importFrame.editBox:SetText("") --
end)

-- ==========================================================
-- CLEAR
-- ==========================================================

importFrame.clearBtn:SetScript("OnClick", function()
    importFrame.editBox:SetText("")
end)

-- ==========================================================
-- EXPORT (ONLY FOR ADD)
-- ==========================================================

importFrame.exportBtn:SetScript("OnClick", function()
    print("Export not implemented yet")
end)

-- ==========================================================
-- OPEN FROM PASTE BUTTON
-- ==========================================================

ItemTracker.importMode = nil


addFrame.paste:SetScript("OnClick", function()
    if ItemTracker.popupMode == "add" then

        ItemTracker:OpenImportAdd()
    else
        ItemTracker:OpenImportRemove()
    end
end)





function ItemTracker:OpenImportAdd()
    self.importMode = "add"          -- 🔥 ВАЖНО
    importFrame.title:SetText("Add Item IDs")
    importFrame.exportBtn:Hide()
    importFrame:Show()
    importFrame.editBox:SetFocus()
end

function ItemTracker:OpenImportRemove()
    self.importMode = "remove"       -- 🔥 ВАЖНО
    importFrame.title:SetText("Remove Item IDs")
    importFrame.exportBtn:Hide()
    importFrame:Show()
    importFrame.editBox:SetFocus()
end




-- ==========================================================
-- ADD / REMOVE POPUP (SINGLE WINDOW, VISUAL MODES)
-- ==========================================================



ShowPopup = function(mode)
    -- mode: "add" | "remove"
    ItemTracker.popupMode = mode

    -- POSITION (RIGHT FROM CURSOR)
    local scale = UIParent:GetScale()
    local x, y = GetCursorPosition()
    x = x / scale
    y = y / scale

    addFrame:ClearAllPoints()
    addFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x + 40, y + 15)

    if ItemTracker.mainFrame then
        addFrame:SetFrameLevel(ItemTracker.mainFrame:GetFrameLevel() + 50)
    else
        addFrame:SetFrameStrata("DIALOG")
    end

    -- TITLE
    if addFrame.title then
        addFrame.title:SetText(mode == "add" and "Add items" or "Remove items")
    end

    -- OK BUTTON
    if addFrame.ok then
        addFrame.ok:SetText(mode == "add" and "ADD" or "Remove")
    end

    -- EXPORT BUTTON
    if addFrame.export then
        if mode == "add" then
            addFrame.export:Show()
        else
            addFrame.export:Hide()
        end
    end

    addFrame.input:SetText("")
    addFrame:Show()
    addFrame.input:SetFocus()
end




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

    local item = ItemTracker.Items[index]
    if not item then return end

    local itemID = item.itemID

    for _, tier in ipairs(ItemTracker.TIERS) do
        UIDropDownMenu_AddButton({
            text = tier,
            notCheckable = true,
            func = function()
                ItemTrackerDB.tiers[itemID] = tier
                CloseDropDownMenus()
                ItemTracker:Update()
            end,
        })
    end

    UIDropDownMenu_AddButton({
        text = "Clear",
        notCheckable = true,
        func = function()
            ItemTrackerDB.tiers[itemID] = nil
            CloseDropDownMenus()
            ItemTracker:Update()
        end,
    })
end

-- ==========================================================
-- THRESHOLD POPUP
-- ==========================================================

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

            local item = ItemTracker.Items[index]
            if not item then return end

            ItemTracker:ShowThresholdPopup(item.itemID)
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
            local index = ItemTrackerDB.order[row.pos]
            local item = ItemTracker.Items[index]
            if not item then return end

            ItemTrackerDB.notes[item.itemID] = self:GetText()
        end)

        -- DRAG
        row:EnableMouse(true)
        row:RegisterForDrag("LeftButton")

        row:SetScript("OnDragStart", function(self)
            self.dragFrom = self.pos
            self:SetAlpha(0.4)

            local index = ItemTrackerDB.order[self.pos]
            local item = ItemTracker.Items[index]
            if not item then return end

            local count = ItemTracker:CountInBags(item.itemID)
            local tier = ItemTrackerDB.tiers[item.itemID] or "—"

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
            local count = self:GetEffectiveItemCount(item.itemID)


            local r, g, b = self:GetColor(count, item.itemID)

            row.pos = pos
            row:SetPoint("TOPLEFT", 0, -(pos - 1) * ROW_H)

            row.icon:SetTexture(GetItemIcon(item.itemID))
            row.name:SetText(item.name)
            row.name:SetTextColor(r, g, b)

            row.count:SetText(count)
            row.count:SetTextColor(r, g, b)
            local itemID = item.itemID

            row.tier.text:SetText(ItemTrackerDB.tiers[itemID] or "—")
            row.note:SetText(ItemTrackerDB.notes[itemID] or "")


            row:Show()
        end
    end

    content:SetHeight(#ItemTrackerDB.order * ROW_H)
end

function ItemTracker:GetEffectiveItemCount(itemID)
    return self:CountItem(itemID)
end





