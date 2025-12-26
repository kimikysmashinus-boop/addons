-- ==========================================================
-- ItemTracker — Classic Era 1.15+
-- Индивидуальные пороги для каждого предмета (ItemThresholds)
-- Только potion-логика, materials удалены
-- ==========================================================

local addonName = ...
local ItemTracker = {}
_G[addonName] = ItemTracker

ItemTracker.auctionCache = {}

-- ==========================================================
-- ТАБЛИЦА ИНДИВИДУАЛЬНЫХ ПОРОГОВ
-- Если предмет тут указан → используется эта логика
-- Если нет → используется базовая логика
-- ==========================================================

local sameThresholds = {
    { limit = 5,   r=1,   g=0,   b=0   },
    { limit = 25,  r=0.7, g=0.7, b=0.7 },
    { limit = 55,  r=1,   g=1,   b=0   },
    { limit = 75,  r=0,   g=1,   b=0   },
    { limit = 999, r=1,   g=0.4, b=0.7 },
}

ItemTracker.ItemThresholds = {
    [3389]  = sameThresholds,  -- Mighty Troll's Blood Potion
    [13463] = sameThresholds,  -- Dreamfoil
}



-- ==========================================================
-- КАТЕГОРИИ (без materials)
-- ==========================================================

ItemTracker.Categories = {

    {
        name = "Dreamfoil",
        mainItem = { itemID = 13463, name = "Dreamfoil" },
        collapsed = false,
        items = {
            { itemID = 13457, name = "Greater Fire Protection Potion" },
            { itemID = 13458, name = "Greater Nature Protection Potion" },
            { itemID = 13459, name = "Greater Shadow Protection Potion" },
            { itemID = 13456, name = "Greater Frost Protection Potion" },
            { itemID = 13461, name = "Greater Arcane Protection Potion" },
            { itemID = 13454, name = "Greater Arcane Elixir" },
            { itemID = 18253, name = "Major Rejuvenation Potion" },
            { itemID = 13452, name = "Elixir of Moongoose" },
            { itemID = 13447, name = "Elixir of Sages" },
            

        }
    },

    {
        name = "Gromsblood",
        mainItem = { itemID = 8846, name = "Gromsblood" },
        collapsed = false,
        items = {
            { itemID = 9206, name = "Elixir of Giants" },
            { itemID = 9224, name = "Elixir of Demonslaying" },
            { itemID = 13453, name = "Elixir of Brute Force" },
            { itemID = 13442, name = "Mighty Rage Potion" },
        }
    },

    {
        name = "Stonescale Oil",
        mainItem = { itemID = 13423, name = "Stonescale Oil" },
        collapsed = false,
        items = {
            { itemID = 13455, name = "Greater Stoneshield Potion" },
            { itemID = 13445, name = "Elixir of Superior Defense" },
        }
    },

    {
        name = "Ghost Mushroom",
        mainItem = { itemID = 8845, name = "Ghost Mushroom" },
        collapsed = false,
        items = {
            { itemID = 9264, name = "Elixir of Shadow Power" },
            { itemID = 9172, name = "Invisibility Potion" },
            { itemID = 9210, name = "Ghost Dye" },
            { itemID = 3387, name = "Limited Invulnerability Potion" },
            { itemID = 8839, name = "Blindweed" },
            { itemID = 9088, name = "Gift of Arthas" },
        }
    },

    {
        name = "Goldthorn",
        mainItem = { itemID = 3821, name = "Goldthorn" },
        collapsed = false,
        items = {
            { itemID = 9187, name = "Elixir of Greater Agility" },
            { itemID = 8951, name = "Elixir of Greater Defense" },
            { itemID = 3825, name = "Elixir of Fortitude" },
            { itemID = 4625, name = "Firebloom" },
            { itemID = 8956, name = "Oil of Immolation" },
            { itemID = 21546, name = "Elixir of Greater Firepower" },
            { itemID = 9061, name = "Goblin Rocket Fuel" },
        }
    },

    {
        name = "Fadeleaf",
        mainItem = { itemID = 3818, name = "Fadeleaf" },
        collapsed = false,
        items = {
            { itemID = 3823, name = "Lesser Invisibility Potion" },
            { itemID = 3369, name = "Grave Moss" },
            { itemID = 3824, name = "Shadow Oil" },
            { itemID = 6048, name = "Shadow Protection Potion" },
        }
    },

    {
        name = "Swiftthistle",
        mainItem = { itemID = 2452, name = "Swiftthistle" },
        collapsed = false,
        items = {
            { itemID = 2459, name = "Swiftness Potion" },
            { itemID = 2457, name = "Elixir of Minor Agility" },
            { itemID = 3390, name = "Elixir of Lesser Agility" },
            { itemID = 3355, name = "Wild Steelbloom" },
            { itemID = 3389, name = "Elixir of Defense" },
        }
    },

    {
        name = "Stranglekelp",
        mainItem = { itemID = 3820, name = "Stranglekelp" },
        collapsed = false,
        items = {
            { itemID = 3389, name = "Mighty Troll's Blood Potion" },
            { itemID = 6052, name = "Nature Protection Potion" },
            { itemID = 5634, name = "Free Action Potion" },
        }
    },

    {
        name = "Large Venom Sac",
        mainItem = { itemID = 1288, name = "Large Venom Sac" },
        collapsed = false,
        items = {
            { itemID = 3386, name = "Elixir of Poison Resistance" },
            { itemID = 6662, name = "Elixir of Giant Growth" },
            { itemID = 3829, name = "Frost Oil" },
        }
    },

    {
        name = "Small Flame",
        mainItem = { itemID = 4402, name = "Small Flame" },
        collapsed = false,
        items = {
            { itemID = 12217, name = "Dragonbreath chill" },
            { itemID = 20452, name = "Smoked Desert" },
            { itemID = 12218, name = "Monster Omlet" },
                
        }
    },
    {
        name = "Rugged Leather",
        mainItem = { itemID = 8170, name = "Rugged Leather" },
        collapsed = false,
        items = {
            { itemID = 15564, name = "Rugged Armor Kit" },
            { itemID = 15062, name = "Devilasaur leggins" },
            { itemID = 15063, name = "Devilasaur Gauntaled" },
            { itemID = 15064, name = "Warbear Harness" },
            { itemID = 15066, name = "ironfeather breastplate" },
            { itemID = 15067, name = "ironfeather Shoulders" },
            { itemID = 6468, name = "Deviate scale belt" },
            { itemID = 6467, name = "Deviate scale gloves" },
                
        }
    },

}

