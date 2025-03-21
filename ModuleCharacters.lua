local ModuleCharacter = TrinityAdmin:GetModule("ModuleCharacter")

-- Fonction pour afficher le panneau CharactersAdmin
function ModuleCharacter:ShowModuleCharacterPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateModuleCharacterPanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau CharactersAdmin
function ModuleCharacter:CreateModuleCharacterPanel()
    local panel = CreateFrame("Frame", "TrinityAdminCharactersAdminPanel", TrinityAdminMainFrame)
    panel:SetSize(680, 340)
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Player/Characters/Pets Functions")

    -------------------------------------------------------------------------------
    -- Création de plusieurs pages dans le panneau
    -------------------------------------------------------------------------------
	local totalPages = 7  -- nombre de pages
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
	
	local inputFields = {}  -- table pour stocker tous les champs et leur texte par défaut

--------------------------------------------------------------------
-- Page 1
--------------------------------------------------------------------
local commandsFramePage1 = CreateFrame("Frame", nil, pages[1])
commandsFramePage1:SetPoint("TOPLEFT", pages[1], "TOPLEFT", 20, -40)
commandsFramePage1:SetSize(500, 350)

local page1Title = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page1Title:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, 0)
page1Title:SetText("Player Functions 1")

-- Scripte pour actions des boutons simples:
local function CreateServerButtonPage1(name, text, tooltip, cmd)
    local btn = CreateFrame("Button", name, commandsFramePage1, "UIPanelButtonTemplate")
    btn:SetSize(150, 22)
    btn:SetText(text)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    btn:SetScript("OnClick", function(self)
        SendChatMessage(cmd, "SAY")
        print("Commande envoyée: " .. cmd)
    end)
    return btn
end
	
-- Ajout du champ de saisie et bouton Add Aura
local spellIdInput = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
spellIdInput:SetSize(150, 22)
spellIdInput:SetPoint("TOPLEFT", page1Title, "BOTTOMLEFT", 0, -15)
spellIdInput:SetAutoFocus(false)
spellIdInput.defaultText = "Enter SpellId"
spellIdInput:SetText(spellIdInput.defaultText)
spellIdInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
spellIdInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

-- Stocke dans la table inputFields
table.insert(inputFields, spellIdInput)


local btnAddAura = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
btnAddAura:SetSize(100, 22)
btnAddAura:SetText("Add Aura")
btnAddAura:SetPoint("LEFT", spellIdInput, "RIGHT", 10, 0)
btnAddAura:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .aura #spellid\n\nAdd the aura from spell #spellid to the selected Unit.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnAddAura:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnAddAura:SetScript("OnClick", function()
    local spellId = spellIdInput:GetText()
    if spellId == "" or spellId == "Enter SpellId" then
        print("Veuillez entrer un SpellId valide.")
        return
    end
    local cmd = ".aura " .. spellId
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

-- Ajout du champ de saisie et bouton Remove Aura
local spellIdInputRemove = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
spellIdInputRemove:SetSize(150, 22)
spellIdInputRemove:SetPoint("TOPLEFT", spellIdInput, "BOTTOMLEFT", 0, -15)
spellIdInputRemove:SetAutoFocus(false)
spellIdInputRemove.defaultText = "Enter SpellId" -- Ajout nécessaire
spellIdInputRemove:SetText(spellIdInputRemove.defaultText)
spellIdInputRemove:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
spellIdInputRemove:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

-- Stocke dans la table inputFields
table.insert(inputFields, spellIdInputRemove)

local btnAddAuraRemove = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
btnAddAuraRemove:SetSize(100, 22)
btnAddAuraRemove:SetText("Remove Aura")
btnAddAuraRemove:SetPoint("LEFT", spellIdInputRemove, "RIGHT", 10, 0)
btnAddAuraRemove:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .unaura #spellid\r\n\r\nRemove aura due to spell #spellid from the selected Unit.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnAddAuraRemove:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnAddAuraRemove:SetScript("OnClick", function()
    local spellId = spellIdInputRemove:GetText()
    if spellId == "" or spellId == "Enter SpellId" then
        print("Veuillez entrer un SpellId valide.")
        return
    end
    local cmd = ".unaura " .. spellId
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

-- Champ de saisie "Player Name"
local playerNameInput = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
playerNameInput:SetSize(150, 22)
playerNameInput:SetPoint("TOPLEFT", spellIdInputRemove, "BOTTOMLEFT", 0, -15)
playerNameInput:SetAutoFocus(false)
playerNameInput.defaultText = "Player Name"
playerNameInput:SetText(playerNameInput.defaultText)
playerNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
playerNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

-- Enregistrement du champ dans la table inputFields
table.insert(inputFields, playerNameInput)

-- Champ de saisie "Duration (s)"
local durationInput = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
durationInput:SetSize(150, 22)
durationInput:SetPoint("LEFT", playerNameInput, "RIGHT", 10, 0)
durationInput:SetAutoFocus(false)
durationInput.defaultText = "Duration (s)"
durationInput:SetText(durationInput.defaultText)
durationInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
durationInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

-- Enregistrement du champ dans la table inputFields
table.insert(inputFields, durationInput)

