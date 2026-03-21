-- ============================================================
--  WowRaidDeathTracker  v1.1.0
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
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- Gruppen-Events: per pcall, da Verfuegbarkeit je nach Client-Version variiert
for _, evt in ipairs({"GROUP_ROSTER_UPDATE", "PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE"}) do
    pcall(frame.RegisterEvent, frame, evt)
end

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
-- Design-Palette (analog FishingKit)
-- ----------------------------------------------------------------
local D = {
    bg      = {0.04, 0.04, 0.06},  bgA  = 0.92,
    border  = {0.18, 0.18, 0.23},  borA = 0.80,
    divider = {0.14, 0.14, 0.18},  divA = 0.90,
    accent  = {0.28, 0.74, 0.97},   -- soft cyan
    label   = {0.40, 0.40, 0.45},   -- muted
    value   = {0.82, 0.84, 0.88},   -- bright
    danger  = {0.90, 0.30, 0.30},   -- red
    barBg   = {0.07, 0.07, 0.09},
}

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
display:Hide()  -- standard: nur in Gruppe/Raid sichtbar

-- Resize: neue API (SetResizeBounds) oder alte (SetResizable + SetMinResize)
if display.SetResizeBounds then
    display:SetResizeBounds(220, 150)
elseif display.SetResizable then
    display:SetResizable(true)
    if display.SetMinResize then display:SetMinResize(220, 150) end
end

-- Hintergrund
local bg = display:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(D.bg[1], D.bg[2], D.bg[3], D.bgA)

-- 1px Rahmen
AddPixelBorder(display, D.border[1], D.border[2], D.border[3], D.borA)

-- Icon (Header)
local icon = display:CreateTexture(nil, "OVERLAY")
icon:SetSize(16, 16)
icon:SetPoint("TOPLEFT", 10, -8)
icon:SetTexture("Interface\\Icons\\Spell_Shadow_DeathCoil")

-- Titel
local titleText = display:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
titleText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
titleText:SetText("|cff47bef5Raid Death Tracker|r")

-- TEST-Badge (neben Titel, nur im Testmodus sichtbar)
local testBadge = display:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
testBadge:SetPoint("LEFT", titleText, "RIGHT", 6, 0)
testBadge:SetText("|cffff9900[TEST]|r")
testBadge:Hide()

-- Schliessen-Button (FishingKit-Stil)
local closeBtn = CreateFrame("Button", nil, display)
closeBtn:SetSize(16, 16)
closeBtn:SetPoint("TOPRIGHT", -8, -8)
local closeBtnBg = closeBtn:CreateTexture(nil, "BACKGROUND")
closeBtnBg:SetAllPoints()
closeBtnBg:SetColorTexture(D.barBg[1], D.barBg[2], D.barBg[3], 0.8)
local closeTex = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
closeTex:SetPoint("CENTER", 0, 0)
closeTex:SetText("x")
closeTex:SetTextColor(D.label[1], D.label[2], D.label[3])
closeBtn:SetScript("OnEnter", function() closeTex:SetTextColor(D.value[1], D.value[2], D.value[3]) end)
closeBtn:SetScript("OnLeave", function() closeTex:SetTextColor(D.label[1], D.label[2], D.label[3]) end)
closeBtn:SetScript("OnClick", function() display:Hide() end)

-- Trennlinie unter Header
local headerLine = display:CreateTexture(nil, "ARTWORK")
headerLine:SetPoint("TOPLEFT",  10, -28)
headerLine:SetPoint("TOPRIGHT", -10, -28)
headerLine:SetHeight(1)
headerLine:SetColorTexture(D.divider[1], D.divider[2], D.divider[3], D.divA)

-- Content-Text
local contentText = display:CreateFontString(nil, "OVERLAY", "GameFontNormal")
contentText:SetPoint("TOPLEFT", display, "TOPLEFT", 10, -36)
contentText:SetWidth(240)
contentText:SetJustifyH("LEFT")
contentText:SetJustifyV("TOP")

