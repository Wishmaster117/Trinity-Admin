local module = TrinityAdmin:GetModule("GMFunctionsPanel")
local L = _G.L

local gpsFrame
local mapEdit, zoneEdit, areaEdit, xEdit, yEdit, zEdit, oEdit, GridEdit, CellEdit, InstanceIDEdit

-- print("At top of file: gpsFrame =", gpsFrame)  -- Devrait afficher "nil"

-------------------------------------------------------------
-- Création de la popup GPS avec les champs de saisie
-------------------------------------------------------------
local function CreateGPSFrame()
 print("CreateGPSFrame() is running...")
    local AceGUI = LibStub("AceGUI-3.0")
    gpsFrame = AceGUI:Create("Frame")
	-- print("gpsFrame created =>", gpsFrame)
    gpsFrame:SetTitle("GPS Info")
    gpsFrame:SetStatusText("Information GPS")
    gpsFrame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        gpsFrame = nil
    end)
    gpsFrame:SetLayout("Flow")
    
    local group = AceGUI:Create("InlineGroup")
    group:SetFullWidth(true)
    group:SetTitle("Coordinates")
    group:SetLayout("Flow")
    gpsFrame:AddChild(group)
    
    mapEdit = AceGUI:Create("EditBox")
    mapEdit:SetLabel("Map:")
    mapEdit:SetFullWidth(true)
    group:AddChild(mapEdit)
    
    zoneEdit = AceGUI:Create("EditBox")
    zoneEdit:SetLabel("Zone:")
    zoneEdit:SetFullWidth(true)
    group:AddChild(zoneEdit)
    
    areaEdit = AceGUI:Create("EditBox")
    areaEdit:SetLabel("Area:")
    areaEdit:SetFullWidth(true)
    group:AddChild(areaEdit)
    
    xEdit = AceGUI:Create("EditBox")
    xEdit:SetLabel("X:")
    xEdit:SetWidth(80)
    group:AddChild(xEdit)
    
    yEdit = AceGUI:Create("EditBox")
    yEdit:SetLabel("Y:")
    yEdit:SetWidth(80)
    group:AddChild(yEdit)
    
    zEdit = AceGUI:Create("EditBox")
    zEdit:SetLabel("Z:")
    zEdit:SetWidth(80)
    group:AddChild(zEdit)
    
    oEdit = AceGUI:Create("EditBox")
    oEdit:SetLabel("O:")
    oEdit:SetWidth(80)
    group:AddChild(oEdit)
    
    GridEdit = AceGUI:Create("EditBox")
    GridEdit:SetLabel("Grid:")
    GridEdit:SetWidth(80)
    group:AddChild(GridEdit)
    
    CellEdit = AceGUI:Create("EditBox")
    CellEdit:SetLabel("Cell:")
    CellEdit:SetWidth(80)
    group:AddChild(CellEdit)
    
    InstanceIDEdit = AceGUI:Create("EditBox")
    InstanceIDEdit:SetLabel("InstanceID:")
    InstanceIDEdit:SetWidth(80)
    group:AddChild(InstanceIDEdit)
    
    --gpsFrame:Hide()
	-- print("Fin de CreateGPSFrame(), gpsFrame =", gpsFrame)
end

-------------------------------------------------------------
-- 1. Déclaration des variables pour la capture GPS
-------------------------------------------------------------
local capturingGPSInfo = false
local gpsInfoCollected = {}
local gpsInfoTimer = nil
-- Déclaration forward de la fonction
local FinishGPSInfoCapture

------------------------------------------------------------
-- CaptureFrame pour écouter CHAT_MSG_SYSTEM pour la capture GPS
------------------------------------------------------------
local gpsCaptureFrame = CreateFrame("Frame")
gpsCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
gpsCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingGPSInfo then return end
    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                         :gsub("|H.-|h(.-)|h", "%1")
                         :gsub("|T.-|t", "")
    table.insert(gpsInfoCollected, cleanMsg)
    if gpsInfoTimer then gpsInfoTimer:Cancel() end
    gpsInfoTimer = C_Timer.NewTimer(1, FinishGPSInfoCapture)
end)

------------------------------------------------------------
-- Fonction de traitement de la capture GPS
------------------------------------------------------------
FinishGPSInfoCapture = function()
-- print("FinishGPSInfoCapture() => gpsFrame:", gpsFrame)
    capturingGPSInfo = false
    if #gpsInfoCollected > 0 then
        local fullText = table.concat(gpsInfoCollected, "\n")
        -- Captures pour Map, Zone et Area (numéro et texte entre parenthèses)
        local mapNum, mapName = fullText:match("Map:%s*(%S+)%s*%(([^)]+)%)")
        local zoneNum, zoneName = fullText:match("Zone:%s*(%S+)%s*%(([^)]+)%)")
        local areaNum, areaName = fullText:match("Area:%s*(%S+)%s*%(([^)]+)%)")
        
        local x = fullText:match("X:%s*(%S+)")
        local y = fullText:match("Y:%s*(%S+)")
        local z = fullText:match("Z:%s*(%S+)")
        local o = fullText:match("Orientation:%s*(%S+)")
        local grid = fullText:match("grid%s*(%S+)%s*cell")
        local cell = fullText:match("cell%s*(%S+)%s*InstanceID")
        local instanceid = fullText:match("InstanceID:%s*(%S+)")
        
        local mapText = mapNum and (mapNum .. (mapName and " (" .. mapName .. ")" or "")) or ""
        local zoneText = zoneNum and (zoneNum .. (zoneName and " (" .. zoneName .. ")" or "")) or ""
        local areaText = areaNum and (areaNum .. (areaName and " (" .. areaName .. ")" or "")) or ""
        
        if not gpsFrame then
		-- print("gpsFrame is nil, so calling CreateGPSFrame() now...")
            CreateGPSFrame()
        end
        
        mapEdit:SetText(mapText)
        zoneEdit:SetText(zoneText)
        areaEdit:SetText(areaText)
        xEdit:SetText(x or "")
        yEdit:SetText(y or "")
        zEdit:SetText(z or "")
        oEdit:SetText(o or "")
        GridEdit:SetText(grid or "")
        CellEdit:SetText(cell or "")
        InstanceIDEdit:SetText(instanceid or "")
        
		-- print("After CreateGPSFrame(), gpsFrame:", gpsFrame)
        gpsFrame:Show()
    else
        print("Aucune information GPS capturée.")
    end
end

-------------------------------------------------------------
-- Variables et fonctions pour la capture du .guild info
-------------------------------------------------------------
local capturingGuidInfo = false
local guidInfoCollected = {}
local guidInfoTimer = nil

-- Fonction appelée quand on arrête la capture du .guild info
local function FinishGuidInfoCapture()
    capturingGuidInfo = false
    if #guidInfoCollected > 0 then
        local fullText = table.concat(guidInfoCollected, "\n")
        GuidInfoPopup_SetText(fullText)
        GuidInfoPopup:Show()
    else
        TrinityAdmin:Print("Nothing Captures.")
    end
end

-------------------------------------------------------------
-- Création de la popup GuildInfoPopup pour le .guild info
-------------------------------------------------------------
local GuidInfoPopup = CreateFrame("Frame", "GuidInfoPopup", UIParent, "BackdropTemplate")
GuidInfoPopup:SetSize(400, 300)
GuidInfoPopup:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -100, -100)
GuidInfoPopup:SetMovable(true)
GuidInfoPopup:EnableMouse(true)
GuidInfoPopup:RegisterForDrag("LeftButton")
GuidInfoPopup:SetScript("OnDragStart", GuidInfoPopup.StartMoving)
GuidInfoPopup:SetScript("OnDragStop", GuidInfoPopup.StopMovingOrSizing)
GuidInfoPopup:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
GuidInfoPopup:Hide()

