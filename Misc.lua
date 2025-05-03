local Misc = TrinityAdmin:GetModule("Misc")
local L = _G.L

-------------------------------------------------------------------------------
-- Variables de capture "lookup"
-------------------------------------------------------------------------------
local capturingLookup = false
local lookupInfoCollected = {}
local lookupInfoTimer = nil

-------------------------------------------------------------------------------
-- 1) DÉPLACER ProcessLookupCapturedText AVANT l'usage
-------------------------------------------------------------------------------
local function ProcessLookupCapturedText(input)
    local text = (type(input) == "table") and table.concat(input, "\n") or input
    local processedLines = {}
    for line in text:gmatch("[^\r\n]+") do
        table.insert(processedLines, line)
    end
    return processedLines
end

-------------------------------------------------------------------------------
-- 2) Frame pour écouter l'événement, utilisation de ProcessLookupCapturedText
-------------------------------------------------------------------------------
local lookupCaptureFrame = CreateFrame("Frame")
lookupCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
lookupCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingLookup then return end

    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
                       :gsub("|r", "")
                       :gsub("|H.-|h(.-)|h", "%1")
                       :gsub("|T.-|t", "")
                       :gsub("\226[\148-\149][\128-\191]", "")

    table.insert(lookupInfoCollected, cleanMsg)

    if lookupInfoTimer then
        lookupInfoTimer:Cancel()
    end
    lookupInfoTimer = C_Timer.NewTimer(1, function()
        capturingLookup = false
        local fullText = table.concat(lookupInfoCollected, "\n")

        -- ICI on appelle ProcessLookupCapturedText, qui existe déjà
        local lines = ProcessLookupCapturedText(fullText)

        ShowLookupAceGUI(lines)
    end)
end)

-------------------------------------------------------------------------------
-- Fenêtre AceGUI pour afficher le résultat
-------------------------------------------------------------------------------
local AceGUI = LibStub("AceGUI-3.0")
function ShowLookupAceGUI(lines)
    -- Crée la fenêtre
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["Lookup Info"])
    frame:SetStatusText(L["Information from .lookup"])
    frame:SetLayout("Flow")
    frame:SetWidth(600)
    frame:SetHeight(500)

    -- Un ScrollFrame AceGUI
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    frame:AddChild(scroll)

    -- Pour chaque ligne, on crée un EditBox
    -- for i, line in ipairs(lines) do
    --     -- On sépare label et valeur si on veut
    --     local labelText = line:match("^(.-):") or ("Line " .. i)
    --     local valueText = line:match("^[^:]+:%s*(.+)") or line
    --     
    --     local edit = AceGUI:Create("EditBox")
    --     edit:SetLabel("|cffffff00" .. labelText .. ":|r")
    --     edit:SetText(valueText)
    --     edit:SetFullWidth(true)
    --     scroll:AddChild(edit)
    -- end
	for i, line in ipairs(lines) do
        local edit = AceGUI:Create("EditBox")
        -- edit:SetLabel("Line " .. i)
		edit:SetLabel(L["Line"] .. " " .. i)
        edit:SetText(line)
        edit:SetFullWidth(true)
        scroll:AddChild(edit)
    end

    -- Bouton de fermeture
    local btnClose = AceGUI:Create("Button")
    btnClose:SetText(L["Close"])
    btnClose:SetWidth(100)
    btnClose:SetCallback("OnClick", function() frame:Hide() end)
    frame:AddChild(btnClose)
end

-------------------------------------------------------------------------------
-- Pour lancer la capture avant d'envoyer la commande .lookup
-------------------------------------------------------------------------------
function StartLookupCapture()
    -- On vide les anciennes infos
    wipe(lookupInfoCollected)
    capturingLookup = true
    -- Si un timer existe, on l'annule
    if lookupInfoTimer then
        lookupInfoTimer:Cancel()
        lookupInfoTimer = nil
    end
end