-- ==========================================================
-- БАЗОВАЯ ЦВЕТОВАЯ СХЕМА
-- ==========================================================

function ItemTracker:GetBaseColor(count)
    if count <= 4 then return 1,0,0
    elseif count <= 19 then return 0.7,0.7,0.7
    elseif count <= 34 then return 1,1,0
    elseif count <= 40 then return 0,1,0
    else return 1,0.4,0.7 end
end

-- ==========================================================
-- Индивидуальная логика цвета
-- ==========================================================

function ItemTracker:GetItemColor(itemID, count)
    local t = ItemTracker.ItemThresholds[itemID]

    -- если есть индивидуальные пороги → используем их
    if t then
        for _, th in ipairs(t) do
            if count <= th.limit then
                return th.r, th.g, th.b
            end
        end
    end

    -- иначе базовая логика
    return ItemTracker:GetBaseColor(count)
end

-- ==========================================================
-- Подсчёт предметов (Bags + Bank + Mail + Auctions)
-- ==========================================================

function ItemTracker:CountItem(itemID)
    local total = 0

    -- Bags
    for bag = 0,4 do
        local slots = C_Container.GetContainerNumSlots(bag)
        if slots then
            for slot = 1, slots do
                local id = C_Container.GetContainerItemID(bag, slot)
                if id == itemID then
                    local info = C_Container.GetContainerItemInfo(bag, slot)
                    total = total + (info and info.stackCount or 1)
                end
            end
        end
    end

    -- Bank
    if BankFrame and BankFrame:IsShown() then
        for bag = -1, 11 do
            local slots = C_Container.GetContainerNumSlots(bag)
            if slots then
                for slot = 1, slots do
                    local id = C_Container.GetContainerItemID(bag, slot)
                    if id == itemID then
                        local info = C_Container.GetContainerItemInfo(bag, slot)
                        total = total + (info and info.stackCount or 1)
                    end
                end
            end
        end
    end

    -- Mail
    for msg = 1, GetInboxNumItems() do
        for att = 1, ATTACHMENTS_MAX_RECEIVE or 2 do
            local _, id, _, count = GetInboxItem(msg, att)
            if id == itemID then total = total + (count or 1) end
        end
    end

    -- Auction
    for _, auc in ipairs(ItemTracker.auctionCache) do
        if auc.itemID == itemID then
            total = total + auc.count
        end
    end

    return total
