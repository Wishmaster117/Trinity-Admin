local Others = TrinityAdmin:GetModule("Others")

-------------------------------------------------
-- Fonction pour afficher le panneau Others
-------------------------------------------------
function Others:ShowOthersPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateOthersPanel()
    end
    self.panel:Show()
end

-------------------------------------------------
-- Fonction pour créer le panneau Others
-------------------------------------------------
function Others:CreateOthersPanel()
	local panel = CreateFrame("Frame", "TrinityAdminOthersPanel", TrinityAdminMainFrame)
	panel:ClearAllPoints()
	panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
	panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

	local bg = panel:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(true)
	bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

	panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	panel.title:SetPoint("TOPLEFT", 10, -10)
	panel.title:SetText("Other Stuffs")

    -------------------------------------------------------------------------------
    -- Création de plusieurs pages dans le panneau
    -------------------------------------------------------------------------------
	local totalPages = 3  -- nombre de pages
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
	local totalPages = 3
	
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
	page1Title:SetText("Desable Functions")
    -----------------------------------------------------------------
    -- Section "Desable Add"
    -----------------------------------------------------------------
    local addSubtitle = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addSubtitle:SetPoint("TOPLEFT", page1Title, "BOTTOMLEFT", 0, -20)
    addSubtitle:SetText("Desable Add")

    local disableAddOptions = {
        "disable add battleground",
        "disable add criteria",
        "disable add map",
        "disable add mmap",
        "disable add outdoorpvp",
        "disable add quest",
        "disable add spell",
        "disable add vmap",
    }
    local selectedAddCommand = disableAddOptions[1]

    local addDropdown = CreateFrame("Frame", "TrinityDisableAddDropdown", commandsFramePage1, "UIDropDownMenuTemplate")
    addDropdown:SetPoint("TOPLEFT", addSubtitle, "BOTTOMLEFT", 0, -10)
    UIDropDownMenu_SetWidth(addDropdown, 150)
    UIDropDownMenu_Initialize(addDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, cmd in ipairs(disableAddOptions) do
            info.text = cmd
            info.value = cmd
            info.checked = (cmd == selectedAddCommand)  -- Le petit point apparaît uniquement si c'est l'option sélectionnée
            info.func = function(self)
                selectedAddCommand = self.value
                UIDropDownMenu_SetSelectedValue(addDropdown, self.value)
                -- Pour mettre à jour le check, on peut réinitialiser le menu :
                UIDropDownMenu_Initialize(addDropdown, self:GetParent().initFunc)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedValue(addDropdown, selectedAddCommand)


    local addEntry = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
    addEntry:SetSize(100, 22)
    addEntry:SetPoint("TOPLEFT", addDropdown, "TOPRIGHT", 10, 0)
    addEntry:SetAutoFocus(false)
    addEntry:SetText("Entry")

    local addFlag = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
    addFlag:SetSize(100, 22)
    addFlag:SetPoint("TOPLEFT", addEntry, "TOPRIGHT", 10, 0)
    addFlag:SetAutoFocus(false)
    addFlag:SetText("Flag")

    local addComment = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
    addComment:SetSize(100, 22)
    addComment:SetPoint("TOPLEFT", addFlag, "TOPRIGHT", 10, 0)
    addComment:SetAutoFocus(false)
    addComment:SetText("Comment")

    local addButton = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
    addButton:SetSize(100, 22)
    addButton:SetPoint("TOPLEFT", addComment, "TOPRIGHT", 10, 0)
    addButton:SetText("Desable")
    addButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: " .. selectedAddCommand .. " $entry $flag $comment", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    addButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    addButton:SetScript("OnClick", function()
        local entryVal = addEntry:GetText()
        local flagVal = addFlag:GetText()
        local commentVal = addComment:GetText()
        if entryVal == "" or entryVal == "Entry" or flagVal == "" or flagVal == "Flag" or commentVal == "" or commentVal == "Comment" then
            print("Tous les champs sont obligatoires pour Desable Add!")
            return
        end
        local command = "." .. selectedAddCommand .. " " .. entryVal .. " " .. flagVal .. " " .. commentVal
        SendChatMessage(command, "SAY")
        print("Commande envoyée: " .. command)
    end)

    -----------------------------------------------------------------
    -- Section "Desable remove"
    -----------------------------------------------------------------
    local removeSubtitle = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    removeSubtitle:SetPoint("TOPLEFT", addDropdown, "BOTTOMLEFT", 0, -20)
    removeSubtitle:SetText("Desable remove")

    local disableRemoveOptions = {
        "disable remove battleground",
        "disable remove criteria",
        "disable remove map",
        "disable remove mmap",
        "disable remove outdoorpvp",
        "disable remove quest",
        "disable remove spell",
        "disable remove vmap",
    }
    local selectedRemoveCommand = disableRemoveOptions[1]

    local removeDropdown = CreateFrame("Frame", "TrinityDisableRemoveDropdown", commandsFramePage1, "UIDropDownMenuTemplate")
    removeDropdown:SetPoint("TOPLEFT", removeSubtitle, "BOTTOMLEFT", 0, -10)
    UIDropDownMenu_SetWidth(removeDropdown, 150)
    UIDropDownMenu_Initialize(removeDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, cmd in ipairs(disableRemoveOptions) do
            info.text = cmd
            info.value = cmd
            info.checked = (cmd == selectedRemoveCommand)
            info.func = function(self)
                selectedRemoveCommand = self.value
                UIDropDownMenu_SetSelectedValue(removeDropdown, self.value)
                UIDropDownMenu_Initialize(removeDropdown, self:GetParent().initFunc)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedValue(removeDropdown, selectedRemoveCommand)


    local removeEntry = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
    removeEntry:SetSize(100, 22)
    removeEntry:SetPoint("TOPLEFT", removeDropdown, "TOPRIGHT", 10, 0)
    removeEntry:SetAutoFocus(false)
    removeEntry:SetText("Entry")

    local removeButton = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
    removeButton:SetSize(120, 22)
    removeButton:SetPoint("TOPLEFT", removeEntry, "TOPRIGHT", 10, 0)
    removeButton:SetText("Remove Desable")
    removeButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: " .. selectedRemoveCommand .. " $entry", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    removeButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    removeButton:SetScript("OnClick", function()
        local entryVal = removeEntry:GetText()
        if entryVal == "" or entryVal == "Entry" then
            print("Le champ Entry est obligatoire pour Desable remove!")
            return
        end
        local command = "." .. selectedRemoveCommand .. " " .. entryVal
        SendChatMessage(command, "SAY")
        print("Commande envoyée: " .. command)
    end)
	
	
	--------------------------------
	-- Pour la page 2 :
	--------------------------------
	local commandsFramePage2 = CreateFrame("Frame", nil, pages[2])
	commandsFramePage2:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
	commandsFramePage2:SetSize(500, 350)
	
	local page2Title = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page2Title:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, 0)
	page2Title:SetText("Cast and Mmaps Functions")
		-- Ici, vous ajoutez les boutons pour la page 2
	
	-----------------------------------------------------------
	-- Section "Cast Commands"
	-----------------------------------------------------------
	local castSubtitle = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castSubtitle:SetPoint("TOPLEFT", page2Title, "BOTTOMLEFT", 0, -20)
	castSubtitle:SetText("Cast Commands")
	
	local castOptions = {
		"cast back",
		"cast dest",
		"cast dist",
		"cast self",
		"cast target",
	}
	local selectedCastOption = castOptions[1]
	
	local castDropdown = CreateFrame("Frame", "TrinityCastDropdown", commandsFramePage2, "UIDropDownMenuTemplate")
	castDropdown:SetPoint("TOPLEFT", castSubtitle, "BOTTOMLEFT", 0, -10)
	UIDropDownMenu_SetWidth(castDropdown, 150)
	UIDropDownMenu_Initialize(castDropdown, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		for i, option in ipairs(castOptions) do
			info.text = option
			info.value = option
			info.checked = (option == selectedCastOption)
			info.func = function(self)
				selectedCastOption = self.value
				UIDropDownMenu_SetSelectedValue(castDropdown, self.value)
				-- Cachez tous les cadres et affichez celui correspondant
				castBackFrame:Hide()
				castDestFrame:Hide()
				castDistFrame:Hide()
				castSelfFrame:Hide()
				castTargetFrame:Hide()
				if selectedCastOption == "cast back" then
					castBackFrame:Show()
				elseif selectedCastOption == "cast dest" then
					castDestFrame:Show()
				elseif selectedCastOption == "cast dist" then
					castDistFrame:Show()
				elseif selectedCastOption == "cast self" then
					castSelfFrame:Show()
				elseif selectedCastOption == "cast target" then
					castTargetFrame:Show()
				end
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	UIDropDownMenu_SetSelectedValue(castDropdown, selectedCastOption)
	
	-- Conteneur pour les différentes interfaces de cast
	local castContainer = CreateFrame("Frame", "TrinityCastContainer", commandsFramePage2)
	castContainer:SetPoint("TOPLEFT", castDropdown, "BOTTOMLEFT", 0, -10)
	castContainer:SetSize(400, 120)
	
	-------------------------------
	-- Interface pour "cast back"
	-------------------------------
	local castBackFrame = CreateFrame("Frame", "TrinityCastBackFrame", castContainer)
	castBackFrame:SetAllPoints(castContainer)
	-- Champ Spell ID
	local castBackSpellID = CreateFrame("EditBox", nil, castBackFrame, "InputBoxTemplate")
	castBackSpellID:SetSize(100, 22)
	castBackSpellID:SetPoint("TOPLEFT", castBackFrame, "TOPLEFT", 0, 0)
	castBackSpellID:SetAutoFocus(false)
	castBackSpellID:SetText("Spell ID")
	-- Case à cocher Triggered
	local castBackTriggered = CreateFrame("CheckButton", nil, castBackFrame, "UICheckButtonTemplate")
	castBackTriggered:SetPoint("TOPLEFT", castBackSpellID, "BOTTOMLEFT", 0, -5)
	local castBackTriggeredLabel = castBackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castBackTriggeredLabel:SetPoint("LEFT", castBackTriggered, "RIGHT", 5, 0)
	castBackTriggeredLabel:SetText("Triggered")
	-- Bouton Cast
	local castBackButton = CreateFrame("Button", nil, castBackFrame, "UIPanelButtonTemplate")
	castBackButton:SetSize(100, 22)
	castBackButton:SetPoint("TOPLEFT", castBackTriggered, "BOTTOMLEFT", 0, -10)
	castBackButton:SetText("Cast")
	castBackButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Selected target will cast #spellid to your character. If 'triggered' or part provided then spell casted with triggered flag.", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	castBackButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	castBackButton:SetScript("OnClick", function()
		local spellID = castBackSpellID:GetText()
		if spellID == "" or spellID == "Spell ID" then
			print("Le champ Spell ID est obligatoire!")
			return
		end
		local cmd = ".cast back " .. spellID
		if castBackTriggered:GetChecked() then
			cmd = cmd .. " triggered"
		end
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)
	
	-------------------------------
	-- Interface pour "cast dest"
	-------------------------------
	local castDestFrame = CreateFrame("Frame", "TrinityCastDestFrame", castContainer)
	castDestFrame:SetAllPoints(castContainer)
	castDestFrame:Hide()
	local castDestSpellID = CreateFrame("EditBox", nil, castDestFrame, "InputBoxTemplate")
	castDestSpellID:SetSize(100, 22)
	castDestSpellID:SetPoint("TOPLEFT", castDestFrame, "TOPLEFT", 0, 0)
	castDestSpellID:SetAutoFocus(false)
	castDestSpellID:SetText("Spell ID")
	local castDestX = CreateFrame("EditBox", nil, castDestFrame, "InputBoxTemplate")
	castDestX:SetSize(50, 22)
	castDestX:SetPoint("TOPLEFT", castDestSpellID, "TOPRIGHT", 10, 0)
	castDestX:SetAutoFocus(false)
	castDestX:SetText("X")
	local castDestY = CreateFrame("EditBox", nil, castDestFrame, "InputBoxTemplate")
	castDestY:SetSize(50, 22)
	castDestY:SetPoint("TOPLEFT", castDestX, "TOPRIGHT", 10, 0)
	castDestY:SetAutoFocus(false)
	castDestY:SetText("Y")
	local castDestZ = CreateFrame("EditBox", nil, castDestFrame, "InputBoxTemplate")
	castDestZ:SetSize(50, 22)
	castDestZ:SetPoint("TOPLEFT", castDestY, "TOPRIGHT", 10, 0)
	castDestZ:SetAutoFocus(false)
	castDestZ:SetText("Z")
	local castDestTriggered = CreateFrame("CheckButton", nil, castDestFrame, "UICheckButtonTemplate")
	castDestTriggered:SetPoint("TOPLEFT", castDestSpellID, "BOTTOMLEFT", 0, -5)
	local castDestTriggeredLabel = castDestFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castDestTriggeredLabel:SetPoint("LEFT", castDestTriggered, "RIGHT", 5, 0)
	castDestTriggeredLabel:SetText("Triggered")
	local castDestButton = CreateFrame("Button", nil, castDestFrame, "UIPanelButtonTemplate")
	castDestButton:SetSize(100, 22)
	castDestButton:SetPoint("TOPLEFT", castDestTriggered, "BOTTOMLEFT", 0, -10)
	castDestButton:SetText("Cast")
	castDestButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Selected target will cast #spellid at provided destination. If 'triggered' or part provided then spell casted with triggered flag.", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	castDestButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	castDestButton:SetScript("OnClick", function()
		local spellID = castDestSpellID:GetText()
		local x = castDestX:GetText()
		local y = castDestY:GetText()
		local z = castDestZ:GetText()
		if spellID == "" or spellID == "Spell ID" or x == "" or x == "X" or y == "" or y == "Y" or z == "" or z == "Z" then
			print("Tous les champs sont obligatoires pour cast dest!")
			return
		end
		local cmd = ".cast dest " .. spellID .. " " .. x .. " " .. y .. " " .. z
		if castDestTriggered:GetChecked() then
			cmd = cmd .. " triggered"
		end
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)
	
	-------------------------------
	-- Interface pour "cast dist"
	-------------------------------
	local castDistFrame = CreateFrame("Frame", "TrinityCastDistFrame", castContainer)
	castDistFrame:SetAllPoints(castContainer)
	castDistFrame:Hide()
	local castDistValue = CreateFrame("EditBox", nil, castDistFrame, "InputBoxTemplate")
	castDistValue:SetSize(100, 22)
	castDistValue:SetPoint("TOPLEFT", castDistFrame, "TOPLEFT", 0, 0)
	castDistValue:SetAutoFocus(false)
	castDistValue:SetText("Dist")
	local castDistTriggered = CreateFrame("CheckButton", nil, castDistFrame, "UICheckButtonTemplate")
	castDistTriggered:SetPoint("TOPLEFT", castDistValue, "BOTTOMLEFT", 0, -5)
	local castDistTriggeredLabel = castDistFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castDistTriggeredLabel:SetPoint("LEFT", castDistTriggered, "RIGHT", 5, 0)
	castDistTriggeredLabel:SetText("Triggered")
	local castDistButton = CreateFrame("Button", nil, castDistFrame, "UIPanelButtonTemplate")
	castDistButton:SetSize(100, 22)
	castDistButton:SetPoint("TOPLEFT", castDistTriggered, "BOTTOMLEFT", 0, -10)
	castDistButton:SetText("Cast")
	castDistButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("You will cast spell to pint at distance #dist. If 'triggered' or part provided then spell casted with triggered flag. Not all spells can be casted as area spells.", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	castDistButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	castDistButton:SetScript("OnClick", function()
		local dist = castDistValue:GetText()
		if dist == "" or dist == "Dist" then
			print("Le champ Dist est obligatoire pour cast dist!")
			return
		end
		local cmd = ".cast dist " .. dist
		if castDistTriggered:GetChecked() then
			cmd = cmd .. " triggered"
		end
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)
	
	-------------------------------
	-- Interface pour "cast self"
	-------------------------------
	local castSelfFrame = CreateFrame("Frame", "TrinityCastSelfFrame", castContainer)
	castSelfFrame:SetAllPoints(castContainer)
	castSelfFrame:Hide()
	local castSelfSpellID = CreateFrame("EditBox", nil, castSelfFrame, "InputBoxTemplate")
	castSelfSpellID:SetSize(100, 22)
	castSelfSpellID:SetPoint("TOPLEFT", castSelfFrame, "TOPLEFT", 0, 0)
	castSelfSpellID:SetAutoFocus(false)
	castSelfSpellID:SetText("Spell ID")
	local castSelfTriggered = CreateFrame("CheckButton", nil, castSelfFrame, "UICheckButtonTemplate")
	castSelfTriggered:SetPoint("TOPLEFT", castSelfSpellID, "BOTTOMLEFT", 0, -5)
	local castSelfTriggeredLabel = castSelfFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castSelfTriggeredLabel:SetPoint("LEFT", castSelfTriggered, "RIGHT", 5, 0)
	castSelfTriggeredLabel:SetText("Triggered")
	local castSelfButton = CreateFrame("Button", nil, castSelfFrame, "UIPanelButtonTemplate")
	castSelfButton:SetSize(100, 22)
	castSelfButton:SetPoint("TOPLEFT", castSelfTriggered, "BOTTOMLEFT", 0, -10)
	castSelfButton:SetText("Cast")
	castSelfButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Cast #spellid by target at target itself. If 'triggered' or part provided then spell casted with triggered flag.", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	castSelfButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	castSelfButton:SetScript("OnClick", function()
		local spellID = castSelfSpellID:GetText()
		if spellID == "" or spellID == "Spell ID" then
			print("Le champ Spell ID est obligatoire pour cast self!")
			return
		end
		local cmd = ".cast self " .. spellID
		if castSelfTriggered:GetChecked() then
			cmd = cmd .. " triggered"
		end
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)
	
	-------------------------------
	-- Interface pour "cast target"
	-------------------------------
	local castTargetFrame = CreateFrame("Frame", "TrinityCastTargetFrame", castContainer)
	castTargetFrame:SetAllPoints(castContainer)
	castTargetFrame:Hide()
	local castTargetSpellID = CreateFrame("EditBox", nil, castTargetFrame, "InputBoxTemplate")
	castTargetSpellID:SetSize(100, 22)
	castTargetSpellID:SetPoint("TOPLEFT", castTargetFrame, "TOPLEFT", 0, 0)
	castTargetSpellID:SetAutoFocus(false)
	castTargetSpellID:SetText("Spell ID")
	local castTargetTriggered = CreateFrame("CheckButton", nil, castTargetFrame, "UICheckButtonTemplate")
	castTargetTriggered:SetPoint("TOPLEFT", castTargetSpellID, "BOTTOMLEFT", 0, -5)
	local castTargetTriggeredLabel = castTargetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castTargetTriggeredLabel:SetPoint("LEFT", castTargetTriggered, "RIGHT", 5, 0)
	castTargetTriggeredLabel:SetText("Triggered")
	local castTargetButton = CreateFrame("Button", nil, castTargetFrame, "UIPanelButtonTemplate")
	castTargetButton:SetSize(100, 22)
	castTargetButton:SetPoint("TOPLEFT", castTargetTriggered, "BOTTOMLEFT", 0, -10)
	castTargetButton:SetText("Cast")
	castTargetButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Syntax: .cast target #spellid [triggered]\r\n  Selected target will cast #spellid to his victim. If 'triggered' or part provided then spell casted with triggered flag.", 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	castTargetButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	castTargetButton:SetScript("OnClick", function()
		local spellID = castTargetSpellID:GetText()
		if spellID == "" or spellID == "Spell ID" then
			print("Le champ Spell ID est obligatoire pour cast target!")
			return
		end
		local cmd = ".cast target " .. spellID
		if castTargetTriggered:GetChecked() then
			cmd = cmd .. " triggered"
		end
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)
	
	-----------------------------------------------------------
	-- Section "Mmaps Functions" positionnée à droite de "Cast Commands"
	-----------------------------------------------------------
	local mmapsSubtitle = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	-- On ancre la section "Mmaps Functions" à droite du conteneur des cast commands (castContainer)
	mmapsSubtitle:SetPoint("TOPLEFT", castContainer, "TOPRIGHT", -100, 62)
	mmapsSubtitle:SetText("Mmaps Functions")
	
	local mmapsOptions = {
		"mmap loadedtiles",
		"mmap loc",
		"mmap path",
		"mmap stats",
		"mmap testarea",
	}
	local selectedMmapsOption = mmapsOptions[1]
	
	local mmapsDropdown = CreateFrame("Frame", "TrinityMmapsDropdown", commandsFramePage2, "UIDropDownMenuTemplate")
	-- On ancre le dropdown sous le titre mmapsSubtitle
	mmapsDropdown:SetPoint("TOPLEFT", mmapsSubtitle, "BOTTOMLEFT", 0, -10)
	UIDropDownMenu_SetWidth(mmapsDropdown, 150)
	UIDropDownMenu_Initialize(mmapsDropdown, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		for i, option in ipairs(mmapsOptions) do
			info.text = option
			info.value = option
			info.checked = (option == selectedMmapsOption)
			info.func = function(self)
				selectedMmapsOption = self.value
				UIDropDownMenu_SetSelectedValue(mmapsDropdown, self.value)
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	UIDropDownMenu_SetSelectedValue(mmapsDropdown, selectedMmapsOption)
	
	local mmapsButton = CreateFrame("Button", nil, commandsFramePage2, "UIPanelButtonTemplate")
	mmapsButton:SetSize(100, 22)
	-- On ancre le bouton à droite du dropdown
	mmapsButton:SetPoint("TOPLEFT", mmapsDropdown, "TOPRIGHT", 10, 0)
	mmapsButton:SetText("Execute")
	mmapsButton:SetScript("OnEnter", function(self)
		local tooltipText = ""
		if selectedMmapsOption == "mmap loadedtiles" then
			tooltipText = "Show which tiles are currently loaded."
		elseif selectedMmapsOption == "mmap loc" then
			tooltipText = "Print on which tile one is."
		elseif selectedMmapsOption == "mmap path" then
			tooltipText = "Calculate and show a path to current select unit."
		elseif selectedMmapsOption == "mmap stats" then
			tooltipText = "Show information about current state of mmaps."
		elseif selectedMmapsOption == "mmap testarea" then
			tooltipText = "Calculate paths for all nearby npcs to player."
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	mmapsButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	mmapsButton:SetScript("OnClick", function()
		local cmd = "." .. selectedMmapsOption
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)
	
local AceGUI = LibStub("AceGUI-3.0")
local mmapsPopupFrame = nil
local mmapsPopupText = ""

local function ShowMmapsPopup(message)
    -- Ajoute le nouveau message au texte existant (avec un saut de ligne)
    mmapsPopupText = mmapsPopupText .. "\n" .. message
    if not mmapsPopupFrame then
        mmapsPopupFrame = AceGUI:Create("Frame")
        mmapsPopupFrame:SetTitle("Mmaps Response")
        mmapsPopupFrame:SetLayout("Flow")
        mmapsPopupFrame:SetWidth(300)
        mmapsPopupFrame:SetHeight(200)
        -- Positionnement à droite de l'écran
        mmapsPopupFrame.frame:SetPoint("RIGHT", UIParent, "RIGHT", -50, 0)
        mmapsPopupFrame:EnableResize(false)
        -- Quand l'utilisateur ferme la fenêtre, réinitialiser la variable
        mmapsPopupFrame:SetCallback("OnClose", function(widget)
            mmapsPopupFrame = nil
            mmapsPopupText = ""
        end)
		mmapsPopupFrame:EnableResize(true)
		mmapsPopupFrame:SetCallback("OnResize", function(widget, width, height)
			widget.multiLine:SetWidth(width - 20)
			widget.multiLine:SetHeight(height - 40)
		end)
        local multiLine = AceGUI:Create("MultiLineEditBox")
        multiLine:SetLabel("")
        multiLine:SetFullWidth(true)
        multiLine:SetFullHeight(true)
        multiLine:SetText(mmapsPopupText)
        multiLine:SetFocus()
        multiLine:DisableButton(true)
        mmapsPopupFrame:AddChild(multiLine)
        mmapsPopupFrame.multiLine = multiLine
    else
        mmapsPopupFrame.multiLine:SetText(mmapsPopupText)
    end
end

local mmapsInterceptor = CreateFrame("Frame")
mmapsInterceptor:RegisterEvent("CHAT_MSG_SYSTEM")
mmapsInterceptor:SetScript("OnEvent", function(self, event, msg)
    if event == "CHAT_MSG_SYSTEM" then
        ShowMmapsPopup(msg)
    end
end)
	--------------------------------
	-- Pour la page 3 :
	--------------------------------
	local commandsFramePage3 = CreateFrame("Frame", nil, pages[3])
	commandsFramePage3:SetPoint("TOPLEFT", pages[3], "TOPLEFT", 20, -40)
	commandsFramePage3:SetSize(500, 350)
	
	local page3Title = commandsFramePage3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page3Title:SetPoint("TOPLEFT", commandsFramePage3, "TOPLEFT", 0, 0)
	page3Title:SetText("Cast Commands")
		-- Ici, vous ajoutez les boutons pour la page 2
		
------------------------------------------------------------------------------
-- Bouton helper pour créer des boutons simples (comme précédemment)
------------------------------------------------------------------------------
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

    ------------------------------------------------------------------------------
    -- Fin du panneau, bouton Back déjà présent
    ------------------------------------------------------------------------------
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