------------------------------------------------------------
-- Méthode pour ajouter les boutons de gestion sur le panneau principal
------------------------------------------------------------
function Misc:AddManagementButtons(panel)
    local btnTitles = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnTitles:SetPoint("TOPLEFT", panel, "TOPLEFT", 100, -80)
    btnTitles:SetText(L["Titles Management"])
	btnTitles:SetWidth(btnTitles:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	btnTitles:SetHeight(22)	
    btnTitles:SetScript("OnClick", function() self:OpenTitlesManagement() end)
    
    local btnResets = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnResets:SetPoint("LEFT", btnTitles, "RIGHT", 10, 0)
    btnResets:SetText(L["Resets Management"])
	btnResets:SetWidth(btnResets:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	btnResets:SetHeight(22)	
    btnResets:SetScript("OnClick", function() self:OpenResetsManagement() end)
    
    local btnArena = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnArena:SetPoint("LEFT", btnResets, "RIGHT", 10, 0)
    btnArena:SetText(L["Arena Management"])
	btnArena:SetWidth(btnArena:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	btnArena:SetHeight(22)	
    btnArena:SetScript("OnClick", function() self:OpenArenaManagement() end)
    
    local btnLookup = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnLookup:SetPoint("TOPLEFT", btnTitles, "BOTTOMLEFT", 0, -10)
    btnLookup:SetText(L["Lookup Functions"])
	btnLookup:SetWidth(btnLookup:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	btnLookup:SetHeight(22)	
    btnLookup:SetScript("OnClick", function() self:OpenLookupFunctions() end)
    
    local btnGroups = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnGroups:SetPoint("LEFT", btnLookup, "RIGHT", 10, 0)
    btnGroups:SetText(L["Groups Management"])
	btnGroups:SetWidth(btnGroups:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	btnGroups:SetHeight(22)	
    btnGroups:SetScript("OnClick", function() self:OpenGroupsManagement() end)
    
    local btnQuests = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnQuests:SetPoint("LEFT", btnGroups, "RIGHT", 10, 0)
    btnQuests:SetText(L["Quests Management"])
	btnQuests:SetWidth(btnQuests:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	btnQuests:SetHeight(22)	
    btnQuests:SetScript("OnClick", function() self:OpenQuestsManagement() end)
	
	local BattlefieldAndPvp = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    BattlefieldAndPvp:SetPoint("TOPLEFT", btnLookup, "BOTTOMLEFT", 0, -10)
    BattlefieldAndPvp:SetText(L["Battlefield And Pvp"])
	BattlefieldAndPvp:SetWidth(BattlefieldAndPvp:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	BattlefieldAndPvp:SetHeight(22)	
    BattlefieldAndPvp:SetScript("OnClick", function() self:OpenBattlefieldAndPvpManagement() end)
	
	local DunjonsFunc = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    DunjonsFunc:SetPoint("LEFT", BattlefieldAndPvp, "RIGHT", 10, 0)
    DunjonsFunc:SetText(L["Dungeons Funcs"])
	DunjonsFunc:SetWidth(DunjonsFunc:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	DunjonsFunc:SetHeight(22)		
    DunjonsFunc:SetScript("OnClick", function() self:OpenDunjonsFuncManagement() end)
	
	local LfgManage = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    LfgManage:SetPoint("LEFT", DunjonsFunc, "RIGHT", 10, 0)
    LfgManage:SetText(L["LFG Management"])
	LfgManage:SetWidth(LfgManage:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	LfgManage:SetHeight(22)	
    LfgManage:SetScript("OnClick", function() self:OpenLfgManageManagement() end)
	
	local EventsManage = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    EventsManage:SetPoint("TOPLEFT", BattlefieldAndPvp, "BOTTOMLEFT", 0, -10)
    EventsManage:SetText(L["Events Manager"])
	EventsManage:SetWidth(EventsManage:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	EventsManage:SetHeight(22)	
    EventsManage:SetScript("OnClick", function() self:OpenEventsManageManagement() end)
	
	local AurasList = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    AurasList:SetPoint("LEFT", EventsManage, "RIGHT", 10, 0)
    AurasList:SetText(L["Auras and Lists Management"])
	AurasList:SetWidth(AurasList:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
	AurasList:SetHeight(22)
    AurasList:SetScript("OnClick", function() self:OpenAurasListManagement() end)
	
end

------------------------------------------------------------
-- Crée le panneau principal Misc
------------------------------------------------------------
function Misc:CreateMiscPanel()
    local panel = CreateFrame("Frame", "TrinityAdminMiscPanel", TrinityAdminMainFrame)
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
    
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)
    
    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(L["Misc Functions"])
    
    -- Ajoute les boutons de gestion
    self:AddManagementButtons(panel)
    
    -- Bouton Retour
    local btnBack = CreateFrame("Button", "TrinityAdminMiscBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(L["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)
    
    self.panel = panel
end

------------------------------------------------------------
-- Affiche le panneau principal Misc
------------------------------------------------------------
function Misc:ShowMiscPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateMiscPanel()
    end
    self.panel:Show()
end

------------------------------------------------------------
-- TITLES MANAGEMENT
------------------------------------------------------------
function Misc:OpenTitlesManagement()
    if self.panel then
        self.panel:Hide()
    end
    
    -- Si le panneau n'existe pas déjà, on le crée
    if not self.titlesPanel then
        
        -- Création du frame principal
        self.titlesPanel = CreateFrame("Frame", "TrinityAdminTitlesPanel", TrinityAdminMainFrame)
        self.titlesPanel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
        self.titlesPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

        local bg = self.titlesPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.titlesPanel)
        bg:SetColorTexture(0.3, 0.3, 0.6, 0.7)

        self.titlesPanel.title = self.titlesPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.titlesPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.titlesPanel.title:SetText(L["Titles Management"])

        ------------------------------------------------------------
        -- VARIABLES LOCALES POUR LA PAGINATION, CHECKBOXES, ETC.
        ------------------------------------------------------------
        local entriesPerPage = 10
        local currentPage = 1
        local currentOptions = {}  -- la liste courante
        local filterEditBox, scrollFrame, scrollChild
        local btnPrev, btnNext, btnPage
        local chkAdd, chkRemove, chkCurrent
        local editMask, btnSetMask

        ------------------------------------------------------------
        -- CHAMP DE RECHERCHE + SCROLLFRAME
        ------------------------------------------------------------
        filterEditBox = CreateFrame("EditBox", nil, self.titlesPanel, "InputBoxTemplate")
        filterEditBox:SetSize(150, 22)
        filterEditBox:SetPoint("TOPLEFT", self.titlesPanel, "TOPLEFT", 10, -40)
        filterEditBox:SetText(L["Search..."])
        filterEditBox:SetAutoFocus(false)
        filterEditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

        scrollFrame = CreateFrame("ScrollFrame", nil, self.titlesPanel, "UIPanelScrollFrameTemplate")
        scrollFrame:SetSize(220, 200)
        scrollFrame:SetPoint("TOPLEFT", filterEditBox, "BOTTOMLEFT", 0, -5)
        scrollFrame:SetPoint("BOTTOMLEFT", self.titlesPanel, "BOTTOMLEFT", 10, 50)

        scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(220, 400)
        scrollFrame:SetScrollChild(scrollChild)

        ------------------------------------------------------------
        -- BOUTONS DE PAGINATION
        ------------------------------------------------------------
        btnPage = CreateFrame("Button", nil, self.titlesPanel, "UIPanelButtonTemplate")
        btnPage:SetSize(90, 22)
        btnPage:SetPoint("BOTTOMRIGHT", self.titlesPanel, "BOTTOM", -160, 10)
        btnPage:SetText("Page 1 / 1")

        btnPrev = CreateFrame("Button", nil, self.titlesPanel, "UIPanelButtonTemplate")
        btnPrev:SetSize(80, 22)
        btnPrev:SetText(L["Preview"])
        btnPrev:SetPoint("RIGHT", btnPage, "LEFT", -5, 0)

        btnNext = CreateFrame("Button", nil, self.titlesPanel, "UIPanelButtonTemplate")
        btnNext:SetSize(80, 22)
        btnNext:SetText(L["Next"])
        btnNext:SetPoint("LEFT", btnPage, "RIGHT", 5, 0)

        ------------------------------------------------------------
        -- CREATION DU CONTENEUR D'OPTIONS (CHECKBOXES)
        ------------------------------------------------------------
        local optionsFrame = CreateFrame("Frame", nil, self.titlesPanel)
        optionsFrame:SetSize(200, 150)
        optionsFrame:SetPoint("RIGHT", self.titlesPanel, "RIGHT", -100, 0)
        optionsFrame:SetPoint("CENTER", self.titlesPanel, "CENTER", -self.titlesPanel:GetWidth()/4, 0)

        -- CHECKBOXES : add, remove, current
        chkAdd = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
        chkAdd:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 0, -10)
        chkAdd.text = chkAdd:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chkAdd.text:SetPoint("LEFT", chkAdd, "RIGHT", 5, 0)
        chkAdd.text:SetText(L["Add a Title"])

        chkRemove = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
        chkRemove:SetPoint("TOPLEFT", chkAdd, "BOTTOMLEFT", 0, -10)
        chkRemove.text = chkRemove:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chkRemove.text:SetPoint("LEFT", chkRemove, "RIGHT", 5, 0)
        chkRemove.text:SetText(L["Remove a Title"])

        chkCurrent = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
        chkCurrent:SetPoint("TOPLEFT", chkRemove, "BOTTOMLEFT", 0, -10)
        chkCurrent.text = chkCurrent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chkCurrent.text:SetPoint("LEFT", chkCurrent, "RIGHT", 5, 0)
        chkCurrent.text:SetText(L["Set Title as Current"])

        -- EDItBOX & BOUTON "SET" : titles set mask
        editMask = CreateFrame("EditBox", nil, optionsFrame, "InputBoxTemplate")
        editMask:SetSize(100, 22)
        editMask:SetPoint("TOPLEFT", chkCurrent, "BOTTOMLEFT", 0, -10)
        editMask:SetText(L["Set titles mask"])

        btnSetMask = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
        btnSetMask:SetSize(80, 22)
        btnSetMask:SetPoint("LEFT", editMask, "RIGHT", 5, 0)
        btnSetMask:SetText(L["Set"])

        ------------------------------------------------------------
        -- FORCER LA SELECTION EXCLUSIVE DES CHECKBOXES
        ------------------------------------------------------------
        chkAdd:SetScript("OnClick", function(self)
            if self:GetChecked() then
                chkRemove:SetChecked(false)
                chkCurrent:SetChecked(false)
            end
        end)
        chkRemove:SetScript("OnClick", function(self)
            if self:GetChecked() then
                chkAdd:SetChecked(false)
                chkCurrent:SetChecked(false)
            end
        end)
        chkCurrent:SetScript("OnClick", function(self)
            if self:GetChecked() then
                chkAdd:SetChecked(false)
                chkRemove:SetChecked(false)
            end
        end)

        btnSetMask:SetScript("OnClick", function()
            local targetName = UnitName("target")
            if not targetName then
                print(L["Please Select a Character!"])
                return
            end
            local maskValue = editMask:GetText()
            if maskValue == "" or maskValue == "Set titles mask" then
                print(L["Please enter a value for mask."])
                return
            end
            -- Envoie la commande
            SendChatMessage(".titles set mask " .. maskValue, "SAY")
            editMask:SetText(L["Set titles mask"])
        end)

        ------------------------------------------------------------
        -- FONCTION LOCALE "PopulateTitlescroll"
        ------------------------------------------------------------
        local function PopulateTitlescroll(options)
            currentOptions = options
            local targetName = UnitName("target")  -- nil si aucune cible

            local totalEntries = #options
            local totalPages   = math.ceil(totalEntries / entriesPerPage)
            if totalPages < 1 then totalPages = 1 end

            -- Ajuster currentPage
            if currentPage > totalPages then currentPage = totalPages end
            if currentPage < 1 then currentPage = 1 end

            -- Cache d'éventuels anciens boutons
            if scrollChild.buttons then
                for _, btn in ipairs(scrollChild.buttons) do
                    btn:Hide()
                end
            else
                scrollChild.buttons = {}
            end

            local startIdx = (currentPage - 1) * entriesPerPage + 1
            local endIdx   = math.min(currentPage * entriesPerPage, totalEntries)

            local lastButton = nil
            local maxTextLength = 20

            for i = startIdx, endIdx do
                local option = options[i]
                local btn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
                btn:SetSize(200, 20)

                if not lastButton then
                    btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -10)
                else
                    btn:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -5)
                end

                -- Construire le texte (remplace %s par targetName)
                local fullText = L[option.name] or ("Item " .. i)
                if targetName then
                    fullText = fullText:gsub("%%s", targetName)
                end

                local truncatedText = fullText
                if #fullText > maxTextLength then
                    truncatedText = fullText:sub(1, maxTextLength) .. "..."
                end

                btn:SetText(truncatedText)
                
                -- Tooltip au survol
                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(fullText, 1, 1, 1, 1, true)
                    GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                end)

                -- OnClick : vérifie la cible + envoie la commande
                btn:SetScript("OnClick", function()
                    local targ = UnitName("target")
                    if not targ then
                        print(L["Please Select a Character!"])
                        return
                    end
                    if chkAdd:GetChecked() then
                        SendChatMessage(".titles add " .. option.entry, "SAY")
                    elseif chkRemove:GetChecked() then
                        SendChatMessage(".titles remove " .. option.entry, "SAY")
                    elseif chkCurrent:GetChecked() then
                        SendChatMessage(".titles current " .. option.entry, "SAY")
                    else
                        print(L["Please secte add/remove/current, or use Set for mask."])
                    end
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

            btnPrev:SetEnabled(currentPage > 1)
            btnNext:SetEnabled(currentPage < totalPages)
        end

        ------------------------------------------------------------
        -- EVENT LISTENER : PLAYER_TARGET_CHANGED
        ------------------------------------------------------------
        local targetListener = CreateFrame("Frame")
        targetListener:RegisterEvent("PLAYER_TARGET_CHANGED")
        targetListener:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_TARGET_CHANGED" then
                -- Réactualise la liste si on a déjà des options
                if currentOptions and #currentOptions > 0 then
                    PopulateTitlescroll(currentOptions)
                end
            end
        end)

        ------------------------------------------------------------
        -- Scripts pagination, filtre, Reset, etc.
        ------------------------------------------------------------
        btnPrev:SetScript("OnClick", function()
            if currentPage > 1 then
                currentPage = currentPage - 1
                PopulateTitlescroll(currentOptions)
            end
        end)

        btnNext:SetScript("OnClick", function()
            local totalPages = math.ceil(#currentOptions / entriesPerPage)
            if currentPage < totalPages then
                currentPage = currentPage + 1
                PopulateTitlescroll(currentOptions)
            end
        end)

        -- Remplissage initial
        local defaultOptions = {}
        for i = 1, #TitlesData do
            table.insert(defaultOptions, TitlesData[i])
        end
        currentPage = 1
        PopulateTitlescroll(defaultOptions)

        -- Filtre
        filterEditBox:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            local searchText = self:GetText():lower()
            if #searchText < 3 then
                print(L["Please enter at least 3 characters for the search."])
                return
            end

            local filteredOptions = {}
            for _, option in ipairs(TitlesData) do
                if (option.name and option.name:lower():find(searchText))
                   or (tostring(option.entry) == searchText) then
                    table.insert(filteredOptions, option)
                end
            end

            if #filteredOptions == 0 then
                -- Cache les anciens boutons
                if scrollChild.buttons then
                    for _, btn in ipairs(scrollChild.buttons) do
                        btn:Hide()
                    end
                end
                -- Affiche "Nothing found"
                if not scrollChild.noResultText then
                    scrollChild.noResultText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    scrollChild.noResultText:SetPoint("TOP", scrollChild, "TOP", 0, -10)
                    scrollChild.noResultText:SetText("|cffff0000" .. L["nothing_found"] .. "|r")
                end
                scrollChild.noResultText:Show()
                scrollChild:SetHeight(50)
            else
                if scrollChild.noResultText then
                    scrollChild.noResultText:Hide()
                end
                currentPage = 1
                PopulateTitlescroll(filteredOptions)
            end
        end)

        -- Bouton Reset
        local btnReset = CreateFrame("Button", nil, self.titlesPanel, "UIPanelButtonTemplate")
        btnReset:SetText(L["Reset"])
		btnReset:SetWidth(btnReset:GetTextWidth() + 20)  -- Ajoute une marge de 20 pixels
		btnReset:SetHeight(22)	
        btnReset:SetPoint("LEFT", filterEditBox, "RIGHT", 10, 0)
        btnReset:SetScript("OnClick", function()
            filterEditBox:SetText("")
            currentPage = 1
            PopulateTitlescroll(TitlesData)
            if scrollChild.noResultText then
                scrollChild.noResultText:Hide()
            end
        end)

        ------------------------------------------------------------
        -- Bouton Retour
        ------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.titlesPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.titlesPanel, "BOTTOM", 0, 10)
        btnBack:SetText(L["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
        btnBack:SetScript("OnClick", function()
            self.titlesPanel:Hide()
            self.panel:Show()
        end)
    end

    TrinityAdmin:HideMainMenu()
    self.titlesPanel:Show()
end

-- Ouvre le panneau Resets Management en masquant le panneau principal
function Misc:OpenResetsManagement()
    if self.panel then
        self.panel:Hide()
    end
    
    if not self.resetsPanel then
        -- Crée le frame principal du panneau Resets
        self.resetsPanel = CreateFrame("Frame", "TrinityAdminResetsPanel", TrinityAdminMainFrame)
        self.resetsPanel:SetPoint("TOPLEFT",  TrinityAdminMainFrame, "TOPLEFT",     10, -50)
        self.resetsPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.resetsPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(true)
        bg:SetColorTexture(0.4, 0.2, 0.2, 0.7)
        
        self.resetsPanel.title = self.resetsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.resetsPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.resetsPanel.title:SetText(L["Resets Management"])
        
        ------------------------------------------------------------
        -- Petite fonction utilitaire pour récupérer un nom cible
        ------------------------------------------------------------
        local function GetPlayerNameOrTarget(editBox)
            local text = editBox:GetText()
            if text and text ~= "" and text ~= "Player Name" then
                return text
            end
            local tName = UnitName("target")
            if tName then
                return tName
            end
            return "$playername"
        end
        
        ------------------------------------------------------------
        -- Petit offset vertical pour disposer les éléments
        ------------------------------------------------------------
        local yOffset = -40
        
        ------------------------------------------------------------
        -- 1) Reset Achievements
        ------------------------------------------------------------
        do
            local editBox = CreateFrame("EditBox", nil, self.resetsPanel, "InputBoxTemplate")
            editBox:SetSize(120, 22)
            editBox:SetPoint("TOPLEFT", self.resetsPanel, "TOPLEFT", 10, yOffset)
            editBox:SetText(L["Player Name"])
            editBox:SetAutoFocus(false)
            
            local btn = CreateFrame("Button", nil, self.resetsPanel, "UIPanelButtonTemplate")
            btn:SetSize(140, 22)
            btn:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
            btn:SetText(L["Reset Achievements"])
            
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["reset_achevements_desc"], 1,1,1,1,true)
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            
            btn:SetScript("OnClick", function()
                local nameToUse = GetPlayerNameOrTarget(editBox)
                SendChatMessage(".reset achievements " .. nameToUse, "SAY")
            end)
            
            yOffset = yOffset - 40
        end
        
        ------------------------------------------------------------
        -- 2) Reset All Spells / Reset All Talents + bouton "Reset"
        ------------------------------------------------------------
        do
            local chkSpells = CreateFrame("CheckButton", nil, self.resetsPanel, "UICheckButtonTemplate")
            chkSpells:SetPoint("TOPLEFT", self.resetsPanel, "TOPLEFT", 10, yOffset + 5)
            chkSpells.text = chkSpells:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            chkSpells.text:SetPoint("LEFT", chkSpells, "RIGHT", 5, 0)
            chkSpells.text:SetText(L["Reset All Spells"])
            
            local chkTalents = CreateFrame("CheckButton", nil, self.resetsPanel, "UICheckButtonTemplate")
            chkTalents:SetPoint("TOPLEFT", chkSpells, "BOTTOMLEFT", 0, -10)
            chkTalents.text = chkTalents:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            chkTalents.text:SetPoint("LEFT", chkTalents, "RIGHT", 5, 0)
            chkTalents.text:SetText(L["Reset All Talents"])
            
            -- On coche "Spells" par défaut
            chkSpells:SetChecked(true)

            -- Forcer la sélection exclusive (exactement un coché)
            chkSpells:SetScript("OnClick", function(self)
                if self:GetChecked() then
                    chkTalents:SetChecked(false)
                else
                    if not chkTalents:GetChecked() then
                        self:SetChecked(true)
                    end
                end
            end)

            chkTalents:SetScript("OnClick", function(self)
                if self:GetChecked() then
                    chkSpells:SetChecked(false)
                else
                    if not chkSpells:GetChecked() then
                        self:SetChecked(true)
                    end
                end
            end)
            
            local btn = CreateFrame("Button", nil, self.resetsPanel, "UIPanelButtonTemplate")
            btn:SetSize(80, 22)
            btn:SetPoint("LEFT", chkTalents, "RIGHT", 120, 20)
            btn:SetText(L["Reset"])
            
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["reset_spells_desc"], 1,1,1,1,true)
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            
            btn:SetScript("OnClick", function()
                if chkSpells:GetChecked() then
                    SendChatMessage(".reset all spells", "SAY")
                elseif chkTalents:GetChecked() then
                    SendChatMessage(".reset all talents", "SAY")
                else
                    print(L["Please check 'Reset All Spells' or 'Reset All Talents' before clicking Reset."])
                end
            end)
            
            yOffset = yOffset - 70
        end
        
        ------------------------------------------------------------
        -- Définition locale de CreateResetRow
        ------------------------------------------------------------
        local function CreateResetRow(labelText, tooltipText, command)
            local editBox = CreateFrame("EditBox", nil, self.resetsPanel, "InputBoxTemplate")
            editBox:SetSize(120, 22)
            editBox:SetPoint("TOPLEFT", self.resetsPanel, "TOPLEFT", 10, yOffset)
            editBox:SetText(L["Player Name"])
            editBox:SetAutoFocus(false)
            
            local btn = CreateFrame("Button", nil, self.resetsPanel, "UIPanelButtonTemplate")
            btn:SetSize(100, 22)
            btn:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
            btn:SetText(labelText)
            
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipText, 1,1,1,1,true)
            end)
            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            
            btn:SetScript("OnClick", function()
                local targetName = UnitName("target")
                local textValue = editBox:GetText()
                
                local finalName = "$playername"
                if textValue and textValue ~= "" and textValue ~= "Player Name" then
                    finalName = textValue
                elseif targetName then
                    finalName = targetName
                end
                -- print("[DEBUG] Commande envoyée: " .. command .. " " .. finalName)
                SendChatMessage(command .. " " .. finalName, "SAY")
            end)
            
            yOffset = yOffset - 40
        end
        
        ------------------------------------------------------------
        -- 3) Reset Honor
        ------------------------------------------------------------
        CreateResetRow(
            L["Reset Honor"],
			L["reset_honor_desc"],
            ".reset honor"
        )
        
        ------------------------------------------------------------
        -- 4) Reset Level
        ------------------------------------------------------------
        CreateResetRow(
            L["Reset Level"],
			L["reset_level_desc"],
            ".reset level"
        )
        
        ------------------------------------------------------------
        -- 5) Reset Spells
        ------------------------------------------------------------
        CreateResetRow(
            L["Reset Spells"],
			L["reset_spells_desc"],
            ".reset spells"
        )
        
        ------------------------------------------------------------
        -- 6) Reset Stats
        ------------------------------------------------------------
        CreateResetRow(
            L["Reset Stats"],
			L["reset_stats_desc"],
            ".reset stats"
        )
        
        ------------------------------------------------------------
        -- 7) Reset Talents
        ------------------------------------------------------------
        CreateResetRow(
            L["Reset Talents"],
            L["reset_talents_desc"],
            ".reset talents"
        )
        
        ------------------------------------------------------------
        -- Bouton Retour
        ------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.resetsPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.resetsPanel, "BOTTOM", 0, 10)
        btnBack:SetText(L["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
        btnBack:SetScript("OnClick", function()
            self.resetsPanel:Hide()
            self.panel:Show()
        end)
    end

    TrinityAdmin:HideMainMenu()
    self.resetsPanel:Show()
end

-- Ouvre le panneau Arena Management en masquant le panneau principal
function Misc:OpenArenaManagement()
    if self.panel then
        self.panel:Hide()
    end
    if not self.arenaPanel then
        self.arenaPanel = CreateFrame("Frame", "TrinityAdminArenaPanel", TrinityAdminMainFrame)
        self.arenaPanel:SetPoint("TOPLEFT",  TrinityAdminMainFrame, "TOPLEFT",     10, -50)
        self.arenaPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.arenaPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.arenaPanel)
        bg:SetColorTexture(0.6, 0.05, 0.05, 0.8)  -- Couleur pour le panneau Arena Management
        
        self.arenaPanel.title = self.arenaPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.arenaPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.arenaPanel.title:SetText(L["Arena Management"])

        ------------------------------------------------------------
        -- Fonction utilitaire : reinitialiser un champ de saisie
        ------------------------------------------------------------
        local function ResetEditBox(editBox, defaultText)
            editBox:SetText(defaultText)
        end

        ------------------------------------------------------------
        -- Conteneur pour organiser les éléments
        ------------------------------------------------------------
        local container = CreateFrame("Frame", nil, self.arenaPanel)
        container:SetPoint("TOPLEFT", self.arenaPanel, "TOPLEFT", 10, -40)
        container:SetSize(self.arenaPanel:GetWidth() - 20, self.arenaPanel:GetHeight() - 80)

        ------------------------------------------------------------
        -- yOffset pour descendre les blocs l'un sous l'autre
        ------------------------------------------------------------
        local yOffset = 0

        ------------------------------------------------------------
        -- 1) CREATE ARENA TEAM
        ------------------------------------------------------------
        do
            local editLeader = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editLeader:SetSize(100, 22)
            editLeader:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editLeader:SetText(L["Leader Name"])
            editLeader:SetAutoFocus(false)
            
            local editTeam  = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editTeam:SetSize(100, 22)
            editTeam:SetPoint("LEFT", editLeader, "RIGHT", 10, 0)
            editTeam:SetText(L["Team Name"])
            editTeam:SetAutoFocus(false)
            
            local editType  = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editType:SetSize(40, 22)
            editType:SetPoint("LEFT", editTeam, "RIGHT", 10, 0)
            editType:SetText(L["Type"])
            editType:SetAutoFocus(false)
            
            local btnCreate = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnCreate:SetText(L["Create Arena Team"])
            -- Ajuste automatiquement la largeur du bouton en fonction du texte
            btnCreate:SetSize(btnCreate:GetTextWidth() + 20, 22)
            btnCreate:SetPoint("LEFT", editType, "RIGHT", 10, 0)
            
            -- Tooltip
            btnCreate:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["A command to create a new Arena-team in game.#type = [2/3/5]"], 1,1,1,1,true)
            end)
            btnCreate:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- OnClick
            btnCreate:SetScript("OnClick", function()
                local leaderVal = editLeader:GetText()
                local teamVal   = editTeam:GetText()
                local typeVal   = editType:GetText()

                if not leaderVal or leaderVal == "" or leaderVal == "Leader Name" then
                    print(L["Please enter a valid Leader Name!"])
                    return
                end
                if not teamVal or teamVal == "" or teamVal == "Team Name" then
                    print(L["Please enter a valid Team Name!"])
                    return
                end
                if not typeVal or typeVal == "" or typeVal == "Type" then
                    print(L["Please select Type (2, 3 or 5)!"])
                    return
                end

                local typeNum = tonumber(typeVal)
                if not typeNum or (typeNum ~= 2 and typeNum ~= 3 and typeNum ~= 5) then
                    print(L["Type must be 2, 3 or 5."])
                    return
                end

                local cmd = ".arena create " .. leaderVal .. " \"" .. teamVal .. "\" " .. typeVal
                SendChatMessage(cmd, "SAY")

                -- Reset
                ResetEditBox(editLeader, "Leader Name")
                ResetEditBox(editTeam,   "Team Name")
                ResetEditBox(editType,   "Type")
            end)

            yOffset = yOffset - 40
        end
        
        ------------------------------------------------------------
        -- 2) CHANGE ARENA TEAM NAME
        ------------------------------------------------------------
        do
            local editOld = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editOld:SetSize(100, 22)
            editOld:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editOld:SetText("Old Name")
            editOld:SetAutoFocus(false)
            
            local editNew = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editNew:SetSize(100, 22)
            editNew:SetPoint("LEFT", editOld, "RIGHT", 10, 0)
            editNew:SetText("New Name")
            editNew:SetAutoFocus(false)

            local btnRename = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnRename:SetText(L["Change Arena Team Name"])
            btnRename:SetSize(btnRename:GetTextWidth() + 20, 22)
            btnRename:SetPoint("LEFT", editNew, "RIGHT", 10, 0)

            -- Tooltip
            btnRename:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Change_Arena_Team_Name_desc"], 1,1,1,1,true)
            end)
            btnRename:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- OnClick
            btnRename:SetScript("OnClick", function()
                local oldVal = editOld:GetText()
                local newVal = editNew:GetText()

                if not oldVal or oldVal == "" or oldVal == "Old Name" then
                    print(L["Please enter a validOld Name."])
                    return
                end
                if not newVal or newVal == "" or newVal == "New Name" then
                    print(L["Please enter a valid New Name."])
                    return
                end

                local cmd = ".arena rename \"" .. oldVal .. "\" \"" .. newVal .. "\""
                SendChatMessage(cmd, "SAY")

                -- Reset
                ResetEditBox(editOld, "Old Name")
                ResetEditBox(editNew, "New Name")
            end)

            yOffset = yOffset - 40
        end

        ------------------------------------------------------------
        -- 3) ASSIGN LEADERSHIP
        ------------------------------------------------------------
        do
            local editTeamID = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editTeamID:SetSize(60, 22)
            editTeamID:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editTeamID:SetText("Team ID")
            editTeamID:SetAutoFocus(false)
            
            local editLeaderName = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editLeaderName:SetSize(120, 22)
            editLeaderName:SetPoint("LEFT", editTeamID, "RIGHT", 10, 0)
            editLeaderName:SetText("New Leader Name")
            editLeaderName:SetAutoFocus(false)

            local btnCaptain = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnCaptain:SetText(L["Assign Leadership"])
            btnCaptain:SetSize(btnCaptain:GetTextWidth() + 20, 22)
            btnCaptain:SetPoint("LEFT", editLeaderName, "RIGHT", 10, 0)

            -- Tooltip
            btnCaptain:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Arena_captain_desc"], 1,1,1,1,true)
            end)
            btnCaptain:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

			-- OnClick
			btnCaptain:SetScript("OnClick", function()
				local teamID   = editTeamID:GetText()
				local leaderNm = editLeaderName:GetText()
			
				if not teamID or teamID == "" or teamID == "Team ID" then
					print(L["Please enter a valid Team ID."])
					return
				end
				if not leaderNm or leaderNm == "" or leaderNm == "New Leader Name" then
					print(L["Please enter a valid New Leader Name."])
					return
				end
			
				-- Vérifie que le nom ne comporte pas d'espaces
				if leaderNm:find("%s") then
					print(L["Leader name doesn't support spaces."])
					return
				end
			
				-- Aucune guillemets autour de leaderNm
				local cmd = ".arena captain " .. teamID .. " " .. leaderNm
				SendChatMessage(cmd, "SAY")
			
				-- Réinitialise les champs
				ResetEditBox(editTeamID,     "Team ID")
				ResetEditBox(editLeaderName, "New Leader Name")
			end)

            yOffset = yOffset - 40
        end

        ------------------------------------------------------------
        -- 4) GET TEAM INFO
        ------------------------------------------------------------
        do
            local editTeamID = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editTeamID:SetSize(60, 22)
            editTeamID:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editTeamID:SetText("Team ID")
            editTeamID:SetAutoFocus(false)
            
            local btnInfo = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnInfo:SetText(L["Get Team Info"])
            btnInfo:SetSize(btnInfo:GetTextWidth() + 20, 22)
            btnInfo:SetPoint("LEFT", editTeamID, "RIGHT", 10, 0)

            -- Tooltip
            btnInfo:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Team_info_desc"], 1,1,1,1,true)
            end)
            btnInfo:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- OnClick
            btnInfo:SetScript("OnClick", function()
                local teamID = editTeamID:GetText()
                if not teamID or teamID == "" or teamID == "Team ID" then
                    print(L["Please enter a valid Team ID."])
                    return
                end

                local cmd = ".arena info " .. teamID
                SendChatMessage(cmd, "SAY")

                ResetEditBox(editTeamID, "Team ID")
            end)

            yOffset = yOffset - 40
        end

        ------------------------------------------------------------
        -- 5) LOOKUP TEAMS
        ------------------------------------------------------------
        do
            local editTeamName = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editTeamName:SetSize(120, 22)
            editTeamName:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editTeamName:SetText("Team Name")
            editTeamName:SetAutoFocus(false)
            
            local btnLookup = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnLookup:SetText(L["Lookup Teams"])
            btnLookup:SetSize(btnLookup:GetTextWidth() + 20, 22)
            btnLookup:SetPoint("LEFT", editTeamName, "RIGHT", 10, 0)

            -- Tooltip
            btnLookup:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Lookup_teal_desc"], 1,1,1,1,true)
            end)
            btnLookup:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- OnClick
            btnLookup:SetScript("OnClick", function()
                local tName = editTeamName:GetText()
                if not tName or tName == "" or tName == "Team Name" then
                    print(L["Please enter a valid Team Name."])
                    return
                end

                local cmd = ".arena lookup " .. tName
                SendChatMessage(cmd, "SAY")

                ResetEditBox(editTeamName, "Team Name")
            end)

            yOffset = yOffset - 40
        end

        ------------------------------------------------------------
        -- 6) DISBAND TEAMS
        ------------------------------------------------------------
        do
            local editTeamID = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editTeamID:SetSize(60, 22)
            editTeamID:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editTeamID:SetText("Team ID")
            editTeamID:SetAutoFocus(false)
            
            local btnDisband = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnDisband:SetText(L["Disband Teams"])
            btnDisband:SetSize(btnDisband:GetTextWidth() + 20, 22)
            btnDisband:SetPoint("LEFT", editTeamID, "RIGHT", 10, 0)

            -- Tooltip
            btnDisband:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Disband_desc"], 1,1,1,1,true)
            end)
            btnDisband:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- OnClick
            btnDisband:SetScript("OnClick", function()
                local teamID = editTeamID:GetText()
                if not teamID or teamID == "" or teamID == "Team ID" then
                    print(L["Please enter a valid Team ID."])
                    return
                end

                local cmd = ".arena disband " .. teamID
                SendChatMessage(cmd, "SAY")

                ResetEditBox(editTeamID, "Team ID")
            end)

            yOffset = yOffset - 40
        end
        
        ------------------------------------------------------------
        -- Bouton Retour commun
        ------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.arenaPanel, "UIPanelButtonTemplate")
        btnBack:SetText(L["Back"])
        btnBack:SetSize(btnBack:GetTextWidth() + 20, 22)
        btnBack:SetPoint("BOTTOM", self.arenaPanel, "BOTTOM", 0, 10)
        btnBack:SetScript("OnClick", function()
            self.arenaPanel:Hide()
            self.panel:Show()
        end)
    end
    TrinityAdmin:HideMainMenu()
    self.arenaPanel:Show()
