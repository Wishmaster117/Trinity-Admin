local L = _G.L
local TrinityAdmin = LibStub("AceAddon-3.0"):GetAddon("TrinityAdmin")
local Others = TrinityAdmin:GetModule("Others")
local L = LibStub("AceLocale-3.0"):GetLocale("TrinityAdmin")

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
	panel.title:SetText(L["Other Stuffs"])

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
	btnPrev:SetText(L["Pagination_Preview"])
	TrinityAdmin.AutoSize(btnPrev, 20, 16)
	btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
	btnPrev:SetScript("OnClick", function()
		if currentPage > 1 then
			ShowPage(currentPage - 1)
		end
	end)
	
	btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnNext:SetText(L["Next"])
	TrinityAdmin.AutoSize(btnNext, 20, 16)
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
	page1Title:SetText(L["Desable Functions"])
    -----------------------------------------------------------------
    -- Section "Desable Add"
    -----------------------------------------------------------------
    local addSubtitle = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addSubtitle:SetPoint("TOPLEFT", page1Title, "BOTTOMLEFT", 0, -20)
    addSubtitle:SetText(L["Desable Add"])

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
    addEntry:SetPoint("TOPLEFT", addDropdown, "TOPRIGHT", 10, 0)
    addEntry:SetAutoFocus(false)
    addEntry:SetText("Entry")
	TrinityAdmin.AutoSize(addEntry, 20, 13, nil, 100)

    local addFlag = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
    addFlag:SetPoint("TOPLEFT", addEntry, "TOPRIGHT", 10, 0)
    addFlag:SetAutoFocus(false)
    addFlag:SetText("Flag")
	TrinityAdmin.AutoSize(addFlag, 20, 13, nil, 100)

    local addComment = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
    addComment:SetPoint("TOPLEFT", addFlag, "TOPRIGHT", 10, 0)
    addComment:SetAutoFocus(false)
    addComment:SetText("Comment")
	TrinityAdmin.AutoSize(addComment, 20, 13, nil, 100)

    local addButton = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
    addButton:SetPoint("TOPLEFT", addComment, "TOPRIGHT", 10, 0)
    addButton:SetText("Desable")
	TrinityAdmin.AutoSize(addButton, 20, 16)
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
            TrinityAdmin:Print(LL["Error_All_fields_required"])
            return
        end
        local command = "." .. selectedAddCommand .. " " .. entryVal .. " " .. flagVal .. " " .. commentVal
        TrinityAdmin:SendCommand(command)
        -- TrinityAdmin:Print("Commande envoyée: " .. command)
    end)

    -----------------------------------------------------------------
    -- Section "Desable remove"
    -----------------------------------------------------------------
    local removeSubtitle = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    removeSubtitle:SetPoint("TOPLEFT", addDropdown, "BOTTOMLEFT", 0, -20)
    removeSubtitle:SetText(L["Desable remove"])

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
    removeEntry:SetPoint("TOPLEFT", removeDropdown, "TOPRIGHT", 10, 0)
    removeEntry:SetAutoFocus(false)
    removeEntry:SetText("Entry")
	TrinityAdmin.AutoSize(removeEntry, 20, 13, nil, 120)

    local removeButton = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
    removeButton:SetPoint("TOPLEFT", removeEntry, "TOPRIGHT", 10, 0)
    removeButton:SetText("Remove Desable")
	TrinityAdmin.AutoSize(removeButton, 20, 16)
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
            TrinityAdmin:Print(L["Error_entry_required"])
            return
        end
        local command = "." .. selectedRemoveCommand .. " " .. entryVal
        TrinityAdmin:SendCommand(command)
        -- TrinityAdmin:Print("Commande envoyée: " .. command)
    end)
	
	
	--------------------------------
	-- Pour la page 2 :
	--------------------------------
	local commandsFramePage2 = CreateFrame("Frame", nil, pages[2])
	commandsFramePage2:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
	commandsFramePage2:SetSize(500, 350)
	
	local page2Title = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page2Title:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, 0)
	page2Title:SetText(L["Cast and Mmaps Functions"])
		-- Ici, vous ajoutez les boutons pour la page 2
	
	-----------------------------------------------------------
	-- 1  SECTION « CAST COMMANDS »
	-----------------------------------------------------------
	local castSubtitle = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castSubtitle:SetPoint("TOPLEFT", page2Title, "BOTTOMLEFT", 0, -20)
	castSubtitle:SetText(L["Cast Commands"])
	
	local castOptions = { "cast back", "cast dest", "cast dist", "cast self", "cast target" }
	local selectedCastOption = castOptions[1]
	
	-- Conteneur + cinq sous-interfaces (créés AVANT le dropdown)
	local castContainer = CreateFrame("Frame", "TrinityCastContainer", commandsFramePage2)
	castContainer:SetPoint("TOPLEFT", castSubtitle, "BOTTOMLEFT", 0, -40)
	castContainer:SetSize(400, 120)
	
	-------------------------------------------------
	-- castBackFrame  (SpellID + triggered)
	-------------------------------------------------
	local castBackFrame = CreateFrame("Frame", nil, castContainer); castBackFrame:SetAllPoints()
	local castBackSpellID  = CreateFrame("EditBox", nil, castBackFrame, "InputBoxTemplate")
	castBackSpellID:SetPoint("TOPLEFT", 0, -10)
	castBackSpellID:SetAutoFocus(false); castBackSpellID:SetText(L["SpellID1"])
	TrinityAdmin.AutoSize(castBackSpellID, 20, 13, nil, 120)
	local castBackTrig     = CreateFrame("CheckButton", nil, castBackFrame, "UICheckButtonTemplate")
	castBackTrig:SetPoint("TOPLEFT", castBackSpellID, "BOTTOMLEFT", 0, -5)
	local castBackTrigLbl  = castBackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castBackTrigLbl:SetPoint("LEFT", castBackTrig, "RIGHT", 5, 0)
	castBackTrigLbl:SetText("Triggered")
	local castBackBtn = CreateFrame("Button", nil, castBackFrame, "UIPanelButtonTemplate")
	castBackBtn:SetPoint("TOPLEFT", castBackTrig, "BOTTOMLEFT", 0, -10)
	castBackBtn:SetText(L["Cast"]); TrinityAdmin.AutoSize(castBackBtn, 20, 16)
	castBackBtn:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetText(L["castbacktooltip"],1,1,1,1,true) end)
	castBackBtn:SetScript("OnLeave", GameTooltip_Hide)
	castBackBtn:SetScript("OnClick", function()
	local id = castBackSpellID:GetText()
	if id=="" or id==L["SpellID1"] then TrinityAdmin:Print(L["error_spell_requires"]); return end
	local cmd = ".cast back "..id..(castBackTrig:GetChecked() and " triggered" or "")
	TrinityAdmin:SendCommand(cmd)
	end)
	
	-------------------------------------------------
	-- castDestFrame  (SpellID  +  X Y Z  + triggered)
	-------------------------------------------------
	local castDestFrame = CreateFrame("Frame", nil, castContainer); castDestFrame:SetAllPoints(); castDestFrame:Hide()
	local castDestSpellID = CreateFrame("EditBox", nil, castDestFrame, "InputBoxTemplate")
	castDestSpellID:SetPoint("TOPLEFT", 0, -10); castDestSpellID:SetAutoFocus(false); castDestSpellID:SetText("Spell ID")
	TrinityAdmin.AutoSize(castDestSpellID, 20, 13, nil, 70)
	local castDestX = CreateFrame("EditBox", nil, castDestFrame, "InputBoxTemplate")
	castDestX:SetPoint("LEFT", castDestSpellID, "RIGHT", 10, 0); castDestX:SetText("X")
	TrinityAdmin.AutoSize(castDestX, 20, 13, nil, 80)
	local castDestY = CreateFrame("EditBox", nil, castDestFrame, "InputBoxTemplate")
	castDestY:SetPoint("LEFT", castDestX, "RIGHT", 10, 0); castDestY:SetText("Y")
	TrinityAdmin.AutoSize(castDestY, 20, 13, nil, 80)
	local castDestZ = CreateFrame("EditBox", nil, castDestFrame, "InputBoxTemplate")
	castDestZ:SetPoint("LEFT", castDestY, "RIGHT", 10, 0); castDestZ:SetText("Z")
	TrinityAdmin.AutoSize(castDestZ, 20, 13, nil, 80)
	local castDestTrig = CreateFrame("CheckButton", nil, castDestFrame, "UICheckButtonTemplate")
	castDestTrig:SetPoint("TOPLEFT", castDestSpellID, "BOTTOMLEFT", 0, -5)
	local castDestTrigLbl = castDestFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castDestTrigLbl:SetPoint("LEFT", castDestTrig, "RIGHT", 5, 0); castDestTrigLbl:SetText("Triggered")
	local castDestBtn = CreateFrame("Button", nil, castDestFrame, "UIPanelButtonTemplate")
	castDestBtn:SetPoint("TOPLEFT", castDestTrig, "BOTTOMLEFT", 0, -10)
	castDestBtn:SetText(L["Cast"]); TrinityAdmin.AutoSize(castDestBtn, 20, 16)
	castDestBtn:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetText(L["castdesttooltip"],1,1,1,1,true) end)
	castDestBtn:SetScript("OnLeave", GameTooltip_Hide)
	castDestBtn:SetScript("OnClick", function()
	local id,x,y,z = castDestSpellID:GetText(), castDestX:GetText(), castDestY:GetText(), castDestZ:GetText()
	if id=="" or id=="Spell ID" or x=="" or x=="X" or y=="" or y=="Y" or z=="" or z=="Z" then TrinityAdmin:Print(L["castdesterror"]); return end
	local cmd = ".cast dest "..id.." "..x.." "..y.." "..z..(castDestTrig:GetChecked() and " triggered" or "")
	TrinityAdmin:SendCommand(cmd)
	end)
	
	-------------------------------------------------
	-- castDistFrame
	-------------------------------------------------
	local castDistFrame = CreateFrame("Frame", nil, castContainer); castDistFrame:SetAllPoints(); castDistFrame:Hide()
	local castDistVal = CreateFrame("EditBox", nil, castDistFrame, "InputBoxTemplate")
	castDistVal:SetPoint("TOPLEFT", 0, -10); castDistVal:SetAutoFocus(false); castDistVal:SetText("Dist")
	TrinityAdmin.AutoSize(castDistVal, 20, 13, nil, 100)
	local castDistTrig = CreateFrame("CheckButton", nil, castDistFrame, "UICheckButtonTemplate")
	castDistTrig:SetPoint("TOPLEFT", castDistVal, "BOTTOMLEFT", 0, -5)
	local castDistTrigLbl = castDistFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castDistTrigLbl:SetPoint("LEFT", castDistTrig, "RIGHT", 5, 0); castDistTrigLbl:SetText("Triggered")
	local castDistBtn = CreateFrame("Button", nil, castDistFrame, "UIPanelButtonTemplate")
	castDistBtn:SetPoint("TOPLEFT", castDistTrig, "BOTTOMLEFT", 0, -10)
	castDistBtn:SetText(L["Cast"]); TrinityAdmin.AutoSize(castDistBtn, 20, 16)
	castDistBtn:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetText(L["castdisttooltip"],1,1,1,1,true) end)
	castDistBtn:SetScript("OnLeave", GameTooltip_Hide)
	castDistBtn:SetScript("OnClick", function()
	local dist = castDistVal:GetText()
	if dist=="" or dist=="Dist" then TrinityAdmin:Print(L["castdisterror"]); return end
	local cmd = ".cast dist "..dist..(castDistTrig:GetChecked() and " triggered" or "")
	TrinityAdmin:SendCommand(cmd)
	end)
	
	-------------------------------------------------
	-- castSelfFrame
	-------------------------------------------------
	local castSelfFrame = CreateFrame("Frame", nil, castContainer); castSelfFrame:SetAllPoints(); castSelfFrame:Hide()
	local castSelfID = CreateFrame("EditBox", nil, castSelfFrame, "InputBoxTemplate")
	castSelfID:SetPoint("TOPLEFT", 0, -10); castSelfID:SetAutoFocus(false); castSelfID:SetText("Spell ID")
	TrinityAdmin.AutoSize(castSelfID, 20, 13, nil, 100)
	local castSelfTrig = CreateFrame("CheckButton", nil, castSelfFrame, "UICheckButtonTemplate")
	castSelfTrig:SetPoint("TOPLEFT", castSelfID, "BOTTOMLEFT", 0, -5)
	local castSelfTrigLbl = castSelfFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castSelfTrigLbl:SetPoint("LEFT", castSelfTrig, "RIGHT", 5, 0); castSelfTrigLbl:SetText("Triggered")
	local castSelfBtn = CreateFrame("Button", nil, castSelfFrame, "UIPanelButtonTemplate")
	castSelfBtn:SetPoint("TOPLEFT", castSelfTrig, "BOTTOMLEFT", 0, -10)
	castSelfBtn:SetText(L["Cast"]); TrinityAdmin.AutoSize(castSelfBtn, 20, 16)
	castSelfBtn:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetText(L["castselftooltip"],1,1,1,1,true) end)
	castSelfBtn:SetScript("OnLeave", GameTooltip_Hide)
	castSelfBtn:SetScript("OnClick", function()
	local id = castSelfID:GetText()
	if id=="" or id=="Spell ID" then TrinityAdmin:Print(L["castselferror"]); return end
	local cmd = ".cast self "..id..(castSelfTrig:GetChecked() and " triggered" or "")
	TrinityAdmin:SendCommand(cmd)
	end)
	
	-------------------------------------------------
	-- castTargetFrame
	-------------------------------------------------
	local castTargetFrame = CreateFrame("Frame", nil, castContainer); castTargetFrame:SetAllPoints(); castTargetFrame:Hide()
	local castTargetID = CreateFrame("EditBox", nil, castTargetFrame, "InputBoxTemplate")
	castTargetID:SetPoint("TOPLEFT", 0, -10); castTargetID:SetAutoFocus(false); castTargetID:SetText("Spell ID")
	TrinityAdmin.AutoSize(castTargetID, 20, 13, nil, 100)
	local castTargetTrig = CreateFrame("CheckButton", nil, castTargetFrame, "UICheckButtonTemplate")
	castTargetTrig:SetPoint("TOPLEFT", castTargetID, "BOTTOMLEFT", 0, -5)
	local castTargetTrigLbl = castTargetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	castTargetTrigLbl:SetPoint("LEFT", castTargetTrig, "RIGHT", 5, 0); castTargetTrigLbl:SetText("Triggered")
	local castTargetBtn = CreateFrame("Button", nil, castTargetFrame, "UIPanelButtonTemplate")
	castTargetBtn:SetPoint("TOPLEFT", castTargetTrig, "BOTTOMLEFT", 0, -10)
	castTargetBtn:SetText(L["Cast"]); TrinityAdmin.AutoSize(castTargetBtn, 20, 16)
	castTargetBtn:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetText(L["casttargettooltip"],1,1,1,1,true) end)
	castTargetBtn:SetScript("OnLeave", GameTooltip_Hide)
	castTargetBtn:SetScript("OnClick", function()
	local id = castTargetID:GetText()
	if id=="" or id=="Spell ID" then TrinityAdmin:Print(L["casttargererror"]); return end
	local cmd = ".cast target "..id..(castTargetTrig:GetChecked() and " triggered" or "")
	TrinityAdmin:SendCommand(cmd)
	end)
	
	-------------------------------------------------
	-- Helper pour (dé)masquer la bonne interface
	-------------------------------------------------
	local function ShowCastFrame(which)
		if castBackFrame then castBackFrame:Hide() end
		if castDestFrame then castDestFrame:Hide() end
		if castDistFrame then castDistFrame:Hide() end
		if castSelfFrame then castSelfFrame:Hide() end
		if castTargetFrame then castTargetFrame:Hide() end
	
		if which == "cast back"   then castBackFrame:Show()
		elseif which == "cast dest"   then castDestFrame:Show()
		elseif which == "cast dist"   then castDistFrame:Show()
		elseif which == "cast self"   then castSelfFrame:Show()
		elseif which == "cast target" then castTargetFrame:Show()
		end
	end
	
	--  Dropdown (créé APRÈS les frames)
	local castDropdown = CreateFrame("Frame", "TrinityCastDropdown", commandsFramePage2, "UIDropDownMenuTemplate")
	castDropdown:SetPoint("TOPLEFT", castSubtitle, "BOTTOMLEFT", 0, -10)
	UIDropDownMenu_SetWidth(castDropdown, 150)
	UIDropDownMenu_Initialize(castDropdown, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		for _, option in ipairs(castOptions) do
			info.text = option
			info.value = option
			info.checked = (option == selectedCastOption)
			info.func = function(self)
				selectedCastOption = self.value
				UIDropDownMenu_SetSelectedValue(castDropdown, self.value)
				ShowCastFrame(selectedCastOption)
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	UIDropDownMenu_SetSelectedValue(castDropdown, selectedCastOption)
	
	-- Afficher l’interface par défaut au chargement
	ShowCastFrame(selectedCastOption)

	-----------------------------------------------------------
	-- Section "Mmaps Functions" positionnée à droite de "Cast Commands"
	-----------------------------------------------------------
	local mmapsSubtitle = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	-- On ancre la section "Mmaps Functions" à droite du conteneur des cast commands (castContainer)
	mmapsSubtitle:SetPoint("TOPLEFT", castContainer, "TOPRIGHT", -100, 62)
	mmapsSubtitle:SetText(L["Mmaps Functions"])
	
	local mmapsListening = false
	
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
	-- On ancre le bouton à droite du dropdown
	mmapsButton:SetPoint("TOPLEFT", mmapsDropdown, "TOPRIGHT", 10, 0)
	mmapsButton:SetText(L["Execute3"])
	TrinityAdmin.AutoSize(mmapsButton, 20, 16)
	mmapsButton:SetScript("OnEnter", function(self)
		local tooltipText = ""
		if selectedMmapsOption == "mmap loadedtiles" then
			tooltipText = L["Show which tiles are currently loaded."]
		elseif selectedMmapsOption == "mmap loc" then
			tooltipText = L["Print on which tile one is."]
		elseif selectedMmapsOption == "mmap path" then
			tooltipText = L["Calculate and show a path to current select unit."]
		elseif selectedMmapsOption == "mmap stats" then
			tooltipText = L["Show information about current state of mmaps."]
		elseif selectedMmapsOption == "mmap testarea" then
			tooltipText = L["Calculate paths for all nearby npcs to player."]
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	mmapsButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	mmapsButton:SetScript("OnClick", function()
		local cmd = "." .. selectedMmapsOption
		mmapsListening = true  -- Activer l'écoute uniquement pour cette commande
		mmapsPopupText = ""    -- Réinitialiser le contenu de la popup
		TrinityAdmin:SendCommand(cmd)
		-- TrinityAdmin:Print("Commande envoyée: " .. cmd)
		-- Désactiver l'écoute après 2 secondes
		C_Timer.After(2, function() mmapsListening = false end)
	end)
	
local AceGUI = LibStub("AceGUI-3.0")
local mmapsPopupFrame = nil
local mmapsPopupText = ""

local function ShowMmapsPopup(message)
    -- Ajoute le nouveau message au texte existant (avec un saut de ligne)
    mmapsPopupText = mmapsPopupText .. "\n" .. message
    if not mmapsPopupFrame then
        mmapsPopupFrame = AceGUI:Create("Frame")
        mmapsPopupFrame:SetTitle(L["Mmaps Response"])
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
        if mmapsListening then
            ShowMmapsPopup(msg)
        end
    end
end)


    --------------------------------
    -- Page 3 (RBAC)
    --------------------------------
    local commandsFramePage3 = CreateFrame("Frame", nil, pages[3])
    commandsFramePage3:SetPoint("TOPLEFT", pages[3], "TOPLEFT", 20, -40)
    commandsFramePage3:SetSize(500, 350)

    local page3Title = commandsFramePage3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    page3Title:SetPoint("TOPLEFT", commandsFramePage3, "TOPLEFT", 0, 0)
    page3Title:SetText(L["GMs Permission"])

--------------------------------------------------------------------------------
-- Popup RBAC
--------------------------------------------------------------------------------
local function ShowRbacPopup(text)
    local AceGUI = LibStub("AceGUI-3.0")

    ------------------------------------------------------------------ 1) données
    local allLines = {}
    if text and text:find("%S") then
        for line in text:gmatch("[^\r\n]+") do
            table.insert(allLines, line)
        end
    else
        table.insert(allLines, L["No data available."])
    end

    ------------------------------------------------------------------ 2) pagination
    local LINES_PER_PAGE = 30
    local currentPage    = 1
    local totalPages     = math.max(1, math.ceil(#allLines / LINES_PER_PAGE))

    ------------------------------------------------------------------ 3) fenêtre
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["RBAC Permissions"])
    frame:SetStatusText("Here are the RBCA List")
    frame:SetLayout("Flow")                -- empilement vertical
    frame:SetWidth(500)
    frame:SetHeight(440)
    frame.frame:ClearAllPoints()
    frame.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetCallback("OnClose", function(w) AceGUI:Release(w) end)

    ------------------------------------------------------------------ 4) zone liste
    local listHolder = AceGUI:Create("ScrollFrame")
    listHolder:SetLayout("List")
    listHolder:SetFullWidth(true)
    listHolder:SetHeight(340)              -- place libre (≈100 px) pour le footer
    frame:AddChild(listHolder)

    -- ---------------------------------------------------------------- RenderPage
    local function RenderPage(p)
        listHolder:ReleaseChildren()

        local first = (p - 1) * LINES_PER_PAGE + 1
        local last  = math.min(#allLines, p * LINES_PER_PAGE)

		for i = first, last do
			----------------------------------------------------------
			-- 1.  Widget : un EditBox « mono-ligne » non-éditable
			----------------------------------------------------------
			local lineBox = AceGUI:Create("EditBox")
			lineBox:SetLabel("")                -- pas d’étiquette
			lineBox:SetFullWidth(true)
			lineBox:SetText(allLines[i])
			lineBox:DisableButton(true)         -- supprime le petit bouton
		
			-- Empêcher la saisie + police un peu plus grande
			if lineBox.editBox then
				lineBox.editBox:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
				lineBox.editBox:SetFontObject("GameFontHighlight")   -- ou GameFontNormalLarge
				lineBox.editBox:SetTextColor(1, 1, 1)                -- texte blanc
			end
			lineBox:SetHeight(18)               -- hauteur fixe pour l’alignement
		
			----------------------------------------------------------
			-- 2.  Zébrage léger (fond gris 18 %)
			----------------------------------------------------------
			if i % 2 == 0 then
				local tex = lineBox.frame:CreateTexture(nil, "BACKGROUND", nil, -1)
				tex:SetAllPoints()
				tex:SetColorTexture(0, 0, 0, 0.18)
			end
		
			listHolder:AddChild(lineBox)
		end
    end
    RenderPage(currentPage)

    ------------------------------------------------------------------ 5) footer
    local footer = AceGUI:Create("SimpleGroup")
    footer:SetLayout("Flow")
    footer:SetFullWidth(true)
    footer:SetHeight(30)
    frame:AddChild(footer)

    -- Bouton « Précédent »
    local btnPrev = AceGUI:Create("Button")
    btnPrev:SetText(L["Pagination_Preview"])
    btnPrev:SetWidth(120)
    footer:AddChild(btnPrev)

    -- label “Page x / y”
    local pageLabel = AceGUI:Create("Label")
    pageLabel:SetText(string.format("   %s %d / %d   ", L["Page"], currentPage, totalPages))
    pageLabel:SetWidth(80)
    footer:AddChild(pageLabel)

    -- Bouton « Suivant »
    local btnNext = AceGUI:Create("Button")
    btnNext:SetText(L["Next"])
    btnNext:SetWidth(120)
    footer:AddChild(btnNext)

    -- espace
    -- local spacer = AceGUI:Create("Label")
    -- spacer:SetWidth(20); spacer:SetText("")
    -- footer:AddChild(spacer)

    -- Bouton « Copier »
    local btnCopy = AceGUI:Create("Button")
    btnCopy:SetText(L["G_Copy"])
    btnCopy:SetWidth(120)
    footer:AddChild(btnCopy)

    ------------------------------------------------------------------ 6) callbacks
    local function UpdateNav()
        pageLabel:SetText(string.format("   %s %d / %d   ", L["Page"], currentPage, totalPages))
        btnPrev:SetDisabled(currentPage == 1)
        btnNext:SetDisabled(currentPage == totalPages)
    end

    btnPrev:SetCallback("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            RenderPage(currentPage)
            UpdateNav()
        end
    end)

    btnNext:SetCallback("OnClick", function()
        if currentPage < totalPages then
            currentPage = currentPage + 1
            RenderPage(currentPage)
            UpdateNav()
        end
    end)

    btnCopy:SetCallback("OnClick", function()
        local pop = AceGUI:Create("Frame")
        pop:SetTitle(L["Copy RBAC Permissions"])
        pop:SetLayout("Fill")
        pop:SetWidth(600)
        pop:SetHeight(400)
        pop.frame:SetPoint("CENTER")
        pop:SetCallback("OnClose", function(w) AceGUI:Release(w) end)

        local bigEdit = AceGUI:Create("MultiLineEditBox")
        bigEdit:SetLabel("")
        bigEdit:DisableButton(true)
        bigEdit:SetFullWidth(true)
        bigEdit:SetFullHeight(true)
        bigEdit:SetText(text or "")
        pop:AddChild(bigEdit)
    end)

    UpdateNav() -- état initial
