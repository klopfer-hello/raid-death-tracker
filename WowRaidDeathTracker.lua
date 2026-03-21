-- ============================================================
--  WowRaidDeathTracker  v2.2
--  TBC Classic Anniversary (2.5.5)
--  Zählt Spielertode – solo, in Party und Raid.
-- ============================================================

local ADDON_NAME = "WowRaidDeathTracker"
local TOP_N      = 5

-- ----------------------------------------------------------------
-- Core Frame (Events)
-- ----------------------------------------------------------------
local frame = CreateFrame("Frame", "RaidDeathTrackerFrame", UIParent)
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ADDON_LOADED")

-- ----------------------------------------------------------------
-- Hilfsfunktion: 1px-Pixelrahmen aus 4 Texturen.
-- Kein BackdropTemplate, kein SetBackdrop – 100% kompatibel.
-- ----------------------------------------------------------------
local function AddPixelBorder(parent, r, g, b, a)
    local top = parent:CreateTexture(nil, "OVERLAY")
    top:SetPoint("TOPLEFT",  parent, "TOPLEFT",  0,  0)
    top:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0,  0)
    top:SetHeight(1)
    top:SetColorTexture(r, g, b, a)

    local bot = parent:CreateTexture(nil, "OVERLAY")
    bot:SetPoint("BOTTOMLEFT",  parent, "BOTTOMLEFT",  0, 0)
    bot:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    bot:SetHeight(1)
    bot:SetColorTexture(r, g, b, a)

    local lft = parent:CreateTexture(nil, "OVERLAY")
    lft:SetPoint("TOPLEFT",    parent, "TOPLEFT",    0,  0)
    lft:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0,  0)
    lft:SetWidth(1)
    lft:SetColorTexture(r, g, b, a)

    local rgt = parent:CreateTexture(nil, "OVERLAY")
    rgt:SetPoint("TOPRIGHT",    parent, "TOPRIGHT",    0, 0)
    rgt:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    rgt:SetWidth(1)
    rgt:SetColorTexture(r, g, b, a)
end

-- ----------------------------------------------------------------
-- Display Frame
-- ----------------------------------------------------------------
local display = CreateFrame("Frame", "RaidDeathTrackerDisplay", UIParent)
display:SetSize(260, 185)
display:SetPoint("CENTER")
display:SetMovable(true)
display:EnableMouse(true)
display:RegisterForDrag("LeftButton")
display:SetScript("OnDragStart", display.StartMoving)
display:SetScript("OnDragStop",  display.StopMovingOrSizing)
display:SetClampedToScreen(true)

-- Resize: neue API (SetResizeBounds) oder alte (SetResizable + SetMinResize)
if display.SetResizeBounds then
    display:SetResizeBounds(220, 150)
elseif display.SetResizable then
    display:SetResizable(true)
    if display.SetMinResize then
        display:SetMinResize(220, 150)
    end
end

-- Haupthintergrund
local bg = display:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0.04, 0.04, 0.07, 0.92)

-- 1px Rahmen (keine Backdrop-API nötig)
AddPixelBorder(display, 0.22, 0.22, 0.28, 1)

-- Header-Balken
local headerBg = display:CreateTexture(nil, "ARTWORK")
headerBg:SetPoint("TOPLEFT",  1, -1)
headerBg:SetPoint("TOPRIGHT", -1, -1)
headerBg:SetHeight(24)
headerBg:SetColorTexture(0.10, 0.10, 0.16, 1)

-- Rote Akzentlinie unter Header
local headerLine = display:CreateTexture(nil, "ARTWORK")
headerLine:SetPoint("TOPLEFT",  1, -25)
headerLine:SetPoint("TOPRIGHT", -1, -25)
headerLine:SetHeight(1)
headerLine:SetColorTexture(0.50, 0.10, 0.10, 1)

-- Icon (Header)
local icon = display:CreateTexture(nil, "OVERLAY")
icon:SetSize(16, 16)
icon:SetPoint("TOPLEFT", 6, -4)
icon:SetTexture("Interface\\Icons\\Spell_Shadow_DeathCoil")

-- Titel
local titleText = display:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
titleText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
titleText:SetText("|cffcc2222Raid|r |cffccccccDeath Tracker|r")

-- TEST-Badge (neben Titel, nur im Testmodus sichtbar)
local testBadge = display:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
testBadge:SetPoint("LEFT", titleText, "RIGHT", 6, 0)
testBadge:SetText("|cffff9900[TEST]|r")
testBadge:Hide()

-- Schliessen-Button
local closeBtn = CreateFrame("Button", nil, display)
closeBtn:SetSize(18, 18)
closeBtn:SetPoint("TOPRIGHT", -4, -3)
local closeTex = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
closeTex:SetAllPoints()
closeTex:SetText("|cff555566x|r")
closeBtn:SetScript("OnEnter", function() closeTex:SetText("|cffff3333x|r") end)
closeBtn:SetScript("OnLeave", function() closeTex:SetText("|cff555566x|r") end)
closeBtn:SetScript("OnClick", function() display:Hide() end)

