local AdvancedItems = TrinityAdmin:GetModule("AdvancedItems")

ItemsData = {} -- Table globale qui contiendra toutes les entrées

-- Fonction pour enlever les accents d'une chaîne
local function removeAccents(str)
    local accents = {
        ["à"] = "a", ["â"] = "a", ["ä"] = "a",
        ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["ë"] = "e",
        ["î"] = "i", ["ï"] = "i",
        ["ô"] = "o", ["ö"] = "o",
        ["ù"] = "u", ["û"] = "u", ["ü"] = "u",
        ["ç"] = "c",
    }
    return (str:gsub("[%z\1-\127\194-\244][\128-\191]*", function(c)
        return accents[c] or c
    end))
end

-- Initialisation de ItemsData en chargeant les 3 fichiers de données
local function InitializeItemsData()
    local function loadDataFromPart(dataPart)
        for _, entry in ipairs(dataPart) do
            if entry and entry.name then
                entry.normalizedName = removeAccents(entry.name:lower())
                table.insert(ItemsData, entry)
            end
        end
    end

    loadDataFromPart(ItemsDataPart1)
    loadDataFromPart(ItemsDataPart2)
    loadDataFromPart(ItemsDataPart3)
    print("Fin du chargement ItemsData. Nombre total chargé :", #ItemsData)
end

-- Appel unique au démarrage :
InitializeItemsData()

local currentResults = nil  -- variable globale pour stocker les résultats filtrés
local isFiltered = false

-- Fonction pour afficher le panneau AdvancedItems
function AdvancedItems:ShowAdvancedItemsPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAdvancedItemsPanel()
    end
    self.panel:Show()
end

------------------------------------------------------------
-- Items Advanced ADD
------------------------------------------------------------

-- Nouvelle fonction de chargement d'un "chunk" à partir de ItemsData
local function LoadItemsChunk(startIndex, numLines)
    local chunk = {}
    for i = startIndex, math.min(startIndex + numLines - 1, #ItemsData) do
        table.insert(chunk, ItemsData[i])
    end
    return chunk
end

------------------------------------------------------------
-- Création du panneau AdvancedItems
------------------------------------------------------------
function AdvancedItems:CreateAdvancedItemsPanel()
    local panel = CreateFrame("Frame", "TrinityAdminServerAdminPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Advance Items Panel")

    ------------------------------------------------------------
    -- Variables
    ------------------------------------------------------------
    local entriesPerPage = 100
    local currentPage = 1
    local totalEntries = #ItemsData  -- Utilisation du nombre d'entrées chargées
    local currentOptions = {}    -- Liste courante (lazy loaded ou filtrée)
    
    ------------------------------------------------------------
    -- Label et champ de recherche
    ------------------------------------------------------------
    local advancedLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- advancedLabel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -20)
	advancedLabel:SetPoint("TOP", panel, "TOP", 0, -20)
    advancedLabel:SetText("Items Advanced Add")

    local filterEditBox = CreateFrame("EditBox", "TrinityAdminGOFilterEditBox", panel, "InputBoxTemplate")
    filterEditBox:SetSize(150, 22)
    -- filterEditBox:SetPoint("TOPRIGHT", advancedLabel, "BOTTOMRIGHT", -20, -5)
	filterEditBox:SetPoint("TOP", advancedLabel, "BOTTOM", 0, -5)
    filterEditBox:SetText("Search...")
	
	-- Nouvelle EditBox pour le nom du joueur, placée à droite de filterEditBox
	local playerNameEditBox = CreateFrame("EditBox", "TrinityAdminPlayerNameEditBox", panel, "InputBoxTemplate")
	playerNameEditBox:SetSize(120, 22)
	-- Placez-la à droite de la box de recherche. Vous pouvez ajuster les offsets si nécessaire :
	playerNameEditBox:SetPoint("LEFT", filterEditBox, "RIGHT", 10, 0)
	playerNameEditBox:SetText("Nom du Joueur")


	-- Nouvelle EditBox pour le montant ("HowMuch?"), placée à droite de la zone "Nom du Joueur"
	local howMuchEditBox = CreateFrame("EditBox", "TrinityAdminHowMuchEditBox", panel, "InputBoxTemplate")
	howMuchEditBox:SetSize(100, 22)
	howMuchEditBox:SetPoint("LEFT", playerNameEditBox, "RIGHT", 10, 0)
	howMuchEditBox:SetText("HowMuch?")
    ------------------------------------------------------------
    -- ScrollFrame et scrollChild
    ------------------------------------------------------------
    local scrollFrame = CreateFrame("ScrollFrame", "TrinityAdminGOScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(220, 200)
    scrollFrame:SetPoint("TOPRIGHT", filterEditBox, "BOTTOMRIGHT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 50)

    local scrollChild = CreateFrame("Frame", "TrinityAdminGOScrollChild", scrollFrame)
    scrollChild:SetSize(220, 400)
    scrollFrame:SetScrollChild(scrollChild)

    ------------------------------------------------------------
    -- Boutons de pagination
    ------------------------------------------------------------
    local btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnPrev:SetSize(80, 22)
    btnPrev:SetText("Preview")
    btnPrev:SetPoint("BOTTOM", panel, "BOTTOM", -120, 10)

    local btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnNext:SetSize(80, 22)
    btnNext:SetText("Next")
    btnNext:SetPoint("BOTTOM", panel, "BOTTOM", 60, 10)

    local btnPage = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnPage:SetSize(90, 22)
    btnPage:SetPoint("BOTTOM", panel, "BOTTOM", -30, 10)
    btnPage:SetText("Page 1 / 1")

    ------------------------------------------------------------
    -- Fonction PopulateGOScroll (affichage du chunk actuel)
    ------------------------------------------------------------
    local currentResults = nil -- variable globale pour stocker les résultats filtrés
    local isFiltered = false   -- indique si on est en mode recherche

    local function PopulateGOScroll(data)
        local sourceData, totalEntriesLocal

        if data then
            sourceData = data
            totalEntriesLocal = #data
            isFiltered = true
        else
            totalEntriesLocal = totalEntries
            sourceData = LoadItemsChunk((currentPage - 1) * entriesPerPage + 1, entriesPerPage)
            isFiltered = false
        end

        if scrollChild.buttons then
            for _, btn in ipairs(scrollChild.buttons) do
                btn:Hide()
            end
        else
            scrollChild.buttons = {}
        end

        local optionsChunk = {}
        print("isFiltered:", isFiltered, "totalEntriesLocal:", totalEntriesLocal, "currentPage:", currentPage)

        if isFiltered then
            local startIdx = (currentPage - 1) * entriesPerPage + 1
            local endIdx = math.min(currentPage * entriesPerPage, totalEntriesLocal)
            print("Mode filtré: startIdx:", startIdx, "endIdx:", endIdx)
            for i = startIdx, endIdx do
                if sourceData[i] then
                    table.insert(optionsChunk, sourceData[i])
                end
            end
        else
            optionsChunk = sourceData
            print("OptionsChunk size:", #optionsChunk)
        end

        if #optionsChunk == 0 then
            if not scrollChild.noResultText then
                scrollChild.noResultText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                scrollChild.noResultText:SetPoint("TOP", scrollChild, "TOP", 0, -10)
                scrollChild.noResultText:SetText("|cffff0000Nothing found|r")
            end
            scrollChild.noResultText:Show()
            scrollChild:SetHeight(50)
            btnPrev:SetEnabled(false)
            btnNext:SetEnabled(false)
            btnPage:SetText("Page 0 / 0")
            return
        else
            if scrollChild.noResultText then
                scrollChild.noResultText:Hide()
            end
        end

        currentOptions = optionsChunk

        local maxTextLength = 20
        local lastButton = nil
        for i, option in ipairs(optionsChunk) do
            local btn = scrollChild.buttons[i]
            if not btn then
                btn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
                btn:SetSize(200, 20)
                table.insert(scrollChild.buttons, btn)
            end
            btn:Show()

            if not lastButton then
                btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -10)
            else
                btn:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -5)
            end

            local fullText = option.name or ("Item " .. i)
            local truncatedText = fullText
            if #fullText > maxTextLength then
                truncatedText = fullText:sub(1, maxTextLength) .. "..."
            end
            btn:SetText(truncatedText)

            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                -- GameTooltip:SetText(fullText, 1, 1, 1, 1, true)
			if option.entry then
			-- Avec traduction
		    -- local translatedName = L[option.name] or option.name
            -- local link = "|cffffffff|Hitem:" .. option.entry .. "|h[" .. translatedName .. "]|h|r"
				local link = "|cffffffff|Hitem:" .. option.entry .. "|h[" .. (option.name or "Item") .. "]|h|r"
				GameTooltip:SetHyperlink(link)
			else
				GameTooltip:SetText(fullText, 1, 1, 1, 1, true)
			end

                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            -- btn:SetScript("OnClick", function()
            --     print("Option cliquée :", fullText, "Entry:", option.entry)
            --     SendChatMessage(".additem set " .. option.entry, "SAY")
            -- end)
			
			btn:SetScript("OnClick", function()
			local playerName = playerNameEditBox:GetText()
			local howMuch = howMuchEditBox:GetText()
			local command = ""
			
			if playerName == "Nom du Joueur" or playerName == "" then
				-- Pas de nom de joueur
				if howMuch == "" or howMuch == "HowMuch?" then
					command = ".additem " .. option.entry
				else
					command = ".additem " .. option.entry .. " " .. howMuch
				end
			else
				-- Nom du joueur fourni
				if howMuch == "" or howMuch == "HowMuch?" then
					command = ".additem to " .. playerName .. " " .. option.entry
				else
					command = ".additem to " .. playerName .. " " .. option.entry .. " " .. howMuch
				end
			end
			
			print("Option cliquée :", fullText, "Entry:", option.entry)
			print("Commande envoyée :", command)
			SendChatMessage(command, "SAY")
			end)

            lastButton = btn
        end

        local visibleCount = #optionsChunk
        local contentHeight = (visibleCount * 25) + 10
        scrollChild:SetHeight(contentHeight)

        btnPage:SetText(currentPage .. " / " .. math.ceil(totalEntriesLocal / entriesPerPage))
        btnPrev:SetEnabled(currentPage > 1)
        btnNext:SetEnabled(currentPage < math.ceil(totalEntriesLocal / entriesPerPage))
    end

    ------------------------------------------------------------
    -- Boutons de pagination
    ------------------------------------------------------------
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            if isFiltered then
                PopulateGOScroll(currentResults)
            else
                PopulateGOScroll()
            end
        end
    end)

    btnNext:SetScript("OnClick", function()
        local totalPagesCalc
        if isFiltered then
            totalPagesCalc = math.ceil(#currentResults / entriesPerPage)
        else
            totalPagesCalc = math.ceil(totalEntries / entriesPerPage)
        end

        if currentPage < totalPagesCalc then
            currentPage = currentPage + 1
            if isFiltered then
                PopulateGOScroll(currentResults)
            else
                PopulateGOScroll()
            end
        end
    end)

    ------------------------------------------------------------
    -- Remplissage initial (sans filtre)
    ------------------------------------------------------------
    currentPage = 1
    PopulateGOScroll()

    local function SearchItems(search)
        local results = {}
        local normalizedSearch = removeAccents(search:lower())

        for _, entry in ipairs(ItemsData) do
            if entry.normalizedName:find(normalizedSearch, 1, true) or tostring(entry.entry) == search then
                table.insert(results, entry)
            end
        end
        print("Nombre de résultats trouvés :", #results)
        return results
    end

    filterEditBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        local searchText = self:GetText():lower()

        if searchText == "search..." or #searchText < 3 then
            print("Veuillez entrer au moins 3 caractères pour la recherche.")
            return
        end

        currentPage = 1
        currentResults = SearchItems(searchText) or {} -- Assure une table vide, jamais nil
        PopulateGOScroll(currentResults)
    end)

    ------------------------------------------------------------
    -- Bouton "Reset" pour revenir à la liste complète
    ------------------------------------------------------------
    local btnReset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnReset:SetSize(80, 22)
    btnReset:SetText("Reset")
    btnReset:SetPoint("RIGHT", filterEditBox, "RIGHT", -155, 0)
    btnReset:SetScript("OnClick", function()
        filterEditBox:SetText("")
        currentPage = 1
        isFiltered = false
        currentResults = nil
        PopulateGOScroll()
        if scrollChild.noResultText then
            scrollChild.noResultText:Hide()
        end
    end)

    ------------------------------------------------------------
    -- Bouton "Back" pour revenir au menu principal
    ------------------------------------------------------------

	local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetSize(80, 22)
    btnBack:SetText("Retour")
    btnBack:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
