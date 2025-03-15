TrinityAdmin = LibStub("AceAddon-3.0"):NewAddon("TrinityAdmin", "AceConsole-3.0", "AceEvent-3.0")

------------------------------------------------------------
-- Librairie icone minimap
------------------------------------------------------------
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("TrinityAdmin", {
    type = "launcher",
    text = "TrinityAdmin",
    icon = "Interface\\Icons\\Inv_7xp_inscription_talenttome01",  -- Remplacez par l'icône souhaitée
    OnClick = function(self, button)
        if button == "LeftButton" then
            TrinityAdmin:ToggleUI()  -- Ouvre/ferme votre interface
        elseif button == "RightButton" then
            -- Ajoutez ici d'autres actions si besoin
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("TrinityAdmin")
        tooltip:AddLine("Cliquez pour ouvrir le menu principal.", 1, 1, 1)
    end,
})

-- Table de sauvegarde pour l'icône minimap
TrinityAdminDB = TrinityAdminDB or {}
TrinityAdminDB.minimap = TrinityAdminDB.minimap or { hide = false }

-- Enregistrement de l'icône sur la minimap
local icon = LibStub("LibDBIcon-1.0")
icon:Register("TrinityAdmin", LDB, TrinityAdminDB.minimap)

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

function TrinityAdmin_ShowAccountPanel()
    TrinityAdmin:ShowAccountPanel()
end
------------------------------------------------------------
-- Gestion du "menu principal" (les 4 boutons désormais)
------------------------------------------------------------
function TrinityAdmin:ShowMainMenu()
    if self.teleportPanel then self.teleportPanel:Hide() end
    if self.gmPanel then self.gmPanel:Hide() end
    if self.npcPanel then self.npcPanel:Hide() end
    if self.gmFunctionsPanel then self.gmFunctionsPanel:Hide() end  -- Masque aussi le nouveau
	if self.accountPanel then self.accountPanel:Hide() end  -- Masque accounpanel

    -- On ré‐affiche tous les boutons
    TrinityAdminMainFrameTeleportButton:Show()
    TrinityAdminMainFrameGMButton:Show()
    TrinityAdminMainFrameNPCButton:Show()
    TrinityAdminMainFrameGMFunctionsButton:Show()  -- Le 4e
	TrinityAdminMainFrameAccountButton:Show() -- 5 eme bouton

    TrinityAdminMainFrame:Show()
end

------------------------------------------------------------
-- Fonction pour cacher le menu principale quand on est dans les sous menus
------------------------------------------------------------
function TrinityAdmin:HideMainMenu()
    -- On masque tous les boutons
    TrinityAdminMainFrameTeleportButton:Hide()
    TrinityAdminMainFrameGMButton:Hide()
    TrinityAdminMainFrameNPCButton:Hide()
    TrinityAdminMainFrameGMFunctionsButton:Hide()  -- Le 4e
	TrinityAdminMainFrameAccountButton:Hide()  -- Le 5e

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
    -- goButton:SetSize(60, 22)
    goButton:SetPoint("LEFT", locationDropdown, "RIGHT", 10, 0)
    goButton:SetText("Go")
    goButton:SetHeight(22)
    goButton:SetWidth(goButton:GetTextWidth() + 20)
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
    -- btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", 0, 10)
    btnBack:SetText("Back")
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
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
-- Panneau Modifications
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
        "Currency",
		"Faction",
		"Gender"
    }

    -- Définir displayNames en dehors pour éviter l'erreur
    local displayNames = {
        Choose = TrinityAdmin_Translations["Choose"] or "Choose",
        Speed = TrinityAdmin_Translations["Speed"],
        Money = TrinityAdmin_Translations["Money"],
        Hp = TrinityAdmin_Translations["Hp"],
        Xp = TrinityAdmin_Translations["Xp"],
        Scale = TrinityAdmin_Translations["Scale"],
        Currency = TrinityAdmin_Translations["Currency"],
		Faction = TrinityAdmin_Translations["Faction"],
		Gender = TrinityAdmin_Translations["Gender"]
    }

    local tooltipTexts = {
        Speed = TrinityAdmin_Translations["Modify_Speed"],
        Money = TrinityAdmin_Translations["Modify_Money"],
        Hp = TrinityAdmin_Translations["Modify_HP"],
        Xp = TrinityAdmin_Translations["Modify_XP"],
        Scale = TrinityAdmin_Translations["Modify_Scale"],
        Currency = TrinityAdmin_Translations["Add_Money"],
		Faction = TrinityAdmin_Translations["Modify_Faction"],
		Gender = TrinityAdmin_Translations["Modify_Gender"]
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
    -- btnSet:SetSize(60, 22)
    btnSet:SetPoint("LEFT", modifyDropdown, "RIGHT", 10, 0)
    btnSet:SetText("Set")
    btnSet:SetHeight(22)
    btnSet:SetWidth(btnSet:GetTextWidth() + 20)
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
    -- btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText("Back")
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
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
    -- btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", npc, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        npc:Hide()
        self:ShowMainMenu()
    end)

    self.npcPanel = npc