-- Content-Text (wächst/schrumpft mit Resize)
local contentText = display:CreateFontString(nil, "OVERLAY", "GameFontNormal")
contentText:SetPoint("TOPLEFT",     10, -34)
contentText:SetPoint("BOTTOMRIGHT", display, "BOTTOMRIGHT", -10, 26)
contentText:SetJustifyH("LEFT")
contentText:SetJustifyV("TOP")
contentText:SetWordWrap(false)

-- Footer-Balken
local footerBg = display:CreateTexture(nil, "ARTWORK")
footerBg:SetPoint("BOTTOMLEFT",  1, 1)
footerBg:SetPoint("BOTTOMRIGHT", -1, 1)
footerBg:SetHeight(22)
footerBg:SetColorTexture(0.07, 0.07, 0.11, 1)

-- Footer-Trennlinie
local footerLine = display:CreateTexture(nil, "ARTWORK")
footerLine:SetPoint("BOTTOMLEFT",  1, 23)
footerLine:SetPoint("BOTTOMRIGHT", -1, 23)
footerLine:SetHeight(1)
footerLine:SetColorTexture(0.18, 0.18, 0.24, 1)

-- Reset-Button (Footer links)
local resetBtn = CreateFrame("Button", nil, display)
resetBtn:SetSize(54, 14)
resetBtn:SetPoint("BOTTOMLEFT", 8, 5)

local resetBtnBg = resetBtn:CreateTexture(nil, "BACKGROUND")
resetBtnBg:SetAllPoints()
resetBtnBg:SetColorTexture(0.20, 0.06, 0.06, 1)

AddPixelBorder(resetBtn, 0.38, 0.12, 0.12, 0.9)

local resetBtnText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
resetBtnText:SetAllPoints()
resetBtnText:SetText("|cff993333Reset|r")

resetBtn:SetScript("OnEnter", function()
    resetBtnBg:SetColorTexture(0.32, 0.08, 0.08, 1)
    resetBtnText:SetText("|cffff4444Reset|r")
end)
resetBtn:SetScript("OnLeave", function()
    resetBtnBg:SetColorTexture(0.20, 0.06, 0.06, 1)
    resetBtnText:SetText("|cff993333Reset|r")
end)
resetBtn:SetScript("OnClick", function()
    RaidDeathData = {}
    frame:UpdateDisplay()
    print("|cff00ff00[RDT]|r Tode zurueckgesetzt.")
end)

-- Resize-Griff (unten rechts)
local resizeGrip = CreateFrame("Button", nil, display)
resizeGrip:SetSize(14, 14)
resizeGrip:SetPoint("BOTTOMRIGHT", -1, 1)
resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizeGrip:SetScript("OnMouseDown", function(_, btn)
    if btn == "LeftButton" then display:StartSizing("BOTTOMRIGHT") end
end)
resizeGrip:SetScript("OnMouseUp", function()
    display:StopMovingOrSizing()
end)

-- ----------------------------------------------------------------
-- Minimap-Button
-- ----------------------------------------------------------------
local MINIMAP_RADIUS = 80

local minimapBtn = CreateFrame("Button", "RDTMinimapButton", Minimap)
minimapBtn:SetSize(31, 31)
minimapBtn:SetFrameStrata("MEDIUM")
minimapBtn:SetFrameLevel(8)
minimapBtn:EnableMouse(true)
minimapBtn:RegisterForDrag("LeftButton")

-- Icon füllt den gesamten Button; SetTexCoord trimmt den Icon-Rahmen weg
local minimapBtnIcon = minimapBtn:CreateTexture(nil, "ARTWORK")
minimapBtnIcon:SetTexture("Interface\\Icons\\Spell_Shadow_DeathCoil")
minimapBtnIcon:SetAllPoints()
minimapBtnIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

-- Goldener Kreisrahmen als Overlay (56x56 ist die korrekte Größe für 31px Button)
local minimapBtnRing = minimapBtn:CreateTexture(nil, "OVERLAY")
minimapBtnRing:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
minimapBtnRing:SetSize(56, 56)
minimapBtnRing:SetPoint("CENTER")

-- Highlight beim Hover
minimapBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local function UpdateMinimapButtonPos()
    local angle = (RDTConfig and RDTConfig.minimapAngle) or 220
    local rad   = math.rad(angle)
    minimapBtn:ClearAllPoints()
    minimapBtn:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(rad) * MINIMAP_RADIUS,
        math.sin(rad) * MINIMAP_RADIUS
    )
end

minimapBtn:SetScript("OnDragStart", function(self)
    self:LockHighlight()
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale  = UIParent:GetEffectiveScale()
        local angle  = math.deg(math.atan2((cy / scale) - my, (cx / scale) - mx))
        if RDTConfig then RDTConfig.minimapAngle = angle end
        UpdateMinimapButtonPos()
    end)
end)

minimapBtn:SetScript("OnDragStop", function(self)
    self:UnlockHighlight()
    self:SetScript("OnUpdate", nil)
end)

minimapBtn:SetScript("OnClick", function(_, btn)
    if btn == "LeftButton" then
        if display:IsShown() then display:Hide() else display:Show() end
    end
end)

minimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("|cffcc2222Raid|r Death Tracker")
    GameTooltip:AddLine("|cffaaaaaa[Klick]|r Panel ein/ausblenden", 1, 1, 1)
    GameTooltip:AddLine("|cffaaaaaa[Drag] |r Position verschieben",  1, 1, 1)
    GameTooltip:Show()
end)

minimapBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- ----------------------------------------------------------------
-- UpdateDisplay
-- ----------------------------------------------------------------
local RANK_COLORS = {
    "|cffffcc00",  -- #1 Gold
    "|cffbbbbbb",  -- #2 Silber
    "|cffcd7f32",  -- #3 Bronze
    "|cff999999",  -- #4
    "|cff999999",  -- #5
}

function RaidDeathTrackerFrame:UpdateDisplay()
    if not RaidDeathData or next(RaidDeathData) == nil then
        contentText:SetText("|cff333344Keine Tode erfasst.|r")
        return
    end

    local sorted = {}
    local total  = 0
    for name, count in pairs(RaidDeathData) do
        table.insert(sorted, { name = name, count = count })
        total = total + count
    end
    table.sort(sorted, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return a.name < b.name
    end)

    local lines = {}
    for i = 1, math.min(TOP_N, #sorted) do
        local e   = sorted[i]
        local col = RANK_COLORS[i] or "|cff999999"
        table.insert(lines, string.format(
            "%s#%d|r  |cffdd4444%s|r   |cff777788%dx|r",
            col, i, e.name, e.count
        ))
    end

    local extra  = #sorted - TOP_N
    local footer = ""
    if extra > 0 then
        footer = string.format(
            "\n|cff33334a+%d weitere  -  Gesamt: %d|r",
            extra, total
        )
    elseif #sorted > 1 then
        footer = string.format("\n|cff444455Gesamt: %d Tode|r", total)
    end

    contentText:SetText(table.concat(lines, "\n") .. footer)
end

-- ----------------------------------------------------------------
-- Event Handler
-- ----------------------------------------------------------------
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == ADDON_NAME then
            if not RaidDeathData then RaidDeathData = {} end
            if not RDTConfig then RDTConfig = {} end
            if not RDTConfig.minimapAngle then RDTConfig.minimapAngle = 220 end
            UpdateMinimapButtonPos()
            self:UpdateDisplay()
            print("|cff00ff00[RDT]|r Geladen. /rdt fuer Hilfe")
        end

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, destGUID, destName =
            CombatLogGetCurrentEventInfo()

        if subEvent == "UNIT_DIED"
            and destGUID
            and destGUID:sub(1, 6) == "Player"
        then
            destName = destName or "Unknown"
            RaidDeathData[destName] = (RaidDeathData[destName] or 0) + 1
            self:UpdateDisplay()
        end
    end
end)

-- ----------------------------------------------------------------
-- Test-Modus
-- ----------------------------------------------------------------
local TEST_NAMES = {
    "Arthas", "Thrall", "Sylvanas", "Jaina", "Illidan",
    "Tyrande", "Kael'thas", "Vashj", "Akama", "Maiev",
}

local function ActivateTestMode()
    if not RaidDeathData then RaidDeathData = {} end
    local name = TEST_NAMES[math.random(1, #TEST_NAMES)]
    RaidDeathData[name] = (RaidDeathData[name] or 0) + math.random(1, 5)
    frame:UpdateDisplay()
    display:Show()
    testBadge:Show()
    print("|cff00ff00[RDT]|r |cffff9900Test:|r " .. name .. " hinzugefuegt.")
end

local function DeactivateTestMode()
    testBadge:Hide()
    RaidDeathData = {}
    frame:UpdateDisplay()
    print("|cff00ff00[RDT]|r Testmodus beendet.")
end

-- ----------------------------------------------------------------
-- Slash Commands
-- ----------------------------------------------------------------
SLASH_RAIDDEATHTRACKER1 = "/rdt"
SlashCmdList["RAIDDEATHTRACKER"] = function(msg)
    msg = msg:lower():match("^%s*(.-)%s*$")

    if     msg == "reset"      then
        RaidDeathData = {}
        frame:UpdateDisplay()
        print("|cff00ff00[RDT]|r Tode zurueckgesetzt.")
    elseif msg == "show"       then display:Show()
    elseif msg == "hide"       then display:Hide()
    elseif msg == "toggle"     then
        if display:IsShown() then display:Hide() else display:Show() end
    elseif msg == "test"       then ActivateTestMode()
    elseif msg == "test clear" then DeactivateTestMode()
    else
        print("|cff00ff00[RDT]|r Befehle:")
        print("  /rdt show        - Fenster anzeigen")
        print("  /rdt hide        - Fenster verstecken")
        print("  /rdt toggle      - Fenster umschalten")
        print("  /rdt reset       - Alle Tode zuruecksetzen")
        print("  /rdt test        - Testmodus (Dummy-Daten)")
        print("  /rdt test clear  - Testmodus beenden")
    end
end
