local L = _G.L
local TrinityAdmin = LibStub("AceAddon-3.0"):GetAddon("TrinityAdmin")
local AddItem = TrinityAdmin:GetModule("AddItem")
local L = LibStub("AceLocale-3.0"):GetLocale("TrinityAdmin")

---------------------------------------------------
-- Ajout pour trouver ytraductions manquantes
---------------------------------------------------
-- Table pour stocker toutes les clés de traduction qui manquent
local MissingKeys = {}

-- Wrapper : si la clé n'existe pas dans L, on la garde en mémoire (MissingKeys) et on renvoie le texte brut
local function SafeL(key)
    if not key then
        return ""
    end
    -- Vérifie si la clé est traduite dans L
    local val = L[key]
    if not val then
        -- On enregistre la clé manquante (pour la signaler plus tard)
        MissingKeys[key] = true
        -- On renvoie tout de même la clé brute
        return key
    end
    return val
end
-- Fin ajout

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
    panel.title:SetText(L["Add Item Module"])

    -- Section: Game Objects Tools
    local toolsTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    toolsTitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -20)
    toolsTitle:SetText(L["Advanced Add Functions"])
    --------------------------------------------------------------------------------
    -- Création des trois champs de saisie
    --------------------------------------------------------------------------------
    local input1 = CreateFrame("EditBox", "TrinityAdminAddLearnInput1", panel, "InputBoxTemplate")
    -- input1:SetSize(150, 22)
    input1:SetPoint("TOPLEFT", toolsTitle, "BOTTOMLEFT", 10, -20)
    input1:SetText(L["Choose a action"])  -- Valeur par défaut générale
	TrinityAdmin.AutoSize(input1, 20, 13, nil, 120)

    local input2 = CreateFrame("EditBox", "TrinityAdminAddLearnInput2", panel, "InputBoxTemplate")
    -- input2:SetSize(150, 22)
    input2:SetPoint("TOPLEFT", input1, "BOTTOMLEFT", 0, -10)
    input2:SetText(L["Choose a action"])
	TrinityAdmin.AutoSize(input2, 20, 13, nil, 120)

    local input3 = CreateFrame("EditBox", "TrinityAdminAddLearnInput3", panel, "InputBoxTemplate")
    -- input3:SetSize(150, 22)
    input3:SetPoint("TOPLEFT", input2, "BOTTOMLEFT", 0, -10)
    input3:SetText(L["Choose a action"])
	TrinityAdmin.AutoSize(input3, 20, 13, nil, 120)

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
            tooltip = L["AdditemSyntax"],
            defaults = { L["ID or Name"], L["How many?"], L["BonusList id's separated by ;"] }
        },
        {
            text = "additem set",
            command = ".additem set",
            tooltip = "Syntax: .additemset #itemsetid #bonusListIDs\n\nAdds items from an item set. (#bonusListIDs is optional)",
            defaults = { L["ItemSet ID"], L["Don't use"], L["BonusList id's separated by ;"] }
        },
        {
            text = "lookup item",
            command = ".lookup item",
            tooltip = "Syntax: .lookup item $itemname\n\nLooks up an item by name (utilisez votre langue locale).",
            defaults = { L["Item Name"], L["Don't use"], L["Don't use"] }
        },
        {
            text = "lookup item id",
            command = ".lookup item",
            tooltip = "Syntax: .lookup item $itemid\n\nLooks up an item by its ID.",
            defaults = { L["Item ID"], L["Don't use"], L["Don't use"] }
        },
        {
            text = "lookup item set",
            command = ".lookup item set",
            tooltip = "Syntax: .lookup itemset $itemsetname\n\nLooks up an item set by name (utilisez votre langue locale).",
            defaults = { L["Item Name"], "", "" }
        },
    }
    local selectedOption = ddOptions[1]  -- Option par défaut

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
				TrinityAdmin.AutoSize(input1, 20, 13, nil, 120)
				input2:SetText(option.defaults[2])
				TrinityAdmin.AutoSize(input2, 20, 13, nil, 120)
				input3:SetText(option.defaults[3])
				TrinityAdmin.AutoSize(input3, 20, 13, nil, 120)
				if option.defaults[2] == L["Don't use"] or option.defaults[2] == "" then
					input2:Hide()
				else
					input2:Show()
				end
				if option.defaults[3] == L["Don't use"] or option.defaults[3] == "" then
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
	UIDropDownMenu_SetText(dropdown, L["Choose"])
	
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
    -- btnGo:SetSize(60, 22)
    btnGo:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 15, 0)
    btnGo:SetText(L["Execute3"])
	TrinityAdmin.AutoSize(btnGo, 20, 16)
    btnGo:SetScript("OnClick", function()
        local v1 = input1:GetText()
        local v2 = input2:IsShown() and input2:GetText() or ""
        local v3 = input3:IsShown() and input3:GetText() or ""
        local args = {}
        -- Pour lookup, seule la première zone est utilisée
        if selectedOption.text == "lookup item" or selectedOption.text == "lookup item id" or selectedOption.text == "lookup item set" then
            if v1 == "" or v1 == selectedOption.defaults[1] then
                TrinityAdmin:Print(L["Please fill in the required field."])
                return
            end
            args = { v1 }
        elseif selectedOption.text == "additem" then
            if v1 == "" or v1 == selectedOption.defaults[1] then
                TrinityAdmin:Print(L["The 'ID or Name' field is required."])
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
                TrinityAdmin:Print(L["The 'ItemSet ID' field is required."])
                return
            end
            table.insert(args, v1)
            if input3:IsShown() and v3 ~= "" and v3 ~= selectedOption.defaults[3] then
                table.insert(args, v3)
            end
        end
        local finalCommand = selectedOption.command .. " " .. table.concat(args, " ")
        -- print("Commande envoyée: " .. finalCommand)-- Pour debug
        TrinityAdmin:SendCommand(finalCommand)
    end)

	------------------------------------------------------------------------------
    -- Bouton "Clean" à côté de "Go" qui réinitialise les champs de saisie
    ------------------------------------------------------------------------------
    local btnClean = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnClean:SetSize(60, 22)
    btnClean:SetPoint("TOPLEFT", btnGo, "TOPRIGHT", 10, 0)
    btnClean:SetText(L["Clean"])
	TrinityAdmin.AutoSize(btnClean, 20, 16)
    btnClean:SetScript("OnClick", function()
        -- Réinitialiser les champs aux valeurs par défaut de l'option sélectionnée
        input1:SetText(selectedOption.defaults[1])
        input2:SetText(selectedOption.defaults[2])
        input3:SetText(selectedOption.defaults[3])
        -- Masquer ou afficher les champs selon leur valeur par défaut
        if selectedOption.defaults[2] == L["Don't use"] or selectedOption.defaults[2] == "" then
            input2:Hide()
        else
            input2:Show()
        end
        if selectedOption.defaults[3] == L["Don't use"] or selectedOption.defaults[3] == "" then
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
    -- btnBack:SetSize(80, 22)
    btnBack:SetText(L["Back"])
	TrinityAdmin.AutoSize(btnBack, 20, 16)
    btnBack:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    ------------------------------------------------------------
    -- Label "Game Objects Tools Advanced"
    ------------------------------------------------------------
    local advancedLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    advancedLabel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -40, -20)
    advancedLabel:SetText(L["Item Set Easy Add"])

    ------------------------------------------------------------
    -- Champ de saisie pour filtrer la liste
    ------------------------------------------------------------
    local filterEditBox = CreateFrame("EditBox", "TrinityAdminGOFilterEditBox", panel, "InputBoxTemplate")
    -- filterEditBox:SetSize(150, 22)
    filterEditBox:SetPoint("TOPRIGHT", advancedLabel, "BOTTOMRIGHT", -20, -5)
    filterEditBox:SetText(L["Search..."])
	TrinityAdmin.AutoSize(filterEditBox, 20, 13, nil, 150)

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
    -- btnPrev:SetSize(80, 22)
    btnPrev:SetText(L["Pagination_Preview"])
	TrinityAdmin.AutoSize(btnPrev, 20, 16)
    btnPrev:SetPoint("BOTTOM", panel, "BOTTOM", 110, 10)

    local btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnNext:SetSize(80, 22)
    btnNext:SetText(L["Next"])
	TrinityAdmin.AutoSize(btnNext, 20, 16)
    btnNext:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)

    local btnPage = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnPage:SetSize(90, 22)
    btnPage:SetPoint("BOTTOM", panel, "BOTTOM", 200, 10)
    btnPage:SetText("Page 1 / 1")
	TrinityAdmin.AutoSize(btnPage, 20, 16)

