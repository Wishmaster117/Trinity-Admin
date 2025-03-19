local AdvancedItems = TrinityAdmin:GetModule("AdvancedItems")

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

-- Fonction de lazy search sur ItemsDataString (si ItemsData n'est pas chargé)
local function LazySearchItems(searchText)
    local results = {}
    -- Parcourt chaque ligne de la chaîne
    for line in ItemsDataString:gmatch("[^\r\n]+") do
        local f = loadstring("return " .. line)
        if f then
            local option = f()
            if (option.name and option.name:lower():find(searchText)) or (tostring(option.entry) == searchText) then
                table.insert(results, option)
            end
        end
    end
    return results
end

-- Fonction de chargement d'un chunk de données depuis ItemsDataString
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
    -- Variables et Bouton Retour
    ------------------------------------------------------------
    local entriesPerPage = 100
    local currentPage = 1
    local totalEntries = 154000  -- Nombre total d'entrées connu
    local currentOptions = {}    -- La liste courante (lazy loaded ou filtrée)

    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetSize(80, 22)
    btnBack:SetText("Retour")
    btnBack:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)
    
    ------------------------------------------------------------
    -- Label et champ de recherche
    ------------------------------------------------------------
    local advancedLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    advancedLabel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -20)
    advancedLabel:SetText("Item Set Advanced Add")

    local filterEditBox = CreateFrame("EditBox", "TrinityAdminGOFilterEditBox", panel, "InputBoxTemplate")
    filterEditBox:SetSize(150, 22)
    filterEditBox:SetPoint("TOPRIGHT", advancedLabel, "BOTTOMRIGHT", -20, -5)
    filterEditBox:SetText("Search...")

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
    -- Fonction PopulateGOScroll (affichage du chunk actuel)
    ------------------------------------------------------------
    local function PopulateGOScroll(data)
        local sourceData, totalEntriesLocal

        if data then
            sourceData = data
            totalEntriesLocal = #data
        else
            totalEntriesLocal = totalEntries
            sourceData = LoadItemsChunk((currentPage - 1) * entriesPerPage + 1, entriesPerPage)
        end

        if scrollChild.buttons then
            for _, btn in ipairs(scrollChild.buttons) do
                btn:Hide()
            end
        else
            scrollChild.buttons = {}
        end

        local optionsChunk = {}
        if data then
            local startIdx = (currentPage - 1) * entriesPerPage + 1
            local endIdx = math.min(currentPage * entriesPerPage, totalEntriesLocal)
            for i = startIdx, endIdx do
                table.insert(optionsChunk, sourceData[i])
            end
        else
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

            local globalIndex = (data and ((currentPage - 1) * entriesPerPage + i)) or ((currentPage - 1) * entriesPerPage + i)
            local fullText = option.name or ("Item " .. globalIndex)
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

    ------------------------------------------------------------
    -- Boutons de pagination
    ------------------------------------------------------------
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            PopulateGOScroll()
        end
    end)

    btnNext:SetScript("OnClick", function()
        local totalPagesCalc = math.ceil(totalEntries / entriesPerPage)
        if currentPage < totalPagesCalc then
            currentPage = currentPage + 1
            PopulateGOScroll()
        end
    end)

    ------------------------------------------------------------
    -- Remplissage initial (sans filtre)
    ------------------------------------------------------------
    currentPage = 1
    PopulateGOScroll(ItemsData)  -- Attention: ItemsData doit être défini si vous effectuez une recherche globale.
                                -- Sinon, laissez la fonction utiliser lazy loading (sans argument) : PopulateGOScroll()
	

-- Assurez-vous que la fonction removeAccents est définie avant :
local function removeAccents(str)
    local accents = {
        ["à"] = "a", ["â"] = "a", ["ä"] = "a",
        ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["ë"] = "e",
        ["î"] = "i", ["ï"] = "i",
        ["ô"] = "o", ["ö"] = "o",
        ["ù"] = "u", ["û"] = "u", ["ü"] = "u",
        ["ç"] = "c",
        -- ajoutez d'autres conversions si nécessaire
    }
    return (str:gsub("[%z\1-\127\194-\244][\128-\191]*", function(c)
        return accents[c] or c
    end))
end

-- Fonction de recherche sur ItemsDataString (lazy loading)
local function SearchItemsDataString(search)
    local results = {}
    local normalizedSearch = removeAccents(search:lower())
    for line in ItemsDataString:gmatch("[^\r\n]+") do
        -- On suppose que chaque ligne est du type: { entry = 1688, name = "Éclats du lustre vivant" },
        local chunkFunc, err = loadstring("return " .. line)
        if chunkFunc then
            local entry = chunkFunc()
            if entry and entry.name then
                local normalizedName = removeAccents(entry.name:lower())
                if normalizedName:find(normalizedSearch) then
                    table.insert(results, entry)
                end
            end
        end
    end
    return results
end

-- Script du filtre (OnEnterPressed sur filterEditBox)
filterEditBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
    local searchText = self:GetText():lower()
    
    if searchText == "search..." then
        print("Veuillez saisir un terme de recherche.")
        return
    end

    if #searchText < 3 then
        print("Veuillez entrer au moins 3 caractères pour la recherche.")
        return
    end

    local normalizedSearch = removeAccents(searchText)
    local filteredOptions = {}
    local allOptions

    if ItemsData then
        allOptions = ItemsData
    else
        -- Si ItemsData n'est pas défini, effectuez une recherche sur l'intégralité du fichier
        allOptions = SearchItemsDataString(searchText)
    end

    for _, option in ipairs(allOptions) do
        if option.name then
            local normalizedName = removeAccents(option.name:lower())
            if normalizedName:find(normalizedSearch) then
                table.insert(filteredOptions, option)
            end
        end
        if tostring(option.entry) == searchText then
            table.insert(filteredOptions, option)
        end
    end

    if #filteredOptions == 0 then
        if scrollChild.buttons then
            for _, btn in ipairs(scrollChild.buttons) do
                btn:Hide()
            end
        end
        if not scrollChild.noResultText then
            scrollChild.noResultText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            scrollChild.noResultText:SetPoint("TOP", scrollChild, "TOP", 0, -10)
            scrollChild.noResultText:SetText("|cffff0000Nothing found|r")
        end
        scrollChild.noResultText:Show()
        scrollChild:SetHeight(50)
    else
        if scrollChild.noResultText then
            scrollChild.noResultText:Hide()
        end
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
        filterEditBox:SetText("")
        currentPage = 1
        if ItemsData then
            PopulateGOScroll(ItemsData)
        else
            PopulateGOScroll()
        end
        if scrollChild.noResultText then
            scrollChild.noResultText:Hide()
        end
    end)

    ------------------------------------------------------------
    -- Bouton "Back" pour revenir au menu principal
    ------------------------------------------------------------
    local btnBack2 = CreateFrame("Button", "TrinityAdminTeleportBackButton", panel, "UIPanelButtonTemplate")
    btnBack2:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack2:SetText(TrinityAdmin_Translations["Back"])
    btnBack2:SetHeight(22)
    btnBack2:SetWidth(btnBack2:GetTextWidth() + 20)
    btnBack2:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end

