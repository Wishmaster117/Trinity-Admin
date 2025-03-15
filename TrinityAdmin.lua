-- TrinityAdmin.lua
-- Assurez-vous que TeleportTable.lua est listé dans le .toc AVANT ce fichier

TrinityAdmin = LibStub("AceAddon-3.0"):NewAddon("TrinityAdmin", "AceConsole-3.0", "AceEvent-3.0")

------------------------------------------------------------
-- Fonctions d'initialisation de l'addon
------------------------------------------------------------
function TrinityAdmin:OnInitialize()
    self:Print("TrinityAdmin OnInitialize fired")
    self:CreateMainMenu()
    self:RegisterChatCommand("trinityadmin", "ToggleUI")
end

function TrinityAdmin:OnEnable()
    self:Print("TrinityAdmin OnEnable fired")
end

function TrinityAdmin:OnDisable()
    self:Print("TrinityAdmin OnDisable fired")
end

------------------------------------------------------------------------------
-- Création du menu principal
------------------------------------------------------------------------------
function TrinityAdmin:CreateMainMenu()
    local f = CreateFrame("Frame", "TrinityAdminMainFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(600, 400)
    f:SetPoint("CENTER")
    f:Hide() -- Masqué par défaut

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("LEFT", f.TitleBg, "LEFT", 5, 0)
    f.title:SetText("TrinityAdmin Main Menu")

    -- Bouton Teleport placé en haut à gauche
    local btnTeleport = CreateFrame("Button", "TrinityAdminButtonTeleport", f, "UIPanelButtonTemplate")
    btnTeleport:SetSize(80, 22)
    btnTeleport:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -30)
    btnTeleport:SetText("Teleport")
    btnTeleport:SetScript("OnClick", function() self:ShowTeleportPanel() end)

    -- Bouton GM placé à droite du bouton Teleport
    local btnGM = CreateFrame("Button", "TrinityAdminButtonGM", f, "UIPanelButtonTemplate")
    btnGM:SetSize(80, 22)
    btnGM:SetPoint("LEFT", btnTeleport, "RIGHT", 10, 0)
    btnGM:SetText("GM")
    btnGM:SetScript("OnClick", function() self:ShowGMPanel() end)

    -- Bouton Npc placé à droite du bouton GM
    local btnNpc = CreateFrame("Button", "TrinityAdminButtonNpc", f, "UIPanelButtonTemplate")
    btnNpc:SetSize(80, 22)
    btnNpc:SetPoint("LEFT", btnGM, "RIGHT", 10, 0)
    btnNpc:SetText("Npc")
    btnNpc:SetScript("OnClick", function() self:ShowNPCPanel() end)

    self.mainFrame = f
end

function TrinityAdmin:ShowMainMenu()
    -- Masque les panneaux secondaires s'ils existent
    if self.teleportPanel then self.teleportPanel:Hide() end
    if self.gmPanel then self.gmPanel:Hide() end
    if self.npcPanel then self.npcPanel:Hide() end
    self.mainFrame:Show()
end

function TrinityAdmin:HideMainMenu()
    self.mainFrame:Hide()
end

------------------------------------------------------------------------------
-- Panneau Teleport
------------------------------------------------------------------------------
function TrinityAdmin:ShowTeleportPanel()
    self:HideMainMenu()
    if not self.teleportPanel then
        self:CreateTeleportPanel()
    end
    self.teleportPanel:Show()
end

