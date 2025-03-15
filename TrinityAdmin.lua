TrinityAdmin = LibStub("AceAddon-3.0"):NewAddon("TrinityAdmin", "AceConsole-3.0", "AceEvent-3.0")

------------------------------------------------------------
-- Fonctions d'initialisation
------------------------------------------------------------
function TrinityAdmin:OnInitialize()
    self:Print("TrinityAdmin OnInitialize fired")
    self:RegisterChatCommand("trinityadmin", "ToggleUI")
    self.gmFlyOn = false
end

function TrinityAdmin:OnEnable()
    -- self:Print("TrinityAdmin OnEnable fired")
	-- Remplacer le texte du titre par la traduction
    TrinityAdminMainFrameTitle:SetText(TrinityAdmin_Translations["TrinityAdmin Main Menu"])
end

function TrinityAdmin:OnDisable()
    self:Print("TrinityAdmin OnDisable fired")
end

------------------------------------------------------------
-- /trinityadmin : ouvre/ferme le mainFrame
------------------------------------------------------------
function TrinityAdmin:ToggleUI()
    if TrinityAdminMainFrame:IsShown() then
        TrinityAdminMainFrame:Hide()
    else
        TrinityAdminMainFrame:Show()
    end
end

------------------------------------------------------------
-- Fonctions appelées par le XML (boutons existants)
------------------------------------------------------------
function TrinityAdmin_ShowTeleportPanel()
    TrinityAdmin:ShowTeleportPanel()
end
function TrinityAdmin_ShowGMPanel()
    TrinityAdmin:ShowGMPanel()
end
function TrinityAdmin_ShowNPCPanel()
    TrinityAdmin:ShowNPCPanel()
end

-- On ajoute la nouvelle fonction pour le quatrième bouton
function TrinityAdmin_ShowGMFunctionsPanel()
    TrinityAdmin:ShowGMFunctionsPanel()
end

------------------------------------------------------------
-- Gestion du "menu principal" (les 4 boutons désormais)
------------------------------------------------------------
function TrinityAdmin:ShowMainMenu()
    if self.teleportPanel then self.teleportPanel:Hide() end
    if self.gmPanel then self.gmPanel:Hide() end
    if self.npcPanel then self.npcPanel:Hide() end
    if self.gmFunctionsPanel then self.gmFunctionsPanel:Hide() end  -- Masque aussi le nouveau

    -- On ré‐affiche tous les boutons
    TrinityAdminMainFrameTeleportButton:Show()
    TrinityAdminMainFrameGMButton:Show()
    TrinityAdminMainFrameNPCButton:Show()
    TrinityAdminMainFrameGMFunctionsButton:Show()  -- Le 4e

    TrinityAdminMainFrame:Show()
end

function TrinityAdmin:HideMainMenu()
    -- On masque tous les boutons
    TrinityAdminMainFrameTeleportButton:Hide()
    TrinityAdminMainFrameGMButton:Hide()
    TrinityAdminMainFrameNPCButton:Hide()
    TrinityAdminMainFrameGMFunctionsButton:Hide()  -- Le 4e

    TrinityAdminMainFrame:Show()
end

------------------------------------------------------------
-- Téléportation : Panneau (inchangé)
------------------------------------------------------------
function TrinityAdmin:ShowTeleportPanel()
    self:HideMainMenu()
    if not self.teleportPanel then
        self:CreateTeleportPanel()
    end
    self.teleportPanel:Show()
end