------------------------------------------------------------
-- Fonction pour chopper les cles manquantes de traduction
------------------------------------------------------------
-- Table pour lister les clés manquantes
local MissingKeys = {}

-- Wrapper pour récupérer une traduction L[key]
-- Si la clé est absente, on la stocke dans MissingKeys
-- et on renvoie la valeur brute.
local function SafeL(key)
    if not key then
        return ""
    end

    local val = L[key]
    if not val then
        -- On note la clé manquante dans MissingKeys
        MissingKeys[key] = true
        -- On retourne quand même la clé brute
        return key
    end
    return val
end

------------------------------------------------------------
-- Fonction PopulateGOScroll(options) - modifiée pour chopper les cles manquantes de traduction
------------------------------------------------------------
local function PopulateGOScroll(options)
    -- On mémorise la liste courante
    currentOptions = options

    -- Calcule nombre total d'entrées et de pages
    local totalEntries = #options
    local totalPages   = math.ceil(totalEntries / entriesPerPage)
    if totalPages < 1 then
        totalPages = 1
    end

    -- Ajuste currentPage si hors bornes
    if currentPage > totalPages then
        currentPage = totalPages
    end
    if currentPage < 1 then
        currentPage = 1
    end

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
    local maxTextLength = 20
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

        -- On récupère le texte via SafeL (pour marquer les clés manquantes)
        local rawText = option.name
        local textToShow = SafeL(rawText)  -- renvoie L[rawText] ou la clé brute si manquante

        -- Si SafeL renvoie la chaîne vide (rawText = nil), on prend "Item .. i"
        if textToShow == "" then
            textToShow = "Item " .. i
        end

        -- Tronquer le texte s'il est trop long
        local truncatedText = textToShow
        if #textToShow > maxTextLength then
            truncatedText = textToShow:sub(1, maxTextLength) .. "..."
        end

        btn:SetText(truncatedText)

        -- Tooltip : on affiche le texte complet
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(textToShow, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            if self.wowheadTooltip then
                self.wowheadTooltip:Hide()
            end
        end)

        -- Lorsqu'on clique sur le bouton
        btn:SetScript("OnClick", function()
            -- print("Option cliquée :", textToShow, "Entry:", option.entry)
            -- SendChatMessage(".additem set " .. option.entry, "SAY")
			TrinityAdmin:SendCommand('.additem set  ' .. option.entry)
        end)

        lastButton = btn
        table.insert(scrollChild.buttons, btn)
    end

    -- Ajuster la hauteur du scrollChild
    local visibleCount = endIdx - startIdx + 1
    local contentHeight = (visibleCount * 25) + 10
    scrollChild:SetHeight(contentHeight)

    -- Mettre à jour le label de page
    btnPage:SetText(currentPage .. " / " .. totalPages)

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
    -- print("[DEBUG]Nombre d'items dans ItemSetData: " .. #ItemSetData)
    currentPage = 1
    PopulateGOScroll(defaultOptions)
	
	-- Recheche avec text Nothing found
	filterEditBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		local searchText = self:GetText():lower()
	
		-- Vérifie que l'utilisateur a saisi au moins 3 caractères
		if #searchText < 3 then
			TrinityAdmin:Print(L["Please enter at least 3 characters for the search."])
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
				scrollChild.noResultText:SetText("|cffff0000" .. L["Nothing found"] .. "|r") -- Texte en rouge
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
	-- btnReset:SetSize(80, 22)
	btnReset:SetText(L["Reset"])
	TrinityAdmin.AutoSize(btnReset, 20, 16)
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

	-- 3) Commande ajoutée pour voir si il manque des clés de traduction :
	SLASH_TRINITYADMIN_MISSINGKEYS1 = "/tamissingkeys"
	SlashCmdList["TRINITYADMIN_MISSINGKEYS"] = function(msg)
		if not next(MissingKeys) then
			TrinityAdmin:Print("Aucune clé manquante n'a été détectée pour le moment.")
			return
		end
	
		TrinityAdmin:Print("=== Clés de traduction manquantes ===")
		for missingKey, _ in pairs(MissingKeys) do
			TrinityAdmin:Print("- " .. missingKey)
		end
	end
	
    self.panel = panel
end
