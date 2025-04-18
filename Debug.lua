local Debug = TrinityAdmin:GetModule("Debug")
local L = _G.L

-------------------------------------------------
-- Fonction pour afficher le panneau Debug
-------------------------------------------------
function Debug:ShowDebugPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateDebugPanel()
    end
    self.panel:Show()
end

-------------------------------------------------
-- Fonction pour créer le panneau Debug
-------------------------------------------------
function Debug:CreateDebugPanel()
	local panel = CreateFrame("Frame", "TrinityAdminDebugPanel", TrinityAdminMainFrame)
	panel:ClearAllPoints()
	panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
	panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

	local bg = panel:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(true)
	bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

	panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	panel.title:SetPoint("TOPLEFT", 10, -10)
	panel.title:SetText(L["Debug Panel"])

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

     ------------------------------------------------------------------------------
    -- Boutons de navigation (précédent / suivant)
    ------------------------------------------------------------------------------
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
	btnPrev:SetText(L["Preview"])
	btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
	btnPrev:SetScript("OnClick", function()
		if currentPage > 1 then
			ShowPage(currentPage - 1)
		end
	end)
	
	btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnNext:SetSize(80, 22)
	btnNext:SetText(L["Next"])
	btnNext:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
	btnNext:SetScript("OnClick", function()
		if currentPage < totalPages then
			ShowPage(currentPage + 1)
		end
	end)

	ShowPage(1)
	
	-------------------------------------------------
	-- Helper functions and AceGUI window creator
	-------------------------------------------------
	local AceGUI = LibStub("AceGUI-3.0")
	
	local function AutoWidthButton(btn)
		btn:SetWidth(btn:GetTextWidth() + 20)
	end
	
	local function OpenDebugOutputWindow(title, debugCommand)
		local window = AceGUI:Create("Frame")
		window:SetTitle(title)
		window:SetStatusText("")
		window:SetLayout("Flow")
		window:SetWidth(400)
		window:SetHeight(300)
		window.frame:ClearAllPoints()
		window.frame:SetPoint("RIGHT", UIParent, "RIGHT", -10, 0)
		
		local outputBox = AceGUI:Create("MultiLineEditBox")
		outputBox:SetLabel("")
		outputBox:SetFullWidth(true)
		outputBox:SetFullHeight(true)
		outputBox:SetText("")
		window:AddChild(outputBox)
		
		-- Création d'un frame pour capter les messages du chat et les afficher dans outputBox
		local captureFrame = CreateFrame("Frame")
		--captureFrame:RegisterEvent("CHAT_MSG_CHANNEL")
		--captureFrame:RegisterEvent("CHAT_MSG_SAY")
		--captureFrame:RegisterEvent("CHAT_MSG_YELL")
		--captureFrame:RegisterEvent("CHAT_MSG_PARTY")
		--captureFrame:RegisterEvent("CHAT_MSG_GUILD")
		--captureFrame:RegisterEvent("CHAT_MSG_OFFICER")
		captureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
		captureFrame:SetScript("OnEvent", function(self, event, msg, ...)
			local currentText = outputBox:GetText()
			outputBox:SetText(currentText .. "\n" .. msg)
		end)
		
		return window
	end

	--------------------------------
	-- Pour la page 1 :
	--------------------------------
	local commandsFramePage1 = CreateFrame("Frame", nil, pages[1])
	commandsFramePage1:SetPoint("TOPLEFT", pages[1], "TOPLEFT", 20, -40)
	commandsFramePage1:SetSize(500, 350)
	
	local page1Title = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page1Title:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, 0)
	page1Title:SetText(L["Debug Functions Page 1"])

	-- Bouton Debug Areatriggers
	local debugAreatriggersButton = CreateFrame("Button", "DebugAreatriggersButton", commandsFramePage1, "UIPanelButtonTemplate")
	--debugAreatriggersButton:SetSize(180, 22)
	debugAreatriggersButton:SetHeight(24)
	debugAreatriggersButton:SetPoint("TOPLEFT", page1Title, "BOTTOMLEFT", 0, -20)
	debugAreatriggersButton:SetText(L["Areatriggers Debug is OFF"])
	debugAreatriggersButton:SetScript("OnClick", function(self)
		SendChatMessage(".debug areatriggers", "SAY")
		-- print("Commande envoyée: .debug areatriggers")
	end)
	debugAreatriggersButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Toggle debug mode for areatriggers. In debug mode GM will be notified if reaching an areatrigger."], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	debugAreatriggersButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	AutoWidthButton(debugAreatriggersButton)
	
	-- Bouton Debug Arena (à droite du bouton Areatriggers)
	local debugArenaButton = CreateFrame("Button", "DebugArenaButton", commandsFramePage1, "UIPanelButtonTemplate")
	--debugArenaButton:SetSize(180, 22)
	debugArenaButton:SetHeight(24)
	debugArenaButton:SetPoint("LEFT", debugAreatriggersButton, "RIGHT", 10, 0)
	debugArenaButton:SetText(L["Arena Debug is OFF"])
	debugArenaButton:SetScript("OnClick", function(self)
		SendChatMessage(".debug arena", "SAY")
		-- print("Commande envoyée: .debug arena")
	end)
	debugArenaButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Toggle debug mode for arenas. In debug mode GM can start arena with single player."], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	debugArenaButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	AutoWidthButton(debugArenaButton)
	
	-- Bouton Debug Bg (à droite du bouton Arena)
	local debugBgButton = CreateFrame("Button", "DebugBgButton", commandsFramePage1, "UIPanelButtonTemplate")
	-- debugBgButton:SetHight(180, 22)
	debugBgButton:SetHeight(24)
	debugBgButton:SetPoint("LEFT", debugArenaButton, "RIGHT", 10, 0)
	debugBgButton:SetText(L["Bg Debug is OFF"])
	debugBgButton:SetScript("OnClick", function(self)
		SendChatMessage(".debug bg", "SAY")
		-- print("Commande envoyée: .debug bg")
	end)
	debugBgButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Toggle debug mode for battlegrounds. In debug mode GM can start battleground with single player."], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	debugBgButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	AutoWidthButton(debugBgButton)
	
	-- Frame pour capturer les messages du chat et mettre à jour les boutons précédents
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
	eventFrame:SetScript("OnEvent", function(self, event, msg, ...)
		-- Mise à jour du bouton Areatriggers
		if msg:find("Areatrigger debugging turned on") then
			debugAreatriggersButton:SetText(L["Areatriggers Debug is ON"])
		elseif msg:find("Areatrigger debugging turned off") then
			debugAreatriggersButton:SetText(L["Areatriggers Debug is OFF"])
		end
	
		-- Mise à jour du bouton Arena (seulement la partie importante du message)
		if msg:find("Arenas are set to 1v1 for debugging") then
			debugArenaButton:SetText(L["Arena Debug is ON"])
		elseif msg:find("Arenas are set to normal playercount") then
			debugArenaButton:SetText(L["Arena Debug is OFF"])
		end
	
		-- Mise à jour du bouton Bg
		if msg:find("Battlegrounds are set to 1v0 for debugging") then
			debugBgButton:SetText(L["Bg Debug is ON"])
		elseif msg:find("Battlegrounds are set to normal playercount") then
			debugBgButton:SetText(L["Bg Debug is OFF"])
		end
	end)
	
	-------------------------------------------------
	-- Nouveaux boutons de debug avec sortie dans une fenêtre Ace3
	-------------------------------------------------
	-- Ligne 2 : Debug Combat, Debug Phase et Debug Threat
	-- Premier bouton de la deuxième rangée
	local debugCombatButton = CreateFrame("Button", "DebugCombatButton", commandsFramePage1, "UIPanelButtonTemplate")
	debugCombatButton:SetText(L["Debug Combat"])
	debugCombatButton:SetHeight(24)
	debugCombatButton:SetPoint("TOPLEFT", debugAreatriggersButton, "BOTTOMLEFT", 0, -20)
	debugCombatButton:SetScript("OnClick", function(self)
		SendChatMessage(".debug combat", "SAY")
		-- print("Commande envoyée: .debug combat")
		OpenDebugOutputWindow("Debug Combat Output", ".debug combat")
	end)
	debugCombatButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Lists the target's (or own) combat references."], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	debugCombatButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	AutoWidthButton(debugCombatButton)
	
	local debugPhaseButton = CreateFrame("Button", "DebugPhaseButton", commandsFramePage1, "UIPanelButtonTemplate")
	debugPhaseButton:SetText(L["Debug Phase"])
	debugPhaseButton:SetHeight(24)
	debugPhaseButton:SetPoint("LEFT", debugCombatButton, "RIGHT", 10, 0)
	debugPhaseButton:SetScript("OnClick", function(self)
		SendChatMessage(".debug phase", "SAY")
		-- print("Commande envoyée: .debug phase")
		OpenDebugOutputWindow("Debug Phase Output", ".debug phase")
	end)
	debugPhaseButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Sends a phase debug report of a player to you."], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	debugPhaseButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	AutoWidthButton(debugPhaseButton)
	
	local debugThreatButton = CreateFrame("Button", "DebugThreatButton", commandsFramePage1, "UIPanelButtonTemplate")
	debugThreatButton:SetText(L["Debug Threat"])
	debugThreatButton:SetHeight(24)
	debugThreatButton:SetPoint("LEFT", debugPhaseButton, "RIGHT", 10, 0)
	debugThreatButton:SetScript("OnClick", function(self)
		SendChatMessage(".debug threat", "SAY")
		-- print("Commande envoyée: .debug threat")
		OpenDebugOutputWindow("Debug Threat Output", ".debug threat")
	end)
	debugThreatButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Lists the units threatened by target (or self). If target has a threat list, lists that threat list, too."], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	debugThreatButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	AutoWidthButton(debugThreatButton)
	
	-- Ligne 3 : Debug Threatinfo, Debug asan memoryleak et Debug asan outofbounds
	local debugThreatinfoButton = CreateFrame("Button", "DebugThreatinfoButton", commandsFramePage1, "UIPanelButtonTemplate")
	debugThreatinfoButton:SetText(L["Debug Threatinfo"])
	debugThreatinfoButton:SetHeight(24)
	debugThreatinfoButton:SetPoint("TOPLEFT", debugCombatButton, "BOTTOMLEFT", 0, -20)
	debugThreatinfoButton:SetScript("OnClick", function(self)
		SendChatMessage(".debug threatinfo", "SAY")
		-- print("Commande envoyée: .debug threatinfo")
		OpenDebugOutputWindow("Debug Threatinfo Output", ".debug threatinfo")
	end)
	debugThreatinfoButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Displays various debug information about the target's threat state, modifiers, redirects and similar."], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	debugThreatinfoButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	AutoWidthButton(debugThreatinfoButton)
	
	local debugAsanMemoryleakButton = CreateFrame("Button", "DebugAsanMemoryleakButton", commandsFramePage1, "UIPanelButtonTemplate")
	debugAsanMemoryleakButton:SetText(L["Debug asan memoryleak"])
	debugAsanMemoryleakButton:SetHeight(24)
	debugAsanMemoryleakButton:SetPoint("LEFT", debugThreatinfoButton, "RIGHT", 10, 0)
	debugAsanMemoryleakButton:SetScript("OnClick", function(self)
		SendChatMessage(".debug asan memoryleak", "SAY")
		-- print("Commande envoyée: .debug asan memoryleak")
		OpenDebugOutputWindow("Debug asan memoryleak Output", ".debug asan memoryleak")
	end)
	debugAsanMemoryleakButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Triggers a memory leak.\nUse only when testing dynamic analysis tools."], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	debugAsanMemoryleakButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	AutoWidthButton(debugAsanMemoryleakButton)
	
	local debugAsanOutofboundsButton = CreateFrame("Button", "DebugAsanOutofboundsButton", commandsFramePage1, "UIPanelButtonTemplate")
	debugAsanOutofboundsButton:SetText(L["Debug asan outofbounds"])
	debugAsanOutofboundsButton:SetHeight(24)
	debugAsanOutofboundsButton:SetPoint("LEFT", debugAsanMemoryleakButton, "RIGHT", 10, 0)
	debugAsanOutofboundsButton:SetScript("OnClick", function(self)
		SendChatMessage(".debug asan outofbounds", "SAY")
		-- print("Commande envoyée: .debug asan outofbounds")
		OpenDebugOutputWindow("Debug asan outofbounds Output", ".debug asan outofbounds")
	end)
	debugAsanOutofboundsButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Triggers a stack out of bounds read.\nUse only when testing dynamic analysis tools."], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	debugAsanOutofboundsButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	AutoWidthButton(debugAsanOutofboundsButton)

	
	------------------------------------------------------------
	-- Page 2
	------------------------------------------------------------
	local commandsFramePage2 = CreateFrame("Frame", nil, pages[2])
	commandsFramePage2:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
	commandsFramePage2:SetSize(500, 350)
	
	local page2Title = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page2Title:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, 0)
	page2Title:SetText(L["Debug Functions Page 2"])
	
	-- Table qui définit les commandes debug et leur interface
	local debugCommands = {
	["debug boundary"] = {
		fields = { {default="Fill"}, {default="Duration"} },
		buttonText = L["Start"],
		tooltip = "Flood fills the targeted unit's movement boundary and marks the edge of said boundary with debug creatures.\nSpecify 'fill' as first parameter to fill the entire area with debug creatures.",
		commandPrefix = ".debug boundary",
		mandatory = {1}  -- Le champ Fill est obligatoire si Duration est renseigné
	},
	["debug conversation"] = {
		fields = { {default="Conversation ID"} },
		buttonText = L["Start"],
		tooltip = "Play given conversation.",
		commandPrefix = ".debug conversation",
		mandatory = {1}
	},
	["debug guidlimits"] = {
		fields = { {default="Map ID"} },
		buttonText = L["Start"],
		tooltip = "Shows the current Creature and GameObject highest Guid for the specified map id or for all maps if none is specified\n",
		commandPrefix = ".debug guidlimits"
	},
	["debug instancespawn"] = {
		fields = { {default="Group ID or explain"} },
		buttonText = L["Start"],
		tooltip = "Displays information about the spawn groups being managed by the current instance script. If groupID is specified, additionally explains why that spawn group is in the listed state. If 'explain' is specified, explains all spawn groups.",
		commandPrefix = ".debug instancespawn"
	},
	["debug loadcells"] = {
		fields = { {default="Map ID"} },
		buttonText = L["Start"],
		tooltip = "Loads all cells for debugging purposes",
		commandPrefix = ".debug loadcells"
	},
	["debug moveflags"] = {
		fields = { {default="NewMoveFlags"}, {default="NewMoveFlags2"} },
		buttonText = L["Start"],
		tooltip = "No params given will output the current moveflags of the target",
		commandPrefix = ".debug moveflags"
	},
	["debug neargraveyard"] = {
		fields = { {default="Nothing or linked"} },
		buttonText = L["Start"],
		tooltip = "Find the nearest graveyard from dbc or db (if linked)",
		commandPrefix = ".debug neargraveyard"
	},
	["debug objectcount"] = {
		fields = { {default="Map ID"} },
		buttonText = L["Start"],
		tooltip = "Shows the number of Creatures and GameObjects for the specified map id or for all maps if none is specified\n",
		commandPrefix = ".debug objectcount"
	},
	["debug play cinematic"] = {
		fields = { {default="Cinematic ID"} },
		buttonText = L["Start"],
		tooltip = "Syntax: .debug play cinematic #cinematicid\r\n\r\nPlay cinematic #cinematicid for you. You stay at place while your mind fly.\r\n",
		commandPrefix = ".debug play cinematic",
		mandatory = {1}
	},
	["debug play movie"] = {
		fields = { {default="Movie ID"} },
		buttonText = L["Start"],
		tooltip = "Syntax: .debug play movie #movieid\r\n\r\nPlay movie #movieid for you.",
		commandPrefix = ".debug play movie",
		mandatory = {1}
	},
	["debug play music"] = {
		fields = { {default="Music ID"} },
		buttonText = L["Start"],
		tooltip = "Syntax: .debug play music #musicId\nPlay music with #musicId.\nMusic will be played only for you. Other players will not hear this.",
		commandPrefix = ".debug play music",
		mandatory = {1}
	},
	["debug objectsound"] = {
		fields = { {default="SoundKit Id"}, {default="BroadcastText Id"} },
		buttonText = L["Start"],
		tooltip = "Syntax: .debug play objectsound #soundKitId [#broadcastTextId]\nPlay object sound with #soundKitId [and #broadcastTextId].\nSound will be played only for you. Other players will not hear this.",
		commandPrefix = ".debug play objectsound"
	},
	["debug play sound"] = {
		fields = { {default="Sound ID"} },
		buttonText = L["Start"],
		tooltip = "Syntax: .debug play sound #soundid\r\n\r\nPlay sound with #soundid.\r\nSound will be play only for you. Other players do not hear this.\r\nWarning: client may have more 5000 sounds...",
		commandPrefix = ".debug play sound",
		mandatory = {1}
	},
	["debug questreset"] = {
		dropdown = { options = {"daily", "weekly", "monthly", "all"}, default = "daily" },
		buttonText = "Reset",
		tooltip = "Syntax: .debug questreset <daily/weekly/monthly/all>\n\nPerforms quest reset procedure for the specified type (or all types).\nQuest pools will be re-generated, and quest completion status will be reset.",
		commandPrefix = ".debug questreset"
	},
	["debug raidreset"] = {
		fields = { {default="Map ID"}, {default="Difficulty"} },
		buttonText = "Reset",
		tooltip = "Syntax: .debug raidreset mapid [difficulty]\nForces a global reset of the specified map on all difficulties (or only the specific difficulty if specified). Effectively the same as setting the specified map's reset timer to now.",
		commandPrefix = ".debug raidreset",
		mandatory = {1}  -- Map ID est obligatoire
	},
	["debug send playerchoice"] = {
		fields = { {default="Choice Id"} },
		buttonText = L["Start"],
		tooltip = "Syntax: .debug send playerchoice $choiceId\r\nSend given choice to player.",
		commandPrefix = ".debug send playerchoice",
		mandatory = {1}
	},
	["debug transport"] = {
		dropdown = { options = {"Start", "stop"}, default = "start" },
		buttonText = L["Set"],
		tooltip = "Syntax: .debug transport [start/stop]\n\nAllows to stop the current transport at its nearest wait point and start movement of a stopped one. Not all transports can be started or stopped.",
		commandPrefix = ".debug transport"
	},
	["debug warden force"] = {
		buttonText = L["Start"],
		tooltip = "Syntax: .debug warden force\nForces the warden to perform its action.",
		commandPrefix = ".debug warden force"
	},
	["debug worldstate"] = {
		fields = { {default="State Id"}, {default="Value"} },
		buttonText = L["Start"],
		tooltip = "Syntax: debug worldstate $stateId $value\n\nSends a world state update for the specified state to your client.",
		commandPrefix = ".debug worldstate",
		mandatory = {1,2}
	},
	["debug dummy"] = {
		buttonText = L["Start"],
		tooltip = "Syntax: .debug dummy\nA dummy debug command.",
		commandPrefix = ".debug dummy"
	}
	}
	
	-- Création du menu déroulant de sélection principal
	local debugDropdown = CreateFrame("Frame", "DebugDropdown", commandsFramePage2, "UIDropDownMenuTemplate")
	debugDropdown:SetPoint("TOPLEFT", page2Title, "BOTTOMLEFT", 0, -20)
	UIDropDownMenu_SetWidth(debugDropdown, 200)
	UIDropDownMenu_Initialize(debugDropdown, function(self, level, menuList)
	for k, _ in pairs(debugCommands) do
		local info = UIDropDownMenu_CreateInfo() -- création d'une nouvelle table pour chaque option
		info.text = k
		info.value = k
		info.checked = (UIDropDownMenu_GetSelectedValue(debugDropdown) == k)
		info.func = function(button)
		UIDropDownMenu_SetSelectedValue(debugDropdown, button.value)
		UIDropDownMenu_SetText(debugDropdown, button.value)
		UpdateDebugCommandUI(button.value)
		end
		UIDropDownMenu_AddButton(info)
	end
	end)
	UIDropDownMenu_SetText(debugDropdown, "Please choose")
	UIDropDownMenu_SetSelectedValue(debugDropdown, "Please choose")
	
	-- Création d'une frame pour contenir dynamiquement les champs et le bouton
	local debugCommandFrame = CreateFrame("Frame", nil, commandsFramePage2)
	debugCommandFrame:SetPoint("TOPLEFT", debugDropdown, "BOTTOMLEFT", 0, -20)
	debugCommandFrame:SetSize(400, 200)
	
	-- Fonction utilitaire pour nettoyer la frame (supprime les éléments enfants)
	local function ClearDebugCommandFrame()
	for _, child in ipairs({debugCommandFrame:GetChildren()}) do
		child:Hide()
		child:SetParent(nil)
	end
	end
	
	-- Fonction qui met à jour l'interface en fonction de la commande sélectionnée
	function UpdateDebugCommandUI(commandName)
	ClearDebugCommandFrame()
	local cmdInfo = debugCommands[commandName]
	if not cmdInfo then return end
	
	local yOffset = 0
	local inputs = {}  -- table pour stocker les champs de saisie ou dropdown
	
	if cmdInfo.fields then
		for i, field in ipairs(cmdInfo.fields) do
		local editBox = CreateFrame("EditBox", nil, debugCommandFrame, "InputBoxTemplate")
		editBox:SetSize(150, 22)
		editBox:SetPoint("TOPLEFT", debugCommandFrame, "TOPLEFT", 0, -yOffset)
		editBox:SetAutoFocus(false)
		editBox:SetText(field.default)
		inputs[i] = editBox
		yOffset = yOffset + 30
		end
	elseif cmdInfo.dropdown then
		local dropdown = CreateFrame("Frame", nil, debugCommandFrame, "UIDropDownMenuTemplate")
		dropdown:SetPoint("TOPLEFT", debugCommandFrame, "TOPLEFT", 0, -yOffset)
		UIDropDownMenu_SetWidth(dropdown, 150)
		UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
		for _, option in ipairs(cmdInfo.dropdown.options) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = option
			info.value = option
			info.checked = (UIDropDownMenu_GetSelectedValue(dropdown) == option)
			info.func = function(button)
			UIDropDownMenu_SetSelectedValue(dropdown, button.value)
			UIDropDownMenu_SetText(dropdown, button.value)
			end
			UIDropDownMenu_AddButton(info)
		end
		end)
		UIDropDownMenu_SetText(dropdown, cmdInfo.dropdown.default)
		inputs[1] = dropdown
		yOffset = yOffset + 40  -- Augmentation de l'offset pour dropdown(s)
	end
	
	-- Création du bouton d'action, positionné en fonction du yOffset calculé
	local btn = CreateFrame("Button", nil, debugCommandFrame, "UIPanelButtonTemplate")
	btn:SetSize(80, 22)
	btn:SetPoint("TOPLEFT", debugCommandFrame, "TOPLEFT", 0, -yOffset)
	btn:SetText(cmdInfo.buttonText)
	btn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(cmdInfo.tooltip, 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btn:SetScript("OnClick", function()
		local command = cmdInfo.commandPrefix
		if cmdInfo.fields then
		for i, field in ipairs(cmdInfo.fields) do
			local text = inputs[i]:GetText()
			if cmdInfo.mandatory and (function()
			for _, m in ipairs(cmdInfo.mandatory) do
				if m == i then return true end
			end
			return false
			end)() and (not text or text == field.default) then
			print("Erreur : le champ '" .. field.default .. "' est obligatoire!")
			return
			end
			if commandName == "debug boundary" and i == 1 and (not text or text == field.default) then
			break
			end
			command = command .. " " .. text
		end
		elseif cmdInfo.dropdown then
		local selectedValue = UIDropDownMenu_GetSelectedValue(inputs[1])
		command = command .. " " .. (selectedValue or cmdInfo.dropdown.default)
		end
		--print("[DEBUG] Commande construite: " .. command)
		SendChatMessage(command, "SAY")
		--print("[DEBUG] Commande envoyée: " .. command)
	end)
	
	debugCommandFrame:Show()
	end

---------------------------------------------------------------
-- SECTION: Scene Debug Options (ajouté à droite de debugCommandFrame)
---------------------------------------------------------------
-- On suppose que debugCommandFrame existe déjà dans la page 2 du module debug.
local sceneDebugEnabled = false

-- Création d'une frame pour la section Scene Debug, positionnée à droite de debugCommandFrame
local sceneDebugFrame = CreateFrame("Frame", nil, commandsFramePage2)
sceneDebugFrame:SetPoint("TOPLEFT", page2Title, "TOPRIGHT", 200, 0)
sceneDebugFrame:SetSize(200, 300)

-- Bouton toggle pour activer/désactiver le debug de scene
local sceneToggleButton = CreateFrame("Button", nil, sceneDebugFrame, "UIPanelButtonTemplate")
sceneToggleButton:SetSize(150, 22)
sceneToggleButton:SetPoint("TOPLEFT", sceneDebugFrame, "TOPLEFT", 0, 0)
sceneToggleButton:SetText("Scene debug is OFF")
sceneToggleButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Toggle debug mode for scenes. In debug mode GM will be notified in chat when scenes start/stop/trigger event", 1,1,1,1,true)
    GameTooltip:Show()
end)
sceneToggleButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
sceneToggleButton:SetScript("OnClick", function(self)
    sceneDebugEnabled = not sceneDebugEnabled
    if sceneDebugEnabled then
        self:SetText("Scene debug is ON")
    else
        self:SetText("Scene debug is OFF")
    end
    SendChatMessage(".scene debug", "SAY")
end)

