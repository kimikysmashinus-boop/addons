local button = CreateFrame("Button", "ClassicItemTrackerMinimap", Minimap)
button:SetSize(28,28)
local t = button:CreateTexture(nil, "BACKGROUND")
t:SetAllPoints(button)
t:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
button:SetPoint("CENTER", Minimap, "CENTER", 80, 10)

button:SetScript("OnClick", function(self, btn)
    if btn == "LeftButton" then
        print("ClassicItemTracker: minimap button clicked")
    end
end)

button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("ClassicItemTracker")
    GameTooltip:Show()
end)
button:SetScript("OnLeave", function() GameTooltip:Hide() end)