end


-- Ouvre le panneau Lookup Functions en masquant le panneau principal
function Misc:OpenLookupFunctions()
    if self.panel then
        self.panel:Hide()
    end
    if not self.lookupPanel then
        -- Création du panneau principal
        self.lookupPanel = CreateFrame("Frame", "TrinityAdminLookupPanel", TrinityAdminMainFrame)
        self.lookupPanel:SetPoint("TOPLEFT",  TrinityAdminMainFrame, "TOPLEFT",     10, -50)
        self.lookupPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.lookupPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.lookupPanel)
        bg:SetColorTexture(0.5, 0.5, 0.2, 0.7)
        
        self.lookupPanel.title = self.lookupPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.lookupPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.lookupPanel.title:SetText(L["Lookup Functions"])

        -------------------------------------------------------------------------
        -- Fonctions utilitaires
        -------------------------------------------------------------------------
        
        -- Réinitialiser un champ EditBox à une valeur par défaut
        local function ResetEditBox(editBox, defaultText)
            editBox:SetText(defaultText)
        end
        
        -- Fonction pour ajouter les résultats dans la fenêtre ACE3
        local function AppendLookupResult(line)
            TrinityAdmin:AppendAce3Line(line)
        end
        
        local function OnChatMsgSayFilter(selfFrame, event, msg, player, ...)
            AppendLookupResult(msg)
            return false
        end
        
        -- Installation d'un filtre sur le canal SAY
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", OnChatMsgSayFilter)

        -------------------------------------------------------------------------
        -- Création des options pour le premier menu déroulant (un seul champ + bouton)
        -------------------------------------------------------------------------
        local singleOptions = {
            {
                text       = L["lookup area"],
                defaultEB  = "Enter Area Name part",
                command    = ".lookup area",
                tooltip    = L["Lookup_area_desc"]
            },
            {
                text       = L["lookup creature"],
                defaultEB  = "Enter Creature Name part",
                command    = ".lookup creature",
                tooltip    = L["lookup_creature_desc"]
            },
            {
                text       = L["lookup event"],
                defaultEB  = "Enter Event Neme",  -- y a-t-il un correctif => "Enter Event Name" ?
                command    = ".lookup event",
                tooltip    = L["lookup_event_desc"]
            },
            {
                text       = L["lookup faction"],
                defaultEB  = "Enter Faction Name",
                command    = ".lookup faction",
                tooltip    = L["lookup_faction_desc"]
            },
            {
                text       = L["lookup item"],
                defaultEB  = "Enter Item Name",
                command    = ".lookup item",
                tooltip    = L["lookup_item_desc"]
            },
            {
                text       = L["lookup item set"],
                defaultEB  = "Enter ItemSet Name",
                command    = ".lookup item set",
                tooltip    = L["lookup_item_set_desc"]
            },
            {
                text       = L["lookup map"],
                defaultEB  = "Enter Map Name Part",
                command    = ".lookup map",
                tooltip    = L["lookup_map_desc"]
            },
            {
                text       = L["lookup object"],
                defaultEB  = "Enter Object Name",
                command    = ".lookup object",
                tooltip    = L["lookup_object_dec"]
            },
            {
                text       = L["lookup quest"],
                defaultEB  = "Enter Quest Name Part",
                command    = ".lookup quest",
                tooltip    = L["lookup_quest_desc"]
            },
            {
                text       = L["lookup skill"],
                defaultEB  = "Enter Skill Name Part",
                command    = ".lookup skill",
                tooltip    = L["lookup_skill_desc"]
            },
            {
                text       = L["lookup spell"],
                defaultEB  = "Enter Spell Name Part",
                command    = ".lookup spell",
                tooltip    = L["lookup_spell_desc"]
            },
            {
                text       = L["lookup spell id"],
                defaultEB  = "Enter Spell ID",
                command    = ".lookup spell id",
                tooltip    = L["lookup_spell_id_desc"]
            },
            {
                text       = L["lookup taxinode"],
                defaultEB  = "Enter Taxinode Substring",
                command    = ".lookup taxinode",
                tooltip    = L["lookup_taxinode_desc"]
            },
            {
                text       = L["lookup tele"],
                defaultEB  = "Enter Teleport Substring",
                command    = ".lookup tele",
                tooltip    = L["lookup_tele_desc"]
            },
            {
                text       = L["lookup title"],
                defaultEB  = "Enter Title Name Part",
                command    = ".lookup title",
                tooltip    = L["lookup_title_desc"]
            },
        }

        -------------------------------------------------------------------------
        -- 2) OPTIONS pour le second menu déroulant (2 champs + bouton)
        -------------------------------------------------------------------------
        local doubleOptions = {
            {
                text            = L["lookup player ip"],
                defaultEB1      = "Enter IP",
                defaultEB2      = "Limit",
                command         = ".lookup player ip",
                tooltip         = L["lookup_player_ip_desc"]
            },
            {
                text            = L["lookup player email"],
                defaultEB1      = "Enter Email",
                defaultEB2      = "Limit",
                command         = ".lookup player email",
                tooltip         = L["lookup_player_email_desc"]
            },
            {
                text            = L["lookup player account"],
                defaultEB1      = "Enter a Username",
                defaultEB2      = "Limit",
                command         = ".lookup player account",
                tooltip         = L["lookup_player_account_desc"]
            },
        }

        -------------------------------------------------------------------------
        -- Placement
        -------------------------------------------------------------------------
        local yOffset = -10
        local xOffset = 0

        -- Crée un conteneur pour le 1er bloc (un champ, un menu, un bouton)
        local block1 = CreateFrame("Frame", nil, self.lookupPanel)
        block1:SetSize(600, 50)
        block1:SetPoint("TOPLEFT", self.lookupPanel, "TOPLEFT", 10, -50)

        -------------------------------------------------------------------------
        -- 1er bloc : un champ + un menu dropdown + un bouton "Lookup"
        -------------------------------------------------------------------------
        -- EditBox
        local editSingle = CreateFrame("EditBox", nil, block1, "InputBoxTemplate")
        editSingle:SetSize(200, 22)
        editSingle:SetPoint("TOPLEFT", block1, "TOPLEFT", 0, 0)
        editSingle:SetAutoFocus(false)
        
        -- Dropdown
        local singleDropdown = CreateFrame("Frame", "TrinityAdminSingleDropdown", block1, "UIDropDownMenuTemplate")
        singleDropdown:SetPoint("LEFT", editSingle, "RIGHT", 10, 0)
        UIDropDownMenu_SetWidth(singleDropdown, 160)
        UIDropDownMenu_SetText(singleDropdown, singleOptions[1].text)  -- par défaut
        
        -- On stocke l'option sélectionnée
        singleDropdown.selectedOption = singleOptions[1]
        -- On applique directement la valeur par défaut
        editSingle:SetText(singleDropdown.selectedOption.defaultEB)

        -- Bouton "Lookup"
        local btnSingleLookup = CreateFrame("Button", nil, block1, "UIPanelButtonTemplate")
        btnSingleLookup:SetText(L["Lookup"])
        btnSingleLookup:SetSize(btnSingleLookup:GetTextWidth() + 20, 22)
        btnSingleLookup:SetPoint("LEFT", singleDropdown, "RIGHT", 10, 0)

        -- Fonction pour changer dynamiquement le placeholder et le tooltip
        local function SingleDropdown_OnClick(option)
            singleDropdown.selectedOption = option
            UIDropDownMenu_SetSelectedName(singleDropdown, option.text)
            UIDropDownMenu_SetText(singleDropdown, option.text)
            -- Met à jour le champ EditBox
            editSingle:SetText(option.defaultEB)
        end

        UIDropDownMenu_Initialize(singleDropdown, function(frame, level, menuList)
            for i, opt in ipairs(singleOptions) do
                local info = UIDropDownMenu_CreateInfo()
                info.text    = opt.text
                info.value   = i
                info.func    = function() SingleDropdown_OnClick(opt) end
                info.checked = (opt == singleDropdown.selectedOption)
                UIDropDownMenu_AddButton(info, level)
            end
        end)

        -- Script "OnEnter" du bouton => tooltip dynamique
        btnSingleLookup:SetScript("OnEnter", function(self)
            local opt = singleDropdown.selectedOption
            if not opt then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(opt.tooltip, 1,1,1,1,true)
        end)
        btnSingleLookup:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- OnClick => exécute la commande .lookup ...
		btnSingleLookup:SetScript("OnClick", function()
			local opt = singleDropdown.selectedOption
			if not opt then return end
		
			local textValue = editSingle:GetText()
			if not textValue or textValue == "" or textValue == opt.defaultEB then
				print(L["Please provide a value for:"] .. " " .. opt.text)
				return
			end
		
			-- On démarre la capture
			StartLookupCapture()
		
			-- On envoie la commande
			local cmd = opt.command .. " " .. textValue
			SendChatMessage(cmd, "SAY")
		
			-- On reset le champ
			editSingle:SetText(opt.defaultEB)
		end)

        -------------------------------------------------------------------------
        -- 2ème bloc : deux champs + un menu + un bouton Lookup
        -------------------------------------------------------------------------
        local block2 = CreateFrame("Frame", nil, self.lookupPanel)
        block2:SetSize(600, 50)
        block2:SetPoint("TOPLEFT", block1, "BOTTOMLEFT", 0, -20)

        -- EditBox 1
        local editFirst = CreateFrame("EditBox", nil, block2, "InputBoxTemplate")
        editFirst:SetSize(120, 22)
        editFirst:SetPoint("TOPLEFT", block2, "TOPLEFT", 0, 0)
        editFirst:SetAutoFocus(false)

        -- EditBox 2
        local editSecond = CreateFrame("EditBox", nil, block2, "InputBoxTemplate")
        editSecond:SetSize(60, 22)
        editSecond:SetPoint("LEFT", editFirst, "RIGHT", 10, 0)
        editSecond:SetAutoFocus(false)

        -- Dropdown
        local doubleDropdown = CreateFrame("Frame", "TrinityAdminDoubleDropdown", block2, "UIDropDownMenuTemplate")
        doubleDropdown:SetPoint("LEFT", editSecond, "RIGHT", 10, 0)
        UIDropDownMenu_SetWidth(doubleDropdown, 180)
        UIDropDownMenu_SetText(doubleDropdown, doubleOptions[1].text)
        
        doubleDropdown.selectedOption = doubleOptions[1]
        -- Applique la valeur par défaut
        editFirst:SetText(doubleDropdown.selectedOption.defaultEB1)
        editSecond:SetText(doubleDropdown.selectedOption.defaultEB2)

        -- Bouton "Lookup"
        local btnDoubleLookup = CreateFrame("Button", nil, block2, "UIPanelButtonTemplate")
        btnDoubleLookup:SetText(L["Lookup"])
        btnDoubleLookup:SetSize(btnDoubleLookup:GetTextWidth() + 20, 22)
        btnDoubleLookup:SetPoint("LEFT", doubleDropdown, "RIGHT", 10, 0)

        -- Fonctions de selection
        local function DoubleDropdown_OnClick(option)
            doubleDropdown.selectedOption = option
            UIDropDownMenu_SetSelectedName(doubleDropdown, option.text)
            UIDropDownMenu_SetText(doubleDropdown, option.text)
            -- Met à jour les 2 champs
            editFirst:SetText(option.defaultEB1)
            editSecond:SetText(option.defaultEB2)
        end

        UIDropDownMenu_Initialize(doubleDropdown, function(frame, level, menuList)
            for i, opt in ipairs(doubleOptions) do
                local info = UIDropDownMenu_CreateInfo()
                info.text    = opt.text
                info.value   = i
                info.func    = function() DoubleDropdown_OnClick(opt) end
                info.checked = (opt == doubleDropdown.selectedOption)
                UIDropDownMenu_AddButton(info, level)
            end
        end)

        -- Tooltip dynamique du bouton
        btnDoubleLookup:SetScript("OnEnter", function(self)
            local opt = doubleDropdown.selectedOption
            if not opt then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(opt.tooltip, 1,1,1,1,true)
        end)
        btnDoubleLookup:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

		-- OnClick => exécute la commande
		btnDoubleLookup:SetScript("OnClick", function()
			local opt = doubleDropdown.selectedOption
			if not opt then return end
			
			local val1 = editFirst:GetText()
			local val2 = editSecond:GetText()
			if not val1 or val1 == "" or val1 == opt.defaultEB1 then
				print(L["Please provide a value for:"] .. " " .. opt.defaultEB1)
				return
			end
			if not val2 or val2 == "" or val2 == opt.defaultEB2 then
				print(L["Please provide a value for:"] .. " " .. opt.defaultEB2)
				return
			end
		
			-- 1) Démarrer la capture avant d'envoyer la commande
			StartLookupCapture()
		
			-- 2) Envoyer la commande
			local cmd = opt.command .. " " .. val1 .. " " .. val2
			SendChatMessage(cmd, "SAY")
		
			-- 3) Reset des champs
			editFirst:SetText(opt.defaultEB1)
			editSecond:SetText(opt.defaultEB2)
		end)

        -------------------------------------------------------------------------
        -- Bouton Retour
        -------------------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.lookupPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.lookupPanel, "BOTTOM", 0, 10)
        btnBack:SetText(L["Back"])
        btnBack:SetSize(btnBack:GetTextWidth() + 20, 22)
        btnBack:SetScript("OnClick", function()
            self.lookupPanel:Hide()
            self.panel:Show()
        end)
    end

    TrinityAdmin:HideMainMenu()
    self.lookupPanel:Show()
