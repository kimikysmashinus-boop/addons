-- ==========================================================
-- ITEMTRACKER — SETTINGS WINDOW (FULLY WORKING)
-- ==========================================================

local ItemTracker = ItemTracker or {}
_G.ItemTracker = ItemTracker

-- ==========================================================
-- COLORS
-- ==========================================================

ItemTracker.STATE_COLORS = {
    gray    = { 0.6, 0.6, 0.6 },
    yellow  = { 1.0, 0.82, 0.0 },
    green   = { 0.2, 1.0, 0.2 },
    red     = { 1.0, 0.2, 0.2 },
    missing = { 0.5, 0.5, 1.0 }, -- синий
}

-- ==========================================================
-- SAFE DEFAULTS (CRITICAL)
-- ==========================================================

ItemTracker.AUTO_UI = {
    rowHeight  = 35, -- >= iconSize
    rowSpacing = 6,
    iconSize   = 31,
}

ItemTrackerDB = ItemTrackerDB or {}

ItemTrackerDB.defaultThresholds = ItemTrackerDB.defaultThresholds or {
    gray   = 9,
    yellow = 15,
    green  = 25,
}

ItemTrackerDB.colorThresholds = ItemTrackerDB.colorThresholds or {}
ItemTrackerDB.order           = ItemTrackerDB.order or {}
ItemTracker.Items             = ItemTracker.Items or {}

-- ==========================================================
-- BASE SETTINGS FRAME
-- ==========================================================

local settingsFrame = CreateFrame(
    "Frame",
    "ItemTrackerSettingsFrame",
    UIParent,
    "BackdropTemplate"
)

ItemTracker.settingsFrame = settingsFrame

settingsFrame:SetSize(360, 220)
settingsFrame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
settingsFrame:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 14,
})
settingsFrame:SetBackdropColor(0, 0, 0, 0.9)