-- Bouton "Freeze"
local btnFreeze = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
btnFreeze:SetSize(100, 22)
btnFreeze:SetText("Freeze")
btnFreeze:SetPoint("LEFT", durationInput, "RIGHT", 10, 0)
btnFreeze:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .freeze [#player] [#duration]\nFreezes #player for #duration (seconds)\nFreezes the selected player if no arguments are given.\nDefault duration: GM.FreezeAuraDuration (worldserver.conf)", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnFreeze:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnFreeze:SetScript("OnClick", function()
    local playerName = playerNameInput:GetText()
    local duration = durationInput:GetText()

    -- Vérifie et remplace automatiquement le nom du joueur par celui de la cible actuelle si vide
    if playerName == "" or playerName == playerNameInput.defaultText then
        playerName = UnitName("target")
        if playerName then
            print("La Cible est : " .. playerName) -- Pour debug
        else
            print("Veuillez entrer un nom de joueur valide ou sélectionner une cible.")
            return
        end
    end
	
    -- Vérifie et définit une durée par défaut (60s) si non précisée
    if duration == "" or duration == durationInput.defaultText then
        duration = "60"
    end

    local cmd = ".freeze " .. playerName .. " " .. duration
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

-- Champ de saisie "Player Name" pour UnFreeze
local playerNameUnfreezeInput = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
playerNameUnfreezeInput:SetSize(150, 22)
playerNameUnfreezeInput:SetPoint("TOPLEFT", playerNameInput, "BOTTOMLEFT", 0, -15)
playerNameUnfreezeInput:SetAutoFocus(false)
playerNameUnfreezeInput.defaultText = "Player Name"
playerNameUnfreezeInput:SetText(playerNameUnfreezeInput.defaultText)
playerNameUnfreezeInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
playerNameUnfreezeInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

-- Ajout dans la table inputFields pour réinitialisation automatique
table.insert(inputFields, playerNameUnfreezeInput)

-- Bouton "UnFreeze"
local btnUnfreeze = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
btnUnfreeze:SetSize(100, 22)
btnUnfreeze:SetText("UnFreeze")
btnUnfreeze:SetPoint("LEFT", playerNameUnfreezeInput, "RIGHT", 10, 0)
btnUnfreeze:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .unfreeze (#player)\n\n\"Unfreezes\" #player and enables his chat again. When using this without #name it will unfreeze your target.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnUnfreeze:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnUnfreeze:SetScript("OnClick", function()
    local playerName = playerNameUnfreezeInput:GetText()

    -- Vérifie et remplace automatiquement le nom du joueur par celui de la cible actuelle si vide
    if playerName == "" or playerName == playerNameUnfreezeInput.defaultText then
        playerName = UnitName("target")
        if playerName then
            print("La Cible est : " .. playerName) -- Pour debug
        else
            print("Veuillez entrer un nom de joueur valide ou sélectionner une cible.")
            return
        end
    end
	
    local cmd = ".unfreeze " .. playerName
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)


-- Bouton liste des joueurs Freeze
local btnFreezeList = CreateServerButtonPage1("FreezeListButton", "Freeze List", "Syntax: .listfreeze\r\n\r\nSearch and output all frozen players.", ".listfreeze")
btnFreezeList:SetPoint("TOPLEFT", btnUnfreeze, "TOPRIGHT", 10, 0)

	
-- Fonction polyvalente pour réinitialiser les champs de saisie
local function ResetInputs()
    for _, input in ipairs(inputFields) do
        if input:GetText() ~= input.defaultText then
            input:SetText(input.defaultText)
        end
    end
end


-- Bouton Reset Inputs
local btnResetInputs = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText("Reset Inputs")
btnResetInputs:SetPoint("TOPLEFT", playerNameUnfreezeInput, "BOTTOMLEFT", 0, -15)
btnResetInputs:SetScript("OnClick", ResetInputs)

--------------------------------------------------------------------
-- Page 2
--------------------------------------------------------------------
local commandsFramePage2 = CreateFrame("Frame", nil, pages[2])
commandsFramePage2:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
commandsFramePage2:SetSize(500, 350)

local page2Title = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page2Title:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, 0)
page2Title:SetText("Player Functions 2")

-- Fonction améliorée pour les boutons simples appliquant la commande à la cible ou au GM par défaut
local function CreateServerButtonPage2(name, text, tooltip, cmd)
    local btn = CreateFrame("Button", name, commandsFramePage2, "UIPanelButtonTemplate")
    btn:SetSize(150, 22)
    btn:SetText(text)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    btn:SetScript("OnClick", function(self)
        local targetName = UnitName("target")
        local finalCmd

        if targetName then
            finalCmd = cmd .. " " .. targetName
        else
            finalCmd = cmd -- sans cible (appliqué au GM lui-même)
        end

        SendChatMessage(finalCmd, "SAY")
        print("Commande envoyée: " .. finalCmd)
    end)
    return btn
end

-- Fonction polyvalente pour réinitialiser les champs de saisie
local function ResetInputs()
    for _, input in ipairs(inputFields) do
        if input:GetText() ~= input.defaultText then
            input:SetText(input.defaultText)
        end
    end
end

-- Bouton Repaire
local btnRepairItems = CreateServerButtonPage2("RepairItemsButton", "Repair Items", "Syntax: .repairitems\n\nRepair all selected player's items.", ".repairitems")
btnRepairItems:SetPoint("TOPLEFT", page2Title, "BOTTOMLEFT", 0, -15)

-- Bouton unpossess
local btnUnpossess = CreateServerButtonPage2("UnpossessButton", "Unpossess", "Syntax: .unpossess\r\n\r\nIf you are possessed, unpossesses yourself; otherwise unpossesses current possessed target.", ".unpossess")
btnUnpossess:SetPoint("TOPLEFT", btnRepairItems, "TOPRIGHT", 10, 0)

----------------------------
-- Section Unstuck
----------------------------	
-- Champ de saisie "Player Name" pour unstuck
local playerNameunstuckInput = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
playerNameunstuckInput:SetSize(150, 22)
playerNameunstuckInput:SetPoint("TOPLEFT", btnRepairItems, "BOTTOMLEFT", 0, -15)
playerNameunstuckInput:SetAutoFocus(false)
playerNameunstuckInput.defaultText = "Player Name"
playerNameunstuckInput:SetText(playerNameunstuckInput.defaultText)
playerNameunstuckInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
playerNameunstuckInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

-- Ajout dans la table inputFields pour réinitialisation automatique
table.insert(inputFields, playerNameunstuckInput)

-- Création du Dropdown "Location" pour unstuck
local unstuckLocationDropdown = CreateFrame("Frame", "UnstuckLocationDropdown", commandsFramePage2, "UIDropDownMenuTemplate")
unstuckLocationDropdown:SetPoint("TOPLEFT", playerNameunstuckInput, "TOPRIGHT", -10, 4)

-- Définition des options
local locations = {
    { text = "inn", value = "inn" },
    { text = "graveyard", value = "graveyard" },
    { text = "startzone", value = "startzone" },
}

local selectedLocation = locations[1].value -- Valeur par défaut

-- Fonction pour initialiser le menu déroulant
UIDropDownMenu_SetWidth(unstuckLocationDropdown, 120)
UIDropDownMenu_SetText(unstuckLocationDropdown, "Location")

