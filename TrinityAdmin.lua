-- TrinityAdmin.lua
-- Suppose que TeleportData est déjà défini (via TeleportTable.lua) et chargé avant.

TrinityAdmin = LibStub("AceAddon-3.0"):NewAddon("TrinityAdmin", "AceConsole-3.0", "AceEvent-3.0")

function TrinityAdmin:OnInitialize()
    self:Print("TrinityAdmin OnInitialize fired")
    self:CreateUI()
    self:RegisterChatCommand("trinityadmin", "ToggleUI")
end

function TrinityAdmin:OnEnable()
    self:Print("TrinityAdmin OnEnable fired")
end

function TrinityAdmin:OnDisable()
    self:Print("TrinityAdmin OnDisable fired")
end

------------------------------------------------------------------------------
-- Création de l'interface principale
------------------------------------------------------------------------------
function TrinityAdmin:CreateUI()
    local f = CreateFrame("Frame", "TrinityAdminFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(600, 400)
    f:SetPoint("CENTER")
    f:Hide() -- Masqué par défaut

    -- Titre
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("LEFT", f.TitleBg, "LEFT", 5, 0)
    f.title:SetText("TrinityAdmin")

    ----------------------------------------------------------------------
    -- Variables internes pour retenir les sélections
    ----------------------------------------------------------------------
    self.selectedContinent = nil
    self.selectedZone = nil
    self.selectedCommand = nil
	self.gmFlyOn = false  -- état du GM fly
	self.modifyFunction = "speed"  -- fonction par défaut pour la commande modify

    ----------------------------------------------------------------------
    -- Boutons principaux en bas
    ----------------------------------------------------------------------
    local btnTeleport = CreateFrame("Button", "TrinityAdminButtonTeleport", f, "UIPanelButtonTemplate")
    btnTeleport:SetSize(80, 22)
    btnTeleport:SetPoint("BOTTOMLEFT", 10, 10)
    btnTeleport:SetText("Teleport")
    btnTeleport:SetScript("OnClick", function()
        if self.continentDropdown:IsShown() then
            -- Si déjà visible, on masque tout
            self.continentDropdown:Hide()
            self.zoneDropdown:Hide()
            self.locationDropdown:Hide()
            self.goButton:Hide()
        else
            -- Sinon on (re)affiche le dropdown de Continent
            self.continentDropdown:Show()
            self.zoneDropdown:Hide()
            self.locationDropdown:Hide()
            self.goButton:Hide()

            UIDropDownMenu_Initialize(self.continentDropdown, function(dropdown, level, menuList)
                level = level or 1
                local continents = TeleportData
                if not continents then
                    print("Aucun continent trouvé dans TeleportData !")
                    return
                end

                for continentName, zonesTable in pairs(continents) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = continentName
                    info.value = continentName
                    info.isNotRadio = false
                    info.checked = (self.selectedContinent == continentName)
                    info.func = function(button)
                        -- Met à jour la sélection
                        self.selectedContinent = button.value
                        UIDropDownMenu_SetSelectedValue(self.continentDropdown, button.value)
                        UIDropDownMenu_SetText(self.continentDropdown, button.text)

                        -- Réinitialise zone/lieu
                        self.selectedZone = nil
                        self.selectedCommand = nil

                        -- Remplit la liste des zones
                        self:PopulateZoneDropdown(button.value)
                        self.zoneDropdown:Show()

                        -- On met le dropdown zone sur “Select Zone” (sauf si on veut restaurer un éventuel ancien choix)
                        UIDropDownMenu_SetText(self.zoneDropdown, "Select Zone")
                        UIDropDownMenu_SetText(self.locationDropdown, "Select Location")
                        self.locationDropdown:Hide()
                        self.goButton:Hide()
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end)

            -- Si on a déjà un continent sélectionné, on l’affiche. Sinon on affiche "Select Continent"
            if self.selectedContinent then
                UIDropDownMenu_SetText(self.continentDropdown, self.selectedContinent)
            else
                UIDropDownMenu_SetText(self.continentDropdown, "Select Continent")
            end
        end
    end)

    -- Bouton GM (anciennement "Char")
    local btnGM = CreateFrame("Button", "TrinityAdminButtonGM", f, "UIPanelButtonTemplate")
    btnGM:SetSize(80, 22)
    btnGM:SetPoint("LEFT", btnTeleport, "RIGHT", 10, 0)
    btnGM:SetText("GM")
    btnGM:SetScript("OnClick", function()
        self:ToggleGMPanel()
    end)

    local btnNpc = CreateFrame("Button", "TrinityAdminButtonNpc", f, "UIPanelButtonTemplate")
    btnNpc:SetSize(80, 22)
    btnNpc:SetPoint("LEFT", btnChar, "RIGHT", 10, 0)
    btnNpc:SetText("Npc")
    btnNpc:SetScript("OnClick", function() self:Print("Bouton Npc cliqué !") end)

    ----------------------------------------------------------------------
    -- Création des 3 dropdowns et du bouton Go
    ----------------------------------------------------------------------

    -- 1) Dropdown Continent
    local continentDropdown = CreateFrame("Frame", "TrinityAdminContinentDropdown", f, "UIDropDownMenuTemplate")
    continentDropdown:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -50)
    UIDropDownMenu_SetWidth(continentDropdown, 110)
    UIDropDownMenu_SetText(continentDropdown, "Select Continent")
    continentDropdown:Hide()

    -- 2) Dropdown Zone
    local zoneDropdown = CreateFrame("Frame", "TrinityAdminZoneDropdown", f, "UIDropDownMenuTemplate")
    zoneDropdown:SetPoint("LEFT", continentDropdown, "RIGHT", 0, 0)
    UIDropDownMenu_SetWidth(zoneDropdown, 110)
    UIDropDownMenu_SetText(zoneDropdown, "Select Zone")
    zoneDropdown:Hide()

    -- 3) Dropdown Location
    local locationDropdown = CreateFrame("Frame", "TrinityAdminLocationDropdown", f, "UIDropDownMenuTemplate")
    locationDropdown:SetPoint("LEFT", zoneDropdown, "RIGHT", 0, 0)
    UIDropDownMenu_SetWidth(locationDropdown, 110)
    UIDropDownMenu_SetText(locationDropdown, "Select Location")
    locationDropdown:Hide()

    -- Bouton Go
    local goButton = CreateFrame("Button", "TrinityAdminGoButton", f, "UIPanelButtonTemplate")
    goButton:SetSize(60, 22)
    goButton:SetPoint("LEFT", locationDropdown, "RIGHT", 0, 2)
    goButton:SetText("Go")
    goButton:Hide()
    goButton:SetScript("OnClick", function()
        if self.selectedCommand then
            self:TeleportTo(self.selectedCommand)
        else
            print("Veuillez sélectionner un lieu.")
        end
    end)

    -- On stocke toutes ces références
    self.frame = f
    self.continentDropdown = continentDropdown
    self.zoneDropdown = zoneDropdown
    self.locationDropdown = locationDropdown
    self.goButton = goButton
