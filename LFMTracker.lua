LFMTracker = {}

local addon = LFMTracker
addon.entries = {}
addon.filteredEntries = {}
addon.scrollOffset = 0
addon.selectedRaids = { ALL = true }
addon.maxLines = 7
addon.maxEntries = 120
addon.raids = {"ALL", "ONY", "BWL", "ZG", "MC", "ES", "AQ20", "AQ40", "KARA", "NAXX"}

local frame = CreateFrame("Frame")

local defaults = {
    opacity = 0.94,
    filtersCollapsed = false,
    showMinimap = true,
    minimapDetached = false,
    minimapAngle = 3.5,
    minimapDetachedX = -220,
    minimapDetachedY = -140,
    launcherX = -220,
    launcherY = -140,
    messageTemplate = "hi, inv?",
    alertsWhenHidden = true,
    alertSound = "TellMessage"
}

local function CopyDefaults(dst, src)
    for k, v in pairs(src) do
        if dst[k] == nil then
            dst[k] = v
        end
    end
end

local function Normalize(msg)
    return string.upper(msg or "")
end

local function Trim(text)
    return string.gsub(string.gsub(text or "", "^%s+", ""), "%s+$", "")
end

function addon:GetMessageTemplate()
    if not LFMTrackerDB then
        return ""
    end

    if LFMTrackerDB.messageTemplate ~= nil then
        return LFMTrackerDB.messageTemplate
    end

    if LFMTrackerDB.messg ~= nil then
        return LFMTrackerDB.messg
    end

    return ""
end

function addon:SetMessageTemplate(text)
    local cleaned = Trim(text)
    LFMTrackerDB.messageTemplate = cleaned
    LFMTrackerDB.messg = cleaned
end

function addon:IsRaidAliasMatch(upperMsg, raid)
    if raid == "AQ20" then
        return string.find(upperMsg, "AQ20") ~= nil or string.find(upperMsg, "RUINS") ~= nil
    elseif raid == "AQ40" then
        return string.find(upperMsg, "AQ40") ~= nil or string.find(upperMsg, "TEMPLE") ~= nil
    elseif raid == "ONY" then
        return string.find(upperMsg, "ONY") ~= nil or string.find(upperMsg, "ONYXIA") ~= nil
    elseif raid == "KARA" then
        return string.find(upperMsg, "KARA") ~= nil or string.find(upperMsg, "K%d") ~= nil or string.find(upperMsg, "KARAZHAN") ~= nil
    elseif raid == "ES" then
        return string.find(upperMsg, "[^%a]ES[^%a]") ~= nil or string.find(upperMsg, "EMERALD") ~= nil
    elseif raid == "ZG" then
        return string.find(upperMsg, "ZG") ~= nil or string.find(upperMsg, "ZUL") ~= nil or string.find(upperMsg, "GURUB") ~= nil
    elseif raid == "MC" then
        return string.find(upperMsg, "MC") ~= nil or string.find(upperMsg, "MOLTEN") ~= nil or string.find(upperMsg, "CORE") ~= nil
    elseif raid == "BWL" then
        return string.find(upperMsg, "BWL") ~= nil or string.find(upperMsg, "BLACKWING") ~= nil
    elseif raid == "NAXX" then
        return string.find(upperMsg, "NAXX") ~= nil or string.find(upperMsg, "NAX") ~= nil or string.find(upperMsg, "NEXUS") ~= nil
    end

    return string.find(upperMsg, raid) ~= nil
end

function addon:IsRaidMatch(entryMsg)
    if self.selectedRaids.ALL then
        return true
    end

    local upperMsg = Normalize(entryMsg)
    for raid, enabled in pairs(self.selectedRaids) do
        if enabled and raid ~= "ALL" and self:IsRaidAliasMatch(upperMsg, raid) then
            return true
        end
    end

    return false
end

function addon:GetRaidFilterLabel()
    if self.selectedRaids.ALL then
        return "ALL"
    end

    local list = {}
    for _, raid in ipairs(self.raids) do
        if raid ~= "ALL" and self.selectedRaids[raid] then
            table.insert(list, raid)
        end
    end

    return table.concat(list, ",")
end

function addon:CountSelectedRaids()
    if self.selectedRaids.ALL then
        return 1
    end

    local c = 0
    for raid, enabled in pairs(self.selectedRaids) do
        if enabled and raid ~= "ALL" then
            c = c + 1
        end
    end
    return c
end