end

------------------------------------------------------------
-- Panel ACCOUNTS
------------------------------------------------------------
function TrinityAdmin:ShowAccountPanel()
    self:HideMainMenu()
    if not self.accountPanel then
        self:CreateAccountPanel()
    end
    self.accountPanel:Show()
end

function TrinityAdmin:CreateAccountPanel()
    local account = CreateFrame("Frame", "TrinityAdminAccountPanel", TrinityAdminMainFrame)
    account:ClearAllPoints()
    account:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    account:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = account:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    account.title = account:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    account.title:SetPoint("TOPLEFT", 10, -10)
    account.title:SetText(TrinityAdmin_Translations["Account_Panel"])

    -- Label indiquant "Création de comptes" (utilisation de la traduction)
    local creationLabel = account:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    creationLabel:SetPoint("TOPLEFT", account, "TOPLEFT", 10, -30)
    creationLabel:SetText(TrinityAdmin_Translations["Account Creation"])

    -- EditBox pour l'Account avec valeur par défaut et tooltip
    local accountEditBox = CreateFrame("EditBox", "TrinityAdminAccountEditBox", account, "InputBoxTemplate")
    accountEditBox:SetSize(200, 22)
    accountEditBox:SetPoint("TOPLEFT", account, "TOPLEFT", 10, -50)
    accountEditBox:SetAutoFocus(false)
    accountEditBox:SetText(TrinityAdmin_Translations["Username"])
    accountEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == TrinityAdmin_Translations["Username"] then
            self:SetText("")
        end
    end)
    accountEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(TrinityAdmin_Translations["Username"])
        end
    end)
    -- Ajout du tooltip pour préciser le format
    accountEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(TrinityAdmin_Translations["Account_Format_Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    accountEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- EditBox pour le Password avec valeur par défaut
    local passwordEditBox = CreateFrame("EditBox", "TrinityAdminPasswordEditBox", account, "InputBoxTemplate")
    passwordEditBox:SetSize(200, 22)
    passwordEditBox:SetPoint("TOPLEFT", accountEditBox, "BOTTOMLEFT", 0, -10)
    passwordEditBox:SetAutoFocus(false)
    passwordEditBox:SetText(TrinityAdmin_Translations["Password"])
    passwordEditBox:SetPassword(true)  -- Masque la saisie
    passwordEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == TrinityAdmin_Translations["Password"] then
            self:SetText("")
        end
    end)
    passwordEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(TrinityAdmin_Translations["Password"])
        end
    end)
    -- (Optionnel : vous pouvez ajouter un tooltip pour le password si besoin)
	passwordEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(TrinityAdmin_Translations["Account_Password_Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    passwordEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    -- Bouton "Create"
    local btnCreate = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    -- btnCreate:SetSize(80, 22)
    btnCreate:SetPoint("TOPLEFT", passwordEditBox, "BOTTOMLEFT", 0, -10)
    btnCreate:SetText(TrinityAdmin_Translations["Create"])
    btnCreate:SetHeight(22)
    btnCreate:SetWidth(btnCreate:GetTextWidth() + 20)
    btnCreate:SetScript("OnClick", function()
        local accountValue = accountEditBox:GetText()
        local passwordValue = passwordEditBox:GetText()
        -- Vérifie si les champs sont remplis (en tenant compte des valeurs par défaut)
        if accountValue == "" or accountValue == TrinityAdmin_Translations["Username"] or
           passwordValue == "" or passwordValue == TrinityAdmin_Translations["Password"] then
            print(TrinityAdmin_Translations["Please enter both account and password."])
            return
        end
        local command = ".bnetaccount create \"" .. accountValue .. "\" \"" .. passwordValue .. "\""
        SendChatMessage(command, "SAY")
    end)

    -- Label "Bannir un compte"
    local banLabel = account:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    banLabel:SetPoint("TOPLEFT", btnCreate, "BOTTOMLEFT", 0, -20)
    banLabel:SetText(TrinityAdmin_Translations["Ban Account"])
    
    -- EditBox pour le Name
    local banNameEditBox = CreateFrame("EditBox", "TrinityAdminBanNameEditBox", account, "InputBoxTemplate")
    banNameEditBox:SetSize(150, 22)
    banNameEditBox:SetPoint("TOPLEFT", banLabel, "BOTTOMLEFT", 0, -10)
    banNameEditBox:SetAutoFocus(false)
    banNameEditBox:SetText(TrinityAdmin_Translations["Name"])
    banNameEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == TrinityAdmin_Translations["Name"] then
            self:SetText("")
        end
    end)
    banNameEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(TrinityAdmin_Translations["Name"])
        end
    end)
    banNameEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(TrinityAdmin_Translations["Name Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    banNameEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- EditBox pour le Bantime
    local banTimeEditBox = CreateFrame("EditBox", "TrinityAdminBanTimeEditBox", account, "InputBoxTemplate")
    banTimeEditBox:SetSize(150, 22)
    banTimeEditBox:SetPoint("TOPLEFT", banNameEditBox, "BOTTOMLEFT", 0, -10)
    banTimeEditBox:SetAutoFocus(false)
    banTimeEditBox:SetText(TrinityAdmin_Translations["Bantime"])
    banTimeEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == TrinityAdmin_Translations["Bantime"] then
            self:SetText("")
        end
    end)
    banTimeEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(TrinityAdmin_Translations["Bantime"])
        end
    end)
    banTimeEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(TrinityAdmin_Translations["Bantime Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    banTimeEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- EditBox pour le Reason
    local banReasonEditBox = CreateFrame("EditBox", "TrinityAdminBanReasonEditBox", account, "InputBoxTemplate")
    banReasonEditBox:SetSize(150, 22)
    banReasonEditBox:SetPoint("TOPLEFT", banTimeEditBox, "BOTTOMLEFT", 0, -10)
    banReasonEditBox:SetAutoFocus(false)
    banReasonEditBox:SetText(TrinityAdmin_Translations["Reason"])
    banReasonEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == TrinityAdmin_Translations["Reason"] then
            self:SetText("")
        end
    end)
    banReasonEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(TrinityAdmin_Translations["Reason"])
        end
    end)
    -- (Vous pouvez ajouter un tooltip ici si nécessaire)
    
    -- Bouton "Ban"
    local btnBan = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    -- btnBan:SetSize(120, 22)
    btnBan:SetPoint("TOPLEFT", banReasonEditBox, "BOTTOMLEFT", 0, -10)
    btnBan:SetText(TrinityAdmin_Translations["Ban"])
    btnBan:SetHeight(22)
    btnBan:SetWidth(btnBan:GetTextWidth() + 20)
    btnBan:SetScript("OnClick", function()
        local nameValue = banNameEditBox:GetText()
        local timeValue = banTimeEditBox:GetText()
        local reasonValue = banReasonEditBox:GetText()
        if nameValue == "" or nameValue == TrinityAdmin_Translations["Name"]
           or timeValue == "" or timeValue == TrinityAdmin_Translations["Bantime"]
           or reasonValue == "" or reasonValue == TrinityAdmin_Translations["Reason"] then
            print(TrinityAdmin_Translations["Please enter name, bantime and reason."])
            return
        end
        local command = ".ban account " .. nameValue .. " " .. timeValue .. " " .. reasonValue
        SendChatMessage(command, "SAY")
    end)

    -- Bouton "Bannir Personnage" à droite du bouton "Ban"
    local btnBanChar = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    -- btnBanChar:SetSize(120, 22)
    btnBanChar:SetHeight(22)
    btnBanChar:SetPoint("LEFT", btnBan, "RIGHT", 10, 0)
    btnBanChar:SetText(TrinityAdmin_Translations["Ban Character"])
    btnBanChar:SetWidth(btnBanChar:GetTextWidth() + 20)
    btnBanChar:SetScript("OnClick", function()
        local nameValue = banNameEditBox:GetText()
        local timeValue = banTimeEditBox:GetText()
        local reasonValue = banReasonEditBox:GetText()
        if nameValue == "" or nameValue == TrinityAdmin_Translations["Name"]
           or timeValue == "" or timeValue == TrinityAdmin_Translations["Bantime"]
           or reasonValue == "" or reasonValue == TrinityAdmin_Translations["Reason"] then
            print(TrinityAdmin_Translations["Please enter name, bantime and reason."])
            return
        end
        local command = ".ban character " .. nameValue .. " " .. timeValue .. " " .. reasonValue
        SendChatMessage(command, "SAY")
    end)


    local btnBack = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    -- btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", account, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        account:Hide()
        self:ShowMainMenu()
    end)

    self.accountPanel = account
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
    -- btnFly:SetSize(80, 22)
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
    
	-- Bouton Retout (positionné )
	local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText("Back")
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        self:ShowMainMenu()
    end)
	
    self.gmFunctionsPanel = panel
end