end

------------------------------------------------------------------------------
-- Remplit la liste des zones pour un continent donné
------------------------------------------------------------------------------
function TrinityAdmin:PopulateZoneDropdown(continentName)
    UIDropDownMenu_Initialize(self.zoneDropdown, function(dropdown, level, menuList)
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
            info.checked = (self.selectedZone == zoneName)
            info.func = function(button)
                self.selectedZone = zoneName
                UIDropDownMenu_SetSelectedValue(self.zoneDropdown, zoneName)
                UIDropDownMenu_SetText(self.zoneDropdown, zoneName)

                self.selectedCommand = nil
                self:PopulateLocationDropdown(continentName, zoneName)
                self.locationDropdown:Show()
                UIDropDownMenu_SetText(self.locationDropdown, "Select Location")
                self.goButton:Hide()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    -- Si on a déjà une zone sélectionnée, on l’affiche, sinon "Select Zone"
    if self.selectedZone then
        UIDropDownMenu_SetText(self.zoneDropdown, self.selectedZone)
    else
        UIDropDownMenu_SetText(self.zoneDropdown, "Select Zone")
    end
end

------------------------------------------------------------------------------
-- Remplit la liste des lieux pour un couple (continent, zone)
------------------------------------------------------------------------------
function TrinityAdmin:PopulateLocationDropdown(continentName, zoneName)
    UIDropDownMenu_Initialize(self.locationDropdown, function(dropdown, level, menuList)
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
            info.checked = (self.selectedCommand == command)
            info.func = function(button)
                self.selectedCommand = command
                UIDropDownMenu_SetSelectedValue(self.locationDropdown, locationName)
                UIDropDownMenu_SetText(self.locationDropdown, locationName)
                self.goButton:Show()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    -- Si on a déjà un lieu sélectionné, on l’affiche, sinon "Select Location"
    if self.selectedCommand then
        -- Astuce : on n’a pas gardé le *nom* du lieu, seulement la commande.
        -- Si vous voulez réellement restaurer le nom, il faudrait mémoriser locationName quelque part.
        UIDropDownMenu_SetText(self.locationDropdown, "Selected location") 
        -- ou mieux: UIDropDownMenu_SetText(self.locationDropdown, "Previously chosen location")
    else
        UIDropDownMenu_SetText(self.locationDropdown, "Select Location")
    end
end

------------------------------------------------------------------------------
-- Exécuter la commande de téléportation
------------------------------------------------------------------------------
function TrinityAdmin:TeleportTo(command)
    -- Sur votre serveur privé, envoyez la commande via le chat
    SendChatMessage(command, "SAY")
end

------------------------------------------------------------------------------
-- Panneau GM : création et affichage
------------------------------------------------------------------------------
function TrinityAdmin:ToggleGMPanel()
    if self.gmPanel and self.gmPanel:IsShown() then
        self.gmPanel:Hide()
    else
        if not self.gmPanel then
            -- Création du panneau GM en haut de la fenêtre principale
            local gm = CreateFrame("Frame", "TrinityAdminGMPanel", self.frame)
            gm:SetSize(400, 70)
            gm:SetPoint("TOP", self.frame, "TOP", 0, -30)  -- Sous le titre

            -- Fond semi-transparent
            local bg = gm:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(true)
            bg:SetColorTexture(0, 0, 0, 0.5)

            ----------------------------------------------------------------------------
            -- Bouton GM FLY
            ----------------------------------------------------------------------------
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

            ----------------------------------------------------------------------------
            -- Champ de saisie pour la valeur (EditBox)
            ----------------------------------------------------------------------------
            local modifyInput = CreateFrame("EditBox", "TrinityAdminModifyInput", gm, "InputBoxTemplate")
            modifyInput:SetSize(80, 22)
            modifyInput:SetPoint("LEFT", btnFly, "RIGHT", 20, 0)
            modifyInput:SetAutoFocus(false)
            modifyInput:SetText("Set speed")
            modifyInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

            ----------------------------------------------------------------------------
            -- Dropdown pour choisir la fonction à modifier (Speed, Money, Hp, Xp, Scale)
            ----------------------------------------------------------------------------

local modifyDropdown = CreateFrame("Frame", "TrinityAdminModifyDropdown", gm, "UIDropDownMenuTemplate")
modifyDropdown:SetPoint("LEFT", modifyInput, "RIGHT", 10, 0)
UIDropDownMenu_SetWidth(modifyDropdown, 90)
UIDropDownMenu_SetText(modifyDropdown, "Speed")
-- Initialisation du dropdown avec les choix
UIDropDownMenu_Initialize(modifyDropdown, function(dropdown, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    local options = {"Speed", "Money", "Hp", "Xp", "Scale"}
    for _, option in ipairs(options) do
        info.text = option
        info.value = option
        info.func = function(selfButton)
            UIDropDownMenu_SetSelectedValue(dropdown, selfButton.value)
            UIDropDownMenu_SetText(dropdown, selfButton.text)
            TrinityAdmin.modifyFunction = selfButton.value
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

            ----------------------------------------------------------------------------
            -- Bouton "Set" pour appliquer la modification
            ----------------------------------------------------------------------------
            local btnSet = CreateFrame("Button", nil, gm, "UIPanelButtonTemplate")
            btnSet:SetSize(60, 22)
            btnSet:SetPoint("LEFT", modifyDropdown, "RIGHT", 10, 0)
            btnSet:SetText("Set")
            btnSet:SetScript("OnClick", function()
                local value = modifyInput:GetText()
                if value == "" or value == "Set speed" then
                    print("Veuillez entrer une valeur valide.")
                else
                    -- Compose la commande selon la fonction choisie
                    local command = ".modify " .. TrinityAdmin.modifyFunction .. " " .. value
                    SendChatMessage(command, "SAY")
                end
            end)

            -- Stocke la référence du panneau GM
            self.gmPanel = gm
        end
        self.gmPanel:Show()
    end
end

------------------------------------------------------------------------------
-- Commande slash /trinityadmin pour basculer l'affichage de la fenêtre
------------------------------------------------------------------------------
function TrinityAdmin:ToggleUI(input)
    if self.frame:IsShown() then
        self.frame:Hide()
        if self.gmPanel then self.gmPanel:Hide() end
    else
        self.frame:Show()
    end
end
