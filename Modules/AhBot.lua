local L = _G.L
local TrinityAdmin = LibStub("AceAddon-3.0"):GetAddon("TrinityAdmin")
local AhBot = TrinityAdmin:GetModule("AhBot")
local L = LibStub("AceLocale-3.0"):GetLocale("TrinityAdmin")

-- Fonction pour afficher le panneau AhBot
function AhBot:ShowAhBotPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAhBotPanel()
    end
    self.panel:Show()
end

-- Declaration des variables de capture
local capturingAHStatus = false
local ahStatusCollected = {}
local ahStatusTimer     = nil

-- Fame Ace 3
local function ShowAHStatusAceGUI(lines)
    local AceGUI = LibStub("AceGUI-3.0")

    local frame = AceGUI:Create("Frame")
    frame:SetTitle(".ahbot status output")
    frame:SetStatusText("Information from .ahbot status")
    frame:SetLayout("Flow")
    frame:SetWidth(600)
    frame:SetHeight(450)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    frame:AddChild(scroll)

    for i, line in ipairs(lines) do
        local edit = AceGUI:Create("EditBox")
        edit:SetLabel("Line " .. i)
        edit:SetText(line)
        edit:SetFullWidth(true)
        scroll:AddChild(edit)
    end

    local btnClose = AceGUI:Create("Button")
    btnClose:SetText("Fermer")
    btnClose:SetWidth(100)
    btnClose:SetCallback("OnClick", function() AceGUI:Release(frame) end)
    frame:AddChild(btnClose)
end

-- Ecoute du chat
local ahCaptureFrame = CreateFrame("Frame")
ahCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")          -- réponse classique

