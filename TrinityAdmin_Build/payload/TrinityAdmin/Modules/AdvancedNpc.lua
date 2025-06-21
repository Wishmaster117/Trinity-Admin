local L = _G.L
local TrinityAdmin = LibStub("AceAddon-3.0"):GetAddon("TrinityAdmin")
local AdvancedNpc = TrinityAdmin:GetModule("AdvancedNpc")
local L = LibStub("AceLocale-3.0"):GetLocale("TrinityAdmin")

NPCData = {} -- Table globale qui contiendra toutes les entrées

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

-- Initialisation de NpcData en chargeant les 3 fichiers de données
local function InitializeNPCData()
    local function loadDataFromPart(dataPart)
        for _, entry in ipairs(dataPart) do
            if entry and entry.name then
                entry.normalizedName = removeAccents(entry.name:lower())
                table.insert(NPCData, entry)
            end
        end
    end

    loadDataFromPart(NpcDataPart1)
    loadDataFromPart(NpcDataPart2)
    loadDataFromPart(NpcDataPart3)
	loadDataFromPart(NpcDataPart4)
	loadDataFromPart(NpcDataPart5)
	loadDataFromPart(NpcDataPart6)
	loadDataFromPart(NpcDataPart7)
    -- TrinityAdmin:Print("Fin du chargement NpcData. Nombre total chargé :", #NPCData)
end

-- Appel unique au démarrage :
InitializeNPCData()

local currentResults = nil  -- variable globale pour stocker les résultats filtrés
local isFiltered = false

-- Fonction pour afficher le panneau AdvancedNpc
function AdvancedNpc:ShowAdvancedNpcPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAdvancedNpcPanel()
    end
    self.panel:Show()
end

------------------------------------------------------------
-- Npc Advanced ADD
------------------------------------------------------------

-- Nouvelle fonction de chargement d'un "chunk" à partir de NpcData
local function LoadItemsChunk(startIndex, numLines)
    local chunk = {}
    for i = startIndex, math.min(startIndex + numLines - 1, #NPCData) do
        table.insert(chunk, NPCData[i])
    end
    return chunk
end

------------------------------------------------------------
-- Création du panneau AdvancedNpc
------------------------------------------------------------
function AdvancedNpc:CreateAdvancedNpcPanel()
    local panel = CreateFrame("Frame", "TrinityAdminAdvancedNpcPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(L["Advanced Npc Add"])

    ------------------------------------------------------------
    -- Variables
    ------------------------------------------------------------
    local entriesPerPage = 100
    local currentPage = 1
    local totalEntries = #NPCData  -- Utilisation du nombre d'entrées chargées
    local currentOptions = {}    -- Liste courante (lazy loaded ou filtrée)
    
    ------------------------------------------------------------
    -- Label et champ de recherche
    ------------------------------------------------------------
    local advancedLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- advancedLabel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -20)
	advancedLabel:SetPoint("TOP", panel, "TOP", 0, -20)
    advancedLabel:SetText(L["Advanced Npc Add"])

    local filterEditBox = CreateFrame("EditBox", "TrinityAdminGOFilterEditBox", panel, "InputBoxTemplate")
    -- filterEditBox:SetPoint("TOPRIGHT", advancedLabel, "BOTTOMRIGHT", -20, -5)
	filterEditBox:SetPoint("TOP", advancedLabel, "BOTTOM", 0, -5)
    filterEditBox:SetText(L["Search..."])
	TrinityAdmin.AutoSize(filterEditBox, 20, 13, nil, 120)
	
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
    btnPrev:SetText(L["Pagination_Preview"])
	TrinityAdmin.AutoSize(btnPrev, 20, 16)
    btnPrev:SetPoint("BOTTOM", panel, "BOTTOM", -120, 10)

    local btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnNext:SetText(L["Next"])
	TrinityAdmin.AutoSize(btnNext, 20, 16)
    btnNext:SetPoint("BOTTOM", panel, "BOTTOM", 60, 10)

    local btnPage = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnPage:SetSize(90, 22)
    btnPage:SetPoint("BOTTOM", panel, "BOTTOM", -30, 10)
    btnPage:SetText("Page 1 / 1")

    ------------------------------------------------------------
    -- Création d'une frame de prévisualisation indépendante
    ------------------------------------------------------------
	local creaturePreviewFrame = CreateFrame("Frame", "CreaturePreviewContainer", TrinityAdminMainFrame)
	creaturePreviewFrame:SetSize(440, 440)
	creaturePreviewFrame:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPRIGHT", 60, 0)
	creaturePreviewFrame:SetFrameStrata("HIGH")
	creaturePreviewFrame:EnableMouse(true)
	creaturePreviewFrame:SetHitRectInsets(50, 50, 50, 50) -- gauche, droite, haut, bas
	creaturePreviewFrame:Hide()
	
	-- Ajout d'un fond semi-transparent (facultatif)
	local bg = creaturePreviewFrame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0, 0, 0, 0.5)
	
	-- 1) Créer le bouton “fermer” avec le template UIPanelCloseButton
	local btnClose = CreateFrame("Button", nil, creaturePreviewFrame, "UIPanelCloseButton")
	
	-- 2) Positionner ce bouton dans l’angle supérieur gauche du cadre
	-- Ajustez les valeurs x/y si la croix n’est pas parfaitement alignée
	btnClose:SetPoint("TOPRIGHT", creaturePreviewFrame, "TOPRIGHT", 0, 0)
	
	-- 3) Quand on clique dessus, on cache simplement creaturePreviewFrame
	btnClose:SetScript("OnClick", function()
		creaturePreviewFrame:Hide()
	end)

	-- Création du modèle de la créature dans la frame de prévisualisation
	local creatureModel = CreateFrame("PlayerModel", "CreaturePreviewModel", creaturePreviewFrame)
	-- creatureModel:SetSize(400, 400)
	-- creatureModel:SetPoint("CENTER", creaturePreviewFrame, "CENTER", 0, 0)
	creatureModel:SetAllPoints(creaturePreviewFrame)
	-- creatureModel:SetPortraitZoom(1.0)
	creatureModel:SetCamDistanceScale(1.2) -- Zoomer dezoomer
	
	-- Ajout de la variable pour stocker l'angle actuel (en radians)
    local currentFacing = 0
	
	-- Deux flags pour savoir si on tourne à gauche ou à droite
	local rotatingLeft  = false
	local rotatingRight = false	

	-- OnUpdate sur le frame parent pour faire tourner le modèle
	creaturePreviewFrame:SetScript("OnUpdate", function(self, elapsed)
		-- elapsed est le temps écoulé depuis la dernière frame, en secondes
		if rotatingLeft then
			currentFacing = currentFacing - (1 * elapsed)   -- 1 rad/s vers la gauche
			creatureModel:SetFacing(currentFacing)
		elseif rotatingRight then
			currentFacing = currentFacing + (1 * elapsed)   -- 1 rad/s vers la droite
			creatureModel:SetFacing(currentFacing)
		end
	end)
	
	-----------------------------------------------------------------
    -- Boutons de rotation : « ← » et « → »
    -----------------------------------------------------------------
 
    -- Bouton “Rotation gauche”
    local btnRotateLeft = CreateFrame("Button", "RotateLeftButton", creaturePreviewFrame, "UIPanelButtonTemplate")
    btnRotateLeft:SetSize(20, 20)
    btnRotateLeft:SetPoint("BOTTOMLEFT", creaturePreviewFrame, "BOTTOMLEFT", 10, 10)
    btnRotateLeft:SetText("<<")
    TrinityAdmin.AutoSize(btnRotateLeft, 14, 14)
    
	btnRotateLeft:SetScript("OnClick", function()
        -- On décrémente l'angle puis on applique la rotation
        currentFacing = currentFacing - 0.1    -- 0.1 rad  5.7°
        creatureModel:SetFacing(currentFacing)
    end)
	
	btnRotateLeft:SetScript("OnMouseDown", function(self)
    rotatingLeft = true
	end)
	btnRotateLeft:SetScript("OnMouseUp", function(self)
		rotatingLeft = false
	end)
 
    -- Bouton “Rotatation droite”
    local btnRotateRight = CreateFrame("Button", "RotateRightButton", creaturePreviewFrame, "UIPanelButtonTemplate")
    btnRotateRight:SetSize(20, 20)
    btnRotateRight:SetPoint("BOTTOMRIGHT", creaturePreviewFrame, "BOTTOMRIGHT", -10, 10)
    btnRotateRight:SetText(">>")
    TrinityAdmin.AutoSize(btnRotateRight, 14, 14)
    
	btnRotateRight:SetScript("OnClick", function()
        -- On incrémente l'angle puis on applique la rotation
        currentFacing = currentFacing + 0.1
        creatureModel:SetFacing(currentFacing)
    end)
	
	btnRotateRight:SetScript("OnMouseDown", function(self)
    rotatingRight = true
	end)
	btnRotateRight:SetScript("OnMouseUp", function(self)
		rotatingRight = false
	end)

    -- Cacher la preview seulement lorsque la souris quitte TOUTE LA FRAME
    creaturePreviewFrame:SetScript("OnLeave", function(self)
       self:Hide()
    end)	

    ------------------------------------------------------------
    -- Fonction PopulateGOScroll pour peupler la liste des pnj
    ------------------------------------------------------------

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
        -- TrinityAdmin:Print("isFiltered:", isFiltered, "totalEntriesLocal:", totalEntriesLocal, "currentPage:", currentPage)

        if isFiltered then
            local startIdx = (currentPage - 1) * entriesPerPage + 1
            local endIdx = math.min(currentPage * entriesPerPage, totalEntriesLocal)
            -- TrinityAdmin:Print("Mode filtré: startIdx:", startIdx, "endIdx:", endIdx)
            for i = startIdx, endIdx do
                if sourceData[i] then
                    table.insert(optionsChunk, sourceData[i])
                end
            end
        else
            optionsChunk = sourceData
            -- TrinityAdmin:Print("OptionsChunk size:", #optionsChunk)
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
			creatureModel:SetDisplayInfo(option.DisplayId)
			creaturePreviewFrame:Show()
			end)
			
			-- Lorsqu'on quitte le bouton, on masque la frame
			-- btn:SetScript("OnLeave", function(self)
				-- creaturePreviewFrame:Hide()
			-- end)

			btn:SetScript("OnClick", function()
			local command = ""
			command = ".npc add " .. option.entry
			-- TrinityAdmin:Print("Option cliquée :", fullText, "Entry:", option.entry)
			-- TrinityAdmin:Print("Commande envoyée :", command)
			-- SendChatMessage(command, "SAY")
			TrinityAdmin:SendCommand(command)
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

    local function SearchNpc(search)
        local results = {}
        local normalizedSearch = removeAccents(search:lower())

        for _, entry in ipairs(NPCData) do
            if entry.normalizedName:find(normalizedSearch, 1, true) or tostring(entry.entry) == search then
                table.insert(results, entry)
            end
        end
        -- TrinityAdmin:Print("Nombre de résultats trouvés :", #results)
        return results
    end

    filterEditBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        local searchText = self:GetText():lower()

        if searchText == L["search..."] or #searchText < 3 then
            TrinityAdmin:Print(L["Please enter at least 3 characters for the search."])
            return
        end

        currentPage = 1
        currentResults = SearchNpc(searchText) or {} -- Assure une table vide, jamais nil
        PopulateGOScroll(currentResults)
    end)

    ------------------------------------------------------------
    -- Bouton "Reset" pour revenir à la liste complète
    ------------------------------------------------------------
    local btnReset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnReset:SetText(L["Reset"])
	TrinityAdmin.AutoSize(btnReset, 20, 16)
    btnReset:SetPoint("RIGHT", filterEditBox, "RIGHT", -155, 0)
	btnReset:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Reset Search Field"], 1, 1, 1, 1, true)
		GameTooltip:Show()
    end)
    btnReset:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
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
    -- Bouton "Delete" pour revenir à la liste complète
    ------------------------------------------------------------
    local btnDelete = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnDelete:SetText(L["Delete Npc"])
	TrinityAdmin.AutoSize(btnDelete, 20, 16)
    btnDelete:SetPoint("LEFT", filterEditBox, "RIGHT", 10, 0)
	btnDelete:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Delete Selected NPC"], 1, 1, 1, 1, true)
		GameTooltip:Show()
    end)
    btnDelete:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)	
    btnDelete:SetScript("OnClick", function()
		if not UnitExists("target") then 
		TrinityAdmin:Print(L["Please Select a Creature!"]) 
		return 
		end
	local command = ".npc delete" 
	--print("Commande envoyée :", command) 
	TrinityAdmin:SendCommand(command) 
	end)
    ------------------------------------------------------------
    -- Bouton "Move" pour revenir à la liste complète
    ------------------------------------------------------------
    local btnMove = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnMove:SetText(L["Move Npc"])
	TrinityAdmin.AutoSize(btnMove, 20, 16)
    btnMove:SetPoint("LEFT", btnDelete, "RIGHT", 10, 0)
	btnMove:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Move the NPC to your coordinates."], 1, 1, 1, 1, true)
		GameTooltip:Show()
    end)
    btnMove:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)	
    btnMove:SetScript("OnClick", function()
		if not UnitExists("target") then 
		TrinityAdmin:Print(L["Please Select a Creature!"]) 
		return 
		end
		local command = ""
		command = ".npc move "
		--TrinityAdmin:Print("Commande envoyée :", command)
		TrinityAdmin:SendCommand(command)
	end)	
    ------------------------------------------------------------
    -- Bouton "Back" pour revenir au menu principal
    ------------------------------------------------------------

	local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetText(L["Back"])
	TrinityAdmin.AutoSize(btnBack, 20, 16)
    btnBack:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
