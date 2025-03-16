local module = TrinityAdmin:GetModule("GMFunctionsPanel")

function module:ShowGMFunctionsPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateGMFunctionsPanel()
    end
    self.panel:Show()
end

function module:CreateGMFunctionsPanel()
    local panel = CreateFrame("Frame", "TrinityAdminGMFunctionsPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
    
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)
    
    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(TrinityAdmin_Translations["GM Functions Panel"])
    
    -- Exemple : Bouton GM Fly ON/OFF
    local btnFly = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnFly:SetPoint("TOPLEFT", 10, -50)
    btnFly:SetText(self.gmFlyOn and "GM Fly ON" or "GM Fly OFF")
    btnFly:SetHeight(22)
    btnFly:SetWidth(btnFly:GetTextWidth() + 20)
    btnFly:SetScript("OnClick", function()
        if self.gmFlyOn then
            SendChatMessage(".gm fly off", "SAY")
            btnFly:SetText("GM Fly OFF")
            self.gmFlyOn = false
        else
            SendChatMessage(".gm fly on", "SAY")
            btnFly:SetText("GM Fly ON")
            self.gmFlyOn = true
        end
    end)
	
		-- Bouton GM ON/OFF
    local btnGmOn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnGmOn:SetSize(80, 22)
	btnGmOn:SetPoint("LEFT", btnFly, "RIGHT", 10, 0)
    btnGmOn:SetText(self.gmOn and "GM ON" or "GM OFF")
    btnGmOn:SetHeight(22)
    btnGmOn:SetWidth(btnGmOn:GetTextWidth() + 20)
    btnGmOn:SetScript("OnClick", function()
        if self.gmOn then
            SendChatMessage(".gm off", "SAY")
            btnGmOn:SetText("GM is OFF")
            self.gmOn = false
        else
            SendChatMessage(".gm on", "SAY")
            btnGmOn:SetText("GM is ON")
            self.gmOn = true
        end
    end)

    -- Bouron GM Chat ON/OFF
    local btnGmChat = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnGmChat:SetSize(100, 22)
    btnGmChat:SetPoint("LEFT", btnGmOn, "RIGHT", 10, 0)
    btnGmChat:SetText(self.gmChatOn and "GM Chat ON" or "GM ChatOFF")
    btnGmChat:SetHeight(22)
    btnGmChat:SetWidth(btnGmChat:GetTextWidth() + 20)
    btnGmChat:SetScript("OnClick", function()
        if self.gmChatOn then
			SendChatMessage(".gm chat off", "SAY")
			btnGmChat:SetText("GM Chat OFF")
			self.gmChatOn = false
		else
			SendChatMessage(".gm chat on", "SAY")
			btnGmChat:SetText("GM Chat ON")
			self.gmChatOn = true
		end
    end)
	
	-- Bouton GM Ingame (sans toggle)
	local btnGmIngame = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	-- btnGmIngame:SetSize(100, 22)
	btnGmIngame:SetPoint("LEFT", btnGmChat, "RIGHT", 10, 0)
	btnGmIngame:SetText("GM Ingame")
    btnGmIngame:SetHeight(22)
    btnGmIngame:SetWidth(btnGmIngame:GetTextWidth() + 20)
	btnGmIngame:SetScript("OnClick", function()
		SendChatMessage(".gm ingame", "SAY")
	end)

    -- Bouton GM List (sans toggle)
	local btnGmList = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	-- btnGmList:SetSize(100, 22)
	btnGmList:SetPoint("LEFT", btnGmIngame, "RIGHT", 10, 0)
	btnGmList:SetText("GM List")
	btnGmList:SetHeight(22)
    btnGmList:SetWidth(btnGmList:GetTextWidth() + 20)
    btnGmList:SetScript("OnClick", function()
		SendChatMessage(".gm list", "SAY")
	end)
	
	-- Bouton GM Visible (toggle on/off)
	local btnGmVisible = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	-- btnGmVisible:SetSize(100, 22)
	btnGmVisible:SetPoint("LEFT", btnGmList, "RIGHT", 10, 0)
	btnGmVisible:SetText(self.gmVisible and "GM Visible ON" or "GM Visible OFF")
    btnGmVisible:SetHeight(22)
    btnGmVisible:SetWidth(btnGmVisible:GetTextWidth() + 20)
	btnGmVisible:SetScript("OnClick", function()
		if self.gmVisible then
			SendChatMessage(".gm visible off", "SAY")
			btnGmVisible:SetText("GM Visible OFF")
			self.gmVisible = false
		else
			SendChatMessage(".gm visible on", "SAY")
			btnGmVisible:SetText("GM Visible ON")
			self.gmVisible = true
		end
	end)
	
	-- Bouton Appear (positionné sous GM Fly)
	local btnAppear = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	-- btnAppear:SetSize(100, 22)
	btnAppear:SetPoint("TOPLEFT", btnFly, "BOTTOMLEFT", 0, -10) -- Positionnement sous btnFly
	btnAppear:SetText("Appear")
    btnAppear:SetHeight(22)
    btnAppear:SetWidth(btnAppear:GetTextWidth() + 20)
	btnAppear:SetScript("OnClick", function()
		SendChatMessage(".appear", "SAY")
	end)
	
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
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