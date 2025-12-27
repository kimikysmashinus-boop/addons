-- Utils.lua

local addonName = ...
local ItemTracker = _G[addonName]

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

function ItemTracker:GetColor(count, itemID)
    local t = ItemTrackerDB.colorThresholds[itemID]
    local d = ItemTrackerDB.defaultThresholds

    local gray   = (t and t.gray)   or d.gray
    local yellow = (t and t.yellow) or d.yellow
    local green  = (t and t.green)  or d.green

    if count <= gray   then return 0.6,0.6,0.6 end
    if count <= yellow then return 1,1,0 end
    if count <= green  then return 0,1,0 end
    return 1,0,0
end

function ItemTracker:MoveIndex(tbl, from, to)
    if not tbl or from == to then return end
    local v = table.remove(tbl, from)
    table.insert(tbl, to, v)
end