local title = GuidInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -15)
title:SetText("Guild Info")

local closeButton = CreateFrame("Button", nil, GuidInfoPopup, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", GuidInfoPopup, "TOPRIGHT")

local scrollFrame = CreateFrame("ScrollFrame", "GuidInfoScrollFrame", GuidInfoPopup, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 15, -50)
scrollFrame:SetSize(370, 230)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(370, 230)
scrollFrame:SetScrollChild(content)

local infoText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
infoText:SetPoint("TOPLEFT")
infoText:SetWidth(350)
infoText:SetJustifyH("LEFT")
infoText:SetJustifyV("TOP")

function GuidInfoPopup_SetText(text)
    infoText:SetText(text or "")
    local textHeight = infoText:GetStringHeight()
    content:SetHeight(textHeight + 5)
    scrollFrame:SetVerticalScroll(0)
end

-------------------------------------------------------------
-- CaptureFrame pour écouter CHAT_MSG_SYSTEM pour .guild info
-------------------------------------------------------------
local guidCaptureFrame = CreateFrame("Frame")
guidCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
guidCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingGuidInfo then
        return
    end
    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
                       :gsub("|r", "")
                       :gsub("|H.-|h(.-)|h", "%1")
                       :gsub("|T.-|t", "")
                       :gsub("\226[\148-\149][\128-\191]", "")
    table.insert(guidInfoCollected, cleanMsg)
    if guidInfoTimer then guidInfoTimer:Cancel() end
    guidInfoTimer = C_Timer.NewTimer(1, FinishGuidInfoCapture)
end)


------------------------------------------------------------------
-- Table listant tous les boutons (sans le bouton Appear).
------------------------------------------------------------------
local buttonDefs = {
    {
        name = "btnFly",
        textON = "GM Fly ON",  
        textOFF = "GM Fly OFF",
        tooltip = L["btnFly tooltip"],
        commandON = ".gm fly on",
        commandOFF = ".gm fly off",
        isToggle = true,
        anchorTo = "TOPLEFT",
        anchorOffsetX = 10,
        anchorOffsetY = -50,
        linkTo = nil,
        stateVar = "gmFlyOn",
    },
    {
        name = "btnGmOn",
        textON = "GM ON",
        textOFF = "GM OFF",
        tooltip = L["btnGmOn tooltip"],
        commandON = ".gm on",
        commandOFF = ".gm off",
        isToggle = true,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnFly",
        stateVar = "gmOn",
    },
    {
        name = "btnGmChat",
        textON = "GM Chat ON",
        textOFF = "GM Chat OFF",
        tooltip = L["btnGmChat tooltip"],
        commandON = ".gm chat on",
        commandOFF = ".gm chat off",
        isToggle = true,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnGmOn",
        stateVar = "gmChatOn",
    },
    {
        name = "btnGmIngame",
        text = "GM Ingame",
        tooltip = L["btnGmIngame tooltip"],
        command = ".gm ingame",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnGmChat",
    },
    {
        name = "btnGmList",
        text = "GM List",
        tooltip = L["btnGmList tooltip"],
        command = ".gm list",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnGmIngame",
    },
    {
        name = "btnGmVisible",
        textON = "GM Visible ON",
        textOFF = "GM Visible OFF",
        tooltip = L["btnGmVisible tooltip"],
        commandON = ".gm visible on",
        commandOFF = ".gm visible off",
        isToggle = true,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnGmList",
        stateVar = "gmVisible",
    },
    -- (On commente btnAppear pour faire notre champ de saisie custom)
    -- {
    --     name = "btnAppear",
    --     text = "Appear",
    --     ...
    -- },
    {
        name = "btnRevive",
        text = "Revive",
        tooltip = L["btnRevive tooltip"],
        command = ".revive",
        isToggle = false,
        anchorTo = "TOPLEFT",
        anchorOffsetX = -90,
        anchorOffsetY = -20,
        linkTo = "btnFly",
    },
    {
        name = "btnDie",
        text = "Die",
        tooltip = L["btnDie tooltip"],
        command = ".die",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnRevive",
    },
    {
        name = "btnSave",
        text = "Save",
        tooltip = L["btnSave tooltip"],
        command = ".save",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnDie",
    },
    {
        name = "btnSaveAll",
        text = "Save All",
        tooltip = L["btnSaveAll tooltip"],
        command = ".saveall",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnSave",
    },
    {
        name = "btnRespawn",
        text = "Respawn",
        tooltip = L["btnRespawn tooltip"],
        command = ".respawn",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnSaveAll",
    },
    {
        name = "btnDemorph",
        text = "Demorph",
        tooltip = L["btnDemorph tooltip"],
        command = ".demorph",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnRespawn",
    },
    {
        name = "btnWhispers",
        textON = "GM Whispers ON",
        textOFF = "GM Whispers OFF",
        tooltip = L["btnWhispers tooltip"],
        commandON = ".whispers on",
        commandOFF = ".whispers off",
        isToggle = true,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnDemorph",
        stateVar = "gmWhispers",
    },
    {
        name = "btnMailbox",
        text = "MailBox",
        tooltip = L["btnMailbox tooltip"],
        command = ".mailbox",
        isToggle = false,
        anchorTo = "TOPLEFT",
        anchorOffsetX = -60,
        anchorOffsetY = -20,
        linkTo = "btnRevive",
    },	
    {
        name = "btnBank",
        text = "Bank",
        tooltip = L["btnBank tooltip"],
        command = ".bank",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnMailbox",
    },	
    {
        name = "btncometome",
        text = "Come To Me",
        tooltip = L["btncometome tooltip"],
        command = ".cometome",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnBank",
    },	
    {
        name = "btnguid",
        text = "Character Guid",
        tooltip = L["btnguid tooltip"],
        command = ".guid",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btncometome",
    },
    {
        name = "btndismount",
        text = "Dismount",
        tooltip = L["btndismount tooltip"],
        command = ".dismount",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnguid",
    },	
    {
        name = "btnpossess",
        text = "Possess",
        tooltip = L["btnpossess tooltip"],
        command = ".possess",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btndismount",
    },
	{
		name = "btnGPS",
		text = "GPS",
		tooltip = L["btnGPS tooltip"],
		isToggle = false,
		anchorTo = "LEFT",
		anchorOffsetX = 10,
		anchorOffsetY = 0,
		linkTo = "btnpossess",
   },	
}

------------------------------------------------------------------
-- Petite fonction utilitaire pour fixer le tooltip
------------------------------------------------------------------
local function SetTooltipScripts(btn, tooltipText)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltipText or "", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

------------------------------------------------------------------
-- Fonction pour créer un bouton à partir de la définition
------------------------------------------------------------------
local function CreateGMButton(panel, def, module, buttonRefs)
    local btn = CreateFrame("Button", def.name, panel, "UIPanelButtonTemplate")
    local anchorRelative = panel
    local anchorPoint    = def.anchorTo or "TOPLEFT"
    local relativePoint  = def.anchorTo

    if def.linkTo and buttonRefs[def.linkTo] then
        anchorRelative = buttonRefs[def.linkTo]
        relativePoint  = "RIGHT"
    end

    btn:SetPoint(anchorPoint, anchorRelative, relativePoint, def.anchorOffsetX, def.anchorOffsetY)

    if def.isToggle and def.stateVar then
        local state = module[def.stateVar]
        if state then
            btn:SetText(def.textON)
        else
            btn:SetText(def.textOFF)
        end
    else
        btn:SetText(def.text)
    end

    btn:SetHeight(22)
    btn:SetWidth(btn:GetTextWidth() + 20)

    if def.isToggle and def.stateVar then
        btn:SetScript("OnClick", function()
            if module[def.stateVar] then
                SendChatMessage(def.commandOFF, "SAY")
                btn:SetText(def.textOFF)
                module[def.stateVar] = false
            else
                SendChatMessage(def.commandON, "SAY")
                btn:SetText(def.textON)
                module[def.stateVar] = true
            end
        end)
    else
        btn:SetScript("OnClick", function()
            -- print("Commande envoyée :" .. def.command)
            SendChatMessage(def.command, "SAY")
        end)
    end

    SetTooltipScripts(btn, def.tooltip)
    buttonRefs[def.name] = btn