end


-- Ouvre le panneau Groups Management en masquant le panneau principal
function Misc:OpenGroupsManagement()
    if self.panel then
        self.panel:Hide()
    end
    if not self.groupsPanel then
        -- Crée le panneau principal
        self.groupsPanel = CreateFrame("Frame", "TrinityAdminGroupsPanel", TrinityAdminMainFrame)
        self.groupsPanel:SetPoint("TOPLEFT",  TrinityAdminMainFrame, "TOPLEFT",     10, -50)
        self.groupsPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.groupsPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.groupsPanel)
        bg:SetColorTexture(0.6, 0.4, 0.2, 0.7)  -- Couleur pour le panneau Groups Management
        
        self.groupsPanel.title = self.groupsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.groupsPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.groupsPanel.title:SetText(L["Groups Management"])

        -------------------------------------------------------------------------
        -- Fonction utilitaire : obtenir le nom du champ ou la cible
        -- Si 'textValue' est vide ou égal au texte par défaut => on prend le joueur ciblé
        -- Sinon, si on n'a pas de cible => on met "$playername"
        -------------------------------------------------------------------------
        local function GetNameOrTarget(textValue, defaultText)
            if textValue and textValue ~= "" and textValue ~= defaultText then
                return textValue
            end
            local target = UnitName("target")
            if target then
                return target
            end
            return "$playername"
        end

        -------------------------------------------------------------------------
        -- Conteneur principal
        -------------------------------------------------------------------------
        local container = CreateFrame("Frame", nil, self.groupsPanel)
        container:SetPoint("TOPLEFT", self.groupsPanel, "TOPLEFT", 10, -40)
        container:SetSize(self.groupsPanel:GetWidth() - 20, self.groupsPanel:GetHeight() - 80)

        local yOffset = 0

        -------------------------------------------------------------------------
        -- (1) BLOCK : Two EditBoxes + "Join" Button
        -------------------------------------------------------------------------
        do
            -- 1) "Player Name From Group"
            local editFrom = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editFrom:SetSize(140, 22)
            editFrom:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editFrom:SetAutoFocus(false)
            editFrom:SetText("Player Name From Group")

            -- 2) "Player Name to Add"
            local editTo = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editTo:SetSize(140, 22)
            editTo:SetPoint("LEFT", editFrom, "RIGHT", 10, 0)
            editTo:SetAutoFocus(false)
            editTo:SetText("Player Name to Add")

            -- 3) "Join" button
            local btnJoin = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnJoin:SetText(L["Join"])
            btnJoin:SetSize(btnJoin:GetTextWidth() + 20, 22)
            btnJoin:SetPoint("LEFT", editTo, "RIGHT", 10, 0)

            -- Tooltip
            btnJoin:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Join_group_desc"], 1,1,1,1,true)
            end)
            btnJoin:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- OnClick => envoie la commande
            btnJoin:SetScript("OnClick", function()
                local fromValue = editFrom:GetText()
                local toValue   = editTo:GetText()

                -- 'fromValue' doit être non vide
                if (not fromValue or fromValue == "" or fromValue == "Player Name From Group") then
                    print(L["Please provide a valid valuer for 'Player Name From Group'."])
                    return
                end

                -- 'toValue' peut être vide => on prend la cible
                -- ou "$playername" si pas de cible
                local finalTo   = GetNameOrTarget(toValue, "Player Name to Add")

                local cmd = ".group join " .. fromValue .. " " .. finalTo
                SendChatMessage(cmd, "SAY")

                -- Reset
                editFrom:SetText("Player Name From Group")
                editTo:SetText("Player Name to Add")
            end)

            yOffset = yOffset - 40
        end

        -------------------------------------------------------------------------
        -- (2) BLOCK : Un champ + menu déroulant + bouton "Execute"
        -------------------------------------------------------------------------
        local groupOptions = {
            {
                text        = L["group leader"],
                command     = ".group leader",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_leader_desc"]
            },
            {
                text        = L["group level"],
                command     = ".group level",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_level_desc"]
            },
            {
                text        = L["group list"],
                command     = ".group list",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_list_desc"]
            },
            {
                text        = L["group repair"],
                command     = ".group repair",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_repair_desc"]
            },
            {
                text        = L["group revive"],
                command     = ".group revive",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_revive_desc"]
            },
            {
                text        = L["group set assistant"],
                command     = ".group set assistant",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_set_assistant_desc"]
            },
            {
                text        = L["group set leader"],
                command     = ".group set leader",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_set_leader_desc"]
            },
            {
                text        = L["group set mainassist"],
                command     = ".group set mainassist",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_set_mainassist_desc"]
            },
            {
                text        = L["group set maintank"],
                command     = ".group set maintank",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_set_maintank_desc"]
            },
            {
                text        = L["group summon"],
                command     = ".group summon",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_summon_desc"]
            },
            {
                text        = L["group remove"],
                command     = ".group remove",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_remove_desc"]
            },
            {
                text        = L["group disband"],
                command     = ".group disband",
                defaultEB   = "Enter Player Name",
                tooltip     = L["group_disband_desc"]
            },
        }

        do
            local block2 = CreateFrame("Frame", nil, container)
            block2:SetSize(600, 50)
            block2:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

            -- EditBox
            local editName = CreateFrame("EditBox", nil, block2, "InputBoxTemplate")
            editName:SetSize(140, 22)
            editName:SetPoint("TOPLEFT", block2, "TOPLEFT", 0, 0)
            editName:SetAutoFocus(false)

            -- Dropdown
            local dropdown = CreateFrame("Frame", "TrinityAdminGroupsDropdown", block2, "UIDropDownMenuTemplate")
            dropdown:SetPoint("LEFT", editName, "RIGHT", 10, 0)
            UIDropDownMenu_SetWidth(dropdown, 200)
            
            -- Par défaut
            dropdown.selectedOption = groupOptions[1]
            UIDropDownMenu_SetText(dropdown, groupOptions[1].text)
            editName:SetText(dropdown.selectedOption.defaultEB)

            local btnExecute = CreateFrame("Button", nil, block2, "UIPanelButtonTemplate")
            btnExecute:SetText(L["Execute"])
            btnExecute:SetSize(btnExecute:GetTextWidth() + 20, 22)
            btnExecute:SetPoint("LEFT", dropdown, "RIGHT", 10, 0)

            -- Fonction OnClick pour l'option du menu
            local function Dropdown_OnClick(opt)
                dropdown.selectedOption = opt
                UIDropDownMenu_SetSelectedName(dropdown, opt.text)
                UIDropDownMenu_SetText(dropdown, opt.text)
                -- Mettre à jour le champ
                editName:SetText(opt.defaultEB)
            end

            UIDropDownMenu_Initialize(dropdown, function(frame, level, menuList)
                for i, opt in ipairs(groupOptions) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text    = opt.text
                    info.value   = i
                    info.func    = function() Dropdown_OnClick(opt) end
                    info.checked = (opt == dropdown.selectedOption)
                    UIDropDownMenu_AddButton(info, level)
                end
            end)

            -- Tooltip dynamique du bouton "Execute"
            btnExecute:SetScript("OnEnter", function(self)
                local opt = dropdown.selectedOption
                if not opt then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(opt.tooltip, 1,1,1,1,true)
            end)
            btnExecute:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- OnClick => envoie la commande
            btnExecute:SetScript("OnClick", function()
                local opt = dropdown.selectedOption
                if not opt then return end

                local textValue = editName:GetText()
                if not textValue or textValue == "" or textValue == opt.defaultEB then
                    -- On prend la cible du GM ou "$playername"
                    local target = UnitName("target")
                    if target then
                        textValue = target
                    else
                        textValue = "$playername"
                    end
                end

                local cmd = opt.command .. " " .. textValue
                SendChatMessage(cmd, "SAY")

                -- Reset
                editName:SetText(opt.defaultEB)
            end)

            yOffset = yOffset - 60
        end

        -------------------------------------------------------------------------
        -- Bouton Retour commun
        -------------------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.groupsPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.groupsPanel, "BOTTOM", 0, 10)
        btnBack:SetText(L["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
        btnBack:SetScript("OnClick", function()
            self.groupsPanel:Hide()
            self.panel:Show()
        end)
    end

    TrinityAdmin:HideMainMenu()
    self.groupsPanel:Show()
end

-- Ouvre le panneau Quests Management en masquant le panneau principal
function Misc:OpenQuestsManagement()
    if self.panel then
        self.panel:Hide()
    end
    if not self.questsPanel then
        -- Crée le panneau principal
        self.questsPanel = CreateFrame("Frame", "TrinityAdminQuestsPanel", TrinityAdminMainFrame)
        self.questsPanel:SetPoint("TOPLEFT",  TrinityAdminMainFrame, "TOPLEFT",     10, -50)
        self.questsPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.questsPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.questsPanel)
        bg:SetColorTexture(0.2, 0.2, 0.2, 0.7)  -- Couleur pour le panneau Quests Management
        
        self.questsPanel.title = self.questsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.questsPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.questsPanel.title:SetText(L["Quests Management"])

        ------------------------------------------------------------
        -- Fonction utilitaire pour réinitialiser une EditBox
        ------------------------------------------------------------
        local function ResetEditBox(editBox, defaultText)
            editBox:SetText(defaultText)
        end

        ------------------------------------------------------------
        -- Conteneur pour organiser tous les éléments
        ------------------------------------------------------------
        local container = CreateFrame("Frame", nil, self.questsPanel)
        container:SetPoint("TOPLEFT", self.questsPanel, "TOPLEFT", 10, -40)
        container:SetSize(self.questsPanel:GetWidth() - 20, self.questsPanel:GetHeight() - 80)

        ------------------------------------------------------------
        -- Offset vertical pour aligner les blocs
        ------------------------------------------------------------
        local yOffset = 0

        ------------------------------------------------------------
        -- 1) Add Quest
        ------------------------------------------------------------
        do
            local editQuestID = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editQuestID:SetSize(100, 22)
            editQuestID:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editQuestID:SetText("Quest ID")
            editQuestID:SetAutoFocus(false)

            local btnAdd = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnAdd:SetText(L["Add Quest"])
            btnAdd:SetSize(btnAdd:GetTextWidth() + 20, 22)
            btnAdd:SetPoint("LEFT", editQuestID, "RIGHT", 10, 0)

            btnAdd:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Add_quest_desc"], 1,1,1,1,true)
            end)
            btnAdd:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btnAdd:SetScript("OnClick", function()
                local questID = editQuestID:GetText()
                if not questID or questID == "" or questID == "Quest ID" then
                    print(L["Please provide a valid Quest ID."])
                    return
                end

                local cmd = ".quest add " .. questID
                SendChatMessage(cmd, "SAY")

                -- Reset
                ResetEditBox(editQuestID, "Quest ID")
            end)

            yOffset = yOffset - 40
        end

        ------------------------------------------------------------
        -- 2) Complete Quest
        ------------------------------------------------------------
        do
            local editQuestID = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editQuestID:SetSize(100, 22)
            editQuestID:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editQuestID:SetText("Quest ID")
            editQuestID:SetAutoFocus(false)

            local btnComplete = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnComplete:SetText(L["Complete Quest"])
            btnComplete:SetSize(btnComplete:GetTextWidth() + 20, 22)
            btnComplete:SetPoint("LEFT", editQuestID, "RIGHT", 10, 0)

            btnComplete:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Complete_Quest_desc"], 1,1,1,1,true)
            end)
            btnComplete:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btnComplete:SetScript("OnClick", function()
                local questID = editQuestID:GetText()
                if not questID or questID == "" or questID == "Quest ID" then
                    print(L["Please provide a valid Quest ID."])
                    return
                end

                local cmd = ".quest complete " .. questID
                SendChatMessage(cmd, "SAY")

                -- Reset
                ResetEditBox(editQuestID, "Quest ID")
            end)

            yOffset = yOffset - 40
        end

        ------------------------------------------------------------
        -- 3) Complete Quest Objective
        ------------------------------------------------------------
        do
            local editObjID = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editObjID:SetSize(130, 22)
            editObjID:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editObjID:SetText("Quest Objective ID")
            editObjID:SetAutoFocus(false)

            local btnObjective = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnObjective:SetText(L["Complete Quest Objective"])
            btnObjective:SetSize(btnObjective:GetTextWidth() + 20, 22)
            btnObjective:SetPoint("LEFT", editObjID, "RIGHT", 10, 0)

            btnObjective:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Complete_Quest_Objective_desc"], 1,1,1,1,true)
            end)
            btnObjective:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btnObjective:SetScript("OnClick", function()
                local objID = editObjID:GetText()
                if not objID or objID == "" or objID == "Quest Objective ID" then
                    print(L["Please provide a valid Quest Objective ID."])
                    return
                end

                local cmd = ".quest objective complete " .. objID
                SendChatMessage(cmd, "SAY")

                -- Reset
                ResetEditBox(editObjID, "Quest Objective ID")
            end)

            yOffset = yOffset - 40
        end

        ------------------------------------------------------------
        -- 4) Remove Quest
        ------------------------------------------------------------
        do
            local editQuestID = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editQuestID:SetSize(100, 22)
            editQuestID:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editQuestID:SetText("Quest ID")
            editQuestID:SetAutoFocus(false)

            local btnRemove = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnRemove:SetText(L["Remove Quest"])
            btnRemove:SetSize(btnRemove:GetTextWidth() + 20, 22)
            btnRemove:SetPoint("LEFT", editQuestID, "RIGHT", 10, 0)

            btnRemove:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Remove_Quest_desc"], 1,1,1,1,true)
            end)
            btnRemove:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btnRemove:SetScript("OnClick", function()
                local questID = editQuestID:GetText()
                if not questID or questID == "" or questID == "Quest ID" then
                    print(L["Please provide a valid Quest ID."])
                    return
                end

                local cmd = ".quest remove " .. questID
                SendChatMessage(cmd, "SAY")

                -- Reset
                ResetEditBox(editQuestID, "Quest ID")
            end)

            yOffset = yOffset - 40
        end

        ------------------------------------------------------------
        -- 5) Reward Quest
        ------------------------------------------------------------
        do
            local editQuestID = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editQuestID:SetSize(100, 22)
            editQuestID:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
            editQuestID:SetText("Quest ID")
            editQuestID:SetAutoFocus(false)

            local btnReward = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnReward:SetText(L["Reward Quest"])
            btnReward:SetSize(btnReward:GetTextWidth() + 20, 22)
            btnReward:SetPoint("LEFT", editQuestID, "RIGHT", 10, 0)

            btnReward:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Reward_Quest_desc"], 1,1,1,1,true)
            end)
            btnReward:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btnReward:SetScript("OnClick", function()
                local questID = editQuestID:GetText()
                if not questID or questID == "" or questID == "Quest ID" then
                    print(L["Please provide a valid Quest ID."])
                    return
                end

                local cmd = ".quest reward " .. questID
                SendChatMessage(cmd, "SAY")

                -- Reset
                ResetEditBox(editQuestID, "Quest ID")
            end)

            yOffset = yOffset - 40
        end
        
        ------------------------------------------------------------
        -- Bouton Retour
        ------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.questsPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.questsPanel, "BOTTOM", 0, 10)
        btnBack:SetText(L["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
        btnBack:SetScript("OnClick", function()
            self.questsPanel:Hide()
            self.panel:Show()
        end)
    end
    TrinityAdmin:HideMainMenu()
    self.questsPanel:Show()
end


-- Ouvre le panneau BattlefieldAndPvpManagement en masquant le panneau principal
function Misc:OpenBattlefieldAndPvpManagement()
    if self.panel then
        self.panel:Hide()
    end
    if not self.BattlefieldAndPvpPanel then
        self.BattlefieldAndPvpPanel = CreateFrame("Frame", "TrinityAdminBattlefieldAndPvpPanel", TrinityAdminMainFrame)
        self.BattlefieldAndPvpPanel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
        self.BattlefieldAndPvpPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.BattlefieldAndPvpPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.BattlefieldAndPvpPanel)
        bg:SetColorTexture(0.6, 0.4, 0.2, 0.7)
        
        self.BattlefieldAndPvpPanel.title = self.BattlefieldAndPvpPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.BattlefieldAndPvpPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.BattlefieldAndPvpPanel.title:SetText(L["Battlefield / PvP Management"])

        ----------------------------------------------------------------------------
        -- Fonction utilitaire : obtenir le nom du champ ou la cible GM
        ----------------------------------------------------------------------------
        local function GetNameOrTarget(value, defaultText)
            if value and value ~= "" and value ~= defaultText then
                return value
            end
            local target = UnitName("target")
            if target then
                return target
            end
            return nil  -- signifier qu'on n'a pas de cible du tout
        end

        ----------------------------------------------------------------------------
        -- Conteneur global
        ----------------------------------------------------------------------------
        local container = CreateFrame("Frame", nil, self.BattlefieldAndPvpPanel)
        container:SetPoint("TOPLEFT", self.BattlefieldAndPvpPanel, "TOPLEFT", 10, -40)
        container:SetSize(
            self.BattlefieldAndPvpPanel:GetWidth() - 20,
            self.BattlefieldAndPvpPanel:GetHeight() - 80
        )

        ----------------------------------------------------------------------------
        -- On crée deux "colonnes" : leftContainer et rightContainer
        ----------------------------------------------------------------------------
        local leftContainer = CreateFrame("Frame", nil, container)
        leftContainer:SetSize(container:GetWidth()/2 - 10, container:GetHeight())
        leftContainer:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)

        local rightContainer = CreateFrame("Frame", nil, container)
        rightContainer:SetSize(container:GetWidth()/2 - 10, container:GetHeight())
        rightContainer:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)

        -- Offsets indépendants
        local yLeft = 0
        local yRight = 0

        ----------------------------------------------------------------------------
        -- (1) Sous-titre : "Bg Deserter Management" (dans la colonne de gauche)
        ----------------------------------------------------------------------------
        do
            local title = leftContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            title:SetPoint("TOPLEFT", leftContainer, "TOPLEFT", 0, yLeft)
            title:SetText(L["Bg Deserter Management"])

            yLeft = yLeft - 20
        end

        ----------------------------------------------------------------------------
        -- (1) Un champ + un menu + un bouton "Set" (Deserter BG) - colonne gauche
        ----------------------------------------------------------------------------
        local deserterBgOptions = {
            {
                text      = L["deserter bg add"],
                cmd       = ".deserter bg add",
                defaultEB = "Time",
                tooltip   = L["deserter_bg_add_desc"],
                needValue = true,  -- champ obligatoire
            },
            {
                text      = L["deserter bg remove"],
                cmd       = ".deserter bg remove",
                defaultEB = "N/A",
                tooltip   = L["deserter_bg_remove_desc"],
                needValue = false, -- champ non utilisé
            },
        }

        do
            local block = CreateFrame("Frame", nil, leftContainer)
            block:SetSize(300, 40)
            block:SetPoint("TOPLEFT", leftContainer, "TOPLEFT", 0, yLeft)

            local editBox = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editBox:SetSize(100, 22)
            editBox:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
            editBox:SetAutoFocus(false)

            local dropdown = CreateFrame("Frame", nil, block, "UIDropDownMenuTemplate")
            dropdown:SetPoint("LEFT", editBox, "RIGHT", 5, 0)
            UIDropDownMenu_SetWidth(dropdown, 120)

            -- Par défaut
            dropdown.selectedOption = deserterBgOptions[1]
            UIDropDownMenu_SetText(dropdown, dropdown.selectedOption.text)
            editBox:SetText(dropdown.selectedOption.defaultEB)

            -- Bouton "Set"
            local btnSet = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnSet:SetText(L["Set"])
            btnSet:SetSize(btnSet:GetTextWidth() + 20, 22)
            btnSet:SetPoint("LEFT", dropdown, "RIGHT", 5, 0)

            -- Dropdown init
            local function OnClickOption(opt)
                dropdown.selectedOption = opt
                UIDropDownMenu_SetSelectedName(dropdown, opt.text)
                UIDropDownMenu_SetText(dropdown, opt.text)
                editBox:SetText(opt.defaultEB)
            end

            UIDropDownMenu_Initialize(dropdown, function(frame, level, menuList)
                for i, opt in ipairs(deserterBgOptions) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text    = opt.text
                    info.value   = i
                    info.func    = function() OnClickOption(opt) end
                    info.checked = (opt == dropdown.selectedOption)
                    UIDropDownMenu_AddButton(info, level)
                end
            end)

            -- Tooltip dynamique du bouton
            btnSet:SetScript("OnEnter", function(self)
                local opt = dropdown.selectedOption
                if not opt then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(opt.tooltip, 1,1,1,1,true)
            end)
            btnSet:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- OnClick => envoi de la commande
            btnSet:SetScript("OnClick", function()
                local opt = dropdown.selectedOption
                if not opt then return end

                local target = UnitName("target")
                if not target then
                    print(L["Error: Please target a character."])
                    return
                end

                if opt.needValue then
                    local val = editBox:GetText()
                    if not val or val == "" or val == opt.defaultEB then
						print(L["Please provide a value for:"] .. " " .. opt.text)
                        return
                    end
                    local cmd = opt.cmd .. " " .. val
                    SendChatMessage(cmd, "SAY")
					-- print("[DEBUG] Commande envoyée : " .. cmd)
                else
                    local cmd = opt.cmd
                    SendChatMessage(cmd, "SAY")
					-- print("[DEBUG] Commande envoyée : " .. cmd)
                end
            end)

            yLeft = yLeft - 50
        end

        ----------------------------------------------------------------------------
        -- (2) Sous-titre : "Instance Deserter Management" (colonne gauche)
        ----------------------------------------------------------------------------
        do
            local title = leftContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            title:SetPoint("TOPLEFT", leftContainer, "TOPLEFT", 0, yLeft)
            title:SetText(L["Instance Deserter Management"])

            yLeft = yLeft - 20
        end

        ----------------------------------------------------------------------------
        -- (2) Un champ + menu + bouton "Set" (Deserter Instance) - colonne gauche
        ----------------------------------------------------------------------------
        local deserterInstanceOptions = {
            {
                text      = L["deserter instance add"],
                cmd       = ".deserter instance add",
                defaultEB = "Time",
                tooltip   = L["deserter_instance_add_desc"],
                needValue = true,
            },
            {
                text      = L["deserter instance remove"],
                cmd       = ".deserter instance remove",
                defaultEB = "N/A",
                tooltip   = L["deserter_instance_remove_desc"],
                needValue = false,
            },
        }

        do
            local block = CreateFrame("Frame", nil, leftContainer)
            block:SetSize(300, 40)
            block:SetPoint("TOPLEFT", leftContainer, "TOPLEFT", 0, yLeft)

            local editBox = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editBox:SetSize(100, 22)
            editBox:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
            editBox:SetAutoFocus(false)

            local dropdown = CreateFrame("Frame", nil, block, "UIDropDownMenuTemplate")
            dropdown:SetPoint("LEFT", editBox, "RIGHT", 5, 0)
            UIDropDownMenu_SetWidth(dropdown, 120)

            dropdown.selectedOption = deserterInstanceOptions[1]
            UIDropDownMenu_SetText(dropdown, dropdown.selectedOption.text)
            editBox:SetText(dropdown.selectedOption.defaultEB)

            local btnSet = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnSet:SetText(L["Set"])
            btnSet:SetSize(btnSet:GetTextWidth() + 20, 22)
            btnSet:SetPoint("LEFT", dropdown, "RIGHT", 5, 0)

            local function OnClickOption(opt)
                dropdown.selectedOption = opt
                UIDropDownMenu_SetSelectedName(dropdown, opt.text)
                UIDropDownMenu_SetText(dropdown, opt.text)
                editBox:SetText(opt.defaultEB)
            end

            UIDropDownMenu_Initialize(dropdown, function(frame, level, menuList)
                for i, opt in ipairs(deserterInstanceOptions) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text    = opt.text
                    info.value   = i
                    info.func    = function() OnClickOption(opt) end
                    info.checked = (opt == dropdown.selectedOption)
                    UIDropDownMenu_AddButton(info, level)
                end
            end)

            btnSet:SetScript("OnEnter", function(self)
                local opt = dropdown.selectedOption
                if not opt then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(opt.tooltip, 1,1,1,1,true)
            end)
            btnSet:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnSet:SetScript("OnClick", function()
                local opt = dropdown.selectedOption
                if not opt then return end

                local target = UnitName("target")
                if not target then
                    print(L["Error: Please target a character."])
                    return
                end

                if opt.needValue then
                    local val = editBox:GetText()
                    if not val or val == "" or val == opt.defaultEB then
                        print(L["Please provide a value for:"] .. " " .. opt.text)
                        return
                    end
                    local cmd = opt.cmd .. " " .. val
                    SendChatMessage(cmd, "SAY")
                else
                    SendChatMessage(opt.cmd, "SAY")
                end
            end)

            yLeft = yLeft - 50
        end

        ----------------------------------------------------------------------------
        -- PVP MANAGEMENT : on le place en haut à droite
        ----------------------------------------------------------------------------

        do
            local title = rightContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            title:SetPoint("TOPLEFT", rightContainer, "TOPLEFT", 0, yRight)
            title:SetText("|cff00ff00" .. L["PvP Management"] .. "|r")
            yRight = yRight - 20
        end

        -- (A) Un champ "Enter Player Name" + bouton "Stop Combat"
        do
            local block = CreateFrame("Frame", nil, rightContainer)
            block:SetSize(300, 40)
            block:SetPoint("TOPLEFT", rightContainer, "TOPLEFT", 0, yRight)

            local editName = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editName:SetSize(140, 22)
            editName:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
            editName:SetAutoFocus(false)
            editName:SetText("Enter Player Name")

            local btnStopCombat = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnStopCombat:SetText(L["Stop Combat"])
            btnStopCombat:SetSize(btnStopCombat:GetTextWidth() + 20, 22)
            btnStopCombat:SetPoint("LEFT", editName, "RIGHT", 10, 0)

            btnStopCombat:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Stop Combat Tooltip"],
                    1,1,1,1,true
                )
            end)
            btnStopCombat:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnStopCombat:SetScript("OnClick", function()
                local val = editName:GetText()
                if val and val ~= "" and val ~= "Enter Player Name" then
                    SendChatMessage(".combatstop " .. val, "SAY")
                else
                    local target = UnitName("target")
                    if not target then
                        print(L["target_or_name_error"])
                        return
                    end
                    SendChatMessage(".combatstop " .. target, "SAY")
                end
                editName:SetText("Enter Player Name")
            end)

            yRight = yRight - 50
        end

        -- (B) Un champ "Amount" + bouton "Add Honor" + bouton "Add Honor Kill"
        do
            local block = CreateFrame("Frame", nil, rightContainer)
            block:SetSize(300, 40)
            block:SetPoint("TOPLEFT", rightContainer, "TOPLEFT", 0, yRight)

            local editAmount = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editAmount:SetSize(80, 22)
            editAmount:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
            editAmount:SetAutoFocus(false)
            editAmount:SetText("Amount")

            local btnAddHonor = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnAddHonor:SetText(L["Add Honor"])
            btnAddHonor:SetSize(btnAddHonor:GetTextWidth() + 20, 22)
            btnAddHonor:SetPoint("LEFT", editAmount, "RIGHT", 10, 0)

            btnAddHonor:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Add Honor tooltip"]",
                    1,1,1,1,true
                )
            end)
            btnAddHonor:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnAddHonor:SetScript("OnClick", function()
                local amountVal = editAmount:GetText()
                if not amountVal or amountVal == "" or amountVal == "Amount" then
                    print(L["honor_amount_error"])
                    return
                end
                -- Vérifier la cible
                local target = UnitName("target")
                if not target then
                    print(L["honor_target_error"])
                    return
                end

                SendChatMessage(".honor add " .. amountVal, "SAY")
                editAmount:SetText("Amount")
            end)

            local btnAddHonorKill = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnAddHonorKill:SetText(L["Add Honor Kill"])
            btnAddHonorKill:SetSize(btnAddHonorKill:GetTextWidth() + 20, 22)
            btnAddHonorKill:SetPoint("LEFT", btnAddHonor, "RIGHT", 20, 0)

            btnAddHonorKill:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Add Honor Kill tooltip"],
                    1,1,1,1,true
                )
            end)
            btnAddHonorKill:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnAddHonorKill:SetScript("OnClick", function()
                -- S'applique directement au GM
                SendChatMessage(".honor add kill", "SAY")
            end)

            yRight = yRight - 50
        end

        -- (C) Bouton "PvP Stats"
        do
            local block = CreateFrame("Frame", nil, rightContainer)
            block:SetSize(300, 40)
            block:SetPoint("TOPLEFT", rightContainer, "TOPLEFT", 0, yRight)

            local btnPvPStats = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnPvPStats:SetText(L["PvP Stats"])
            btnPvPStats:SetSize(btnPvPStats:GetTextWidth() + 20, 22)
            btnPvPStats:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)

            btnPvPStats:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["PvP Stats tooltip"], 1,1,1,1,true)
            end)
            btnPvPStats:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnPvPStats:SetScript("OnClick", function()
                SendChatMessage(".pvpstats", "SAY")
            end)

            yRight = yRight - 50
        end

        ----------------------------------------------------------------------------
        -- (4) Sous-titre "Battlefield Management" (toujours colonne gauche)
        ----------------------------------------------------------------------------
        do
            local titleBF = leftContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            titleBF:SetPoint("TOPLEFT", leftContainer, "TOPLEFT", 0, yLeft)
            titleBF:SetText("|cff00ff00" .. L["Battlefield Management"] .. "|r")

            yLeft = yLeft - 20
        end

        ----------------------------------------------------------------------------
        -- (4a) Premier menu (bf enable/start/stop/switch) + second menu (WinterGrasp/Tol Barad) + bouton "Set"
        --      (toujours colonne gauche)
        ----------------------------------------------------------------------------
        local bfOptions1 = {
            { text = "bf enable",  cmd = ".bf enable",  tooltip = "Syntax: .bf enable #battleid", },
            { text = "bf start",   cmd = ".bf start",   tooltip = "Syntax: .bf start #battleid", },
            { text = "bf stop",    cmd = ".bf stop",    tooltip = "Syntax: .bf stop #battleid", },
            { text = "bf switch",  cmd = ".bf switch",  tooltip = "Syntax: .bf switch #battleid", },
        }

        local bfOptions2 = {
            { text = "WinterGrasp", id = 1 },
            { text = "Tol Barad",   id = 2 },
        }

        do
            local block = CreateFrame("Frame", nil, leftContainer)
            block:SetSize(300, 40)
            block:SetPoint("TOPLEFT", leftContainer, "TOPLEFT", 0, yLeft)

            local dropdown1 = CreateFrame("Frame", nil, block, "UIDropDownMenuTemplate")
            dropdown1:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
            UIDropDownMenu_SetWidth(dropdown1, 80)

            local dropdown2 = CreateFrame("Frame", nil, block, "UIDropDownMenuTemplate")
            dropdown2:SetPoint("LEFT", dropdown1, "RIGHT", 10, 0)
            UIDropDownMenu_SetWidth(dropdown2, 80)

            dropdown1.selectedOption = bfOptions1[1]
            UIDropDownMenu_SetText(dropdown1, bfOptions1[1].text)

            dropdown2.selectedOption = bfOptions2[1]
            UIDropDownMenu_SetText(dropdown2, bfOptions2[1].text)

            local btnSet = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnSet:SetText(L["Set"])
            btnSet:SetSize(btnSet:GetTextWidth() + 20, 22)
            btnSet:SetPoint("LEFT", dropdown2, "RIGHT", 10, 0)

            local function OnClickOption1(opt)
                dropdown1.selectedOption = opt
                UIDropDownMenu_SetSelectedName(dropdown1, opt.text)
                UIDropDownMenu_SetText(dropdown1, opt.text)
            end
            UIDropDownMenu_Initialize(dropdown1, function(frame, level, menuList)
                for i, opt in ipairs(bfOptions1) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text    = opt.text
                    info.value   = i
                    info.func    = function() OnClickOption1(opt) end
                    info.checked = (opt == dropdown1.selectedOption)
                    UIDropDownMenu_AddButton(info, level)
                end
            end)

            local function OnClickOption2(opt)
                dropdown2.selectedOption = opt
                UIDropDownMenu_SetSelectedName(dropdown2, opt.text)
                UIDropDownMenu_SetText(dropdown2, opt.text)
            end
            UIDropDownMenu_Initialize(dropdown2, function(frame, level, menuList)
                for i, opt in ipairs(bfOptions2) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text    = opt.text
                    info.value   = i
                    info.func    = function() OnClickOption2(opt) end
                    info.checked = (opt == dropdown2.selectedOption)
                    UIDropDownMenu_AddButton(info, level)
                end
            end)

            btnSet:SetScript("OnEnter", function(self)
                if not dropdown1.selectedOption then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(dropdown1.selectedOption.tooltip, 1,1,1,1,true)
            end)
            btnSet:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnSet:SetScript("OnClick", function()
                local opt1 = dropdown1.selectedOption
                local opt2 = dropdown2.selectedOption
                if not opt1 or not opt2 then return end

                local battleid = opt2.id
                local cmd = opt1.cmd .. " " .. tostring(battleid)
                SendChatMessage(cmd, "SAY")
            end)

            yLeft = yLeft - 60
        end

        ----------------------------------------------------------------------------
        -- (4b) menu : "WinterGrasp/Tol Barad", champ "Timer", bouton "Set"
        ----------------------------------------------------------------------------
        local bfTimerOptions = {
            { text = "WinterGrasp", id = 1 },
            { text = "Tol Barad",   id = 2 },
        }

        do
            local block = CreateFrame("Frame", nil, leftContainer)
            block:SetSize(300, 40)
            block:SetPoint("TOPLEFT", leftContainer, "TOPLEFT", 0, yLeft)

            local dropdown3 = CreateFrame("Frame", nil, block, "UIDropDownMenuTemplate")
            dropdown3:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
            UIDropDownMenu_SetWidth(dropdown3, 80)

            dropdown3.selectedOption = bfTimerOptions[1]
            UIDropDownMenu_SetText(dropdown3, bfTimerOptions[1].text)

            local editTimer = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editTimer:SetSize(80, 22)
            editTimer:SetPoint("LEFT", dropdown3, "RIGHT", 10, 0)
            editTimer:SetAutoFocus(false)
            editTimer:SetText("Timer")

            local btnTimer = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnTimer:SetText(L["Set"])
            btnTimer:SetSize(btnTimer:GetTextWidth() + 20, 22)
            btnTimer:SetPoint("LEFT", editTimer, "RIGHT", 10, 0)

            local function OnClickOption3(opt)
                dropdown3.selectedOption = opt
                UIDropDownMenu_SetSelectedName(dropdown3, opt.text)
                UIDropDownMenu_SetText(dropdown3, opt.text)
            end
            UIDropDownMenu_Initialize(dropdown3, function(frame, level, menuList)
                for i, opt in ipairs(bfTimerOptions) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text    = opt.text
                    info.value   = i
                    info.func    = function() OnClickOption3(opt) end
                    info.checked = (opt == dropdown3.selectedOption)
                    UIDropDownMenu_AddButton(info, level)
                end
            end)

            btnTimer:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Syntax: .bf timer #battleid #timer", 1,1,1,1,true)
            end)
            btnTimer:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnTimer:SetScript("OnClick", function()
                local opt = dropdown3.selectedOption
                local val = editTimer:GetText()
                if not val or val == "" or val == "Timer" then
                    print("Veuillez saisir une valeur de timer.")
                    return
                end
                local battleid = opt.id
                local cmd = ".bf timer " .. tostring(battleid) .. " " .. val
                SendChatMessage(cmd, "SAY")

                editTimer:SetText("Timer")
            end)

            yLeft = yLeft - 50
        end

        ----------------------------------------------------------------------------
        -- Bouton Retour
        ----------------------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.BattlefieldAndPvpPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.BattlefieldAndPvpPanel, "BOTTOM", 0, 10)
        btnBack:SetText(L["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
        btnBack:SetScript("OnClick", function()
            self.BattlefieldAndPvpPanel:Hide()
            self.panel:Show()
        end)
    end
    TrinityAdmin:HideMainMenu()
    self.BattlefieldAndPvpPanel:Show()
end

function Misc:OpenDunjonsFuncManagement()
    if self.panel then
        self.panel:Hide()
    end
    if not self.DunjonsFuncPanel then
        self.DunjonsFuncPanel = CreateFrame("Frame", "TrinityAdminDunjonsFuncPanel", TrinityAdminMainFrame)
        self.DunjonsFuncPanel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
        self.DunjonsFuncPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.DunjonsFuncPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.DunjonsFuncPanel)
        bg:SetColorTexture(0.6, 0.4, 0.2, 0.7)  -- couleur de fond

        self.DunjonsFuncPanel.title = self.DunjonsFuncPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.DunjonsFuncPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.DunjonsFuncPanel.title:SetText(L["Dungeons Funcs"])

        -- Petit container pour tout disposer
        local container = CreateFrame("Frame", nil, self.DunjonsFuncPanel)
        container:SetPoint("TOPLEFT", self.DunjonsFuncPanel, "TOPLEFT", 10, -40)
        container:SetSize(
            self.DunjonsFuncPanel:GetWidth() - 20,
            self.DunjonsFuncPanel:GetHeight() - 80
        )

        local yOffset = 0  -- position verticale courante

        -- --------------------------------------------------------------------------------
        -- 1) Un champ "Enter MapID or all" + champ "Difficulty" + bouton "Unbind"
        -- --------------------------------------------------------------------------------
        do
            local block = CreateFrame("Frame", nil, container)
            block:SetSize(500, 40)
            block:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

            local editMapID = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editMapID:SetSize(120, 22)
            editMapID:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
            editMapID:SetAutoFocus(false)
            editMapID:SetText("Enter MapID or all")

            local editDifficulty = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editDifficulty:SetSize(80, 22)
            editDifficulty:SetPoint("LEFT", editMapID, "RIGHT", 10, 0)
            editDifficulty:SetAutoFocus(false)
            editDifficulty:SetText("Difficulty")

            local btnUnbind = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnUnbind:SetText(L["Unbind"])
            btnUnbind:SetSize(btnUnbind:GetTextWidth() + 20, 22)
            btnUnbind:SetPoint("LEFT", editDifficulty, "RIGHT", 10, 0)

            btnUnbind:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Unbind tooltip"], 1,1,1,1,true)
            end)
            btnUnbind:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnUnbind:SetScript("OnClick", function()
                -- On vérifie si on a une cible GM (obligatoire)
                local target = UnitName("target")
                if not target then
                    print(L["target_player_error"])
                    return
                end

                local valMapID = editMapID:GetText()
                if not valMapID or valMapID == "" or valMapID == "Enter MapID or all" then
                    print("Veuillez entrer un mapid ou 'all'.")
                    return
                end
                -- On peut vérifier que si ce n'est pas 'all', alors c'est un nombre ?
                if (valMapID ~= "all") and (not tonumber(valMapID)) then
                    print(L["invalid_mapid_error"])
                    return
                end

                local valDiff = editDifficulty:GetText()
                -- si c'est "Difficulty" ou "", on n'envoie pas
                local cmd = ".instance unbind " .. valMapID
                if valDiff and valDiff ~= "" and valDiff ~= "Difficulty" then
                    cmd = cmd .. " " .. valDiff
                end

                SendChatMessage(cmd, "SAY")
            end)

            yOffset = yOffset - 50
        end

        -- --------------------------------------------------------------------------------
        -- 2) Un bouton "List Binds"
        -- --------------------------------------------------------------------------------
        do
            local block = CreateFrame("Frame", nil, container)
            block:SetSize(300, 40)
            block:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

            local btnList = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnList:SetText(L["List Binds"])
            btnList:SetSize(btnList:GetTextWidth() + 20, 22)
            btnList:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)

            btnList:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["List Binds Tooltip"], 1,1,1,1,true)
            end)
            btnList:SetScript("OnLeave", function() GameTooltip:Hide() end)

			btnList:SetScript("OnClick", function()
				local target = UnitName("target")
				if not target then
					print(L["target_player_error"])
					return
				end
				-- On n'inclut pas son nom dans la commande, mais la commande s’applique à la cible
				SendChatMessage(".instance listbinds", "SAY")
			end)

            yOffset = yOffset - 50
        end

        -- --------------------------------------------------------------------------------
        -- 3) 2 champs ("Boss ID", "Player Name") + bouton "Get"
        -- --------------------------------------------------------------------------------
        do
            local block = CreateFrame("Frame", nil, container)
            block:SetSize(500, 40)
            block:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

            local editBossID = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editBossID:SetSize(80, 22)
            editBossID:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
            editBossID:SetAutoFocus(false)
            editBossID:SetText("Boss ID")

            local editPlayer = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editPlayer:SetSize(120, 22)
            editPlayer:SetPoint("LEFT", editBossID, "RIGHT", 10, 0)
            editPlayer:SetAutoFocus(false)
            editPlayer:SetText("Player Name")

            local btnGet = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnGet:SetText(L["Get"])
            btnGet:SetSize(btnGet:GetTextWidth() + 20, 22)
            btnGet:SetPoint("LEFT", editPlayer, "RIGHT", 10, 0)

            btnGet:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Get boss tooltip"], 1,1,1,1,true)
            end)
            btnGet:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnGet:SetScript("OnClick", function()
                local bossIdVal = editBossID:GetText()
                if not bossIdVal or bossIdVal == "" or bossIdVal == "Boss ID" then
                    print(L["enter_boss_id_error"])
                    return
                end

                local playerVal = editPlayer:GetText()
                local cmd = ".instance getbossstate " .. bossIdVal

                if playerVal and playerVal ~= "" and playerVal ~= "Player Name" then
                    cmd = cmd .. " " .. playerVal
                end

                SendChatMessage(cmd, "SAY")
            end)

            yOffset = yOffset - 50
        end

        -- --------------------------------------------------------------------------------
        -- 4) 3 champs ("Boss ID", "Encounter State", "Player Name") + bouton "Set"
        -- --------------------------------------------------------------------------------
        do
            local block = CreateFrame("Frame", nil, container)
            block:SetSize(600, 40)
            block:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

            local editBossID = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editBossID:SetSize(80, 22)
            editBossID:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
            editBossID:SetAutoFocus(false)
            editBossID:SetText("Boss ID")

            local editEncounter = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editEncounter:SetSize(120, 22)
            editEncounter:SetPoint("LEFT", editBossID, "RIGHT", 10, 0)
            editEncounter:SetAutoFocus(false)
            editEncounter:SetText(L["Encounter State"])

            local editPlayer = CreateFrame("EditBox", nil, block, "InputBoxTemplate")
            editPlayer:SetSize(120, 22)
            editPlayer:SetPoint("LEFT", editEncounter, "RIGHT", 10, 0)
            editPlayer:SetAutoFocus(false)
            editPlayer:SetText("Player Name")

            local btnSet = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnSet:SetText("Set")
            btnSet:SetSize(btnSet:GetTextWidth() + 20, 22)
            btnSet:SetPoint("LEFT", editPlayer, "RIGHT", 10, 0)

            btnSet:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Encounter State tooltip"], 1,1,1,1,true)
            end)
            btnSet:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnSet:SetScript("OnClick", function()
                local bossIdVal = editBossID:GetText()
                if not bossIdVal or bossIdVal == "" or bossIdVal == "Boss ID" then
                    print(L["enter_boss_id_error"])
                    return
                end

                local encVal = editEncounter:GetText()
                if not encVal or encVal == "" or encVal == "Encounter State" then
                    print(L["enter_encounter_state_error"])
                    return
                end

                local cmd = ".instance setbossstate " .. bossIdVal .. " " .. encVal
                local playerVal = editPlayer:GetText()
                if playerVal and playerVal ~= "" and playerVal ~= "Player Name" then
                    cmd = cmd .. " " .. playerVal
                end

                SendChatMessage(cmd, "SAY")
            end)

            yOffset = yOffset - 50
        end

        -- --------------------------------------------------------------------------------
        -- 5) Bouton "Show Instances Stats"
        -- --------------------------------------------------------------------------------
        do
            local block = CreateFrame("Frame", nil, container)
            block:SetSize(300, 40)
            block:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

            local btnStats = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnStats:SetText(L["Show Instances Stats"])
            btnStats:SetSize(btnStats:GetTextWidth() + 20, 22)
            btnStats:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)

            btnStats:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Show Instances Stats Tooltip"], 1,1,1,1,true)
            end)
            btnStats:SetScript("OnLeave", function() GameTooltip:Hide() end)

            btnStats:SetScript("OnClick", function()
                SendChatMessage(".instance stats", "SAY")
            end)

            yOffset = yOffset - 50
        end

        ----------------------------------------------------------------------------
        -- Bouton Retour (en bas)
        ----------------------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.DunjonsFuncPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.DunjonsFuncPanel, "BOTTOM", 0, 10)
        btnBack:SetText(L["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
        btnBack:SetScript("OnClick", function()
            self.DunjonsFuncPanel:Hide()
            self.panel:Show()
        end)
    end
    TrinityAdmin:HideMainMenu()
    self.DunjonsFuncPanel:Show()
end


------------------------------------------------------------
-- Fonction de traitement du texte si on veut séparer lignes
------------------------------------------------------------
local function ProcessLfgCapturedText(input)
    local text = (type(input) == "table") and table.concat(input, "\n") or input
    local processedLines = {}

        --    Roles: Dps, Leader"
    text = text
        :gsub(",%s*(Dungeons:)", "\n%1")
        :gsub(",%s*(Roles:)",    "\n%1")

    -- Maintenant on sépare chaque ligne par les retours à la ligne
    local processedLines = {}
    for line in text:gmatch("[^\r\n]+") do
        table.insert(processedLines, line)
    end
    return processedLines
end

------------------------------------------------------------
-- Variables globales (ou du module) pour la capture "LFG"
------------------------------------------------------------
local capturingLfg = false
local lfgInfoCollected = {}
local lfgInfoTimer = nil

------------------------------------------------------------
-- Frame pour écouter l'événement de chat (system ou say)
--  et capturer la sortie des commandes .lfg
------------------------------------------------------------
local lfgCaptureFrame = CreateFrame("Frame")
lfgCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")  -- On peut aussi écouter "CHAT_MSG_SAY" si nécessaire
lfgCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingLfg then return end

    -- Nettoyage minimal (suppression codes couleur, textures, etc.)
    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
                       :gsub("|r", "")
                       :gsub("|H.-|h(.-)|h", "%1")
                       :gsub("|T.-|t", "")
                       :gsub("\226[\148-\149][\128-\191]", "")

    table.insert(lfgInfoCollected, cleanMsg)

    -- Réinitialise / redémarre le timer (par ex. 1 seconde)
    if lfgInfoTimer then
        lfgInfoTimer:Cancel()
    end
    lfgInfoTimer = C_Timer.NewTimer(1, function()
        capturingLfg = false
        local fullText = table.concat(lfgInfoCollected, "\n")
        local lines = ProcessLfgCapturedText(fullText)
        ShowLfgAceGUI(lines)
    end)
end)

------------------------------------------------------------
-- Fenêtre AceGUI pour afficher le résultat
------------------------------------------------------------
local AceGUI = LibStub("AceGUI-3.0")
function ShowLfgAceGUI(lines)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["LFG Info"])
    frame:SetStatusText(L["Information from lfg command"])
    frame:SetLayout("Flow")
    frame:SetWidth(600)
    frame:SetHeight(500)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    frame:AddChild(scroll)

    for i, line in ipairs(lines) do
        local edit = AceGUI:Create("EditBox")
        edit:SetLabel(string.format("Line %d", i))
        edit:SetText(line)
        edit:SetFullWidth(true)
        scroll:AddChild(edit)
    end

    local btnClose = AceGUI:Create("Button")
    btnClose:SetText(L["Close"])
    btnClose:SetWidth(100)
    btnClose:SetCallback("OnClick", function() frame:Hide() end)
    frame:AddChild(btnClose)
