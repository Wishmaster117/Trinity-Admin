local Misc = TrinityAdmin:GetModule("Misc")

------------------------------------------------------------
-- Méthode pour ajouter les boutons de gestion sur le panneau principal
------------------------------------------------------------
function Misc:AddManagementButtons(panel)
    local btnTitles = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnTitles:SetSize(150, 22)
    btnTitles:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -40)
    btnTitles:SetText("Titles Management")
    btnTitles:SetScript("OnClick", function() self:OpenTitlesManagement() end)
    
    local btnResets = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnResets:SetSize(150, 22)
    btnResets:SetPoint("TOPLEFT", btnTitles, "BOTTOMLEFT", 0, -10)
    btnResets:SetText("Resets Management")
    btnResets:SetScript("OnClick", function() self:OpenResetsManagement() end)
    
    local btnArena = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnArena:SetSize(150, 22)
    btnArena:SetPoint("TOPLEFT", btnResets, "BOTTOMLEFT", 0, -10)
    btnArena:SetText("Arena Management")
    btnArena:SetScript("OnClick", function() self:OpenArenaManagement() end)
    
    local btnLookup = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnLookup:SetSize(150, 22)
    btnLookup:SetPoint("TOPLEFT", btnArena, "BOTTOMLEFT", 0, -10)
    btnLookup:SetText("Lookup Functions")
    btnLookup:SetScript("OnClick", function() self:OpenLookupFunctions() end)
    
    local btnGroups = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnGroups:SetSize(150, 22)
    btnGroups:SetPoint("TOPLEFT", btnLookup, "BOTTOMLEFT", 0, -10)
    btnGroups:SetText("Groups Management")
    btnGroups:SetScript("OnClick", function() self:OpenGroupsManagement() end)
    
    local btnQuests = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnQuests:SetSize(150, 22)
    btnQuests:SetPoint("TOPLEFT", btnGroups, "BOTTOMLEFT", 0, -10)
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
    
    -- Ajoute les boutons de gestion (la méthode est maintenant bien définie)
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
-- Implémentation du panneau Titles Management
------------------------------------------------------------
function Misc:OpenTitlesManagement()
    if self.panel then
        self.panel:Hide()
    end
    if not self.titlesPanel then
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
        -- (1) Variables locales pour la pagination, checkboxes, etc.
        ------------------------------------------------------------
        local entriesPerPage = 10
        local currentPage = 1
        local currentOptions = {}  -- la liste courante (filtrée ou non)

        -- Checkboxes et champ de saisie
        local chkAdd, chkRemove, chkCurrent
        local editMask, btnSetMask

        ------------------------------------------------------------
        -- (2) Création du champ de saisie filtrage + scrollFrame
        ------------------------------------------------------------
        local filterEditBox = CreateFrame("EditBox", nil, self.titlesPanel, "InputBoxTemplate")
        filterEditBox:SetSize(150, 22)
        filterEditBox:SetPoint("TOPLEFT", self.titlesPanel, "TOPLEFT", 10, -40)
        filterEditBox:SetText("Search...")
        filterEditBox:SetAutoFocus(false)
        filterEditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        
        local scrollFrame = CreateFrame("ScrollFrame", nil, self.titlesPanel, "UIPanelScrollFrameTemplate")
        scrollFrame:SetSize(220, 200)
        scrollFrame:SetPoint("TOPLEFT", filterEditBox, "BOTTOMLEFT", 0, -5)
        scrollFrame:SetPoint("BOTTOMLEFT", self.titlesPanel, "BOTTOMLEFT", 10, 50)

        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(220, 400) -- hauteur ajustée dynamiquement
        scrollFrame:SetScrollChild(scrollChild)

        ------------------------------------------------------------
        -- Boutons de pagination (Preview, Next, Page Label)
        ------------------------------------------------------------
        local btnPage = CreateFrame("Button", nil, self.titlesPanel, "UIPanelButtonTemplate")
        btnPage:SetSize(90, 22)
        btnPage:SetPoint("BOTTOMRIGHT", self.titlesPanel, "BOTTOM", -160, 10)
        btnPage:SetText("Page 1 / 1")

        local btnPrev = CreateFrame("Button", nil, self.titlesPanel, "UIPanelButtonTemplate")
        btnPrev:SetSize(80, 22)
        btnPrev:SetText("Preview")
        btnPrev:SetPoint("RIGHT", btnPage, "LEFT", -5, 0)

        local btnNext = CreateFrame("Button", nil, self.titlesPanel, "UIPanelButtonTemplate")
        btnNext:SetSize(80, 22)
        btnNext:SetText("Next")
        btnNext:SetPoint("LEFT", btnPage, "RIGHT", 5, 0)

        ------------------------------------------------------------
        -- (2 bis) Création du conteneur d'options (cases à cocher)
        ------------------------------------------------------------
        local optionsFrame = CreateFrame("Frame", nil, self.titlesPanel)
        optionsFrame:SetSize(200, 150) 
        optionsFrame:SetPoint("RIGHT", self.titlesPanel, "RIGHT", -100, 0)
        optionsFrame:SetPoint("CENTER", self.titlesPanel, "CENTER", -self.titlesPanel:GetWidth()/4, 0)

        -- chkAdd
        chkAdd = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
        chkAdd:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 0, -10)
        chkAdd.text = chkAdd:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chkAdd.text:SetPoint("LEFT", chkAdd, "RIGHT", 5, 0)
        chkAdd.text:SetText("Add a Title")
		chkAdd:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Syntax: .titles add #title\r\nAdd title #title (id or shift-link) to known titles list for selected player.", 1, 1, 1, 1, true)
		end)
		chkAdd:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)

        -- chkRemove
        chkRemove = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
        chkRemove:SetPoint("TOPLEFT", chkAdd, "BOTTOMLEFT", 0, -10)
        chkRemove.text = chkRemove:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chkRemove.text:SetPoint("LEFT", chkRemove, "RIGHT", 5, 0)
        chkRemove.text:SetText("Remove a Title")
		chkRemove:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Syntax: .titles remove #title\r\nRemove title #title (id or shift-link) from known titles list for selected player.", 1, 1, 1, 1, true)
		end)
		chkRemove:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)		

        -- chkCurrent
        chkCurrent = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
        chkCurrent:SetPoint("TOPLEFT", chkRemove, "BOTTOMLEFT", 0, -10)
        chkCurrent.text = chkCurrent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chkCurrent.text:SetPoint("LEFT", chkCurrent, "RIGHT", 5, 0)
        chkCurrent.text:SetText("Set Title as Current")
		chkCurrent:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Syntax: .titles current #title\r\nSet title #title (id or shift-link) as current selected title for selected player. If title is not in known title list for player then it will be added to list.", 1, 1, 1, 1, true)
		end)
		chkCurrent:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)				

        -- editMask et btnSetMask
        editMask = CreateFrame("EditBox", nil, optionsFrame, "InputBoxTemplate")
        editMask:SetSize(100, 22)
        editMask:SetPoint("TOPLEFT", chkCurrent, "BOTTOMLEFT", 0, -10)
        editMask:SetText("Set titles mask")

        btnSetMask = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
        btnSetMask:SetSize(80, 22)
        btnSetMask:SetPoint("LEFT", editMask, "RIGHT", 5, 0)
        btnSetMask:SetText("Set")
		btnSetMask:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Syntax: .titles set mask #mask\r\n\r\nAllows user to use all titles from #mask.\r\n\r\n #mask=0 disables the title-choose-field", 1, 1, 1, 1, true)
		end)
		btnSetMask:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)		

        ------------------------------------------------------------
        -- Scripts OnClick pour les checkboxes + bouton Set
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
        -- (3) Déclaration de la fonction PopulateTitlescroll
        ------------------------------------------------------------
        local function PopulateTitlescroll(options)
            currentOptions = options

            local totalEntries = #options
            local totalPages = math.ceil(totalEntries / entriesPerPage)
            if totalPages < 1 then totalPages = 1 end

            if currentPage > totalPages then currentPage = totalPages end
            if currentPage < 1 then currentPage = 1 end

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

                local fullText = option.name or ("Item " .. i)
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

                -- ICI : on utilise chkAdd/chkRemove/chkCurrent sans erreur,
                -- car ils sont déjà déclarés dans cette portée.
                btn:SetScript("OnClick", function()
                    local targetName = UnitName("target")
                    if not targetName then
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

            local visibleCount = endIdx - startIdx + 1
            local contentHeight = (visibleCount * 25) + 10
            scrollChild:SetHeight(contentHeight)

            btnPage:SetText(currentPage .. " / " .. totalPages)
            btnPrev:SetEnabled(currentPage > 1)
            btnNext:SetEnabled(currentPage < totalPages)
        end

        ------------------------------------------------------------
        -- (4) Scripts pour la pagination, filtre, etc.
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
                PopulateTitlesscroll(filteredOptions)
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
            PopulateTitlesscroll(TitlesData)
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
        self.resetsPanel = CreateFrame("Frame", "TrinityAdminResetsPanel", TrinityAdminMainFrame)
        self.resetsPanel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
        self.resetsPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.resetsPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.resetsPanel)
        bg:SetColorTexture(0.4, 0.2, 0.2, 0.7)
        
        self.resetsPanel.title = self.resetsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.resetsPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.resetsPanel.title:SetText("Resets Management")
        
        -- Ajoutez ici vos éléments et fonctions spécifiques à la gestion des resets.
        
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
        self.arenaPanel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
        self.arenaPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.arenaPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.arenaPanel)
        bg:SetColorTexture(0.2, 0.5, 0.2, 0.7)  -- Couleur pour le panneau Arena Management
        
        self.arenaPanel.title = self.arenaPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.arenaPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.arenaPanel.title:SetText("Arena Management")
        
        -- Ajoutez ici vos éléments et fonctions spécifiques à la gestion des arènes.
        
        local btnBack = CreateFrame("Button", nil, self.arenaPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.arenaPanel, "BOTTOM", 0, 10)
        btnBack:SetText(TrinityAdmin_Translations["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
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
        self.lookupPanel = CreateFrame("Frame", "TrinityAdminLookupPanel", TrinityAdminMainFrame)
        self.lookupPanel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
        self.lookupPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.lookupPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.lookupPanel)
        bg:SetColorTexture(0.5, 0.5, 0.2, 0.7)  -- Couleur pour le panneau Lookup Functions
        
        self.lookupPanel.title = self.lookupPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.lookupPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.lookupPanel.title:SetText("Lookup Functions")
        
        -- Ajoutez ici vos éléments et fonctions spécifiques à la gestion des lookup.
        
        local btnBack = CreateFrame("Button", nil, self.lookupPanel, "UIPanelButtonTemplate")
        btnBack:SetPoint("BOTTOM", self.lookupPanel, "BOTTOM", 0, 10)
        btnBack:SetText(TrinityAdmin_Translations["Back"])
        btnBack:SetHeight(22)
        btnBack:SetWidth(btnBack:GetTextWidth() + 20)
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
        self.questsPanel = CreateFrame("Frame", "TrinityAdminQuestsPanel", TrinityAdminMainFrame)
        self.questsPanel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
        self.questsPanel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
        
        local bg = self.questsPanel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(self.questsPanel)
        bg:SetColorTexture(0.2, 0.2, 0.2, 0.7)  -- Couleur pour le panneau Quests Management
        
        self.questsPanel.title = self.questsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.questsPanel.title:SetPoint("TOPLEFT", 10, -10)
        self.questsPanel.title:SetText("Quests Management")
        
        -- Ajoutez ici vos éléments et fonctions spécifiques à la gestion des quêtes.
        
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
