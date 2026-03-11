local addon = LFMTracker

local lines = {}
local roleTabs = {}
local raidTabs = {}
local filterText
local pageUpBtn
local pageDownBtn

local LINE_HEIGHT = 24

local function BuildFilteredEntries()
    local filtered = {}

    for _, entry in ipairs(addon.entries) do
        if addon:MatchesActiveFilters(entry.msg) then
            table.insert(filtered, entry)
        end
    end

    addon.filteredEntries = filtered
    return filtered
end

function addon:ApplyOpacity()
    if self.ui then
        self.ui:SetBackdropColor(0.05, 0.05, 0.08, LFMTrackerDB.opacity)
    end
end

function addon:RefreshTabVisuals()
    for _, tab in ipairs(roleTabs) do
        if tab.role == self.currentRole then
            tab:LockHighlight()
        else
            tab:UnlockHighlight()
        end
    end

    for _, tab in ipairs(raidTabs) do
        if self.selectedRaids[tab.raid] then
            tab:LockHighlight()
        else
            tab:UnlockHighlight()
        end
    end
end

function addon:ApplyLayout()
    if not self.ui then
        return
    end

    local collapsed = LFMTrackerDB.filtersCollapsed
    if collapsed then
        self.roleContainer:Hide()
        self.raidContainer:Hide()
        self.ui:SetHeight(300)
        self.listStartY = -82
    else
        self.roleContainer:Show()
        self.raidContainer:Show()
        self.ui:SetHeight(350)
        self.listStartY = -118
    end

    for i = 1, self.maxLines do
        lines[i]:SetPoint("TOPLEFT", 12, self.listStartY - ((i - 1) * LINE_HEIGHT))
    end

    pageUpBtn:ClearAllPoints()
    pageUpBtn:SetPoint("TOPLEFT", 446, self.listStartY)
    pageDownBtn:ClearAllPoints()
    pageDownBtn:SetPoint("TOPLEFT", 446, self.listStartY - 24)

    self.compactBtn:SetText(collapsed and "Filters" or "Compact")
    self:RefreshList()
end

function addon:RefreshList()
    if not self.ui then
        return
    end

    local filtered = BuildFilteredEntries()
    local total = table.getn(filtered)
    local maxOffset = total - self.maxLines
    if maxOffset < 0 then
        maxOffset = 0
    end

    if self.scrollOffset < 0 then
        self.scrollOffset = 0
    elseif self.scrollOffset > maxOffset then
        self.scrollOffset = maxOffset
    end

    for i = 1, self.maxLines do
        local index = self.scrollOffset + i
        local row = lines[i]

        if index <= total then
            local e = filtered[index]
            local shortMsg = e.msg
            if string.len(shortMsg) > 60 then
                shortMsg = string.sub(shortMsg, 1, 57) .. "..."
            end

            row.text:SetText(e.sender .. ": " .. shortMsg)
            row.player = e.sender
            row.fullMessage = e.sender .. ": " .. e.msg
            row.bg:Show()
            row.text:Show()
            row:Show()
        else
            row.text:SetText("")
            row.player = nil
            row.fullMessage = nil
            row.bg:Hide()
            row.text:Hide()
            row:Hide()
        end
    end

    if total > self.maxLines then
        filterText:SetText("Role: " .. self.currentRole .. " | Raid: " .. self:GetRaidFilterLabel() .. " | " .. total .. " [" .. (self.scrollOffset + 1) .. "-" .. math.min(self.scrollOffset + self.maxLines, total) .. "]")
    else
        filterText:SetText("Role: " .. self.currentRole .. " | Raid: " .. self:GetRaidFilterLabel() .. " | " .. total)
    end

    if self.scrollOffset <= 0 then
        pageUpBtn:Disable()
    else
        pageUpBtn:Enable()
    end

    if self.scrollOffset >= maxOffset then
        pageDownBtn:Disable()
    else
        pageDownBtn:Enable()
    end

    self:RefreshTabVisuals()
end