UIDropDownMenu_Initialize(unstuckLocationDropdown, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for _, loc in ipairs(locations) do
        info.text = loc.text
        info.value = loc.value
        info.func = function(self)
            selectedLocation = self.value
            UIDropDownMenu_SetText(unstuckLocationDropdown, self:GetText())
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- Bouton "Unstuck"
local btnUnstuck = CreateFrame("Button", nil, commandsFramePage2, "UIPanelButtonTemplate")
btnUnstuck:SetSize(100, 22)
btnUnstuck:SetText("UnStucke")
btnUnstuck:SetPoint("LEFT", unstuckLocationDropdown, "RIGHT", 10, 0)
btnUnstuck:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .unstuck $playername [inn/graveyard/startzone]\n\nTeleports specified player to specified location. Default location is player\'s current hearth location.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnUnstuck:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnUnstuck:SetScript("OnClick", function()
    local playerName = playerNameunstuckInput:GetText()

    -- Vérifie et remplace automatiquement le nom du joueur par celui de la cible actuelle si vide
    if playerName == "" or playerName == playerNameunstuckInput.defaultText then
        playerName = UnitName("target")
        if playerName then
            print("La Cible est : " .. playerName) -- Pour debug
        else
            print("Veuillez entrer un nom de joueur valide ou sélectionner une cible.")
            return
        end
    end
	
    local cmd = ".unstuck " .. playerName .. " " .. selectedLocation
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Section Kick
----------------------------
-- Champ de saisie "Player Name"
local kickNameInput = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
kickNameInput:SetSize(150, 22)
kickNameInput:SetPoint("TOPLEFT", playerNameunstuckInput, "BOTTOMLEFT", 0, -15)
kickNameInput:SetAutoFocus(false)
kickNameInput.defaultText = "Player Name"
kickNameInput:SetText(kickNameInput.defaultText)
kickNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
kickNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

-- Enregistrement du champ dans la table inputFields
table.insert(inputFields, kickNameInput)

-- Champ de saisie "Raison"
local reasonInput = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
reasonInput:SetSize(150, 22)
reasonInput:SetPoint("LEFT", kickNameInput, "RIGHT", 10, 0)
reasonInput:SetAutoFocus(false)
reasonInput.defaultText = "Reason"
reasonInput:SetText(reasonInput.defaultText)
reasonInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
reasonInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

-- Enregistrement du champ dans la table inputFields
table.insert(inputFields, reasonInput)

-- Bouton "Kick"
local btnKick = CreateFrame("Button", nil, commandsFramePage2, "UIPanelButtonTemplate")
btnKick:SetSize(100, 22)
btnKick:SetText("Kick")
btnKick:SetPoint("LEFT", reasonInput, "RIGHT", 10, 0)
btnKick:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("'Syntax: .kick [$charactername] [$reason]\r\n\r\nKick the given character name from the world with or without reason. If no character name is provided then the selected player (except for yourself) will be kicked. If no reason is provided, default is No Reason.)", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnKick:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnKick:SetScript("OnClick", function()
    local playerName = kickNameInput:GetText()
    local reason = reasonInput:GetText()

    -- Vérifie et remplace automatiquement le nom du joueur par celui de la cible actuelle si vide
    if playerName == "" or playerName == kickNameInput.defaultText then
        playerName = UnitName("target")
        if playerName then
            print("La Cible est : " .. playerName) -- Pour debug
        else
            print("Veuillez entrer un nom de joueur valide ou sélectionner une cible.")
            return
        end
    end
	
    -- Vérifie et définit une durée par défaut (60s) si non précisée
    if reason == "" or reason == reasonInput.defaultText then
        reason = "Oust !!"
    end

    local cmd = ".kick " .. playerName .. " " .. reason
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Section Levelup
----------------------------

-- Champ de saisie "Player Name"
local levelupNameInput = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
levelupNameInput:SetSize(150, 22)
levelupNameInput:SetPoint("TOPLEFT", kickNameInput, "BOTTOMLEFT", 0, -15)
levelupNameInput:SetAutoFocus(false)
levelupNameInput.defaultText = "Player Name"
levelupNameInput:SetText(levelupNameInput.defaultText)
levelupNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
levelupNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

-- Enregistrement du champ dans la table inputFields
table.insert(inputFields, levelupNameInput)

-- Champ de saisie "Levels"
local levelsInput = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
levelsInput:SetSize(150, 22)
levelsInput:SetPoint("LEFT", levelupNameInput, "RIGHT", 10, 0)
levelsInput:SetAutoFocus(false)
levelsInput.defaultText = "Levels ?"
levelsInput:SetText(levelsInput.defaultText)
levelsInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
levelsInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

-- Enregistrement du champ dans la table inputFields
table.insert(inputFields, levelsInput)

-- Bouton "Levelup"
local btnLevelup = CreateFrame("Button", nil, commandsFramePage2, "UIPanelButtonTemplate")
btnLevelup:SetSize(100, 22)
btnLevelup:SetText("LevelUp")
btnLevelup:SetPoint("LEFT", levelsInput, "RIGHT", 10, 0)
btnLevelup:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("'Syntax: .levelup [$playername] [#numberoflevels]\r\n\r\nIncrease/decrease the level of character with $playername (or the selected if not name provided) by #numberoflevels Or +1 if no #numberoflevels provided). If #numberoflevels is omitted, the level will be increase by 1. If #numberoflevels is 0, the same level will be restarted. If no character is selected and name not provided, increase your level. Command can be used for offline character. All stats and dependent values recalculated. At level decrease talents can be reset if need. Also at level decrease equipped items with greater level requirement can be lost.)", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnLevelup:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnLevelup:SetScript("OnClick", function()
    local playerName = levelupNameInput:GetText()
    local level = levelsInput:GetText()

    -- Vérifie et remplace automatiquement le nom du joueur par celui de la cible actuelle si vide
    if playerName == "" or playerName == levelupNameInput.defaultText then
        playerName = UnitName("target")
        if playerName then
            print("La Cible est : " .. playerName)
        else
            print("Aucune cible sélectionnée.")
            print("Veuillez entrer un nom de joueur valide ou sélectionner une cible.")
            return
        end
    end

    -- Vérifie et définit une durée par défaut (60s) si non précisée
    if level == "" or level == levelsInput.defaultText then
        level = "1"
    end

    local cmd = ".levelup " .. playerName .. " " .. level
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Bouton Reset Inputs
----------------------------
local btnResetInputs = CreateFrame("Button", nil, commandsFramePage2, "UIPanelButtonTemplate")
btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText("Reset Inputs")
btnResetInputs:SetPoint("TOPLEFT", btnLevelup, "BOTTOMLEFT", 0, -15)
btnResetInputs:SetScript("OnClick", ResetInputs)

---------------------------------------------------------------
-- Page 3
---------------------------------------------------------------
local commandsFramePage3 = CreateFrame("Frame", nil, pages[3])
commandsFramePage3:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
commandsFramePage3:SetSize(500, 350)

local page3Title = commandsFramePage3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page3Title:SetPoint("TOPLEFT", commandsFramePage3, "TOPLEFT", 0, 0)
page3Title:SetText("Characters Functions")

-- Fonction polyvalente pour réinitialiser les champs de saisie
local function ResetInputs()
    for _, input in ipairs(inputFields) do
        if input:GetText() ~= input.defaultText then
            input:SetText(input.defaultText)
        end
    end
end

----------------------------
-- Fonction char rename
----------------------------
-- Champ de saisie "Name"
local renameNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
renameNameInput:SetSize(150, 22)
renameNameInput:SetPoint("TOPLEFT", page3Title, "BOTTOMLEFT", 0, -20)
renameNameInput:SetAutoFocus(false)
renameNameInput.defaultText = "Character Name"
renameNameInput:SetText(renameNameInput.defaultText)
renameNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
renameNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, renameNameInput)

-- Champ de saisie "New Name"
local renameNewNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
renameNewNameInput:SetSize(150, 22)
renameNewNameInput:SetPoint("LEFT", renameNameInput, "RIGHT", 10, 0)
renameNewNameInput:SetAutoFocus(false)
renameNewNameInput.defaultText = "New Name"
renameNewNameInput:SetText(renameNewNameInput.defaultText)
renameNewNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
renameNewNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, renameNewNameInput)

-- Bouton "Rename"
local btnRename = CreateFrame("Button", nil, commandsFramePage3, "UIPanelButtonTemplate")
btnRename:SetSize(100, 22)
btnRename:SetText("Rename")
btnRename:SetPoint("LEFT", renameNewNameInput, "RIGHT", 10, 0)
btnRename:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .character rename [$name] [$newName]\n\nMark selected in-game or by $name in command character for rename at next login.\n\nIf $newName then the player will be forced rename.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnRename:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnRename:SetScript("OnClick", function()
    local nameValue = renameNameInput:GetText()
    local newNameValue = renameNewNameInput:GetText()

    -- Si "Name" vide, utilise la cible du GM
    if nameValue == "" or nameValue == renameNameInput.defaultText then
        nameValue = UnitName("target")
        if not nameValue then
            print("Veuillez entrer un nom valide ou sélectionner une cible.")
            return
        end
    end

    local cmd = ".character rename " .. nameValue

    -- Ajoute le nouveau nom seulement s'il est précisé
    if newNameValue ~= "" and newNameValue ~= renameNewNameInput.defaultText then
        cmd = cmd .. " " .. newNameValue
    end

    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction char reputation
----------------------------

-- Champ de saisie "Name"
local reputationNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
reputationNameInput:SetSize(150, 22)
reputationNameInput:SetPoint("TOPLEFT", renameNameInput, "BOTTOMLEFT", 0, -10)
reputationNameInput:SetAutoFocus(false)
reputationNameInput.defaultText = "Character Name"
reputationNameInput:SetText(reputationNameInput.defaultText)
reputationNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
reputationNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, reputationNameInput)

-- Bouton "Rename"
local btnReputation = CreateFrame("Button", nil, commandsFramePage3, "UIPanelButtonTemplate")
btnReputation:SetSize(130, 22)
btnReputation:SetText("Show Reputation")
btnReputation:SetPoint("LEFT", reputationNameInput, "RIGHT", 10, 0)
btnReputation:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .character reputation [$player_name]\r\n\r\nShow reputation information for selected player or player find by $player_name.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnReputation:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnReputation:SetScript("OnClick", function()
    local nameValue = reputationNameInput:GetText()

    -- Si "Name" vide, utilise la cible du GM
    if nameValue == "" or nameValue == reputationNameInput.defaultText then
        nameValue = UnitName("target")
        if not nameValue then
            print("Veuillez entrer un nom valide ou sélectionner une cible.")
            return
        end
    end

    local cmd = ".character reputation " .. nameValue

    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction char Titles
----------------------------

-- Champ de saisie "Name"
local titlesNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
titlesNameInput:SetSize(150, 22)
titlesNameInput:SetPoint("TOPLEFT", reputationNameInput, "BOTTOMLEFT", 0, -10)
titlesNameInput:SetAutoFocus(false)
titlesNameInput.defaultText = "Character Name"
titlesNameInput:SetText(titlesNameInput.defaultText)
titlesNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
titlesNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, titlesNameInput)

-- Bouton "Titles"
local btnTitles = CreateFrame("Button", nil, commandsFramePage3, "UIPanelButtonTemplate")
btnTitles:SetSize(110, 22)
btnTitles:SetText("Show Titles")
btnTitles:SetPoint("LEFT", titlesNameInput, "RIGHT", 10, 0)
btnTitles:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .character titles [$player_name]\r\n\r\nShow known titles list for selected player or player find by $player_name.'", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnTitles:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnTitles:SetScript("OnClick", function()
    local nameValue = titlesNameInput:GetText()

    -- Si "Name" vide, utilise la cible du GM
    if nameValue == "" or nameValue == titlesNameInput.defaultText then
        nameValue = UnitName("target")
        if not nameValue then
            print("Veuillez entrer un nom valide ou sélectionner une cible.")
            return
        end
    end

    local cmd = ".character titles " .. nameValue

    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction char Changerace
----------------------------

-- Champ de saisie "Name"
local changeraceNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
changeraceNameInput:SetSize(150, 22)
changeraceNameInput:SetPoint("TOPLEFT", titlesNameInput, "BOTTOMLEFT", 0, -10)
changeraceNameInput:SetAutoFocus(false)
changeraceNameInput.defaultText = "Character Name"
changeraceNameInput:SetText(changeraceNameInput.defaultText)
changeraceNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
changeraceNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, changeraceNameInput)

-- Bouton "ChangeRace"
local btnChangeRace = CreateFrame("Button", nil, commandsFramePage3, "UIPanelButtonTemplate")
btnChangeRace:SetSize(120, 22)
btnChangeRace:SetText("Change Race")
btnChangeRace:SetPoint("LEFT", changeraceNameInput, "RIGHT", 10, 0)
btnChangeRace:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .character changerace $name\r\n\r\nChange character race.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnChangeRace:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnChangeRace:SetScript("OnClick", function()
    local nameValue = changeraceNameInput:GetText()

    -- Si "Name" est vide, utilise automatiquement la cible actuelle
    if nameValue == "" or nameValue == changeraceNameInput.defaultText or not nameValue then
        print("Veuillez entrer un nom valide ou sélectionner une cible.")
        return
    end

    local cmd = ".character changerace " .. nameValue

    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction char Changefaction
----------------------------

-- Champ de saisie "Name"
local changefactionNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
changefactionNameInput:SetSize(150, 22)
changefactionNameInput:SetPoint("TOPLEFT", changeraceNameInput, "BOTTOMLEFT", 0, -10)
changefactionNameInput:SetAutoFocus(false)
changefactionNameInput.defaultText = "Character Name"
changefactionNameInput:SetText(changefactionNameInput.defaultText)
changefactionNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
changefactionNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, changefactionNameInput)

-- Bouton "ChangeRace"
local btnChangefaction = CreateFrame("Button", nil, commandsFramePage3, "UIPanelButtonTemplate")
btnChangefaction:SetSize(120, 22)
btnChangefaction:SetText("Change Faction")
btnChangefaction:SetPoint("LEFT", changefactionNameInput, "RIGHT", 10, 0)
btnChangefaction:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .character changefaction $name\r\n\r\nChange character faction.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnChangefaction:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnChangefaction:SetScript("OnClick", function()
    local nameValue = changefactionNameInput:GetText()

    -- Si "Name" est vide, utilise automatiquement la cible actuelle
    if nameValue == "" or nameValue == changefactionNameInput.defaultText or not nameValue then
        print("Veuillez entrer un nom valide ou sélectionner une cible.")
        return
    end

    local cmd = ".character changefaction " .. nameValue

    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction char Customize
----------------------------
	
-- Champ de saisie "Name"
local customizeNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
customizeNameInput:SetSize(150, 22)
customizeNameInput:SetPoint("TOPLEFT", changefactionNameInput, "BOTTOMLEFT", 0, -10)
customizeNameInput:SetAutoFocus(false)
customizeNameInput.defaultText = "Character Name"
customizeNameInput:SetText(customizeNameInput.defaultText)
customizeNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
customizeNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, customizeNameInput)

-- Bouton "ChangeRace"
local btnCustomize = CreateFrame("Button", nil, commandsFramePage3, "UIPanelButtonTemplate")
btnCustomize:SetSize(140, 22)
btnCustomize:SetText("Character Customize")
btnCustomize:SetPoint("LEFT", customizeNameInput, "RIGHT", 10, 0)
btnCustomize:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .character customize [$name]\r\n\r\nMark selected in game or by $name in command character for customize at next login.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnCustomize:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnCustomize:SetScript("OnClick", function()
    local nameValue = customizeNameInput:GetText()

    -- Si "Name" est vide, utilise automatiquement la cible actuelle
    if nameValue == "" or nameValue == customizeNameInput.defaultText or not nameValue then
        print("Veuillez entrer un nom valide ou sélectionner une cible.")
        return
    end

    local cmd = ".character customize " .. nameValue

    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction change level
----------------------------
-- Champ de saisie "Character Name"
local charNameLevelInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
charNameLevelInput:SetSize(150, 22)
charNameLevelInput:SetPoint("TOPLEFT", customizeNameInput, "BOTTOMLEFT", 0, -10)
charNameLevelInput:SetAutoFocus(false)
charNameLevelInput.defaultText = "Character Name"
charNameLevelInput:SetText(charNameLevelInput.defaultText)
charNameLevelInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
charNameLevelInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, charNameLevelInput)

-- Champ de saisie "Level"
local levelValueInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
levelValueInput:SetSize(100, 22)
levelValueInput:SetPoint("LEFT", charNameLevelInput, "RIGHT", 10, 0)
levelValueInput:SetAutoFocus(false)
levelValueInput.defaultText = "Level"
levelValueInput:SetText(levelValueInput.defaultText)
levelValueInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
levelValueInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, levelValueInput)

-- Bouton "Set Level"
local btnSetLevel = CreateFrame("Button", nil, commandsFramePage3, "UIPanelButtonTemplate")
btnSetLevel:SetSize(100, 22)
btnSetLevel:SetText("Set")
btnSetLevel:SetPoint("LEFT", levelValueInput, "RIGHT", 10, 0)
btnSetLevel:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        "Syntax: .character level [$playername] [#level]\n\nSet the level of character with $playername (or the selected if not name provided) by #numberoflevels or +1 if no #numberoflevels provided. If #numberoflevels is omitted, the level will increase by 1. If #numberoflevels is 0, the same level will be restarted. If no character is selected and name not provided, increases your level. Command can be used for offline character. All stats and dependent values recalculated. At level decrease talents can be reset if needed. Also at level decrease equipped items with greater level requirement can be lost.",
        1, 1, 1, 1, true
    )
    GameTooltip:Show()
