local AddLearn = TrinityAdmin:GetModule("AddLearn")

-- Fonction pour afficher le panneau AddLearn
function AddLearn:ShowAddLearnPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAddLearnPanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau AddLearn
function AddLearn:CreateAddLearnPanel()
    local panel = CreateFrame("Frame", "TrinityAdminAddLearnPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre, modifiez selon vos besoins

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Add Learn Panel")  -- Vous pouvez utiliser TrinityAdmin_Translations si nécessaire

    -- Ici, vous pouvez ajouter d'autres éléments (boutons, champs de saisie, etc.) pour la gestion du serveur
    local btnBack = CreateFrame("Button", "TrinityAdminTeleportBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)
	
    self.panel = panel
end
