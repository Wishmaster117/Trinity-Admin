local AddItem = TrinityAdmin:GetModule("AddItem")

-- Fonction pour afficher le panneau AddItem
function AddItem:ShowAddItemPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAddItemPanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau AddItem
function AddItem:CreateAddItemPanel()
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
            command = ".additem set",
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
            command = ".lookup item set",
            tooltip = "Syntax: .lookup itemset $itemsetname\n\nLooks up an item set by name (utilisez votre langue locale).",
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
	
    ------------------------------------------------------------
    -- Items Advanced ADD
    ------------------------------------------------------------	
    ------------------------------------------------------------
    -- Variables de pagination
    ------------------------------------------------------------
    local entriesPerPage = 100
    local currentPage = 1
    local currentOptions = {}  -- la liste courante (filtrée ou non)

    ------------------------------------------------------------
    -- Bouton "Retour" (pour revenir au menu principal)
    ------------------------------------------------------------
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetSize(80, 22)
    btnBack:SetText("Retour")
    btnBack:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    ------------------------------------------------------------
    -- Label "Game Objects Tools Advanced"
    ------------------------------------------------------------
    local advancedLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    advancedLabel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -20)
    advancedLabel:SetText("Item Set Advanced Add")

    ------------------------------------------------------------
    -- Champ de saisie pour filtrer la liste
    ------------------------------------------------------------
    local filterEditBox = CreateFrame("EditBox", "TrinityAdminGOFilterEditBox", panel, "InputBoxTemplate")
    filterEditBox:SetSize(150, 22)
    filterEditBox:SetPoint("TOPRIGHT", advancedLabel, "BOTTOMRIGHT", -20, -5)
    filterEditBox:SetText("Search...")

    ------------------------------------------------------------
    -- ScrollFrame + scrollChild
    ------------------------------------------------------------
    local scrollFrame = CreateFrame("ScrollFrame", "TrinityAdminGOScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(220, 200)
    -- Ancrage : en dessous du filterEditBox, en haut à droite du panel
    scrollFrame:SetPoint("TOPRIGHT", filterEditBox, "BOTTOMRIGHT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 50)

    local scrollChild = CreateFrame("Frame", "TrinityAdminGOScrollChild", scrollFrame)
    scrollChild:SetSize(220, 400) -- hauteur ajustée dynamiquement
    scrollFrame:SetScrollChild(scrollChild)

    ------------------------------------------------------------
    -- Boutons de pagination : Précédent, Suivant, et label Page
    ------------------------------------------------------------
    local btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnPrev:SetSize(80, 22)
    btnPrev:SetText("Preview")
    btnPrev:SetPoint("BOTTOM", panel, "BOTTOM", 110, 10)

    local btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnNext:SetSize(80, 22)
    btnNext:SetText("Next")
    btnNext:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)

    local btnPage = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnPage:SetSize(90, 22)
    btnPage:SetPoint("BOTTOM", panel, "BOTTOM", 200, 10)
    btnPage:SetText("Page 1 / 1")

    ------------------------------------------------------------
    -- Fonction PopulateGOScroll(options)
    ------------------------------------------------------------
    local function PopulateGOScroll(options)
        -- On mémorise la liste courante
        currentOptions = options

        -- Calcule nombre total d'entrées et de pages
        local totalEntries = #options
        local totalPages = math.ceil(totalEntries / entriesPerPage)
        if totalPages < 1 then totalPages = 1 end

        -- Ajuste currentPage si hors bornes
        if currentPage > totalPages then currentPage = totalPages end
        if currentPage < 1 then currentPage = 1 end

        -- Efface d'éventuels anciens boutons
        if scrollChild.buttons then
            for _, btn in ipairs(scrollChild.buttons) do
                btn:Hide()
            end
        else
            scrollChild.buttons = {}
        end

        -- Indices de début/fin pour la page courante
        local startIdx = (currentPage - 1) * entriesPerPage + 1
        local endIdx   = math.min(currentPage * entriesPerPage, totalEntries)

        -- Création des boutons
		local maxTextLength = 20 -- ?? Changez ce nombre pour ajuster la taille max
		local lastButton = nil
		for i = startIdx, endIdx do
			local option = options[i]
			local btn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
			btn:SetSize(200, 20)
		
			if not lastButton then
				btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -10)
			else
				btn:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -5)
			end
		
			-- Tronquer le texte s'il est trop long
			-- local fullText = option.name or ("Item "..i)
			local fullText = TrinityAdmin_Translations[option.name] or option.name or ("Item "..i) -- Modification pour traduction
			local truncatedText = fullText
			if #fullText > maxTextLength then
				truncatedText = fullText:sub(1, maxTextLength) .. "..."
			end
		
			btn:SetText(truncatedText)
		
			-- Ajouter un tooltip pour afficher le texte complet au survol
			btn:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(fullText, 1, 1, 1, 1, true)
				GameTooltip:Show()
			end)
			btn:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)
					
			btn:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
				if self.wowheadTooltip then
					self.wowheadTooltip:Hide()
				end
			end)

			btn:SetScript("OnClick", function()
				print("Option cliquée :", fullText, "Entry:", option.entry)
				SendChatMessage(".additem set " .. option.entry, "SAY")
			end)
		
			lastButton = btn
			table.insert(scrollChild.buttons, btn)
		end

        -- Ajuster la hauteur du scrollChild
        local visibleCount = endIdx - startIdx + 1
        local contentHeight = (visibleCount * 25) + 10
        scrollChild:SetHeight(contentHeight)

        -- Mettre à jour le label de page
        btnPage:SetText(currentPage.." / "..totalPages)

        -- Activer/désactiver Précédent/Suivant
        btnPrev:SetEnabled(currentPage > 1)
        btnNext:SetEnabled(currentPage < totalPages)
    end

    ------------------------------------------------------------
    -- Scripts de btnPrev / btnNext
    ------------------------------------------------------------
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            PopulateGOScroll(currentOptions)
        end
    end)

    btnNext:SetScript("OnClick", function()
        local totalPages = math.ceil(#currentOptions / entriesPerPage)
        if currentPage < totalPages then
            currentPage = currentPage + 1
            PopulateGOScroll(currentOptions)
        end
    end)

    ------------------------------------------------------------
    -- Remplissage initial (sans filtre)
    ------------------------------------------------------------
    local defaultOptions = {}
    -- Chargez *toutes* vos entrées, par exemple
    for i = 1, #ItemSetData do
        table.insert(defaultOptions, ItemSetData[i])
    end

    currentPage = 1
    PopulateGOScroll(defaultOptions)
	
	-- Recheche avec text Nothing found
	filterEditBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		local searchText = self:GetText():lower()
	
		-- Vérifie que l'utilisateur a saisi au moins 3 caractères
		if #searchText < 3 then
			print("Veuillez entrer au moins 3 caractères pour la recherche.")
			return
		end
	
		local filteredOptions = {}
		for _, option in ipairs(ItemSetData) do
			-- Vérifie si le texte est dans le "name" ou correspond à l'"entry"
			if (option.name and option.name:lower():find(searchText)) or
			(tostring(option.entry) == searchText) then
				table.insert(filteredOptions, option)
			end
		end
	
		-- Si aucun résultat n'est trouvé, afficher "Nothing found"
		if #filteredOptions == 0 then
			-- Supprime les anciens boutons si présents
			if scrollChild.buttons then
				for _, btn in ipairs(scrollChild.buttons) do
					btn:Hide()
				end
			end
			
			-- Si le texte "Nothing found" n'existe pas, le créer
			if not scrollChild.noResultText then
				scrollChild.noResultText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				scrollChild.noResultText:SetPoint("TOP", scrollChild, "TOP", 0, -10)
				scrollChild.noResultText:SetText("|cffff0000Nothing found|r") -- Texte en rouge
			end
			scrollChild.noResultText:Show()
	
			-- Ajuste la hauteur pour éviter l'affichage de contenu invisible
			scrollChild:SetHeight(50)
	
		else
			-- Cache le texte "Nothing found" s'il était affiché
			if scrollChild.noResultText then
				scrollChild.noResultText:Hide()
			end
			
			-- Charge les résultats normalement
			currentPage = 1
			PopulateGOScroll(filteredOptions)
		end
	end)

	------------------------------------------------------------
	-- Bouton "Reset" pour revenir à la liste complète
	------------------------------------------------------------
	local btnReset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnReset:SetSize(80, 22)
	btnReset:SetText("Reset")
	btnReset:SetPoint("RIGHT", filterEditBox, "RIGHT", -155, 0)
	btnReset:SetScript("OnClick", function()
		filterEditBox:SetText("")  -- Efface le champ de recherche
		currentPage = 1  -- Revient à la première page
		PopulateGOScroll(ItemSetData)  -- Recharge toute la liste
	
		-- Cacher le message "Nothing found" s'il est affiché
		if scrollChild.noResultText then
			scrollChild.noResultText:Hide()
		end
	end)

    ------------------------------------------------------------
    -- Enfin, on mémorise ce panel dans self.panel
    ------------------------------------------------------------
	
    self.panel = panel
end
