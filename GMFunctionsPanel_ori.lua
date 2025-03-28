local module = TrinityAdmin:GetModule("GMFunctionsPanel")

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

-------------------------------------------------------------
-- 1. Déclaration des variables pour la capture GPS
-------------------------------------------------------------
local capturingGPSInfo = false
local gpsInfoCollected = {}
local gpsInfoTimer = nil
-- Déclaration forward de la fonction
local FinishGPSInfoCapture

-------------------------------------------------------------
-- Création de la popup GPS avec les champs de saisie
-------------------------------------------------------------
local GPSInfoPopup, editMap, editZone, editArea, editX, editY, editZ, editO, editGrid, editCell, editInstanceID
do 
    GPSInfoPopup = CreateFrame("Frame", "GPSInfoPopup", UIParent, "BackdropTemplate")
    GPSInfoPopup:SetSize(400, 300)
    GPSInfoPopup:SetPoint("CENTER")
    GPSInfoPopup:SetMovable(true)
    GPSInfoPopup:EnableMouse(true)
    GPSInfoPopup:RegisterForDrag("LeftButton")
    GPSInfoPopup:SetScript("OnDragStart", GPSInfoPopup.StartMoving)
    GPSInfoPopup:SetScript("OnDragStop", GPSInfoPopup.StopMovingOrSizing)
    GPSInfoPopup:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    GPSInfoPopup:Hide()
    
	    -- Ajout d'un bouton Close dans la popup GPS
	local closeGPSButton = CreateFrame("Button", nil, GPSInfoPopup, "UIPanelCloseButton")
	closeGPSButton:SetPoint("TOPRIGHT", GPSInfoPopup, "TOPRIGHT", -5, -5)

    local gpsTitle = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    gpsTitle:SetPoint("TOP", GPSInfoPopup, "TOP", 0, -15)
    gpsTitle:SetText("GPS Info")
    
    local labelMap = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelMap:SetPoint("TOPLEFT", 20, -40)
    labelMap:SetText("Map:")
    editMap = CreateFrame("EditBox", nil, GPSInfoPopup, "InputBoxTemplate")
    editMap:SetPoint("LEFT", labelMap, "RIGHT", 10, 0)
    editMap:SetSize(100, 20)
    
    local labelZone = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelZone:SetPoint("TOPLEFT", labelMap, "BOTTOMLEFT", 0, -10)
    labelZone:SetText("Zone:")
    editZone = CreateFrame("EditBox", nil, GPSInfoPopup, "InputBoxTemplate")
    editZone:SetPoint("LEFT", labelZone, "RIGHT", 10, 0)
    editZone:SetSize(100, 20)
    
    local labelArea = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelArea:SetPoint("TOPLEFT", labelZone, "BOTTOMLEFT", 0, -10)
    labelArea:SetText("Area:")
    editArea = CreateFrame("EditBox", nil, GPSInfoPopup, "InputBoxTemplate")
    editArea:SetPoint("LEFT", labelArea, "RIGHT", 10, 0)
    editArea:SetSize(100, 20)
    
    local labelX = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelX:SetPoint("TOPLEFT", labelArea, "BOTTOMLEFT", 0, -20)
    labelX:SetText("X:")
    editX = CreateFrame("EditBox", nil, GPSInfoPopup, "InputBoxTemplate")
    editX:SetPoint("LEFT", labelX, "RIGHT", 10, 0)
    editX:SetSize(50, 20)
    
    local labelY = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelY:SetPoint("TOPLEFT", labelX, "BOTTOMLEFT", 0, -10)
    labelY:SetText("Y:")
    editY = CreateFrame("EditBox", nil, GPSInfoPopup, "InputBoxTemplate")
    editY:SetPoint("LEFT", labelY, "RIGHT", 10, 0)
    editY:SetSize(50, 20)
    
    local labelZ = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelZ:SetPoint("TOPLEFT", labelY, "BOTTOMLEFT", 0, -10)
    labelZ:SetText("Z:")
    editZ = CreateFrame("EditBox", nil, GPSInfoPopup, "InputBoxTemplate")
    editZ:SetPoint("LEFT", labelZ, "RIGHT", 10, 0)
    editZ:SetSize(50, 20)
    
    local labelO = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelO:SetPoint("TOPLEFT", labelZ, "BOTTOMLEFT", 0, -10)
    labelO:SetText("O:")
    editO = CreateFrame("EditBox", nil, GPSInfoPopup, "InputBoxTemplate")
    editO:SetPoint("LEFT", labelO, "RIGHT", 10, 0)
    editO:SetSize(50, 20)
    
    local labelGrid = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelGrid:SetPoint("TOPLEFT", labelO, "BOTTOMLEFT", 0, -20)
    labelGrid:SetText("Grid:")
    editGrid = CreateFrame("EditBox", nil, GPSInfoPopup, "InputBoxTemplate")
    editGrid:SetPoint("LEFT", labelGrid, "RIGHT", 10, 0)
    editGrid:SetSize(50, 20)
    
    local labelCell = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelCell:SetPoint("TOPLEFT", labelGrid, "BOTTOMLEFT", 0, -10)
    labelCell:SetText("Cell:")
    editCell = CreateFrame("EditBox", nil, GPSInfoPopup, "InputBoxTemplate")
    editCell:SetPoint("LEFT", labelCell, "RIGHT", 10, 0)
    editCell:SetSize(50, 20)
    
    local labelInstanceID = GPSInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelInstanceID:SetPoint("TOPLEFT", labelCell, "BOTTOMLEFT", 0, -10)
    labelInstanceID:SetText("InstanceID:")
    editInstanceID = CreateFrame("EditBox", nil, GPSInfoPopup, "InputBoxTemplate")
    editInstanceID:SetPoint("LEFT", labelInstanceID, "RIGHT", 10, 0)
    editInstanceID:SetSize(50, 20)
