local GameObjects = TrinityAdmin:GetModule("GameObjects")
local L = _G.L

-- Fonction pour afficher le panneau GameObjects
function GameObjects:ShowGameObjectsPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateGameObjectsPanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau GameObjects
function GameObjects:CreateGameObjectsPanel()
    local panel = CreateFrame("Frame", "TrinityAdminGameObjectsPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre, modifiez selon vos besoins

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(L["GameObjects Panel"])  -- Vous pouvez utiliser L si nécessaire

    -- Section: Game Objects Tools
local toolsTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
toolsTitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -20)
toolsTitle:SetText(L["Game Objects Tools"])

-- Champ de saisie pour la commande spéciale
local specialInput = CreateFrame("EditBox", "TrinityAdminSpecialInput", panel, "InputBoxTemplate")
specialInput:SetAutoFocus(false)
-- specialInput:SetSize(150, 22)
specialInput:SetPoint("TOPLEFT", toolsTitle, "BOTTOMLEFT", 0, -5)
-- On lui affecte une valeur par défaut (celle de la première option)
specialInput:SetText(L["Enter Guid"])
TrinityAdmin.AutoSize(specialInput, 20, 13, nil, 200)

-- Table des options du menu déroulant
local specialOptions = {
    { text = L["gobject activate"], command = ".gobject activate", defaultText = L["Enter Guid"], tooltip = L["Enter_Guid_tooltip"] },
    { text = L["gobject add"], command = ".gobject add", defaultText = L["Enter Id Spawntime"], tooltip = L["EnterIdSpawntime_tooltip"] },
    { text = L["gobject add temp"], command = ".gobject add temp", defaultText = L["Enter Guid or Id"], tooltip = L["EnterGuidorId_tooltip"] },
    { text = L["gobject delete"], command = ".gobject delete", defaultText = L["Enter Gobject guid"], tooltip = L["EnterGobjectguid_tooltip"] },
    { text = L["gobject despawngroup"], command = ".gobject despawngroup", defaultText = L["Enter GroupId"], tooltip = L["EnterGroupId_tooltip"] },
    { text = L["gobject info"], command = ".gobject info", defaultText = L["Enter Entry or Link"], tooltip = L["EnterEntryorLink_tooltip"] },
    { text = L["gobject info guid"], command = ".gobject info guid", defaultText = L["Enter Guid or Link"], tooltip = L["EnterGuidorLink_tooltip"] },
    { text = L["gobject near"], command = ".gobject near", defaultText = L["Enter Distance"], tooltip = L["EnterDistance_tooltip"] },
    { text = L["gobject set phase"], command = ".gobject set phase", defaultText = L["Enter Guid PhaseMask"], tooltip = L["EnterGuidPhaseMask_tooltip"] },
    { text = L["gobject set state"], command = ".gobject set state", defaultText = L["Enter State"], tooltip = "" },
    { text = L["gobject spawngroup"], command = ".gobject spawngroup", defaultText = L["Enter GroupId"], tooltip = L["EnterGroupId_tooltip2"] },
    { text = L["gobject target"], command = ".gobject target", defaultText = L["Enter Guid or Name part"], tooltip = L["EnterGuidorNamepart_tooltip"] },
}

	-- Création du menu déroulant pour les options
	local specialDropdown = CreateFrame("Frame", "TrinityAdminSpecialDropdown", panel, "UIDropDownMenuTemplate")
	specialDropdown:SetPoint("LEFT", specialInput, "RIGHT", 0, -1)
	UIDropDownMenu_SetWidth(specialDropdown, 140)
	UIDropDownMenu_SetButtonWidth(specialDropdown, 220)
	-- Initialisation de la sélection (par défaut, la première option)
	specialDropdown.selectedID = 1
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
				-- Met à jour la valeur par défaut du champ de saisie
				specialInput:SetText(option.defaultText)
				-- Met à jour le tooltip du champ de saisie
				specialInput:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetText(option.tooltip, 1, 1, 1, 1, true)
					GameTooltip:Show()
				end)
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end)
	-- Affiche la première option
	UIDropDownMenu_SetSelectedID(specialDropdown, specialDropdown.selectedID)
	UIDropDownMenu_SetText(specialDropdown, specialOptions[specialDropdown.selectedID].text)
	specialDropdown.selectedOption = specialOptions[specialDropdown.selectedID]
	
	-- Bouton "Execute" pour lancer la commande
	local btnSpecialExecute = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	-- btnSpecialExecute:SetSize(60, 22)
	btnSpecialExecute:SetText(L["Execute"])
	TrinityAdmin.AutoSize(btnSpecialExecute, 20, 16)
	btnSpecialExecute:SetPoint("TOPLEFT", specialInput, "BOTTOMLEFT", 0, -10)
	btnSpecialExecute:SetScript("OnClick", function()
		local inputValue = specialInput:GetText()
		local option = specialDropdown.selectedOption
		local command = option.command
		local finalCommand = command .. " " .. inputValue
		if inputValue == "" or inputValue == option.defaultText then
			local targetName = UnitName("target")
			if targetName then
				finalCommand = command .. " " .. targetName
			else
				TrinityAdmin:Print(L["enter_value_or_target_error"])
				return
			end
		end
		SendChatMessage(finalCommand, "SAY")
	end)
	btnSpecialExecute:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local option = specialDropdown.selectedOption or specialOptions[1]
		GameTooltip:SetText(option.tooltip, 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnSpecialExecute:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
    ------------------------------------------------------------------
    -- Section: Game Object Advanced
    ------------------------------------------------------------------
    -- Sous-titre "Game Object Advanced"
    local advLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    advLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -180)  -- Ajustez l'offset vertical selon votre layout
    advLabel:SetText(L["Game Object Advanced"])
    
    -- Champ de saisie pour le GUID
    local advGuidEdit = CreateFrame("EditBox", "TrinityAdminAdvGuidEditBox", panel, "InputBoxTemplate")
    -- advGuidEdit:SetSize(150, 22)
    advGuidEdit:SetPoint("TOPLEFT", advLabel, "BOTTOMLEFT", 0, -5)
    advGuidEdit:SetText(L["EnterGuid_69"])
	TrinityAdmin.AutoSize(advGuidEdit, 20, 13)
    
    -- Champ de saisie pour X
    local advXEdit = CreateFrame("EditBox", "TrinityAdminAdvXEditBox", panel, "InputBoxTemplate")
    -- advXEdit:SetSize(80, 22)
    advXEdit:SetPoint("TOPLEFT", advGuidEdit, "TOPRIGHT", 10, 0)
    advXEdit:SetText(L["Enter X"])
	TrinityAdmin.AutoSize(advXEdit, 20, 13)
    
    -- Champ de saisie pour Y
    local advYEdit = CreateFrame("EditBox", "TrinityAdminAdvYEditBox", panel, "InputBoxTemplate")
    -- advYEdit:SetSize(80, 22)
    advYEdit:SetPoint("TOPLEFT", advXEdit, "TOPRIGHT", 10, 0)
    advYEdit:SetText(L["Enter Y"])
	TrinityAdmin.AutoSize(advYEdit, 20, 13)
    
    -- Champ de saisie pour Z
    local advZEdit = CreateFrame("EditBox", "TrinityAdminAdvZEditBox", panel, "InputBoxTemplate")
    -- advZEdit:SetSize(80, 22)
    advZEdit:SetPoint("TOPLEFT", advYEdit, "TOPRIGHT", 10, 0)
    advZEdit:SetText(L["Enter Z"])
	TrinityAdmin.AutoSize(advZEdit, 20, 13)
    
    -- Dropdown pour choisir l'action ("gobject move" ou "gobject turn")
    local advDropdown = CreateFrame("Frame", "TrinityAdminAdvDropdown", panel, "UIDropDownMenuTemplate")
    advDropdown:SetPoint("TOPLEFT", advGuidEdit, "BOTTOMLEFT", 0, -9)
    UIDropDownMenu_SetWidth(advDropdown, 150)
    UIDropDownMenu_SetButtonWidth(advDropdown, 170)
    local advOptions = {
        { text = L["gobject move"], command = ".gobject move", defaultText = L["Enter Guid"], tooltip = L["gobject_move_tooltip"] },
        { text = L["gobject turn"], command = ".gobject turn", defaultText = L["Enter Guid"], tooltip = L["gobject_turn_tooltip"] },
    }
    if not advDropdown.selectedID then advDropdown.selectedID = 1 end
    UIDropDownMenu_Initialize(advDropdown, function(dropdownFrame, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, option in ipairs(advOptions) do
            info.text = option.text
            info.value = option.command
            info.checked = (i == advDropdown.selectedID)
            info.func = function(buttonFrame)
                advDropdown.selectedID = i
                UIDropDownMenu_SetSelectedID(advDropdown, i)
                UIDropDownMenu_SetText(advDropdown, option.text)
                advDropdown.selectedOption = option
                -- Met à jour la valeur par défaut du champ GUID
                advGuidEdit:SetText(option.defaultText)
                -- Configure le tooltip du champ GUID
                advGuidEdit:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(option.tooltip, 1, 1, 1, 1, true)
                    GameTooltip:Show()
                end)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetSelectedID(advDropdown, advDropdown.selectedID)
    UIDropDownMenu_SetText(advDropdown, advOptions[advDropdown.selectedID].text)
    advDropdown.selectedOption = advOptions[advDropdown.selectedID]
    
    -- Bouton "Move"
    local advButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- advButton:SetSize(60, 22)
    advButton:SetText(L["Movegob"])
	TrinityAdmin.AutoSize(advButton, 20, 16)
    advButton:SetPoint("LEFT", advDropdown, "RIGHT", -5, 0)
    advButton:SetScript("OnClick", function()
        local guid = advGuidEdit:GetText()
        local x = advXEdit:GetText()
        local y = advYEdit:GetText()
        local z = advZEdit:GetText()
        local option = advDropdown.selectedOption
        local command = option.command
        if guid == "" or guid == option.defaultText then
            TrinityAdmin:Print(L["enter_valid_guid_error"])
            return
        end
        local finalCommand = command .. " " .. guid .. " " .. x .. " " .. y .. " " .. z
        -- print("Debug: Commande envoyée: " .. finalCommand)  -- pour débug
        SendChatMessage(finalCommand, "SAY")
    end)
    advButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local opt = advDropdown.selectedOption or advOptions[1]
        GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    advButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    ------------------------------------------------------------
    -- GameObject Advanced ADD
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
    advancedLabel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -20)
    advancedLabel:SetText(L["Game Objects Advanced Add"])

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
			local fullText = option.name or ("Item "..i)
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
					
			-- btn:SetScript("OnLeave", function(self)
			-- 	GameTooltip:Hide()
			-- 	if self.wowheadTooltip then
			-- 		self.wowheadTooltip:Hide()
			-- 	end
			-- end)

			btn:SetScript("OnClick", function()
				-- print("Option cliquée :", fullText, "Entry:", option.entry)
				SendChatMessage(".gobject add " .. option.entry, "SAY")
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
    for i = 1, #GameObjectsData do
        table.insert(defaultOptions, GameObjectsData[i])
    end

    currentPage = 1
    PopulateGOScroll(defaultOptions)
	
	-- Recheche avec text Nothing found
	filterEditBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		local searchText = self:GetText():lower()
	
		-- Vérifie que l'utilisateur a saisi au moins 3 caractères
		if #searchText < 3 then
			TrinityAdmin:Print(L["min_search_length_error"])
			return
		end
	
		local filteredOptions = {}
		for _, option in ipairs(GameObjectsData) do
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
	-- btnReset:SetSize(80, 22)
	btnReset:SetText(L["Reset"])
	TrinityAdmin.AutoSize(btnReset, 20, 16)
	btnReset:SetPoint("RIGHT", filterEditBox, "RIGHT", -155, 0)
	btnReset:SetScript("OnClick", function()
		filterEditBox:SetText("")  -- Efface le champ de recherche
		currentPage = 1  -- Revient à la première page
		PopulateGOScroll(GameObjectsData)  -- Recharge toute la liste
	
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