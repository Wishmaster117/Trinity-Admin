local GameObjects = TrinityAdmin:GetModule("GameObjects")

-- Fonction pour afficher le panneau GameObjects
function GameObjects:ShowGameObjectsPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateGameObjectsPanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau GameObjects
function GameObjects:CreateGameObjectsPanel()
    local panel = CreateFrame("Frame", "TrinityAdminGameObjectsPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre, modifiez selon vos besoins

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("GameObjects Panel")  -- Vous pouvez utiliser TrinityAdmin_Translations si nécessaire

    -- Section: Game Objects Tools
local toolsTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
toolsTitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -20)
toolsTitle:SetText("Game Objects Tools")

-- Champ de saisie pour la commande spéciale
local specialInput = CreateFrame("EditBox", "TrinityAdminSpecialInput", panel, "InputBoxTemplate")
specialInput:SetAutoFocus(false)
specialInput:SetSize(150, 22)
specialInput:SetPoint("TOPLEFT", toolsTitle, "BOTTOMLEFT", 0, -5)
-- On lui affecte une valeur par défaut (celle de la première option)
specialInput:SetText("Enter Value")

-- Table des options du menu déroulant
local specialOptions = {
    { text = "gobject activate", command = ".gobject activate", defaultText = "Enter Gobject guid", tooltip = "Syntax: .gobject activate #guid\r\n\r\nActivates an object like a door or a button." },
    { text = "gobject add", command = ".gobject add", defaultText = "Enter Gobject Id Spawntime", tooltip = "Syntax: .gobject add #id <spawntimeSecs>\r\n\r\nAdd a game object from game object templates to the world at your current location using the #id.\r\nspawntimesecs sets the spawntime, it is optional.\r\n\r\nNote: this is a copy of .gameobject." },
    { text = "gobject add temp", command = ".gobject add temp", defaultText = "Enter Gobject guid or Id", tooltip = "Adds a temporary gameobject that is not saved to DB." },
    { text = "gobject delete", command = ".gobject delete", defaultText = "Enter Gobject guid", tooltip = "Syntax: .gobject delete #go_guid\r\nDelete gameobject with guid #go_guid." },
    { text = "gobject despawngroup", command = ".gobject despawngroup", defaultText = "Enter GroupId", tooltip = "Syntax: .gobject despawngroup $groupId [removerespawntime]." },
    { text = "gobject info", command = ".gobject info", defaultText = "Enter Entry or Link", tooltip = "Syntax: .gobject info [$entry|$link]\r\n\r\nQuery Gameobject information for given gameobject entry or link.\r\nFor example .gobject info 36." },
    { text = "gobject info guid", command = ".gobject info guid", defaultText = "Enter Guid or Link", tooltip = "Syntax: .gobject info guid [$guid|$link]\r\n\r\nQuery Gameobject information for given gameobject guid or link.\r\nFor example .gobject info guid 100" },
    { text = "gobject near", command = ".gobject near", defaultText = "Enter Distance", tooltip = "Syntax: .gobject near [#distance]\r\n\r\nOutput gameobjects at distance #distance from player. If #distance not provided, use 10 as default." },
    { text = "gobject set phase", command = ".gobject set phase", defaultText = "Enter Guid PhaseMask", tooltip = "Syntax: .gobject set phase #guid #phasemask\r\n\r\nGameobject with DB guid #guid phasemask changed to #phasemask and saved to DB." },
    { text = "gobject set state", command = ".gobject set state", defaultText = "Enter State", tooltip = "" },
    { text = "gobject spawngroup", command = ".gobject spawngroup", defaultText = "Enter GroupId", tooltip = "Syntax: .gobject spawngroup $groupId [ignorerespawn] [force]" },
    { text = "gobject target", command = ".gobject target", defaultText = "Enter Guid or Name part", tooltip = "Syntax: .gobject target [#go_id|#go_name_part]\r\n\r\nLocate and show position of the nearest gameobject matching the provided id or name part." },
}

-- Création du menu déroulant pour les options
local specialDropdown = CreateFrame("Frame", "TrinityAdminSpecialDropdown", panel, "TrinityAdminDropdownTemplate")
specialDropdown:SetPoint("LEFT", specialInput, "RIGHT", 10, 0)
UIDropDownMenu_SetWidth(specialDropdown, 220)
UIDropDownMenu_SetButtonWidth(specialDropdown, 240)
-- Initialisation de la sélection (par défaut, la première option)
specialDropdown.selectedID = 1
UIDropDownMenu_Initialize(specialDropdown, function(dropdownFrame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for i, option in ipairs(specialOptions) do
        info.text = option.text
        info.value = option.command
        info.checked = (i == specialDropdown.selectedID)
        info.func = function(buttonFrame)
            specialDropdown.selectedID = i
            UIDropDownMenu_SetSelectedID(specialDropdown, i)
            UIDropDownMenu_SetText(specialDropdown, option.text)
            specialDropdown.selectedOption = option
            -- Met à jour la valeur par défaut du champ de saisie
            specialInput:SetText(option.defaultText)
            -- Met à jour le tooltip du champ de saisie
            specialInput:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(option.tooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)
-- Affiche la première option
UIDropDownMenu_SetSelectedID(specialDropdown, specialDropdown.selectedID)
UIDropDownMenu_SetText(specialDropdown, specialOptions[specialDropdown.selectedID].text)
specialDropdown.selectedOption = specialOptions[specialDropdown.selectedID]

-- Bouton "Execute" pour lancer la commande
local btnSpecialExecute = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
btnSpecialExecute:SetSize(60, 22)
btnSpecialExecute:SetText("Execute")
btnSpecialExecute:SetPoint("TOPLEFT", specialInput, "BOTTOMLEFT", 0, -10)
btnSpecialExecute:SetScript("OnClick", function()
    local inputValue = specialInput:GetText()
    local option = specialDropdown.selectedOption
    local command = option.command
    local finalCommand = command .. " " .. inputValue
    if inputValue == "" or inputValue == option.defaultText then
        local targetName = UnitName("target")
        if targetName then
            finalCommand = command .. " " .. targetName
        else
            print("Veuillez saisir une valeur ou cibler un joueur.")
            return
        end
    end
    SendChatMessage(finalCommand, "SAY")
end)
btnSpecialExecute:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local option = specialDropdown.selectedOption or specialOptions[1]
    GameTooltip:SetText(option.tooltip, 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnSpecialExecute:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

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
