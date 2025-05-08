local TeleportModule = TrinityAdmin:GetModule("TeleportPanel")
local L = _G.L

function TeleportModule:ShowTeleportPanel()
    TrinityAdmin:HideMainMenu()
    if not self.teleportPanel then
        self:CreateTeleportPanel()
    end
    self.teleportPanel:Show()
end

function TeleportModule:CreateTeleportPanel()
    local panel = CreateFrame("Frame", "TrinityAdminTeleportPanel", TrinityAdminMainFrame)
    panel:SetSize(700, 200)
    panel:SetPoint("TOPLEFT",  TrinityAdminMainFrame, "TOPLEFT",     10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(L["Teleport Panel"])
    
	-- Bouton Retour commun
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(L["Back"])
    -- btnBack:SetSize(btnBack:GetTextWidth() + 20, 22)
	TrinityAdmin.AutoSize(btnBack, 20, 16)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)
	
    -------------------------------------------------------------------------
    -- On déclare ici navPageLabel (AVANT de définir ShowPage)
    -------------------------------------------------------------------------
    local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 42)
    navPageLabel:SetText("Page 1 / 3")

    -------------------------------------------------------------------------
    -- 3 FRAMES : page1, page2, page3
    -------------------------------------------------------------------------
    local page1 = CreateFrame("Frame", "TrinityAdminTeleportPage1", panel)
    page1:SetAllPoints(panel)

    local page2 = CreateFrame("Frame", "TrinityAdminTeleportPage2", panel)
    page2:SetAllPoints(panel)
    page2:Hide()

    local page3 = CreateFrame("Frame", "TrinityAdminTeleportPage3", panel)
    page3:SetAllPoints(panel)
    page3:Hide()

    -- ======================================================================
    -- 1) Déclarer la fonction ShowPage (qui utilise navPageLabel)
    -- ======================================================================
	local totalPages = 3
    local currentPage = 1
	local btnPrev, btnNext
	local function ShowPage(pageIndex)
    page1:Hide()
    page2:Hide()
    page3:Hide()

    if pageIndex == 1 then
        page1:Show()
        navPageLabel:SetText("Page 1 / 3")
    elseif pageIndex == 2 then
        page2:Show()
        navPageLabel:SetText("Page 2 / 3")
    elseif pageIndex == 3 then
        page3:Show()
        navPageLabel:SetText("Page 3 / 3")
    end

    -- Activer ou désactiver les boutons
    if btnPrev then
        if pageIndex <= 1 then
            btnPrev:Disable()
        else
            btnPrev:Enable()
        end
    end

    if btnNext then
        if pageIndex >= totalPages then
            btnNext:Disable()
        else
            btnNext:Enable()
        end
    end
