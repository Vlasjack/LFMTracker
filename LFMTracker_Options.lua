local addon = LFMTracker

local optionsFrame

local function CreateCheckButton(parent, label, key, x, y)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", x, y)
    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    cb.text:SetText(label)

    cb:SetScript("OnClick", function()
        LFMTrackerDB[key] = this:GetChecked() and true or false
        addon:ApplyDB()
    end)

    return cb
end

function addon:ToggleOptions()
    if not optionsFrame then
        return
    end

    if optionsFrame:IsVisible() then
        optionsFrame:Hide()
    else
        optionsFrame:Show()
    end
end

function addon:CreateOptionsUI()
    if optionsFrame then
        return
    end

    optionsFrame = CreateFrame("Frame", "LFMTrackerOptions", UIParent)
    self.optionsFrame = optionsFrame

    optionsFrame:SetWidth(280)
    optionsFrame:SetHeight(240)
    optionsFrame:SetPoint("CENTER", 280, 140)
    optionsFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = 1,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    optionsFrame:SetBackdropColor(0.06, 0.06, 0.09, 0.94)
    optionsFrame:SetBackdropBorderColor(0.4, 0.4, 0.5)
    optionsFrame:EnableMouse(true)
    optionsFrame:SetMovable(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnDragStart", function() this:StartMoving() end)
    optionsFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

    local title = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText("LFMTracker Options")

    local closeBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() optionsFrame:Hide() end)

    local opacityLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    opacityLabel:SetPoint("TOPLEFT", 14, -40)
    opacityLabel:SetText("Window opacity")

    local slider = CreateFrame("Slider", "LFMTrackerOpacitySlider", optionsFrame, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 12, -56)
    slider:SetWidth(220)
    slider:SetMinMaxValues(10, 100)
    slider:SetValueStep(1)

    local low = getglobal(slider:GetName() .. "Low")
    local high = getglobal(slider:GetName() .. "High")
    local text = getglobal(slider:GetName() .. "Text")
    low:SetText("10%")
    high:SetText("100%")
    text:SetText("")

    slider:SetScript("OnValueChanged", function()
        local val = math.floor(this:GetValue() + 0.5)
        LFMTrackerDB.opacity = val / 100
        addon:ApplyOpacity()
    end)

    local minimapCb = CreateCheckButton(optionsFrame, "Show launcher icon", "showMinimap", 14, -98)
    local alertsCb = CreateCheckButton(optionsFrame, "Alerts when window hidden", "alertsWhenHidden", 14, -124)
    local soundCb = CreateCheckButton(optionsFrame, "Play alert sound", "playSound", 14, -150)
    local flashCb = CreateCheckButton(optionsFrame, "Flash WoW icon (if supported)", "flashClient", 14, -176)
    local detachedCb = CreateCheckButton(optionsFrame, "Detach launcher from minimap", "minimapDetached", 14, -202)

 

    function optionsFrame:RefreshValues()
        slider:SetValue(math.floor((LFMTrackerDB.opacity or 0.92) * 100))
        minimapCb:SetChecked(LFMTrackerDB.showMinimap)
        alertsCb:SetChecked(LFMTrackerDB.alertsWhenHidden)
        soundCb:SetChecked(LFMTrackerDB.playSound)
        flashCb:SetChecked(LFMTrackerDB.flashClient)
        detachedCb:SetChecked(LFMTrackerDB.minimapDetached)
    end

    optionsFrame:SetScript("OnShow", function()
        this:RefreshValues()
    end)

    optionsFrame:Hide()
end