end

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
    capturingGPSInfo = false
    if #gpsInfoCollected > 0 then
        local fullText = table.concat(gpsInfoCollected, "\n")
        -- Capture pour Map, Zone et Area : numéro + texte entre parenthèses
        local mapNum, mapName = fullText:match("Map:%s*(%S+)%s*%(([^)]+)%)")
        local zoneNum, zoneName = fullText:match("Zone:%s*(%S+)%s*%(([^)]+)%)")
        local areaNum, areaName = fullText:match("Area:%s*(%S+)%s*%(([^)]+)%)")
        
        -- Autres captures
        local x = fullText:match("X:%s*(%S+)")
        local y = fullText:match("Y:%s*(%S+)")
        local z = fullText:match("Z:%s*(%S+)")
        local o = fullText:match("Orientation:%s*(%S+)")
        local grid = fullText:match("grid%s*(%S+)%s*cell")
        local cell = fullText:match("cell%s*(%S+)%s*InstanceID")
        local instanceid = fullText:match("InstanceID:%s*(%S+)")
        
        -- Combinaison : affiche le numéro suivi du texte entre parenthèses s'il existe
        local mapText = mapNum and (mapNum .. (mapName and " (" .. mapName .. ")" or "")) or ""
        local zoneText = zoneNum and (zoneNum .. (zoneName and " (" .. zoneName .. ")" or "")) or ""
        local areaText = areaNum and (areaNum .. (areaName and " (" .. areaName .. ")" or "")) or ""
        
        editMap:SetText(mapText)
        editZone:SetText(zoneText)
        editArea:SetText(areaText)
        editX:SetText(x or "")
        editY:SetText(y or "")
        editZ:SetText(z or "")
        editO:SetText(o or "")
        editGrid:SetText(grid or "")
        editCell:SetText(cell or "")
        editInstanceID:SetText(instanceid or "")
        
        GPSInfoPopup:Show()
    else
        print("Aucune information GPS capturée.")
    end