end

------------------------------------------------------------
-- Pour lancer la capture avant d'envoyer la commande .lfg
------------------------------------------------------------
local function StartLfgCapture()
    wipe(lfgInfoCollected)
    capturingLfg = true
    if lfgInfoTimer then
        lfgInfoTimer:Cancel()
        lfgInfoTimer = nil
    end
end

------------------------------------------------------------
-- Ouvre le panneau LfgManage en masquant le panneau principal
------------------------------------------------------------
function Misc:OpenLfgManageManagement()
    if self.panel then
        self.panel:Hide()
    end

    if not self.LfgManagePanel then
        -- Crée le panneau principal
        self.LfgManagePanel = CreateFrame("Frame", "TrinityAdminLfgManagePanel", TrinityAdminMainFrame)
        self.LfgManagePanel:SetPoint("TOPLEFT",  TrinityAdminMainFrame, "TOPLEFT",     10, -50)
        self.LfgManagePanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.LfgManagePanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.LfgManagePanel)
        bg:SetColorTexture(0.6, 0.4, 0.2, 0.7)
        
        self.LfgManagePanel.title = self.LfgManagePanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.LfgManagePanel.title:SetPoint("TOPLEFT", 10, -10)
        self.LfgManagePanel.title:SetText(L["LFG Management"])
        
        ---------------------------------------------------------------------
        -- Conteneur pour disposer les éléments
        ---------------------------------------------------------------------
        local container = CreateFrame("Frame", nil, self.LfgManagePanel)
        container:SetPoint("TOPLEFT", self.LfgManagePanel, "TOPLEFT", 10, -40)
        container:SetSize(self.LfgManagePanel:GetWidth() - 20, self.LfgManagePanel:GetHeight() - 80)

        local xOffset = 0
        local yOffset = 0

        ---------------------------------------------------------------------
        -- Boutons "Lfg Clean", "Lfg Group", "Lfg Player", "Lfg Queue"
        ---------------------------------------------------------------------
        -- On va les placer sur une même ligne, par exemple
        local blockButtons = CreateFrame("Frame", nil, container)
        blockButtons:SetSize(600, 40)
        blockButtons:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

        -- 2) Lfg Group
        local btnGroup = CreateFrame("Button", nil, blockButtons, "UIPanelButtonTemplate")
        btnGroup:SetText(L["Lfg Group"])
        btnGroup:SetSize(btnGroup:GetTextWidth() + 20, 22)
        btnGroup:SetPoint("TOPLEFT", blockButtons, "TOPLEFT", 10, 0)

        btnGroup:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Lfg Group tooltip"], 1,1,1,1,true)
        end)
        btnGroup:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnGroup:SetScript("OnClick", function()
            StartLfgCapture()
            SendChatMessage(".lfg group", "SAY")
        end)

        -- 3) Lfg Player
        local btnPlayer = CreateFrame("Button", nil, blockButtons, "UIPanelButtonTemplate")
        btnPlayer:SetText(L["Lfg Player"])
        btnPlayer:SetSize(btnPlayer:GetTextWidth() + 20, 22)
        btnPlayer:SetPoint("LEFT", btnGroup, "RIGHT", 10, 0)

        btnPlayer:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Lfg Player Tooltip"], 1,1,1,1,true)
        end)
        btnPlayer:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnPlayer:SetScript("OnClick", function()
            StartLfgCapture()
            SendChatMessage(".lfg player", "SAY")
        end)

        -- 4) Lfg Queue
        local btnQueue = CreateFrame("Button", nil, blockButtons, "UIPanelButtonTemplate")
        btnQueue:SetText(L["Lfg Queue"])
        btnQueue:SetSize(btnQueue:GetTextWidth() + 20, 22)
        btnQueue:SetPoint("LEFT", btnPlayer, "RIGHT", 10, 0)

        btnQueue:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Lfg Queue tooltip"], 1,1,1,1,true)
        end)
        btnQueue:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnQueue:SetScript("OnClick", function()
            StartLfgCapture()
            SendChatMessage(".lfg queue", "SAY")
        end)

        yOffset = yOffset - 50

        ---------------------------------------------------------------------
        -- En dessous : un champ "New Value" + bouton "Set" => .lfg options ...
        ---------------------------------------------------------------------
        local blockOptions = CreateFrame("Frame", nil, container)
        blockOptions:SetSize(600, 40)
        blockOptions:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

        local editOptions = CreateFrame("EditBox", nil, blockOptions, "InputBoxTemplate")
        editOptions:SetSize(120, 22)
        editOptions:SetPoint("TOPLEFT", blockOptions, "TOPLEFT", 0, 0)
        editOptions:SetAutoFocus(false)
        editOptions:SetText("New Value")

        local btnSet = CreateFrame("Button", nil, blockOptions, "UIPanelButtonTemplate")
        btnSet:SetText(L["Show/Set Option"])
        btnSet:SetSize(btnSet:GetTextWidth() + 20, 22)
        btnSet:SetPoint("LEFT", editOptions, "RIGHT", 10, 0)

        btnSet:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["SowSet_Tooltip"], 1,1,1,1,true)
        end)
        btnSet:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btnSet:SetScript("OnClick", function()
            local val = editOptions:GetText()
            if not val or val == "" or val == "New Value" then
                -- On n'envoie pas la valeur
                SendChatMessage(".lfg options", "SAY")
            else
                SendChatMessage(".lfg options " .. val, "SAY")
            end
            editOptions:SetText("New Value")
        end)

        -- Bouton Retour
        local btnBack = CreateFrame("Button", nil, self.LfgManagePanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.LfgManagePanel, "BOTTOM", 0, 10)
        btnBack:SetText(L["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
        btnBack:SetScript("OnClick", function()
            self.LfgManagePanel:Hide()
            self.panel:Show()
        end)
    end

    TrinityAdmin:HideMainMenu()
    self.LfgManagePanel:Show()
end

-- Ouvre le panneau EventsManage en masquant le panneau principal
-----------------------------------------------------------
-- 1) Variables de capture pour .event [commandes]
-----------------------------------------------------------
local capturingEvents = false
local eventsInfoCollected = {}
local eventsInfoTimer = nil

-- Frame pour écouter les messages système (CHAT_MSG_SYSTEM)
local eventsCaptureFrame = CreateFrame("Frame")
eventsCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
eventsCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingEvents then return end

    -- Nettoyage minimal
    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
                       :gsub("|r", "")
                       :gsub("|H.-|h(.-)|h", "%1")
                       :gsub("|T.-|t", "")
                       :gsub("\226[\148-\149][\128-\191]", "")

    table.insert(eventsInfoCollected, cleanMsg)

    -- On redémarre un timer (1 seconde)
    if eventsInfoTimer then
        eventsInfoTimer:Cancel()
    end
    eventsInfoTimer = C_Timer.NewTimer(1, function()
        capturingEvents = false
        local fullText = table.concat(eventsInfoCollected, "\n")
        local lines = ProcessEventsCapturedText(fullText)
        ShowEventsAceGUI(lines)
    end)
end)