-- Dropdown pour choisir l'action de scene
local sceneActions = {"Choose", "scene play", "scene cancel", "scene playpackage"}
local sceneDropdown = CreateFrame("Frame", "SceneActionDropdown", sceneDebugFrame, "UIDropDownMenuTemplate")
sceneDropdown:SetPoint("TOPLEFT", sceneToggleButton, "BOTTOMLEFT", -20, -20)
UIDropDownMenu_SetWidth(sceneDropdown, 150)
UIDropDownMenu_SetText(sceneDropdown, "Choose")
sceneDropdown.selectedOption = "Choose"
UIDropDownMenu_Initialize(sceneDropdown, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for _, option in ipairs(sceneActions) do
        info.text = option
        info.value = option
        info.checked = (option == sceneDropdown.selectedOption)
        info.func = function(button)
            sceneDropdown.selectedOption = button.value
            UIDropDownMenu_SetText(sceneDropdown, button.value)
            UIDropDownMenu_SetSelectedValue(sceneDropdown, button.value)
            UpdateSceneUI(button.value)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- Frame conteneur pour les champs de saisie dynamiques
local sceneInputFrame = CreateFrame("Frame", nil, sceneDebugFrame)
sceneInputFrame:SetPoint("TOPLEFT", sceneDropdown, "BOTTOMLEFT", 0, -10)
sceneInputFrame:SetSize(150, 60)

-- Variables pour stocker les références aux champs de saisie créés dynamiquement
local sceneInput1, sceneInput2

-- Fonction utilitaire pour nettoyer le conteneur des inputs
local function ClearSceneInputs()
    for _, child in ipairs({sceneInputFrame:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    sceneInput1 = nil
    sceneInput2 = nil
end

-- Bouton d'action pour la dropdown, qui changera de texte et tooltip en fonction de l'option sélectionnée
local sceneActionButton = CreateFrame("Button", nil, sceneDebugFrame, "UIPanelButtonTemplate")
sceneActionButton:SetSize(150, 22)
sceneActionButton:SetPoint("TOPLEFT", sceneInputFrame, "BOTTOMLEFT", 0, -10)
sceneActionButton:SetText("Choose")
sceneActionButton.tooltip = "Choose an action"
sceneActionButton:Hide()
sceneActionButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltip or "Choose an action", 1,1,1,1,true)
    GameTooltip:Show()
end)
sceneActionButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Fonction de mise à jour de l'interface selon l'option sélectionnée dans la dropdown
function UpdateSceneUI(option)
    ClearSceneInputs()
    if option == "scene play" then
        sceneInput1 = CreateFrame("EditBox", nil, sceneInputFrame, "InputBoxTemplate")
        sceneInput1:SetSize(150,22)
        sceneInput1:SetPoint("TOPLEFT", sceneInputFrame, "TOPLEFT", 0, 0)
        sceneInput1:SetAutoFocus(false)
        sceneInput1:SetText("Scene Id")
        sceneActionButton:SetText("Play")
        sceneActionButton.tooltip = "Plays scene with id for targeted player."
        sceneActionButton:Show()
    elseif option == "scene cancel" then
        sceneInput1 = CreateFrame("EditBox", nil, sceneInputFrame, "InputBoxTemplate")
        sceneInput1:SetSize(150,22)
        sceneInput1:SetPoint("TOPLEFT", sceneInputFrame, "TOPLEFT", 0, 0)
        sceneInput1:SetAutoFocus(false)
        sceneInput1:SetText("Scene Package Id")
        sceneActionButton:SetText("Cancel")
        sceneActionButton.tooltip = "Cancels scene with package id for targeted player."
        sceneActionButton:Show()
    elseif option == "scene playpackage" then
        sceneInput1 = CreateFrame("EditBox", nil, sceneInputFrame, "InputBoxTemplate")
        sceneInput1:SetSize(150,22)
        sceneInput1:SetPoint("TOPLEFT", sceneInputFrame, "TOPLEFT", 0, 0)
        sceneInput1:SetAutoFocus(false)
        sceneInput1:SetText("Scene Package Id")
        sceneInput2 = CreateFrame("EditBox", nil, sceneInputFrame, "InputBoxTemplate")
        sceneInput2:SetSize(150,22)
        sceneInput2:SetPoint("TOPLEFT", sceneInput1, "BOTTOMLEFT", 0, -5)
        sceneInput2:SetAutoFocus(false)
        sceneInput2:SetText("Playback Flags")
        sceneActionButton:SetText("Play Package")
        sceneActionButton.tooltip = "Plays scene with package id and playback flags for targeted player."
        sceneActionButton:Show()
    else
        sceneActionButton:SetText("Choose")
        sceneActionButton.tooltip = "Choose an action"
        sceneActionButton:Hide()  -- On cache le bouton si l'option est "Choose"
    end
end

-- Script du bouton d'action pour envoyer la commande appropriée
sceneActionButton:SetScript("OnClick", function()
    local option = sceneDropdown.selectedOption
    if option == "scene play" then
        if sceneInput1 then
            local sceneId = sceneInput1:GetText()
            if sceneId == "" or sceneId == "Scene Id" then
                print("Erreur: veuillez renseigner un Scene Id.")
                return
            end
            local cmd = ".scene play " .. sceneId
            SendChatMessage(cmd, "SAY")
            print("[DEBUG] Commande envoyée: " .. cmd)
        end
    elseif option == "scene cancel" then
        if sceneInput1 then
            local scenePackageId = sceneInput1:GetText()
            if scenePackageId == "" or scenePackageId == "Scene Package Id" then
                print("Erreur: veuillez renseigner un Scene Package Id.")
                return
            end
            local cmd = ".scene cancel " .. scenePackageId
            SendChatMessage(cmd, "SAY")
            print("[DEBUG] Commande envoyée: " .. cmd)
        end
    elseif option == "scene playpackage" then
        if sceneInput1 and sceneInput2 then
            local scenePackageId = sceneInput1:GetText()
            local playbackFlags = sceneInput2:GetText()
            if scenePackageId == "" or scenePackageId == "Scene Package Id" then
                print("Erreur: veuillez renseigner un Scene Package Id.")
                return
            end
            if playbackFlags == "" or playbackFlags == "Playback Flags" then
                print("Erreur: veuillez renseigner les Playback Flags.")
                return
            end
            local cmd = ".scene playpackage " .. scenePackageId .. " " .. playbackFlags
            SendChatMessage(cmd, "SAY")
            print("[DEBUG] Commande envoyée: " .. cmd)
        end
    else
        print("Veuillez sélectionner une action dans le dropdown.")
    end
end)

    ------------------------------------------------------------------------------
    -- Bouton Back
    ------------------------------------------------------------------------------
    local btnBackFinal = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("BOTTOM", panel, "BOTTOM", 0, 30)
    btnBackFinal:SetText(L["Back"])
    btnBackFinal:SetHeight(22)
    btnBackFinal:SetWidth(btnBackFinal:GetTextWidth() + 20)
    btnBackFinal:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