function addon:IsLFM(msg)
    local lowerMsg = string.lower(msg or "")

    if string.find(lowerMsg, "lfm") then
        return true
    end

    if string.find(lowerMsg, "need") and (string.find(lowerMsg, "dps") or string.find(lowerMsg, "heal") or string.find(lowerMsg, "tank")) then
        return true
    end

    if string.find(lowerMsg, "last") and string.find(lowerMsg, "spot") then
        return true
    end

    return false
end

function addon:IsWorldChannel(channelName, channelBaseName)
    if channelBaseName and channelBaseName == "World" then
        return true
    end

    if channelName and string.find(channelName, "World") then
        return true
    end

    return false
end

function addon:MatchesActiveFilters(message)
    return self:IsRaidMatch(message)
end

function addon:GetSenderColor(sender)
    return 1, 1, 1
end

function addon:BuildWhisperText(playerName)
    local template = self:GetMessageTemplate()
    if template and string.len(template) > 0 then
        return "/w " .. playerName .. " " .. template
    end
    return "/w " .. playerName .. " "
end

function addon:NotifyIfHidden(entry)
    if not self.ui or self.ui:IsVisible() then
        return
    end

    if not LFMTrackerDB.alertsWhenHidden then
        return
    end

    PlaySound(LFMTrackerDB.alertSound or "TellMessage")
end

function addon:OnNewEntry(entry)
    entry.receivedAt = entry.receivedAt or date("%H:%M")

    table.insert(self.entries, 1, entry)
    while table.getn(self.entries) > self.maxEntries do
        table.remove(self.entries)
    end

    if self:MatchesActiveFilters(entry.msg) then
        self:NotifyIfHidden(entry)
    end

    self:RefreshList()
end

function addon:ToggleRaidSelection(raidName)
    if raidName == "ALL" then
        self.selectedRaids = { ALL = true }
        return
    end

    if self.selectedRaids.ALL then
        self.selectedRaids = {}
    end

    self.selectedRaids[raidName] = not self.selectedRaids[raidName]

    if self:CountSelectedRaids() == 0 then
        self.selectedRaids.ALL = true
    end
end

function addon:ToggleWindow()
    if not self.ui then
        return
    end

    if self.ui:IsVisible() then
        self.ui:Hide()
    else
        self.ui:Show()
        self:RefreshList()
    end
end

function addon:SlashHandler(msg)
    local raw = msg or ""
    local cmd = string.lower(Trim(raw))

    if cmd == "config" or cmd == "options" then
        self:ToggleOptions()
        return
    elseif cmd == "compact" then
        LFMTrackerDB.filtersCollapsed = not LFMTrackerDB.filtersCollapsed
        self:ApplyLayout()
        return
    elseif cmd == "msg" or cmd == "message" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[LFMTracker]|r message template: " .. self:GetMessageTemplate())
        return
    end

    local text = string.gsub(raw, "^%s*[Mm][Ss][Gg]%s+", "")
    if text ~= raw then
        self:SetMessageTemplate(text)
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[LFMTracker]|r message template saved")
        return
    end

    text = string.gsub(raw, "^%s*[Mm][Ee][Ss][Ss][Aa][Gg][Ee]%s+", "")
    if text ~= raw then
        self:SetMessageTemplate(text)
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[LFMTracker]|r message template saved")
        return
    end

    self:ToggleWindow()
end

frame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        if LFMTrackerDB == nil then
            LFMTrackerDB = {}
        end

        if LFMTrackerDB.messageTemplate == nil and LFMTrackerDB.messg ~= nil then
            LFMTrackerDB.messageTemplate = Trim(LFMTrackerDB.messg)
        end

        CopyDefaults(LFMTrackerDB, defaults)
        addon:SetMessageTemplate(addon:GetMessageTemplate())

        if addon.ApplyDB then addon:ApplyDB() end
        if addon.CreateUI then addon:CreateUI() end
        if addon.CreateMinimapButton then addon:CreateMinimapButton() end
        if addon.CreateOptionsUI then addon:CreateOptionsUI() end

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00LFMTracker loaded|r  /lfm  /lfm config  /lfm msg <text>")
    elseif event == "CHAT_MSG_CHANNEL" then
        local message = arg1
        local sender = arg2
        local channelName = arg4
        local channelBaseName = arg9

        if not addon:IsWorldChannel(channelName, channelBaseName) then
            return
        end

        if not addon:IsLFM(message) then
            return
        end

        addon:OnNewEntry({ sender = sender, msg = message })
    end
end)

frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("CHAT_MSG_CHANNEL")
SLASH_LFMTRACKER1 = "/lfm"
SLASH_LFMTRACKER2 = "/lfmtracker"
SlashCmdList["LFMTRACKER"] = function(msg) addon:SlashHandler(msg) end