function TrinityAdmin:CreateTeleportPanel()
    local panel = CreateFrame("Frame", "TrinityAdminTeleportPanel", TrinityAdminMainFrame)
    panel:SetSize(700, 200)
    -- On ancre le panel pour qu'il ne déborde pas
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    -- panel.title:SetText("Teleport Panel")
	panel.title:SetText(TrinityAdmin_Translations["Teleport Panel"])

    ------------------------------------------------------------------
    -- 1) Dropdown Continent (TrinityAdminDropdownTemplate)
    ------------------------------------------------------------------
    local continentDropdown = CreateFrame("Frame", "TrinityAdminContinentDropdown", panel, "TrinityAdminDropdownTemplate")
    continentDropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)

    UIDropDownMenu_Initialize(continentDropdown, function(dropdown, level, menuList)
        level = level or 1
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)

        local continents = TeleportData
        if not continents then
            -- print("Aucun continent trouvé dans TeleportData!")
			print(TrinityAdmin_Translations["No_Teleport_Data_Found"])
            return
        end

        for continentName, zonesTable in pairs(continents) do
            local info = UIDropDownMenu_CreateInfo()
            info.text       = continentName
            info.value      = continentName
            info.isNotRadio = false
            info.r, info.g, info.b = 1,1,1  -- Couleur blanche
            info.checked    = (info.value == selectedValue)

            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(dropdown, button.value)
                UIDropDownMenu_SetText(dropdown, button.value)
                self.selectedContinent = button.value
                self.selectedZone      = nil
                self.selectedCommand   = nil

                self:PopulateZoneDropdown(button.value, panel)
                panel.zoneDropdown:Show()
                -- UIDropDownMenu_SetText(panel.zoneDropdown, "Select Zone")
				UIDropDownMenu_SetText(panel.zoneDropdown, TrinityAdmin_Translations["Select_Zone"])

                panel.locationDropdown:Hide()
                panel.goButton:Hide()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(continentDropdown, TrinityAdmin_Translations["Select_Continent"])

    ------------------------------------------------------------------
    -- 2) Dropdown Zone
    ------------------------------------------------------------------
    local zoneDropdown = CreateFrame("Frame", "TrinityAdminZoneDropdown", panel, "TrinityAdminDropdownTemplate")
    zoneDropdown:SetPoint("LEFT", continentDropdown, "RIGHT", 10, 0)
    UIDropDownMenu_SetText(zoneDropdown, TrinityAdmin_Translations["Select_Zone"])
    zoneDropdown:Hide()

    ------------------------------------------------------------------
    -- 3) Dropdown Location
    ------------------------------------------------------------------
    local locationDropdown = CreateFrame("Frame", "TrinityAdminLocationDropdown", panel, "TrinityAdminDropdownTemplate")
    locationDropdown:SetPoint("LEFT", zoneDropdown, "RIGHT", 10, 0)
    UIDropDownMenu_SetText(locationDropdown, TrinityAdmin_Translations["Select_Location"])
    locationDropdown:Hide()

    ------------------------------------------------------------------
    -- Bouton Go
    ------------------------------------------------------------------
    local goButton = CreateFrame("Button", "TrinityAdminGoButton", panel, "UIPanelButtonTemplate")
    goButton:SetSize(60, 22)
    goButton:SetPoint("LEFT", locationDropdown, "RIGHT", 10, 0)
    goButton:SetText("Go")
    goButton:Hide()
    goButton:SetScript("OnClick", function()
        if self.selectedCommand then
            self:TeleportTo(self.selectedCommand)
        else
            print(TrinityAdmin_Translations["Select_Location"])
        end
    end)

    ------------------------------------------------------------------
    -- Bouton Back
    ------------------------------------------------------------------
    local btnBack = CreateFrame("Button", "TrinityAdminTeleportBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", 0, 10)
    btnBack:SetText("Back")
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        self:ShowMainMenu()
    end)

    panel.continentDropdown = continentDropdown
    panel.zoneDropdown      = zoneDropdown
    panel.locationDropdown  = locationDropdown
    panel.goButton          = goButton

    self.teleportPanel = panel
end

function TrinityAdmin:PopulateZoneDropdown(continentName, panel)
    local zoneDropdown = panel.zoneDropdown
    UIDropDownMenu_Initialize(zoneDropdown, function(dropdown, level, menuList)
        level = level or 1
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)

        local zonesTable = TeleportData[continentName]
        if not zonesTable then
            print("Aucune zone pour le continent:", continentName)
            return
        end

        for zoneName, _ in pairs(zonesTable) do
            local info = UIDropDownMenu_CreateInfo()
            info.text       = zoneName
            info.value      = zoneName
            info.isNotRadio = false
            info.r, info.g, info.b = 1,1,1
            info.checked    = (info.value == selectedValue)

            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(zoneDropdown, button.value)
                UIDropDownMenu_SetText(zoneDropdown, button.value)

                self.selectedZone = button.value

                self:PopulateLocationDropdown(continentName, button.value, panel)
                panel.locationDropdown:Show()
                UIDropDownMenu_SetText(panel.locationDropdown, TrinityAdmin_Translations["Select_Location"])

                panel.goButton:Hide()
            end

            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(zoneDropdown, TrinityAdmin_Translations["Select_Zone"])
end