end
    -- ======================================================================
    -- 2) On crée les boutons de navigation APRÈS ShowPage
    -- ======================================================================
    -- local btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnPrev:SetSize(80, 22)
    btnPrev:SetText(L["Pagination_Preview"])
	TrinityAdmin.AutoSize(btnPrev, 20, 16)
    btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            ShowPage(currentPage)
        end
    end)

    -- local btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    --btnNext:SetSize(80, 22)
    btnNext:SetText(L["Next"])
	TrinityAdmin.AutoSize(btnNext, 20, 16)
    btnNext:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
    btnNext:SetScript("OnClick", function()
        if currentPage < totalPages then
            currentPage = currentPage + 1
            ShowPage(currentPage)
        end
    end)

	-- Puis initialise l'état correctement
	ShowPage(currentPage)
    ----------------------------------------------------------------------------
    -- PAGE 1 : World Teleport + Special
    ----------------------------------------------------------------------------
    do
        local worldTitle = page1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        worldTitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -20)
        worldTitle:SetText(L["World teleportations"])

        -- === continentDropdown, zoneDropdown, locationDropdown, goButton ===
        local continentDropdown = CreateFrame("Frame", "TrinityAdminContinentDropdown", page1, "UIDropDownMenuTemplate")
        continentDropdown:SetPoint("TOPLEFT", worldTitle, "TOPLEFT", -15, -25)
        UIDropDownMenu_SetWidth(continentDropdown, 150)
        UIDropDownMenu_Initialize(continentDropdown, function(dropdown, level, menuList)
            local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)
            local continents = TeleportData
            if not continents then
                TrinityAdmin:Print(L["No_Teleport_Data_Found"])
                return
            end
            for continentName, _ in pairs(continents) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = continentName
                info.value = continentName
                info.isNotRadio = false
                info.r, info.g, info.b = 1, 1, 1
                info.checked = (info.value == selectedValue)
                info.func = function(button)
                    UIDropDownMenu_SetSelectedValue(dropdown, button.value)
                    UIDropDownMenu_SetText(dropdown, button.value)
                    self.selectedContinent = button.value
                    self.selectedZone = nil
                    self.selectedCommand = nil
                    self:PopulateZoneDropdown(button.value, panel) -- Remplir le zoneDropdown
                    panel.zoneDropdown:Show()
                    UIDropDownMenu_SetText(panel.zoneDropdown, L["Select_Zone"])
                    panel.locationDropdown:Hide()
                    panel.goButton:Hide()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        UIDropDownMenu_SetText(continentDropdown, L["Select_Continent"])

        local zoneDropdown = CreateFrame("Frame", "TrinityAdminZoneDropdown", page1, "UIDropDownMenuTemplate")
        zoneDropdown:SetPoint("LEFT", continentDropdown, "RIGHT", 5, 0)
        UIDropDownMenu_SetWidth(zoneDropdown, 150)
        UIDropDownMenu_SetText(zoneDropdown, L["Select_Zone"])
        zoneDropdown:Hide()

        local locationDropdown = CreateFrame("Frame", "TrinityAdminLocationDropdown", page1, "UIDropDownMenuTemplate")
        locationDropdown:SetPoint("LEFT", zoneDropdown, "RIGHT", 5, 0)
        UIDropDownMenu_SetWidth(locationDropdown, 150)
        UIDropDownMenu_SetText(locationDropdown, L["Select_Location"])
        locationDropdown:Hide()

        local goButton = CreateFrame("Button", "TrinityAdminGoButton", page1, "UIPanelButtonTemplate")
        goButton:SetPoint("LEFT", locationDropdown, "RIGHT", 10, 0)
        goButton:SetText(L["Go"])
        -- goButton:SetHeight(22)
        -- goButton:SetWidth(goButton:GetTextWidth() + 20)
		TrinityAdmin.AutoSize(goButton, 20, 16)
        goButton:Hide()
        goButton:SetScript("OnClick", function()
            if self.selectedCommand then
                self:TeleportTo(self.selectedCommand)
            else
                TrinityAdmin:Print(L["Select_Location"])
            end
        end)

        panel.continentDropdown = continentDropdown
        panel.zoneDropdown      = zoneDropdown
        panel.locationDropdown  = locationDropdown
        panel.goButton          = goButton

        -- === Special Teleports ===
        local specialTitle = page1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        specialTitle:SetPoint("TOPLEFT", worldTitle, "BOTTOMLEFT", 0, -80)
        specialTitle:SetText(L["Special teleportations"])

        local specialOptions = {
            { text = "tele add", command = ".tele add", tooltip = L["Tele_Add"] },
            { text = "tele del", command = ".tele del", tooltip = L["Tele_Del"] },
            { text = "tele group", command = ".tele group", tooltip = L["Tele_Group"] },
            { text = "tele name", command = ".tele name", tooltip = L["Tele_Name"] },
            { text = "tele name npc guid", command = ".tele name npc guid", tooltip = L["Tele_Name_Id"] },
            { text = "tele name npc id", command = ".tele name npc id", tooltip = L["Tele_Name_NPC_Id"] },
            { text = "tele name npc name", command = ".tele name npc name", tooltip = L["Tele_Name_NPC_Name"] },
        }

        local specialDropdown = CreateFrame("Frame", "TrinityAdminSpecialDropdown", page1, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(specialDropdown, 120)
        UIDropDownMenu_SetButtonWidth(specialDropdown, 120)
        if not specialDropdown.selectedID then specialDropdown.selectedID = 1 end
        UIDropDownMenu_Initialize(specialDropdown, function(dropdown, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            for i, option in ipairs(specialOptions) do
                info.text = option.text
                info.value = option.command
                info.checked = (i == specialDropdown.selectedID)
                info.func = function(button)
                    specialDropdown.selectedID = i
                    UIDropDownMenu_SetSelectedID(specialDropdown, i)
                    UIDropDownMenu_SetText(specialDropdown, option.text)
                    specialDropdown.selectedOption = option
                    if specialEdit then
                        specialEdit:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText(option.tooltip, 1, 1, 1, 1, true)
                            GameTooltip:Show()
                        end)
                    end
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        UIDropDownMenu_SetSelectedID(specialDropdown, specialDropdown.selectedID)
        UIDropDownMenu_SetText(specialDropdown, specialOptions[specialDropdown.selectedID].text)
        specialDropdown.selectedOption = specialOptions[specialDropdown.selectedID]

        local specialEdit = CreateFrame("EditBox", "TrinityAdminSpecialEditBox", page1, "InputBoxTemplate")
        specialEdit:SetAutoFocus(false)
        -- specialEdit:SetSize(250, 22)
        specialEdit:SetPoint("TOPLEFT", specialTitle, "BOTTOMLEFT", 0, -15)
        specialEdit:SetText(L["Enter_Value"])
		TrinityAdmin.AutoSize(specialEdit, 20, 13)
        specialEdit:SetScript("OnEnter", function(self)
            local opt = specialDropdown.selectedOption or specialOptions[1]
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        specialEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
        specialEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

        specialDropdown:SetPoint("LEFT", specialEdit, "RIGHT", 10, 0)

        local btnSpecialGo = CreateFrame("Button", "TrinityAdminSpecialGoButton", page1, "UIPanelButtonTemplate")
        -- btnSpecialGo:SetSize(40, 22)
        btnSpecialGo:SetText(L["Go"])
		TrinityAdmin.AutoSize(btnSpecialGo, 20, 16)
        btnSpecialGo:SetPoint("LEFT", specialDropdown, "RIGHT", 10, 0)
        btnSpecialGo:SetScript("OnClick", function()
            local inputValue = specialEdit:GetText()
            local option = specialDropdown.selectedOption
            local command = option.command
            local finalCommand = command .. " " .. inputValue
            if inputValue == "" or inputValue == "Enter Value" then
                local targetName = UnitName("target")
                if targetName then
                    finalCommand = command .. " " .. targetName
                else
                    TrinityAdmin:Print(L["please_enter_value_or_select_player"])
                    return
                end
            end
            SendChatMessage(finalCommand, "SAY")
            -- print("[DEBUG] Commande envoyée: " .. finalCommand)
        end)

        btnSpecialGo:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local opt = specialDropdown.selectedOption or specialOptions[1]
            GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btnSpecialGo:SetScript("OnLeave", function() GameTooltip:Hide() end)

        panel.specialDropdown = specialDropdown
        panel.specialEdit     = specialEdit
        panel.btnSpecialGo    = btnSpecialGo
    end

    -- =========================================
    -- PAGE 2 : go xyz / go offset / go zonexy
    -- =========================================
    do
        local yOffset = 0
        local label_page2 = page2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        --label_page2:SetPoint("TOPLEFT", 10, -10)
		label_page2:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -10)
        label_page2:SetText(L["Extended Teleports 2"])
		
        -- A) go xyz
        do
            local row_xyz = CreateFrame("Frame", nil, page2)
            row_xyz:SetSize(680, 40)
            row_xyz:SetPoint("TOPLEFT", page2, "TOPLEFT", 10, -70 - yOffset)
            yOffset = yOffset + 80

            local label_xyz = row_xyz:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            label_xyz:SetPoint("TOPLEFT", row_xyz, "TOPLEFT", 0, 2)
            label_xyz:SetText("go xyz")

            local fields_xyz = {"X", "Y", "Z", "MapID", "O"}
            local edits_xyz = {}
            local xOffset = 0
            for i, label in ipairs(fields_xyz) do
			local edit = CreateFrame("EditBox", nil, row_xyz, "InputBoxTemplate")
			edit:SetAutoFocus(false)
			edit:SetText(label)
		
			-- On positionne soit par rapport à row_xyz, soit à la dernière edit
			if not prev then
				edit:SetPoint("TOPLEFT", row_xyz, "TOPLEFT", 0, -25)
			else
				edit:SetPoint("LEFT", prev, "RIGHT", 10, 0)
			end
		
			TrinityAdmin.AutoSize(edit, 80, 13)
			edits_xyz[i] = edit
			prev = edit
			end

            local btn_xyz = CreateFrame("Button", nil, row_xyz, "UIPanelButtonTemplate")
            -- btn_xyz:SetSize(60, 22)
            -- btn_xyz:SetPoint("TOPLEFT", row_xyz, "TOPLEFT", xOffset, -25)
			btn_xyz:SetPoint("LEFT", prev, "RIGHT", 5, 0)
            btn_xyz:SetText(L["Go"])
			TrinityAdmin.AutoSize(btn_xyz, 20, 16)
			
			-- Ajouter un tooltip pour afficher le texte complet au survol
			btn_xyz:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetText(L["teleport1_explain"], 1, 1, 1, 1, true)
					GameTooltip:Show()
				end)
			btn_xyz:SetScript("OnLeave", function(self)
					GameTooltip:Hide()
			end)
			
            btn_xyz:SetScript("OnClick", function()
                local vals = {}
                for i = 1, 5 do
                    table.insert(vals, edits_xyz[i]:GetText())
                end
                local command = ".go xyz " .. vals[1] .. " " .. vals[2]
                if vals[3] and vals[3] ~= "Z" then
                    command = command .. " " .. vals[3]
                end
                if vals[4] and vals[4] ~= "MapID" then
                    command = command .. " " .. vals[4]
                end
                if vals[5] and vals[5] ~= "O" then
                    command = command .. " " .. vals[5]
                end
                SendChatMessage(command, "SAY")
                -- print("[DEBUG] Commande envoyée: " .. command)
            end)
        end

        -- B) go offset
	do
		local row_offset = CreateFrame("Frame", nil, page2)
		row_offset:SetSize(680, 40)
		row_offset:SetPoint("TOPLEFT", page2, "TOPLEFT", 10, -50 - yOffset)
		yOffset = yOffset + 80
	
		local label_offset = row_offset:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label_offset:SetPoint("TOPLEFT", row_offset, "TOPLEFT", 0, 5)
		label_offset:SetText("go offset")
	
		local fields_offset = {"dForward", "dSideways", "dZ", "dO"}
		local edits_offset = {}
		local prev
	
		-- Création dynamique des EditBox avec AutoSize et ancrage sur la précédente
		for i, key in ipairs(fields_offset) do
			local edit = CreateFrame("EditBox", nil, row_offset, "InputBoxTemplate")
			edit:SetAutoFocus(false)
			edit:SetText(key)
			TrinityAdmin.AutoSize(edit, 80, 13)
	
			if not prev then
				edit:SetPoint("TOPLEFT", row_offset, "TOPLEFT", 0, -20)
			else
				edit:SetPoint("LEFT", prev, "RIGHT", 10, 0)
			end
	
			edits_offset[i] = edit
			prev = edit
		end
	
		-- Bouton « Go » ancré à droite de la dernière EditBox
		local btn_offset = CreateFrame("Button", nil, row_offset, "UIPanelButtonTemplate")
		btn_offset:SetText(L["Go"])
		TrinityAdmin.AutoSize(btn_offset, 20, 16)
		btn_offset:SetPoint("LEFT", prev, "RIGHT", 5, 0)
	
		-- Tooltip
		btn_offset:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(L["teleport2_explain"], 1, 1, 1, 1, true)
			GameTooltip:Show()
		end)
		btn_offset:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	
		-- OnClick
		btn_offset:SetScript("OnClick", function()
			local vals = {}
			for i = 1, #edits_offset do
				table.insert(vals, edits_offset[i]:GetText())
			end
			if vals[1] == "dForward" or vals[1] == "" then
				TrinityAdmin:Print(L["dForward is mandatory and must be modified."])
				return
			end
			for i = 2, #fields_offset do
				if vals[i] == fields_offset[i] then
					TrinityAdmin:Print(L["dForward_error"])
					return
				end
			end
			local command = ".go offset " .. table.concat(vals, " ")
			SendChatMessage(command, "SAY")
		end)
	end


		-- C) go zonexy / go grid
	do
		local row_option = CreateFrame("Frame", nil, page2)
		row_option:SetSize(680, 40)
		row_option:SetPoint("TOPLEFT", page2, "TOPLEFT", 10, -50 - yOffset)
		yOffset = yOffset + 80
	
		local label_option = row_option:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label_option:SetPoint("TOPLEFT", row_option, "TOPLEFT", 0, 5)
		label_option:SetText("go zonexy / go grid")
	
		local edits_option = {}
		local dropdownOptions = {
			{
				text    = "go zonexy",
				command = ".go zonexy",
				fields  = {"X", "Y", "Zone"},
				tooltip = L["go zonexy tooltip"]
			},
			{
				text    = "go grid",
				command = ".go grid",
				fields  = {"gridX", "gridY", "mapId"},
				tooltip = L["go grid tooltip"]
			},
		}
	
		-- 1) Création du dropdown
		local optionDropdown = CreateFrame("Frame", nil, row_option, "TrinityAdminDropdownTemplate")
		optionDropdown:SetPoint("TOPLEFT", row_option, "TOPLEFT", -20, -16)
		UIDropDownMenu_SetWidth(optionDropdown, 120)
		UIDropDownMenu_SetButtonWidth(optionDropdown, 140)
	
		-- 2) Forward-déclaration du bouton pour que la closure le voie
		local btnOption
	
		-- 3) Utility pour repositionner edits + bouton
		local function LayoutFieldsAndButton()
			local prev
			for _, edit in ipairs(edits_option) do
				TrinityAdmin.AutoSize(edit, 80, 13)
				if not prev then
					edit:SetPoint("TOPLEFT", row_option, "TOPLEFT", 150, -20)
				else
					edit:SetPoint("LEFT", prev, "RIGHT", 10, 0)
				end
				prev = edit
			end
	
			-- Maintenant btnOption est bien le local déclaré ci-dessus
			TrinityAdmin.AutoSize(btnOption, 20, 16)
			if prev then
				btnOption:SetPoint("LEFT", prev, "RIGHT", 10, 0)
			else
				btnOption:SetPoint("TOPLEFT", row_option, "TOPLEFT", 150, -20)
			end
		end
	
		-- 4) Initialisation du dropdown
		UIDropDownMenu_Initialize(optionDropdown, function(_, level)
			local info = UIDropDownMenu_CreateInfo()
			for i, opt in ipairs(dropdownOptions) do
				info.text  = opt.text
				info.value = i
				info.checked = (UIDropDownMenu_GetSelectedID(optionDropdown) == i)
				info.func = function()
					UIDropDownMenu_SetSelectedID(optionDropdown, i)
					UIDropDownMenu_SetText(optionDropdown, opt.text)
					optionDropdown.selectedOption = opt
	
					-- mise à jour des EditBox
					for j, edit in ipairs(edits_option) do
						edit:SetText(opt.fields[j] or "")
					end
					LayoutFieldsAndButton()
				end
				UIDropDownMenu_AddButton(info, level)
			end
		end)
	
		-- 5) Sélection par défaut
		UIDropDownMenu_SetSelectedID(optionDropdown, 1)
		UIDropDownMenu_SetText(optionDropdown, dropdownOptions[1].text)
		optionDropdown.selectedOption = dropdownOptions[1]
	
		-- 6) Création des EditBox initiales (on ne touche pas au SetPoint ici)
		for i, fieldName in ipairs(optionDropdown.selectedOption.fields) do
			local edit = CreateFrame("EditBox", nil, row_option, "InputBoxTemplate")
			edit:SetAutoFocus(false)
			edit:SetText(fieldName)
			edits_option[i] = edit
		end
	
		-- 7) Création du bouton « Go »
		btnOption = CreateFrame("Button", nil, row_option, "UIPanelButtonTemplate")
		btnOption:SetText(L["Go"])
		btnOption:SetScript("OnClick", function()
			local opt = optionDropdown.selectedOption
			local vals = {}
			for _, edit in ipairs(edits_option) do
				table.insert(vals, edit:GetText())
			end
			SendChatMessage(opt.command .. " " .. table.concat(vals, " "), "SAY")
		end)
		btnOption:SetScript("OnEnter", function(self)
			local opt = optionDropdown.selectedOption
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(opt and opt.tooltip or L["No tooltip available."], 1,1,1,1, true)
			GameTooltip:Show()
		end)
		btnOption:SetScript("OnLeave", GameTooltip_Hide)
	
		-- 8) Last but not least : on positionne tout
		LayoutFieldsAndButton()
	end