end)
btnSetLevel:SetScript("OnLeave", function() GameTooltip:Hide() end)

btnSetLevel:SetScript("OnClick", function()
    local charName = charNameLevelInput:GetText()
    local level = levelValueInput:GetText()

    -- Si le nom n'est pas renseigné, utiliser la cible actuelle
    if charName == "" or charName == charNameLevelInput.defaultText then
        charName = UnitName("target")
        if not charName then
            print("Veuillez entrer un nom valide ou sélectionner une cible.")
            return
        end
    end

    local cmd = ".character level " .. charName

    -- Si un niveau est renseigné, ajoute-le à la commande
    if level ~= "" and level ~= levelValueInput.defaultText then
        cmd = cmd .. " " .. level
    end

    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)
----------------------------
-- Bouton Reset Inputs
----------------------------
local btnResetInputs = CreateFrame("Button", nil, commandsFramePage3, "UIPanelButtonTemplate")
btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText("Reset Inputs")
btnResetInputs:SetPoint("TOPRIGHT", page3Title, "TOPRIGHT", 420, -15)
btnResetInputs:SetScript("OnClick", ResetInputs)	
---------------------------------------------------------------
-- Page 4
---------------------------------------------------------------
local commandsFramePage4 = CreateFrame("Frame", nil, pages[4])
commandsFramePage4:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
commandsFramePage4:SetSize(500, 350)