end


    --------------------------------------------------------------------------------
    -- Préparatifs pour la capture des messages système et affichage dans une popup Ace3
    -- (IL FAUT déclarer rbacListener ici, avant la création du bouton)
    --------------------------------------------------------------------------------
    local rbacMessages = {}
    local rbacListener = CreateFrame("Frame")
    rbacListener:SetScript("OnEvent", function(self, event, msg, ...)
        tinsert(rbacMessages, msg)
    end)
	
    --------------------------------------------------------------------------------
    -- SECTION 1 : Show rbac Id's List
    --------------------------------------------------------------------------------
    local row1 = CreateFrame("Frame", nil, commandsFramePage3)
    row1:SetPoint("TOPLEFT", page3Title, "BOTTOMLEFT", 0, -20)
    row1:SetSize(500, 30)

    local editRbacID = CreateFrame("EditBox", nil, row1, "InputBoxTemplate")
    editRbacID:SetPoint("LEFT", row1, "LEFT", 0, 0)
    editRbacID:SetAutoFocus(false)
    editRbacID:SetText("ID")
    TrinityAdmin.AutoSize(editRbacID, 20, 13, nil, 60)

    local btnShowRbacList = CreateFrame("Button", nil, row1, "UIPanelButtonTemplate")
    btnShowRbacList:SetPoint("LEFT", editRbacID, "RIGHT", 10, 0)
    btnShowRbacList:SetText(L["Show rbac Id's List"])
    TrinityAdmin.AutoSize(btnShowRbacList, 20, 16)
    btnShowRbacList:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["rbcatooltip"], 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnShowRbacList:SetScript("OnLeave", function() GameTooltip:Hide() end)

    btnShowRbacList:SetScript("OnClick", function()
        local idText = editRbacID:GetText()
        local cmd
        if idText ~= "" and idText ~= "ID" then
            cmd = ".rbac list " .. idText
        else
            cmd = ".rbac list"
        end

        -- Réinitialiser et démarrer la capture des messages système
        rbacMessages = {}              -- on vide la table
        rbacListener:RegisterEvent("CHAT_MSG_SYSTEM")
        TrinityAdmin:SendCommand(cmd)

        -- On capture pendant 2 secondes, puis on appelle ShowRbacPopup
        C_Timer.After(2, function()
            rbacListener:UnregisterEvent("CHAT_MSG_SYSTEM")
            local output = table.concat(rbacMessages, "\n")
            ShowRbacPopup(output)
        end)
    end)

    --------------------------------------------------------------------------------
    -- SECTION 2 : rbac account (Account, ID, Realm ID, Dropdown et Bouton Action)
    --------------------------------------------------------------------------------
    local row2 = CreateFrame("Frame", nil, commandsFramePage3)
    row2:SetPoint("TOPLEFT", row1, "BOTTOMLEFT", 0, -20)
    row2:SetSize(500, 30)

    local editAccount = CreateFrame("EditBox", nil, row2, "InputBoxTemplate")
    editAccount:SetPoint("LEFT", row2, "LEFT", 0, 0)
    editAccount:SetAutoFocus(false)
    editAccount:SetText("Account")
    TrinityAdmin.AutoSize(editAccount, 20, 13, nil, 100)

    local editAccountID = CreateFrame("EditBox", nil, row2, "InputBoxTemplate")
    editAccountID:SetPoint("LEFT", editAccount, "RIGHT", 10, 0)
    editAccountID:SetAutoFocus(false)
    editAccountID:SetText("ID")
    TrinityAdmin.AutoSize(editAccountID, 20, 13, nil, 60)

    local editRealmID = CreateFrame("EditBox", nil, row2, "InputBoxTemplate")
    editRealmID:SetPoint("LEFT", editAccountID, "RIGHT", 10, 0)
    editRealmID:SetAutoFocus(false)
    editRealmID:SetText("Realm ID")
    TrinityAdmin.AutoSize(editRealmID, 20, 13, nil, 60)

    local btnAccountAction
    local actionDropdown = CreateFrame("Frame", "RbacActionDropdown", row2, "UIDropDownMenuTemplate")
    actionDropdown:SetPoint("LEFT", editRealmID, "RIGHT", 10, -2)
    UIDropDownMenu_SetWidth(actionDropdown, 120)
    UIDropDownMenu_SetText(actionDropdown, "Choose")
    actionDropdown.selectedOption = "Choose"

    local actions = {
        "Choose",
        "rbac account deny",
        "rbac account grant",
        "rbac account list",
        "rbac account revoke",
    }

    UIDropDownMenu_Initialize(actionDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for _, action in ipairs(actions) do
            info.text = action
            info.value = action
            info.checked = (action == actionDropdown.selectedOption)
            info.func = function()
                actionDropdown.selectedOption = action
                UIDropDownMenu_SetText(actionDropdown, action)
                UIDropDownMenu_SetSelectedValue(actionDropdown, action)
                if action == "rbac account deny" then
                    btnAccountAction:SetText("Deny")
                    btnAccountAction.tooltip = L["rbcadeny"]
                elseif action == "rbac account grant" then
                    btnAccountAction:SetText("Grant")
                    btnAccountAction.tooltip = L["rbcagrant"]
                elseif action == "rbac account list" then
                    btnAccountAction:SetText("View")
                    btnAccountAction.tooltip = L["rbcaview"]
                elseif action == "rbac account revoke" then
                    btnAccountAction:SetText("Revoke")
                    btnAccountAction.tooltip = L["rbcarevoke"]
                else
                    btnAccountAction:SetText("Choose")
                    btnAccountAction.tooltip = ""
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    local function CaptureChatAndPopup(duration)
        local messages = {}
        local listener = CreateFrame("Frame")
        listener:SetScript("OnEvent", function(self, event, msg, ...)
            table.insert(messages, msg)
        end)
        listener:RegisterEvent("CHAT_MSG_SYSTEM")
        C_Timer.After(duration, function()
            listener:UnregisterEvent("CHAT_MSG_SYSTEM")
            local output = table.concat(messages, "\n")
            ShowRbacPopup(output)
        end)
    end

    btnAccountAction = CreateFrame("Button", nil, row2, "UIPanelButtonTemplate")
    btnAccountAction:SetPoint("LEFT", actionDropdown, "RIGHT", 10, 0)
    btnAccountAction:SetText(L["choose3"])
    TrinityAdmin.AutoSize(btnAccountAction, 20, 16)
    btnAccountAction.tooltip = ""
    btnAccountAction:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tooltip or L["Choose an action"], 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnAccountAction:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btnAccountAction:SetScript("OnClick", function()
        local selected = actionDropdown.selectedOption
        local accountVal = editAccount:GetText()
        local idVal = editAccountID:GetText()
        local realmVal = editRealmID:GetText()
        if accountVal == "Account" then accountVal = "" end
        if idVal == "ID" then idVal = "" end
        if realmVal == "Realm ID" then realmVal = "" end

        local cmd = nil
        if selected == "rbac account deny" then
            if idVal == "" then
                TrinityAdmin:Print(L["demyerror"])
                return
            end
            cmd = ".rbac account deny " .. accountVal .. " " .. idVal .. " " .. realmVal
        elseif selected == "rbac account grant" then
            if idVal == "" then
                TrinityAdmin:Print(L["demyerror1"])
                return
            end
            cmd = ".rbac account grant " .. accountVal .. " " .. idVal .. " " .. realmVal
        elseif selected == "rbac account list" then
            if accountVal == "" then
                TrinityAdmin:Print(L["demyerror2"])
                return
            end
            cmd = ".rbac account list " .. accountVal
        elseif selected == "rbac account revoke" then
            if idVal == "" then
                TrinityAdmin:Print(L["demyerror3"])
                return
            end
            cmd = ".rbac account revoke " .. accountVal .. " " .. idVal .. " " .. realmVal
        else
            TrinityAdmin:Print(L["demyerror4"])
            return
        end

        TrinityAdmin:SendCommand(cmd)
        CaptureChatAndPopup(2)
    end)

    ------------------------------------------------------------------------------

    -- Bouton Back (toujours présent)
    local btnBackFinal = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("BOTTOM", panel, "BOTTOM", 0, 30)
    btnBackFinal:SetText(L["Back"])
    TrinityAdmin.AutoSize(btnBackFinal, 20, 16)
    btnBackFinal:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end