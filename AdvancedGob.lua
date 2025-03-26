local AdvancedGob = TrinityAdmin:GetModule("AdvancedGob")

-------------------------------------------------------------
-- Variables et fonctions pour la capture du .gob info
-------------------------------------------------------------
local capturingGobInfo = false
local GobInfoCollected = {}
local GobInfoTimer = nil

-- Fonction appelée quand on arrête la capture
local function FinishGobInfoCapture()
    capturingGobInfo = false
    if #GobInfoCollected > 0 then
        -- Concatène toutes les lignes
        local fullText = table.concat(GobInfoCollected, "\n")
        
        -- Affiche dans la popup
        GobInfoPopup_SetText(fullText)
        GobInfoPopup:Show()
    else
        -- Aucun message capturé
        TrinityAdmin:Print("No Gob info was captured.")
    end
end

-------------------------------------------------------------
-- Fenêtre popup GobInfoPopup pour afficher le .gob info
-------------------------------------------------------------
local GobInfoPopup = CreateFrame("Frame", "GobInfoPopup", UIParent, "BackdropTemplate")
GobInfoPopup:SetSize(400, 300)
--GobInfoPopup:SetPoint("CENTER")
GobInfoPopup:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -100, -100)
GobInfoPopup:SetMovable(true)
GobInfoPopup:EnableMouse(true)
GobInfoPopup:RegisterForDrag("LeftButton")
-- Correction : utiliser GobInfoPopup.StartMoving et StopMovingOrSizing
GobInfoPopup:SetScript("OnDragStart", GobInfoPopup.StartMoving)
GobInfoPopup:SetScript("OnDragStop", GobInfoPopup.StopMovingOrSizing)
GobInfoPopup:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
GobInfoPopup:Hide()  -- Caché par défaut

-- Titre de la fenêtre
local title = GobInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -15)
title:SetText("Gob Info")

