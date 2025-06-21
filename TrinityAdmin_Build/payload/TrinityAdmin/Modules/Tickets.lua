local L = _G.L
local TrinityAdmin = LibStub("AceAddon-3.0"):GetAddon("TrinityAdmin")
local Tickets = TrinityAdmin:GetModule("Tickets")
local L = LibStub("AceLocale-3.0"):GetLocale("TrinityAdmin")

-------------------------------------------------
-- Fonction pour afficher le panneau Tickets
-------------------------------------------------
function Tickets:ShowTicketsPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateTicketsPanel()
    end
    self.panel:Show()
end

-------------------------------------------------
-- Fonction pour créer le panneau Tickets
-------------------------------------------------
function Tickets:CreateTicketsPanel()
    local panel = CreateFrame("Frame", "TrinityAdminTicketsPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(L["T_management"])

    -------------------------------------------------------------------------------
    -- Nous allons créer 7 pages au total
    -------------------------------------------------------------------------------
    local totalPages = 7
    local pages = {}
    for i = 1, totalPages do
        pages[i] = CreateFrame("Frame", nil, panel)
        pages[i]:SetAllPoints(panel)
        pages[i]:Hide()
    end

    local currentPage = 1

    -- Label de navigation (ex: "Page 1 / 7")
    local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
    navPageLabel:SetText("Page 1 / " .. totalPages)

	-- 1) forward-déclarez les boutons pour qu’ils soient visibles dans ShowPage
	local btnPrev, btnNext

    local function ShowPage(pageIndex)
        currentPage = pageIndex
        for i = 1, totalPages do
            if i == pageIndex then
                pages[i]:Show()
            else
                pages[i]:Hide()
            end
        end
        navPageLabel:SetText("Page " .. pageIndex .. " / " .. totalPages)
		
		-- 2) active/désactive les boutons selon la page
		if pageIndex <= 1 then
			btnPrev:Disable()
		else
			btnPrev:Enable()
		end
		
		if pageIndex >= totalPages then
			btnNext:Disable()
		else
			btnNext:Enable()
		end

    end

    -- Bouton Précédent
    -- local btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnPrev:SetText(L["Pagination_Preview"])
	TrinityAdmin.AutoSize(btnPrev, 20, 16)
    btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            ShowPage(currentPage - 1)
        end
    end)

    -- Bouton Suivant
    -- local btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnNext:SetSize(80, 22)
    btnNext:SetText(L["Next"])
	TrinityAdmin.AutoSize(btnNext, 20, 16)
    btnNext:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
    btnNext:SetScript("OnClick", function()
        if currentPage < totalPages then
            ShowPage(currentPage + 1)
        end
    end)
	
	-- 4) enfin, initialisez bien l’état des boutons
    ShowPage(currentPage)

    ----------------------------------------------------------------------------
    -- Fonctions utilitaires pour ajouter des lignes de commande
    ----------------------------------------------------------------------------
    local function AddTwoParamCommandRow(parent, commandLabel, defaultParam1, defaultParam2, commandPrefix)
        local row = CreateFrame("Frame", nil, parent)
        row:SetSize(500, 30)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -parent.rowOffset)
        parent.rowOffset = parent.rowOffset + 35

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
        label:SetText(commandLabel)

        local edit1 = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        -- edit1:SetSize(80, 22)
        edit1:SetPoint("LEFT", label, "RIGHT", 10, 0)
        edit1:SetAutoFocus(false)
        edit1:SetText(defaultParam1)
		TrinityAdmin.AutoSize(edit1, 20, 13, nil, 80)

        local edit2 = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        -- edit2:SetSize(120, 22)
        edit2:SetPoint("LEFT", edit1, "RIGHT", 10, 0)
        edit2:SetAutoFocus(false)
        edit2:SetText(defaultParam2)
		TrinityAdmin.AutoSize(edit2, 20, 13, nil, 120)

        local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        -- btn:SetSize(60, 22) -- Enlevé pour resize auto
        btn:SetPoint("LEFT", edit2, "RIGHT", 10, 0)
        btn:SetText(L["Send"])
		TrinityAdmin.AutoSize(btn, 20, 16)
        btn:SetScript("OnClick", function()
            local param1 = edit1:GetText()
            local param2 = edit2:GetText()
            if not param1 or param1 == "" or param1 == defaultParam1 then
                TrinityAdmin:Print(L["enter_first_param"] .. commandLabel)
                return
            end
            if not param2 or param2 == "" or param2 == defaultParam2 then
                TrinityAdmin:Print(L["enter second param"] .. commandLabel)
                return
            end
            local fullCommand = commandPrefix .. " " .. param1 .. " " .. param2
            TrinityAdmin:SendCommand(fullCommand)
            -- TrinityAdmin:Print("[DEBUG] Commande envoyée: " .. fullCommand)
        end)
    end

    local function AddOneParamCommandRow(parent, commandLabel, defaultParam, commandPrefix)
        local row = CreateFrame("Frame", nil, parent)
        row:SetSize(500, 30)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -parent.rowOffset)
        parent.rowOffset = parent.rowOffset + 35

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
        label:SetText(commandLabel)

        local edit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        -- edit:SetSize(80, 22)
        edit:SetPoint("LEFT", label, "RIGHT", 10, 0)
        edit:SetAutoFocus(false)
        edit:SetText(defaultParam)
		TrinityAdmin.AutoSize(edit, 20, 13, nil, 80)

        local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        -- btn:SetSize(60, 22)
        btn:SetPoint("LEFT", edit, "RIGHT", 10, 0)
        btn:SetText(L["Send"])
		TrinityAdmin.AutoSize(btn, 20, 16)
        btn:SetScript("OnClick", function()
            local param = edit:GetText()
            if not param or param == "" or param == defaultParam then
                TrinityAdmin:Print(L["please enter value for"] .. commandLabel)
                return
            end
            local fullCommand = commandPrefix .. " " .. param
            TrinityAdmin:SendCommand(fullCommand)
            -- TrinityAdmin:Print("[DEBUG] Commande envoyée: " .. fullCommand)
        end)
    end

    local function AddNoParamCommandRow(parent, commandLabel, commandPrefix)
        local row = CreateFrame("Frame", nil, parent)
        row:SetSize(500, 30)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -parent.rowOffset)
        parent.rowOffset = parent.rowOffset + 35

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
        label:SetText(commandLabel)

        local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btn:SetPoint("LEFT", label, "RIGHT", 10, 0)
        btn:SetText(L["Send"])
		TrinityAdmin.AutoSize(btn, 20, 16)
        btn:SetScript("OnClick", function()
            -- SendChatMessage(commandPrefix, "SAY")
			TrinityAdmin:SendCommand(commandPrefix)
            -- TrinityAdmin:Print("[DEBUG] Commande envoyée: " .. commandPrefix)
        end)
    end

    -------------------------------------------------------------
    -- PAGE 1 : Bug Tickets (1/2)
    -------------------------------------------------------------
    local page1 = pages[1]
    local frameBug1 = CreateFrame("Frame", nil, page1)
    frameBug1:SetPoint("TOPLEFT", page1, "TOPLEFT", 20, -40)
    frameBug1:SetSize(500, 300)
    frameBug1.rowOffset = 0

    local titleBug1 = frameBug1:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleBug1:SetPoint("TOPLEFT", frameBug1, "TOPLEFT", 0, 0)
    titleBug1:SetText(L["bug tickets page1"])
    frameBug1.rowOffset = frameBug1.rowOffset + 35

    AddTwoParamCommandRow(frameBug1, L["Ticket Bug Assign"], L["TicketID"], L["GMName"], ".ticket bug assign")
    AddOneParamCommandRow(frameBug1, L["Ticket Bug Close"], L["TicketID"], ".ticket bug close")
    AddNoParamCommandRow(frameBug1, L["Ticket Bug ClosedList"], ".ticket bug closedlist")
    AddTwoParamCommandRow(frameBug1, L["Ticket Bug Comment"], L["TicketID"], L["Comment"], ".ticket bug comment")

    -------------------------------------------------------------
    -- PAGE 2 : Bug Tickets (2/2)
    -------------------------------------------------------------
    local page2 = pages[2]
    local frameBug2 = CreateFrame("Frame", nil, page2)
    frameBug2:SetPoint("TOPLEFT", page2, "TOPLEFT", 20, -40)
    frameBug2:SetSize(500, 300)
    frameBug2.rowOffset = 0

    local titleBug2 = frameBug2:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleBug2:SetPoint("TOPLEFT", frameBug2, "TOPLEFT", 0, 0)
    titleBug2:SetText(L["bug tickets page2"])
    frameBug2.rowOffset = frameBug2.rowOffset + 35

    AddOneParamCommandRow(frameBug2, L["Ticket Bug Delete"], L["TicketID"], ".ticket bug delete")
    AddNoParamCommandRow(frameBug2, L["Ticket Bug List"], ".ticket bug list")
    AddOneParamCommandRow(frameBug2, L["Ticket Bug Unassign"], L["TicketID"], ".ticket bug unassign")
    AddOneParamCommandRow(frameBug2, L["Ticket Bug View"], L["TicketID"], ".ticket bug view")

    -------------------------------------------------------------
    -- PAGE 3 : Complaint Tickets (1/2)
    -------------------------------------------------------------
    local page3 = pages[3]
    local frameComplaint1 = CreateFrame("Frame", nil, page3)
    frameComplaint1:SetPoint("TOPLEFT", page3, "TOPLEFT", 20, -40)
    frameComplaint1:SetSize(500, 300)
    frameComplaint1.rowOffset = 0

    local titleComplaint1 = frameComplaint1:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleComplaint1:SetPoint("TOPLEFT", frameComplaint1, "TOPLEFT", 0, 0)
    titleComplaint1:SetText(L["Complaint Tickets (1/2)"])
    frameComplaint1.rowOffset = frameComplaint1.rowOffset + 35

    AddTwoParamCommandRow(frameComplaint1, L["Ticket Complaint Assign"], L["TicketID"], L["GMName"], ".ticket complaint assign")
    AddOneParamCommandRow(frameComplaint1, L["Ticket Complaint Close"], L["TicketID"], ".ticket complaint close")
    AddNoParamCommandRow(frameComplaint1, L["Ticket Complaint ClosedList"], ".ticket complaint closedlist")
    AddTwoParamCommandRow(frameComplaint1, L["Ticket Complaint Comment"], L["TicketID"], L["TComment"], ".ticket complaint comment")

    -------------------------------------------------------------
    -- PAGE 4 : Complaint Tickets (2/2)
    -------------------------------------------------------------
    local page4 = pages[4]
    local frameComplaint2 = CreateFrame("Frame", nil, page4)
    frameComplaint2:SetPoint("TOPLEFT", page4, "TOPLEFT", 20, -40)
    frameComplaint2:SetSize(500, 300)
    frameComplaint2.rowOffset = 0

    local titleComplaint2 = frameComplaint2:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleComplaint2:SetPoint("TOPLEFT", frameComplaint2, "TOPLEFT", 0, 0)
    titleComplaint2:SetText(L["Complaint Tickets (2/2)"])
    frameComplaint2.rowOffset = frameComplaint2.rowOffset + 35

    AddOneParamCommandRow(frameComplaint2, L["Ticket Complaint Delete"], L["TicketID"], ".ticket complaint delete")
    AddNoParamCommandRow(frameComplaint2, L["Ticket Complaint List"], ".ticket complaint list")
    AddOneParamCommandRow(frameComplaint2, L["Ticket Complaint Unassign"], L["TicketID"], ".ticket complaint unassign")
    AddOneParamCommandRow(frameComplaint2, L["Ticket Complaint View"], L["TicketID"], ".ticket complaint view")

    -------------------------------------------------------------
    -- PAGE 5 : Suggestion Tickets (1/2)
    -------------------------------------------------------------
    local page5 = pages[5]
    local frameSuggestion1 = CreateFrame("Frame", nil, page5)
    frameSuggestion1:SetPoint("TOPLEFT", page5, "TOPLEFT", 20, -40)
    frameSuggestion1:SetSize(500, 300)
    frameSuggestion1.rowOffset = 0

    local titleSuggestion1 = frameSuggestion1:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleSuggestion1:SetPoint("TOPLEFT", frameSuggestion1, "TOPLEFT", 0, 0)
    titleSuggestion1:SetText(L["Suggestion Tickets (1/2)"])
    frameSuggestion1.rowOffset = frameSuggestion1.rowOffset + 35

    AddTwoParamCommandRow(frameSuggestion1, L["Ticket Suggestion Assign"], L["TicketID"], L["GMName"], ".ticket suggestion assign")
    AddOneParamCommandRow(frameSuggestion1, L["Ticket Suggestion Close"], L["TicketID"], ".ticket suggestion close")
    AddNoParamCommandRow(frameSuggestion1, L["Ticket Suggestion ClosedList"], ".ticket suggestion closedlist")
    AddTwoParamCommandRow(frameSuggestion1, L["Ticket Suggestion Comment"], L["TicketID"], L["TComment"], ".ticket suggestion comment")

    -------------------------------------------------------------
    -- PAGE 6 : Suggestion Tickets (2/2)
    -------------------------------------------------------------
    local page6 = pages[6]
    local frameSuggestion2 = CreateFrame("Frame", nil, page6)
    frameSuggestion2:SetPoint("TOPLEFT", page6, "TOPLEFT", 20, -40)
    frameSuggestion2:SetSize(500, 300)
    frameSuggestion2.rowOffset = 0

    local titleSuggestion2 = frameSuggestion2:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleSuggestion2:SetPoint("TOPLEFT", frameSuggestion2, "TOPLEFT", 0, 0)
    titleSuggestion2:SetText(L["Suggestion Tickets (2/2)"])
    frameSuggestion2.rowOffset = frameSuggestion2.rowOffset + 35

    AddOneParamCommandRow(frameSuggestion2, L["Ticket Suggestion Delete"], L["TicketID"], ".ticket suggestion delete")
    AddNoParamCommandRow(frameSuggestion2, L["Ticket Suggestion List"], ".ticket suggestion list")
    AddOneParamCommandRow(frameSuggestion2, L["Ticket Suggestion Unassign"], L["TicketID"], ".ticket suggestion unassign")
    AddOneParamCommandRow(frameSuggestion2, L["Ticket Suggestion View"], L["TicketID"], ".ticket suggestion view")

    -------------------------------------------------------------
    -- PAGE 7 : Ticket Reset
    -------------------------------------------------------------
    local page7 = pages[7]
    local frameReset = CreateFrame("Frame", nil, page7)
    frameReset:SetPoint("TOPLEFT", page7, "TOPLEFT", 20, -40)
    frameReset:SetSize(500, 300)
    frameReset.rowOffset = 0

    local titleReset = frameReset:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleReset:SetPoint("TOPLEFT", frameReset, "TOPLEFT", 0, 0)
    titleReset:SetText(L["Ticket Reset"])
    frameReset.rowOffset = frameReset.rowOffset + 35

    AddNoParamCommandRow(frameReset, L["Ticket Reset"], ".ticket reset")
    AddNoParamCommandRow(frameReset, L["Ticket Reset All"], ".ticket reset all")
    AddNoParamCommandRow(frameReset, L["Ticket Reset Bug"], ".ticket reset bug")
    AddNoParamCommandRow(frameReset, L["Ticket Reset Complaint"], ".ticket reset complaint")
    AddNoParamCommandRow(frameReset, L["Ticket Reset Suggestion"], ".ticket reset suggestion")

    ---------------------------------------------------------------------------
    -- Bouton "Back"
    ---------------------------------------------------------------------------
    local btnBackFinal = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("BOTTOM", panel, "BOTTOM", 0, 30)
    btnBackFinal:SetText(L["Back"])
    TrinityAdmin.AutoSize(btnBackFinal, 20, 16)
    btnBackFinal:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    -- On affiche la page 1 par défaut
    ShowPage(1)
    self.panel = panel
end

---------------------------------------------------------------------
-- Fonction pour afficher un popup de retour
-- Vous pouvez la lier à un event chat pour capturer les retours GM
---------------------------------------------------------------------
function Tickets:ShowPopup(message)
    if not self.popupFrame then
        self.popupFrame = CreateFrame("Frame", "TicketsPopupFrame", UIParent, "BasicFrameTemplateWithInset")
        self.popupFrame:SetSize(300, 200)
        self.popupFrame:SetPoint("CENTER")
        
        self.popupFrame.title = self.popupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.popupFrame.title:SetPoint("TOP", self.popupFrame, "TOP", 0, -10)
        self.popupFrame.title:SetText(L["Tickets Output"])
        
        self.popupFrame.content = self.popupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        self.popupFrame.content:SetPoint("CENTER", self.popupFrame, "CENTER", 0, 0)
        self.popupFrame.content:SetWidth(self.popupFrame:GetWidth() - 20)
    end
    
    self.popupFrame.content:SetText(message)
    self.popupFrame:Show()
end