function TrinityAdmin:PopulateLocationDropdown(continentName, zoneName, panel)
    local locationDropdown = panel.locationDropdown
    UIDropDownMenu_Initialize(locationDropdown, function(dropdown, level, menuList)
        level = level or 1
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)

        local locTable = TeleportData[continentName] and TeleportData[continentName][zoneName]
        if not locTable then
            print("Aucun lieu pour la zone:", zoneName, "du continent:", continentName)
            return
        end

        for locationName, command in pairs(locTable) do
            local info = UIDropDownMenu_CreateInfo()
            info.text       = locationName
            info.value      = command
            info.isNotRadio = false
            info.r, info.g, info.b = 1,1,1
            info.checked    = (info.value == selectedValue)

            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(locationDropdown, button.value)
                UIDropDownMenu_SetText(locationDropdown, info.text)

                self.selectedCommand = button.value
                panel.goButton:Show()
            end

            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(locationDropdown, TrinityAdmin_Translations["Select_Location"])
end

function TrinityAdmin:TeleportTo(command)
    SendChatMessage(command, "SAY")
end

------------------------------------------------------------
-- Panel GM
------------------------------------------------------------
function TrinityAdmin:ShowGMPanel()
    self:HideMainMenu()
    if not self.gmPanel then
        self:CreateGMPanel()
    end
    self.gmPanel:Show()
end

function TrinityAdmin:CreateGMPanel()
    local panel = CreateFrame("Frame", "TrinityAdminGMPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(TrinityAdmin_Translations["Modify_Panel"])

    -- Champ de saisie
    local modifyInput = CreateFrame("EditBox", "TrinityAdminModifyInput", panel, "InputBoxTemplate")
    modifyInput:SetSize(80, 22)
    modifyInput:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)
    modifyInput:SetAutoFocus(false)
    modifyInput:SetText("Enter Value")
    modifyInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Dropdown
    local modifyDropdown = CreateFrame("Frame", "TrinityAdminModifyDropdown", panel, "TrinityAdminDropdownTemplate")
    modifyDropdown:SetPoint("LEFT", modifyInput, "RIGHT", 10, 0)

    -- Définir les options globalement
    local options = {
        "Choose",
        "Speed",
        "Money",
        "Hp",
        "Xp",
        "Scale",
        "Currency"
    }

    -- Définir displayNames en dehors pour éviter l'erreur
    local displayNames = {
        Choose = TrinityAdmin_Translations["Choose"] or "Choose",
        Speed = TrinityAdmin_Translations["Speed"],
        Money = TrinityAdmin_Translations["Money"],
        Hp = TrinityAdmin_Translations["Hp"],
        Xp = TrinityAdmin_Translations["Xp"],
        Scale = TrinityAdmin_Translations["Scale"],
        Currency = TrinityAdmin_Translations["Currency"]
    }

    local tooltipTexts = {
        Speed = TrinityAdmin_Translations["Modify_Speed"],
        Money = TrinityAdmin_Translations["Modify_Money"],
        Hp = TrinityAdmin_Translations["Modify_HP"],
        Xp = TrinityAdmin_Translations["Modify_XP"],
        Scale = TrinityAdmin_Translations["Modify_Scale"],
        Currency = TrinityAdmin_Translations["Add_Money"]
    }

    UIDropDownMenu_Initialize(modifyDropdown, function(dropdown, level, menuList)
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown) or "Choose"
        local info = UIDropDownMenu_CreateInfo()

        for _, option in ipairs(options) do
            info.text = displayNames[option] or option
            info.value = option
            info.isNotRadio = false
            info.r, info.g, info.b = 1, 1, 1
            info.checked = (info.value == selectedValue)

            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(dropdown, button.value)
                UIDropDownMenu_SetText(dropdown, displayNames[button.value] or button.value)
                TrinityAdmin.modifyFunction = button.value

                -- Vérifie si un tooltip est défini pour l'option sélectionnée
                if tooltipTexts[button.value] then
                    modifyInput:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(tooltipTexts[button.value], 1, 1, 1)
                        GameTooltip:Show()
                    end)
                    modifyInput:SetScript("OnLeave", function(self)
                        GameTooltip:Hide()
                    end)
                else
                    modifyInput:SetScript("OnEnter", nil)
                    modifyInput:SetScript("OnLeave", nil)
                end
            end

            UIDropDownMenu_AddButton(info, level)
        end
    end)

    -- Utiliser selectedValue pour afficher "Choose" par défaut
    local selectedValue = "Choose"
    UIDropDownMenu_SetText(modifyDropdown, displayNames[selectedValue] or selectedValue)

    -- Bouton "Set"
    local btnSet = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnSet:SetSize(60, 22)
    btnSet:SetPoint("LEFT", modifyDropdown, "RIGHT", 10, 0)
    btnSet:SetText("Set")
    btnSet:SetScript("OnClick", function()
        local value = modifyInput:GetText()
        if value == "" or value == "Enter Value" or value == "Choose" then
            print(TrinityAdmin_Translations["Enter_Valid_Value"])
            return
        end

        local func = TrinityAdmin.modifyFunction or "Speed"
        local command

        if func == "Currency" then
            local id, amount = string.match(value, "(%S+)%s+(%S+)")
            if not id or not amount then
                print(TrinityAdmin_Translations["Enter_Valid_Currency"])
                return
            end
            command = ".modify currency " .. id .. " " .. amount
        else
            command = ".modify " .. func .. " " .. value
        end

        SendChatMessage(command, "SAY")
    end)

    -- Bouton Back
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText("Back")
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        self:ShowMainMenu()
    end)

    self.gmPanel = panel