local page4Title = commandsFramePage4:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page4Title:SetPoint("TOPLEFT", commandsFramePage4, "TOPLEFT", 0, 0)
page4Title:SetText("Character Functions 2")

-- Fonction polyvalente pour réinitialiser les champs de saisie
local function ResetInputs()
    for _, input in ipairs(inputFields) do
        if input:GetText() ~= input.defaultText then
            input:SetText(input.defaultText)
        end
    end
end

----------------------------
-- character changeaccount
----------------------------
-- Champ de saisie "Name"
local characterchangeaccountNameInput = CreateFrame("EditBox", nil, commandsFramePage4, "InputBoxTemplate")
characterchangeaccountNameInput:SetSize(150, 22)
characterchangeaccountNameInput:SetPoint("TOPLEFT", page3Title, "BOTTOMLEFT", 0, -20)
characterchangeaccountNameInput:SetAutoFocus(false)
characterchangeaccountNameInput.defaultText = "Character Name"
characterchangeaccountNameInput:SetText(characterchangeaccountNameInput.defaultText)
characterchangeaccountNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
characterchangeaccountNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, characterchangeaccountNameInput)

-- Champ de saisie "New Name"
local accountNewAccountInput = CreateFrame("EditBox", nil, commandsFramePage4, "InputBoxTemplate")
accountNewAccountInput:SetSize(150, 22)
accountNewAccountInput:SetPoint("LEFT", characterchangeaccountNameInput, "RIGHT", 10, 0)
accountNewAccountInput:SetAutoFocus(false)
accountNewAccountInput.defaultText = "Account"
accountNewAccountInput:SetText(accountNewAccountInput.defaultText)
accountNewAccountInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
accountNewAccountInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, accountNewAccountInput)