-----------------------------------------------------------
-- 2) Lance la capture avant d'envoyer la commande
-----------------------------------------------------------
local function StartEventsCapture()
    wipe(eventsInfoCollected)
    capturingEvents = true
    if eventsInfoTimer then
        eventsInfoTimer:Cancel()
        eventsInfoTimer = nil
    end
end

-----------------------------------------------------------
-- 3) Fonction de parsing (séparer en lignes)
-----------------------------------------------------------
function ProcessEventsCapturedText(input)
    local text = (type(input) == "table") and table.concat(input, "\n") or input
    local processedLines = {}
    for line in text:gmatch("[^\r\n]+") do
        table.insert(processedLines, line)
    end
    return processedLines
end

-----------------------------------------------------------
-- 4) Fenêtre AceGUI pour afficher le résultat
-----------------------------------------------------------
local AceGUI = LibStub("AceGUI-3.0")
function ShowEventsAceGUI(lines)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["Frame Events Info"])
    frame:SetStatusText(L["Infos_from_event"])
    frame:SetLayout("Flow")
    frame:SetWidth(600)
    frame:SetHeight(500)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    frame:AddChild(scroll)

    for i, line in ipairs(lines) do
        local edit = AceGUI:Create("EditBox")
        edit:SetLabel(L["Line "] .. i)
        edit:SetText(line)
        edit:SetFullWidth(true)
        scroll:AddChild(edit)
    end

    local btnClose = AceGUI:Create("Button")
    btnClose:SetText(L["Close"])
    btnClose:SetWidth(100)
    btnClose:SetCallback("OnClick", function() frame:Hide() end)
    frame:AddChild(btnClose)
