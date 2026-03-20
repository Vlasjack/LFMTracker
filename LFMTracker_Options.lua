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

        if key == "minimapDetached" then
            addon:UpdateMinimapButtonPosition()
        else
            addon:ApplyDB()
        end
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

    optionsFrame:SetWidth(320)
    optionsFrame:SetHeight(240)
    optionsFrame:SetPoint("CENTER", 300, 140)
    optionsFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = 1,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    optionsFrame:SetBackdropColor(0.05, 0.07, 0.11, 0.96)
    optionsFrame:SetBackdropBorderColor(0.30, 0.46, 0.66)
    optionsFrame:EnableMouse(true)
    optionsFrame:SetMovable(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnDragStart", function() this:StartMoving() end)
    optionsFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

    local title = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -12)
    title:SetText("LFMTracker Options")

    local closeBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() optionsFrame:Hide() end)

    local opacityLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    opacityLabel:SetPoint("TOPLEFT", 16, -42)
    opacityLabel:SetText("Window opacity")

    local slider = CreateFrame("Slider", "LFMTrackerOpacitySlider", optionsFrame, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 12, -58)
    slider:SetWidth(250)
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

    local minimapCb = CreateCheckButton(optionsFrame, "Show launcher icon", "showMinimap", 16, -104)
    local alertsCb = CreateCheckButton(optionsFrame, "Alert when window hidden", "alertsWhenHidden", 16, -130)
    local detachedCb = CreateCheckButton(optionsFrame, "Detach launcher from minimap", "minimapDetached", 16, -156)

    local messageLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    messageLabel:SetPoint("TOPLEFT", 16, -190)
    messageLabel:SetText("Whisper template")

    local messageBox = CreateFrame("EditBox", "LFMTrackerMessageTemplateBox", optionsFrame, "InputBoxTemplate")
    messageBox:SetPoint("TOPLEFT", 16, -206)
    messageBox:SetWidth(230)
    messageBox:SetHeight(24)
    messageBox:SetAutoFocus(false)
    messageBox:SetScript("OnEnterPressed", function()
        addon:SetMessageTemplate(this:GetText())
        this:ClearFocus()
    end)
    messageBox:SetScript("OnEscapePressed", function()
        this:SetText(addon:GetMessageTemplate())
        this:ClearFocus()
    end)
    messageBox:SetScript("OnEditFocusLost", function()
        addon:SetMessageTemplate(this:GetText())
    end)

    function optionsFrame:RefreshValues()
        slider:SetValue(math.floor((LFMTrackerDB.opacity or 0.94) * 100))
        minimapCb:SetChecked(LFMTrackerDB.showMinimap)
        alertsCb:SetChecked(LFMTrackerDB.alertsWhenHidden)
        detachedCb:SetChecked(LFMTrackerDB.minimapDetached)
        messageBox:SetText(addon:GetMessageTemplate())
    end

    optionsFrame:SetScript("OnShow", function()
        this:RefreshValues()
    end)

    optionsFrame:Hide()
end

function addon:ApplyDB()
    if self.ui then
        self:ApplyOpacity()
    end
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

function addon:ApplyOpacity()
    if self.ui then
        local alpha = LFMTrackerDB.opacity or 0.94
        self.ui:SetBackdropColor(0.02, 0.03, 0.06, alpha)
    end
end