end

-- ==========================================================
-- UI + ScrollFrame
-- ==========================================================

local frame = CreateFrame("Frame", "ItemTrackerFrame", UIParent)
ItemTracker.Frame = frame

local screenHeight = UIParent:GetHeight()
frame:SetSize(320, screenHeight * 0.55)

frame:SetPoint("CENTER")
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(frame)
bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
bg:SetVertexColor(0,0,0,0.85)

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOP", 0, -10)
frame.title:SetText("ItemTracker")

local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 4, -35)
scroll:SetPoint("BOTTOMRIGHT", -26, 4)

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(1,1)
scroll:SetScrollChild(content)
frame.content = content

local function CreateLine(parent, offsetY)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("TOPLEFT", 10, offsetY)
    fs:SetJustifyH("LEFT")
    return fs
end

local nextY = -10
for _, cat in ipairs(ItemTracker.Categories) do
    local btn = CreateFrame("Button", nil, content)
    btn:SetPoint("TOPLEFT", 10, nextY)
    btn:SetSize(250, 18)

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.text:SetPoint("LEFT")

    cat.button = btn
    btn:SetScript("OnClick", function()
        cat.collapsed = not cat.collapsed
        ItemTracker:UpdateWindow()
    end)

    nextY = nextY - 20

    for _, item in ipairs(cat.items) do
        item.line = CreateLine(content, nextY)
        nextY = nextY - 18
    end
end

content:SetHeight(-nextY + 20)

-- ==========================================================
-- Update Window
-- ==========================================================

function ItemTracker:UpdateWindow()
    local y = -10

    for _, cat in ipairs(ItemTracker.Categories) do
        local count = ItemTracker:CountItem(cat.mainItem.itemID)
        local r,g,b = ItemTracker:GetItemColor(cat.mainItem.itemID, count)

        local symbol = cat.collapsed and "▶" or "▼"
        cat.button:SetPoint("TOPLEFT", 10, y)
        cat.button.text:SetText(symbol .. "  " .. cat.mainItem.name .. ": " .. count)
        cat.button.text:SetTextColor(r,g,b)

        y = y - 20

        if not cat.collapsed then
            for _, item in ipairs(cat.items) do
                local c = ItemTracker:CountItem(item.itemID)
                local rr,gg,bb = ItemTracker:GetItemColor(item.itemID, c)

                item.line:SetText(item.name .. ": " .. c)
                item.line:SetTextColor(rr,gg,bb)
                item.line:SetPoint("TOPLEFT", 30, y)
                item.line:Show()

                y = y - 18
            end
        else
            for _, item in ipairs(cat.items) do
                item.line:Hide()
            end
        end
    end

    frame.content:SetHeight(-y + 20)
end

-- ==========================================================
-- Events
-- ==========================================================

local ev = CreateFrame("Frame")
ev:RegisterEvent("BAG_UPDATE")
ev:RegisterEvent("MAIL_INBOX_UPDATE")
ev:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
ev:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")

ev:SetScript("OnEvent", function(_, event)
    if event == "AUCTION_OWNED_LIST_UPDATE" then
        ItemTracker.auctionCache = {}
        local total = GetNumAuctionItems("owner")
        for i = 1, total do
            local link = GetAuctionItemLink("owner", i)
            if link then
                local id = tonumber(link:match("item:(%d+):"))
                local _,_,count = GetAuctionItemInfo("owner", i)
                table.insert(ItemTracker.auctionCache, { itemID = id, count = count or 1 })
            end
        end
    end

    if ItemTracker.Frame:IsShown() then
        ItemTracker:UpdateWindow()
    end
end)

-- ==========================================================
-- Slash Command
-- ==========================================================

SLASH_ITEMTRACKER1 = "/it"
SlashCmdList["ITEMTRACKER"] = function()
    if ItemTracker.Frame:IsShown() then
        ItemTracker.Frame:Hide()
    else
        ItemTracker:UpdateWindow()
        ItemTracker.Frame:Show()
    end
end

-- авто-открытие
local auto = CreateFrame("Frame")
auto:RegisterEvent("PLAYER_LOGIN")
auto:SetScript("OnEvent", function()
    ItemTracker.Frame:Show()
    ItemTracker:UpdateWindow()
end)

print("ItemTracker loaded. Use /it")