end

----------------------------------------------------------------------------
-- 5) Création d'une "dropdown" défilante (scrollable) pour EventsData
----------------------------------------------------------------------------
local function CreateScrollableEventsDropdown(parent)
    -- Bouton principal (comme un dropdown)
    local mainButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    mainButton:SetSize(180, 22)
    mainButton:SetText(L["Drop Select Event"])  -- texte par défaut

    mainButton.selectedEventID = nil  -- contiendra l'ID sélectionné

    -- Frame qui contient la liste + scrollbar
    local menuFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    menuFrame:SetSize(220, 200)  -- Ajustez la taille à vos besoins
    menuFrame:SetPoint("TOPLEFT", mainButton, "BOTTOMLEFT", 0, -2)
    menuFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, edgeSize = 14, tileSize = 14,
    })
    menuFrame:SetBackdropColor(0, 0, 0, 0.8)
    menuFrame:Hide()  -- masqué par défaut

    -- ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", nil, menuFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", menuFrame, "BOTTOMRIGHT", -26, 5)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)  -- sera ajusté
    scrollFrame:SetScrollChild(scrollChild)

    local ITEM_HEIGHT = 20
    local spacing = 2
    local currentY = 0

    if not EventsData or #EventsData == 0 then
        -- Si aucun event
        local noItem = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noItem:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
        noItem:SetText(L["No EventsData found."])
        currentY = ITEM_HEIGHT
    else
        for i, data in ipairs(EventsData) do
            local eventName = data.name
            local eventID   = data.eventEntry

            local itemBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
            itemBtn:SetSize(180, ITEM_HEIGHT)
            itemBtn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -currentY)
            itemBtn:SetText(eventName)

            itemBtn:SetScript("OnClick", function()
                mainButton:SetText(eventName)
                mainButton.selectedEventID = eventID
                menuFrame:Hide()
            end)

            currentY = currentY + ITEM_HEIGHT + spacing
        end
    end

    -- Ajuster la hauteur en fonction du nombre d'items
    scrollChild:SetHeight(currentY)

    -- Toggle
    mainButton:SetScript("OnClick", function()
        if menuFrame:IsShown() then
            menuFrame:Hide()
        else
            menuFrame:Show()
        end
    end)

    return mainButton
end

----------------------------------------------------------------------------
-- 6) Panneau principal : Events Manager
----------------------------------------------------------------------------
function Misc:OpenEventsManageManagement()
    if self.panel then
        self.panel:Hide()
    end
    if not self.EventsManagePanel then
        self.EventsManagePanel = CreateFrame("Frame", "TrinityAdminEventsManagePanel", TrinityAdminMainFrame)
        self.EventsManagePanel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
        self.EventsManagePanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.EventsManagePanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.EventsManagePanel)
        bg:SetColorTexture(0.6, 0.4, 0.2, 0.7)
        
        self.EventsManagePanel.title = self.EventsManagePanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.EventsManagePanel.title:SetPoint("TOPLEFT", 10, -10)
        self.EventsManagePanel.title:SetText(L["Events Manager"])

        ---------------------------------------------------------------
        -- 6.2) Bouton "Event Active List"
        ---------------------------------------------------------------
		do
			local blockActiveList = CreateFrame("Frame", nil, self.EventsManagePanel)
			blockActiveList:SetSize(600, 40)
			-- On l'ancre en haut, mais sous le titre (ajustez le Y à votre convenance).
			blockActiveList:SetPoint("TOPLEFT", self.EventsManagePanel, "TOPLEFT", 10, -60)
		
			local btnActiveList = CreateFrame("Button", nil, blockActiveList, "UIPanelButtonTemplate")
			btnActiveList:SetText(L["Event Active List"])
			btnActiveList:SetSize(btnActiveList:GetTextWidth() + 20, 22)
			btnActiveList:SetPoint("TOPLEFT", blockActiveList, "TOPLEFT", 0, 0)
		
			btnActiveList:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(L["Event Active List tooltip"], 1,1,1,1,true)
			end)
			btnActiveList:SetScript("OnLeave", function() GameTooltip:Hide() end)
		
			btnActiveList:SetScript("OnClick", function()
				StartEventsCapture()
				SendChatMessage(".event activelist", "SAY")
			end)
		end

		---------------------------------------------------------------
        -- Container
        ---------------------------------------------------------------
        local container = CreateFrame("Frame", nil, self.EventsManagePanel)
        container:SetPoint("TOPLEFT", self.EventsManagePanel, "TOPLEFT", 10, -100)
        container:SetSize(self.EventsManagePanel:GetWidth()-20, self.EventsManagePanel:GetHeight()-80)

        local yOffset = 0
        
		---------------------------------------------------------------
		-- Fonction Reset
		---------------------------------------------------------------
		local function ResetDropdownSelection(scrollableDropdown, defaultText)
		scrollableDropdown.selectedEventID = nil
		scrollableDropdown:SetText(defaultText)
		end
        ---------------------------------------------------------------
        -- 6.1) Créer le dropdown "scrollable" + 3 boutons (Get/Start/Stop)
        ---------------------------------------------------------------
        do
			-- 1) Le bloc principal
            local block = CreateFrame("Frame", nil, container)
            block:SetSize(600, 40)
            block:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

			-- Juste après avoir créé local block ...
			local label = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			label:SetPoint("BOTTOMLEFT", block, "TOPLEFT", 0, -20)
			label:SetText(L["Drop Select Event"])


            -- 2) Le dropdown scrollable
            local scrollableDropdown = CreateScrollableEventsDropdown(block)
            scrollableDropdown:SetPoint("TOPLEFT", label, "TOPLEFT", 0, -20)

            scrollableDropdown:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Drop Select Event drop tooltip"], 1,1,1,1,true)
            end)
            scrollableDropdown:SetScript("OnLeave", function() GameTooltip:Hide() end)
			
            -- 3) Bouton "Info"
            local btnGet = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnGet:SetText(L["Info_Event"])
            btnGet:SetSize(btnGet:GetTextWidth() + 20, 22)
            btnGet:SetPoint("LEFT", scrollableDropdown, "RIGHT", 10, 0)
            btnGet:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Info_Event_tooltip"], 1,1,1,1,true)
            end)
            btnGet:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btnGet:SetScript("OnClick", function()
                local selectedID = scrollableDropdown.selectedEventID
                if not selectedID then
                    print(L["select_event_error"])
                    return
                end
                StartEventsCapture()
                local cmd = ".event info " .. tostring(selectedID)
                SendChatMessage(cmd, "SAY")
				-- Réinitialiser après utilisation :
				ResetDropdownSelection(scrollableDropdown, "Select Event")
            end)

            -- 4) Bouton "Start"
            local btnStart = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnStart:SetText(L["Start Event"])
            btnStart:SetSize(btnStart:GetTextWidth() + 20, 22)
            btnStart:SetPoint("LEFT", btnGet, "RIGHT", 10, 0)
            btnStart:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Start Event tooltip"], 1,1,1,1,true)
            end)
            btnStart:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btnStart:SetScript("OnClick", function()
                local selectedID = scrollableDropdown.selectedEventID
                if not selectedID then
                    print(L["select_event_error"])
                    return
                end
                StartEventsCapture()
                local cmd = ".event start " .. tostring(selectedID)
                SendChatMessage(cmd, "SAY")
				-- Réinitialiser après utilisation :
				ResetDropdownSelection(scrollableDropdown, "Select Event")
            end)

            -- 5) Bouton "Stop"
            local btnStop = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
            btnStop:SetText(L["Stop Event"])
            btnStop:SetSize(btnStop:GetTextWidth() + 20, 22)
            btnStop:SetPoint("LEFT", btnStart, "RIGHT", 10, 0)
            btnStop:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Stop Event tooltip"], 1,1,1,1,true)
            end)
            btnStop:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btnStop:SetScript("OnClick", function()
                local selectedID = scrollableDropdown.selectedEventID
                if not selectedID then
                    print(L["select_event_error"])
                    return
                end
                StartEventsCapture()
                local cmd = ".event stop " .. tostring(selectedID)
                SendChatMessage(cmd, "SAY")
				-- Réinitialiser après utilisation :
				ResetDropdownSelection(scrollableDropdown, "Select Event")
            end)

            yOffset = yOffset - 50
        end

        ---------------------------------------------------------------
        -- Bouton Retour
        ---------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.EventsManagePanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.EventsManagePanel, "BOTTOM", 0, 10)
        btnBack:SetText(L["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
        btnBack:SetScript("OnClick", function()
            self.EventsManagePanel:Hide()
            self.panel:Show()
        end)
    end

    TrinityAdmin:HideMainMenu()
    self.EventsManagePanel:Show()
end

-- Ouvre le panneau AurasList en masquant le panneau principal
-----------------------------------------------------------
-- Partie capture des messages système
-----------------------------------------------------------
local capturingEvents = false
local eventsInfoCollected = {}
local eventsInfoTimer = nil
local lastListCommand = nil

-- Frame pour écouter les messages système (CHAT_MSG_SYSTEM)
local eventsCaptureFrame = CreateFrame("Frame")
eventsCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
eventsCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingEvents then return end

    -- Nettoyage minimal du message
    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
                       :gsub("|r", "")
                       :gsub("|H.-|h(.-)|h", "%1")
                       :gsub("|T.-|t", "")
                       :gsub("\226[\148-\149][\128-\191]", "")
    table.insert(eventsInfoCollected, cleanMsg)

    -- Redémarrer un timer d'une seconde
    if eventsInfoTimer then
        eventsInfoTimer:Cancel()
    end
	eventsInfoTimer = C_Timer.NewTimer(1, function()
		capturingEvents = false
		local fullText = table.concat(eventsInfoCollected, "\n")
		local lines = ProcessEventsCapturedText(fullText)
		if lastListCommand and lastListCommand:find("%.list spawnpoints") then
			ShowListSpawnsPopup(lines)
		else
			ShowEventsAceGUI(lines)
		end
		lastListCommand = nil  -- Réinitialisation après traitement
	end)--Fin du callback du timer
end)  -- Fin de la fonction OnEvent

-- Lance la capture
local function StartEventsCapture()
    wipe(eventsInfoCollected)
    capturingEvents = true
    if eventsInfoTimer then
        eventsInfoTimer:Cancel()
        eventsInfoTimer = nil
    end
end

-- Fonction de parsing : sépare le texte en lignes
function ProcessEventsCapturedText(input)
    local text = (type(input) == "table") and table.concat(input, "\n") or input
    local processedLines = {}
    for line in text:gmatch("[^\r\n]+") do
        table.insert(processedLines, line)
    end
    return processedLines
end

-- Affiche les messages capturés dans une popup AceGUI
function ShowEventsAceGUI(lines)
    local AceGUI = LibStub("AceGUI-3.0")
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["Captured Events"])
	frame:SetStatusText(L["Information from other commands"])
    frame:SetLayout("Fill")
    frame:SetWidth(400)
    frame:SetHeight(300)
    
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    frame:AddChild(scroll)
    
    for i, line in ipairs(lines) do
        local edit = AceGUI:Create("EditBox")
        edit:SetLabel(L["Line "] .. i)
        edit:SetText(line)
        edit:SetFullWidth(true)
        scroll:AddChild(edit)
    end

    local closeBtn = AceGUI:Create("Button")
    closeBtn:SetText(L["Close"])
    closeBtn:SetWidth(100)
    closeBtn:SetCallback("OnClick", function() AceGUI:Release(frame) end)
    frame:AddChild(closeBtn)