end


    -- =========================================
    -- PAGE 3 : go areatrigger / boss / ...
    -- =========================================
    do
        local yOffset = 0
        local label_page3 = page3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- label_page3:SetPoint("TOPLEFT", 10, -10)
		label_page3:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -20)
        label_page3:SetText(L["Extra Teleports 3"])

        local goOptions = {
            { text = "go areatrigger", command = ".go areatrigger", defaultText = "AreatriggerID", tooltip = "Syntax: .go areatrigger <areatriggerId>" },
            { text = "go boss",         command = ".go boss",         defaultText = "Boss Name", tooltip = "Syntax: .go boss <part(s) of name>" },
            { text = "go bugticket",    command = ".go bugticket",    defaultText = "TicketId", tooltip = "Syntax: .go bugticket <ticketId>" },
            { text = "go complaintticket", command = ".go complaintticket", defaultText = "TicketId", tooltip = "Syntax: .go complaintticket <ticketId>" },
            { text = "go creature",     command = ".go creature",     defaultText = "SpawnID", tooltip = "Syntax: .go creature <spawnId>" },
            { text = "go creature id",  command = ".go creature id",  defaultText = "Creature ID", tooltip = "Syntax: .go creature id <creatureId>" },
            { text = "go gameobject",   command = ".go gameobject",   defaultText = "SpawnID", tooltip = "Syntax: .go gameobject <spawnId>" },
            { text = "go gameobject id",command = ".go gameobject id",defaultText = "Gobject ID", tooltip = "Syntax: .go gameobject id <goId>" },
            { text = "go graveyard",    command = ".go graveyard",    defaultText = "Graveyard ID", tooltip = "Syntax: .go graveyard <graveyardId>" },
            { text = "go instance",     command = ".go instance",     defaultText = "Instance Name", tooltip = "Syntax: .go instance <part(s) of name>" },
            { text = "go quest",        command = ".go quest",        defaultText = "Quest ID", tooltip = "Syntax: .go quest #quest_id" },
            { text = "go suggestionticket", command = ".go suggestionticket", defaultText = "TicketId", tooltip = "Syntax: .go suggestionticket <ticketId>" },
            { text = "go taxinode",      command = ".go taxinode",      defaultText = "Node ID", tooltip = "Syntax: .go taxinode <nodeId>" },
        }

        local row_option2 = CreateFrame("Frame", nil, page3)
        row_option2:SetSize(680, 40)
        row_option2:SetPoint("TOPLEFT", page3, "TOPLEFT", 10, -50 - yOffset)
        yOffset = yOffset + 45

		----------------------------------------------------------------
		-- 1) Déclarer localement 'optionEditBox2' AVANT le dropdown
		----------------------------------------------------------------
		local optionEditBox2
		
		----------------------------------------------------------------
		-- 2) Créer le dropdown 'optionDropdown2'
		----------------------------------------------------------------
		local optionDropdown2 = CreateFrame("Frame", nil, row_option2, "TrinityAdminDropdownTemplate")
		optionDropdown2:SetPoint("TOPLEFT", row_option2, "TOPLEFT", 0, -26)
		UIDropDownMenu_SetWidth(optionDropdown2, 150)
		UIDropDownMenu_SetButtonWidth(optionDropdown2, 200)
	
		UIDropDownMenu_Initialize(optionDropdown2, function(dropdown, level, menuList)
			local info = UIDropDownMenu_CreateInfo()
			for i, opt in ipairs(goOptions) do
				info.text   = opt.text
				info.value  = i
				info.func = function(button)
					UIDropDownMenu_SetSelectedID(optionDropdown2, i)
					UIDropDownMenu_SetText(optionDropdown2, opt.text)
					optionDropdown2.selectedOption = opt
	
					-- Ici, 'optionEditBox2' existe déjà,
					-- on peut donc l’utiliser :
					if optionEditBox2 then
						optionEditBox2:SetText(opt.defaultText)
						TrinityAdmin.AutoSize(optionEditBox2, 20, 13)
					end
				end
				info.checked = (UIDropDownMenu_GetSelectedID(optionDropdown2) == i)
				UIDropDownMenu_AddButton(info, level)
			end
		end)
	
		-- Valeurs par défaut :
		UIDropDownMenu_SetSelectedID(optionDropdown2, 1)
		UIDropDownMenu_SetText(optionDropdown2, goOptions[1].text)
		optionDropdown2.selectedOption = goOptions[1]
	
		----------------------------------------------------------------
		-- 3) Créer l’EditBox APRES la déclaration,
		----------------------------------------------------------------
		optionEditBox2 = CreateFrame("EditBox", nil, row_option2, "InputBoxTemplate")
		optionEditBox2:SetSize(150, 22)
		optionEditBox2:SetPoint("LEFT", optionDropdown2, "RIGHT", 10, 0)
		optionEditBox2:SetAutoFocus(false)
		optionEditBox2:SetText(goOptions[1].defaultText)
	
		-- Petit tooltip optionnel :
		optionEditBox2:SetScript("OnEnter", function(self)
			local opt = optionDropdown2.selectedOption or goOptions[1]
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
			GameTooltip:Show()
		end)
		optionEditBox2:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
		----------------------------------------------------------------
		-- 4) Bouton "Go"
		----------------------------------------------------------------
		local btnOption2 = CreateFrame("Button", nil, row_option2, "UIPanelButtonTemplate")
		-- btnOption2:SetSize(60, 22)
		btnOption2:SetPoint("LEFT", optionEditBox2, "RIGHT", 10, 0)
		btnOption2:SetText(L["Go"])
		TrinityAdmin.AutoSize(btnOption2, 20, 16)
	
		btnOption2:SetScript("OnClick", function()
			local opt = optionDropdown2.selectedOption or goOptions[1]
			local val = optionEditBox2:GetText()
			if not val or val == "" or val == opt.defaultText then
				TrinityAdmin:Print(L["please_enter_value2"] .. opt.text)
				return
			end
			local command = opt.command .. " " .. val
			SendChatMessage(command, "SAY")
			-- print("[DEBUG] Commande envoyée: " .. command)
		end)
		
				-- Petit tooltip optionnel :
		btnOption2:SetScript("OnEnter", function(self)
			local opt = optionDropdown2.selectedOption or goOptions[1]
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
			GameTooltip:Show()
		end)
		btnOption2:SetScript("OnLeave", function() GameTooltip:Hide() end)
		
	end
	
    -- Afficher la page1 par défaut
    ShowPage(1)

    -- On stocke le panel si besoin
    self.teleportPanel = panel
