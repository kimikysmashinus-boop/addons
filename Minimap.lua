-- ==========================================================
-- ItemTracker — Minimap Button (CLASSIC SAFE, DRAGGABLE)
-- ==========================================================

local addonName = ...
local ItemTracker = _G[addonName]
if not ItemTracker then return end

-- ==========================================================
-- CONSTANTS
-- ==========================================================
local RADIUS = 80
local DEFAULT_ANGLE = 45

-- ==========================================================
-- BUTTON
-- ==========================================================
local btn = CreateFrame("Button", "ItemTrackerMinimapButton", Minimap)
btn:SetSize(32, 32)
btn:SetFrameStrata("MEDIUM")
btn:SetFrameLevel(8)

btn:EnableMouse(true)
btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
btn:RegisterForDrag("LeftButton")

-- ==========================================================
-- ICON
-- ==========================================================
local icon = btn:CreateTexture(nil, "ARTWORK")
icon:SetSize(20, 20)
icon:SetPoint("CENTER")
icon:SetTexture("Interface/Icons/Racial_Dwarf_FindTreasure")

-- ROUND MASK
local mask = btn:CreateMaskTexture()
mask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask")
mask:SetAllPoints(icon)
icon:AddMaskTexture(mask)

-- BORDER
local border = btn:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface/Minimap/MiniMap-TrackingButtonBorder")
border:SetAllPoints(btn)

-- ==========================================================
-- POSITION
-- ==========================================================
local function UpdatePosition()
    local angle = ItemTrackerDB.minimap.angle or DEFAULT_ANGLE
    local rad = math.rad(angle)

    btn:ClearAllPoints()
    btn:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        math.cos(rad) * RADIUS,
        math.sin(rad) * RADIUS
    )
end

-- ==========================================================
-- DRAG
-- ==========================================================
btn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local mx, my = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()

        mx, my = mx / scale, my / scale
        local cx, cy = Minimap:GetCenter()

        ItemTrackerDB.minimap.angle =
            math.deg(math.atan2(my - cy, mx - cx))

        UpdatePosition()
    end)
end)

btn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

-- ==========================================================
-- SETTINGS WINDOW TOGGLE (REAL ONE)
-- ==========================================================
function ItemTracker:ToggleSettingsWindow()
    local f = self.settingsFrame
    if not f then
        print("ItemTracker: settingsFrame not found")
        return
    end

    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end

-- ==========================================================
-- RIGHT CLICK MENU (CLASSIC SAFE)
-- ==========================================================
local menuFrame = CreateFrame(
    "Frame",
    "ItemTrackerMinimapMenu",
    UIParent,
    "UIDropDownMenuTemplate"
)

local function InitMenu()
    UIDropDownMenu_AddButton({
        text = "ItemTracker",
        isTitle = true,
        notCheckable = true,
    })

    UIDropDownMenu_AddButton({
        text = "Toggle settings window",
        notCheckable = true,
        func = function()
            ItemTracker:ToggleSettingsWindow()
        end,
    })

    UIDropDownMenu_AddButton({
        text = CLOSE,
        notCheckable = true,
        func = CloseDropDownMenus,
    })
end

local function ShowMenu(self)
    UIDropDownMenu_Initialize(menuFrame, InitMenu, "MENU")
    ToggleDropDownMenu(1, nil, menuFrame, self, 0, 0)
end

-- ==========================================================
-- CLICK HANDLER
-- ==========================================================
btn:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        local f = ItemTracker.mainFrame
        if not f then return end

        if f:IsShown() then
            f:Hide()
        else
            f:Show()
        end

    elseif button == "RightButton" then
        ShowMenu(self)
    end
end)

-- ==========================================================
-- TOOLTIP
-- ==========================================================
btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("ItemTracker", 1, 1, 1)
    GameTooltip:AddLine("Left Click: Main window", 0.9, 0.9, 0.9)
    GameTooltip:AddLine("Right Click: Settings", 0.9, 0.9, 0.9)
    GameTooltip:AddLine("Drag: Move button", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

btn:SetScript("OnLeave", GameTooltip_Hide)

-- ==========================================================
-- INIT
-- ==========================================================
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, _, name)
    if name ~= addonName then return end

    ItemTrackerDB = ItemTrackerDB or {}
    ItemTrackerDB.minimap = ItemTrackerDB.minimap or {
        angle = DEFAULT_ANGLE,
    }

    UpdatePosition()
    btn:Show()
end)
