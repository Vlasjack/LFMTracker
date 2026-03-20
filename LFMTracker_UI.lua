local addon = LFMTracker

local lines = {}
local raidTabs = {}
local filterText
local summaryText
local pageUpBtn
local pageDownBtn
local footerAnchor

local LINE_HEIGHT = 28

local ROW_BACKDROPS = {
    { 0.10, 0.13, 0.19, 0.92 },
    { 0.07, 0.10, 0.16, 0.92 }
}

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

local function SetRowTexture(row, hovered)
    local color = ROW_BACKDROPS[row.rowParity]
    if hovered then
        row.bg:SetTexture(color[1] + 0.08, color[2] + 0.08, color[3] + 0.10, 0.95)
    else
        row.bg:SetTexture(color[1], color[2], color[3], color[4])
    end
end

local function WrapTextWithColor(text, r, g, b)
    local hex = string.format("%02x%02x%02x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
    return "|cff" .. hex .. text .. "|r"
end

function addon:ApplyOpacity()
    if self.ui then
        self.ui:SetBackdropColor(0.02, 0.03, 0.06, LFMTrackerDB.opacity)
    end
end

function addon:RefreshTabVisuals()
    for _, tab in ipairs(raidTabs) do
        if self.selectedRaids[tab.raid] then
            tab:LockHighlight()
            tab.label:SetTextColor(1.00, 0.92, 0.72)
        else
            tab:UnlockHighlight()
            tab.label:SetTextColor(0.74, 0.80, 0.90)
        end
    end
end

function addon:ApplyLayout()
    if not self.ui then
        return
    end

    local collapsed = LFMTrackerDB.filtersCollapsed
    if collapsed then
        self.raidContainer:Hide()
        self.ui:SetHeight(336)
        self.listPanel:ClearAllPoints()
        self.listPanel:SetPoint("TOPLEFT", 12, -58)
        self.listStartY = -88
        footerAnchor:ClearAllPoints()
        footerAnchor:SetPoint("BOTTOMLEFT", self.ui, "BOTTOMLEFT", 18, 12)
    else
        self.raidContainer:Show()
        self.ui:SetHeight(404)
        self.listPanel:ClearAllPoints()
        self.listPanel:SetPoint("TOPLEFT", 12, -112)
        self.listStartY = -146
        footerAnchor:ClearAllPoints()
        footerAnchor:SetPoint("BOTTOMLEFT", self.ui, "BOTTOMLEFT", 18, 12)
    end

    for i = 1, self.maxLines do
        lines[i]:SetPoint("TOPLEFT", 16, self.listStartY - ((i - 1) * LINE_HEIGHT))
    end

    pageUpBtn:ClearAllPoints()
    pageUpBtn:SetPoint("BOTTOMRIGHT", self.ui, "BOTTOMRIGHT", -76, 14)
    pageDownBtn:ClearAllPoints()
    pageDownBtn:SetPoint("BOTTOMRIGHT", self.ui, "BOTTOMRIGHT", -18, 14)

    self.compactBtn:SetText(collapsed and "Show filters" or "Compact")
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
            local senderR, senderG, senderB = self:GetSenderColor(e.sender)
            local shortMsg = e.msg
            if string.len(shortMsg) > 70 then
                shortMsg = string.sub(shortMsg, 1, 67) .. "..."
            end

            row.sender:SetText(WrapTextWithColor(e.sender, senderR, senderG, senderB))
            row.message:SetText(shortMsg)
            row.time:SetText(e.receivedAt or "--:--")
            row.player = e.sender
            row.fullMessage = e.sender .. ": " .. e.msg
            row.bg:Show()
            row:Show()
            SetRowTexture(row, false)
        else
            row.sender:SetText("")
            row.message:SetText("")
            row.time:SetText("")
            row.player = nil
            row.fullMessage = nil
            row.bg:Hide()
            row:Hide()
        end
    end

    local rangeStart = total == 0 and 0 or (self.scrollOffset + 1)
    local rangeEnd = math.min(self.scrollOffset + self.maxLines, total)
    filterText:SetText("Raids: " .. self:GetRaidFilterLabel() .. "  •  " .. total .. " results  •  " .. rangeStart .. "-" .. rangeEnd)

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

local function CreateFilterTab(parent, width, height, x, y, text)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetWidth(width)
    btn:SetHeight(height)
    btn:SetPoint("TOPLEFT", x, y)
    btn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = 1,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(0.08, 0.12, 0.18, 0.90)
    btn:SetBackdropBorderColor(0.20, 0.35, 0.52, 1.00)
    btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    local highlight = btn:GetHighlightTexture()
    highlight:SetVertexColor(0.28, 0.48, 0.74, 0.18)

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", btn, "CENTER", 0, 0)
    label:SetText(text)
    btn.label = label

    return btn
end

function addon:CreateUI()
    if self.ui then
        return
    end

    local ui = CreateFrame("Frame", "LFMTrackerUI", UIParent)
    self.ui = ui

    ui:SetWidth(528)
    ui:SetHeight(404)
    ui:SetPoint("CENTER", 0, 150)
    ui:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = 1,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    ui:SetBackdropBorderColor(0.32, 0.48, 0.68, 1)
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

    local header = ui:CreateTexture(nil, "BORDER")
    header:SetTexture(0.07, 0.11, 0.18, 0.98)
    header:SetPoint("TOPLEFT", 8, -8)
    header:SetPoint("TOPRIGHT", -8, -8)
    header:SetHeight(40)

    local title = ui:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("LFMTracker")

    local subtitle = ui:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetText("Clean raid finder for World chat")
    subtitle:SetTextColor(0.70, 0.78, 0.90)

    local closeBtn = CreateFrame("Button", nil, ui, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() ui:Hide() end)

    self.compactBtn = CreateFrame("Button", nil, ui, "UIPanelButtonTemplate")
    self.compactBtn:SetWidth(96)
    self.compactBtn:SetHeight(20)
    self.compactBtn:SetPoint("TOPRIGHT", -42, -24)
    self.compactBtn:SetText("Compact")
    self.compactBtn:SetScript("OnClick", function()
        LFMTrackerDB.filtersCollapsed = not LFMTrackerDB.filtersCollapsed
        addon:ApplyLayout()
    end)

    local raidPanel = CreateFrame("Frame", nil, ui)
    raidPanel:SetPoint("TOPLEFT", 14, -54)
    raidPanel:SetWidth(500)
    raidPanel:SetHeight(60)
    self.raidContainer = raidPanel

    local raidLabel = raidPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    raidLabel:SetPoint("TOPLEFT", 2, -2)
    raidLabel:SetText("Raids")
    raidLabel:SetTextColor(0.92, 0.84, 0.62)

    for i, raid in ipairs(self.raids) do
        local col = math.mod(i - 1, 5)
        local row = math.floor((i - 1) / 5)
        local tab = CreateFilterTab(raidPanel, 92, 20, col * 98, -12 - (row * 24), raid)
        tab.raid = raid
        tab:SetScript("OnClick", function()
            addon:ToggleRaidSelection(this.raid)
            addon.scrollOffset = 0
            addon:RefreshList()
        end)
        table.insert(raidTabs, tab)
    end

    local listPanel = CreateFrame("Frame", nil, ui)
    listPanel:SetPoint("TOPLEFT", 12, -106)
    listPanel:SetWidth(504)
    listPanel:SetHeight(282)
    self.listPanel = listPanel

    local headerSender = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerSender:SetPoint("TOPLEFT", 12, -10)
    headerSender:SetText("Player")
    headerSender:SetTextColor(0.92, 0.84, 0.62)

    local headerMessage = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerMessage:SetPoint("TOPLEFT", 116, -10)
    headerMessage:SetText("Message")
    headerMessage:SetTextColor(0.92, 0.84, 0.62)

    local headerTime = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerTime:SetPoint("TOPRIGHT", -18, -10)
    headerTime:SetText("Time")
    headerTime:SetTextColor(0.92, 0.84, 0.62)

    self.listStartY = -146

    for i = 1, self.maxLines do
        local btn = CreateFrame("Button", nil, ui)
        btn:SetWidth(476)
        btn:SetHeight(LINE_HEIGHT)
        btn:SetPoint("TOPLEFT", 16, self.listStartY - ((i - 1) * LINE_HEIGHT))
        btn.rowParity = math.mod(i, 2) + 1

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(btn)
        btn.bg = bg
        SetRowTexture(btn, false)
        bg:Hide()

        local sender = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        sender:SetPoint("LEFT", 10, 0)
        sender:SetWidth(88)
        sender:SetJustifyH("LEFT")
        btn.sender = sender

        local message = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        message:SetPoint("LEFT", 108, 0)
        message:SetWidth(306)
        message:SetJustifyH("LEFT")
        message:SetTextColor(0.84, 0.89, 0.97)
        btn.message = message

        local time = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        time:SetPoint("RIGHT", -10, 0)
        time:SetWidth(52)
        time:SetJustifyH("RIGHT")
        time:SetTextColor(0.61, 0.72, 0.84)
        btn.time = time

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
                GameTooltip:AddLine("Click to prepare whisper", 0.75, 0.88, 1)
                GameTooltip:Show()
                SetRowTexture(this, true)
            end
        end)

        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
            if this.player then
                SetRowTexture(this, false)
            end
        end)

        lines[i] = btn
    end

    pageUpBtn = CreateFrame("Button", nil, ui, "UIPanelButtonTemplate")
    pageUpBtn:SetWidth(52)
    pageUpBtn:SetHeight(22)
    pageUpBtn:SetPoint("BOTTOMRIGHT", ui, "BOTTOMRIGHT", -76, 14)
    pageUpBtn:SetText("Prev")
    pageUpBtn:SetScript("OnClick", function()
        addon.scrollOffset = addon.scrollOffset - addon.maxLines
        addon:RefreshList()
    end)

    pageDownBtn = CreateFrame("Button", nil, ui, "UIPanelButtonTemplate")
    pageDownBtn:SetWidth(52)
    pageDownBtn:SetHeight(22)
    pageDownBtn:SetPoint("BOTTOMRIGHT", ui, "BOTTOMRIGHT", -18, 14)
    pageDownBtn:SetText("Next")
    pageDownBtn:SetScript("OnClick", function()
        addon.scrollOffset = addon.scrollOffset + addon.maxLines
        addon:RefreshList()
    end)

    footerAnchor = CreateFrame("Frame", nil, ui)
    footerAnchor:SetWidth(1)
    footerAnchor:SetHeight(1)
    footerAnchor:SetPoint("BOTTOMLEFT", ui, "BOTTOMLEFT", 18, 12)

    filterText = ui:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    filterText:SetPoint("BOTTOMLEFT", footerAnchor, "BOTTOMLEFT", 0, 0)
    filterText:SetTextColor(0.82, 0.88, 0.96)

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