-- Trennlinie über Footer
local footerLine = display:CreateTexture(nil, "ARTWORK")
footerLine:SetPoint("BOTTOMLEFT",  10, 24)
footerLine:SetPoint("BOTTOMRIGHT", -10, 24)
footerLine:SetHeight(1)
footerLine:SetColorTexture(D.divider[1], D.divider[2], D.divider[3], D.divA)

-- Hilfsfunktion: Footer-Button im FishingKit-Stil
local function MakeFooterBtn(label, r, g, b)
    local btn = CreateFrame("Button", nil, display)
    btn:SetSize(54, 14)
    local btnBg = btn:CreateTexture(nil, "BACKGROUND")
    btnBg:SetAllPoints()
    btnBg:SetColorTexture(D.barBg[1], D.barBg[2], D.barBg[3], 0.8)
    AddPixelBorder(btn, r, g, b, 0.6)
    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint("CENTER", 0, 0)
    btnText:SetText(label)
    btnText:SetTextColor(r, g, b)
    btn:SetScript("OnEnter", function() btnText:SetTextColor(D.value[1], D.value[2], D.value[3]) end)
    btn:SetScript("OnLeave", function() btnText:SetTextColor(r, g, b) end)
    return btn
end

-- Reset-Button (Footer links)
local resetBtn = MakeFooterBtn("Reset", D.danger[1], D.danger[2], D.danger[3])
resetBtn:SetPoint("BOTTOMLEFT", 8, 6)
resetBtn:SetScript("OnClick", function()
    RaidDeathData = {}
    frame:UpdateDisplay()
    print("|cff00ff00[RDT]|r Tode zurueckgesetzt.")
end)

-- Post-Button (Footer rechts)
local postBtn = MakeFooterBtn("Post", D.accent[1], D.accent[2], D.accent[3])
postBtn:SetPoint("BOTTOMRIGHT", -18, 6)
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
        tt:AddLine("|cff47bef5Raid Death Tracker|r")
        tt:AddLine("|cff666672[Klick]|r Panel ein/ausblenden", 1, 1, 1)
        tt:AddLine("|cff666672[Drag] |r Position verschieben",  1, 1, 1)
    end,
})

-- ----------------------------------------------------------------
-- Hilfsfunktion: sortierte Todesliste (desc count, asc name)
-- ----------------------------------------------------------------
local function GetSortedDeaths()
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
    return sorted, total
end

-- ----------------------------------------------------------------
-- UpdateDisplay
-- ----------------------------------------------------------------
local RANK_COLORS = {
    "|cffffcc00",  -- #1 Gold
    "|cffbbbbbb",  -- #2 Silber
    "|cffcd7f32",  -- #3 Bronze
    "|cff666672",  -- #4  (D.label)
    "|cff666672",  -- #5  (D.label)
}

