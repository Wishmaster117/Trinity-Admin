local AdvancedItems = TrinityAdmin:GetModule("AdvancedItems")

-- Fonction pour afficher le panneau AdvancedItems
function AdvancedItems:ShowAdvancedItemsPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAdvancedItemsPanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau AdvancedItems
function AdvancedItems:CreateAdvancedItemsPanel()
    local panel = CreateFrame("Frame", "TrinityAdminServerAdminPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre, modifiez selon vos besoins

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Advance Items Panel")  -- Vous pouvez utiliser TrinityAdmin_Translations si nécessaire

    ------------------------------------------------------------
    -- Items Advanced ADD
    ------------------------------------------------------------

	local function LoadItemsChunk(startLine, numLines)
		local chunk = ""
		local currentLine = 1
		for line in ItemsDataString:gmatch("[^\r\n]+") do
			if currentLine >= startLine and currentLine < startLine + numLines then
				chunk = chunk .. line .. "\n"
			end
			currentLine = currentLine + 1
			if currentLine >= startLine + numLines then
				break
			end
		end
		local chunkFunc, err = loadstring("return {" .. chunk .. "}")
		if not chunkFunc then
			error("Erreur lors du chargement du chunk : " .. err)
		end
		return chunkFunc()
	end


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
    advancedLabel:SetText("Add Item Advanced")

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
    -- Variables de pagination
    ------------------------------------------------------------
    local entriesPerPage = 100
	local currentPage = 1
	local totalEntries = 154000  -- Nombre total d'entrées connu
	local currentOptions = {}    -- La liste courante (lazy loaded ou filtrée)

    ------------------------------------------------------------
    -- Fonction PopulateGOScroll(options)
    ------------------------------------------------------------

	local function PopulateGOScroll(data)
    local sourceData
    local totalEntriesLocal

    if data then
        -- Mode filtré ou chargé en mémoire
        sourceData = data
        totalEntriesLocal = #data
    else
        -- Mode lazy loading via ItemsDataString
        -- Vous connaissez le nombre total d'entrées
        totalEntriesLocal = totalEntries
        -- Charge le chunk depuis ItemsDataString
        sourceData = LoadItemsChunk((currentPage - 1) * entriesPerPage + 1, entriesPerPage)
    end

    -- Efface les anciens boutons
    if scrollChild.buttons then
        for _, btn in ipairs(scrollChild.buttons) do
            btn:Hide()
        end
    else
        scrollChild.buttons = {}
    end

    local optionsChunk = {}
    if data then
        -- Si on a un tableau en paramètre, on en extrait le chunk
        local startIdx = (currentPage - 1) * entriesPerPage + 1
        local endIdx   = math.min(currentPage * entriesPerPage, totalEntriesLocal)
        for i = startIdx, endIdx do
            table.insert(optionsChunk, sourceData[i])
        end
    else
        -- Sinon, sourceData est déjà le chunk chargé
        optionsChunk = sourceData
    end
    currentOptions = optionsChunk

    local maxTextLength = 20
    local lastButton = nil
    for i, option in ipairs(optionsChunk) do
        local btn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
        btn:SetSize(200, 20)
        if not lastButton then
            btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -10)
        else
            btn:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -5)
        end

        local fullText = option.name or ("Item " .. ((data and ((currentPage - 1) * entriesPerPage + i)) or ((currentPage - 1) * entriesPerPage + i)))
        local truncatedText = fullText
        if #fullText > maxTextLength then
            truncatedText = fullText:sub(1, maxTextLength) .. "..."
        end
        btn:SetText(truncatedText)

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(fullText, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        btn:SetScript("OnClick", function()
            print("Option cliquée :", fullText, "Entry:", option.entry)
            SendChatMessage(".additem set " .. option.entry, "SAY")
        end)

        lastButton = btn
        table.insert(scrollChild.buttons, btn)
    end

    local visibleCount = #optionsChunk
    local contentHeight = (visibleCount * 25) + 10
    scrollChild:SetHeight(contentHeight)

    btnPage:SetText(currentPage .. " / " .. math.ceil(totalEntriesLocal / entriesPerPage))
    btnPrev:SetEnabled(currentPage > 1)
    btnNext:SetEnabled(currentPage < math.ceil(totalEntriesLocal / entriesPerPage))
	end

	
	btnPrev:SetScript("OnClick", function()
		if currentPage > 1 then
			currentPage = currentPage - 1
			PopulateGOScroll()
		end
	end)
	
	btnNext:SetScript("OnClick", function()
		local totalPages = math.ceil(totalEntries / entriesPerPage)
		if currentPage < totalPages then
			currentPage = currentPage + 1
			PopulateGOScroll()
		end
	end)

    ------------------------------------------------------------
    -- Remplissage initial (sans filtre)
    ------------------------------------------------------------
	-- Utilisez directement la table ItemsData :
	currentPage = 1
	PopulateGOScroll(ItemsData)
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
		for _, option in ipairs(ItemsData) do
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
		PopulateGOScroll(ItemsData)  -- Recharge toute la liste
	
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