end


------------------------------------------------------------
-- Panel NPC
------------------------------------------------------------
function TrinityAdmin:ShowNPCPanel()
    self:HideMainMenu()
    if not self.npcPanel then
        self:CreateNPCPanel()
    end
    self.npcPanel:Show()
end

function TrinityAdmin:CreateNPCPanel()
    local npc = CreateFrame("Frame", "TrinityAdminNPCPanel", TrinityAdminMainFrame)
    npc:ClearAllPoints()
    npc:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    npc:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = npc:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    npc.title = npc:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    npc.title:SetPoint("TOPLEFT", 10, -10)
    npc.title:SetText(TrinityAdmin_Translations["Free_Panel"])

    local btnBack = CreateFrame("Button", nil, npc, "UIPanelButtonTemplate")
    btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", npc, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetScript("OnClick", function()
        npc:Hide()
        self:ShowMainMenu()
    end)

    self.npcPanel = npc
end

------------------------------------------------------------
-- Nouveau Panel : GM Functions
------------------------------------------------------------
function TrinityAdmin:ShowGMFunctionsPanel()
    self:HideMainMenu()
    if not self.gmFunctionsPanel then
        self:CreateGMFunctionsPanel()
    end
    self.gmFunctionsPanel:Show()
end

function TrinityAdmin:CreateGMFunctionsPanel()
    local panel = CreateFrame("Frame", "TrinityAdminGMFunctionsPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7) -- Couleur différente pour distinguer le panel

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    -- panel.title:SetText("GM Functions Panel")
	panel.title:SetText(TrinityAdmin_Translations["GM Functions Panel"])

    -- Bouton GM FLY ON/OFF
    local btnFly = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnFly:SetSize(80, 22)
    btnFly:SetPoint("TOPLEFT", 10, -50)
    btnFly:SetText(self.gmFlyOn and "GM Fly ON" or "GM Fly OFF")
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
    btnGmOn:SetSize(80, 22)
	btnGmOn:SetPoint("LEFT", btnFly, "RIGHT", 10, 0)
    btnGmOn:SetText(self.gmOn and "GM ON" or "GM OFF")
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
    btnGmChat:SetSize(100, 22)
    btnGmChat:SetPoint("LEFT", btnGmOn, "RIGHT", 10, 0)
    btnGmChat:SetText(self.gmChatOn and "GM Chat ON" or "GM ChatOFF")
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
	btnGmIngame:SetSize(100, 22)
	btnGmIngame:SetPoint("LEFT", btnGmChat, "RIGHT", 10, 0)
	btnGmIngame:SetText("GM Ingame")
	btnGmIngame:SetScript("OnClick", function()
		SendChatMessage(".gm ingame", "SAY")
	end)

    -- Bouton GM List (sans toggle)
	local btnGmList = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnGmList:SetSize(100, 22)
	btnGmList:SetPoint("LEFT", btnGmIngame, "RIGHT", 10, 0)
	btnGmList:SetText("GM List")
	btnGmList:SetScript("OnClick", function()
		SendChatMessage(".gm list", "SAY")
	end)
	
	-- Bouton GM Visible (toggle on/off)
	local btnGmVisible = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnGmVisible:SetSize(100, 22)
	btnGmVisible:SetPoint("LEFT", btnGmList, "RIGHT", 10, 0)
	btnGmVisible:SetText(self.gmVisible and "GM Visible ON" or "GM Visible OFF")
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

	local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText("Back")
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        self:ShowMainMenu()
    end)
	
    self.gmFunctionsPanel = panel
end