end

------------------------------------------------------------------
-- Fonctions du module
------------------------------------------------------------------
function module:ShowGMFunctionsPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateGMFunctionsPanel()
    end
    self.panel:Show()
end

function module:CreateGMFunctionsPanel()
    local panel = CreateFrame("Frame", "TrinityAdminGMFunctionsPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(L["GM Functions Panel"] or "GM Functions Panel")

    ----------------------------------------------------------------------------
    -- Création du conteneur de contenu pour la pagination
    ----------------------------------------------------------------------------
    local contentContainer = CreateFrame("Frame", nil, panel)
    contentContainer:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, 30)
    contentContainer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 40)

    local totalPages = 3
    local pages = {}
    for i = 1, totalPages do
        pages[i] = CreateFrame("Frame", nil, contentContainer)
        pages[i]:SetAllPoints(contentContainer)
        pages[i]:Hide()
        pages[i].yOffset = 0
    end

    ----------------------------------------------------------------------------
    -- Fonction utilitaire pour créer une ligne dans une page
    ----------------------------------------------------------------------------
    local function CreateRow(page, height)
        local row = CreateFrame("Frame", nil, page)
        row:SetSize(contentContainer:GetWidth(), height)
        row:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -page.yOffset)
        page.yOffset = page.yOffset + height + 5
        return row
    end

    ----------------------------------------------------------------------------
    -- Boutons de navigation de la pagination
    ----------------------------------------------------------------------------
    local currentPage = 1
    local btnPrev, btnNext

    local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 35)
    navPageLabel:SetText("Page 1 / " .. totalPages)

    local function ShowPage(pageIndex)
        for i = 1, totalPages do
            if i == pageIndex then
                pages[i]:Show()
            else
                pages[i]:Hide()
            end
        end
        navPageLabel:SetText("Page " .. pageIndex .. " / " .. totalPages)
        btnPrev:SetEnabled(pageIndex > 1)
        btnNext:SetEnabled(pageIndex < totalPages)
    end

    btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnPrev:SetSize(80, 22)
    btnPrev:SetText(L["Preview"])
    btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            ShowPage(currentPage)
        end
    end)

    btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnNext:SetSize(80, 22)
    btnNext:SetText(L["Next"])
    btnNext:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
    btnNext:SetScript("OnClick", function()
        if currentPage < totalPages then
            currentPage = currentPage + 1
            ShowPage(currentPage)
        end
    end)

    ShowPage(currentPage)

    ----------------------------------------------------------------------------
    -- PAGE 1 : Contient le contenu existant
    ----------------------------------------------------------------------------
    do
        local page = pages[1]

        -- Tableau pour stocker les références de nos boutons
        local buttonRefs = {}

        -- Création de tous les boutons à partir de buttonDefs
        for _, def in ipairs(buttonDefs) do
            CreateGMButton(page, def, self, buttonRefs)
        end

if buttonRefs["btnGPS"] then
    buttonRefs["btnGPS"]:SetScript("OnClick", function()
        capturingGPSInfo = true
        gpsInfoCollected = {}
        if gpsInfoTimer then
            gpsInfoTimer:Cancel()
            gpsInfoTimer = nil
        end
        SendChatMessage(".gps", "SAY")
    end)