end

-- Affiche les messages capturés pour List spawns
-- function ShowListSpawnsPopup(lines)
--     local AceGUI = LibStub("AceGUI-3.0")
--     local frame = AceGUI:Create("Frame")
--     frame:SetTitle("List Spawnpoints")
-- 	frame:SetStatusText("Information from .List Spawnpoints commands")
--     frame:SetLayout("Fill")
--     frame:SetWidth(500)
--     frame:SetHeight(400)
--   
--     local multiline = AceGUI:Create("MultiLineEditBox")
--     multiline:SetLabel("Spawnpoints")
--     multiline:SetFullWidth(true)
--     multiline:SetFullHeight(true)
--     multiline:SetText(table.concat(lines, "\n"))
--     if multiline.editBox then
--         multiline.editBox:HookScript("OnEditFocusGained", function(self)
--             self:ClearFocus()
--         end)
--     end
--     frame:AddChild(multiline)
--     
--     local closeBtn = AceGUI:Create("Button")
--     closeBtn:SetText("Close")
--     closeBtn:SetWidth(100)
--     closeBtn:SetCallback("OnClick", function() AceGUI:Release(frame) end)
--     frame:AddChild(closeBtn)
-- end
function ShowListSpawnsPopup(lines)
    local AceGUI = LibStub("AceGUI-3.0")
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["List Spawnpoints"])
    frame:SetStatusText(L["Information from .List Spawnpoints commands"])
    frame:SetLayout("List")
    frame:SetWidth(500)
    frame:SetHeight(400)
    
    local pageSize = 40  -- Nombre de lignes par page
    local currentPage = 1
    local totalPages = math.ceil(#lines / pageSize)
    
    local function GetPageText(page)
        local startIndex = (page - 1) * pageSize + 1
        local endIndex = math.min(page * pageSize, #lines)
        local pageLines = {}
        for i = startIndex, endIndex do
            table.insert(pageLines, lines[i])
        end
        return table.concat(pageLines, "\n")
    end

    -- Zone de texte avec hauteur fixe pour laisser de la place aux boutons
    local multiline = AceGUI:Create("MultiLineEditBox")
    multiline:SetLabel(L["Spawnpoints"])
    multiline:SetFullWidth(true)
    multiline:SetHeight(250)
    multiline:SetText(GetPageText(currentPage))
    if multiline.editBox then
        multiline.editBox:HookScript("OnEditFocusGained", function(self)
            self:ClearFocus()
        end)
    end
    frame:AddChild(multiline)
    
    -- Groupe de pagination
    local paginationGroup = AceGUI:Create("SimpleGroup")
    paginationGroup:SetFullWidth(true)
    paginationGroup:SetLayout("Flow")
    paginationGroup:SetHeight(30)
    
local btnPrev = AceGUI:Create("Button")
btnPrev:SetText(L["Preview"])
btnPrev:SetWidth(100)
btnPrev:SetCallback("OnClick", function()
    if currentPage > 1 then
        currentPage = currentPage - 1
        multiline:SetText(GetPageText(currentPage))
        pageLabel:SetText("Page " .. currentPage .. " / " .. totalPages)
    end
end)
paginationGroup:AddChild(btnPrev)

-- Espaceur pour décaler le label de pagination
local spacer = AceGUI:Create("Label")
spacer:SetText("")
spacer:SetWidth(40)  -- ajustez cette largeur selon vos besoins
paginationGroup:AddChild(spacer)

local pageLabel = AceGUI:Create("Label")
pageLabel:SetText("Page " .. currentPage .. " / " .. totalPages)
pageLabel:SetWidth(150)
paginationGroup:AddChild(pageLabel)

local btnNext = AceGUI:Create("Button")
btnNext:SetText(L["Next"])
btnNext:SetWidth(100)
btnNext:SetCallback("OnClick", function()
    if currentPage < totalPages then
        currentPage = currentPage + 1
        multiline:SetText(GetPageText(currentPage))
        pageLabel:SetText("Page " .. currentPage .. " / " .. totalPages)
    end
end)
paginationGroup:AddChild(btnNext)
    
    frame:AddChild(paginationGroup)
    
    -- local closeBtn = AceGUI:Create("Button")
    -- closeBtn:SetText("Close")
    -- closeBtn:SetWidth(100)
    -- closeBtn:SetCallback("OnClick", function() AceGUI:Release(frame) end)
    -- frame:AddChild(closeBtn)
end

-----------------------------------------------------------
-- Panneau AurasList Management
-----------------------------------------------------------
function Misc:OpenAurasListManagement()
    if self.panel then
        self.panel:Hide()
    end
    if not self.AurasListPanel then
        self.AurasListPanel = CreateFrame("Frame", "TrinityAdminAurasListPanel", TrinityAdminMainFrame)
        self.AurasListPanel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
        self.AurasListPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.AurasListPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.AurasListPanel)
        bg:SetColorTexture(0.6, 0.4, 0.2, 0.7)
        
        self.AurasListPanel.title = self.AurasListPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.AurasListPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.AurasListPanel.title:SetText(L["Auras and Lists Funcs"])
        
        ----------------------------------------------------------------------------
        -- 1) Boutons "List Auras", "List Scenes" et "List Spawnpoints"
        ----------------------------------------------------------------------------
        local btnListAuras = CreateFrame("Button", nil, self.AurasListPanel, "UIPanelButtonTemplate")
        btnListAuras:SetPoint("TOPLEFT", self.AurasListPanel, "TOPLEFT", 10, -40)
        btnListAuras:SetText(L["List Auras"])
        btnListAuras:SetWidth(btnListAuras:GetTextWidth() + 20)
        btnListAuras:SetHeight(22)
        btnListAuras:SetScript("OnClick", function()
            StartEventsCapture()
            local command = ".list auras"
            SendChatMessage(command, "SAY")
        end)
        btnListAuras:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["List Auras tooltip"], 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btnListAuras:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        local btnListScenes = CreateFrame("Button", nil, self.AurasListPanel, "UIPanelButtonTemplate")
        btnListScenes:SetPoint("LEFT", btnListAuras, "RIGHT", 10, 0)
        btnListScenes:SetText(L["List Scenes"])
        btnListScenes:SetWidth(btnListScenes:GetTextWidth() + 20)
        btnListScenes:SetHeight(22)
        btnListScenes:SetScript("OnClick", function()
            StartEventsCapture()
            local command = ".list scenes"
            SendChatMessage(command, "SAY")
        end)
        btnListScenes:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["List Scenes tooltip"], 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btnListScenes:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        local btnListSpawnpoints = CreateFrame("Button", nil, self.AurasListPanel, "UIPanelButtonTemplate")
        btnListSpawnpoints:SetPoint("LEFT", btnListScenes, "RIGHT", 10, 0)
        btnListSpawnpoints:SetText(L["List Spawnpoints"])
        btnListSpawnpoints:SetWidth(btnListSpawnpoints:GetTextWidth() + 20)
        btnListSpawnpoints:SetHeight(22)
        btnListSpawnpoints:SetScript("OnClick", function()
    local command = ".list spawnpoints"
    lastListCommand = command  -- sauvegarde de la commande
    StartEventsCapture()
    SendChatMessage(command, "SAY")
end)
        btnListSpawnpoints:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["List Spawnpoints tooltip"], 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btnListSpawnpoints:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        ----------------------------------------------------------------------------
        -- 2) Ligne "Creature ID", "Max Count" et bouton "Show Creatures List"
        ----------------------------------------------------------------------------
        local editCreatureID = CreateFrame("EditBox", nil, self.AurasListPanel, "InputBoxTemplate")
        editCreatureID:SetSize(80, 22)
        editCreatureID:SetPoint("TOPLEFT", btnListAuras, "BOTTOMLEFT", 0, -20)
        editCreatureID:SetText("Creature ID")
        editCreatureID:SetAutoFocus(false)
        
        local editCreatureMax = CreateFrame("EditBox", nil, self.AurasListPanel, "InputBoxTemplate")
        editCreatureMax:SetSize(80, 22)
        editCreatureMax:SetPoint("LEFT", editCreatureID, "RIGHT", 10, 0)
        editCreatureMax:SetText("Max Count")
        editCreatureMax:SetAutoFocus(false)
        
        local btnShowCreatures = CreateFrame("Button", nil, self.AurasListPanel, "UIPanelButtonTemplate")
        btnShowCreatures:SetPoint("LEFT", editCreatureMax, "RIGHT", 10, 0)
        btnShowCreatures:SetText(L["Show Creatures List"])
        btnShowCreatures:SetWidth(btnShowCreatures:GetTextWidth() + 20)
        btnShowCreatures:SetHeight(22)
        btnShowCreatures:SetScript("OnClick", function()
            local creatureID = editCreatureID:GetText()
            local maxCount = editCreatureMax:GetText()
            if creatureID == "" or creatureID == "Creature ID" then
                print(L["enter_valid_creature_id_error"])
                return
            end
            StartEventsCapture()
            local command = ".list creature " .. creatureID
            if maxCount ~= "" and maxCount ~= "Max Count" then
                command = command .. " " .. maxCount
            end
            SendChatMessage(command, "SAY")
            editCreatureID:SetText("Creature ID")
            editCreatureMax:SetText("Max Count")
        end)
        btnShowCreatures:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Show Creatures List Tooltip"], 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btnShowCreatures:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        ----------------------------------------------------------------------------
        -- 3) Ligne "Item ID", "Max Count" et bouton "Show Items List"
        ----------------------------------------------------------------------------
        local editItemID = CreateFrame("EditBox", nil, self.AurasListPanel, "InputBoxTemplate")
        editItemID:SetSize(80, 22)
        editItemID:SetPoint("TOPLEFT", editCreatureID, "BOTTOMLEFT", 0, -20)
        editItemID:SetText("Item ID")
        editItemID:SetAutoFocus(false)
        
        local editItemMax = CreateFrame("EditBox", nil, self.AurasListPanel, "InputBoxTemplate")
        editItemMax:SetSize(80, 22)
        editItemMax:SetPoint("LEFT", editItemID, "RIGHT", 10, 0)
        editItemMax:SetText("Max Count")
        editItemMax:SetAutoFocus(false)
        
        local btnShowItems = CreateFrame("Button", nil, self.AurasListPanel, "UIPanelButtonTemplate")
        btnShowItems:SetPoint("LEFT", editItemMax, "RIGHT", 10, 0)
        btnShowItems:SetText(L["Show Items List"])
        btnShowItems:SetWidth(btnShowItems:GetTextWidth() + 20)
        btnShowItems:SetHeight(22)
        btnShowItems:SetScript("OnClick", function()
            local itemID = editItemID:GetText()
            local maxCount = editItemMax:GetText()
            if itemID == "" or itemID == "Item ID" then
               print(L["enter_valid_item_id_error"])
                return
            end
            StartEventsCapture()
            local command = ".list item " .. itemID
            if maxCount ~= "" and maxCount ~= "Max Count" then
                command = command .. " " .. maxCount
            end
            SendChatMessage(command, "SAY")
            editItemID:SetText("Item ID")
            editItemMax:SetText("Max Count")
        end)
        btnShowItems:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Show Items List tooltip"], 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btnShowItems:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        ----------------------------------------------------------------------------
        -- 4) Ligne "Character Name" et bouton "List Mails"
        ----------------------------------------------------------------------------
        local editCharacterName = CreateFrame("EditBox", nil, self.AurasListPanel, "InputBoxTemplate")
        editCharacterName:SetSize(120, 22)
        editCharacterName:SetPoint("TOPLEFT", editItemID, "BOTTOMLEFT", 0, -20)
        editCharacterName:SetText("Character Name")
        editCharacterName:SetAutoFocus(false)
        
        local btnListMails = CreateFrame("Button", nil, self.AurasListPanel, "UIPanelButtonTemplate")
        btnListMails:SetPoint("LEFT", editCharacterName, "RIGHT", 10, 0)
        btnListMails:SetText(L["List Mails"])
        btnListMails:SetWidth(btnListMails:GetTextWidth() + 20)
        btnListMails:SetHeight(22)
        btnListMails:SetScript("OnClick", function()
            local characterName = editCharacterName:GetText()
            if characterName == "" or characterName == "Character Name" then
                print(L["enter_valid_character_name_error"])
                return
            end
            StartEventsCapture()
            local command = ".list mail " .. characterName
            SendChatMessage(command, "SAY")
            editCharacterName:SetText("Character Name")
        end)
        btnListMails:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["List Mails tooltip"], 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btnListMails:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        ----------------------------------------------------------------------------
        -- 5) Ligne "Gameobject ID", "Max Count" et bouton "Show Gamobjects List"
        ----------------------------------------------------------------------------
        local editGobjectID = CreateFrame("EditBox", nil, self.AurasListPanel, "InputBoxTemplate")
        editGobjectID:SetSize(80, 22)
        editGobjectID:SetPoint("TOPLEFT", editCharacterName, "BOTTOMLEFT", 0, -20)
        editGobjectID:SetText("Gameobject ID")
        editGobjectID:SetAutoFocus(false)
        
        local editGobjectMax = CreateFrame("EditBox", nil, self.AurasListPanel, "InputBoxTemplate")
        editGobjectMax:SetSize(80, 22)
        editGobjectMax:SetPoint("LEFT", editGobjectID, "RIGHT", 10, 0)
        editGobjectMax:SetText("Max Count")
        editGobjectMax:SetAutoFocus(false)
        
        local btnShowGobjects = CreateFrame("Button", nil, self.AurasListPanel, "UIPanelButtonTemplate")
        btnShowGobjects:SetPoint("LEFT", editGobjectMax, "RIGHT", 10, 0)
        btnShowGobjects:SetText(L["Show Gamobjects List"])
        btnShowGobjects:SetWidth(btnShowGobjects:GetTextWidth() + 20)
        btnShowGobjects:SetHeight(22)
        btnShowGobjects:SetScript("OnClick", function()
            local gobjectID = editGobjectID:GetText()
            local maxCount = editGobjectMax:GetText()
            if gobjectID == "" or gobjectID == "Gameobject ID" then
                print(L["enter_valid_gameobject_id_error"])
                return
            end
            StartEventsCapture()
            local command = ".list object " .. gobjectID
            if maxCount ~= "" and maxCount ~= "Max Count" then
                command = command .. " " .. maxCount
            end
            SendChatMessage(command, "SAY")
            editGobjectID:SetText("Gameobject ID")
            editGobjectMax:SetText("Max Count")
        end)
        btnShowGobjects:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Show Gamobjects List tooltip"], 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btnShowGobjects:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        ----------------------------------------------------------------------------
        -- 6) Ligne "Distance" et bouton "List Respawns"
        ----------------------------------------------------------------------------
        local editDistance = CreateFrame("EditBox", nil, self.AurasListPanel, "InputBoxTemplate")
        editDistance:SetSize(80, 22)
        editDistance:SetPoint("TOPLEFT", editGobjectID, "BOTTOMLEFT", 0, -20)
        editDistance:SetText("Distance")
        editDistance:SetAutoFocus(false)
        
        local btnListRespawns = CreateFrame("Button", nil, self.AurasListPanel, "UIPanelButtonTemplate")
        btnListRespawns:SetPoint("LEFT", editDistance, "RIGHT", 10, 0)
        btnListRespawns:SetText(L["List Respawns"])
        btnListRespawns:SetWidth(btnListRespawns:GetTextWidth() + 20)
        btnListRespawns:SetHeight(22)
        btnListRespawns:SetScript("OnClick", function()
            local distance = editDistance:GetText()
            StartEventsCapture()
            local command = ".list respawns"
            if distance ~= "" and distance ~= "Distance" then
                command = command .. " " .. distance
            end
            SendChatMessage(command, "SAY")
            editDistance:SetText("Distance")
        end)
        btnListRespawns:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["List Respawns tooltip"], 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btnListRespawns:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        ----------------------------------------------------------------------------
        -- Bouton "Back" pour revenir au panneau principal
        ----------------------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.AurasListPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.AurasListPanel, "BOTTOM", 0, 10)
        btnBack:SetText(L["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
        btnBack:SetScript("OnClick", function()
            self.AurasListPanel:Hide()
            self.panel:Show()
        end)
    end

    TrinityAdmin:HideMainMenu()
    self.AurasListPanel:Show()
end