-- Bouton "Rename"
local btnRename = CreateFrame("Button", nil, commandsFramePage4, "UIPanelButtonTemplate")
btnRename:SetSize(120, 22)
btnRename:SetText("Change Account")
btnRename:SetPoint("LEFT", accountNewAccountInput, "RIGHT", 10, 0)
btnRename:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .character changeaccount [$player] $account\n\nTransfers ownership of named (or selected) character to another account", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnRename:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnRename:SetScript("OnClick", function()
    local nameValue = characterchangeaccountNameInput:GetText()
    local newAccountValue = accountNewAccountInput:GetText()

    -- Si "Name" vide, utilise la cible du GM
    if nameValue == "" or nameValue == characterchangeaccountNameInput.defaultText then
        nameValue = UnitName("target")
        if not nameValue or newAccountValue == "" or newAccountValue == accountNewAccountInput.defaultText then
            print("Veuillez entrer un nom valide, un compte valide et/ou sélectionner une cible.")
            return
        end
    end
	
    local cmd = ".character changeaccount " .. nameValue .. " " ..newAccountValue
	
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- character deleted delete and others
----------------------------
-- Vérifie l'existence de la table inputFields
if not inputFields then inputFields = {} end

-- Définition des options du dropdown
local dropdownOptions = {
    { text = "character deleted delete", defaultText = "Enter Char Name or Guid", command = ".character deleted delete", tooltip = "Syntax: .character deleted delete #guid|$name\r\nCompletely deletes the selected characters.\r\nIf $name is supplied, only characters with that string in their name will be deleted,\r\nif #guid is supplied, only the character with that GUID will be deleted." },
    { text = "character deleted list", defaultText = "Enter Char Name or Guid", command = ".character deleted list", tooltip = "Syntax: .character deleted list [#guid|$name]\r\nShows a list with all deleted characters.\r\nIf $name is supplied, only characters with that string in their name will be selected,\r\nif #guid is supplied, only the character with that GUID will be selected." },
    { text = "character deleted old", defaultText = "Enter keepDays Value", command = ".character deleted old", tooltip = "Syntax: .character deleted old [#keepDays]\r\nCompletely deletes all characters with deleted time longer #keepDays.\r\nIf #keepDays not provided the used value from mangosd.conf option 'CharDelete.KeepDays'.\r\nIf referenced config option disabled (use 0 value) then command can't be used without #keepDays." },
    { text = "character erase", defaultText = "Enter Char Name", command = ".character erase", tooltip = "Syntax: .character erase $name\r\nDelete character $name. Character finally deleted in case any deleting options." },
}

local selectedOption = dropdownOptions[1] -- Option par défaut initiale

-- Création du champ de saisie dynamique
local dynamicInput = CreateFrame("EditBox", nil, commandsFramePage4, "InputBoxTemplate")
dynamicInput:SetSize(150, 22)
dynamicInput:SetPoint("TOPLEFT", characterchangeaccountNameInput, "BOTTOMLEFT", 0, -20)
dynamicInput:SetAutoFocus(false)
dynamicInput.defaultText = selectedOption.defaultText
dynamicInput:SetText(dynamicInput.defaultText)

dynamicInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
dynamicInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, dynamicInput)

-- Dropdown menu
local dynamicDropdown = CreateFrame("Frame", "DynamicDropdownMenu", commandsFramePage4, "UIDropDownMenuTemplate")
dynamicDropdown:SetPoint("LEFT", dynamicInput, "RIGHT", -10, -2)
UIDropDownMenu_SetWidth(dynamicDropdown, 150)
UIDropDownMenu_SetText(dynamicDropdown, selectedOption.text)

local function UpdateDynamicInput(option)
    selectedOption = option
    dynamicInput.defaultText = option.defaultText
    dynamicInput:SetText(dynamicInput.defaultText)
end