end

----------------------------------------------------------------------------
-- Fonctions PopulateZoneDropdown, PopulateLocationDropdown, TeleportTo (inchangées)
----------------------------------------------------------------------------
function TeleportModule:PopulateZoneDropdown(continentName, panel)
    local zoneDropdown = panel.zoneDropdown
    UIDropDownMenu_Initialize(zoneDropdown, function(dropdown, level, menuList)
        level = level or 1
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)
        local zonesTable = TeleportData[continentName]
        if not zonesTable then
            TrinityAdmin:Print(L["No_Teleport_Data_Found"])
            return
        end
        for zoneName, _ in pairs(zonesTable) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = zoneName
            info.value = zoneName
            info.isNotRadio = false
            info.r, info.g, info.b = 1, 1, 1
            info.checked = (info.value == selectedValue)
            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(zoneDropdown, button.value)
                UIDropDownMenu_SetText(zoneDropdown, button.value)
                self.selectedZone = button.value
                self:PopulateLocationDropdown(continentName, button.value, panel)
                panel.locationDropdown:Show()
                UIDropDownMenu_SetText(panel.locationDropdown, L["Select_Location"])
                panel.goButton:Hide()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(zoneDropdown, L["Select_Zone"])
end

function TeleportModule:PopulateLocationDropdown(continentName, zoneName, panel)
    local locationDropdown = panel.locationDropdown
    UIDropDownMenu_Initialize(locationDropdown, function(dropdown, level, menuList)
        level = level or 1
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)
        local locTable = TeleportData[continentName] and TeleportData[continentName][zoneName]
        if not locTable then
            TrinityAdmin:Print(L["No location for zone:"], zoneName, L["of continent:"], continentName)
            return
        end
        for locationName, command in pairs(locTable) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = locationName
            info.value = command
            info.isNotRadio = false
            info.r, info.g, info.b = 1, 1, 1
            info.checked = (info.value == selectedValue)
            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(locationDropdown, button.value)
                UIDropDownMenu_SetText(locationDropdown, info.text)
                self.selectedCommand = button.value
                panel.goButton:Show()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(locationDropdown, L["Select_Location"])
end

function TeleportModule:TeleportTo(command)
    SendChatMessage(command, "SAY")
end