ahCaptureFrame:SetScript("OnEvent", function(_, _, msg)
    if not capturingAHStatus then return end

    -- Nettoyage rapide
    local clean = msg:gsub("|c%x%x%x%x%x%x%x%x","")
                   :gsub("|r","")
                   :gsub("|H.-|h(.-)|h","%1")
                   :gsub("|T.-|t","")
                   :gsub("\226[\148-\149][\128-\191]","")

    table.insert(ahStatusCollected, clean)
    if ahStatusTimer then ahStatusTimer:Cancel() end

    -- On attend 1 s sans nouveau message pour considérer la réponse finie
    ahStatusTimer = C_Timer.NewTimer(1, function()
        capturingAHStatus = false

        local lines = {}
        for line in table.concat(ahStatusCollected, "\n"):gmatch("[^\r\n]+") do
            table.insert(lines, line)
        end
        ShowAHStatusAceGUI(lines)
    end)
end)


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
    panel.title:SetText(L["AH Bot Control Panel"])
	
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
        pages[i].yOffset = 0
    end

    ----------------------------------------------------------------------------
    -- Fonction utilitaire pour créer une ligne dans une page
    ----------------------------------------------------------------------------
    local function CreateRow(page, height)
        local row = CreateFrame("Frame", nil, page)
        row:SetSize(contentContainer:GetWidth(), height)
        row:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -page.yOffset)
        page.yOffset = page.yOffset + height + 5 
        return row
    end

    ----------------------------------------------------------------------------
    -- Boutons de navigation de la pagination
    ----------------------------------------------------------------------------
    local currentPage = 1
    local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
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
    -- btnPrev:SetSize(80, 22)
    btnPrev:SetText(L["Pagination_Preview"])
	TrinityAdmin.AutoSize(btnPrev, 20, 16)
    btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            ShowPage(currentPage)
        end
    end)

    local btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnNext:SetSize(80, 22)
    btnNext:SetText(L["Next"])
	TrinityAdmin.AutoSize(btnNext, 20, 16)
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
            label:SetText(L["ahbot items Ammont"])
            local defaults = {"GrayItems", "WhiteItems", "GreenItems", "BlueItems", "PurpleItems", "OrangeItems", "YellowItems"}
            local edits = {}
            local fieldX = 0
            local width, spacing = 70, 10
			for i = 1, 7 do
				local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
				editBox:SetSize(width, 22)
				editBox:SetAutoFocus(false)
				editBox:SetText(defaults[i])
			
				if i == 1 then
					editBox:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -20)
				else
					-- ancre à droite de la précédente, avec 10px de marge
					editBox:SetPoint("LEFT", edits[i-1], "RIGHT", spacing, 0)
				end
			
				TrinityAdmin.AutoSize(editBox, 20, 13, nil, width)
				edits[i] = editBox
			end

            local btnSet = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            -- btnSet:SetSize(100, 22)
            -- btnSet:SetPoint("TOPLEFT", row, "TOPLEFT", fieldX, -20)
			btnSet:SetPoint("TOPLEFT", edits[4], "BOTTOMLEFT", 0, -10)
            btnSet:SetText(L["Set Amount"])
			TrinityAdmin.AutoSize(btnSet, 20, 16)
            local tooltipText = L["Set amount of each items color be selled on auction."]
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
                        TrinityAdmin:Print(L["All fields are required! Please fill them correctly."])
                        return
                    end
                    table.insert(values, val)
                end
                local fullCommand = ".ahbot items " .. table.concat(values, " ")
				-- === lancement de la capture ===
				ahStatusCollected = {}
				capturingAHStatus = true
				if ahStatusTimer then ahStatusTimer:Cancel() end
				-- ===============================					
                -- SendChatMessage(fullCommand, "SAY")
				TrinityAdmin:SendCommand(fullCommand)
                -- print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end

    -- 2) ahbot items <color> : Répartition sur 3 lignes

    -- On ajoute un espace de 40px sous le bouton Set Amount
    CreateRow(page, 40)

    -- 2) ahbot items <color> : Répartition sur 3 lignes
    local function CreateColorButtonsRow(page, colors)
        local row = CreateRow(page, 40)
        local prevBtn
        for i, color in ipairs(colors) do
            -- EditBox
            local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            -- editBox:SetSize(80, 22)
            if i == 1 then
                editBox:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -20)
            else
                -- Toujours 20px à droite du bouton précédent
                editBox:SetPoint("LEFT", prevBtn, "RIGHT", 15, 0)
            end
            editBox:SetAutoFocus(false)
            editBox:SetText(L["Amountahbot"])
			TrinityAdmin.AutoSize(editBox, 20, 13, nil, 80)

            -- Bouton « Add color… »
            local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            -- btn:SetSize(100, 22)

            btn:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
            btn:SetText(L["Add color"] .. color.name)
			TrinityAdmin.AutoSize(btn, 20, 16)

            -- Tooltip
            local tooltipText = string.format(
                L["ahbot_items_syntax_tooltip"],
                color.cmd, color.name, color.name
            )
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Clic
            btn:SetScript("OnClick", function()
                local val = editBox:GetText()
                if not val or val == "" or val == L["Amountahbot"] then
                    TrinityAdmin:Print(L["Please enter a valid amount for "] .. color.name .. ".")
                    return
                end
                local fullCommand = ".ahbot items " .. color.cmd .. " " .. val
				-- === lancement de la capture ===
				ahStatusCollected = {}
				capturingAHStatus = true
				if ahStatusTimer then ahStatusTimer:Cancel() end
				-- ===============================					
                -- SendChatMessage(fullCommand, "SAY")
				TrinityAdmin:SendCommand(fullCommand)
            end)

            -- On garde une référence au bouton pour positionner la prochaine EditBox
            prevBtn = btn
        end
    end

    -- Ligne 1 : Blue, Gray, Green
    CreateColorButtonsRow(page, {
        { name = "Blue",  cmd = "blue"  },
        { name = "Gray",  cmd = "gray"  },
        { name = "Green", cmd = "green" },
    })

    -- Ligne 2 : Orange, Purple, White
    CreateColorButtonsRow(page, {
        { name = "Orange", cmd = "orange" },
        { name = "Purple", cmd = "purple" },
        { name = "White",  cmd = "white"  },
    })

    -- Ligne 3 : Yellow seule
    CreateColorButtonsRow(page, {
        { name = "Yellow", cmd = "yellow" },
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
            label:SetText(L["ahbot ratio (3 values)"])
            local defaults = {"allianceratio", "horderatio", "neutralratio"}
            local edits = {}
            local fieldX = 0
            for i = 1, 3 do
                local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
                -- editBox:SetSize(100, 22)
                editBox:SetPoint("TOPLEFT", row, "TOPLEFT", fieldX, -20)
                editBox:SetAutoFocus(false)
                editBox:SetText(defaults[i])
				TrinityAdmin.AutoSize(editBox, 20, 13)
                edits[i] = editBox
                fieldX = fieldX + 110
            end
            local btnRatio = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            -- btnRatio:SetSize(100, 22)
            btnRatio:SetPoint("TOPLEFT", row, "TOPLEFT", fieldX, -20)
            btnRatio:SetText(L["Add Ratio"])
			TrinityAdmin.AutoSize(btnRatio, 20, 16)
            local tooltipText = L["Set ratio of items in 3 auctions house."]
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
                        TrinityAdmin:Print(L["All 3 ratio fields are required!"])
                        return
                    end
                    table.insert(values, val)
                end
                local fullCommand = ".ahbot ratio " .. table.concat(values, " ")
                SendChatMessage(fullCommand, "SAY")
                -- print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end

        -- 4) ahbot ratio <faction> : Pour alliance, horde et neutral
        local function CreateAhbotRatioFactionRow(factionName)
            local row = CreateRow(page, 40)
            local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            -- editBox:SetSize(80, 22)
            editBox:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -20)
            editBox:SetAutoFocus(false)
            editBox:SetText("Ratio")
			TrinityAdmin.AutoSize(editBox, 20, 13)
            local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            -- btn:SetSize(120, 22)
            btn:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
            btn:SetText("Set Ratio " .. factionName)
			TrinityAdmin.AutoSize(btn, 20, 16)
            -- local tooltipText = "Syntax: .ahbot ratio " .. factionName .. " $" .. factionName .. "ratio\r\n\r\nSet ratio of items in " .. factionName .. " auction house."
			local tooltipText = string.format(L["ahbot_ratio_syntax_tooltip"], factionName, factionName, factionName)
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btn:SetScript("OnClick", function()
                local val = editBox:GetText()
                if not val or val == "" or val == "Ratio" then
                    TrinityAdmin:Print(L["Please enter a valid ratio for "] .. factionName .. ".")
                    return
                end
                local fullCommand = ".ahbot ratio " .. factionName .. " " .. val			
                SendChatMessage(fullCommand, "SAY")
                -- print("[DEBUG] Commande envoyée: " .. fullCommand)
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
            -- editBox:SetSize(80, 22)
            editBox:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -20)
            editBox:SetAutoFocus(false)
            editBox:SetText("Option")
			TrinityAdmin.AutoSize(editBox, 20, 13)

            local btnRebuild = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            -- btnRebuild:SetSize(80, 22)
            btnRebuild:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
            btnRebuild:SetText(L["Rebuild"])
			TrinityAdmin.AutoSize(btnRebuild, 20, 16)

            local tooltipRebuild = L["Aution House Expire Tooltip"]
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
                -- print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end

        -- 6) ahbot status : Champ "Option" + bouton "AH Status"
        do
            local row = CreateRow(page, 40)
            local editBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            -- editBox:SetSize(80, 22)
            editBox:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -20)
            editBox:SetAutoFocus(false)
            editBox:SetText("Option")
			TrinityAdmin.AutoSize(editBox, 20, 13)

            local btnStatus = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            -- btnStatus:SetSize(80, 22)
            btnStatus:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
            btnStatus:SetText(L["AH Status"])
			TrinityAdmin.AutoSize(btnStatus, 20, 16)

            local tooltipStatus = L["Ah_Curent_Stat"]
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
				-- === lancement de la capture ===
				ahStatusCollected = {}
				capturingAHStatus = true
				if ahStatusTimer then ahStatusTimer:Cancel() end
				-- ===============================
                SendChatMessage(fullCommand, "SAY")
                -- print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end

        -- 7) ahbot reload : Bouton "Reload AH" seul
        do
            local row = CreateRow(page, 40)
            local btnReload = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            -- btnReload:SetSize(100, 22)
            btnReload:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -20)
            btnReload:SetText(L["Reload AH"])
			TrinityAdmin.AutoSize(btnReload, 20, 16)

            local tooltipReload = L["Reload AHBot settings from configuration file."]
            btnReload:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipReload, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btnReload:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btnReload:SetScript("OnClick", function()
                local fullCommand = ".ahbot reload"
				-- === lancement de la capture ===
				ahStatusCollected = {}
				capturingAHStatus = true
				if ahStatusTimer then ahStatusTimer:Cancel() end
				-- ===============================				
                SendChatMessage(fullCommand, "SAY")
                -- print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
        end
    end

    ShowPage(1)
	
	------------------------------------------------------------------------------
    -- Bouton Back final (commun aux pages)
    ------------------------------------------------------------------------------
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", navPageLabel, "CENTER", 0, 15)
    btnBack:SetText(L["Back"])
	TrinityAdmin.AutoSize(btnBack, 20, 16)
    -- btnBack:SetHeight(22)
    -- btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    -- On augmente le niveau pour qu'il apparaisse au-dessus des pages
    btnBack:SetFrameLevel(panel:GetFrameLevel() + 10)
    -- ou alternativement : btnBack:SetFrameStrata("HIGH")
    
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)
	
    self.panel = panel
end
