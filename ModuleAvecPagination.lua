local ServerAdmin = TrinityAdmin:GetModule("ServerAdmin")

-- Fonction pour afficher le panneau ServerAdmin
function ServerAdmin:ShowServerAdminPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateServerAdminPanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau ServerAdmin
function ServerAdmin:CreateServerAdminPanel()
    local panel = CreateFrame("Frame", "TrinityAdminServerAdminPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Server Admin Panel")

    -------------------------------------------------------------------------------
    -- Création de plusieurs pages dans le panneau
    -------------------------------------------------------------------------------
	local totalPages = 2  -- nombre de pages
	local pages = {}
	for i = 1, totalPages do
		pages[i] = CreateFrame("Frame", nil, panel)
		pages[i]:SetAllPoints(panel)
		pages[i]:Hide()  -- on cache toutes les pages au départ
	end
	
	-- Label de navigation unique (affiché en bas du panneau)
	local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
	navPageLabel:SetText("Page 1 / " .. totalPages)
	
	-- Fonction de changement de page
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
	
	ShowPage(1)
	
-- Pour la page 1 :
local commandsFramePage1 = CreateFrame("Frame", nil, pages[1])
commandsFramePage1:SetPoint("TOPLEFT", pages[1], "TOPLEFT", 20, -40)
commandsFramePage1:SetSize(500, 350)

local page1Title = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page1Title:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, 0)
page1Title:SetText("Server Admin Panel Page 1")
    -- Ici, vous pouvez ajouter les boutons pour la page 1
    --local btnServerCorpses = CreateServerButton("ServerCorpsesButton", "server corpses", "Syntax: .server corpses\r\n\r\nTrigger corpses expire check in world.", ".server corpses")
    --btnServerCorpses:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, -10)
    -- Ajoutez d'autres boutons de la page 1…

-- Pour la page 2 :
local commandsFramePage2 = CreateFrame("Frame", nil, pages[2])
commandsFramePage2:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
commandsFramePage2:SetSize(500, 350)

local page2Title = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page2Title:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, 0)
page2Title:SetText("Server Admin Panel Page 2")
    -- Ici, vous ajoutez les boutons pour la page 2
    --local btnServerPlimit = CreateServerButton("ServerPlimitButton", "server plimit", "Syntax: .server plimit [arg]\r\nShow or set player limit.", ".server plimit")
    --btnServerPlimit:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, -10)
    -- Ajoutez d'autres boutons de la page 2…

    ------------------------------------------------------------------------------
    -- Bouton helper pour créer des boutons simples (comme précédemment)
    ------------------------------------------------------------------------------
    local function CreateServerButton(name, text, tooltip, cmd)
        local btn = CreateFrame("Button", name, nil, "UIPanelButtonTemplate")
        btn:SetSize(150, 22)
        btn:SetText(text)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        btn:SetScript("OnClick", function(self)
            SendChatMessage(cmd, "SAY")
            print("Commande envoyée: " .. cmd)
        end)
        return btn
    end

     ------------------------------------------------------------------------------
    -- Boutons de navigation (précédent / suivant)
    ------------------------------------------------------------------------------
    local currentPage = 1

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


    ------------------------------------------------------------------------------
    -- Fin du panneau, bouton Back déjà présent
    ------------------------------------------------------------------------------
    local btnBackFinal = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBackFinal:SetText(TrinityAdmin_Translations["Back"])
    btnBackFinal:SetHeight(22)
    btnBackFinal:SetWidth(btnBackFinal:GetTextWidth() + 20)
    btnBackFinal:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
