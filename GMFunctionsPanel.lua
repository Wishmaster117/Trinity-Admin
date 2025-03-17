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
        anchorOffsetX = 0,
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
		    print("Commande envoyée :" ..def.command) -- Pour débug, à enlever
            SendChatMessage(def.command, "SAY")
        end)
    end

    -- Tooltip
    SetTooltipScripts(btn, def.tooltip)

    -- On stocke ce bouton dans un tableau de références
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

    -- Tableau pour stocker les références de nos boutons
    local buttonRefs = {}

    -- Crée tous les boutons
    for _, def in ipairs(buttonDefs) do
        CreateGMButton(panel, def, self, buttonRefs)
    end

    ------------------------------------------------------------------
    -- Création du champ "Appear" et son bouton Go
    ------------------------------------------------------------------
    -- On part du principe que le dernier bouton de la première ligne est "btnRespawn"
    local anchor = buttonRefs["btnRevive"]
    if anchor then
        -- Label
        local appearLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        appearLabel:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -20)
        appearLabel:SetText("Appear Function")

        -- Champ de saisie
        local appearEdit = CreateFrame("EditBox", "TrinityAdminAppearEditBox", panel, "InputBoxTemplate")
        appearEdit:SetAutoFocus(false)
        appearEdit:SetSize(120, 22)
        appearEdit:SetPoint("TOPLEFT", appearLabel, "BOTTOMLEFT", 0, -5)
        
		-- Valeur par défaut
        appearEdit:SetText("Character Name")
		
        -- Tooltip du champ
        appearEdit:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(TrinityAdmin_Translations["Tele_to_Player"], 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        appearEdit:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- Pour valider quand on appuie sur Entrée
        appearEdit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
        end)

        -- Bouton Go
        local btnAppearGo = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        btnAppearGo:SetSize(40, 22)
        btnAppearGo:SetText("Go")
        btnAppearGo:SetPoint("LEFT", appearEdit, "RIGHT", 10, 0)

        btnAppearGo:SetScript("OnClick", function()
            local playerName = appearEdit:GetText()
            if playerName and playerName ~= "" then
                SendChatMessage(".appear "..playerName, "SAY")
            else
                print("Veuillez saisir le nom du joueur pour .appear.")
            end
        end)
    else
        print("Erreur: impossible de trouver 'btnRespawn' pour ancrer le champ Appear.")
    end
	
	------------------------------------------------------------------
    -- CREATION DU CHAMP "MORPH" ET SON BOUTON GO
    ------------------------------------------------------------------
    -- On va l'ancrer sous le précédent bloc Appear, par ex. sous le label Appear ou son Edit
    -- Si vous voulez le mettre "à côté", vous pouvez ajuster l'ancrage (e.g. "LEFT", offsetX, etc.).
    -- Ici, on suppose qu'on veut le placer dessous la zone Appear
    local anchor2 = buttonRefs["btnRevive"]  -- ou appearEdit, ou btnAppearGo, selon votre préférence
    if anchor2 then
        -- Label Morph
        local morphLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        morphLabel:SetPoint("TOPLEFT", anchor2, "BOTTOMLEFT", 180, -20)
        morphLabel:SetText("Morph Function")

        -- Champ de saisie Morph
        local morphEdit = CreateFrame("EditBox", "TrinityAdminMorphEditBox", panel, "InputBoxTemplate")
        morphEdit:SetAutoFocus(false)
        morphEdit:SetSize(120, 22)
        morphEdit:SetPoint("TOPLEFT", morphLabel, "BOTTOMLEFT", 0, -5)

        -- Valeur par défaut
        morphEdit:SetText("Display ID")

        -- Tooltip du champ
        morphEdit:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Change your current model id to #displayid.", 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        morphEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Au focus, si c'est "Display ID", on l'efface
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

        -- Bouton "Go" Morph
        local btnMorphGo = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        btnMorphGo:SetSize(40, 22)
        btnMorphGo:SetText("Go")
        btnMorphGo:SetPoint("LEFT", morphEdit, "RIGHT", 10, 0)
        btnMorphGo:SetScript("OnClick", function()
            local displayId = morphEdit:GetText()
            if displayId and displayId ~= "" and displayId ~= "Display ID" then
                SendChatMessage(".morph "..displayId, "SAY")
            else
                print("Veuillez saisir un Display ID pour .morph.")
            end
        end)
    else
        print("Erreur: impossible de trouver 'btnRevive' pour ancrer le champ Morph.")
    end
	
	------------------------------------------------------------------
    -- CREATION DU CHAMP "Custom Mute" et son bouton Go
    ------------------------------------------------------------------
    local anchorMute = buttonRefs["btnRevive"]
    if anchorMute then
        -- On ancre le label "Custom Mute" sous btnRevive avec un offset vertical de -80 pixels
        local muteLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        muteLabel:SetPoint("TOPLEFT", anchorMute, "BOTTOMLEFT", 0, -80)
        muteLabel:SetText("Mute Function")

        -- Création du menu déroulant pour choisir l'option mute
        local muteDropdown = CreateFrame("Frame", "TrinityAdminMuteDropdown", panel, "UIDropDownMenuTemplate")
        muteDropdown:SetPoint("TOPLEFT", muteLabel, "BOTTOMLEFT", 0, -5)
        UIDropDownMenu_SetWidth(muteDropdown, 110)
        UIDropDownMenu_SetButtonWidth(muteDropdown, 240)
        local muteOptions = {
            { text = "mute", command = ".mute", tooltip = "Syntax : PlayerName TimeInMinutes Reason" },
            { text = "unmute", command = ".unmute", tooltip = "" },
            { text = "mutehistory", command = ".mutehistory", tooltip = "" },
        }

		-- Initialisation de muteDropdown pour conserver la sélection
		if not muteDropdown.selectedID then 
			muteDropdown.selectedID = 1 
		end
		
		UIDropDownMenu_Initialize(muteDropdown, function(dropdownFrame, level, menuList)
			local info = UIDropDownMenu_CreateInfo()
			for i, option in ipairs(muteOptions) do
				info.text = option.text
				info.value = option.command
				info.checked = (i == muteDropdown.selectedID)  -- l'option sélectionnée est cochée
				info.func = function(buttonFrame)
					muteDropdown.selectedID = i                           -- mémorise l'ID sélectionné
					UIDropDownMenu_SetSelectedID(muteDropdown, i)           -- met à jour l'UI
					UIDropDownMenu_SetText(muteDropdown, option.text)       -- affiche le texte de l'option choisie
					muteDropdown.selectedOption = option                  -- stocke l'option choisie
				end
				UIDropDownMenu_AddButton(info, level)
			end
		end)
		
		UIDropDownMenu_SetSelectedID(muteDropdown, muteDropdown.selectedID)
		UIDropDownMenu_SetText(muteDropdown, muteOptions[muteDropdown.selectedID].text)
		muteDropdown.selectedOption = muteOptions[muteDropdown.selectedID]

        -- Champ de saisie pour la commande mute
        local muteEdit = CreateFrame("EditBox", "TrinityAdminMuteEditBox", panel, "InputBoxTemplate")
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

        -- Bouton "Go" pour la section Mute
		local btnMuteGo = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
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
				-- Si un joueur est ciblé, le champ doit contenir le temps et la raison
				local time, reason = string.match(inputText, "^(%S+)%s+(.+)$")
				if not time or not reason then
					print("Veuillez saisir le temps (minutes) et la raison, séparés par un espace.")
					return
				else
					finalCommand = cmd .. " " .. targetName .. " " .. time .. " " .. reason
				end
			else
				-- Si aucun joueur n'est ciblé, on attend que l'utilisateur saisisse tout : nom, temps, raison
				if not inputText or inputText == "" then
					print("Veuillez saisir le nom du joueur, le temps et la raison pour .mute.")
					return
				else
					finalCommand = cmd .. " " .. inputText
				end
			end
		else
			-- Pour les autres options (unmute, mutehistory)
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
        print("Erreur: impossible de trouver 'btnRevive' pour ancrer le bloc Mute.")
    end

    ------------------------------------------------------------------
    -- Bouton Back
    ------------------------------------------------------------------
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"] or "Back")
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
