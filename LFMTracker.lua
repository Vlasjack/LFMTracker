LFMTracker = {}

local addon = LFMTracker
addon.entries = {}
addon.filteredEntries = {}
addon.scrollOffset = 0
addon.currentRole = "ALL"
addon.selectedRaids = { ALL = true }
addon.maxLines = 8
addon.maxEntries = 120
addon.raids = {"ALL", "ONY", "BWL", "ZG", "MC", "ES", "AQ20", "AQ40", "KARA", "NAXX"}
addon.roles = {"ALL", "DPS", "HEAL", "TANK"}

local frame = CreateFrame("Frame")

local defaults = {
    opacity = 0.92,
    filtersCollapsed = false,
    showMinimap = true,
    launcherX = -220,
    launcherY = -140,
    messg = "hi, inv?",
    alertsWhenHidden = true,
    playSound = true
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

local function ContainsToken(upperMsg, token)
    return string.find(upperMsg, "(^|[^%a])" .. token .. "([^%a]|$)") ~= nil
end

function addon:IsRoleMatch(entryMsg)
    local msg = Normalize(entryMsg)

    if self.currentRole == "ALL" then
        return true
    elseif self.currentRole == "DPS" then
        return ContainsToken(msg, "DPS") or ContainsToken(msg, "DD")
    elseif self.currentRole == "HEAL" then
        return ContainsToken(msg, "HEAL") or ContainsToken(msg, "HEALER")
    elseif self.currentRole == "TANK" then
        return ContainsToken(msg, "TANK") or ContainsToken(msg, "MT") or ContainsToken(msg, "OT")
    end

    return false
end

function addon:IsRaidAliasMatch(upperMsg, raid)
    if raid == "AQ20" then
        return string.find(upperMsg, "AQ20") ~= nil or 
               string.find(upperMsg, "RUINS") ~= nil
               
    elseif raid == "AQ40" then
        return string.find(upperMsg, "AQ40") ~= nil or 
               string.find(upperMsg, "TEMPLE") ~= nil
               
    elseif raid == "ONY" then
        return string.find(upperMsg, "ONY") ~= nil or      -- ONY, ONY10, ONY20, ONY40
               string.find(upperMsg, "ONYXIA") ~= nil
               
    elseif raid == "KARA" then
        return string.find(upperMsg, "KARA") ~= nil or     -- KARA, KARA10, KARA20
               string.find(upperMsg, "K%d") ~= nil or      -- K10, K20, K40
               string.find(upperMsg, "KARAZHAN") ~= nil
               
    elseif raid == "ES" then
        return string.find(upperMsg, "ES") ~= nil or       -- ES, ES15, ES30, ES40
               string.find(upperMsg, "EMERALD") ~= nil
               
    elseif raid == "ZG" then
        return string.find(upperMsg, "ZG") ~= nil or 
               string.find(upperMsg, "ZUL") ~= nil or 
               string.find(upperMsg, "GURUB") ~= nil
               
    elseif raid == "MC" then
        return string.find(upperMsg, "MC") ~= nil or 
               string.find(upperMsg, "MOLTEN") ~= nil or 
               string.find(upperMsg, "CORE") ~= nil
               
    elseif raid == "BWL" then
        return string.find(upperMsg, "BWL") ~= nil or 
               string.find(upperMsg, "BLACK") ~= nil or 
               string.find(upperMsg, "WING") ~= nil
               
    elseif raid == "NAXX" then
        return string.find(upperMsg, "NAXX") ~= nil or 
               string.find(upperMsg, "NAX") ~= nil or 
               string.find(upperMsg, "NEXUS") ~= nil
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
    return self:IsRoleMatch(message) and self:IsRaidMatch(message)
end


function addon:BuildWhisperText(playerName)
    local template = LFMTrackerDB and LFMTrackerDB.messg or ""
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

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[LFMTracker]|r " .. entry.sender .. ": " .. entry.msg)

    if LFMTrackerDB.playSound then
        PlaySound("TellMessage")
    end
end

function addon:OnNewEntry(entry)
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
    local cmd = string.lower(raw)

    if cmd == "config" or cmd == "options" then
        self:ToggleOptions()
        return
    elseif cmd == "compact" then
        LFMTrackerDB.filtersCollapsed = not LFMTrackerDB.filtersCollapsed
        self:ApplyLayout()
        return
    elseif cmd == "msg" or cmd == "message" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[LFMTracker]|r message template: " .. (LFMTrackerDB.messg or ""))
        return
    end

    local text = string.gsub(raw, "^%s*[Mm][Ss][Gg]%s+", "")
    if text ~= raw then
        LFMTrackerDB.messg = text
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[LFMTracker]|r message template saved")
        return
    end

    text = string.gsub(raw, "^%s*[Mm][Ee][Ss][Ss][Aa][Gg][Ee]%s+", "")
    if text ~= raw then
        LFMTrackerDB.messg = text
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
        CopyDefaults(LFMTrackerDB, defaults)

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