-- Bouton Close
local closeButton = CreateFrame("Button", nil, GobInfoPopup, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", GobInfoPopup, "TOPRIGHT")

-- ScrollFrame
local scrollFrame = CreateFrame("ScrollFrame", "GobInfoScrollFrame", GobInfoPopup, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 15, -50)
scrollFrame:SetSize(370, 230)

-- Conteneur du texte
local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(370, 230)
scrollFrame:SetScrollChild(content)

-- FontString pour le texte
local infoText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
infoText:SetPoint("TOPLEFT")
infoText:SetWidth(350)          -- un peu moins que 370 pour la marge
infoText:SetJustifyH("LEFT")
infoText:SetJustifyV("TOP")

-- Fonction pour régler le texte et ajuster la taille
function GobInfoPopup_SetText(text)
    infoText:SetText(text or "")
    local textHeight = infoText:GetStringHeight()
    content:SetHeight(textHeight + 5)
    scrollFrame:SetVerticalScroll(0) -- revient en haut
end

-------------------------------------------------------------
-- CaptureFrame pour écouter CHAT_MSG_SYSTEM
-------------------------------------------------------------
-- Déclaration globale dans le module (accessible par l'événement)
local posXEB, posYEB, posZEB, deleteGuidEB
local initialX, initialY, initialZ

-- local GobCaptureFrame = CreateFrame("Frame")
-- GobCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
-- GobCaptureFrame:SetScript("OnEvent", function(self, event, msg)
--     if capturingMemory then
--         local x, y, z = string.match(msg, "location %(([%d%.%-]+),%s*([%d%.%-]+),%s*([%d%.%-]+)%)")
--         if x and y and z then
--             posXEB:SetText(tostring(x))
--             posYEB:SetText(tostring(y))
--             posZEB:SetText(tostring(z))
--             print("Coordonnées capturées: X=" .. x .. " Y=" .. y .. " Z=" .. z)
--             capturingMemory = false
--             return  -- Arrête le traitement pour ce message
--         end
--     end
-- 
--     if not capturingGobInfo then
--         return
--     end
--     
--     -- Traitement habituel pour capturer le .gobject info
--     local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
--     cleanMsg = cleanMsg:gsub("|r", "")
--     cleanMsg = cleanMsg:gsub("|H.-|h(.-)|h", "%1")
--     cleanMsg = cleanMsg:gsub("|T.-|t", "")
--     cleanMsg = cleanMsg:gsub("\226[\148-\149][\128-\191]", "")
--     table.insert(GobInfoCollected, cleanMsg)
--     if GobInfoTimer then GobInfoTimer:Cancel() end
--     GobInfoTimer = C_Timer.NewTimer(1, FinishGobInfoCapture)
-- end)
local GobCaptureFrame = CreateFrame("Frame")
GobCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
GobCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if capturingMemory then
        local x, y, z = string.match(msg, "location %(([%d%.%-]+),%s*([%d%.%-]+),%s*([%d%.%-]+)%)")
        if x and y and z then
            posXEB:SetText(tostring(x))
            posYEB:SetText(tostring(y))
            posZEB:SetText(tostring(z))
            -- Mémorisation de la position initiale
            initialX = tonumber(x)
            initialY = tonumber(y)
            initialZ = tonumber(z)
            local spawnID = string.match(msg, "SpawnID:%s*([%d]+)")
            if spawnID and deleteGuidEB then
                deleteGuidEB:SetText(tostring(spawnID))
            end
            --print("Coordonnées capturées: X=" .. x .. " Y=" .. y .. " Z=" .. z .. " GUID=" .. (spawnID or ""))
            capturingMemory = false
            return  -- Arrête le traitement pour ce message
        end
    end

    if not capturingGobInfo then
        return
    end
    
    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
    cleanMsg = cleanMsg:gsub("|r", "")
    cleanMsg = cleanMsg:gsub("|H.-|h(.-)|h", "%1")
    cleanMsg = cleanMsg:gsub("|T.-|t", "")
    cleanMsg = cleanMsg:gsub("\226[\148-\149][\128-\191]", "")
    table.insert(GobInfoCollected, cleanMsg)
    if GobInfoTimer then GobInfoTimer:Cancel() end
    GobInfoTimer = C_Timer.NewTimer(1, FinishGobInfoCapture)
end)


-------------------------------------------------
-- Fonction pour afficher le panneau AdvancedGob
-------------------------------------------------
function AdvancedGob:ShowAdvancedGobPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAdvancedGobPanel()
    end
    self.panel:Show()
end

-------------------------------------------------
-- Fonction pour créer le panneau AdvancedGob
-------------------------------------------------
function AdvancedGob:CreateAdvancedGobPanel()
    local panel = CreateFrame("Frame", "TrinityAdminAdvancedGobPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
    
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)
    
    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Advanced GameObjects")

    -------------------------------------------------------------------------------
    -- Création de plusieurs pages dans le panneau
    -------------------------------------------------------------------------------
    local totalPages = 2  -- nombre de pages
    local pages = {}
    for i = 1, totalPages do
        pages[i] = CreateFrame("Frame", nil, panel)
        pages[i]:SetAllPoints(panel)
        pages[i]:Hide()  -- on cache toutes les pages au départ
    end
    
    -- Label de navigation unique (affiché en bas du panneau)
    local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
    navPageLabel:SetText("Page 1 / " .. totalPages)

    -------------------------------------------------------------------------------
    -- Boutons de navigation (précédent / suivant)
    -------------------------------------------------------------------------------
    local btnPrev, btnNext  -- déclaration globale dans le module

    local currentPage = 1
    local totalPages = 2

    local function ShowPage(pageIndex)
        currentPage = pageIndex  -- mettre à jour la variable globale de la pagination
        for i = 1, totalPages do
            if i == pageIndex then
                pages[i]:Show()
            else
                pages[i]:Hide()
            end
        end
        navPageLabel:SetText("Page " .. pageIndex .. " / " .. totalPages)

        if pageIndex == 1 then
            btnPrev:Disable()
        else
            btnPrev:Enable()
        end

        if pageIndex == totalPages then
            btnNext:Disable()
        else
            btnNext:Enable()
        end
    end

    btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnPrev:SetSize(80, 22)
    btnPrev:SetText("Précédent")
    btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            ShowPage(currentPage - 1)
        end
    end)

    btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnNext:SetSize(80, 22)
    btnNext:SetText("Suivant")
    btnNext:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
    btnNext:SetScript("OnClick", function()
        if currentPage < totalPages then
            ShowPage(currentPage + 1)
        end
    end)

    ShowPage(1)
    
    --------------------------------
    -- Pour la page 1 :
    --------------------------------
    local commandsFramePage1 = CreateFrame("Frame", nil, pages[1])
    commandsFramePage1:SetPoint("TOPLEFT", pages[1], "TOPLEFT", 20, -40)
    commandsFramePage1:SetSize(500, 350)
    
    local page1Title = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    page1Title:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, 0)
    page1Title:SetText("Advanced GameObjects 1")

    -- Sous-titre "Game Objects Near"
    local gameObjectsNearTitle = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    gameObjectsNearTitle:SetPoint("TOPLEFT", page1Title, "BOTTOMLEFT", 0, -20)
    gameObjectsNearTitle:SetText("Game Objects Near")

    -- Champ de saisie pour la distance
    local distanceEditBox = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
    distanceEditBox:SetSize(100, 22)
    distanceEditBox:SetPoint("TOPLEFT", gameObjectsNearTitle, "BOTTOMLEFT", 0, -10)
    distanceEditBox:SetAutoFocus(false)
    distanceEditBox:SetText("Distance")

    -- Bouton "Show"
    local btnShow = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
    btnShow:SetSize(60, 22)
    btnShow:SetPoint("LEFT", distanceEditBox, "RIGHT", 10, 0)
    btnShow:SetText("Show")
    btnShow:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .gobject near  [#distance]\nOutput gameobjects at distance #distance from player.\nOutput gameobject guids and coordinates sorted by distance from character.\nIf #distance not provided use 10 as default value.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnShow:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    btnShow:SetScript("OnClick", function(self)
        local distance = distanceEditBox:GetText()
        if distance == "" or distance == "Distance" then
            SendChatMessage(".gobject near", "SAY")
            --print("Commande envoyée: .gobject near")
        else
            SendChatMessage(".gobject near " .. distance, "SAY")
            --print("Commande envoyée: .gobject near " .. distance)
        end
        GobInfoPopup_SetText("")
        GobInfoCollected = {}
        capturingGobInfo = true
        if GobInfoTimer then
            GobInfoTimer:Cancel()
        end
        GobInfoTimer = C_Timer.NewTimer(1, FinishGobInfoCapture)
    end)
    
	--------------------------------
	-- Move du gameobject
	--------------------------------
	-- Champ de saisie pour le GUID du gameobject
	local gameObjectGuidEB = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	gameObjectGuidEB:SetSize(200, 22)
	gameObjectGuidEB:SetPoint("TOPLEFT", distanceEditBox, "BOTTOMLEFT", 0, -20)
	gameObjectGuidEB:SetAutoFocus(false)
	gameObjectGuidEB:SetText("Enter GameObject Guid")
	
	-- Bouton "Memory" à droite du champ GUID (reste inchangé)
	local capturingMemory = false  -- variable pour détecter la réponse du memory
	local btnMemory = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnMemory:SetSize(80, 22)
	btnMemory:SetPoint("LEFT", gameObjectGuidEB, "RIGHT", 5, 0)
	btnMemory:SetText("Memorize")
	btnMemory:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Click to save positions before making changes.", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnMemory:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
    end)
	
	btnMemory:SetScript("OnClick", function(self)
		local guid = gameObjectGuidEB:GetText()
		if guid == "" or guid == "Enter GameObject Guid" then
			print("Veuillez entrer un GameObject Guid valide.")
			return
		end
		capturingMemory = true
		SendChatMessage(".gobject info guid " .. guid, "SAY")
		--print("Commande envoyée: .gobject info guid " .. guid)
		C_Timer.NewTimer(3, function() capturingMemory = false end)
	end)
	
	GobCaptureFrame:SetScript("OnEvent", function(self, event, msg)
		if capturingMemory then
			-- Recherche le texte "location (x, y, z)" dans le message
			local x, y, z = string.match(msg, "location %(([%d%.%-]+),%s*([%d%.%-]+),%s*([%d%.%-]+)%)")
			if x and y and z then
				posXEB:SetText(tostring(x))
				posYEB:SetText(tostring(y))
				posZEB:SetText(tostring(z))
				-- Mémorisation de la position initiale
				initialX = tonumber(x)
				initialY = tonumber(y)
				initialZ = tonumber(z)
				local spawnID = string.match(msg, "SpawnID:%s*([%d]+)")
				if spawnID and deleteGuidEB then
					deleteGuidEB:SetText(tostring(spawnID))
				end
				-- print("Coordonnées capturées: X=" .. x .. " Y=" .. y .. " Z=" .. z .. " GUID=" .. (spawnID or ""))
				capturingMemory = false
				return  -- Arrête le traitement pour ce message
			end
		end
	
		if not capturingGobInfo then
			return
		end
    
    -- Traitement habituel pour capturer le .gobject info
    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
    cleanMsg = cleanMsg:gsub("|r", "")
    cleanMsg = cleanMsg:gsub("|H.-|h(.-)|h", "%1")
    cleanMsg = cleanMsg:gsub("|T.-|t", "")
    cleanMsg = cleanMsg:gsub("\226[\148-\149][\128-\191]", "")
    table.insert(GobInfoCollected, cleanMsg)
    if GobInfoTimer then GobInfoTimer:Cancel() end
    GobInfoTimer = C_Timer.NewTimer(1, FinishGobInfoCapture)
	end)
	
	-- Création des champs de position et affectation aux variables globales
	posXEB = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	posXEB:SetSize(80, 22)
	posXEB:SetPoint("TOPLEFT", gameObjectGuidEB, "BOTTOMLEFT", 0, -10)
	posXEB:SetAutoFocus(false)
	posXEB:EnableKeyboard(false)
	posXEB:SetText("0")
	
	posYEB = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	posYEB:SetSize(80, 22)
	posYEB:SetPoint("LEFT", posXEB, "RIGHT", 10, 0)
	posYEB:SetAutoFocus(false)
	posYEB:EnableKeyboard(false)
	posYEB:SetText("0")
	
	posZEB = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	posZEB:SetSize(80, 22)
	posZEB:SetPoint("LEFT", posYEB, "RIGHT", 10, 0)
	posZEB:SetAutoFocus(false)
	posZEB:EnableKeyboard(false)
	posZEB:SetText("0")
	
	-- Nouveau champ pour le GUID à supprimer
	deleteGuidEB = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	deleteGuidEB:SetSize(120, 22)
	deleteGuidEB:SetPoint("LEFT", posXEB, "BOTTOMLEFT", 0, -20)
	deleteGuidEB:SetAutoFocus(false)
	deleteGuidEB:EnableKeyboard(false)
	deleteGuidEB:SetText("GUID")
	
	-- Bouton "Delete" à droite du nouvel editbox
	local btnDelete = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnDelete:SetPoint("LEFT", deleteGuidEB, "RIGHT", 5, 0)
	btnDelete:SetHeight(22)
	btnDelete:SetText("Delete")
	btnDelete:SetWidth(btnDelete:GetTextWidth() + 10)
	btnDelete:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Delete The GameObject.", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnDelete:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
    end)	
	btnDelete:SetScript("OnClick", function(self)
		local guid = deleteGuidEB:GetText()
		if guid == "" or guid == "Enter GUID to delete" then
			print("Please enter a valid GUID.")
			return
		end
		local command = ".gobject delete " .. guid
		SendChatMessage(command, "SAY")
		print("Commande envoyée: " .. command)
	end)
	
	-- Conteneur pour les boutons fléchés (placé à droite des champs de position)
	local arrowContainer = CreateFrame("Frame", nil, commandsFramePage1)
	arrowContainer:SetSize(100, 100)
	arrowContainer:SetPoint("LEFT", posZEB, "RIGHT", 135, 30)
	
	-- Création d'un font string pour afficher le mode d'emploi au-dessus du bloc de flèches
	local instructionsText = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	instructionsText:SetPoint("TOPRIGHT", arrowContainer, "TOPLEFT", 250, 70)
	instructionsText:SetWidth(300)
	instructionsText:SetJustifyH("LEFT")
	instructionsText:SetText("Instructions: Get the object's GUID using the 'Show' button, enter this GUID in the 'Enter GameObject GUID' field and press Memorize to save the positions. Then, use the buttons to move the GameObject.")
	
	-- Bouton flèche haut (correspond à z+)
	local btnUp = CreateFrame("Button", nil, arrowContainer, "UIPanelButtonTemplate")
	btnUp:SetHeight(22)
	btnUp:SetPoint("TOP", arrowContainer, "TOP", 0, -5)
	btnUp:SetText("Move Up")
	btnUp:SetWidth(btnUp:GetTextWidth() + 10)
	btnUp:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Move GameObject Up (+Z Position).", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnUp:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
    end)
	
	btnUp:SetScript("OnClick", function(self)
		local guid = gameObjectGuidEB:GetText()
		if guid == "" or guid == "Enter GameObject Guid" then
			print("Veuillez entrer un GameObject Guid valide.")
			return
		end
		local x = tonumber(posXEB:GetText()) or 0
		local y = tonumber(posYEB:GetText()) or 0
		local z = tonumber(posZEB:GetText()) or 0
		z = z + 0.5  -- Incrémente Z (bouge vers le haut)
		posZEB:SetText(tostring(z))
		local command = ".gobject move " .. guid .. " " .. x .. " " .. y .. " " .. z
		SendChatMessage(command, "SAY")
		print("Commande envoyée: " .. command)
	end)
	
	-- Bouton flèche gauche (correspond à +X)
	local btnLeft = CreateFrame("Button", nil, arrowContainer, "UIPanelButtonTemplate")
	btnLeft:SetHeight(22)
	btnLeft:SetPoint("LEFT", btnUp, "BOTTOMLEFT", 70, -20)
	btnLeft:SetText("Move Right")
	btnLeft:SetWidth(btnLeft:GetTextWidth() + 10)
	btnLeft:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Move GameObject to Right (+X Position).", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLeft:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
    end)
	
	btnLeft:SetScript("OnClick", function(self)
		local guid = gameObjectGuidEB:GetText()
		if guid == "" or guid == "Enter GameObject Guid" then
			print("Veuillez entrer un GameObject Guid valide.")
			return
		end
		local x = tonumber(posXEB:GetText()) or 0
		local y = tonumber(posYEB:GetText()) or 0
		local z = tonumber(posZEB:GetText()) or 0
		x = x + 0.5  -- Décrémente X (bouge vers la gauche)
		posXEB:SetText(tostring(x))
		local command = ".gobject move " .. guid .. " " .. x .. " " .. y .. " " .. z
		SendChatMessage(command, "SAY")
		print("Commande envoyée: " .. command)
	end)
	
	-- Bouton flèche droite (correspond à -X)
	local btnRight = CreateFrame("Button", nil, arrowContainer, "UIPanelButtonTemplate")
	btnRight:SetHeight(22)
	btnRight:SetPoint("RIGHT", btnUp, "BOTTOMRIGHT", -70, -20)
	btnRight:SetText("Move Left")
	btnRight:SetWidth(btnRight:GetTextWidth() + 10)
	btnRight:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Move GameObject to Left (-X Position).", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnRight:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
    end)
	
	btnRight:SetScript("OnClick", function(self)
		local guid = gameObjectGuidEB:GetText()
		if guid == "" or guid == "Enter GameObject Guid" then
			print("Veuillez entrer un GameObject Guid valide.")
			return
		end
		local x = tonumber(posXEB:GetText()) or 0
		local y = tonumber(posYEB:GetText()) or 0
		local z = tonumber(posZEB:GetText()) or 0
		x = x - 0.5  -- Incrémente X (bouge vers la droite)
		posXEB:SetText(tostring(x))
		local command = ".gobject move " .. guid .. " " .. x .. " " .. y .. " " .. z
		SendChatMessage(command, "SAY")
		print("Commande envoyée: " .. command)
	end)
	
	-- Bouton flèche bas (correspond à z-)
	local btnDown = CreateFrame("Button", nil, arrowContainer, "UIPanelButtonTemplate")
	btnDown:SetHeight(22)
	btnDown:SetPoint("BOTTOM", arrowContainer, "BOTTOM", 0, 5)
	btnDown:SetText("Move Down")
	btnDown:SetWidth(btnDown:GetTextWidth() + 10)
	btnDown:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Move GameObject Down (-Z Position).", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnDown:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
    end)
	
	btnDown:SetScript("OnClick", function(self)
		local guid = gameObjectGuidEB:GetText()
		if guid == "" or guid == "Enter GameObject Guid" then
			print("Veuillez entrer un GameObject Guid valide.")
			return
		end
		local x = tonumber(posXEB:GetText()) or 0
		local y = tonumber(posYEB:GetText()) or 0
		local z = tonumber(posZEB:GetText()) or 0
		z = z - 0.5  -- Décrémente Z (bouge vers le bas)
		posZEB:SetText(tostring(z))
		local command = ".gobject move " .. guid .. " " .. x .. " " .. y .. " " .. z
		SendChatMessage(command, "SAY")
		print("Commande envoyée: " .. command)
	end)
	
	local btnReset = CreateFrame("Button", nil, arrowContainer, "UIPanelButtonTemplate")
	btnReset:SetHeight(22)
	btnReset:SetText("Reset")
	btnReset:SetWidth(btnReset:GetTextWidth() + 10)
	btnReset:SetPoint("CENTER", btnDown, "BOTTOM", 0, -30)
	btnReset:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Reset GameObject to its initial coordinates.", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnReset:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
    end)
	
	btnReset:SetScript("OnClick", function(self)
		if not initialX or not initialY or not initialZ then
			print("Aucune position initiale mémorisée.")
			return
		end
		posXEB:SetText(tostring(initialX))
		posYEB:SetText(tostring(initialY))
		posZEB:SetText(tostring(initialZ))
		local guid = gameObjectGuidEB:GetText()
		if guid == "" or guid == "Enter GameObject Guid" then
			print("Veuillez entrer un GameObject Guid valide.")
			return
		end
		local command = ".gobject move " .. guid .. " " .. initialX .. " " .. initialY .. " " .. initialZ
		SendChatMessage(command, "SAY")
		print("Reset: " .. command)
	end)


    --------------------------------
    -- Pour la page 2 :
    --------------------------------
    local commandsFramePage2 = CreateFrame("Frame", nil, pages[2])
    commandsFramePage2:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
    commandsFramePage2:SetSize(500, 350)
    
    local page2Title = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    page2Title:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, 0)
    page2Title:SetText("Advanced GameObjects 2")
    -- Ici, vous ajoutez les boutons pour la page 2

    -------------------------------------------------------------------------------
    -- Bouton helper pour créer des boutons simples (comme précédemment)
    -------------------------------------------------------------------------------
    local function CreateServerButton(name, text, tooltip, cmd)
        local btn = CreateFrame("Button", name, nil, "UIPanelButtonTemplate")
        btn:SetSize(150, 22)
        btn:SetText(text)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        btn:SetScript("OnClick", function(self)
            SendChatMessage(cmd, "SAY")
            print("Commande envoyée: " .. cmd)
        end)
        return btn
    end

    -------------------------------------------------------------------------------
    -- Fin du panneau, bouton Back déjà présent
    -------------------------------------------------------------------------------
    local btnBackFinal = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("BOTTOM", panel, "BOTTOM", 0, 30)
    btnBackFinal:SetText(TrinityAdmin_Translations["Back"])
    btnBackFinal:SetHeight(22)
    btnBackFinal:SetWidth(btnBackFinal:GetTextWidth() + 20)
    btnBackFinal:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
