-- ============================================================
--  WowRaidDeathTracker
--  TBC Classic Anniversary
--  Zählt Spielertode im Raid/Party und zeigt eine Strichliste.
-- ============================================================

-- ----------------------------------------------------------------
-- Event Frame (Core)
-- ----------------------------------------------------------------
local frame = CreateFrame("Frame", "RaidDeathTrackerFrame", UIParent)
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ADDON_LOADED")

-- ----------------------------------------------------------------
-- Display Frame (UI)
-- ----------------------------------------------------------------
local display = CreateFrame("Frame", "RaidDeathTrackerDisplay", UIParent)
display:SetSize(300, 420)
display:SetPoint("CENTER")
display:SetMovable(true)
display:EnableMouse(true)
display:RegisterForDrag("LeftButton")
display:SetScript("OnDragStart", display.StartMoving)
display:SetScript("OnDragStop",  display.StopMovingOrSizing)
display:SetClampedToScreen(true)

-- Background
local bg = display:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0, 0, 0, 0.65)

-- Border
local border = CreateFrame("Frame", nil, display, "BackdropTemplate")
border:SetAllPoints()
border:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets    = { left = 3, right = 3, top = 3, bottom = 3 },
})
border:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

-- Title
local title = display:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("|cffff4444☠|r Raid Death Tracker")

-- Scrolling text area
local scrollFrame = CreateFrame("ScrollFrame", nil, display, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT",     10, -35)
scrollFrame:SetPoint("BOTTOMRIGHT", -28, 34)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(260, 1)
scrollFrame:SetScrollChild(scrollChild)

local text = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("TOPLEFT", 0, 0)
text:SetWidth(250)
text:SetJustifyH("LEFT")
text:SetJustifyV("TOP")
text:SetWordWrap(true)

-- Reset Button
local resetBtn = CreateFrame("Button", nil, display, "UIPanelButtonTemplate")
resetBtn:SetSize(110, 24)
resetBtn:SetPoint("BOTTOM", 0, 6)
resetBtn:SetText("Reset")
resetBtn:SetScript("OnClick", function()
    RaidDeathData = {}
    RaidDeathTrackerFrame:UpdateDisplay()
    print("|cff00ff00[RDT]|r Tode zurückgesetzt.")
end)

-- ----------------------------------------------------------------
-- Helper: Strichliste erzeugen
-- Gruppen zu je 5 werden als "卌" dargestellt, Rest als Striche.
-- ----------------------------------------------------------------
local function GetTally(count)
    local tally = ""
    local full  = math.floor(count / 5)
    local rest  = count % 5
    for _ = 1, full do tally = tally .. "卌 " end
    local marks = { "|", "||", "|||", "||||" }
    if rest > 0 then tally = tally .. marks[rest] end
    return tally
end

-- ----------------------------------------------------------------
-- UpdateDisplay
-- ----------------------------------------------------------------
function RaidDeathTrackerFrame:UpdateDisplay()
    if not RaidDeathData or next(RaidDeathData) == nil then
        text:SetText("|cff888888Keine Tode erfasst.|r")
        scrollChild:SetHeight(20)
        return
    end

    -- In sortierbare Liste umwandeln (meiste Tode oben)
    local sorted = {}
    for name, count in pairs(RaidDeathData) do
        table.insert(sorted, { name = name, count = count })
    end
    table.sort(sorted, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return a.name < b.name
    end)

    local lines = {}
    for _, entry in ipairs(sorted) do
        local tally = GetTally(entry.count)
        table.insert(lines, string.format(
            "|cffff6666%s|r  %s |cff888888(%d)|r",
            entry.name, tally, entry.count
        ))
    end

    local content = table.concat(lines, "\n")
    text:SetText(content)

    -- ScrollChild-Höhe dynamisch anpassen
    local lineCount = #lines
    scrollChild:SetHeight(math.max(lineCount * 18, 20))
end

-- ----------------------------------------------------------------
-- Event Handler
-- ----------------------------------------------------------------
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == "WowRaidDeathTracker" then
            if not RaidDeathData then RaidDeathData = {} end
            self:UpdateDisplay()
            print("|cff00ff00[RDT]|r Addon geladen. Befehl: /rdt")
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
-- Slash Commands
-- /rdt          → Hilfe
-- /rdt show     → Fenster anzeigen
-- /rdt hide     → Fenster verstecken
-- /rdt toggle   → Fenster umschalten
-- /rdt reset    → Zähler zurücksetzen
-- ----------------------------------------------------------------
SLASH_RAIDDEATHTRACKER1 = "/rdt"
SlashCmdList["RAIDDEATHTRACKER"] = function(msg)
    msg = msg:lower():match("^%s*(.-)%s*$") -- trim

    if msg == "reset" then
        RaidDeathData = {}
        RaidDeathTrackerFrame:UpdateDisplay()
        print("|cff00ff00[RDT]|r Tode zurückgesetzt.")
    elseif msg == "hide" then
        display:Hide()
    elseif msg == "show" then
        display:Show()
    elseif msg == "toggle" then
        if display:IsShown() then display:Hide() else display:Show() end
    else
        print("|cff00ff00[RDT]|r Befehle:")
        print("  /rdt show    – Fenster anzeigen")
        print("  /rdt hide    – Fenster verstecken")
        print("  /rdt toggle  – Fenster umschalten")
        print("  /rdt reset   – Alle Tode zurücksetzen")
    end
end
