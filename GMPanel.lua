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

    -- Dropdown
    local modifyDropdown = CreateFrame("Frame", "TrinityAdminModifyDropdown", panel, "TrinityAdminDropdownTemplate")
    modifyDropdown:SetPoint("LEFT", modifyInput, "RIGHT", 10, 0)

    -- Définir les options globalement
    local options = {
        "Choose",
        "Speed",
        "Money",
        "Hp",
        "Xp",
        "Scale",
        "Currency",
		"Faction",
		"Gender"
    }

    -- Définir displayNames en dehors pour éviter l'erreur
    local displayNames = {
        Choose = TrinityAdmin_Translations["Choose"] or "Choose",
        Speed = TrinityAdmin_Translations["Speed"],
        Money = TrinityAdmin_Translations["Money"],
        Hp = TrinityAdmin_Translations["Hp"],
        Xp = TrinityAdmin_Translations["Xp"],
        Scale = TrinityAdmin_Translations["Scale"],
        Currency = TrinityAdmin_Translations["Currency"],
		Faction = TrinityAdmin_Translations["Faction"],
		Gender = TrinityAdmin_Translations["Gender"]
    }

    local tooltipTexts = {
        Speed = TrinityAdmin_Translations["Modify_Speed"],
        Money = TrinityAdmin_Translations["Modify_Money"],
        Hp = TrinityAdmin_Translations["Modify_HP"],
        Xp = TrinityAdmin_Translations["Modify_XP"],
        Scale = TrinityAdmin_Translations["Modify_Scale"],
        Currency = TrinityAdmin_Translations["Add_Money"],
		Faction = TrinityAdmin_Translations["Modify_Faction"],
		Gender = TrinityAdmin_Translations["Modify_Gender"]
    }

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

                -- Vérifie si un tooltip est défini pour l'option sélectionnée
                if tooltipTexts[button.value] then
                    modifyInput:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(tooltipTexts[button.value], 1, 1, 1)
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

    -- Utiliser selectedValue pour afficher "Choose" par défaut
    local selectedValue = "Choose"
    UIDropDownMenu_SetText(modifyDropdown, displayNames[selectedValue] or selectedValue)

    -- Bouton "Set"
    local btnSet = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnSet:SetSize(60, 22)
    btnSet:SetPoint("LEFT", modifyDropdown, "RIGHT", 10, 0)
    btnSet:SetText("Set")
    btnSet:SetHeight(22)
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
        else
            command = ".modify " .. func .. " " .. value
        end

        SendChatMessage(command, "SAY")
    end)

    -- Bouton Back
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText("Back")
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.gmPanel = panel
end