function RaidDeathTrackerFrame:UpdateDisplay()
    if not RaidDeathData or next(RaidDeathData) == nil then
        contentText:SetText("|cff333344Keine Tode erfasst.|r")
        return
    end

    local sorted, total = GetSortedDeaths()

    local lines = {}
    for i = 1, math.min(TOP_N, #sorted) do
        local e   = sorted[i]
        local col = RANK_COLORS[i] or "|cff999999"
        table.insert(lines, string.format(
            "%s#%d|r  |cffd1d6e1%s|r   |cff666672%dx|r",
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

    local sorted = GetSortedDeaths()

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
    for i = 1, math.min(TOP_N, #sorted) do
        local e = sorted[i]
        send(string.format("#%d  %s  -- %dx", i, e.name, e.count))
    end
    send("------------------------------")

    local dest = channel or "lokalen Chat"
    print("|cff00ff00[RDT]|r Top 5 gepostet in " .. dest .. ".")
end

-- ----------------------------------------------------------------
-- Gruppen-Sichtbarkeit + Auto-Reset beim Beitreten
-- ----------------------------------------------------------------
local wasInGroup = false

local function UpdateGroupVisibility()
    if testBadge:IsShown() then return end
    local inGroup = IsInRaid() or IsInGroup()
    if inGroup and not wasInGroup then
        -- Gruppe/Raid beigetreten: Daten zuruecksetzen und anzeigen
        RaidDeathData = {}
        frame:UpdateDisplay()
        display:Show()
        print("|cff00ff00[RDT]|r Gruppe beigetreten – Daten zurueckgesetzt.")
    elseif not inGroup then
        display:Hide()
    end
    wasInGroup = inGroup
end

-- ----------------------------------------------------------------
-- Feign-Death-Erkennung: Tod erst nach 3s bestaetigen
-- ----------------------------------------------------------------
local FEIGN_DEATH_DELAY = 3
local pendingDeaths = {}  -- { [name] = { time = t, token = "raid1"|"party1"|"player" } }

local deathCheckFrame = CreateFrame("Frame")

local function FindUnitToken(name)
    if UnitName("player") == name then return "player" end
    for i = 1, 40 do
        local token = "raid"..i
        if not UnitExists(token) then break end
        if UnitName(token) == name then return token end
    end
    for i = 1, 4 do
        local token = "party"..i
        if not UnitExists(token) then break end
        if UnitName(token) == name then return token end
    end
end

local function OnDeathCheck(self)
    local now = GetTime()
    for name, entry in pairs(pendingDeaths) do
        if now - entry.time >= FEIGN_DEATH_DELAY then
            pendingDeaths[name] = nil
            if UnitIsDead(entry.token) then
                RaidDeathData[name] = (RaidDeathData[name] or 0) + 1
                frame:UpdateDisplay()
            end
            -- andernfalls: Feign Death — nicht zaehlen
        end
    end
    if not next(pendingDeaths) then
        self:SetScript("OnUpdate", nil)
    end
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
            UpdateGroupVisibility()
            print("|cff00ff00[RDT]|r v1.1.0 Geladen. /rdt fuer Hilfe")
        end

    elseif event == "PLAYER_ENTERING_WORLD"
        or event == "GROUP_ROSTER_UPDATE"
        or event == "PARTY_MEMBERS_CHANGED"
        or event == "RAID_ROSTER_UPDATE" then
        UpdateGroupVisibility()

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, destGUID, destName =
            CombatLogGetCurrentEventInfo()

        if subEvent == "UNIT_DIED"
            and destGUID
            and destGUID:sub(1, 6) == "Player"
            and (IsInRaid() or IsInGroup())
        then
            -- Nur eigene Gruppen-/Raid-Mitglieder zaehlen
            local token = FindUnitToken(destName)
            if token then
                local _, classId = UnitClass(token)
                if classId == "HUNTER" then
                    -- Feign Death moeglich: erst nach 3s bestaetigen
                    pendingDeaths[destName] = { time = GetTime(), token = token }
                    deathCheckFrame:SetScript("OnUpdate", OnDeathCheck)
                else
                    RaidDeathData[destName] = (RaidDeathData[destName] or 0) + 1
                    frame:UpdateDisplay()
                end
            end
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
    print("|cff00ff00[RDT]|r Test: " .. #TEST_NAMES .. " Eintraege erstellt.")
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

    if     msg == ""           then
        if display:IsShown() then display:Hide() else display:Show() end
    elseif msg == "reset"      then
        RaidDeathData = {}
        frame:UpdateDisplay()
        print("|cff00ff00[RDT]|r Tode zurueckgesetzt.")
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
        print("  Minimap-Winkel: " .. tostring(RDTConfig and RDTConfig.minimapPos))
        print("  Minimap-Btn groesse: " .. minimapBtn:GetWidth() .. "x" .. minimapBtn:GetHeight())
    else
        print("|cff00ff00[RDT]|r Befehle:")
        print("  /rdt            - Fenster ein/ausblenden")
        print("  /rdt reset      - Alle Tode zuruecksetzen")
        print("  /rdt post       - Top 5 in Raid/Party posten")
        print("  /rdt test       - Testmodus (Dummy-Daten)")
        print("  /rdt test clear - Testmodus beenden")
        print("  /rdt debug      - Debug-Informationen anzeigen")
    end
end