end
        -- Ajout du comportement personnalisé pour le bouton "btnguid"
		if buttonRefs["btnguid"] then
			buttonRefs["btnguid"]:SetScript("OnClick", function()
				local targetName = UnitName("target")
				if not targetName or not UnitIsPlayer("target") then
					print("Merci de selectionner un personnage valide")
					return
				end
				capturingGuidInfo = true
				guidInfoCollected = {}
				if guidInfoTimer then
					guidInfoTimer:Cancel()
					guidInfoTimer = nil
				end
				SendChatMessage(".guid", "SAY")
			end)
		end


        ------------------------------------------------------------------
        -- Création du champ "Appear" et son bouton Go
        ------------------------------------------------------------------
        local anchor = buttonRefs["btnMailbox"]
        if anchor then
            local appearLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            appearLabel:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -20)
            appearLabel:SetText(L["Appear Function"])

            local appearEdit = CreateFrame("EditBox", "TrinityAdminAppearEditBox", page, "InputBoxTemplate")
            appearEdit:SetAutoFocus(false)
            appearEdit:SetSize(120, 22)
            appearEdit:SetPoint("TOPLEFT", appearLabel, "BOTTOMLEFT", 0, -5)
            appearEdit:SetText(L["Character Name_appear"])
            appearEdit:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Tele_to_Player"], 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            appearEdit:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            appearEdit:SetScript("OnEnterPressed", function(self)
                self:ClearFocus()
            end)

            local btnAppearGo = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
            btnAppearGo:SetSize(40, 22)
            btnAppearGo:SetText("Go")
            btnAppearGo:SetPoint("LEFT", appearEdit, "RIGHT", 10, 0)
            btnAppearGo:SetScript("OnClick", function()
                local playerName = appearEdit:GetText()
                if playerName and playerName ~= "" then
                    SendChatMessage(".appear " .. playerName, "SAY")
                else
                    print(L["enter_player_name_appear_error"])
                end
            end)
        else
           print(L["btn_mailbox_anchor_error"])
        end

        ------------------------------------------------------------------
        -- CREATION DU CHAMP "MORPH" ET SON BOUTON GO
        ------------------------------------------------------------------
        local anchor2 = buttonRefs["btnMailbox"]
        if anchor2 then
            local morphLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            morphLabel:SetPoint("TOPLEFT", anchor2, "BOTTOMLEFT", 180, -20)
            morphLabel:SetText(L["Morph Function"])

            local morphEdit = CreateFrame("EditBox", "TrinityAdminMorphEditBox", page, "InputBoxTemplate")
            morphEdit:SetAutoFocus(false)
            morphEdit:SetSize(120, 22)
            morphEdit:SetPoint("TOPLEFT", morphLabel, "BOTTOMLEFT", 0, -5)
            morphEdit:SetText(L["Display ID Morph"])
            morphEdit:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["display-id-tooltip"], 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            morphEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
            morphEdit:SetScript("OnEditFocusGained", function(self)
                if self:GetText() == L["Display ID Morph"] then
                    self:SetText("")
                end
            end)
            morphEdit:SetScript("OnEditFocusLost", function(self)
                if self:GetText() == "" then
                    self:SetText(L["Display ID Morph"])
                end
            end)
            morphEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

            local btnMorphGo = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
            btnMorphGo:SetSize(40, 22)
            btnMorphGo:SetText("Go")
            btnMorphGo:SetPoint("LEFT", morphEdit, "RIGHT", 10, 0)
            btnMorphGo:SetScript("OnClick", function()
                local displayId = morphEdit:GetText()
                if displayId and displayId ~= "" and displayId ~= L["Display ID Morph"] then
                    SendChatMessage(".morph " .. displayId, "SAY")
                else
                   print(L["enter_display_id_morph_error"])
                end
            end)
        else
            -- print("Erreur: impossible de trouver 'btnMailbox' pour ancrer le champ Morph.")
        end

        ------------------------------------------------------------------
        -- CREATION DU CHAMP "Custom Mute" et son bouton Go
        ------------------------------------------------------------------
        local anchorMute = buttonRefs["btnMailbox"]
        if anchorMute then
            local muteLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            muteLabel:SetPoint("TOPLEFT", anchorMute, "BOTTOMLEFT", 0, -80)
            muteLabel:SetText(L["Mute Function"])

            local muteDropdown = CreateFrame("Frame", "TrinityAdminMuteDropdown", page, "UIDropDownMenuTemplate")
            muteDropdown:SetPoint("TOPLEFT", muteLabel, "BOTTOMLEFT", 0, -5)
            UIDropDownMenu_SetWidth(muteDropdown, 110)
            UIDropDownMenu_SetButtonWidth(muteDropdown, 240)
            local muteOptions = {
                { text = "mute", command = ".mute", tooltip = L["MUTE_TOOLTIP"] },
                { text = "unmute", command = ".unmute", tooltip = L["UNMUTE_TOOLTIP"] },
                { text = "mutehistory", command = ".mutehistory", tooltip = L["MUTEhistory_TOOLTIP"] },
            }
            if not muteDropdown.selectedID then 
                muteDropdown.selectedID = 1 
            end

            UIDropDownMenu_Initialize(muteDropdown, function(dropdownFrame, level, menuList)
                local info = UIDropDownMenu_CreateInfo()
                for i, option in ipairs(muteOptions) do
                    info.text = option.text
                    info.value = option.command
                    info.checked = (i == muteDropdown.selectedID)
                    info.func = function(buttonFrame)
                        muteDropdown.selectedID = i
                        UIDropDownMenu_SetSelectedID(muteDropdown, i)
                        UIDropDownMenu_SetText(muteDropdown, option.text)
                        muteDropdown.selectedOption = option
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end)

            UIDropDownMenu_SetSelectedID(muteDropdown, muteDropdown.selectedID)
            UIDropDownMenu_SetText(muteDropdown, muteOptions[muteDropdown.selectedID].text)
            muteDropdown.selectedOption = muteOptions[muteDropdown.selectedID]

			------------------------------------------------------------------
			-- 2) Champ de saisie : Player Name
			------------------------------------------------------------------
			local nameEdit = CreateFrame("EditBox", "TrinityAdminMuteNameEditBox", page, "InputBoxTemplate")
			nameEdit:SetAutoFocus(false)
			nameEdit:SetSize(120, 22)
			nameEdit:SetPoint("TOPLEFT", muteLabel, "BOTTOMLEFT", 0, -35)
			nameEdit:SetMaxLetters(50)
			nameEdit:SetText("")  -- par défaut vide
			nameEdit:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(L["TOOLTIP_INFO_MUTE_PLAYER"], 1, 1, 1, 1, true)
				GameTooltip:Show()
			end)
			nameEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
			nameEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
		
			------------------------------------------------------------------
			-- 3) Champ de saisie : Time (minutes)
			------------------------------------------------------------------
			local timeEdit = CreateFrame("EditBox", "TrinityAdminMuteTimeEditBox", page, "InputBoxTemplate")
			timeEdit:SetAutoFocus(false)
			timeEdit:SetSize(40, 22)
			timeEdit:SetPoint("LEFT", nameEdit, "RIGHT", 10, 0)
			timeEdit:SetMaxLetters(5)
			timeEdit:SetNumeric(true)  -- facultatif, pour restreindre aux nombres
			timeEdit:SetText("")  
			timeEdit:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(L["tooltip_howmanytime"], 1, 1, 1, 1, true)
				GameTooltip:Show()
			end)
			timeEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
			timeEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
		
			------------------------------------------------------------------
			-- 4) Champ de saisie : Reason
			------------------------------------------------------------------
			local reasonEdit = CreateFrame("EditBox", "TrinityAdminMuteReasonEditBox", page, "InputBoxTemplate")
			reasonEdit:SetAutoFocus(false)
			reasonEdit:SetSize(140, 22)
			reasonEdit:SetPoint("LEFT", timeEdit, "RIGHT", 10, 0)
			reasonEdit:SetMaxLetters(100)
			reasonEdit:SetText("")
			reasonEdit:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(L["Mute reason (required)"], 1, 1, 1, 1, true)
				GameTooltip:Show()
			end)
			reasonEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
			reasonEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
		
			------------------------------------------------------------------
			-- 5) Bouton "Go"
			------------------------------------------------------------------
			local btnMuteGo = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
			btnMuteGo:SetSize(40, 22)
			btnMuteGo:SetText("Go")
			btnMuteGo:SetPoint("LEFT", reasonEdit, "RIGHT", 10, 0)
		
			btnMuteGo:SetScript("OnClick", function()
				local option = muteDropdown.selectedOption  -- L'entrée du menu
				local cmd    = option.command
				local finalCommand = ""
		
				-- Récupération des valeurs saisies
				local inputPlayerName = nameEdit:GetText()
				local inputTime       = timeEdit:GetText()
				local inputReason     = reasonEdit:GetText()
		
				-- Si aucun nom n'est saisi et qu'on a une cible
				if (not inputPlayerName or inputPlayerName == "") then
					local targetName = UnitName("target")
					if targetName then
						inputPlayerName = targetName
					end
				end
		
		
				------------------------------------------------------------------
				-- Logique selon l'option sélectionnée
				------------------------------------------------------------------
				if option.text == "mute" then
					-- .mute PlayerName Time Reason
					if (not inputPlayerName or inputPlayerName == "") then
						print(L["Please enter a Player NAme or Select a Player"])
						return
					end
					if (not inputTime or inputTime == "") then
						print(L["Please, enter time in minuts."])
						return
					end
					if (not inputReason or inputReason == "") then
						print(L["Please enter a reason for the mute."])
						return
					end
		
					-- Concatène la commande
					finalCommand = cmd .. " " .. inputPlayerName .. " " .. inputTime .. " " .. inputReason
		
				elseif option.text == "unmute" then
					-- .unmute PlayerName
					if (not inputPlayerName or inputPlayerName == "") then
						print(L["Please enter a Player NAme or Select a Player"])
						return
					end
					finalCommand = cmd .. " " .. inputPlayerName
		
				elseif option.text == "mutehistory" then
					-- .mutehistory PlayerName
					if (not inputPlayerName or inputPlayerName == "") then
						print(L["Please enter a Player NAme or Select a Player"])
						return
					end
					finalCommand = cmd .. " " .. inputPlayerName
				end
		
				------------------------------------------------------------------
				-- Envoi de la commande
				------------------------------------------------------------------
				if finalCommand ~= "" then
					-- print("Commande envoyée : " .. finalCommand)
					SendChatMessage(finalCommand, "SAY")
				end
			end)
        else
            -- print("Erreur: impossible de trouver 'btnMailbox' pour ancrer le bloc Mute.")
        end
    end

        ----------------------------------------------------------------------------
        -- PAGE 2 : Fonctions de développement et annonces
        ----------------------------------------------------------------------------
        do
            local page = pages[2]
            local row

            -- Ligne 1 : Dev Status, boutons radio (ON/OFF) et bouton SET
            row = CreateRow(page, 30)
            local devStatusLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            devStatusLabel:SetPoint("LEFT", row, "LEFT", 0, -40)
            devStatusLabel:SetText(L["Dev Status"])

            local devStatusValue = "on"
			local radioOn, radioOff
			
			-- Puis on crée radioOn
			radioOn = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
			radioOn:SetPoint("LEFT", devStatusLabel, "RIGHT", 10, 0)
			radioOn.text:SetText("ON")
			radioOn:SetChecked(true)
			radioOn:SetScript("OnClick", function(self)
				-- Ici, radioOff existe déjà, même si on va la définir juste après
				radioOff:SetChecked(false)
				devStatusValue = "on"
			end)
			
			-- Enfin, on crée radioOff
			radioOff = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
			radioOff:SetPoint("LEFT", radioOn, "RIGHT", 20, 0)
			radioOff.text:SetText("OFF")
			radioOff:SetChecked(false)
			radioOff:SetScript("OnClick", function(self)
				radioOn:SetChecked(false)
				devStatusValue = "off"
			end)

            local btnDevSet = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnDevSet:SetSize(40, 22)
            btnDevSet:SetText("SET")
            btnDevSet:SetPoint("LEFT", radioOff, "RIGHT", 20, 0)
            btnDevSet:SetScript("OnClick", function()
                SendChatMessage(".dev " .. devStatusValue, "SAY")
            end)
            btnDevSet:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["devstatus_tooltip"], 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnDevSet:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Ligne 2 : Champ d'annonce globale .announce
            row = CreateRow(page, 30)
            local announceEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            announceEdit:SetSize(150, 22)
            announceEdit:SetPoint("LEFT", row, "LEFT", 0, -40)
            announceEdit:SetAutoFocus(false)
            announceEdit:SetText(L["Global_Message"])
            local btnAnnounce = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnAnnounce:SetSize(60, 22)
            btnAnnounce:SetText("Send")
            btnAnnounce:SetPoint("LEFT", announceEdit, "RIGHT", 10, 0)
            btnAnnounce:SetScript("OnClick", function()
                local text = announceEdit:GetText()
                if not text or text == "" or text == L["Global_Message"] then
                    print(L["Error : Please enter a message."])
                else
                    SendChatMessage('.announce "' .. text .. '"', "SAY")
                end
            end)
            btnAnnounce:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Global_Message_tooltip"], 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnAnnounce:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Ligne 3 : Champ GM Message pour .gmannounce
            row = CreateRow(page, 30)
            local gmMessageEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            gmMessageEdit:SetSize(150, 22)
            gmMessageEdit:SetPoint("LEFT", row, "LEFT", 0, -40)
            gmMessageEdit:SetAutoFocus(false)
            gmMessageEdit:SetText(L["GM Message 2"])
            local btnGmMessage = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnGmMessage:SetSize(60, 22)
            btnGmMessage:SetText("Send")
            btnGmMessage:SetPoint("LEFT", gmMessageEdit, "RIGHT", 10, 0)
            btnGmMessage:SetScript("OnClick", function()
                local text = gmMessageEdit:GetText()
                if not text or text == "" or text == L["GM Message 2"] then
                    print(L["Error : Please enter a message."])
                else
                    SendChatMessage('.gmannounce "' .. text .. '"', "SAY")
                end
            end)
            btnGmMessage:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["GM Message 2 tooltip"], 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnGmMessage:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Ligne 4 : Champ GM Notification pour .gmnotify
            row = CreateRow(page, 30)
            local gmNotifyEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            gmNotifyEdit:SetSize(150, 22)
            gmNotifyEdit:SetPoint("LEFT", row, "LEFT", 0, -40)
            gmNotifyEdit:SetAutoFocus(false)
            gmNotifyEdit:SetText(L["GM Notification"])
            local btnGmNotify = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnGmNotify:SetSize(60, 22)
            btnGmNotify:SetText("Send")
            btnGmNotify:SetPoint("LEFT", gmNotifyEdit, "RIGHT", 10, 0)
            btnGmNotify:SetScript("OnClick", function()
                local text = gmNotifyEdit:GetText()
                if not text or text == "" or text == L["GM Notification"] then
                    print(L["Error : Please enter a message."])
                else
                    SendChatMessage('.gmnotify "' .. text .. '"', "SAY")
                end
            end)
            btnGmNotify:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Syntax: .gmnotify $notification\r\nDisplays a notification on the screen of all online GM's."], 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnGmNotify:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Ligne 5 : Champ GM Announcement pour .nameannounce
            row = CreateRow(page, 30)
            local gmAnnounceEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            gmAnnounceEdit:SetSize(150, 22)
            gmAnnounceEdit:SetPoint("LEFT", row, "LEFT", 0, -40)
            gmAnnounceEdit:SetAutoFocus(false)
            gmAnnounceEdit:SetText(L["GM Announcement"])
            local btnGmAnnounce = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnGmAnnounce:SetSize(60, 22)
            btnGmAnnounce:SetText("Send")
            btnGmAnnounce:SetPoint("LEFT", gmAnnounceEdit, "RIGHT", 10, 0)
            btnGmAnnounce:SetScript("OnClick", function()
                local text = gmAnnounceEdit:GetText()
                if not text or text == "" or text == L["GM Announcement"] then
                    print(L["Error : Please enter a message for nameannounce."])
                else
                    SendChatMessage('.nameannounce "' .. text .. '"', "SAY")
                end
            end)
            btnGmAnnounce:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Syntax: .nameannounce $announcement.\nSend an announcement to all online players, displaying the name of the sender."], 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnGmAnnounce:SetScript("OnLeave", function() GameTooltip:Hide() end)
			
			
			-- Ligne 6 : Champ GM Announcement pour .notify
            row = CreateRow(page, 30)
            local gmNotifyEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            gmNotifyEdit:SetSize(150, 22)
            gmNotifyEdit:SetPoint("LEFT", row, "LEFT", 0, -40)
            gmNotifyEdit:SetAutoFocus(false)
            gmNotifyEdit:SetText(L["GM Notify"])
            local btnGmNotify = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnGmNotify:SetSize(60, 22)
            btnGmNotify:SetText("Send")
            btnGmNotify:SetPoint("LEFT", gmNotifyEdit, "RIGHT", 10, 0)
            btnGmNotify:SetScript("OnClick", function()
                local text = gmNotifyEdit:GetText()
                if not text or text == "" or text == L["GM Notify"] then
                    print(L["Error : Please enter a message to Notify."])
                else
                    SendChatMessage('.notify "' .. text .. '"', "SAY")
                end
            end)
            btnGmNotify:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["GM Notify Tooltip"] = "Send a global message to all players online in screen.")
                GameTooltip:Show()
            end)
            btnGmNotify:SetScript("OnLeave", function() GameTooltip:Hide() end)

		-----------------------------------------------------------------------------
		-- Ligne 6 : Dropdown Skill, champs Level et Max pour .setskill
		-----------------------------------------------------------------------------
		row = CreateRow(page, 30)
		
		-- Création d'un bouton d'affichage qui montrera le menu personnalisé
		local displayButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		displayButton:SetSize(220, 22)
		displayButton:SetPoint("LEFT", row, "LEFT", 0, -40)
		displayButton:SetText(L["Select Skill"])
		-- On stocke la sélection dans displayButton.selectedSkill
		
		-- Création du cadre du menu déroulant personnalisé (initialement caché)
		local customDropdown = CreateFrame("Frame", "SkillDropdownFrame", row)
		customDropdown:SetSize(220, 10 * 16)  -- 10 boutons de 16 pixels de haut chacun
		customDropdown:SetPoint("TOPLEFT", displayButton, "BOTTOMLEFT", 0, -5)
		customDropdown:Hide()
		
		-- Ajout d'une texture d'arrière-plan pour changer la couleur de fond
		local bg = customDropdown:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints(customDropdown)
		bg:SetColorTexture(0, 0, 0, 0.5)  -- Noir à 50% d'opacité (ajustez selon vos besoins)
		
		-- Création d'un faux scroll frame couvrant tout le cadre du menu
		local scrollFrame = CreateFrame("ScrollFrame", "SkillScrollFrame", customDropdown, "FauxScrollFrameTemplate")
		scrollFrame:SetAllPoints(customDropdown)
		
		-- Création de 10 boutons qui seront réutilisés pour afficher les entrées
		local numButtons = 10
		local buttons = {}
		for i = 1, numButtons do
			local btn = CreateFrame("Button", "SkillDropdownButton"..i, customDropdown)
			btn:SetSize(120, 16)
			if i == 1 then
				btn:SetPoint("TOPLEFT", customDropdown, "TOPLEFT", 35, 0)
			else
				btn:SetPoint("TOPLEFT", buttons[i-1], "BOTTOMLEFT", 0, 0)
			end
			btn:SetNormalFontObject("GameFontNormal")
			btn:SetHighlightFontObject("GameFontHighlight")
			btn:SetScript("OnClick", function(self)
				displayButton.selectedSkill = SkillsData[self.index]
				--displayButton:SetText(SkillsData[self.index].name)
				displayButton:SetText(L[SkillsData[self.index].name] or SkillsData[self.index].name)
				customDropdown:Hide()
			end)
			buttons[i] = btn
		end
		
		-- Fonction de mise à jour du menu déroulant en fonction du défilement
		local function UpdateDropdown()
			local offset = FauxScrollFrame_GetOffset(scrollFrame)
			for i = 1, numButtons do
				local index = i + offset
				if index <= #SkillsData then
					local skill = SkillsData[index]
					-- buttons[i]:SetText(skill.name)
					buttons[i]:SetText(L[skill.name] or skill.name)
					buttons[i].index = index
					buttons[i]:Show()
				else
					buttons[i]:Hide()
				end
			end
		end
		
		scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
			FauxScrollFrame_OnVerticalScroll(self, offset, 16, UpdateDropdown)
		end)
		
		-- Initialisation du scroll frame dès l'affichage du menu
		customDropdown:SetScript("OnShow", function(self)
			FauxScrollFrame_Update(scrollFrame, #SkillsData, numButtons, 16)
			UpdateDropdown()
		end)
		
		-- Affichage/Masquage du menu déroulant au clic sur le bouton d'affichage
		displayButton:SetScript("OnClick", function(self)
			if customDropdown:IsShown() then
				customDropdown:Hide()
			else
				customDropdown:Show()
			end
		end)
		
		-----------------------------------------------------------------------
		-- Les autres éléments restent inchangés
		-----------------------------------------------------------------------
		local levelEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
		levelEdit:SetSize(60, 22)
		levelEdit:SetPoint("LEFT", displayButton, "RIGHT", 20, 0)
		levelEdit:SetAutoFocus(false)
		levelEdit:SetText("Level")
		
		local maxEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
		maxEdit:SetSize(60, 22)
		maxEdit:SetPoint("LEFT", levelEdit, "RIGHT", 10, 0)
		maxEdit:SetAutoFocus(false)
		maxEdit:SetText("Max")
		
		local btnSetSkill = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		btnSetSkill:SetSize(60, 22)
		btnSetSkill:SetText("Set")
		btnSetSkill:SetPoint("LEFT", maxEdit, "RIGHT", 10, 0)
		btnSetSkill:SetScript("OnClick", function()
			local selectedSkill = displayButton.selectedSkill
			if not selectedSkill then
				print(L["Error : Please select a skill."])
				return
			end
			local level = levelEdit:GetText()
			if not level or level == "" or level == "Level" then
				print(L["Error : Please enter a value for Level."])
				return
			end
			local command = ".setskill " .. selectedSkill.entry .. " " .. level
			local max = maxEdit:GetText()
			if max and max ~= "" and max ~= "Max" then
				command = command .. " " .. max
			end
			SendChatMessage(command, "SAY")
		end)
		btnSetSkill:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(L["Syntax: .setskill #skill #level [#max]\r\n\r\nSet a skill of id #skill with a current skill value of #level and a maximum value of #max (or equal current maximum if not provided) for the selected character. If no character is selected, you learn the skill."], 1, 1, 1, 1, true)
			GameTooltip:Show()
		end)
		btnSetSkill:SetScript("OnLeave", function() GameTooltip:Hide() end)

			end

