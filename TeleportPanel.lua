local TeleportModule = TrinityAdmin:GetModule("TeleportPanel")

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
    -- On ancre le panel pour qu'il ne déborde pas
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(TrinityAdmin_Translations["Teleport Panel"])

    ------------------------------------------------------------------
    -- 1) Dropdown Continent (TrinityAdminDropdownTemplate)
    ------------------------------------------------------------------
	local worldTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    worldTitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -5)
    worldTitle:SetText("World teleportations")
	
    local continentDropdown = CreateFrame("Frame", "TrinityAdminContinentDropdown", panel, "UIDropDownMenuTemplate")
    continentDropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)
	UIDropDownMenu_SetWidth(continentDropdown, 150)  -- Largeur fixée

    UIDropDownMenu_Initialize(continentDropdown, function(dropdown, level, menuList)
        level = level or 1
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)
        local continents = TeleportData
        if not continents then
            print(TrinityAdmin_Translations["No_Teleport_Data_Found"])
            return
        end
        for continentName, zonesTable in pairs(continents) do
            local info = UIDropDownMenu_CreateInfo()
            info.text       = continentName
            info.value      = continentName
            info.isNotRadio = false
            info.r, info.g, info.b = 1,1,1
            info.checked    = (info.value == selectedValue)

            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(dropdown, button.value)
                UIDropDownMenu_SetText(dropdown, button.value)
                self.selectedContinent = button.value
                self.selectedZone      = nil
                self.selectedCommand   = nil

                self:PopulateZoneDropdown(button.value, panel)
                panel.zoneDropdown:Show()
                UIDropDownMenu_SetText(panel.zoneDropdown, TrinityAdmin_Translations["Select_Zone"])

                panel.locationDropdown:Hide()
                panel.goButton:Hide()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(continentDropdown, TrinityAdmin_Translations["Select_Continent"])
	
    ------------------------------------------------------------------
    -- 2) Dropdown Zone
    ------------------------------------------------------------------
    local zoneDropdown = CreateFrame("Frame", "TrinityAdminZoneDropdown", panel, "UIDropDownMenuTemplate")
	zoneDropdown:SetPoint("LEFT", continentDropdown, "RIGHT", 5, 0)
	UIDropDownMenu_SetWidth(zoneDropdown, 150)
	UIDropDownMenu_SetText(zoneDropdown, TrinityAdmin_Translations["Select_Zone"])
	zoneDropdown:Hide()
    ------------------------------------------------------------------
    -- 3) Dropdown Location
    ------------------------------------------------------------------
    local locationDropdown = CreateFrame("Frame", "TrinityAdminLocationDropdown", panel, "UIDropDownMenuTemplate")
	locationDropdown:SetPoint("LEFT", zoneDropdown, "RIGHT", 5, 0)
	UIDropDownMenu_SetWidth(locationDropdown, 150)
	UIDropDownMenu_SetText(locationDropdown, TrinityAdmin_Translations["Select_Location"])
	locationDropdown:Hide()

    ------------------------------------------------------------------
    -- Bouton Go
    ------------------------------------------------------------------
    local goButton = CreateFrame("Button", "TrinityAdminGoButton", panel, "UIPanelButtonTemplate")
    goButton:SetPoint("LEFT", locationDropdown, "RIGHT", 10, 0)
    goButton:SetText("Go")
    goButton:SetHeight(22)
    goButton:SetWidth(goButton:GetTextWidth() + 20)
    goButton:Hide()
    goButton:SetScript("OnClick", function()
        if self.selectedCommand then
            self:TeleportTo(self.selectedCommand)
        else
            print(TrinityAdmin_Translations["Select_Location"])
        end
    end)

    ------------------------------------------------------------------
    -- Section: Special teleportations
    ------------------------------------------------------------------
    local specialTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    specialTitle:SetPoint("TOPLEFT", continentDropdown, "BOTTOMLEFT", 0, -20)
    specialTitle:SetText("Special teleportations")
    
    -- Premièrement, créez le menu déroulant pour choisir l'option spéciale
    local specialOptions = {
        { text = "tele add", command = ".tele add", tooltip = TrinityAdmin_Translations["Tele_Add"] },
        { text = "tele del", command = ".tele del", tooltip = TrinityAdmin_Translations["Tele_Del"] },
        { text = "tele group", command = ".tele group", tooltip = TrinityAdmin_Translations["Tele_Group"] },
        { text = "tele name", command = ".tele name", tooltip = TrinityAdmin_Translations["Tele_Name"] },
        { text = "tele name npc guid", command = ".tele name npc guid", tooltip = TrinityAdmin_Translations["Tele_Name_Id"] },
        { text = "tele name npc id", command = ".tele name npc id", tooltip = TrinityAdmin_Translations["Tele_Name_NPC_Id"] },
        { text = "tele name npc name", command = ".tele name npc name", tooltip = TrinityAdmin_Translations["Tele_Name_NPC_Name"] },
    }
    
    local specialDropdown = CreateFrame("Frame", "TrinityAdminSpecialDropdown", panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(specialDropdown, 120)
    UIDropDownMenu_SetButtonWidth(specialDropdown, 240)
    if not specialDropdown.selectedID then specialDropdown.selectedID = 1 end
    UIDropDownMenu_Initialize(specialDropdown, function(dropdownFrame, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, option in ipairs(specialOptions) do
            info.text = option.text
            info.value = option.command
            info.checked = (i == specialDropdown.selectedID)
            info.func = function(buttonFrame)
                specialDropdown.selectedID = i
                UIDropDownMenu_SetSelectedID(specialDropdown, i)
                UIDropDownMenu_SetText(specialDropdown, option.text)
                specialDropdown.selectedOption = option
				print("DEBUG: Option sélectionnée: " .. option.text)       -- Affiche l'option sélectionnée pour débug
                -- Met à jour le tooltip du champ de saisie (que nous créerons ensuite)
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

    -- Ensuite, créez le champ de saisie pour la commande spéciale
    local specialEdit = CreateFrame("EditBox", "TrinityAdminSpecialEditBox", panel, "InputBoxTemplate")
    specialEdit:SetAutoFocus(false)
    specialEdit:SetSize(150, 22)
    -- On l'ancre sous le titre, par exemple avec un offset vertical
    specialEdit:SetPoint("TOPLEFT", specialTitle, "BOTTOMLEFT", 0, -10)
    specialEdit:SetText("Enter Value")
    specialEdit:SetScript("OnEnter", function(self)
        local opt = specialDropdown.selectedOption or specialOptions[1]
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    specialEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
    specialEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    
    -- Ajustez la position du dropdown maintenant que le champ de saisie existe
    specialDropdown:SetPoint("LEFT", specialEdit, "RIGHT", 10, 0)

    -- Bouton "Go" pour la commande spéciale
    local btnSpecialGo = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnSpecialGo:SetSize(40, 22)
    btnSpecialGo:SetText("Go")
    btnSpecialGo:SetPoint("LEFT", specialDropdown, "RIGHT", 10, 0)
    btnSpecialGo:SetScript("OnClick", function()
        local inputValue = specialEdit:GetText()
        local option = specialDropdown.selectedOption
        local command = option.command
        local finalCommand = command .. " " .. inputValue  -- sans guillemets
        if inputValue == "" or inputValue == "Enter Value" then
            local targetName = UnitName("target")
            if targetName then
                finalCommand = command .. " " .. targetName
            else
			    print("Sortie du SAY:" ..finalCommand) -- Pour debug
                print("Veuillez saisir une valeur ou cibler un joueur.")
                return
            end
        end
        SendChatMessage(finalCommand, "SAY")
    end)
    btnSpecialGo:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local opt = specialDropdown.selectedOption or specialOptions[1]
        GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnSpecialGo:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

	
    ------------------------------------------------------------------
    -- Bouton Back
    ------------------------------------------------------------------
    local btnBack = CreateFrame("Button", "TrinityAdminTeleportBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    panel.continentDropdown = continentDropdown
    panel.zoneDropdown      = zoneDropdown
    panel.locationDropdown  = locationDropdown
    panel.goButton          = goButton

    self.teleportPanel = panel
end

-- Définition des fonctions dans le module TeleportPanel
function TeleportModule:PopulateZoneDropdown(continentName, panel)
    local zoneDropdown = panel.zoneDropdown
    UIDropDownMenu_Initialize(zoneDropdown, function(dropdown, level, menuList)
        level = level or 1
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)
        local zonesTable = TeleportData[continentName]
        if not zonesTable then
            print("Aucune zone pour le continent:", continentName)
            return
        end
        for zoneName, _ in pairs(zonesTable) do
            local info = UIDropDownMenu_CreateInfo()
            info.text       = zoneName
            info.value      = zoneName
            info.isNotRadio = false
            info.r, info.g, info.b = 1,1,1
            info.checked    = (info.value == selectedValue)

            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(zoneDropdown, button.value)
                UIDropDownMenu_SetText(zoneDropdown, button.value)
                self.selectedZone = button.value
                self:PopulateLocationDropdown(continentName, button.value, panel)
                panel.locationDropdown:Show()
                UIDropDownMenu_SetText(panel.locationDropdown, TrinityAdmin_Translations["Select_Location"])
                panel.goButton:Hide()
            end

            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(zoneDropdown, TrinityAdmin_Translations["Select_Zone"])
end

function TeleportModule:PopulateLocationDropdown(continentName, zoneName, panel)
    local locationDropdown = panel.locationDropdown
    UIDropDownMenu_Initialize(locationDropdown, function(dropdown, level, menuList)
        level = level or 1
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)
        local locTable = TeleportData[continentName] and TeleportData[continentName][zoneName]
        if not locTable then
            print("Aucun lieu pour la zone:", zoneName, "du continent:", continentName)
            return
        end

        for locationName, command in pairs(locTable) do
            local info = UIDropDownMenu_CreateInfo()
            info.text       = locationName
            info.value      = command
            info.isNotRadio = false
            info.r, info.g, info.b = 1,1,1
            info.checked    = (info.value == selectedValue)

            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(locationDropdown, button.value)
                UIDropDownMenu_SetText(locationDropdown, info.text)
                self.selectedCommand = button.value
                panel.goButton:Show()
            end

            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(locationDropdown, TrinityAdmin_Translations["Select_Location"])
end

function TeleportModule:TeleportTo(command)
    SendChatMessage(command, "SAY")
end
