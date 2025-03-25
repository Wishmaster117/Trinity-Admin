local module = TrinityAdmin:GetModule("GMFunctionsPanel")

-------------------------------------------------------------
-- Variables et fonctions pour la capture du .guild info
-------------------------------------------------------------
local capturingGuidInfo = false
local guidInfoCollected = {}
local guidInfoTimer = nil

-- Fonction appelée quand on arrête la capture
local function FinishGuidInfoCapture()
    capturingGuidInfo = false
    if #guidInfoCollected > 0 then
        -- Concatène toutes les lignes
        local fullText = table.concat(guidInfoCollected, "\n")
        
        -- Affiche dans la popup
        GuidInfoPopup_SetText(fullText)
        GuidInfoPopup:Show()
    else
        -- Aucun message capturé
        TrinityAdmin:Print("Nothing Captures.")
    end
end

-------------------------------------------------------------
-- Fenêtre popup GuildInfoPopup pour afficher le .guild info
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
    insets = { left=8, right=8, top=8, bottom=8 }
})
GuidInfoPopup:Hide()  -- Caché par défaut

-- Titre de la fenêtre
local title = GuidInfoPopup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -15)
title:SetText("Guild Info")

-- Bouton Close
local closeButton = CreateFrame("Button", nil, GuidInfoPopup, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", GuidInfoPopup, "TOPRIGHT")

-- ScrollFrame
local scrollFrame = CreateFrame("ScrollFrame", "GuidInfoScrollFrame", GuidInfoPopup, "UIPanelScrollFrameTemplate")
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
function GuidInfoPopup_SetText(text)
    infoText:SetText(text or "")
    local textHeight = infoText:GetStringHeight()
    content:SetHeight(textHeight + 5)
    scrollFrame:SetVerticalScroll(0) -- revient en haut
end

-------------------------------------------------------------
-- CaptureFrame pour écouter CHAT_MSG_SYSTEM
-------------------------------------------------------------
local guidCaptureFrame = CreateFrame("Frame")
guidCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
guidCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingGuidInfo then
        return
    end
    
    -- Nettoyage éventuel des codes couleur, etc.
    local cleanMsg = msg
    cleanMsg = cleanMsg:gsub("|c%x%x%x%x%x%x%x%x", "") -- Retire codes couleurs
    cleanMsg = cleanMsg:gsub("|r", "")
    cleanMsg = cleanMsg:gsub("|H.-|h(.-)|h", "%1")     -- Retire liens
    cleanMsg = cleanMsg:gsub("|T.-|t", "")             -- Retire textures
    -- Retire quelques caractères "box drawing"
    cleanMsg = cleanMsg:gsub("\226[\148-\149][\128-\191]", "")

    -- Ajoute la ligne au tableau
    table.insert(guidInfoCollected, cleanMsg)

    -- On redémarre le timer (1 seconde sans nouveau message => fin capture)
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

    -- On détermine l'ancrage
    local anchorRelative = panel
    local anchorPoint    = def.anchorTo or "TOPLEFT"
    local relativePoint  = def.anchorTo

    if def.linkTo and buttonRefs[def.linkTo] then
        anchorRelative = buttonRefs[def.linkTo]
        relativePoint  = "RIGHT"
    end

    btn:SetPoint(anchorPoint, anchorRelative, relativePoint, def.anchorOffsetX, def.anchorOffsetY)

    -- Gère le texte (toggle ou simple)
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

    -- Script OnClick
    if def.isToggle and def.stateVar then
        btn:SetScript("OnClick", function()
            if module[def.stateVar] then
                -- OFF
                SendChatMessage(def.commandOFF, "SAY")
                btn:SetText(def.textOFF)
                module[def.stateVar] = false
            else
                -- ON
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

    -- Tooltip
    SetTooltipScripts(btn, def.tooltip)

    -- Stockage de la référence du bouton
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
    -- contentContainer:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)
	contentContainer:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, 30)
    contentContainer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 40)

    local totalPages = 2
    local pages = {}
    for i = 1, totalPages do
        pages[i] = CreateFrame("Frame", nil, contentContainer)
        pages[i]:SetAllPoints(contentContainer)
        pages[i]:Hide()
        pages[i].yOffset = 0  -- pour placer les éléments verticalement
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
	-- Déclaration de la variable de page actuelle et pré-déclaration des boutons
	local currentPage = 1
	local btnPrev, btnNext
	
	-- Création de navPageLabel (celui-ci peut être créé avant les boutons)
	local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 35)
	navPageLabel:SetText("Page 1 / " .. totalPages)
	
	-- Déclaration de la fonction ShowPage qui utilise btnPrev et btnNext
	local function ShowPage(pageIndex)
		for i = 1, totalPages do
			if i == pageIndex then
				pages[i]:Show()
			else
				pages[i]:Hide()
			end
		end
		navPageLabel:SetText("Page " .. pageIndex .. " / " .. totalPages)
		if pageIndex <= 1 then
			btnPrev:SetEnabled(false)
		else
			btnPrev:SetEnabled(true)
		end
		if pageIndex >= totalPages then
			btnNext:SetEnabled(false)
		else
			btnNext:SetEnabled(true)
		end
	end
	
	-- Création et configuration du bouton Précédent
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
	
	-- Création et configuration du bouton Suivant
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
	
	-- Appel initial de la fonction ShowPage
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

            local muteEdit = CreateFrame("EditBox", "TrinityAdminMuteEditBox", page, "InputBoxTemplate")
            muteEdit:SetAutoFocus(false)
            muteEdit:SetSize(180, 22)
            muteEdit:SetPoint("TOPLEFT", muteLabel, "BOTTOMLEFT", 0, -35)
            muteEdit:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if muteDropdown.selectedOption.text == "mute" then
                    GameTooltip:SetText("Syntax : PlayerName TimeInMinutes Reason", 1, 1, 1, 1, true)
                else
                    GameTooltip:SetText("", 1, 1, 1, 1, true)
                end
                GameTooltip:Show()
            end)
            muteEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
            muteEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

            local btnMuteGo = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
            btnMuteGo:SetSize(40, 22)
            btnMuteGo:SetText("Go")
            btnMuteGo:SetPoint("LEFT", muteEdit, "RIGHT", 10, 0)
            btnMuteGo:SetScript("OnClick", function()
                local inputText = muteEdit:GetText()
                local option = muteDropdown.selectedOption
                local cmd = option.command
                local finalCommand = ""
                if option.text == "mute" then
                    local targetName = UnitName("target")
                    if targetName then
                        local time, reason = string.match(inputText, "^(%S+)%s+(.+)$")
                        if not time or not reason then
                            print("Veuillez saisir le temps (minutes) et la raison, séparés par un espace.")
                            return
                        else
                            finalCommand = cmd .. " " .. targetName .. " " .. time .. " " .. reason
                        end
                    else
                        if not inputText or inputText == "" then
                            print("Veuillez saisir le nom du joueur, le temps et la raison pour .mute.")
                            return
                        else
                            finalCommand = cmd .. " " .. inputText
                        end
                    end
                else
                    if not inputText or inputText == "" then
                        local targetName = UnitName("target")
                        if targetName then
                            finalCommand = cmd .. " " .. targetName
                        else
                            print("Veuillez saisir un nom ou cibler un joueur.")
                            return
                        end
                    else
                        finalCommand = cmd .. " " .. inputText
                    end
                end
                SendChatMessage(finalCommand, "SAY")
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