--------------------------------------------------------------------------
-- PAGE 3
--------------------------------------------------------------------------
	do
            local page = pages[3]
            local row
		
        -----------------------------------------------------------
        -- 1) Button "Distance"
        -----------------------------------------------------------
		row = CreateRow(page, 30)  -- create a row 30px high
        local btnDistance = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnDistance:SetSize(80, 22)
        btnDistance:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -40)
        btnDistance:SetText(L["Distance71"])

        -- Tooltip
        btnDistance:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Distance71_Tooltip"], 1,1,1,1,true)
        end)
        btnDistance:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- OnClick => .distance [targetName]
        btnDistance:SetScript("OnClick", function()
            local targetName = UnitName("target")
            if not targetName then
                print(L["distance_target_error"])
                return
            end
            local cmd = ".distance "
            SendChatMessage(cmd, "SAY")
			-- print("[DEBUG] Commande envoyée: " ..cmd)
        end)

        -----------------------------------------------------------
        -- 2) EditBox "Area ID" + Button "Hide Area"
        -----------------------------------------------------------
        local editAreaHide = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        editAreaHide:SetSize(60, 22)
        editAreaHide:SetPoint("LEFT", btnDistance, "RIGHT", 30, 0)
        editAreaHide:SetAutoFocus(false)
        editAreaHide:SetText(L["Area ID"])

        local btnHideArea = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnHideArea:SetSize(80, 22)
        btnHideArea:SetPoint("LEFT", editAreaHide, "RIGHT", 5, 0)
        btnHideArea:SetText(L["Hide Area"])

        btnHideArea:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Hide Area Tooltip"], 1,1,1,1,true)
        end)
        btnHideArea:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnHideArea:SetScript("OnClick", function()
            local val = editAreaHide:GetText()
            if not val or val == "" or val == L["Area ID"] then
                print(L["enter_area_id_hidearea_error"])
                return
            end
            local cmd = ".hidearea " .. val
            -- We do NOT actually add the target's name to the command,
            -- so if there's a target, it applies to them; if no target, applies to you.
            SendChatMessage(cmd, "SAY")
			-- print("[DEBUG] Commande envoyée: " ..cmd)
        end)

        -----------------------------------------------------------
        -- 3) EditBox "Area ID" + Button "Show Area"
        -----------------------------------------------------------
        local editAreaShow = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        editAreaShow:SetSize(60, 22)
        editAreaShow:SetPoint("LEFT", btnHideArea, "RIGHT", 10, 0)
        editAreaShow:SetAutoFocus(false)
        editAreaShow:SetText("Area ID")

        local btnShowArea = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnShowArea:SetSize(80, 22)
        btnShowArea:SetPoint("LEFT", editAreaShow, "RIGHT", 5, 0)
        btnShowArea:SetText(L["Show Area"])

        btnShowArea:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Show Area tooltip"], 1,1,1,1,true)
        end)
        btnShowArea:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnShowArea:SetScript("OnClick", function()
            local val = editAreaShow:GetText()
            if not val or val == "" or val == (L["Area ID"] then
                -- print("Erreur: veuillez saisir un Area ID pour .showarea.")
                return
            end
            local cmd = ".showarea " .. val
            SendChatMessage(cmd, "SAY")
			print("[DEBUG] Commande envoyée: " ..cmd)
        end)

    ---------------------------------------------------------------
    -- LINE 2
    --  - EditBox "Player Name" + Button "Summon"
    --  - EditBox "Player Name" + Button "Recall"
    ---------------------------------------------------------------
        row = CreateRow(page, 30)

        -----------------------------------------------------------
        -- 1) Summon
        -----------------------------------------------------------
        local editSummon = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        editSummon:SetSize(100, 22)
        editSummon:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -40)
        editSummon:SetAutoFocus(false)
        editSummon:SetText(L["Player Name"])

        local btnSummon = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnSummon:SetSize(80, 22)
        btnSummon:SetPoint("LEFT", editSummon, "RIGHT", 5, 0)
        btnSummon:SetText(L["SummonP"])

        btnSummon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["SummonP_tooltip"], 1,1,1,1,true)
        end)
        btnSummon:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnSummon:SetScript("OnClick", function()
            local val = editSummon:GetText()
            if not val or val == "" or val == L["Player Name"] then
               print(L["enter_player_name_summon_error"])
                return
            end
            local cmd = ".summon " .. val
            SendChatMessage(cmd, "SAY")
			-- print("[DEBUG] Commande envoyée: " ..cmd)
        end)

        -----------------------------------------------------------
        -- 2) Recall
        -----------------------------------------------------------
        local editRecall = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        editRecall:SetSize(100, 22)
        editRecall:SetPoint("LEFT", btnSummon, "RIGHT", 20, 0)
        editRecall:SetAutoFocus(false)
        editRecall:SetText(L["Player Name"])

        local btnRecall = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnRecall:SetSize(80, 22)
        btnRecall:SetPoint("LEFT", editRecall, "RIGHT", 5, 0)
        btnRecall:SetText(L["RecallP"])

        btnRecall:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["RecallP_tooltip"], 1,1,1,1,true)
        end)
        btnRecall:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnRecall:SetScript("OnClick", function()
            local val = editRecall:GetText()
            if not val or val == "" or val == L["Player Name"] then
                -- If empty => use target
                local targetName = UnitName("target")
                if not targetName then
                   print(L["enter_name_or_target_recall_error"])
                    return
                end
                local cmd = ".recall " .. targetName
                SendChatMessage(cmd, "SAY")
            else
                -- Use the typed name
                local cmd = ".recall " .. val
                SendChatMessage(cmd, "SAY")
				-- print("[DEBUG] Commande envoyée: " ..cmd)
            end
        end)

    ---------------------------------------------------------------
    -- LINE 3
    --  - Button "Bindsight"
    --  - Button "Unbindsight"
    --  - Button "Honor Update"
    ---------------------------------------------------------------
        row = CreateRow(page, 30)

        -- 1) Bindsight
        local btnBindsight = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnBindsight:SetSize(80, 22)
        btnBindsight:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -40)
        btnBindsight:SetText(L["Bindsight"])

        btnBindsight:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Bindsight_tooltip"], 1,1,1,1,true)
        end)
        btnBindsight:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnBindsight:SetScript("OnClick", function()
            local targetName = UnitName("target")
            if not targetName then
                print(L["target_required_bindsight_error"])
                return
            end
            local cmd = ".bindsight"
            SendChatMessage(cmd, "SAY")
			-- print("[DEBUG] Commande envoyée: " ..cmd)
        end)

        -- 2) Unbindsight
        local btnUnbindsight = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnUnbindsight:SetSize(100, 22)
        btnUnbindsight:SetPoint("LEFT", btnBindsight, "RIGHT", 20, 0)
        btnUnbindsight:SetText(L["Unbindsight"])

        btnUnbindsight:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Unbindsight_tooltip"], 1,1,1,1,true)
        end)
        btnUnbindsight:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnUnbindsight:SetScript("OnClick", function()
            local targetName = UnitName("target")
            if not targetName then
                print(L["target_required_unbindsight_error"])
                return
            end
            local cmd = ".unbindsight"
            SendChatMessage(cmd, "SAY")
			-- print("[DEBUG] Commande envoyée: " ..cmd)
        end)

        -- 3) Honor Update
        local btnHonorUpdate = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnHonorUpdate:SetSize(100, 22)
        btnHonorUpdate:SetPoint("LEFT", btnUnbindsight, "RIGHT", 20, 0)
        btnHonorUpdate:SetText(L["Honor Update"])

        btnHonorUpdate:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Honor_Update_tooltip"], 1,1,1,1,true)
        end)
        btnHonorUpdate:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnHonorUpdate:SetScript("OnClick", function()
            local cmd = ".honor update"
            SendChatMessage(cmd, "SAY")
			-- print("[DEBUG] Commande envoyée: " ..cmd)
        end)

    ---------------------------------------------------------------
    -- LINE 4
    --  - EditBox "Channel"
    --  - RadioButton "On"
    --  - RadioButton "Off"
    --  - Button "Set Ownership"
    ---------------------------------------------------------------
        row = CreateRow(page, 30)

        -- EditBox "Channel"
        local editChannel = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        editChannel:SetSize(100, 22)
        editChannel:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -40)
        editChannel:SetAutoFocus(false)
        editChannel:SetText(L["Channel"])

        -- Radio "On"
        local radioOn = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        radioOn.text = radioOn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        radioOn.text:SetPoint("LEFT", radioOn, "RIGHT", 2, 1)
        radioOn.text:SetText("On")
        radioOn:SetPoint("LEFT", editChannel, "RIGHT", 10, 0)
        radioOn:SetChecked(false)

        -- Radio "Off"
        local radioOff = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        radioOff.text = radioOff:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        radioOff.text:SetPoint("LEFT", radioOff, "RIGHT", 2, 1)
        radioOff.text:SetText("Off")
        radioOff:SetPoint("LEFT", radioOn, "RIGHT", 40, 0)
        radioOff:SetChecked(false)

        -- Make them exclusive
        local function UncheckOther(this, other)
            this:SetChecked(true)
            other:SetChecked(false)
        end

        radioOn:SetScript("OnClick", function(self)
            if self:GetChecked() then
                UncheckOther(self, radioOff)
            else
                -- If user tries to uncheck On, we re-check it if Off is not selected
                if not radioOff:GetChecked() then
                    self:SetChecked(true)
                end
            end
        end)

        radioOff:SetScript("OnClick", function(self)
            if self:GetChecked() then
                UncheckOther(self, radioOn)
            else
                if not radioOn:GetChecked() then
                    self:SetChecked(true)
                end
            end
        end)

        -- Button "Set Ownership"
        local btnSetOwner = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnSetOwner:SetSize(120, 22)
        btnSetOwner:SetPoint("LEFT", radioOff, "RIGHT", 40, 0)
        btnSetOwner:SetText(L["Set Ownership"])

        btnSetOwner:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Channel_tooltip"], 1,1,1,1,true)
        end)
        btnSetOwner:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnSetOwner:SetScript("OnClick", function()
            local chanName = editChannel:GetText()
            if not chanName or chanName == "" or chanName == L["Channel"] then
                print(L["enter_channel_error"])
                return
            end

            -- Determine "on" or "off"
            local state = nil
            if radioOn:GetChecked() then
                state = "on"
            elseif radioOff:GetChecked() then
                state = "off"
            end

            if not state then
                print(L["check_on_off_error"])
                return
            end

            local cmd = ".channel set ownership " .. chanName .. " " .. state
            SendChatMessage(cmd, "SAY")
			-- print("[DEBUG] Commande envoyée: " ..cmd)
        end)

    ---------------------------------------------------------------
    -- LINE 5
    --  - Dropdown "Weather Type" => (Rain=1, Snow=2, Sand=3)
    --  - Dropdown "Status" => (Enable=1, Disable=2)
    --  - Button "Set Weather"
    ---------------------------------------------------------------
        row = CreateRow(page, 30)

        -- Weather Type
        local weatherTypes = {
            { text="Rain",  id=1 },
            { text="Snow",  id=2 },
            { text="Sand",  id=3 },
        }
        local weatherDropdown = CreateFrame("Frame", nil, row, "UIDropDownMenuTemplate")
        weatherDropdown:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -40)
        UIDropDownMenu_SetWidth(weatherDropdown, 100)
        UIDropDownMenu_SetText(weatherDropdown, "Weather Type")
        weatherDropdown.selected = nil

        UIDropDownMenu_Initialize(weatherDropdown, function(self, level, menuList)
            for i, wtype in ipairs(weatherTypes) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = wtype.text
                info.func = function()
                    weatherDropdown.selected = wtype
                    UIDropDownMenu_SetText(weatherDropdown, wtype.text)
                end
                info.checked = (weatherDropdown.selected and weatherDropdown.selected.id == wtype.id)
                UIDropDownMenu_AddButton(info, level)
            end
        end)

        -- Status
        local statuses = {
            { text="Enable",  id=1 },
            { text="Disable", id=0 },
        }
        local statusDropdown = CreateFrame("Frame", nil, row, "UIDropDownMenuTemplate")
        statusDropdown:SetPoint("LEFT", weatherDropdown, "RIGHT", 20, 0)
        UIDropDownMenu_SetWidth(statusDropdown, 100)
        UIDropDownMenu_SetText(statusDropdown, "Status")
        statusDropdown.selected = nil

        UIDropDownMenu_Initialize(statusDropdown, function(self, level, menuList)
            for i, st in ipairs(statuses) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = st.text
                info.func = function()
                    statusDropdown.selected = st
                    UIDropDownMenu_SetText(statusDropdown, st.text)
                end
                info.checked = (statusDropdown.selected and statusDropdown.selected.id == st.id)
                UIDropDownMenu_AddButton(info, level)
            end
        end)

        -- Button "Set Weather"
        local btnWeather = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnWeather:SetPoint("LEFT", statusDropdown, "RIGHT", 20, 0)
        btnWeather:SetSize(100, 22)
        btnWeather:SetText(L["Set Weather"])

        btnWeather:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Set_Weather_tooltip"], 1,1,1,1,true)
        end)
        btnWeather:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnWeather:SetScript("OnClick", function()
            if not weatherDropdown.selected then
                print(L["select_weather_type_error"])
                return
            end
            if not statusDropdown.selected then
                print(L["select_status_error"])
                return
            end

            local wID = weatherDropdown.selected.id
            local sID = statusDropdown.selected.id

            -- For "Enable" we presumably use 1, for "Disable" => 0 or 2?
            -- The spec said "Desable" means 2, so we interpret 2 => 0? 
            -- The user said "Desable => 2"? The example is "enable => 1, disable => 2".
            -- But wchange syntax says #status can be 0 or 1. 
            -- So let's interpret "Disable => 0" if you want to follow the normal .wchange logic:
            -- but let's just do the user wants 1 or 2. We'll do .wchange wID sID.
            -- The user specifically said "for example for snow we do .wchange 2 1" => that means "2 => snow, 1 => enable"
            -- so we'll just pass them directly:
            local cmd = ".wchange " .. wID .. " " .. sID
            SendChatMessage(cmd, "SAY")
			-- print("[DEBUG] Commande envoyée: " ..cmd)
        end)

    ---------------------------------------------------------------
    -- LINE 6
    --  - 2 checkboxes "Alliance" / "Horde"
    --  - Button "Show Grave"
    ---------------------------------------------------------------

        row = CreateRow(page, 30)

        local chkAlliance = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        chkAlliance:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -40)
        chkAlliance.text = chkAlliance:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chkAlliance.text:SetPoint("LEFT", chkAlliance, "RIGHT", 2, 0)
        chkAlliance.text:SetText("Alliance")

        local chkHorde = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        chkHorde:SetPoint("LEFT", chkAlliance, "RIGHT", 60, 0)
        chkHorde.text = chkHorde:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chkHorde.text:SetPoint("LEFT", chkHorde, "RIGHT", 2, 0)
        chkHorde.text:SetText("Horde")

        -- We do not want both selected => handle OnClick
        local function UncheckOther(this, other)
            if this:GetChecked() then
                other:SetChecked(false)
            end
        end

        chkAlliance:SetScript("OnClick", function(self)
            if self:GetChecked() then
                UncheckOther(self, chkHorde)
            end
        end)

        chkHorde:SetScript("OnClick", function(self)
            if self:GetChecked() then
                UncheckOther(self, chkAlliance)
            end
        end)

        local btnShowGrave = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnShowGrave:SetSize(100, 22)
        btnShowGrave:SetPoint("LEFT", chkHorde, "RIGHT", 60, 0)
        btnShowGrave:SetText(L["Show Grave"])

        btnShowGrave:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Show_Grave_tooltip"], 1,1,1,1,true)
        end)
        btnShowGrave:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnShowGrave:SetScript("OnClick", function()
            local allianceChecked = chkAlliance:GetChecked()
            local hordeChecked    = chkHorde:GetChecked()

            if allianceChecked then
                SendChatMessage(".neargrave alliance", "SAY")
            elseif hordeChecked then
                SendChatMessage(".neargrave horde", "SAY")
            else
                -- If neither checked, send ".neargrave"
                SendChatMessage(".neargrave", "SAY")
            end
        end)

	---------------------------------------------------------------
	-- LINE 7: Link Grave Section
	---------------------------------------------------------------
	row = CreateRow(page, 30)
	
	-- Champ de saisie "Grave ID"
	local editGraveID = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
	editGraveID:SetSize(60, 22)
	editGraveID:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -40)
	editGraveID:SetAutoFocus(false)
	editGraveID:SetText("Grave ID")
	
	-- Case à cocher "Horde"
	local chkGraveHorde = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
	chkGraveHorde:SetPoint("LEFT", editGraveID, "RIGHT", 10, 0)
	chkGraveHorde.text = chkGraveHorde:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	chkGraveHorde.text:SetPoint("LEFT", chkGraveHorde, "RIGHT", 2, 0)
	chkGraveHorde.text:SetText("Horde")
	chkGraveHorde:SetChecked(false)
	
	-- Case à cocher "Alliance"
	local chkGraveAlliance = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
	chkGraveAlliance:SetPoint("LEFT", chkGraveHorde, "RIGHT", 60, 0)
	chkGraveAlliance.text = chkGraveAlliance:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	chkGraveAlliance.text:SetPoint("LEFT", chkGraveAlliance, "RIGHT", 2, 0)
	chkGraveAlliance.text:SetText("Alliance")
	chkGraveAlliance:SetChecked(false)
	
	-- Rendre les cases mutuellement exclusives
	chkGraveHorde:SetScript("OnClick", function(self)
		if self:GetChecked() then
			chkGraveAlliance:SetChecked(false)
		end
	end)
	chkGraveAlliance:SetScript("OnClick", function(self)
		if self:GetChecked() then
			chkGraveHorde:SetChecked(false)
		end
	end)
	
	-- Bouton "Link Grave"
	local btnLinkGrave = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
	btnLinkGrave:SetSize(100, 22)
	btnLinkGrave:SetPoint("LEFT", chkGraveAlliance, "RIGHT", 60, 0)
	btnLinkGrave:SetText(L["Link Grave"])
	btnLinkGrave:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Link_Grave_tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLinkGrave:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLinkGrave:SetScript("OnClick", function()
		local graveID = editGraveID:GetText()
		if graveID == "" or graveID == "Grave ID" then
			print(L["enter_grave_id_linkgrave_error"])
			return
		end
		if chkGraveHorde:GetChecked() then
			local cmd = ".linkgrave " .. graveID .. " horde"
			SendChatMessage(cmd, "SAY")
			-- print("[DEBUG] Commande envoyée: " .. cmd)
		elseif chkGraveAlliance:GetChecked() then
			local cmd = ".linkgrave " .. graveID .. " alliance"
			SendChatMessage(cmd, "SAY")
			-- print("[DEBUG] Commande envoyée: " .. cmd)
		else
			print(L["select_faction_linkgrave_error"])
		end
	end)

end

    ----------------------------------------------------------------------------
    -- Bouton Back commun (hors pagination)
    ----------------------------------------------------------------------------
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(L["Back"] or "Back")
    btnBack:SetSize(btnBack:GetTextWidth() + 20, 22)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    ShowPage(1)
    self.panel = panel
end