UIDropDownMenu_Initialize(dynamicDropdown, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for _, option in ipairs(dropdownOptions) do
        info.text = option.text
		info.checked = (selectedOption.text == option.text) -- Ici est la clé
        info.func = function()
            UIDropDownMenu_SetText(dynamicDropdown, option.text)
            UpdateDynamicInput(option)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- Bouton "Execute"
local btnExecute = CreateFrame("Button", nil, commandsFramePage4, "UIPanelButtonTemplate")
btnExecute:SetSize(100, 22)
btnExecute:SetText("Execute")
btnExecute:SetPoint("LEFT", dynamicDropdown, "RIGHT", -5, 2)

btnExecute:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(selectedOption.tooltip, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnExecute:SetScript("OnLeave", function() GameTooltip:Hide() end)

btnExecute:SetScript("OnClick", function()
    local inputValue = dynamicInput:GetText()

    -- Vérification rigoureuse du contenu du champ de saisie
    if inputValue == "" or inputValue == dynamicInput.defaultText then
        print("Veuillez entrer une valeur valide dans le champ de saisie.")
        return
    end

    local finalCmd = selectedOption.command .. " " .. inputValue

    SendChatMessage(finalCmd, "SAY")
    print("Commande envoyée : " .. finalCmd)
end)


----------------------------
-- Fonction Restore
----------------------------

-- Champ obligatoire "Enter Char Name or Guid"
local restoreCharGuidInput = CreateFrame("EditBox", nil, commandsFramePage4, "InputBoxTemplate")
restoreCharGuidInput:SetSize(170, 22)
restoreCharGuidInput:SetPoint("TOPLEFT", dynamicInput, "TOPLEFT", 0, -40)
restoreCharGuidInput:SetAutoFocus(false)
restoreCharGuidInput.defaultText = "Enter Char Name or Guid"
restoreCharGuidInput:SetText(restoreCharGuidInput.defaultText)
restoreCharGuidInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
restoreCharGuidInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, restoreCharGuidInput)

-- Champ optionnel "New Name"
local restoreNewNameInput = CreateFrame("EditBox", nil, commandsFramePage4, "InputBoxTemplate")
restoreNewNameInput:SetSize(150, 22)
restoreNewNameInput:SetPoint("LEFT", restoreCharGuidInput, "RIGHT", 10, 0)
restoreNewNameInput:SetAutoFocus(false)
restoreNewNameInput.defaultText = "New Name"
restoreNewNameInput:SetText(restoreNewNameInput.defaultText)
restoreNewNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
restoreNewNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, restoreNewNameInput)

-- Champ optionnel "New Account"
local restoreNewAccountInput = CreateFrame("EditBox", nil, commandsFramePage4, "InputBoxTemplate")
restoreNewAccountInput:SetSize(150, 22)
restoreNewAccountInput:SetPoint("LEFT", restoreNewNameInput, "RIGHT", 10, 0)
restoreNewAccountInput:SetAutoFocus(false)
restoreNewAccountInput.defaultText = "New Account"
restoreNewAccountInput:SetText(restoreNewAccountInput.defaultText)
restoreNewAccountInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
restoreNewAccountInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, restoreNewAccountInput)

-- Bouton "Restore"
local btnRestore = CreateFrame("Button", nil, commandsFramePage4, "UIPanelButtonTemplate")
btnRestore:SetSize(100, 22)
btnRestore:SetText("Restore")
btnRestore:SetPoint("LEFT", restoreNewAccountInput, "RIGHT", 10, 0)

btnRestore:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        "Syntax: .character deleted restore #guid|$name [$newname] [#new account]\nRestores deleted characters.\nIf $name is supplied, only characters with that string in their name will be restored, if $guid is supplied, only the character with that GUID will be restored.\nIf $newname is set, the character will be restored with that name instead of the original one. If #newaccount is set, the character will be restored to specific account character list. This works only with one character!",
        1, 1, 1, 1, true
    )
    GameTooltip:Show()
end)
btnRestore:SetScript("OnLeave", function() GameTooltip:Hide() end)

btnRestore:SetScript("OnClick", function()
    local guidOrName = restoreCharGuidInput:GetText()
    local newName = restoreNewNameInput:GetText()
    local newAccount = restoreNewAccountInput:GetText()

    -- Vérifie si le premier champ est renseigné
    if guidOrName == "" or guidOrName == restoreCharGuidInput.defaultText then
        print("Erreur : Veuillez entrer un Char Name ou Guid valide.")
        return
    end

    local cmd = ".character deleted restore " .. guidOrName

    -- Ajoute "newName" seulement s'il est renseigné
    if newName ~= "" and newName ~= restoreNewNameInput.defaultText then
        cmd = cmd .. " " .. newName
    end

    -- Ajoute "newAccount" seulement s'il est renseigné
    if newAccount ~= "" and newAccount ~= restoreNewAccountInput.defaultText then
        cmd = cmd .. " " .. newAccount
    end

    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)


local btnResetInputs = CreateFrame("Button", nil, commandsFramePage4, "UIPanelButtonTemplate")
btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText("Reset Inputs")
btnResetInputs:SetPoint("TOPRIGHT", restoreNewAccountInput, "BOTTOMLEFT", 0, -15)
btnResetInputs:SetScript("OnClick", ResetInputs)	
---------------------------------------------------------------
-- Page 5
---------------------------------------------------------------
local commandsFramePage5 = CreateFrame("Frame", nil, pages[5])
commandsFramePage5:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
commandsFramePage5:SetSize(500, 350)

local page5Title = commandsFramePage5:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page5Title:SetPoint("TOPLEFT", commandsFramePage5, "TOPLEFT", 0, 0)
page5Title:SetText("Pets Functions")

-- Fonction améliorée pour les boutons simples appliquant la commande à la cible ou au GM par défaut
local function CreateServerButtonPage5(name, text, tooltip, cmd)
    local btn = CreateFrame("Button", name, commandsFramePage5, "UIPanelButtonTemplate")
    btn:SetSize(150, 22)
    btn:SetText(text)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    btn:SetScript("OnClick", function(self)
        local targetName = UnitName("target")
        local finalCmd

        if targetName then
            finalCmd = cmd .. " " .. targetName
        else
            finalCmd = cmd -- sans cible (appliqué au GM lui-même)
        end

        SendChatMessage(finalCmd, "SAY")
        print("Commande envoyée: " .. finalCmd)
    end)
    return btn
end

-- Fonction polyvalente pour réinitialiser les champs de saisie
local function ResetInputs()
    for _, input in ipairs(inputFields) do
        if input:GetText() ~= input.defaultText then
            input:SetText(input.defaultText)
        end
    end
end

----------------------------
-- Fonction Pet Create
----------------------------
local btnPetCreate = CreateServerButtonPage5("PetCreateButton", "Create Pet", "Syntax: .pet create\r\n\r\nCreates a pet of the selected creature.", ".pet create")
btnPetCreate:SetPoint("TOPLEFT", page5Title, "BOTTOMLEFT", 0, -15)

