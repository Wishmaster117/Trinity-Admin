local Misc = TrinityAdmin:GetModule("Misc")

local Misc = TrinityAdmin:GetModule("Misc")

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
    frame:SetTitle("Lookup Info")
    frame:SetStatusText("Information from .lookup")
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
        edit:SetLabel("Line " .. i)
        edit:SetText(line)
        edit:SetFullWidth(true)
        scroll:AddChild(edit)
    end

    -- Bouton de fermeture
    local btnClose = AceGUI:Create("Button")
    btnClose:SetText("Fermer")
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
    btnTitles:SetSize(150, 22)
    btnTitles:SetPoint("TOPLEFT", panel, "TOPLEFT", 100, -80)
    btnTitles:SetText("Titles Management")
    btnTitles:SetScript("OnClick", function() self:OpenTitlesManagement() end)
    
    local btnResets = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnResets:SetSize(150, 22)
    btnResets:SetPoint("LEFT", btnTitles, "RIGHT", 10, 0)
    btnResets:SetText("Resets Management")
    btnResets:SetScript("OnClick", function() self:OpenResetsManagement() end)
    
    local btnArena = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnArena:SetSize(150, 22)
    btnArena:SetPoint("LEFT", btnResets, "RIGHT", 10, 0)
    btnArena:SetText("Arena Management")
    btnArena:SetScript("OnClick", function() self:OpenArenaManagement() end)
    
    local btnLookup = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnLookup:SetSize(150, 22)
    btnLookup:SetPoint("TOPLEFT", btnTitles, "BOTTOMLEFT", 0, -10)
    btnLookup:SetText("Lookup Functions")
    btnLookup:SetScript("OnClick", function() self:OpenLookupFunctions() end)
    
    local btnGroups = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnGroups:SetSize(150, 22)
    btnGroups:SetPoint("LEFT", btnLookup, "RIGHT", 10, 0)
    btnGroups:SetText("Groups Management")
    btnGroups:SetScript("OnClick", function() self:OpenGroupsManagement() end)
    
    local btnQuests = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnQuests:SetSize(150, 22)
    btnQuests:SetPoint("LEFT", btnGroups, "RIGHT", 10, 0)
    btnQuests:SetText("Quests Management")
    btnQuests:SetScript("OnClick", function() self:OpenQuestsManagement() end)
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
    panel.title:SetText("Misc Functions")
    
    -- Ajoute les boutons de gestion
    self:AddManagementButtons(panel)
    
    -- Bouton Retour
    local btnBack = CreateFrame("Button", "TrinityAdminMiscBackButton", panel, "UIPanelButtonTemplate")
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
        self.titlesPanel.title:SetText("Titles Management")

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
        filterEditBox:SetText("Search...")
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
        btnPrev:SetText("Preview")
        btnPrev:SetPoint("RIGHT", btnPage, "LEFT", -5, 0)

        btnNext = CreateFrame("Button", nil, self.titlesPanel, "UIPanelButtonTemplate")
        btnNext:SetSize(80, 22)
        btnNext:SetText("Next")
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
        chkAdd.text:SetText("Add a Title")

        chkRemove = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
        chkRemove:SetPoint("TOPLEFT", chkAdd, "BOTTOMLEFT", 0, -10)
        chkRemove.text = chkRemove:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chkRemove.text:SetPoint("LEFT", chkRemove, "RIGHT", 5, 0)
        chkRemove.text:SetText("Remove a Title")

        chkCurrent = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
        chkCurrent:SetPoint("TOPLEFT", chkRemove, "BOTTOMLEFT", 0, -10)
        chkCurrent.text = chkCurrent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chkCurrent.text:SetPoint("LEFT", chkCurrent, "RIGHT", 5, 0)
        chkCurrent.text:SetText("Set Title as Current")

        -- EDItBOX & BOUTON "SET" : titles set mask
        editMask = CreateFrame("EditBox", nil, optionsFrame, "InputBoxTemplate")
        editMask:SetSize(100, 22)
        editMask:SetPoint("TOPLEFT", chkCurrent, "BOTTOMLEFT", 0, -10)
        editMask:SetText("Set titles mask")

        btnSetMask = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
        btnSetMask:SetSize(80, 22)
        btnSetMask:SetPoint("LEFT", editMask, "RIGHT", 5, 0)
        btnSetMask:SetText("Set")

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
                print("Veuillez sélectionner un joueur.")
                return
            end
            local maskValue = editMask:GetText()
            if maskValue == "" or maskValue == "Set titles mask" then
                print("Veuillez saisir une valeur pour le mask.")
                return
            end
            -- Envoie la commande
            SendChatMessage(".titles set mask " .. maskValue, "SAY")
            editMask:SetText("Set titles mask")
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
                local fullText = TrinityAdmin_Translations[option.name] or ("Item " .. i)
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
                        print("Veuillez sélectionner un joueur.")
                        return
                    end
                    if chkAdd:GetChecked() then
                        SendChatMessage(".titles add " .. option.entry, "SAY")
                    elseif chkRemove:GetChecked() then
                        SendChatMessage(".titles remove " .. option.entry, "SAY")
                    elseif chkCurrent:GetChecked() then
                        SendChatMessage(".titles current " .. option.entry, "SAY")
                    else
                        print("Veuillez sélectionner add/remove/current, ou utiliser Set pour le mask.")
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
                print("Veuillez entrer au moins 3 caractères pour la recherche.")
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
                    scrollChild.noResultText:SetText("|cffff0000Nothing found|r")
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
        btnReset:SetSize(80, 22)
        btnReset:SetText("Reset")
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
        btnBack:SetText(TrinityAdmin_Translations["Back"])
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
        self.resetsPanel.title:SetText("Resets Management")
        
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
            editBox:SetText("Player Name")
            editBox:SetAutoFocus(false)
            
            local btn = CreateFrame("Button", nil, self.resetsPanel, "UIPanelButtonTemplate")
            btn:SetSize(140, 22)
            btn:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
            btn:SetText("Reset Achievements")
            
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .reset achievements [$playername]\r\n\r\n" ..
                    "Reset achievements data for selected or named (online or offline) character.\n" ..
                    "Achievements for persistance progress data like completed quests/etc re-filled at reset.\n" ..
                    "Achievements for events like kills/casts/etc will be lost.",
                    1,1,1,1,true
                )
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
            chkSpells.text:SetText("Reset All Spells")
            
            local chkTalents = CreateFrame("CheckButton", nil, self.resetsPanel, "UICheckButtonTemplate")
            chkTalents:SetPoint("TOPLEFT", chkSpells, "BOTTOMLEFT", 0, -10)
            chkTalents.text = chkTalents:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            chkTalents.text:SetPoint("LEFT", chkTalents, "RIGHT", 5, 0)
            chkTalents.text:SetText("Reset All Talents")
            
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
            btn:SetText("Reset")
            
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .reset all spells\r\n\r\n" ..
                    "Syntax: .reset all talents\r\n\r\n" ..
                    "Request reset spells or talents (including talents for all character's pets if any)\n" ..
                    "at next login each existed character.",
                    1,1,1,1,true
                )
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            
            btn:SetScript("OnClick", function()
                if chkSpells:GetChecked() then
                    SendChatMessage(".reset all spells", "SAY")
                elseif chkTalents:GetChecked() then
                    SendChatMessage(".reset all talents", "SAY")
                else
                    print("Veuillez cocher 'Reset All Spells' ou 'Reset All Talents' avant d'appuyer sur Reset.")
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
            editBox:SetText("Player Name")
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
                print("[DEBUG] Commande envoyée: " .. command .. " " .. finalName)
                SendChatMessage(command .. " " .. finalName, "SAY")
            end)
            
            yOffset = yOffset - 40
        end
        
        ------------------------------------------------------------
        -- 3) Reset Honor
        ------------------------------------------------------------
        CreateResetRow(
            "Reset Honor",
            "Syntax: .reset honor [Playername]\nReset all honor data for targeted character.",
            ".reset honor"
        )
        
        ------------------------------------------------------------
        -- 4) Reset Level
        ------------------------------------------------------------
        CreateResetRow(
            "Reset Level",
            "Syntax: .reset level [Playername]\nReset level to 1 including reset stats and talents.\n" ..
            "Equipped items with greater level requirement can be lost.",
            ".reset level"
        )
        
        ------------------------------------------------------------
        -- 5) Reset Spells
        ------------------------------------------------------------
        CreateResetRow(
            "Reset Spells",
            "Syntax: .reset spells [Playername]\nRemoves all non-original spells from spellbook.\n" ..
            "Playername can be name of offline character.",
            ".reset spells"
        )
        
        ------------------------------------------------------------
        -- 6) Reset Stats
        ------------------------------------------------------------
        CreateResetRow(
            "Reset Stats",
            "Syntax: .reset stats [Playername]\nResets(recalculate) all stats of the targeted player " ..
            "to their original VALUES at current level.",
            ".reset stats"
        )
        
        ------------------------------------------------------------
        -- 7) Reset Talents
        ------------------------------------------------------------
        CreateResetRow(
            "Reset Talents",
            "Syntax: .reset talents [Playername]\nRemoves all talents of the targeted player or pet " ..
            "or named player.\nPlayername can be name of offline character.\n" ..
            "With player talents also will be reset talents for all character's pets if any.",
            ".reset talents"
        )
        
        ------------------------------------------------------------
        -- Bouton Retour
        ------------------------------------------------------------
        local btnBack = CreateFrame("Button", nil, self.resetsPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.resetsPanel, "BOTTOM", 0, 10)
        btnBack:SetText(TrinityAdmin_Translations["Back"])
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
        self.arenaPanel.title:SetText("Arena Management")

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
            editLeader:SetText("Leader Name")
            editLeader:SetAutoFocus(false)
            
            local editTeam  = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editTeam:SetSize(100, 22)
            editTeam:SetPoint("LEFT", editLeader, "RIGHT", 10, 0)
            editTeam:SetText("Team Name")
            editTeam:SetAutoFocus(false)
            
            local editType  = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
            editType:SetSize(40, 22)
            editType:SetPoint("LEFT", editTeam, "RIGHT", 10, 0)
            editType:SetText("Type")
            editType:SetAutoFocus(false)
            
            local btnCreate = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            btnCreate:SetText("Create Arena Team")
            -- Ajuste automatiquement la largeur du bouton en fonction du texte
            btnCreate:SetSize(btnCreate:GetTextWidth() + 20, 22)
            btnCreate:SetPoint("LEFT", editType, "RIGHT", 10, 0)
            
            -- Tooltip
            btnCreate:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .arena create $name \"arena name\" #type\n\n" ..
                    "A command to create a new Arena-team in game.\n" ..
                    "#type = [2/3/5]",
                    1,1,1,1,true
                )
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
                    print("Veuillez renseigner un Leader Name valide.")
                    return
                end
                if not teamVal or teamVal == "" or teamVal == "Team Name" then
                    print("Veuillez renseigner un Team Name valide.")
                    return
                end
                if not typeVal or typeVal == "" or typeVal == "Type" then
                    print("Veuillez saisir un Type (2, 3 ou 5).")
                    return
                end

                local typeNum = tonumber(typeVal)
                if not typeNum or (typeNum ~= 2 and typeNum ~= 3 and typeNum ~= 5) then
                    print("Le Type doit être 2, 3 ou 5.")
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
            btnRename:SetText("Change Arena Team Name")
            btnRename:SetSize(btnRename:GetTextWidth() + 20, 22)
            btnRename:SetPoint("LEFT", editNew, "RIGHT", 10, 0)

            -- Tooltip
            btnRename:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .arena rename \"oldname\" \"newname\"\n\n" ..
                    "A command to rename Arena-team name.",
                    1,1,1,1,true
                )
            end)
            btnRename:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- OnClick
            btnRename:SetScript("OnClick", function()
                local oldVal = editOld:GetText()
                local newVal = editNew:GetText()

                if not oldVal or oldVal == "" or oldVal == "Old Name" then
                    print("Veuillez renseigner un Old Name valide.")
                    return
                end
                if not newVal or newVal == "" or newVal == "New Name" then
                    print("Veuillez renseigner un New Name valide.")
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
            btnCaptain:SetText("Assign Leadership")
            btnCaptain:SetSize(btnCaptain:GetTextWidth() + 20, 22)
            btnCaptain:SetPoint("LEFT", editLeaderName, "RIGHT", 10, 0)

            -- Tooltip
            btnCaptain:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .arena captain #TeamID $name\n\n" ..
                    "A command to set new captain to the team. $name must be in the team.",
                    1,1,1,1,true
                )
            end)
            btnCaptain:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

			-- OnClick
			btnCaptain:SetScript("OnClick", function()
				local teamID   = editTeamID:GetText()
				local leaderNm = editLeaderName:GetText()
			
				if not teamID or teamID == "" or teamID == "Team ID" then
					print("Veuillez renseigner un Team ID valide.")
					return
				end
				if not leaderNm or leaderNm == "" or leaderNm == "New Leader Name" then
					print("Veuillez renseigner un New Leader Name valide.")
					return
				end
			
				-- Vérifie que le nom ne comporte pas d'espaces
				if leaderNm:find("%s") then
					print("Le nom du leader ne doit pas comporter d'espaces.")
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
            btnInfo:SetText("Get Team Info")
            btnInfo:SetSize(btnInfo:GetTextWidth() + 20, 22)
            btnInfo:SetPoint("LEFT", editTeamID, "RIGHT", 10, 0)

            -- Tooltip
            btnInfo:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .arena info #TeamID\n\n" ..
                    "A command that show info about arena team.",
                    1,1,1,1,true
                )
            end)
            btnInfo:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- OnClick
            btnInfo:SetScript("OnClick", function()
                local teamID = editTeamID:GetText()
                if not teamID or teamID == "" or teamID == "Team ID" then
                    print("Veuillez renseigner un Team ID valide.")
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
            btnLookup:SetText("Lookup Teams")
            btnLookup:SetSize(btnLookup:GetTextWidth() + 20, 22)
            btnLookup:SetPoint("LEFT", editTeamName, "RIGHT", 10, 0)

            -- Tooltip
            btnLookup:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .arena lookup $name\n\n" ..
                    "A command that gives a list of arenateams matching the given $name.",
                    1,1,1,1,true
                )
            end)
            btnLookup:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- OnClick
            btnLookup:SetScript("OnClick", function()
                local tName = editTeamName:GetText()
                if not tName or tName == "" or tName == "Team Name" then
                    print("Veuillez renseigner un Team Name valide.")
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
            btnDisband:SetText("Disband Teams")
            btnDisband:SetSize(btnDisband:GetTextWidth() + 20, 22)
            btnDisband:SetPoint("LEFT", editTeamID, "RIGHT", 10, 0)

            -- Tooltip
            btnDisband:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .arena disband #TeamID\n\n" ..
                    "A command to disband an Arena-team in game.",
                    1,1,1,1,true
                )
            end)
            btnDisband:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- OnClick
            btnDisband:SetScript("OnClick", function()
                local teamID = editTeamID:GetText()
                if not teamID or teamID == "" or teamID == "Team ID" then
                    print("Veuillez renseigner un Team ID valide.")
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
        btnBack:SetText(TrinityAdmin_Translations["Back"])
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
        self.lookupPanel.title:SetText("Lookup Functions")

        -------------------------------------------------------------------------
        -- Fonctions utilitaires
        -------------------------------------------------------------------------
        
        -- Réinitialiser un champ EditBox à une valeur par défaut
        local function ResetEditBox(editBox, defaultText)
            editBox:SetText(defaultText)
        end
        
        -- Fonction pour ajouter les résultats dans la fenêtre ACE3
        -- (Supposons qu'une fonction TrinityAdmin:AppendAce3Line(msg) existe déjà,
        --  qui ajoute la ligne 'msg' dans un conteneur ACE3, comme vous l'avez
        --  fait dans d'autres modules.)
        local function AppendLookupResult(line)
            -- Exemples :
            -- TrinityAdmin:AppendAce3Line(line)
            -- ou tout autre code d'intégration à la fenêtre ACE3
            TrinityAdmin:AppendAce3Line(line)
        end
        
        -- Filtre chat (exemple) : si on veut capturer les réponses du serveur
        -- dans SAY et les envoyer dans la fenêtre ACE3
        local function OnChatMsgSayFilter(selfFrame, event, msg, player, ...)
            -- On peut y faire un test plus fin si on veut seulement
            -- des retours de commandes .lookup :
            -- if msg:match("^Lookup result:") then ...
            AppendLookupResult(msg)
            return false  -- laisser le message s'afficher en chat normal
        end
        
        -- Installation d'un filtre sur le canal SAY (facultatif)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", OnChatMsgSayFilter)

        -------------------------------------------------------------------------
        -- Création des options pour le premier menu déroulant (un seul champ + bouton)
        -------------------------------------------------------------------------
        local singleOptions = {
            {
                text       = "lookup area",
                defaultEB  = "Enter Area Name part",
                command    = ".lookup area",
                tooltip    = "Syntax: .lookup area $namepart\r\n\r\n" ..
                             "Looks up an area by $namepart, and returns all matches with their area ID's."
            },
            {
                text       = "lookup creature",
                defaultEB  = "Enter Creature Name part",
                command    = ".lookup creature",
                tooltip    = "Syntax: .lookup creature $namepart\r\n\r\n" ..
                             "Looks up a creature by $namepart, and returns all matches with their creature ID's."
            },
            {
                text       = "lookup event",
                defaultEB  = "Enter Event Neme",  -- y a-t-il un correctif => "Enter Event Name" ?
                command    = ".lookup event",
                tooltip    = "Syntax: .lookup event $name\r\n" ..
                             "Attempts to find the ID of the event with the provided $name."
            },
            {
                text       = "lookup faction",
                defaultEB  = "Enter Faction Name",
                command    = ".lookup faction",
                tooltip    = "Syntax: .lookup faction $name\r\n" ..
                             "Attempts to find the ID of the faction with the provided $name."
            },
            {
                text       = "lookup item",
                defaultEB  = "Enter Item Name",
                command    = ".lookup item",
                tooltip    = "Syntax: .lookup item $itemname\r\n\r\n" ..
                             "Looks up an item by $itemname, and returns all matches with their Item ID's."
            },
            {
                text       = "lookup item set",
                defaultEB  = "Enter ItemSet Name",
                command    = ".lookup item set",
                tooltip    = "Syntax: .lookup itemset $itemname\r\n\r\n" ..
                             "Looks up an item set by $itemname, and returns all matches with their Item set ID's."
            },
            {
                text       = "lookup map",
                defaultEB  = "Enter Map Name Part",
                command    = ".lookup map",
                tooltip    = "Syntax: .lookup map $namepart\r\n\r\n" ..
                             "Looks up a map by $namepart, and returns all matches with their map ID's."
            },
            {
                text       = "lookup object",
                defaultEB  = "Enter Object Name",
                command    = ".lookup object",
                tooltip    = "Syntax: .lookup object $objname\r\n\r\n" ..
                             "Looks up a gameobject by $objname, and returns all matches with their Gameobject ID's."
            },
            {
                text       = "lookup quest",
                defaultEB  = "Enter Quest Name Part",
                command    = ".lookup quest",
                tooltip    = "Syntax: .lookup quest $namepart\r\n\r\n" ..
                             "Looks up a quest by $namepart, and returns all matches with their quest ID's."
            },
            {
                text       = "lookup skill",
                defaultEB  = "Enter Skill Name Part",
                command    = ".lookup skill",
                tooltip    = "Syntax: .lookup skill $namepart\r\n\r\n" ..
                             "Looks up a skill by $namepart, and returns all matches with their skill ID's."
            },
            {
                text       = "lookup spell",
                defaultEB  = "Enter Spell Name Part",
                command    = ".lookup spell",
                tooltip    = "Syntax: .lookup spell $namepart\r\n\r\n" ..
                             "Looks up a spell by $namepart, and returns all matches with their spell ID's."
            },
            {
                text       = "lookup spell id",
                defaultEB  = "Enter Spell ID",
                command    = ".lookup spell id",
                tooltip    = "Syntax: .lookup spell id #spellid\n\n" ..
                             "Looks up a spell by #spellid, and returns the match with its spell name."
            },
            {
                text       = "lookup taxinode",
                defaultEB  = "Enter Taxinode Substring",
                command    = ".lookup taxinode",
                tooltip    = "Syntax: .lookup taxinode $substring\r\n\r\n" ..
                             "Search and output all taxinodes with provide $substring in name."
            },
            {
                text       = "lookup tele",
                defaultEB  = "Enter Teleport Substring",
                command    = ".lookup tele",
                tooltip    = "Syntax: .lookup tele $substring\r\n\r\n" ..
                             "Search and output all .tele command locations with provide $substring in name."
            },
            {
                text       = "lookup title",
                defaultEB  = "Enter Title Name Part",
                command    = ".lookup title",
                tooltip    = "Syntax: .lookup title $namepart\r\n\r\n" ..
                             "Looks up a title by $namepart, and returns all matches with their title ID's and index's."
            },
        }

        -------------------------------------------------------------------------
        -- 2) OPTIONS pour le second menu déroulant (2 champs + bouton)
        -------------------------------------------------------------------------
        local doubleOptions = {
            {
                text            = "lookup player ip",
                defaultEB1      = "Enter IP",
                defaultEB2      = "Limit",
                command         = ".lookup player ip",
                tooltip         = "Syntax: .lookup player ip $ip ($limit)\r\n\r\n" ..
                                  "Searchs players, whose account last_ip is $ip with optional param $limit of results."
            },
            {
                text            = "lookup player email",
                defaultEB1      = "Enter Email",
                defaultEB2      = "Limit",
                command         = ".lookup player email",
                tooltip         = "Syntax: .lookup player email $email ($limit)\r\n\r\n" ..
                                  "Searchs players, whose account email is $email with optional param $limit of results."
            },
            {
                text            = "lookup player account",
                defaultEB1      = "Enter a Username",
                defaultEB2      = "Limit",
                command         = ".lookup player account",
                tooltip         = "Syntax: .lookup player account $account ($limit)\r\n\r\n" ..
                                  "Searchs players, whose account username is $account with optional param $limit of results."
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
        btnSingleLookup:SetText("Lookup")
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
				print("Veuillez renseigner une valeur pour : " .. opt.text)
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
        btnDoubleLookup:SetText("Lookup")
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
				print("Veuillez renseigner une valeur pour : " .. opt.defaultEB1)
				return
			end
			if not val2 or val2 == "" or val2 == opt.defaultEB2 then
				print("Veuillez renseigner une valeur pour : " .. opt.defaultEB2)
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
        btnBack:SetText(TrinityAdmin_Translations["Back"])
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
        self.groupsPanel = CreateFrame("Frame", "TrinityAdminGroupsPanel", TrinityAdminMainFrame)
        self.groupsPanel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
        self.groupsPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.groupsPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.groupsPanel)
        bg:SetColorTexture(0.6, 0.4, 0.2, 0.7)  -- Couleur pour le panneau Groups Management
        
        self.groupsPanel.title = self.groupsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.groupsPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.groupsPanel.title:SetText("Groups Management")
        
        -- Ajoutez ici vos éléments et fonctions spécifiques à la gestion des groupes.
        
        local btnBack = CreateFrame("Button", nil, self.groupsPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.groupsPanel, "BOTTOM", 0, 10)
        btnBack:SetText(TrinityAdmin_Translations["Back"])
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
        self.questsPanel.title:SetText("Quests Management")

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
            btnAdd:SetText("Add Quest")
            btnAdd:SetSize(btnAdd:GetTextWidth() + 20, 22)
            btnAdd:SetPoint("LEFT", editQuestID, "RIGHT", 10, 0)

            btnAdd:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .quest add #quest_id\r\n\r\n" ..
                    "Add to character quest log quest #quest_id. " ..
                    "Quest started from item can’t be added by this command " ..
                    "but correct .additem call provided in command output.",
                    1,1,1,1,true
                )
            end)
            btnAdd:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btnAdd:SetScript("OnClick", function()
                local questID = editQuestID:GetText()
                if not questID or questID == "" or questID == "Quest ID" then
                    print("Veuillez renseigner un Quest ID valide.")
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
            btnComplete:SetText("Complete Quest")
            btnComplete:SetSize(btnComplete:GetTextWidth() + 20, 22)
            btnComplete:SetPoint("LEFT", editQuestID, "RIGHT", 10, 0)

            btnComplete:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .quest complete #questid\r\n" ..
                    "Mark all quest objectives as completed for target character active quest. " ..
                    "After this target character can go and get quest reward.",
                    1,1,1,1,true
                )
            end)
            btnComplete:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btnComplete:SetScript("OnClick", function()
                local questID = editQuestID:GetText()
                if not questID or questID == "" or questID == "Quest ID" then
                    print("Veuillez renseigner un Quest ID valide.")
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
            btnObjective:SetText("Complete Quest Objective")
            btnObjective:SetSize(btnObjective:GetTextWidth() + 20, 22)
            btnObjective:SetPoint("LEFT", editObjID, "RIGHT", 10, 0)

            btnObjective:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .quest objective complete #questObjectiveId\n" ..
                    "Mark specific quest objective as completed for target character.",
                    1,1,1,1,true
                )
            end)
            btnObjective:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btnObjective:SetScript("OnClick", function()
                local objID = editObjID:GetText()
                if not objID or objID == "" or objID == "Quest Objective ID" then
                    print("Veuillez renseigner un Quest Objective ID valide.")
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
            btnRemove:SetText("Remove Quest")
            btnRemove:SetSize(btnRemove:GetTextWidth() + 20, 22)
            btnRemove:SetPoint("LEFT", editQuestID, "RIGHT", 10, 0)

            btnRemove:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .quest remove #quest_id\r\n\r\n" ..
                    "Set quest #quest_id state to not completed and not active " ..
                    "(and remove from active quest list) for selected player.",
                    1,1,1,1,true
                )
            end)
            btnRemove:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btnRemove:SetScript("OnClick", function()
                local questID = editQuestID:GetText()
                if not questID or questID == "" or questID == "Quest ID" then
                    print("Veuillez renseigner un Quest ID valide.")
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
            btnReward:SetText("Reward Quest")
            btnReward:SetSize(btnReward:GetTextWidth() + 20, 22)
            btnReward:SetPoint("LEFT", editQuestID, "RIGHT", 10, 0)

            btnReward:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(
                    "Syntax: .quest reward #questId\n\n" ..
                    "Grants quest reward to selected player and removes quest from his log " ..
                    "(quest must be in completed state).",
                    1,1,1,1,true
                )
            end)
            btnReward:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btnReward:SetScript("OnClick", function()
                local questID = editQuestID:GetText()
                if not questID or questID == "" or questID == "Quest ID" then
                    print("Veuillez renseigner un Quest ID valide.")
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
        btnBack:SetText(TrinityAdmin_Translations["Back"])
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