function addon:CreateUI()
    local ui = CreateFrame("Frame", "LFMTrackerUI", UIParent)
    self.ui = ui

    ui:SetWidth(500)
    ui:SetHeight(350)
    ui:SetPoint("CENTER", 0, 180)
    ui:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = 1,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    ui:SetBackdropBorderColor(0.45, 0.45, 0.55)
    ui:EnableMouse(true)
    ui:SetMovable(true)
    ui:RegisterForDrag("LeftButton")
    ui:SetScript("OnDragStart", function() this:StartMoving() end)
    ui:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    ui:EnableMouseWheel(true)
    ui:SetScript("OnMouseWheel", function()
        if arg1 > 0 then
            addon.scrollOffset = addon.scrollOffset - 1
        else
            addon.scrollOffset = addon.scrollOffset + 1
        end
        addon:RefreshList()
    end)

    local title = ui:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText("LFMTracker")

    local closeBtn = CreateFrame("Button", nil, ui, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() ui:Hide() end)

    self.compactBtn = CreateFrame("Button", nil, ui, "UIPanelButtonTemplate")
    self.compactBtn:SetWidth(78)
    self.compactBtn:SetHeight(20)
    self.compactBtn:SetPoint("TOPRIGHT", -52, -30)
    self.compactBtn:SetText("Compact")
    self.compactBtn:SetScript("OnClick", function()
        LFMTrackerDB.filtersCollapsed = not LFMTrackerDB.filtersCollapsed
        addon:ApplyLayout()
    end)

    self.roleContainer = CreateFrame("Frame", nil, ui)
    self.roleContainer:SetWidth(320)
    self.roleContainer:SetHeight(26)
    self.roleContainer:SetPoint("TOPLEFT", 12, -32)

    for i, role in ipairs(self.roles) do
        local tab = CreateFrame("Button", nil, self.roleContainer, "UIPanelButtonTemplate")
        tab:SetWidth(74)
        tab:SetHeight(20)
        tab:SetPoint("LEFT", (i - 1) * 78, 0)
        tab:SetText(role)
        tab.role = role
        tab:SetScript("OnClick", function()
            addon.currentRole = this.role
            addon.scrollOffset = 0
            addon:RefreshList()
        end)
        table.insert(roleTabs, tab)
    end

    self.raidContainer = CreateFrame("Frame", nil, ui)
    self.raidContainer:SetWidth(470)
    self.raidContainer:SetHeight(50)
    self.raidContainer:SetPoint("TOPLEFT", 12, -60)

    for i, raid in ipairs(self.raids) do
        local tab = CreateFrame("Button", nil, self.raidContainer, "UIPanelButtonTemplate")
        tab:SetWidth(64)
        tab:SetHeight(20)
        local col = math.mod(i - 1, 5)
        local row = math.floor((i - 1) / 5)
        tab:SetPoint("TOPLEFT", col * 66, -(row * 22))
        tab:SetText(raid)
        tab.raid = raid
        tab:SetScript("OnClick", function()
            addon:ToggleRaidSelection(this.raid)
            addon.scrollOffset = 0
            addon:RefreshList()
        end)
        table.insert(raidTabs, tab)
    end

    self.listStartY = -118

    for i = 1, self.maxLines do
        local rowIndex = i
        local btn = CreateFrame("Button", nil, ui)
        btn:SetWidth(430)
        btn:SetHeight(LINE_HEIGHT)
        btn:SetPoint("TOPLEFT", 12, self.listStartY - ((i - 1) * LINE_HEIGHT))

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        if math.mod(i, 2) == 0 then
            bg:SetTexture(0.17, 0.17, 0.22, 0.5)
        else
            bg:SetTexture(0.11, 0.11, 0.16, 0.5)
        end
        bg:Hide()

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", 8, 0)
        text:SetWidth(412)
        text:SetJustifyH("LEFT")
        text:SetTextHeight(13)
        text:SetNonSpaceWrap(true)
        text:Hide()

        btn.text = text
        btn.bg = bg
        btn.player = nil
        btn.fullMessage = nil
        btn:Hide()

        btn:SetScript("OnClick", function()
            if this.player then
                ChatFrameEditBox:Show()
                ChatFrameEditBox:SetText(addon:BuildWhisperText(this.player))
                ChatFrameEditBox:HighlightText()
            end
        end)

        btn:SetScript("OnEnter", function()
            if this.player and this.fullMessage then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:SetText(this.fullMessage, nil, nil, nil, nil, 1)
                GameTooltip:Show()
                this.bg:SetTexture(0.28, 0.28, 0.36, 0.7)
            end
        end)

        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
            if this.player then
                if math.mod(rowIndex, 2) == 0 then
                    this.bg:SetTexture(0.17, 0.17, 0.22, 0.5)
                else
                    this.bg:SetTexture(0.11, 0.11, 0.16, 0.5)
                end
            end
        end)

        lines[i] = btn
    end

    pageUpBtn = CreateFrame("Button", nil, ui, "UIPanelButtonTemplate")
    pageUpBtn:SetWidth(46)
    pageUpBtn:SetHeight(20)
    pageUpBtn:SetPoint("TOPLEFT", 446, self.listStartY)
    pageUpBtn:SetText("-Pg")
    pageUpBtn:SetScript("OnClick", function()
        addon.scrollOffset = addon.scrollOffset - addon.maxLines
        addon:RefreshList()
    end)

    pageDownBtn = CreateFrame("Button", nil, ui, "UIPanelButtonTemplate")
    pageDownBtn:SetWidth(46)
    pageDownBtn:SetHeight(20)
    pageDownBtn:SetPoint("TOPLEFT", 446, self.listStartY - 24)
    pageDownBtn:SetText("+Pg")
    pageDownBtn:SetScript("OnClick", function()
        addon.scrollOffset = addon.scrollOffset + addon.maxLines
        addon:RefreshList()
    end)

    filterText = ui:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    filterText:SetPoint("BOTTOMLEFT", 12, 10)
    filterText:SetTextColor(0.82, 0.82, 0.9)

    self:ApplyDB()
    self:ApplyLayout()
    self:RefreshList()
end

function addon:ApplyDB()
    self:ApplyOpacity()

    if self.minimapButton then
        if LFMTrackerDB.showMinimap then
            self.minimapButton:Show()
        else
            self.minimapButton:Hide()
        end
    end

    if self.UpdateMinimapButtonPosition then
        self:UpdateMinimapButtonPosition()
    end

    if self.ApplyMinimapIconTexture then
        self:ApplyMinimapIconTexture()
    end
end
