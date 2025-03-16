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
