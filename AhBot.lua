local AhBot = TrinityAdmin:GetModule("AhBot")

-- Fonction pour afficher le panneau AhBot
function AhBot:ShowAhBotPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAhBotPanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau AhBot avec pagination sur 3 pages
function AhBot:CreateAhBotPanel()
    local panel = CreateFrame("Frame", "TrinityAhBotPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("AH Bot Control Panel")

    -- Bouton Retour commun
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetSize(btnBack:GetTextWidth() + 20, 22)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    ----------------------------------------------------------------------------
    -- Conteneur principal pour les pages
    ----------------------------------------------------------------------------
    local contentContainer = CreateFrame("Frame", nil, panel)
    contentContainer:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)
    contentContainer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 40)

    local totalPages = 3
    local pages = {}
    for i = 1, totalPages do
        pages[i] = CreateFrame("Frame", nil, contentContainer)
        pages[i]:SetAllPoints(contentContainer)
        pages[i]:Hide()
        pages[i].yOffset = 0  -- pour placer les éléments verticalement
    end

    ----------------------------------------------------------------------------
    -- Fonction utilitaire pour créer une ligne dans une page
    ----------------------------------------------------------------------------
    local function CreateRow(page, height)
        local row = CreateFrame("Frame", nil, page)
        row:SetSize(contentContainer:GetWidth(), height)
        row:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -page.yOffset)
        page.yOffset = page.yOffset + height + 5  -- espace de 5 pixels entre les lignes
        return row
    end

    ----------------------------------------------------------------------------
    -- Boutons de navigation de la pagination
    ----------------------------------------------------------------------------
    local currentPage = 1
    local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 35)
    navPageLabel:SetText("Page 1 / " .. totalPages)

    local function ShowPage(pageIndex)
        for i = 1, totalPages do
            if i == pageIndex then
                pages[i]:Show()
            else
                pages[i]:Hide()
            end
        end
        navPageLabel:SetText("Page " .. pageIndex .. " / " .. totalPages)
    end

    local btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnPrev:SetSize(80, 22)
    btnPrev:SetText("Précédent")
    btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            ShowPage(currentPage)
        end
    end)

    local btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnNext:SetSize(80, 22)
    btnNext:SetText("Suivant")
    btnNext:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
    btnNext:SetScript("OnClick", function()
        if currentPage < totalPages then
            currentPage = currentPage + 1
            ShowPage(currentPage)
        end
    end)

    ----------------------------------------------------------------------------
    -- PAGE 1
    ----------------------------------------------------------------------------
    do
        local page = pages[1]

        -- 1) ahbot items : 7 champs + bouton "Set Amount"
        do
            local row = CreateRow(page, 40)
            local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            label:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
            label:SetText("ahbot items (Set 7 colors)")
            local defaults = {"GrayItems", "WhiteItems", "GreenItems", "BlueItems", "PurpleItems", "OrangeItems", "YellowItems"}
            local edits = {}
            local fieldX = 0
            for i = 1, 7 do
                local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
                editBox:SetSize(80, 22)
                editBox:SetPoint("TOPLEFT", row, "TOPLEFT", fieldX, -20)
                editBox:SetAutoFocus(false)
                editBox:SetText(defaults[i])
                edits[i] = editBox
                fieldX = fieldX + 85
            end

            local btnSet = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnSet:SetSize(100, 22)
            btnSet:SetPoint("TOPLEFT", row, "TOPLEFT", fieldX, -20)
            btnSet:SetText("Set Amount")
            local tooltipText = "Syntax: .ahbot items $GrayItems $WhiteItems $GreenItems $BlueItems $PurpleItems $OrangeItems $YellowItems\r\n\r\nSet amount of each items color be selled on auction."
            btnSet:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnSet:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btnSet:SetScript("OnClick", function()
                local values = {}
                for i = 1, 7 do
                    local val = edits[i]:GetText()
                    if not val or val == "" or val == defaults[i] then
                        print("All fields are mandatory! Please fill them correctly.")
                        return
                    end
                    table.insert(values, val)
                end
                local fullCommand = ".ahbot items " .. table.concat(values, " ")
                SendChatMessage(fullCommand, "SAY")
                print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end

        -- 2) ahbot items <color> : Répartition sur 3 lignes
        local function CreateColorButtonsRow(page, colors)
            local row = CreateRow(page, 40)
            local xOffset = 0
            for i, color in ipairs(colors) do
                local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
                editBox:SetSize(80, 22)
                editBox:SetPoint("TOPLEFT", row, "TOPLEFT", xOffset, -20)
                editBox:SetAutoFocus(false)
                editBox:SetText("Amount")
                
                local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                btn:SetSize(100, 22)
                btn:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
                btn:SetText("Add " .. color.name)
                
                local tooltipText = "Syntax: .ahbot items " .. color.cmd .. " $" .. color.name .. "Items\r\n\r\nSet amount of " .. color.name .. " color items be selled on auction."
                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
                    GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                btn:SetScript("OnClick", function()
                    local val = editBox:GetText()
                    if not val or val == "" or val == "Amount" then
                        print("Please enter a valid amount for " .. color.name .. ".")
                        return
                    end
                    local fullCommand = ".ahbot items " .. color.cmd .. " " .. val
                    SendChatMessage(fullCommand, "SAY")
                    print("[DEBUG] Commande envoyée: " .. fullCommand)
                end)
                xOffset = xOffset + 80 + 10 + 100 + 20
            end
        end

        -- Ligne 1 : Blue, Gray, Green
        CreateColorButtonsRow(page, {
            { name = "Blue",    cmd = "blue" },
            { name = "Gray",    cmd = "gray" },
            { name = "Green",   cmd = "green" },
        })
        -- Ligne 2 : Orange, Purple, White
        CreateColorButtonsRow(page, {
            { name = "Orange",  cmd = "orange" },
            { name = "Purple",  cmd = "purple" },
            { name = "White",   cmd = "white" },
        })
        -- Ligne 3 : Yellow seule
        CreateColorButtonsRow(page, {
            { name = "Yellow",  cmd = "yellow" },
        })
    end

    ----------------------------------------------------------------------------
    -- PAGE 2
    ----------------------------------------------------------------------------
    do
        local page = pages[2]
        -- 3) ahbot ratio : 3 champs + bouton "Add Ratio"
        do
            local row = CreateRow(page, 40)
            local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            label:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
            label:SetText("ahbot ratio (3 values)")
            local defaults = {"allianceratio", "horderatio", "neutralratio"}
            local edits = {}
            local fieldX = 0
            for i = 1, 3 do
                local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
                editBox:SetSize(100, 22)
                editBox:SetPoint("TOPLEFT", row, "TOPLEFT", fieldX, -20)
                editBox:SetAutoFocus(false)
                editBox:SetText(defaults[i])
                edits[i] = editBox
                fieldX = fieldX + 110
            end
            local btnRatio = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnRatio:SetSize(100, 22)
            btnRatio:SetPoint("TOPLEFT", row, "TOPLEFT", fieldX, -20)
            btnRatio:SetText("Add Ratio")
            local tooltipText = "Syntax: .ahbot ratio $allianceratio $horderatio $neutralratio\r\n\r\nSet ratio of items in 3 auctions house."
            btnRatio:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnRatio:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btnRatio:SetScript("OnClick", function()
                local values = {}
                for i = 1, 3 do
                    local val = edits[i]:GetText()
                    if not val or val == "" or val == defaults[i] then
                        print("All 3 ratio fields are mandatory!")
                        return
                    end
                    table.insert(values, val)
                end
                local fullCommand = ".ahbot ratio " .. table.concat(values, " ")
                SendChatMessage(fullCommand, "SAY")
                print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end

        -- 4) ahbot ratio <faction> : Pour alliance, horde et neutral
        local function CreateAhbotRatioFactionRow(factionName)
            local row = CreateRow(page, 40)
            local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            editBox:SetSize(80, 22)
            editBox:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -20)
            editBox:SetAutoFocus(false)
            editBox:SetText("Ratio")
            local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btn:SetSize(120, 22)
            btn:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
            btn:SetText("Set Ratio " .. factionName)
            local tooltipText = "Syntax: .ahbot ratio " .. factionName .. " $" .. factionName .. "ratio\r\n\r\nSet ratio of items in " .. factionName .. " auction house."
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btn:SetScript("OnClick", function()
                local val = editBox:GetText()
                if not val or val == "" or val == "Ratio" then
                    print("Please enter a valid ratio for " .. factionName .. ".")
                    return
                end
                local fullCommand = ".ahbot ratio " .. factionName .. " " .. val
                SendChatMessage(fullCommand, "SAY")
                print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end

        CreateAhbotRatioFactionRow("alliance")
        CreateAhbotRatioFactionRow("horde")
        CreateAhbotRatioFactionRow("neutral")
    end

    ----------------------------------------------------------------------------
    -- PAGE 3
    ----------------------------------------------------------------------------
    do
        local page = pages[3]

        -- 5) ahbot rebuild : Champ "Option" + bouton "Rebuild"
        do
            local row = CreateRow(page, 40)
            local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            editBox:SetSize(80, 22)
            editBox:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -20)
            editBox:SetAutoFocus(false)
            editBox:SetText("Option")

            local btnRebuild = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnRebuild:SetSize(80, 22)
            btnRebuild:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
            btnRebuild:SetText("Rebuild")

            local tooltipRebuild = "Syntax: .ahbot rebuild [all]\r\n\r\nExpire all actual auction of ahbot except bided by player. Binded auctions included to expire if \"all\" option used. Ahbot re-fill auctions base at current settings then."
            btnRebuild:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipRebuild, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnRebuild:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btnRebuild:SetScript("OnClick", function()
                local val = editBox:GetText()
                local fullCommand = ".ahbot rebuild"
                if val and val ~= "" and val ~= "Option" then
                    fullCommand = fullCommand .. " " .. val
                end
                SendChatMessage(fullCommand, "SAY")
                print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end

        -- 6) ahbot status : Champ "Option" + bouton "AH Status"
        do
            local row = CreateRow(page, 40)
            local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            editBox:SetSize(80, 22)
            editBox:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -20)
            editBox:SetAutoFocus(false)
            editBox:SetText("Option")

            local btnStatus = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnStatus:SetSize(80, 22)
            btnStatus:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
            btnStatus:SetText("AH Status")

            local tooltipStatus = "Syntax: .ahbot status [all]\r\n\r\nShow current ahbot state data in short form, and with \"all\" with details."
            btnStatus:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipStatus, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnStatus:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btnStatus:SetScript("OnClick", function()
                local val = editBox:GetText()
                local fullCommand = ".ahbot status"
                if val and val ~= "" and val ~= "Option" then
                    fullCommand = fullCommand .. " " .. val
                end
                SendChatMessage(fullCommand, "SAY")
                print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end

        -- 7) ahbot reload : Bouton "Reload AH" seul
        do
            local row = CreateRow(page, 40)
            local btnReload = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btnReload:SetSize(100, 22)
            btnReload:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -20)
            btnReload:SetText("Reload AH")

            local tooltipReload = "Syntax: .ahbot reload\r\n\r\nReload AHBot settings from configuration file."
            btnReload:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipReload, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnReload:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btnReload:SetScript("OnClick", function()
                local fullCommand = ".ahbot reload"
                SendChatMessage(fullCommand, "SAY")
                print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end
    end

    ShowPage(1)
    self.panel = panel
end
