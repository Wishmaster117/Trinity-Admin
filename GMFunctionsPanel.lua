local module = TrinityAdmin:GetModule("GMFunctionsPanel")

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
        radioOff:SetPoint("LEFT", radioOn, "RIGHT", 10, 0)
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
