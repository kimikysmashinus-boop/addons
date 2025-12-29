-- Utils.lua

local addonName = ...
local ItemTracker = _G[addonName]

function ItemTracker:CountItem(itemID)
    local bags = GetItemCount(itemID, false)
    local bank = GetItemCount(itemID, true) - bags
    local auction = self.auctionCache[itemID] or 0
   


    return bags + bank + auction
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


