local AddLearn = TrinityAdmin:GetModule("AddLearn")

-- Fonction pour afficher le panneau AddLearn
function AddLearn:ShowAddLearnPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAddLearnPanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau AddLearn
function AddLearn:CreateAddLearnPanel()
    local panel = CreateFrame("Frame", "TrinityAdminAddLearnPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Add Learn Panel")

    -- Section: Game Objects Tools
    local toolsTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    toolsTitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -20)
    toolsTitle:SetText("Advanced Add Functions")
    --------------------------------------------------------------------------------
    -- Création des trois champs de saisie
    --------------------------------------------------------------------------------
    local input1 = CreateFrame("EditBox", "TrinityAdminAddLearnInput1", panel, "InputBoxTemplate")
    input1:SetSize(150, 22)
    input1:SetPoint("TOPLEFT", toolsTitle, "BOTTOMLEFT", 10, -20)
    input1:SetText("Choose a action")  -- Valeur par défaut générale

    local input2 = CreateFrame("EditBox", "TrinityAdminAddLearnInput2", panel, "InputBoxTemplate")
    input2:SetSize(150, 22)
    input2:SetPoint("TOPLEFT", input1, "BOTTOMLEFT", 0, -10)
    input2:SetText("Choose a action")

    local input3 = CreateFrame("EditBox", "TrinityAdminAddLearnInput3", panel, "InputBoxTemplate")
    input3:SetSize(150, 22)
    input3:SetPoint("TOPLEFT", input2, "BOTTOMLEFT", 0, -10)
    input3:SetText("Choose a action")

    --------------------------------------------------------------------------------
    -- Création du menu déroulant
    --------------------------------------------------------------------------------
    local dropdown = CreateFrame("Frame", "TrinityAdminAddLearnDropdown", panel, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", toolsTitle, "BOTTOMLEFT", 160, -20)
    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_SetButtonWidth(dropdown, 170)
    
    -- Options du menu déroulant avec leur commande, tooltip et valeurs par défaut pour les 3 zones de saisie
    local ddOptions = {
        {
            text = "additem",
            command = ".additem",
            tooltip = "Syntax: .additem #itemid/[#itemname] #itemcount #bonusListIDs\n\nAdds the specified number of items to inventory. (#itemcount and #bonusListIDs are optional)",
            defaults = { "ID or Name", "How many?", "BonusList id's separated by ;" }
        },
        {
            text = "additem set",
            command = ".additemset",
            tooltip = "Syntax: .additemset #itemsetid #bonusListIDs\n\nAdds items from an item set. (#bonusListIDs is optional)",
            defaults = { "ItemSet ID", "Don't use", "BonusList id's separated by ;" }
        },
        {
            text = "lookup item",
            command = ".lookup item",
            tooltip = "Syntax: .lookup item $itemname\n\nLooks up an item by name (utilisez votre langue locale).",
            defaults = { "Item Name", "Don't use", "Don't use" }
        },
        {
            text = "lookup item id",
            command = ".lookup item",
            tooltip = "Syntax: .lookup item $itemid\n\nLooks up an item by its ID.",
            defaults = { "Item ID", "Don't use", "Don't use" }
        },
        {
            text = "lookup item set",
            command = ".lookup itemset",
            tooltip = "Syntax: .lookup itemset $itemname\n\nLooks up an item set by name (utilisez votre langue locale).",
            defaults = { "Item Name", "", "" }
        },
    }
    local selectedOption = ddOptions[1]  -- Option par défaut

    -- UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
    --     local info = UIDropDownMenu_CreateInfo()
    --     for i, option in ipairs(ddOptions) do
    --         info.text = option.text
    --         info.value = option.command
    --         -- info.checked = (i == 1)
	-- 		info.checked = (UIDropDownMenu_GetSelectedID(dropdown) == i)
    --         info.func = function(button)
    --             UIDropDownMenu_SetSelectedID(dropdown, i)
    --             UIDropDownMenu_SetText(dropdown, option.text)
    --             selectedOption = option
    --             -- Met à jour les zones de saisie selon l'option sélectionnée
    --             input1:SetText(option.defaults[1])
    --             input2:SetText(option.defaults[2])
    --             input3:SetText(option.defaults[3])
    --             -- Masquer les champs inutiles
    --             if option.defaults[2] == "Don't use" or option.defaults[2] == "" then
    --                 input2:Hide()
    --             else
    --                 input2:Show()
    --             end
    --             if option.defaults[3] == "Don't use" or option.defaults[3] == "" then
    --                 input3:Hide()
    --             else
    --                 input3:Show()
    --             end
    --         end
    --         UIDropDownMenu_AddButton(info, level)
    --     end
    -- end)
	-- -- Partie des textes par defaut quand on ouvre la frame
	-- UIDropDownMenu_SetText(dropdown, "Choose")
    -- -- UIDropDownMenu_SetSelectedID(dropdown, 1)
    -- -- UIDropDownMenu_SetText(dropdown, ddOptions[1].text)
	UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		for i, option in ipairs(ddOptions) do
			info.text = option.text
			info.value = option.command
			info.checked = (UIDropDownMenu_GetSelectedID(dropdown) == i)
			info.func = function(button)
				UIDropDownMenu_SetSelectedID(dropdown, i)
				UIDropDownMenu_SetText(dropdown, option.text)
				selectedOption = option
				-- Mettre à jour les zones de saisie selon l'option sélectionnée
				input1:SetText(option.defaults[1])
				input2:SetText(option.defaults[2])
				input3:SetText(option.defaults[3])
				if option.defaults[2] == "Don't use" or option.defaults[2] == "" then
					input2:Hide()
				else
					input2:Show()
				end
				if option.defaults[3] == "Don't use" or option.defaults[3] == "" then
					input3:Hide()
				else
					input3:Show()
				end
	
				-- Pour l'option "additem", ajouter un tooltip Wowhead sur le champ input1
				if option.text == "additem" then
					input1:SetScript("OnEnter", function(self)
						local text = self:GetText()
						local itemID = tonumber(text)
						if itemID then
							-- Créez un lien formaté pour Wowhead ; si l'addon Wowhead Tooltips est installé,
							-- il devrait reconnaître ce format et afficher le tooltip approprié.
							local link = "|cffffffff|Hwowhead:item:" .. itemID .. "|h[Item " .. itemID .. "]|h|r"
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
							GameTooltip:SetHyperlink(link)
							GameTooltip:Show()
						end
					end)
					input1:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
				else
					input1:SetScript("OnEnter", nil)
					input1:SetScript("OnLeave", nil)
				end
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end)
	UIDropDownMenu_SetText(dropdown, "Choose")
	-- UIDropDownMenu_SetSelectedID(dropdown, 1)
	-- UIDropDownMenu_SetText(dropdown, ddOptions[1].text)


    -- Affichage du tooltip sur le menu déroulant
    dropdown:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(selectedOption.tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    dropdown:SetScript("OnLeave", function() GameTooltip:Hide() end)

    --------------------------------------------------------------------------------
    -- Bouton "Go"
    --------------------------------------------------------------------------------
    local btnGo = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnGo:SetSize(60, 22)
    btnGo:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 35, -10)
    btnGo:SetText("Go")
    btnGo:SetScript("OnClick", function()
        local v1 = input1:GetText()
        local v2 = input2:IsShown() and input2:GetText() or ""
        local v3 = input3:IsShown() and input3:GetText() or ""
        local args = {}
        -- Pour lookup, seule la première zone est utilisée
        if selectedOption.text == "lookup item" or selectedOption.text == "lookup item id" or selectedOption.text == "lookup item set" then
            if v1 == "" or v1 == selectedOption.defaults[1] then
                print("Veuillez remplir le champ requis.")
                return
            end
            args = { v1 }
        elseif selectedOption.text == "additem" then
            if v1 == "" or v1 == selectedOption.defaults[1] then
                print("Le champ 'ID or Name' est obligatoire.")
                return
            end
            table.insert(args, v1)
            if input2:IsShown() and v2 ~= "" and v2 ~= selectedOption.defaults[2] then
                table.insert(args, v2)
            end
            if input3:IsShown() and v3 ~= "" and v3 ~= selectedOption.defaults[3] then
                table.insert(args, v3)
            end
        elseif selectedOption.text == "additem set" then
            if v1 == "" or v1 == selectedOption.defaults[1] then
                print("Le champ 'ItemSet ID' est obligatoire.")
                return
            end
            table.insert(args, v1)
            if input3:IsShown() and v3 ~= "" and v3 ~= selectedOption.defaults[3] then
                table.insert(args, v3)
            end
        end
        local finalCommand = selectedOption.command .. " " .. table.concat(args, " ")
        print("Commande envoyée: " .. finalCommand)
        SendChatMessage(finalCommand, "SAY")
    end)

	------------------------------------------------------------------------------
    -- Bouton "Clean" à côté de "Go" qui réinitialise les champs de saisie
    ------------------------------------------------------------------------------
    local btnClean = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnClean:SetSize(60, 22)
    btnClean:SetPoint("TOPLEFT", btnGo, "TOPRIGHT", 10, 0)
    btnClean:SetText("Clean")
    btnClean:SetScript("OnClick", function()
        -- Réinitialiser les champs aux valeurs par défaut de l'option sélectionnée
        input1:SetText(selectedOption.defaults[1])
        input2:SetText(selectedOption.defaults[2])
        input3:SetText(selectedOption.defaults[3])
        -- Masquer ou afficher les champs selon leur valeur par défaut
        if selectedOption.defaults[2] == "Don't use" or selectedOption.defaults[2] == "" then
            input2:Hide()
        else
            input2:Show()
        end
        if selectedOption.defaults[3] == "Don't use" or selectedOption.defaults[3] == "" then
            input3:Hide()
        else
            input3:Show()
        end
    end)
	
    --------------------------------------------------------------------------------
    -- Bouton "Back"
    --------------------------------------------------------------------------------
    local btnBack = CreateFrame("Button", "TrinityAdminAddLearnBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