settingsFrame:SetMovable(true)
settingsFrame:EnableMouse(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", settingsFrame.StartMoving)
settingsFrame:SetScript("OnDragStop", settingsFrame.StopMovingOrSizing)
settingsFrame:Hide()

-- ==========================================================
-- AUTO SHOW SETTINGS ON LOGIN
-- ==========================================================

local autoShow = CreateFrame("Frame")
autoShow:RegisterEvent("PLAYER_LOGIN")
autoShow:SetScript("OnEvent", function()
    if ItemTracker.settingsFrame then
        ItemTracker.settingsFrame:Show()
    end
end)

-- ==========================================================
-- COLUMN DEFINITIONS (SOURCE OF TRUTH)
-- ==========================================================

local COLUMN_COUNT = #ItemTracker.COLUMNS

-- ==========================================================
-- HEADER
-- ==========================================================

local HEADER_HEIGHT = 28

local header = CreateFrame("Frame", nil, settingsFrame)
settingsFrame.header = header

header:SetHeight(HEADER_HEIGHT)
header:SetPoint("TOPLEFT")
header:SetPoint("TOPRIGHT")

header.bg = header:CreateTexture(nil, "BACKGROUND")
header.bg:SetAllPoints()
header.bg:SetColorTexture(0, 0, 0, 0.4)

header.line = header:CreateTexture(nil, "ARTWORK")
header.line:SetHeight(1)
header.line:SetPoint("BOTTOMLEFT", 6, 0)
header.line:SetPoint("BOTTOMRIGHT", -6, 0)
header.line:SetColorTexture(1, 1, 1, 0.15)

-- ==========================================================
-- CONTENT AREA
-- ==========================================================

local scrollFrame = CreateFrame(
    "ScrollFrame",
    nil,
    settingsFrame,
    "UIPanelScrollFrameTemplate"
)

settingsFrame.scrollFrame = scrollFrame

scrollFrame:SetPoint("TOPLEFT", 8, -HEADER_HEIGHT - 8)
scrollFrame:SetPoint("BOTTOMRIGHT", -8, 8)

local content = CreateFrame("Frame", nil, scrollFrame)
settingsFrame.content = content

content:SetPoint("TOPLEFT")
content:SetWidth(320)
content:SetHeight(1)

scrollFrame:SetScrollChild(content)

-- ==========================================================
-- CREATE COLUMNS
-- ==========================================================

settingsFrame.columns = {}
local columns = settingsFrame.columns

for i, colDef in ipairs(ItemTracker.COLUMNS) do
    local col = CreateFrame("Frame", nil, content)
    columns[colDef.key] = col

    col:SetPoint("TOP")
    col:SetPoint("BOTTOM")

    if i == 1 then
        col:SetPoint("LEFT", content, "LEFT", 0, 0)
    else
        local prevKey = ItemTracker.COLUMNS[i - 1].key
        col:SetPoint("LEFT", columns[prevKey], "RIGHT", 0, 0)
    end
end

-- ==========================================================
-- DIVIDERS
-- ==========================================================

for i = 1, COLUMN_COUNT - 1 do
    local key = ItemTracker.COLUMNS[i].key
    local line = content:CreateTexture(nil, "ARTWORK")

    line:SetWidth(1)
    line:SetColorTexture(1, 1, 1, 0.12)
    line:SetPoint("TOP", columns[key], "TOP")
    line:SetPoint("BOTTOM", columns[key], "BOTTOM")
    line:SetPoint("LEFT", columns[key], "RIGHT", 0, 0)
end

-- ==========================================================
-- AUTO FRAMES POOL
-- ==========================================================

ItemTracker.AutoFrames = {}

for _, colDef in ipairs(ItemTracker.COLUMNS) do
    ItemTracker.AutoFrames[colDef.key] = {}
end

-- ==========================================================
-- CLEAR COLUMN
-- ==========================================================

function ItemTracker:ClearAutoColumn(columnKey)
    for _, row in ipairs(self.AutoFrames[columnKey] or {}) do
        row:Hide()
    end
end

-- ==========================================================
-- RENDER COLUMN
-- ==========================================================

function ItemTracker:RenderAutoColumn(columnKey)
    local parent = self.settingsFrame.columns[columnKey]
    local list   = self.AutoIndex and self.AutoIndex[columnKey]
    local pool   = self.AutoFrames and self.AutoFrames[columnKey]
    local ui     = self.AUTO_UI

    if not parent or not list or not pool then
        return
    end

    self:ClearAutoColumn(columnKey)

    local offsetY = -8

    for i, itemID in ipairs(list) do
        local row = pool[i]

        if not row then
            row = CreateFrame("Frame", nil, parent)
            pool[i] = row

            -- ИКОНКА (фрейм)
            row.icon = CreateFrame("Frame", nil, row)
            row.icon:SetPoint("LEFT", 0, 0)
            row.icon:SetSize(ui.iconSize, ui.iconSize)

            row.icon.tex = row.icon:CreateTexture(nil, "ARTWORK")
            row.icon.tex:SetAllPoints()

            -- ТЕКСТ
            row.count = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.count:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
        end

        -- размеры строки
        row:SetSize(parent:GetWidth() - 16, ui.rowHeight)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, offsetY)
        row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)

        -- данные
        row.icon.tex:SetTexture(GetItemIcon(itemID) or "Interface\\Icons\\INV_Misc_QuestionMark")
        row.count:SetText(self:CountItem(itemID) or 0)

        -- ===============================
        -- 🎨 ВИЗУАЛ
        -- ===============================
        if columnKey == "missing" then
            -- жёлтый текст
            row.count:SetTextColor(1.0, 0.82, 0.0)

            -- glow ВКЛ
            if not row.icon.__glowing then
                ActionButton_ShowOverlayGlow(row.icon)
                row.icon.__glowing = true

                -- увеличение glow
                if row.icon.overlay then
                    row.icon.overlay:SetScale(1.25)
                end
            end
        else
            -- обычные колонки
            local state = self:GetItemColorKey(itemID)
            local clr   = self.STATE_COLORS and self.STATE_COLORS[state]

            if clr then
                row.count:SetTextColor(clr[1], clr[2], clr[3])
            else
                row.count:SetTextColor(1, 1, 1)
            end

            -- glow ВЫКЛ
            if row.icon.__glowing then
                ActionButton_HideOverlayGlow(row.icon)
                row.icon.__glowing = nil
            end
        end

        row:Show()
        offsetY = offsetY - ui.rowHeight - ui.rowSpacing
    end
end





-- ==========================================================
-- LAYOUT UPDATE
-- ==========================================================

local function UpdateColumnsLayout()
    local scrollbarWidth = 20
    local width = (content:GetWidth() - scrollbarWidth) / COLUMN_COUNT

    for _, col in pairs(columns) do
        col:SetWidth(width)
    end
end

content:SetScript("OnSizeChanged", UpdateColumnsLayout)
settingsFrame:SetScript("OnShow", UpdateColumnsLayout)



local scrollBar = scrollFrame.ScrollBar or scrollFrame.scrollBar

if scrollBar then
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", -7, -HEADER_HEIGHT - 20)
    scrollBar:SetPoint("BOTTOMRIGHT", settingsFrame, "BOTTOMRIGHT", -2, 22)
end


-- ==========================================================
-- UPDATE UI
-- ==========================================================

settingsFrame:SetScript("OnShow", function()
    ItemTracker:UpdateAutoUI()
end)

function ItemTracker:UpdateAutoUI()
    if not self.settingsFrame:IsShown() then
        return
    end

    self:BuildAutoIndex()

    for _, colDef in ipairs(self.COLUMNS) do
        self:RenderAutoColumn(colDef.key)
    end

    self:UpdateContentHeight()
end

function ItemTracker:UpdateContentHeight()
    local ui = self.AUTO_UI
    local maxRows = 0

    for _, colDef in ipairs(self.COLUMNS) do
        local list = self.AutoIndex and self.AutoIndex[colDef.key]
        if list then
            maxRows = math.max(maxRows, #list)
        end
    end

    local height =
        16 +
        maxRows * ui.rowHeight +
        math.max(0, maxRows - 1) * ui.rowSpacing +
        16

    self.settingsFrame.content:SetHeight(height)
end
