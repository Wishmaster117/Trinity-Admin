local GameObjects = TrinityAdmin:GetModule("GameObjects")

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
    panel.title:SetText("GameObjects Panel")  -- Vous pouvez utiliser TrinityAdmin_Translations si nécessaire

    -- Section: Game Objects Tools
local toolsTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
toolsTitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -20)
toolsTitle:SetText("Game Objects Tools")

-- Champ de saisie pour la commande spéciale
local specialInput = CreateFrame("EditBox", "TrinityAdminSpecialInput", panel, "InputBoxTemplate")
specialInput:SetAutoFocus(false)
specialInput:SetSize(150, 22)
specialInput:SetPoint("TOPLEFT", toolsTitle, "BOTTOMLEFT", 0, -5)
-- On lui affecte une valeur par défaut (celle de la première option)
specialInput:SetText("Enter Guid")

-- Table des options du menu déroulant
local specialOptions = {
    { text = "gobject activate", command = ".gobject activate", defaultText = "Enter guid", tooltip = "Syntax: .gobject activate #guid\r\n\r\nActivates an object like a door or a button." },
    { text = "gobject add", command = ".gobject add", defaultText = "Enter Id Spawntime", tooltip = "Syntax: .gobject add #id <spawntimeSecs>\r\n\r\nAdd a game object from game object templates to the world at your current location using the #id.\r\nspawntimesecs sets the spawntime, it is optional.\r\n\r\nNote: this is a copy of .gameobject." },
    { text = "gobject add temp", command = ".gobject add temp", defaultText = "Enter uid or Id", tooltip = "Adds a temporary gameobject that is not saved to DB." },
    { text = "gobject delete", command = ".gobject delete", defaultText = "Enter Gobject guid", tooltip = "Syntax: .gobject delete #go_guid\r\nDelete gameobject with guid #go_guid." },
    { text = "gobject despawngroup", command = ".gobject despawngroup", defaultText = "Enter GroupId", tooltip = "Syntax: .gobject despawngroup $groupId [removerespawntime]." },
    { text = "gobject info", command = ".gobject info", defaultText = "Enter Entry or Link", tooltip = "Syntax: .gobject info [$entry|$link]\r\n\r\nQuery Gameobject information for given gameobject entry or link.\r\nFor example .gobject info 36." },
    { text = "gobject info guid", command = ".gobject info guid", defaultText = "Enter Guid or Link", tooltip = "Syntax: .gobject info guid [$guid|$link]\r\n\r\nQuery Gameobject information for given gameobject guid or link.\r\nFor example .gobject info guid 100" },
    { text = "gobject near", command = ".gobject near", defaultText = "Enter Distance", tooltip = "Syntax: .gobject near [#distance]\r\n\r\nOutput gameobjects at distance #distance from player. If #distance not provided, use 10 as default." },
    { text = "gobject set phase", command = ".gobject set phase", defaultText = "Enter Guid PhaseMask", tooltip = "Syntax: .gobject set phase #guid #phasemask\r\n\r\nGameobject with DB guid #guid phasemask changed to #phasemask and saved to DB." },
    { text = "gobject set state", command = ".gobject set state", defaultText = "Enter State", tooltip = "" },
    { text = "gobject spawngroup", command = ".gobject spawngroup", defaultText = "Enter GroupId", tooltip = "Syntax: .gobject spawngroup $groupId [ignorerespawn] [force]" },
    { text = "gobject target", command = ".gobject target", defaultText = "Enter Guid or Name part", tooltip = "Syntax: .gobject target [#go_id|#go_name_part]\r\n\r\nLocate and show position of the nearest gameobject matching the provided id or name part." },
}

	-- Création du menu déroulant pour les options
	local specialDropdown = CreateFrame("Frame", "TrinityAdminSpecialDropdown", panel, "UIDropDownMenuTemplate")
	specialDropdown:SetPoint("LEFT", specialInput, "RIGHT", 10, 0)
	UIDropDownMenu_SetWidth(specialDropdown, 140)
	UIDropDownMenu_SetButtonWidth(specialDropdown, 240)
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
	btnSpecialExecute:SetSize(60, 22)
	btnSpecialExecute:SetText("Execute")
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
				print("Veuillez saisir une valeur ou cibler un joueur.")
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
    advLabel:SetText("Game Object Advanced")
    
    -- Champ de saisie pour le GUID
    local advGuidEdit = CreateFrame("EditBox", "TrinityAdminAdvGuidEditBox", panel, "InputBoxTemplate")
    advGuidEdit:SetSize(150, 22)
    advGuidEdit:SetPoint("TOPLEFT", advLabel, "BOTTOMLEFT", 0, -5)
    advGuidEdit:SetText("Enter Guid")
    
    -- Champ de saisie pour X
    local advXEdit = CreateFrame("EditBox", "TrinityAdminAdvXEditBox", panel, "InputBoxTemplate")
    advXEdit:SetSize(80, 22)
    advXEdit:SetPoint("TOPLEFT", advGuidEdit, "TOPRIGHT", 10, 0)
    advXEdit:SetText("Enter X")
    
    -- Champ de saisie pour Y
    local advYEdit = CreateFrame("EditBox", "TrinityAdminAdvYEditBox", panel, "InputBoxTemplate")
    advYEdit:SetSize(80, 22)
    advYEdit:SetPoint("TOPLEFT", advXEdit, "TOPRIGHT", 10, 0)
    advYEdit:SetText("Enter Y")
    
    -- Champ de saisie pour Z
    local advZEdit = CreateFrame("EditBox", "TrinityAdminAdvZEditBox", panel, "InputBoxTemplate")
    advZEdit:SetSize(80, 22)
    advZEdit:SetPoint("TOPLEFT", advYEdit, "TOPRIGHT", 10, 0)
    advZEdit:SetText("Enter Z")
    
    -- Dropdown pour choisir l'action ("gobject move" ou "gobject turn")
    local advDropdown = CreateFrame("Frame", "TrinityAdminAdvDropdown", panel, "UIDropDownMenuTemplate")
    advDropdown:SetPoint("TOPLEFT", advGuidEdit, "BOTTOMLEFT", 0, -5)
    UIDropDownMenu_SetWidth(advDropdown, 150)
    UIDropDownMenu_SetButtonWidth(advDropdown, 170)
    local advOptions = {
        { text = "gobject move", command = ".gobject move", defaultText = "Enter Guid", tooltip = "Syntax: .gobject move #goguid [#x #y #z]\r\n\r\nMove gameobject #goguid to character coordinates (or to (#x,#y,#z) coordinates if provided)." },
        { text = "gobject turn", command = ".gobject turn", defaultText = "Enter Guid", tooltip = "Syntax: .gobject turn [guid|link] [oz [oy [ox]]]\r\n\r\nSet the orientation of the gameobject to player's orientation or the given orientation." },
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
    advButton:SetSize(60, 22)
    advButton:SetText("Move")
    advButton:SetPoint("LEFT", advDropdown, "RIGHT", 10, 0)
    advButton:SetScript("OnClick", function()
        local guid = advGuidEdit:GetText()
        local x = advXEdit:GetText()
        local y = advYEdit:GetText()
        local z = advZEdit:GetText()
        local option = advDropdown.selectedOption
        local command = option.command
        if guid == "" or guid == option.defaultText then
            print("Veuillez saisir un GUID valide.")
            return
        end
        local finalCommand = command .. " " .. guid .. " " .. x .. " " .. y .. " " .. z
        print("Debug: Commande envoyée: " .. finalCommand)  -- pour débug
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
    advancedLabel:SetText("Game Objects Advanced Add")

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
				print("Option cliquée :", fullText, "Entry:", option.entry)
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

    ------------------------------------------------------------
    -- Script du filtre (EnterPressed)
    ------------------------------------------------------------
	-- Recherche uniquement avec name
    -- filterEditBox:SetScript("OnEnterPressed", function(self)
    --     self:ClearFocus()
    --     local searchText = self:GetText():lower()
    --     if #searchText < 3 then
    --         print("Veuillez entrer au moins 3 caractères pour la recherche.")
    --         return
    --     end
	-- 
    --     local filteredOptions = {}
    --     for _, option in ipairs(GameObjectsData) do
    --         if option.name and option.name:lower():find(searchText) then
    --             table.insert(filteredOptions, option)
    --         end
    --     end
	-- 
    --     currentPage = 1
    --     PopulateGOScroll(filteredOptions)
    -- end)
	
	-- Recheche avec name ou entry
	-- filterEditBox:SetScript("OnEnterPressed", function(self)
	-- 	self:ClearFocus()
	-- 	local searchText = self:GetText():lower()
	-- 
	-- 	-- Vérifie que l'utilisateur a saisi au moins 3 caractères
	-- 	if #searchText < 3 then
	-- 		print("Veuillez entrer au moins 3 caractères pour la recherche.")
	-- 		return
	-- 	end
	-- 
	-- 	local filteredOptions = {}
	-- 	for _, option in ipairs(GameObjectsData) do
	-- 		-- Vérifie si le texte est dans le "name" ou correspond à l'"entry"
	-- 		if (option.name and option.name:lower():find(searchText)) or
	-- 		(tostring(option.entry) == searchText) then
	-- 			table.insert(filteredOptions, option)
	-- 		end
	-- 	end
	-- 
	-- 	currentPage = 1
	-- 	PopulateGOScroll(filteredOptions)
	-- end)
	
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
	btnReset:SetSize(80, 22)
	btnReset:SetText("Reset")
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