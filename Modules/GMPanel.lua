local GMModule = TrinityAdmin:GetModule("GMPanel")
local L = _G.L

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
    panel.title:SetText(L["GM Functions Panel"])

    -- Champ de saisie
    local modifyInput = CreateFrame("EditBox", "TrinityAdminModifyInput", panel, "InputBoxTemplate")
    modifyInput:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)
    modifyInput:SetAutoFocus(false)
    modifyInput:SetText(L["Adm Enter Value"])
	TrinityAdmin.AutoSize(modifyInput, 20, 13)
    modifyInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Dropdown principal
    local modifyDropdown = CreateFrame("Frame", "TrinityAdminModifyDropdown", panel, "UIDropDownMenuTemplate")
    modifyDropdown:SetPoint("LEFT", modifyInput, "RIGHT", 0, -2)

    -- Dropdown supplémentaire pour "Speed"
    local speedOptions = { "Choose", "all", "backwalk", "fly", "swim", "walk" }
    local speedDropdown = CreateFrame("Frame", "TrinityAdminSpeedDropdown", panel, "UIDropDownMenuTemplate")
	
    speedDropdown:SetPoint("LEFT", modifyDropdown, "RIGHT", 120, 0)
    speedDropdown:Hide()  -- masquée par défaut
	UIDropDownMenu_SetWidth(speedDropdown, 60)  -- Définission de la largeur de la drop
	
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
        Choose = L["Choose"] or "Choose",
        Speed = L["Speed"],
        Money = L["Money"],
        Hp = L["Hp"],
        Xp = L["Xp"],
        Scale = L["Scale"],
        Currency = L["Currency"],
        Faction = L["Faction"],
        Gender = L["Gender"],
        honor = L["honor"],
        energy = L["energy"],
        drunk = L["drunk"],
        mana = L["mana"],
        mount = L["mount"],
        phase = L["phase"],
        power = L["power"],
        rage = L["rage"],
        reputation = L["reputation"],
        runicpower = L["runicpower"],
        spell = L["spell"],
        standstate = L["standstate"],
        talentpoints = L["talentpoints"]
    }

    local tooltipTexts = {
        Speed = L["Modify_Speed"],
        Money = L["Modify_Money"],
        Hp = L["Modify_HP"],
        Xp = L["Modify_XP"],
        Scale = L["Modify_Scale"],
        Currency = L["Add_Money"],
        Faction = L["Modify_Faction"],
        Gender = L["Modify_Gender"],
        honor = L["Modify_honor"],
        energy = L["Modify_energy"],
        drunk = L["Modify_drunk"],
        mana = L["Modify_mana"],
        mount = L["Modify_mount"],
        phase = L["Modify_phase"],
        power = L["Modify_power"],
        rage = L["Modify_rage"],
        reputation = L["Modify_reputation"],
        runicpower = L["Modify_runicpower"],
        spell = L["Modify_spell"],
        standstate = L["Modify_standstate"],
        talentpoints = L["Modify_talentpoints"]
    }

    -- Déclaration anticipée du bouton "Set"
    local btnSet = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")

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
                -- print("DEBUG: Fonction sélectionnée = " .. tostring(TrinityAdmin.modifyFunction))
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

    -- Position initiale du bouton "Set"
    btnSet:SetPoint("LEFT", modifyDropdown, "RIGHT", 120, 2)
    btnSet:SetText(L["Set"])
	TrinityAdmin.AutoSize(btnSet, 20, 16)
    btnSet:SetScript("OnClick", function()
        local value = modifyInput:GetText()
        if value == "" or value == L["Adm Enter Value"] or value == "Choose" then
            TrinityAdmin:Print(L["Enter_Valid_Value"])
            return
        end

        local func = TrinityAdmin.modifyFunction or "Speed"
        local command

        if func == "Currency" then
            local id, amount = string.match(value, "(%S+)%s+(%S+)")
            if not id or not amount then
                TrinityAdmin:Print(L["Enter_Valid_Currency"])
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
        -- print("Commande de sortie: " .. command)
        SendChatMessage(command, "SAY")
		modifyInput:SetText(L["Adm Enter Value"])  -- Remise à zéro du texte de saisie
    end)

    -- Bouton Back
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(L["Back"])
	TrinityAdmin.AutoSize(btnBack, 20, 16)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.gmPanel = panel
end