end
------------------------------------------------------------------
-- Table listant tous les boutons (sans le bouton Appear).
------------------------------------------------------------------
local buttonDefs = {
    {
        name = "btnFly",
        textON = "GM Fly ON",  
        textOFF = "GM Fly OFF",
        tooltip = "Active ou désactive la possibilité de voler en GM",
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
        tooltip = "Active ou désactive le mode GM",
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
        tooltip = "Active ou désactive le chat GM",
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
        tooltip = "Active le mode GM ingame (sans toggle).",
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
        tooltip = "Affiche la liste des GMs en jeu.",
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
        tooltip = "Active ou désactive la visibilité GM.",
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
        tooltip = "Ressuscite le personnage.",
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
        tooltip = "Fait mourir instantanément le personnage.",
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
        tooltip = "Sauvegarde votre personnage.",
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
        tooltip = "Sauvegarde tous les personnages.",
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
        tooltip = "Respawn toutes les créatures mortes autour.",
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
        tooltip = "Demorph the selected player.",
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
        tooltip = "Enable/disable accepting whispers by GM from players.",
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
        tooltip = "Show your mailbox content.",
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
        tooltip = "Show your bank inventory.",
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
        tooltip = "Make selected creature come to your current location (new position not saved to DB).",
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
        tooltip = "Display the GUID for the selected character.",
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
        tooltip = "Dismount you, if you are mounted.",
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
        tooltip = "Possesses indefinitely the selected creature.",
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
		tooltip = "Capture GPS info from chat and display it",
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
            print("Commande envoyée :" .. def.command)
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
    panel.title:SetText(TrinityAdmin_Translations["GM Functions Panel"] or "GM Functions Panel")

    ----------------------------------------------------------------------------
    -- Création du conteneur de contenu pour la pagination
    ----------------------------------------------------------------------------
    local contentContainer = CreateFrame("Frame", nil, panel)
    contentContainer:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, 30)
    contentContainer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 40)

    local totalPages = 2
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
    btnPrev:SetText("Précédent")
    btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            ShowPage(currentPage)
        end
    end)

    btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnNext:SetSize(80, 22)
    btnNext:SetText("Suivant")
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

        -- Personnalisation du bouton "GPS"
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
            appearLabel:SetText("Appear Function")

            local appearEdit = CreateFrame("EditBox", "TrinityAdminAppearEditBox", page, "InputBoxTemplate")
            appearEdit:SetAutoFocus(false)
            appearEdit:SetSize(120, 22)
            appearEdit:SetPoint("TOPLEFT", appearLabel, "BOTTOMLEFT", 0, -5)
            appearEdit:SetText("Character Name")
            appearEdit:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(TrinityAdmin_Translations["Tele_to_Player"], 1, 1, 1, 1, true)
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
                    print("Veuillez saisir le nom du joueur pour .appear.")
                end
            end)
        else
            print("Erreur: impossible de trouver 'btnMailbox' pour ancrer le champ Appear.")
        end

        ------------------------------------------------------------------
        -- CREATION DU CHAMP "MORPH" ET SON BOUTON GO
        ------------------------------------------------------------------
        local anchor2 = buttonRefs["btnMailbox"]
        if anchor2 then
            local morphLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            morphLabel:SetPoint("TOPLEFT", anchor2, "BOTTOMLEFT", 180, -20)
            morphLabel:SetText("Morph Function")

            local morphEdit = CreateFrame("EditBox", "TrinityAdminMorphEditBox", page, "InputBoxTemplate")
            morphEdit:SetAutoFocus(false)
            morphEdit:SetSize(120, 22)
            morphEdit:SetPoint("TOPLEFT", morphLabel, "BOTTOMLEFT", 0, -5)
            morphEdit:SetText("Display ID")
            morphEdit:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Change your current model id to #displayid.", 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            morphEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
            morphEdit:SetScript("OnEditFocusGained", function(self)
                if self:GetText() == "Display ID" then
                    self:SetText("")
                end
            end)
            morphEdit:SetScript("OnEditFocusLost", function(self)
                if self:GetText() == "" then
                    self:SetText("Display ID")
                end
            end)
            morphEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

            local btnMorphGo = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
            btnMorphGo:SetSize(40, 22)
            btnMorphGo:SetText("Go")
            btnMorphGo:SetPoint("LEFT", morphEdit, "RIGHT", 10, 0)
            btnMorphGo:SetScript("OnClick", function()
                local displayId = morphEdit:GetText()
                if displayId and displayId ~= "" and displayId ~= "Display ID" then
                    SendChatMessage(".morph " .. displayId, "SAY")
                else
                    print("Veuillez saisir un Display ID pour .morph.")
                end
            end)
        else
            print("Erreur: impossible de trouver 'btnMailbox' pour ancrer le champ Morph.")
        end

        ------------------------------------------------------------------
        -- CREATION DU CHAMP "Custom Mute" et son bouton Go
        ------------------------------------------------------------------
    --     local anchorMute = buttonRefs["btnMailbox"]
    --     if anchorMute then
    --         local muteLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    --         muteLabel:SetPoint("TOPLEFT", anchorMute, "BOTTOMLEFT", 0, -80)
    --         muteLabel:SetText("Mute Function")
	-- 
    --         local muteDropdown = CreateFrame("Frame", "TrinityAdminMuteDropdown", page, "UIDropDownMenuTemplate")
    --         muteDropdown:SetPoint("TOPLEFT", muteLabel, "BOTTOMLEFT", 0, -5)
    --         UIDropDownMenu_SetWidth(muteDropdown, 110)
    --         UIDropDownMenu_SetButtonWidth(muteDropdown, 240)
    --         local muteOptions = {
    --             { text = "mute", command = ".mute", tooltip = "Syntax : PlayerName TimeInMinutes Reason" },
    --             { text = "unmute", command = ".unmute", tooltip = "" },
    --             { text = "mutehistory", command = ".mutehistory", tooltip = "" },
    --         }
    --         if not muteDropdown.selectedID then 
    --             muteDropdown.selectedID = 1 
    --         end
	-- 
    --         UIDropDownMenu_Initialize(muteDropdown, function(dropdownFrame, level, menuList)
    --             local info = UIDropDownMenu_CreateInfo()
    --             for i, option in ipairs(muteOptions) do
    --                 info.text = option.text
    --                 info.value = option.command
    --                 info.checked = (i == muteDropdown.selectedID)
    --                 info.func = function(buttonFrame)
    --                     muteDropdown.selectedID = i
    --                     UIDropDownMenu_SetSelectedID(muteDropdown, i)
    --                     UIDropDownMenu_SetText(muteDropdown, option.text)
    --                     muteDropdown.selectedOption = option
    --                 end
    --                 UIDropDownMenu_AddButton(info, level)
    --             end
    --         end)
	-- 
    --         UIDropDownMenu_SetSelectedID(muteDropdown, muteDropdown.selectedID)
    --         UIDropDownMenu_SetText(muteDropdown, muteOptions[muteDropdown.selectedID].text)
    --         muteDropdown.selectedOption = muteOptions[muteDropdown.selectedID]
	-- 
    --         local muteEdit = CreateFrame("EditBox", "TrinityAdminMuteEditBox", page, "InputBoxTemplate")
    --         muteEdit:SetAutoFocus(false)
    --         muteEdit:SetSize(180, 22)
    --         muteEdit:SetPoint("TOPLEFT", muteLabel, "BOTTOMLEFT", 0, -35)
    --         muteEdit:SetScript("OnEnter", function(self)
    --             GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    --             if muteDropdown.selectedOption.text == "mute" then
    --                 GameTooltip:SetText("Syntax : PlayerName TimeInMinutes Reason", 1, 1, 1, 1, true)
    --             else
    --                 GameTooltip:SetText("", 1, 1, 1, 1, true)
    --             end
    --             GameTooltip:Show()
    --         end)
    --         muteEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
    --         muteEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	-- 
    --         local btnMuteGo = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    --         btnMuteGo:SetSize(40, 22)
    --         btnMuteGo:SetText("Go")
    --         btnMuteGo:SetPoint("LEFT", muteEdit, "RIGHT", 10, 0)
    --         btnMuteGo:SetScript("OnClick", function()
    --             local inputText = muteEdit:GetText()
    --             local option = muteDropdown.selectedOption
    --             local cmd = option.command
    --             local finalCommand = ""
    --             if option.text == "mute" then
    --                 local targetName = UnitName("target")
    --                 if targetName then
    --                     local time, reason = string.match(inputText, "^(%S+)%s+(.+)$")
    --                     if not time or not reason then
    --                         print("Veuillez saisir le temps (minutes) et la raison, séparés par un espace.")
    --                         return
    --                     else
    --                         finalCommand = cmd .. " " .. targetName .. " " .. time .. " " .. reason
    --                     end
    --                 else
    --                     if not inputText or inputText == "" then
    --                         print("Veuillez saisir le nom du joueur, le temps et la raison pour .mute.")
    --                         return
    --                     else
    --                         finalCommand = cmd .. " " .. inputText
    --                     end
    --                 end
    --             else
    --                 if not inputText or inputText == "" then
    --                     local targetName = UnitName("target")
    --                     if targetName then
    --                         finalCommand = cmd .. " " .. targetName
    --                     else
    --                         print("Veuillez saisir un nom ou cibler un joueur.")
    --                         return
    --                     end
    --                 else
    --                     finalCommand = cmd .. " " .. inputText
    --                 end
    --             end
    --             SendChatMessage(finalCommand, "SAY")
    --         end)
    --     else
    --         print("Erreur: impossible de trouver 'btnMailbox' pour ancrer le bloc Mute.")
    --     end
    -- end
		
		------------------------------------------------------------------
        -- CREATION DU CHAMP "Custom Mute" et son bouton Go
        ------------------------------------------------------------------
        local anchorMute = buttonRefs["btnMailbox"]
        if anchorMute then
            local muteLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            muteLabel:SetPoint("TOPLEFT", anchorMute, "BOTTOMLEFT", 0, -80)
            muteLabel:SetText("Mute Function")

            local muteDropdown = CreateFrame("Frame", "TrinityAdminMuteDropdown", page, "UIDropDownMenuTemplate")
            muteDropdown:SetPoint("TOPLEFT", muteLabel, "BOTTOMLEFT", 0, -5)
            UIDropDownMenu_SetWidth(muteDropdown, 110)
            UIDropDownMenu_SetButtonWidth(muteDropdown, 240)
            local muteOptions = {
                { text = "mute", command = ".mute", tooltip = "Syntax : PlayerName TimeInMinutes Reason" },
                { text = "unmute", command = ".unmute", tooltip = "" },
                { text = "mutehistory", command = ".mutehistory", tooltip = "" },
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
				GameTooltip:SetText("Player Name (facultatif si vous avez ciblé un joueur)", 1, 1, 1, 1, true)
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
				GameTooltip:SetText("Durée du mute (en minutes)", 1, 1, 1, 1, true)
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
				GameTooltip:SetText(TrinityAdmin_Translations["Mute reason (required)"], 1, 1, 1, 1, true)
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
						print(TrinityAdmin_Translations["Please enter a Player NAme or Select a Player"])
						return
					end
					if (not inputTime or inputTime == "") then
						print(TrinityAdmin_Translations["Please, enter time in minuts."])
						return
					end
					if (not inputReason or inputReason == "") then
						print(TrinityAdmin_Translations["Please enter a reason for the mute."])
						return
					end
		
					-- Concatène la commande
					finalCommand = cmd .. " " .. inputPlayerName .. " " .. inputTime .. " " .. inputReason
		
				elseif option.text == "unmute" then
					-- .unmute PlayerName
					if (not inputPlayerName or inputPlayerName == "") then
						print(TrinityAdmin_Translations["Please enter a Player NAme or Select a Player"])
						return
					end
					finalCommand = cmd .. " " .. inputPlayerName
		
				elseif option.text == "mutehistory" then
					-- .mutehistory PlayerName
					if (not inputPlayerName or inputPlayerName == "") then
						print(TrinityAdmin_Translations["Please enter a Player NAme or Select a Player"])
						return
					end
					finalCommand = cmd .. " " .. inputPlayerName
				end
		
				------------------------------------------------------------------
				-- Envoi de la commande
				------------------------------------------------------------------
				if finalCommand ~= "" then
					print("Commande envoyée : " .. finalCommand)
					SendChatMessage(finalCommand, "SAY")
				end
			end)
        else
            print("Erreur: impossible de trouver 'btnMailbox' pour ancrer le bloc Mute.")
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
            devStatusLabel:SetText("Dev Status")

            -- Valeur par défaut
            local devStatusValue = "on"

            local radioOn = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
            radioOn:SetPoint("LEFT", devStatusLabel, "RIGHT", 10, 0)
            radioOn.text:SetText("ON")
            radioOn:SetChecked(true)
            radioOn:SetScript("OnClick", function(self)
                radioOff:SetChecked(false)
                devStatusValue = "on"
            end)

            local radioOff = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
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
                GameTooltip:SetText("Syntax: .dev [on/off]\r\n\r\nEnable or Disable in game Dev tag or show current state if on/off not provided.", 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnDevSet:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Ligne 2 : Champ d'annonce globale .announce
            row = CreateRow(page, 30)
            local announceEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            announceEdit:SetSize(150, 22)
            announceEdit:SetPoint("LEFT", row, "LEFT", 0, -40)
            announceEdit:SetAutoFocus(false)
            announceEdit:SetText("Message")
            local btnAnnounce = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnAnnounce:SetSize(60, 22)
            btnAnnounce:SetText("Send")
            btnAnnounce:SetPoint("LEFT", announceEdit, "RIGHT", 10, 0)
            btnAnnounce:SetScript("OnClick", function()
                local text = announceEdit:GetText()
                if not text or text == "" or text == "Message" then
                    print("Erreur : Veuillez saisir un message différent de la valeur par défaut pour .announce.")
                else
                    SendChatMessage('.announce "' .. text .. '"', "SAY")
                end
            end)
            btnAnnounce:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Syntax: .announce $MessageToBroadcast\r\n\r\nSend a global message to all players online in chat log.", 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnAnnounce:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Ligne 3 : Champ GM Message pour .gmannounce
            row = CreateRow(page, 30)
            local gmMessageEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            gmMessageEdit:SetSize(150, 22)
            gmMessageEdit:SetPoint("LEFT", row, "LEFT", 0, -40)
            gmMessageEdit:SetAutoFocus(false)
            gmMessageEdit:SetText("GM Message")
            local btnGmMessage = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnGmMessage:SetSize(60, 22)
            btnGmMessage:SetText("Send")
            btnGmMessage:SetPoint("LEFT", gmMessageEdit, "RIGHT", 10, 0)
            btnGmMessage:SetScript("OnClick", function()
                local text = gmMessageEdit:GetText()
                if not text or text == "" or text == "GM Message" then
                    print("Erreur : Veuillez saisir un message différent de la valeur par défaut pour .gmannounce.")
                else
                    SendChatMessage('.gmannounce "' .. text .. '"', "SAY")
                end
            end)
            btnGmMessage:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Syntax: .gmnameannounce $announcement.\r\nSend an announcement to all online GM's, displaying the name of the sender.", 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnGmMessage:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Ligne 4 : Champ GM Notification pour .gmnotify
            row = CreateRow(page, 30)
            local gmNotifyEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            gmNotifyEdit:SetSize(150, 22)
            gmNotifyEdit:SetPoint("LEFT", row, "LEFT", 0, -40)
            gmNotifyEdit:SetAutoFocus(false)
            gmNotifyEdit:SetText("GM Notification")
            local btnGmNotify = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnGmNotify:SetSize(60, 22)
            btnGmNotify:SetText("Send")
            btnGmNotify:SetPoint("LEFT", gmNotifyEdit, "RIGHT", 10, 0)
            btnGmNotify:SetScript("OnClick", function()
                local text = gmNotifyEdit:GetText()
                if not text or text == "" or text == "GM Notification" then
                    print("Erreur : Veuillez saisir une notification différente de la valeur par défaut pour .gmnotify.")
                else
                    SendChatMessage('.gmnotify "' .. text .. '"', "SAY")
                end
            end)
            btnGmNotify:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Syntax: .gmnotify $notification\r\nDisplays a notification on the screen of all online GM's.", 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnGmNotify:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Ligne 5 : Champ GM Announcement pour .nameannounce
            row = CreateRow(page, 30)
            local gmAnnounceEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            gmAnnounceEdit:SetSize(150, 22)
            gmAnnounceEdit:SetPoint("LEFT", row, "LEFT", 0, -40)
            gmAnnounceEdit:SetAutoFocus(false)
            gmAnnounceEdit:SetText("GM Announcement")
            local btnGmAnnounce = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnGmAnnounce:SetSize(60, 22)
            btnGmAnnounce:SetText("Send")
            btnGmAnnounce:SetPoint("LEFT", gmAnnounceEdit, "RIGHT", 10, 0)
            btnGmAnnounce:SetScript("OnClick", function()
                local text = gmAnnounceEdit:GetText()
                if not text or text == "" or text == "GM Announcement" then
                    print("Erreur : Veuillez saisir un message différent de la valeur par défaut pour .nameannounce.")
                else
                    SendChatMessage('.nameannounce "' .. text .. '"', "SAY")
                end
            end)
            btnGmAnnounce:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Syntax: .nameannounce $announcement.\nSend an announcement to all online players, displaying the name of the sender.", 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnGmAnnounce:SetScript("OnLeave", function() GameTooltip:Hide() end)

		-----------------------------------------------------------------------------
		-- Ligne 6 : Dropdown Skill, champs Level et Max pour .setskill
		-----------------------------------------------------------------------------
		row = CreateRow(page, 30)
		
		-- Création d'un bouton d'affichage qui montrera le menu personnalisé
		local displayButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		displayButton:SetSize(220, 22)
		displayButton:SetPoint("LEFT", row, "LEFT", 0, -40)
		displayButton:SetText("Select Skill")
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
				displayButton:SetText(TrinityAdmin_Translations[SkillsData[self.index].name] or SkillsData[self.index].name)
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
					buttons[i]:SetText(TrinityAdmin_Translations[skill.name] or skill.name)
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
				print("Erreur : Veuillez sélectionner une compétence.")
				return
			end
			local level = levelEdit:GetText()
			if not level or level == "" or level == "Level" then
				print("Erreur : Veuillez saisir une valeur pour Level.")
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
			GameTooltip:SetText("Syntax: .setskill #skill #level [#max]\r\n\r\nSet a skill of id #skill with a current skill value of #level and a maximum value of #max (or equal current maximum if not provided) for the selected character. If no character is selected, you learn the skill.", 1, 1, 1, 1, true)
			GameTooltip:Show()
		end)
		btnSetSkill:SetScript("OnLeave", function() GameTooltip:Hide() end)

			end


    ----------------------------------------------------------------------------
    -- Bouton Back commun (hors pagination)
    ----------------------------------------------------------------------------
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"] or "Back")
    btnBack:SetSize(btnBack:GetTextWidth() + 20, 22)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    ShowPage(1)
    self.panel = panel
end
