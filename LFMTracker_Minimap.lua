local addon = LFMTracker

local function ClampDetachedPosition(btn)
    local x = LFMTrackerDB.minimapDetachedX or -220
    local y = LFMTrackerDB.minimapDetachedY or -140
    local limitX = (UIParent:GetWidth() / 2) + 40
    local limitY = (UIParent:GetHeight() / 2) + 40

    if x > limitX then x = limitX end
    if x < -limitX then x = -limitX end
    if y > limitY then y = limitY end
    if y < -limitY then y = -limitY end

    LFMTrackerDB.minimapDetachedX = x
    LFMTrackerDB.minimapDetachedY = y

    return x, y
end

local function UpdateAttachedPosition(btn)
    local angle = LFMTrackerDB.minimapAngle or 3.5
    local radius = 80

    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius

    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function UpdateDetachedPosition(btn)
    local x, y = ClampDetachedPosition(btn)

    btn:ClearAllPoints()
    btn:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

function addon:ApplyMinimapIconTexture()
    if not self.minimapButton then
        return
    end

    local btn = self.minimapButton

    if btn.iconTexture then
        btn.iconTexture:SetTexture("Interface\\AddOns\\LFMTracker1\\LFM")
        btn.iconTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    if btn.iconTextureAlt then
        btn.iconTextureAlt:SetTexture("Interface\\AddOns\\LFMTracker\\LFM")
        btn.iconTextureAlt:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    if btn.iconRing then
        btn.iconRing:SetTexture(0.10, 0.14, 0.20, 0.85)
    end

    if btn.iconCore then
        btn.iconCore:SetTexture(0.20, 0.56, 0.91, 0.0)
    end

    if btn.iconGlow then
        btn.iconGlow:SetTexture(0.56, 0.80, 1.00, 0.0)
    end

    if btn.iconAccent then
        btn.iconAccent:SetTexture(1.00, 0.82, 0.33, 0.0)
    end

    if btn.iconLetters then
        btn.iconLetters:SetText("LFM")
        btn.iconLetters:SetTextColor(1.00, 0.96, 0.88, 0.0)
    end
end

function addon:UpdateMinimapButtonPosition()
    if not self.minimapButton then
        return
    end

    if LFMTrackerDB.minimapDetached then
        self.minimapButton.overlay:Show()
        self.minimapButton.detachedBorder:Hide()
        UpdateDetachedPosition(self.minimapButton)
    else
        self.minimapButton.overlay:Show()
        self.minimapButton.detachedBorder:Hide()
        UpdateAttachedPosition(self.minimapButton)
    end
end

function addon:CreateMinimapButton()
    if self.minimapButton then
        self:UpdateMinimapButtonPosition()
        self:ApplyMinimapIconTexture()
        return
    end

    local btn = CreateFrame("Button", "LFMTrackerMinimapButton", UIParent)
    self.minimapButton = btn

    btn:SetWidth(31)
    btn:SetHeight(31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetWidth(54)
    overlay:SetHeight(54)
    overlay:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
    btn.overlay = overlay

    local detachedBorder = btn:CreateTexture(nil, "OVERLAY")
    detachedBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    detachedBorder:SetWidth(54)
    detachedBorder:SetHeight(54)
    detachedBorder:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
    btn.detachedBorder = detachedBorder
    detachedBorder:Hide()

    local iconRing = btn:CreateTexture(nil, "ARTWORK")
    iconRing:SetWidth(24)
    iconRing:SetHeight(24)
    iconRing:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.iconRing = iconRing

    local iconTexture = btn:CreateTexture(nil, "OVERLAY")
    iconTexture:SetWidth(20)
    iconTexture:SetHeight(20)
    iconTexture:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.iconTexture = iconTexture

    local iconTextureAlt = btn:CreateTexture(nil, "OVERLAY")
    iconTextureAlt:SetWidth(20)
    iconTextureAlt:SetHeight(20)
    iconTextureAlt:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.iconTextureAlt = iconTextureAlt

    local iconCore = btn:CreateTexture(nil, "OVERLAY")
    iconCore:SetWidth(18)
    iconCore:SetHeight(18)
    iconCore:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.iconCore = iconCore

    local iconGlow = btn:CreateTexture(nil, "BORDER")
    iconGlow:SetWidth(12)
    iconGlow:SetHeight(4)
    iconGlow:SetPoint("BOTTOM", btn, "BOTTOM", 0, 7)
    btn.iconGlow = iconGlow

    local iconAccent = btn:CreateTexture(nil, "OVERLAY")
    iconAccent:SetWidth(6)
    iconAccent:SetHeight(6)
    iconAccent:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -8, -8)
    btn.iconAccent = iconAccent

    local iconLetters = btn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    iconLetters:SetPoint("CENTER", btn, "CENTER", 0, -1)
    btn.iconLetters = iconLetters

    self:ApplyMinimapIconTexture()

    btn:SetScript("OnClick", function()
        if arg1 == "RightButton" then
            addon:ToggleOptions()
        else
            addon:ToggleWindow()
        end
    end)

    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetClampedToScreen(true)

    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText("LFMTracker")
        GameTooltip:AddLine("Left click: show or hide tracker", 1, 1, 1)
        GameTooltip:AddLine("Right click: options", 0.85, 0.85, 0.85)
        GameTooltip:AddLine("Hold Shift or Ctrl to move launcher", 0.7, 0.82, 1)
        GameTooltip:AddLine("Detached mode still clamps to screen edges", 0.7, 0.82, 1)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    btn:SetScript("OnMouseDown", function()
        if arg1 ~= "LeftButton" then
            return
        end

        if not IsShiftKeyDown() and not IsControlKeyDown() then
            return
        end

        if LFMTrackerDB.minimapDetached then
            this:StartMoving()
            return
        end

        if IsShiftKeyDown() or IsControlKeyDown() then
            this:SetScript("OnUpdate", function()
                local mx, my = GetCursorPosition()
                local scale = Minimap:GetEffectiveScale()
                mx = mx / scale
                my = my / scale

                local cx, cy = Minimap:GetCenter()
                local dx = mx - cx
                local dy = my - cy

                local angle = math.atan2 and math.atan2(dy, dx) or math.atan(dy / dx)
                if not math.atan2 and dx < 0 then
                    angle = angle + math.pi
                end

                LFMTrackerDB.minimapAngle = angle
                UpdateAttachedPosition(this)
            end)
        end
    end)

    btn:SetScript("OnMouseUp", function()
        this:SetScript("OnUpdate", nil)
        this:StopMovingOrSizing()

        if LFMTrackerDB.minimapDetached then
            local cx, cy = this:GetCenter()
            local ux, uy = UIParent:GetCenter()
            if cx and cy and ux and uy then
                LFMTrackerDB.minimapDetachedX = cx - ux
                LFMTrackerDB.minimapDetachedY = cy - uy
                ClampDetachedPosition(this)
                UpdateDetachedPosition(this)
            end
        end
    end)

    btn:EnableMouse(true)
    btn:SetMovable(true)

    self:UpdateMinimapButtonPosition()

    if LFMTrackerDB.showMinimap then
        btn:Show()
    else
        btn:Hide()
    end
end
