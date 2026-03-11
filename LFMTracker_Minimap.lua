local addon = LFMTracker

local function UpdateAttachedPosition(btn)
    local angle = LFMTrackerDB.minimapAngle or 200
    local radius = 78

    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius

    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function UpdateDetachedPosition(btn)
    local x = LFMTrackerDB.minimapDetachedX or -220
    local y = LFMTrackerDB.minimapDetachedY or -140

    btn:ClearAllPoints()
    btn:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

function addon:ApplyMinimapIconTexture()
    if not self.minimapButton or not self.minimapButton.icon then
        return
    end

    self.minimapButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_02")
    self.minimapButton.icon:SetTexCoord(0, 1, 0, 1)
    self.minimapButton.icon:SetVertexColor(1,1,1,1)
    self.minimapButton.icon:Show()
end

function addon:UpdateMinimapButtonPosition()
    if not self.minimapButton then
        return
    end

    if LFMTrackerDB.minimapDetached then
        self.minimapButton.overlay:Hide()
        self.minimapButton.detachedBorder:Show()
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
    detachedBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    detachedBorder:SetWidth(36)
    detachedBorder:SetHeight(36)
    detachedBorder:SetPoint("CENTER", btn, "CENTER", 0, 0)
    detachedBorder:Hide()
    btn.detachedBorder = detachedBorder

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:SetAllPoints(btn)
    btn.icon = icon

    self:ApplyMinimapIconTexture()

    btn:SetScript("OnClick", function()
        if arg1 == "RightButton" then
            addon:ToggleOptions()
        else
            addon:ToggleWindow()
        end
    end)

    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText("LFMTracker")
        GameTooltip:AddLine("Left click: Show/Hide window", 1, 1, 1)
        GameTooltip:AddLine("Right click: Options", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    btn:SetScript("OnMouseDown", function()
        if arg1 ~= "LeftButton" then
            return
        end

        if LFMTrackerDB.minimapDetached then
            this:StartMoving()
            return
        end

        if IsShiftKeyDown() then
            this:SetScript("OnUpdate", function()
                local mx, my = GetCursorPosition()
                local scale = Minimap:GetEffectiveScale()
                mx = mx / scale
                my = my / scale

                local cx, cy = Minimap:GetCenter()
                local dx = mx - cx
                local dy = my - cy

                local angle = math.atan(dy / dx)
                if dx < 0 then
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