function TrinityAdmin:CreateTeleportPanel()
    local panel = CreateFrame("Frame", "TrinityAdminTeleportPanel", UIParent, "BasicFrameTemplateWithInset")
    panel:SetSize(700, 200)
    panel:SetPoint("CENTER")
    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("LEFT", panel.TitleBg, "LEFT", 5, 0)
    panel.title:SetText("Teleport Panel")

    -- Dropdown Continent
    local continentDropdown = CreateFrame("Frame", "TrinityAdminContinentDropdown", panel, "UIDropDownMenuTemplate")
    continentDropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)
    UIDropDownMenu_SetWidth(continentDropdown, 110)
    UIDropDownMenu_SetText(continentDropdown, "Select Continent")
    UIDropDownMenu_Initialize(continentDropdown, function(dropdown, level, menuList)
        level = level or 1
        local continents = TeleportData
        if not continents then
            print("Aucun continent trouvé dans TeleportData !")
            return
        end
        for continentName, zonesTable in pairs(continents) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = continentName
            info.value = continentName
            info.isNotRadio = false
            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(continentDropdown, button.value)
                UIDropDownMenu_SetText(continentDropdown, button.text)
                self.selectedContinent = button.value
                self.selectedZone = nil
                self.selectedCommand = nil
                self:PopulateZoneDropdown(button.value, panel)
                panel.zoneDropdown:Show()
                UIDropDownMenu_SetText(panel.zoneDropdown, "Select Zone")
                panel.locationDropdown:Hide()
                panel.goButton:Hide()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    -- Dropdown Zone
    local zoneDropdown = CreateFrame("Frame", "TrinityAdminZoneDropdown", panel, "UIDropDownMenuTemplate")
    zoneDropdown:SetPoint("LEFT", continentDropdown, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(zoneDropdown, 110)
    UIDropDownMenu_SetText(zoneDropdown, "Select Zone")
    zoneDropdown:Hide()

    -- Dropdown Location
    local locationDropdown = CreateFrame("Frame", "TrinityAdminLocationDropdown", panel, "UIDropDownMenuTemplate")
    locationDropdown:SetPoint("LEFT", zoneDropdown, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(locationDropdown, 140)  -- élargi pour mieux voir le texte
    UIDropDownMenu_SetText(locationDropdown, "Select Location")
    locationDropdown:Hide()

    -- Bouton Go
    local goButton = CreateFrame("Button", "TrinityAdminGoButton", panel, "UIPanelButtonTemplate")
    goButton:SetSize(60, 22)
    goButton:SetPoint("LEFT", locationDropdown, "RIGHT", 10, 0)
    goButton:SetText("Go")
    goButton:Hide()
    goButton:SetScript("OnClick", function()
        if self.selectedCommand then
            self:TeleportTo(self.selectedCommand)
        else
            print("Veuillez sélectionner un lieu.")
        end
    end)

    -- Bouton Back
    local btnBack = CreateFrame("Button", "TrinityAdminTeleportBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetSize(80, 22)
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText("Back")
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        self:ShowMainMenu()
    end)

    panel.continentDropdown = continentDropdown
    panel.zoneDropdown = zoneDropdown
    panel.locationDropdown = locationDropdown
    panel.goButton = goButton

    self.teleportPanel = panel
end

function TrinityAdmin:PopulateZoneDropdown(continentName, panel)
    local zoneDropdown = panel.zoneDropdown
    UIDropDownMenu_Initialize(zoneDropdown, function(dropdown, level, menuList)
        level = level or 1
        local zonesTable = TeleportData[continentName]
        if not zonesTable then
            print("Aucune zone pour le continent:", continentName)
            return
        end
        for zoneName, _ in pairs(zonesTable) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = zoneName
            info.value = zoneName
            info.isNotRadio = false
            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(zoneDropdown, button.value)
                UIDropDownMenu_SetText(zoneDropdown, button.text)
                self.selectedZone = button.value
                self:PopulateLocationDropdown(continentName, button.value, panel)
                panel.locationDropdown:Show()
                UIDropDownMenu_SetText(panel.locationDropdown, "Select Location")
                panel.goButton:Hide()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(zoneDropdown, "Select Zone")
end

function TrinityAdmin:PopulateLocationDropdown(continentName, zoneName, panel)
    local locationDropdown = panel.locationDropdown
    UIDropDownMenu_Initialize(locationDropdown, function(dropdown, level, menuList)
        level = level or 1
        local locTable = TeleportData[continentName] and TeleportData[continentName][zoneName]
        if not locTable then
            print("Aucun lieu pour la zone:", zoneName, "du continent:", continentName)
            return
        end
        for locationName, command in pairs(locTable) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = locationName
            info.value = command
            info.isNotRadio = false
            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(locationDropdown, button.text)
                UIDropDownMenu_SetText(locationDropdown, button.text)
                self.selectedCommand = button.value
                panel.goButton:Show()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetText(locationDropdown, "Select Location")
end

function TrinityAdmin:TeleportTo(command)
    SendChatMessage(command, "SAY")
end

------------------------------------------------------------------------------
-- Panneau GM : création et affichage
------------------------------------------------------------------------------
function TrinityAdmin:ShowGMPanel()
    self:HideMainMenu()
    if not self.gmPanel then
        local gm = CreateFrame("Frame", "TrinityAdminGMPanel", UIParent, "BasicFrameTemplateWithInset")
        gm:SetSize(600, 200)
        gm:SetPoint("CENTER")
        gm.title = gm:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        gm.title:SetPoint("LEFT", gm.TitleBg, "LEFT", 5, 0)
        gm.title:SetText("GM Panel")

        local bg = gm:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(true)
        bg:SetColorTexture(0, 0, 0, 0.5)

        -- Bouton GM FLY
        local btnFly = CreateFrame("Button", nil, gm, "UIPanelButtonTemplate")
        btnFly:SetSize(80, 22)
        btnFly:SetPoint("LEFT", gm, "LEFT", 10, 0)
        if self.gmFlyOn then
            btnFly:SetText("GM Fly ON")
        else
            btnFly:SetText("GM Fly OFF")
        end
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

        -- Champ de saisie pour la valeur
        local modifyInput = CreateFrame("EditBox", "TrinityAdminModifyInput", gm, "InputBoxTemplate")
        modifyInput:SetSize(80, 22)
        modifyInput:SetPoint("LEFT", btnFly, "RIGHT", 20, 0)
        modifyInput:SetAutoFocus(false)
        modifyInput:SetText("Enter Value")
        modifyInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

        -- Dropdown pour choisir la fonction à modifier
        local modifyDropdown = CreateFrame("Frame", "TrinityAdminModifyDropdown", gm, "UIDropDownMenuTemplate")
        modifyDropdown:SetPoint("LEFT", modifyInput, "RIGHT", 10, 0)
        UIDropDownMenu_SetWidth(modifyDropdown, 90)
        UIDropDownMenu_SetText(modifyDropdown, "Speed")
        UIDropDownMenu_Initialize(modifyDropdown, function(dropdown, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            local options = {"Speed", "Money", "Hp", "Xp", "Scale"}
            for _, option in ipairs(options) do
                info.text = option
                info.value = option
                info.isNotRadio = false
                info.func = function(selfButton)
                    UIDropDownMenu_SetSelectedValue(dropdown, selfButton.value)
                    UIDropDownMenu_SetText(dropdown, selfButton.text)
                    TrinityAdmin.modifyFunction = selfButton.value
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)

        -- Bouton "Set"
        local btnSet = CreateFrame("Button", nil, gm, "UIPanelButtonTemplate")
        btnSet:SetSize(60, 22)
        btnSet:SetPoint("LEFT", modifyDropdown, "RIGHT", 10, 0)
        btnSet:SetText("Set")
        btnSet:SetScript("OnClick", function()
            local value = modifyInput:GetText()
            if value == "" or value == "Set speed" then
                print("Veuillez entrer une valeur valide.")
            else
                local command = ".modify " .. TrinityAdmin.modifyFunction .. " " .. value
                SendChatMessage(command, "SAY")
            end
        end)

        -- Bouton Back pour revenir au menu principal
        local btnBack = CreateFrame("Button", nil, gm, "UIPanelButtonTemplate")
        btnBack:SetSize(80, 22)
        btnBack:SetPoint("BOTTOM", gm, "BOTTOM", 0, 10)
        btnBack:SetText("Back")
        btnBack:SetScript("OnClick", function()
            gm:Hide()
            self:ShowMainMenu()
        end)

        self.gmPanel = gm
    end
    self.gmPanel:Show()
end

------------------------------------------------------------------------------
-- Panneau NPC : création et affichage (exemple simplifié)
------------------------------------------------------------------------------
function TrinityAdmin:ShowNPCPanel()
    self:HideMainMenu()
    if not self.npcPanel then
        local npc = CreateFrame("Frame", "TrinityAdminNPCPanel", UIParent, "BasicFrameTemplateWithInset")
        npc:SetSize(400, 200)
        npc:SetPoint("CENTER")
        npc.title = npc:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        npc.title:SetPoint("LEFT", npc.TitleBg, "LEFT", 5, 0)
        npc.title:SetText("NPC Panel")
        local btnBack = CreateFrame("Button", nil, npc, "UIPanelButtonTemplate")
        btnBack:SetSize(80, 22)
        btnBack:SetPoint("BOTTOM", npc, "BOTTOM", 0, 10)
        btnBack:SetText("Back")
        btnBack:SetScript("OnClick", function()
            npc:Hide()
            self:ShowMainMenu()
        end)
        self.npcPanel = npc
    end
    self.npcPanel:Show()
end

------------------------------------------------------------------------------
-- Exécute la commande de téléportation
------------------------------------------------------------------------------
function TrinityAdmin:TeleportTo(command)
    SendChatMessage(command, "SAY")
end

------------------------------------------------------------------------------
-- Commande slash /trinityadmin pour basculer l'affichage de la fenêtre principale
------------------------------------------------------------------------------
function TrinityAdmin:ToggleUI(input)
    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
        if self.gmPanel then self.gmPanel:Hide() end
        if self.teleportPanel then self.teleportPanel:Hide() end
        if self.npcPanel then self.npcPanel:Hide() end
    else
        self:ShowMainMenu()
    end
end
