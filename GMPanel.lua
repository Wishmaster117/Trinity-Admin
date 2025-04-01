local GMModule = TrinityAdmin:GetModule("GMPanel")

function GMModule:ShowGMPanel()
    TrinityAdmin:HideMainMenu()
    if not self.gmPanel then
        self:CreateGMPanel()
    end
    self.gmPanel:Show()
end

function GMModule:CreateGMPanel()
    local panel = CreateFrame("Frame", "TrinityAdminGMPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(TrinityAdmin_Translations["GM Functions Panel"])

    -- Champ de saisie
    local modifyInput = CreateFrame("EditBox", "TrinityAdminModifyInput", panel, "InputBoxTemplate")
    modifyInput:SetSize(80, 22)
    modifyInput:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)
    modifyInput:SetAutoFocus(false)
    modifyInput:SetText("Enter Value")
    modifyInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Dropdown principal
    local modifyDropdown = CreateFrame("Frame", "TrinityAdminModifyDropdown", panel, "UIDropDownMenuTemplate")
    modifyDropdown:SetPoint("LEFT", modifyInput, "RIGHT", 0, -2)

    -- Dropdown supplémentaire pour "Speed"
    local speedOptions = { "Choose", "all", "backwalk", "fly", "swim", "walk" }
    local speedDropdown = CreateFrame("Frame", "TrinityAdminSpeedDropdown", panel, "UIDropDownMenuTemplate")
	
    speedDropdown:SetPoint("LEFT", modifyDropdown, "RIGHT", 120, 0) -- ancré à la droite de la dropdown principale
    speedDropdown:Hide()  -- masquée par défaut
	UIDropDownMenu_SetWidth(speedDropdown, 60)  -- Définissez ici la largeur souhaitée
	
    UIDropDownMenu_Initialize(speedDropdown, function(dropdown, level, menuList)
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown) or "Choose"
        local info = UIDropDownMenu_CreateInfo()
        for _, option in ipairs(speedOptions) do
            info.text = option
            info.value = option
            info.isNotRadio = false
            info.r, info.g, info.b = 1, 1, 1
            info.checked = (option == selectedValue)
            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(dropdown, button.value)
                UIDropDownMenu_SetText(dropdown, button.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(speedDropdown, "Choose")

    -- Définition des options de la dropdown principale
    local options = {
        "Choose",
        "Speed",
        "Money",
        "Hp",
        "Xp",
        "Scale",
        "Currency",
        "Faction",
        "Gender",
        "honor",
        "energy",
        "drunk",
        "mana",
        "mount",
        "phase",
        "power",
        "rage",
        "reputation",
        "runicpower",
        "spell",
        "standstate",
        "talentpoints"
    }

    local displayNames = {
        Choose = TrinityAdmin_Translations["Choose"] or "Choose",
        Speed = TrinityAdmin_Translations["Speed"],
        Money = TrinityAdmin_Translations["Money"],
        Hp = TrinityAdmin_Translations["Hp"],
        Xp = TrinityAdmin_Translations["Xp"],
        Scale = TrinityAdmin_Translations["Scale"],
        Currency = TrinityAdmin_Translations["Currency"],
        Faction = TrinityAdmin_Translations["Faction"],
        Gender = TrinityAdmin_Translations["Gender"],
        honor = TrinityAdmin_Translations["honor"],
        energy = TrinityAdmin_Translations["energy"],
        drunk = TrinityAdmin_Translations["drunk"],
        mana = TrinityAdmin_Translations["mana"],
        mount = TrinityAdmin_Translations["mount"],
        phase = TrinityAdmin_Translations["phase"],
        power = TrinityAdmin_Translations["power"],
        rage = TrinityAdmin_Translations["rage"],
        reputation = TrinityAdmin_Translations["reputation"],
        runicpower = TrinityAdmin_Translations["runicpower"],
        spell = TrinityAdmin_Translations["spell"],
        standstate = TrinityAdmin_Translations["standstate"],
        talentpoints = TrinityAdmin_Translations["talentpoints"]
    }

    local tooltipTexts = {
        Speed = TrinityAdmin_Translations["Modify_Speed"],
        Money = TrinityAdmin_Translations["Modify_Money"],
        Hp = TrinityAdmin_Translations["Modify_HP"],
        Xp = TrinityAdmin_Translations["Modify_XP"],
        Scale = TrinityAdmin_Translations["Modify_Scale"],
        Currency = TrinityAdmin_Translations["Add_Money"],
        Faction = TrinityAdmin_Translations["Modify_Faction"],
        Gender = TrinityAdmin_Translations["Modify_Gender"],
        honor = TrinityAdmin_Translations["Modify_honor"],
        energy = TrinityAdmin_Translations["Modify_energy"],
        drunk = TrinityAdmin_Translations["Modify_drunk"],
        mana = TrinityAdmin_Translations["Modify_mana"],
        mount = TrinityAdmin_Translations["Modify_mount"],
        phase = TrinityAdmin_Translations["Modify_phase"],
        power = TrinityAdmin_Translations["Modify_power"],
        rage = TrinityAdmin_Translations["Modify_rage"],
        reputation = TrinityAdmin_Translations["Modify_reputation"],
        runicpower = TrinityAdmin_Translations["Modify_runicpower"],
        spell = TrinityAdmin_Translations["Modify_spell"],
        standstate = TrinityAdmin_Translations["Modify_standstate"],
        talentpoints = TrinityAdmin_Translations["Modify_talentpoints"]
    }

    -- Déclaration anticipée du bouton "Set"
    local btnSet = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnSet:SetHeight(22)
    btnSet:SetWidth(btnSet:GetTextWidth() + 20)
    -- L'ancrage initial sera défini dans le callback

    UIDropDownMenu_Initialize(modifyDropdown, function(dropdown, level, menuList)
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown) or "Choose"
        local info = UIDropDownMenu_CreateInfo()
        for _, option in ipairs(options) do
            info.text = displayNames[option] or option
            info.value = option
            info.isNotRadio = false
            info.r, info.g, info.b = 1, 1, 1
            info.checked = (info.value == selectedValue)
            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(dropdown, button.value)
                UIDropDownMenu_SetText(dropdown, displayNames[button.value] or button.value)
                TrinityAdmin.modifyFunction = button.value
                print("DEBUG: Fonction sélectionnée = " .. tostring(TrinityAdmin.modifyFunction))
                if button.value == "Speed" then
                    speedDropdown:Show()
                    btnSet:ClearAllPoints()
                    btnSet:SetPoint("LEFT", speedDropdown, "RIGHT", 20, 2)
                else
                    speedDropdown:Hide()
                    btnSet:ClearAllPoints()
                    btnSet:SetPoint("LEFT", modifyDropdown, "RIGHT", 120, 2)
                end
                if tooltipTexts[button.value] then
                    modifyInput:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        -- GameTooltip:SetText(tooltipTexts[button.value], 1, 1, 1)
						GameTooltip:SetText(tostring(tooltipTexts[button.value]), 1, 1, 1)
                        GameTooltip:Show()
                    end)
                    modifyInput:SetScript("OnLeave", function(self)
                        GameTooltip:Hide()
                    end)
                else
                    modifyInput:SetScript("OnEnter", nil)
                    modifyInput:SetScript("OnLeave", nil)
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    local selectedValue = "Choose"
    UIDropDownMenu_SetText(modifyDropdown, displayNames[selectedValue] or selectedValue)

    -- Position initiale du bouton "Set" (cas par défaut)
    btnSet:SetPoint("LEFT", modifyDropdown, "RIGHT", 120, 2)
    btnSet:SetText("Set")
	btnSet:SetWidth(btnSet:GetTextWidth() + 20)
    btnSet:SetScript("OnClick", function()
        local value = modifyInput:GetText()
        if value == "" or value == "Enter Value" or value == "Choose" then
            print(TrinityAdmin_Translations["Enter_Valid_Value"])
            return
        end

        local func = TrinityAdmin.modifyFunction or "Speed"
        local command

        if func == "Currency" then
            local id, amount = string.match(value, "(%S+)%s+(%S+)")
            if not id or not amount then
                print(TrinityAdmin_Translations["Enter_Valid_Currency"])
                return
            end
            command = ".modify currency " .. id .. " " .. amount
		elseif func == "Speed" then
			local speedParam = UIDropDownMenu_GetSelectedValue(speedDropdown) or "Choose"
			if speedParam ~= "Choose" then
				command = ".modify speed " .. speedParam .. " " .. value
			else
				command = ".modify speed " .. value
			end
        else
            command = ".modify " .. func .. " " .. value
        end
        print("Commande de sortie: " .. command)
        SendChatMessage(command, "SAY")
		modifyInput:SetText("Enter Value")  -- Remise à zéro du texte de saisie
    end)

    -- Bouton Back
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.gmPanel = panel
end
