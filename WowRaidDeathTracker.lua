-- ============================================================
--  WowRaidDeathTracker  v2.3
--  TBC Classic Anniversary (2.5.5)
--  Zählt Spielertode – solo, in Party und Raid.
-- ============================================================

local ADDON_NAME = "WowRaidDeathTracker"
local TOP_N      = 5

-- Diagnose: Grosser Text auf dem Bildschirm wenn die Datei geladen wird
UIErrorsFrame:AddMessage("RDT v2.3 Datei geladen!", 1, 0.6, 0)

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

-- Content-Text
local contentText = display:CreateFontString(nil, "OVERLAY", "GameFontNormal")
contentText:SetPoint("TOPLEFT", display, "TOPLEFT", 10, -34)
contentText:SetWidth(240)
contentText:SetJustifyH("LEFT")
contentText:SetJustifyV("TOP")

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

-- Post-Button (Footer rechts)
local postBtn = CreateFrame("Button", nil, display)
postBtn:SetSize(54, 14)
postBtn:SetPoint("BOTTOMRIGHT", -18, 5)

local postBtnBg = postBtn:CreateTexture(nil, "BACKGROUND")
postBtnBg:SetAllPoints()
postBtnBg:SetColorTexture(0.06, 0.14, 0.24, 1)

AddPixelBorder(postBtn, 0.12, 0.28, 0.48, 0.9)

local postBtnText = postBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
postBtnText:SetAllPoints()
postBtnText:SetText("|cff3399ccPost|r")

postBtn:SetScript("OnEnter", function()
    postBtnBg:SetColorTexture(0.08, 0.20, 0.36, 1)
    postBtnText:SetText("|cff55bbffPost|r")
end)
postBtn:SetScript("OnLeave", function()
    postBtnBg:SetColorTexture(0.06, 0.14, 0.24, 1)
    postBtnText:SetText("|cff3399ccPost|r")
end)
postBtn:SetScript("OnClick", function()
    PostDeathsToChat()
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
-- Minimap-Button (via LibDBIcon)
-- ----------------------------------------------------------------
local minimapBtn  -- wird nach ADDON_LOADED gesetzt

local ldbObj = LibStub("LibDataBroker-1-1"):NewDataObject("WowRaidDeathTracker", {
    type = "launcher",
    icon = "Interface\\Icons\\Spell_Shadow_DeathCoil",
    OnClick = function(self, btn)
        if btn == "LeftButton" then
            if display:IsShown() then display:Hide() else display:Show() end
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddLine("|cffcc2222Raid|r Death Tracker")
        tt:AddLine("|cffaaaaaa[Klick]|r Panel ein/ausblenden", 1, 1, 1)
        tt:AddLine("|cffaaaaaa[Drag] |r Position verschieben",  1, 1, 1)
    end,
})

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

    local finalText = table.concat(lines, "\n") .. footer
    print("|cff00ff00[RDT]|r Display: " .. #sorted .. " gesamt, " .. #lines .. " angezeigt")
    contentText:SetText(finalText)
end

-- ----------------------------------------------------------------
-- Post Top 5 in Raid/Party
-- ----------------------------------------------------------------
function PostDeathsToChat()
    if not RaidDeathData or next(RaidDeathData) == nil then
        print("|cff00ff00[RDT]|r Keine Daten zum Posten.")
        return
    end

    local sorted = {}
    for name, count in pairs(RaidDeathData) do
        table.insert(sorted, { name = name, count = count })
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)

    local channel
    if testBadge:IsShown() then
        channel = "SAY"
    elseif IsInRaid() then
        channel = "RAID"
    elseif IsInGroup() then
        channel = "PARTY"
    end

    local function send(msg)
        if channel then
            SendChatMessage(msg, channel)
        else
            print(msg)
        end
    end

    send("( --< Raid Death Tracker >-- )")
    for i = 1, math.min(5, #sorted) do
        local e = sorted[i]
        send(string.format("#%d  %s  -- %dx", i, e.name, e.count))
    end
    send("------------------------------")

    local dest = channel or "lokalen Chat"
    print("|cff00ff00[RDT]|r Top 5 gepostet in " .. dest .. ".")
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
            -- Migration: altes minimapAngle-Feld -> minimapPos (LibDBIcon-Format)
            if not RDTConfig.minimapPos then
                RDTConfig.minimapPos = RDTConfig.minimapAngle or 220
                RDTConfig.minimapAngle = nil
            end
            LibStub("LibDBIcon-1.0"):Register("WowRaidDeathTracker", ldbObj, RDTConfig)
            minimapBtn = LibStub("LibDBIcon-1.0"):GetMinimapButton("WowRaidDeathTracker")
            self:UpdateDisplay()
            print("|cff00ff00[RDT]|r v2.3 Geladen. /rdt fuer Hilfe")
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
    RaidDeathData = {}
    for _, name in ipairs(TEST_NAMES) do
        RaidDeathData[name] = math.random(1, 15)
    end
    local count = 0
    for _ in pairs(RaidDeathData) do count = count + 1 end
    print("|cff00ff00[RDT]|r Test: " .. count .. " Eintraege erstellt.")
    display:Show()
    frame:UpdateDisplay()
    testBadge:Show()
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
    elseif msg == "post"       then PostDeathsToChat()
    elseif msg == "test"       then ActivateTestMode()
    elseif msg == "test clear" then DeactivateTestMode()
    elseif msg == "debug"      then
        local count = 0
        if RaidDeathData then for _ in pairs(RaidDeathData) do count = count + 1 end end
        print("|cff00ff00[RDT]|r Debug:")
        print("  Eintraege: " .. count)
        print("  Panel sichtbar: " .. tostring(display:IsShown()))
        print("  Panel groesse: " .. math.floor(display:GetWidth()) .. "x" .. math.floor(display:GetHeight()))
        print("  Minimap-Winkel: " .. tostring(RDTConfig and RDTConfig.minimapAngle))
        print("  Minimap-Btn groesse: " .. minimapBtn:GetWidth() .. "x" .. minimapBtn:GetHeight())
    else
        print("|cff00ff00[RDT]|r Befehle:")
        print("  /rdt show        - Fenster anzeigen")
        print("  /rdt hide        - Fenster verstecken")
        print("  /rdt toggle      - Fenster umschalten")
        print("  /rdt reset       - Alle Tode zuruecksetzen")
        print("  /rdt post        - Top 5 in Raid/Party posten")
        print("  /rdt test        - Testmodus (Dummy-Daten)")
        print("  /rdt test clear  - Testmodus beenden")
        print("  /rdt debug       - Debug-Informationen anzeigen")
    end
end