----------------------------
-- Fonction Learn Pet
----------------------------
-- Champ de saisie "Enterspell"
local petlearnInput = CreateFrame("EditBox", nil, commandsFramePage5, "InputBoxTemplate")
petlearnInput:SetSize(90, 22)
petlearnInput:SetPoint("TOPLEFT", btnPetCreate, "BOTTOMLEFT", 0, -10)
petlearnInput:SetAutoFocus(false)
petlearnInput.defaultText = "Spell ID"
petlearnInput:SetText(petlearnInput.defaultText)
petlearnInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
petlearnInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, petlearnInput)

-- Bouton "Learn Pet"
local btnLearnPet = CreateFrame("Button", nil, commandsFramePage5, "UIPanelButtonTemplate")
btnLearnPet:SetSize(120, 22)
btnLearnPet:SetText("Learn to Pet")
btnLearnPet:SetPoint("LEFT", petlearnInput, "RIGHT", 10, 0)
btnLearnPet:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .pet learn\r\n\r\nLearn #spellid to pet.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnLearnPet:SetScript("OnLeave", function() GameTooltip:Hide() end)

btnLearnPet:SetScript("OnClick", function()
    local petName = petlearnInput:GetText()
	-- Si "petName" vide, on envoi erreur
        if not petName or petName == "" or petName == petlearnInput.defaultText then
            print("Veuillez entrer une ID de Spell Valide.")
            return
		end
    local cmd = ".pet learn " .. petName
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction Pet Level
----------------------------
-- Champ de saisie "Level"
local petlevelInput = CreateFrame("EditBox", nil, commandsFramePage5, "InputBoxTemplate")
petlevelInput:SetSize(90, 22)
petlevelInput:SetPoint("TOPLEFT", petlearnInput, "BOTTOMLEFT", 0, -10)
petlevelInput:SetAutoFocus(false)
petlevelInput.defaultText = "Level"
petlevelInput:SetText(petlevelInput.defaultText)
petlevelInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
petlevelInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, petlevelInput)

-- Bouton "level"
local btnPetlevel = CreateFrame("Button", nil, commandsFramePage5, "UIPanelButtonTemplate")
btnPetlevel:SetSize(120, 22)
btnPetlevel:SetText("Set Level")
btnPetlevel:SetPoint("LEFT", petlevelInput, "RIGHT", 10, 0)
btnPetlevel:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .pet level #dLevel\nIncreases/decreases the pet\'s level by #dLevel. Pet\'s level cannot exceed the owner\'s level.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnPetlevel:SetScript("OnLeave", function() GameTooltip:Hide() end)

btnPetlevel:SetScript("OnClick", function()
    local petLevel = petlevelInput:GetText()
	 -- Si "level" vide, on envoi erreur
        if not petLevel or petLevel == "" or petLevel == petlevelInput.defaultText then
            print("Veuillez entrer un Niveau Valide.")
            return
		end
    local cmd = ".pet level " .. petLevel
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction Pet unlearn
----------------------------
-- Champ de spellid "Level"
local spellidInput = CreateFrame("EditBox", nil, commandsFramePage5, "InputBoxTemplate")
spellidInput:SetSize(90, 22)
spellidInput:SetPoint("TOPLEFT", petlevelInput, "BOTTOMLEFT", 0, -10)
spellidInput:SetAutoFocus(false)
spellidInput.defaultText = "Level"
spellidInput:SetText(spellidInput.defaultText)
spellidInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
spellidInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, spellidInput)

-- Bouton "unlearn"
local btnPetUnlearn = CreateFrame("Button", nil, commandsFramePage5, "UIPanelButtonTemplate")
btnPetUnlearn:SetSize(120, 22)
btnPetUnlearn:SetText("Unlearn")
btnPetUnlearn:SetPoint("LEFT", spellidInput, "RIGHT", 10, 0)
btnPetUnlearn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .pet unleran\r\n\r\nunLearn #spellid to pet.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnPetUnlearn:SetScript("OnLeave", function() GameTooltip:Hide() end)

btnPetUnlearn:SetScript("OnClick", function()
    local petSpell = spellidInput:GetText()
    -- Si "level" vide, on envoi erreur
        if not petSpell or petSpell == "" or petSpell == spellidInput.defaultText then
            print("Veuillez entrer une ID se Spell Valide.")
            return
		end
	
    local cmd = ".pet unleran " .. petSpell
    SendChatMessage(cmd, "SAY")
    print("Commande envoyée : " .. cmd)
end)
	
local btnResetInputs = CreateFrame("Button", nil, commandsFramePage5, "UIPanelButtonTemplate")
btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText("Reset Inputs")
btnResetInputs:SetPoint("TOPRIGHT", btnPetUnlearn, "BOTTOMLEFT", 0, -15)
btnResetInputs:SetScript("OnClick", ResetInputs)	
---------------------------------------------------------------
-- Page 6
---------------------------------------------------------------
local commandsFramePage6 = CreateFrame("Frame", nil, pages[6])
commandsFramePage6:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
commandsFramePage6:SetSize(500, 350)

local page6Title = commandsFramePage6:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page6Title:SetPoint("TOPLEFT", commandsFramePage6, "TOPLEFT", 0, 0)
page6Title:SetText("Player Dumps")

    -- Ajoutez d'autres boutons de la page 6…

---------------------------------------------------------------
-- Page 6
---------------------------------------------------------------
local commandsFramePage7 = CreateFrame("Frame", nil, pages[7])
commandsFramePage7:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
commandsFramePage7:SetSize(500, 350)

local page7Title = commandsFramePage7:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page7Title:SetPoint("TOPLEFT", commandsFramePage7, "TOPLEFT", 0, 0)
page7Title:SetText("Page 7")

    -- Ajoutez d'autres boutons de la page 7…	
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
    -- Bouton Back final (commun aux pages)
    ------------------------------------------------------------------------------
    local btnBackFinal = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("TOPRIGHT", account, "TOPRIGHT", 0, -10)
    btnBackFinal:SetText(TrinityAdmin_Translations["Back"])
    btnBackFinal:SetHeight(22)
    btnBackFinal:SetWidth(btnBackFinal:GetTextWidth() + 20)
    btnBackFinal:SetScript("OnClick", function()
        account:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
