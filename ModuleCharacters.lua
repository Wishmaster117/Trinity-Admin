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
        -- print("Commande envoyée: " .. cmd)
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
    -- print("Commande envoyée : " .. cmd)
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
    -- print("Commande envoyée : " .. cmd)
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
            -- print("La Cible est : " .. playerName) -- Pour debug
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
    -- print("Commande envoyée : " .. cmd)
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
            -- print("La Cible est : " .. playerName) -- Pour debug
        else
            print("Veuillez entrer un nom de joueur valide ou sélectionner une cible.")
            return
        end
    end
	
    local cmd = ".unfreeze " .. playerName
    SendChatMessage(cmd, "SAY")
    -- print("Commande envoyée : " .. cmd)
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
        -- print("Commande envoyée: " .. finalCmd)
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
            -- print("La Cible est : " .. playerName) -- Pour debug
        else
            print("Veuillez entrer un nom de joueur valide ou sélectionner une cible.")
            return
        end
    end
	
    local cmd = ".unstuck " .. playerName .. " " .. selectedLocation
    SendChatMessage(cmd, "SAY")
    -- print("Commande envoyée : " .. cmd)
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
            -- print("La Cible est : " .. playerName) -- Pour debug
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
    -- print("Commande envoyée : " .. cmd)
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
            -- print("La Cible est : " .. playerName)
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
    -- print("Commande envoyée : " .. cmd)
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
    -- print("Commande envoyée : " .. cmd)
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
    -- print("Commande envoyée : " .. cmd)
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
    -- print("Commande envoyée : " .. cmd)
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
    -- print("Commande envoyée : " .. cmd)
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
    -- print("Commande envoyée : " .. cmd)
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
    -- print("Commande envoyée : " .. cmd)
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
    -- print("Commande envoyée : " .. cmd)
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
    -- print("Commande envoyée : " .. cmd)
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
    -- print("Commande envoyée : " .. finalCmd)
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
    -- print("Commande envoyée : " .. cmd)
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
        -- print("Commande envoyée: " .. finalCmd)
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
   --  print("Commande envoyée : " .. cmd)
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
   --  print("Commande envoyée : " .. cmd)
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
   --  print("Commande envoyée : " .. cmd)
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

-- Fonction améliorée pour les boutons simples appliquant la commande à la cible ou au GM par défaut
local function CreateServerButtonPage5(name, text, tooltip, cmd)
    local btn = CreateFrame("Button", name, commandsFramePage6, "UIPanelButtonTemplate")
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
       --  print("Commande envoyée: " .. finalCmd)
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
-- pdumpcopy
----------------------------
-- Champ de saisie "Name"
local pdumpcopyNameInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
pdumpcopyNameInput:SetSize(150, 22)
pdumpcopyNameInput:SetPoint("TOPLEFT", page6Title, "BOTTOMLEFT", 0, -20)
pdumpcopyNameInput:SetAutoFocus(false)
pdumpcopyNameInput.defaultText = "Player NameOrGUID"
pdumpcopyNameInput:SetText(pdumpcopyNameInput.defaultText)
pdumpcopyNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
pdumpcopyNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, pdumpcopyNameInput)

-- Champ de saisie "Account"
local accountInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
accountInput:SetSize(70, 22)
accountInput:SetPoint("LEFT", pdumpcopyNameInput, "RIGHT", 10, 0)
accountInput:SetAutoFocus(false)
accountInput.defaultText = "Account"
accountInput:SetText(accountInput.defaultText)
accountInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
accountInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, accountInput)

-- Champ de saisie "newname"
local newnameInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
newnameInput:SetSize(120, 22)
newnameInput:SetPoint("LEFT", accountInput, "RIGHT", 10, 0)
newnameInput:SetAutoFocus(false)
newnameInput.defaultText = "New Name"
newnameInput:SetText(newnameInput.defaultText)
newnameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
newnameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, newnameInput)

-- Champ de saisie "newguid"
local newguidInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
newguidInput:SetSize(70, 22)
newguidInput:SetPoint("LEFT", newnameInput, "RIGHT", 10, 0)
newguidInput:SetAutoFocus(false)
newguidInput.defaultText = "New Guid"
newguidInput:SetText(newguidInput.defaultText)
newguidInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
newguidInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, newguidInput)

-- Bouton "Rename"
local btnDumpCopy = CreateFrame("Button", nil, commandsFramePage6, "UIPanelButtonTemplate")
btnDumpCopy:SetSize(70, 22)
btnDumpCopy:SetText("Dump")
btnDumpCopy:SetPoint("LEFT", newguidInput, "RIGHT", 10, 0)
btnDumpCopy:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .pdump copy $playerNameOrGUID $account [$newname] [$newguid]\nCopy character with name/guid $playerNameOrGUID into character list of $account with $newname, with first free or $newguid guid.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnDumpCopy:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnDumpCopy:SetScript("OnClick", function()
    local nameValue    = pdumpcopyNameInput:GetText()
    local accountValue = accountInput:GetText()
    local newNameValue = newnameInput:GetText()
    local newGuidValue = newguidInput:GetText()

    -- Vérification des champs obligatoires
    if nameValue == "" or nameValue == pdumpcopyNameInput.defaultText or
       accountValue == "" or accountValue == accountInput.defaultText or
       newNameValue == "" or newNameValue == newnameInput.defaultText then
        print("Les champs Nom ou GUID, Account et New Name sont obligatoires. Veuillez les renseigner.")
        return
    end

    -- Construction de la commande
    local cmd = ".pdump copy " .. nameValue .. " " .. accountValue .. " " .. newNameValue
    -- Ajout du champ newguid s'il est renseigné (différent de vide ou du texte par défaut)
    if newGuidValue ~= "" and newGuidValue ~= newguidInput.defaultText then
        cmd = cmd .. " " .. newGuidValue
    end

    SendChatMessage(cmd, "SAY")
   --  print("Commande envoyée : " .. cmd)
end)

----------------------------
-- pdumpload
----------------------------
-- Champ de saisie "Filename"
local pdumploadFileInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
pdumploadFileInput:SetSize(150, 22)
pdumploadFileInput:SetPoint("TOPLEFT", pdumpcopyNameInput, "BOTTOMLEFT", 0, -20)
pdumploadFileInput:SetAutoFocus(false)
pdumploadFileInput.defaultText = "Enter Filename"
pdumploadFileInput:SetText(pdumploadFileInput.defaultText)
pdumploadFileInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
pdumploadFileInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, pdumploadFileInput)

-- Champ de saisie "Account"
local accountLoadInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
accountLoadInput:SetSize(70, 22)
accountLoadInput:SetPoint("LEFT", pdumploadFileInput, "RIGHT", 10, 0)
accountLoadInput:SetAutoFocus(false)
accountLoadInput.defaultText = "Account"
accountLoadInput:SetText(accountLoadInput.defaultText)
accountLoadInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
accountLoadInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, accountLoadInput)

-- Champ de saisie "newname"
local newnameLoadInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
newnameLoadInput:SetSize(120, 22)
newnameLoadInput:SetPoint("LEFT", accountLoadInput, "RIGHT", 10, 0)
newnameLoadInput:SetAutoFocus(false)
newnameLoadInput.defaultText = "New Name"
newnameLoadInput:SetText(newnameLoadInput.defaultText)
newnameLoadInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
newnameLoadInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, newnameLoadInput)

-- Champ de saisie "newguid"
local newguidLoadInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
newguidLoadInput:SetSize(70, 22)
newguidLoadInput:SetPoint("LEFT", newnameLoadInput, "RIGHT", 10, 0)
newguidLoadInput:SetAutoFocus(false)
newguidLoadInput.defaultText = "New Guid"
newguidLoadInput:SetText(newguidLoadInput.defaultText)
newguidLoadInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
newguidLoadInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, newguidLoadInput)

-- Bouton "Load"
local btnDumpLoad = CreateFrame("Button", nil, commandsFramePage6, "UIPanelButtonTemplate")
btnDumpLoad:SetSize(70, 22)
btnDumpLoad:SetText("Load")
btnDumpLoad:SetPoint("LEFT", newguidLoadInput, "RIGHT", 10, 0)
btnDumpLoad:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .pdump load $filename $account [$newname] [$newguid]\r\nLoad character dump from dump file into character list of $account with saved or $newname, with saved (or first free) or $newguid guid.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnDumpLoad:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnDumpLoad:SetScript("OnClick", function()
    local nameValue    = pdumploadFileInput:GetText()
    local accountValue = accountLoadInput:GetText()
    local newNameValue = newnameLoadInput:GetText()
    local newGuidValue = newguidLoadInput:GetText()

    -- Vérification des champs obligatoires
    if nameValue == "" or nameValue == pdumploadFileInput.defaultText or
       accountValue == "" or accountValue == accountLoadInput.defaultText or
       newNameValue == "" or newNameValue == newnameLoadInput.defaultText then
        print("Les champs Filename, Account et New Name sont obligatoires. Veuillez les renseigner.")
        return
    end

    -- Construction de la commande
    local cmd = ".pdump copy " .. nameValue .. " " .. accountValue .. " " .. newNameValue
    -- Ajout du champ newguid s'il est renseigné (différent de vide ou du texte par défaut)
    if newGuidValue ~= "" and newGuidValue ~= newguidLoadInput.defaultText then
        cmd = cmd .. " " .. newGuidValue
    end

    SendChatMessage(cmd, "SAY")
   --  print("Commande envoyée : " .. cmd)
end)

----------------------------
-- pdumpwrite
----------------------------
-- Champ de saisie "Filename"
local pdumpwriteFileInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
pdumpwriteFileInput:SetSize(120, 22)
pdumpwriteFileInput:SetPoint("TOPLEFT", pdumploadFileInput, "BOTTOMLEFT", 0, -20)
pdumpwriteFileInput:SetAutoFocus(false)
pdumpwriteFileInput.defaultText = "Enter Filename"
pdumpwriteFileInput:SetText(pdumpwriteFileInput.defaultText)
pdumpwriteFileInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
pdumpwriteFileInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, pdumpwriteFileInput)

-- Champ de saisie "Name"
local playerNameWriteInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
playerNameWriteInput:SetSize(150, 22)
playerNameWriteInput:SetPoint("LEFT", pdumpwriteFileInput, "RIGHT", 10, 0)
playerNameWriteInput:SetAutoFocus(false)
playerNameWriteInput.defaultText = "PlayerName Or GUID"
playerNameWriteInput:SetText(playerNameWriteInput.defaultText)
playerNameWriteInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
playerNameWriteInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)

table.insert(inputFields, playerNameWriteInput)

-- Bouton "Write"
local btnDumpWrite = CreateFrame("Button", nil, commandsFramePage6, "UIPanelButtonTemplate")
btnDumpWrite:SetSize(70, 22)
btnDumpWrite:SetText("Write")
btnDumpWrite:SetPoint("LEFT", playerNameWriteInput, "RIGHT", 10, 0)
btnDumpWrite:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .pdump write $filename $playerNameOrGUID\r\nWrite character dump with name/guid $playerNameOrGUID to file $filename.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnDumpWrite:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnDumpWrite:SetScript("OnClick", function()
    local nameValueWrite    = pdumpwriteFileInput:GetText()
    local accountValueWrite = playerNameWriteInput:GetText()

    -- Vérification des champs obligatoires
    if nameValueWrite == "" or nameValueWrite == pdumpwriteFileInput.defaultText or
       accountValueWrite == "" or accountValueWrite == playerNameWriteInput.defaultText then
        print("Les champs Filename, Name or GUI sont obligatoires. Veuillez les renseigner.")
        return
    end

    -- Construction de la commande
    local cmd = ".pdump write " .. nameValueWrite .. " " .. accountValueWrite

    SendChatMessage(cmd, "SAY")
   --  print("Commande envoyée : " .. cmd)
end)
	
-----------------------------
-- Bouton reset
----------------------------
local btnResetInputs = CreateFrame("Button", nil, commandsFramePage6, "UIPanelButtonTemplate")
btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText("Reset Inputs")
btnResetInputs:SetPoint("TOPRIGHT", btnDumpWrite, "BOTTOMLEFT", 0, -15)
btnResetInputs:SetScript("OnClick", ResetInputs)	
---------------------------------------------------------------
-- Page 7 : Player Info Capture (.pinfo) [DEBUG MODE]
---------------------------------------------------------------

-- local commandsFramePage7 = CreateFrame("Frame", nil, pages[7])
-- commandsFramePage7:SetPoint("TOPLEFT", pages[7], "TOPLEFT", 20, -40)
-- commandsFramePage7:SetSize(500, 350)
-- 
-- local page7Title = commandsFramePage7:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
-- page7Title:SetPoint("TOPLEFT", commandsFramePage7, "TOPLEFT", 0, 0)
-- page7Title:SetText("Player Info Capture")
-- 
-- -- Création d'un ScrollFrame pour afficher les informations
-- local scrollFrame = CreateFrame("ScrollFrame", "MyInfoScrollFrame", commandsFramePage7, "UIPanelScrollFrameTemplate")
-- scrollFrame:SetPoint("TOPLEFT", page7Title, "TOPRIGHT", 100, 30)
-- scrollFrame:SetSize(300, 300)
-- 
-- -- Conteneur dans lequel on mettra le FontString
-- local content = CreateFrame("Frame", nil, scrollFrame)
-- content:SetSize(300, 300)  -- Taille initiale, pourra être ajustée dynamiquement
-- scrollFrame:SetScrollChild(content)
-- 
-- -- FontString qui contiendra les infos
-- local infoText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- infoText:SetPoint("TOPLEFT")
-- infoText:SetWidth(300)        -- Largeur du texte (ou un peu moins pour la marge)
-- infoText:SetJustifyH("LEFT")
-- infoText:SetJustifyV("TOP")
-- infoText:SetText("")          -- Initialement vide
-- 
-- -- Variables pour la capture des messages
-- local capturingPinfo = false
-- local collectedInfo = {}
-- local captureTimer = nil
-- 
-- local function FinishCapture()
--     capturingPinfo = false
--     if #collectedInfo > 0 then
--         local fullText = table.concat(collectedInfo, "\n")
--         infoText:SetText(fullText)
--         
--         -- Ajuste dynamiquement la hauteur de 'content' en fonction du texte
--         local textHeight = infoText:GetStringHeight()
--         content:SetHeight(textHeight + 5)  -- +5 px de marge, ajustez selon besoin
-- 
--         -- Remet le scroll en haut
--         scrollFrame:SetVerticalScroll(0)
-- 
--         print("[DEBUG] Capture terminée. Affichage dans la page.")
--     else
--         print("[DEBUG] Fin de capture mais aucune info capturée.")
--     end
-- end
-- 
-- -- Bouton cumulé : envoie la commande .pinfo et déclenche la capture
-- local btnCapturePinfo = CreateFrame("Button", nil, commandsFramePage7, "UIPanelButtonTemplate")
-- btnCapturePinfo:SetSize(180, 24)
-- btnCapturePinfo:SetPoint("TOPLEFT", page7Title, "TOPLEFT", 0, -30)
-- btnCapturePinfo:SetText("Advanced .Pinfo")
-- btnCapturePinfo:SetScript("OnClick", function()
--     SendChatMessage(".pinfo", "SAY")
--     capturingPinfo = true
--     collectedInfo = {}  -- réinitialise la capture
--     if captureTimer then captureTimer:Cancel() end
--     captureTimer = C_Timer.NewTimer(1, FinishCapture)
--     print("[DEBUG] .pinfo envoyé, capture activée")
-- end)
-- 
-- -- Frame pour capturer les événements CHAT_MSG_SYSTEM
-- local captureFrame = CreateFrame("Frame")
-- captureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
-- captureFrame:SetScript("OnEvent", function(self, event, msg)
--     if not capturingPinfo then return end
--     
--     print("[DEBUG] Message CHAT_MSG_SYSTEM reçu : " .. msg)
--     
-- local function DebugStringBytes(str)
--     print("=== Début DebugStringBytes ===")
--     for i = 1, #str do
--         local c = str:sub(i, i)
--         print(i, c, string.byte(c))
--     end
--     print("=== Fin DebugStringBytes ===")
-- end
-- 
-- DebugStringBytes(msg)
-- 
-- -- Exemple de nettoyage
-- local cleanMsg = msg
-- -- Retire les codes couleur, liens, textures, etc. (optionnel)
-- cleanMsg = cleanMsg:gsub("|c%x%x%x%x%x%x%x%x", "")
-- cleanMsg = cleanMsg:gsub("|r", "")
-- cleanMsg = cleanMsg:gsub("|H.-|h(.-)|h", "%1")
-- cleanMsg = cleanMsg:gsub("|T.-|t", "")
-- 
-- -- Retire spécifiquement le caractère U+2502 (box drawing vertical)
-- --cleanMsg = cleanMsg:gsub("\226\148\130", "")
-- cleanMsg = cleanMsg:gsub("\226[\148-\149][\128-\191]", "")
-- 
--     -- Détection du début de la capture (pinfo) s'il y a "Player" et "guid"
--     if cleanMsg:find("Player") and cleanMsg:find("guid") then
--         collectedInfo = {}  -- démarre une nouvelle capture
--         table.insert(collectedInfo, cleanMsg)
--         print("[DEBUG] Début de capture détecté.")
--         if captureTimer then captureTimer:Cancel() end
--         captureTimer = C_Timer.NewTimer(1, FinishCapture)
--         return
--     end
-- 
--     table.insert(collectedInfo, cleanMsg)
--     print("[DEBUG] Ajouté à la capture : " .. cleanMsg)
--     if captureTimer then captureTimer:Cancel() end
--     captureTimer = C_Timer.NewTimer(1, FinishCapture)
-- end)

---------------------------------------------------------------
-- Page 7 : Player Info Capture (.pinfo) [DEBUG MODE]
---------------------------------------------------------------

local commandsFramePage7 = CreateFrame("Frame", nil, pages[7])
commandsFramePage7:SetPoint("TOPLEFT", pages[7], "TOPLEFT", 20, -40)
commandsFramePage7:SetSize(500, 350)

local page7Title = commandsFramePage7:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page7Title:SetPoint("TOPLEFT", commandsFramePage7, "TOPLEFT", 0, 0)
page7Title:SetText("Player Info Capture")

-- ============================================================
-- 1) Variables de capture
-- ============================================================
local capturingPinfo = false
local collectedInfo = {}
local captureTimer = nil

-- ============================================================
-- 2) Fonction de parsing (votre version finale)
-- ============================================================
local function ParseCapturedPinfo(lines)
    local infoTable = {}
    local fullText = table.concat(lines, "\n")  -- on réunit toutes les lignes

    -- 1) Player / GUID
    local playerName, playerGUID = fullText:match("Player%s*%[(.-)%]%s*%((.-)%)")

    -- 2) GM Mode / Phase
    local gmMode = fullText:match("GM Mode%s*(%S+)")
    local phase = fullText:match("Phase:%s*([%-]?%d+)")

    -- 3) Account / GMLevel
    local account = fullText:match("Account:%s*(.-),%s*GMLevel") or ""
    local gmLevel = fullText:match("GMLevel:%s*(%d+)") or ""

    -- 4) Last Login
    local lastLogin = fullText:match("Last Login:%s*([^\n]+)") or ""

    -- 5) OS + Latency
    local osLine = fullText:match("OS:%s*([^\n]+)") or ""
    local os, latency = osLine:match("(.-)%s*%- Latency:%s*([%S]+)")
    os = os or ""
    latency = latency or ""

    -- 6) Registration Email + Email
    local registrationEmailLine = fullText:match("Registration Email:%s*([^\n]+)") or ""
    local regEmail, normalEmail = registrationEmailLine:match("^(.-)%s*%-+%s*Email:%s*(.-)$")

    -- 7) Last IP
    local lastIP = fullText:match("Last IP:%s*([^\n]+)") or ""

    -- 8) Level
    local level = fullText:match("Level:%s*(%d+)") or ""

    -- 9) Race
    local race = fullText:match("Race:%s*([^\n]+)") or ""

    -- 10) Alive
    local alive = fullText:match("Alive %?:%s*(%S+)") or ""

    -- 11) PhaseShift
    local phaseShiftLine = fullText:match("PhaseShift:[^\n]*")

    -- 12) Flags + PersonalGuid
    local flagsLine = fullText:match("%*%s*(.-)\n") or fullText:match("%*%s*(.+)$") or ""

    -- 13) VisibleMapAreaSwaps (ou UiWorldMapAreaSwaps)
    local visibleSwaps = fullText:match("VisibleMapAreaSwaps:%s*([^\n]+)")
                      or fullText:match("UiWorldMapAreaSwaps:%s*([^\n]+)")
                      or ""

    -- 14) Money
    local money = fullText:match("Money:%s*([^\n]+)") or ""

    -- 15) Map / Zone / Area
    local mapVal, zoneVal, areaVal = "", "", ""
    local m, z, a = fullText:match("Map:%s*([^,]+),%s*Zone:%s*([^,]+),%s*Area:%s*([^\n]+)")
    if m and z and a then
        m = m:gsub("^%s*(.-)%s*$", "%1")
        z = z:gsub("^%s*(.-)%s*$", "%1")
        a = a:gsub("^%s*(.-)%s*$", "%1")
        mapVal, zoneVal, areaVal = m, z, a
    end

    -- 16) Played time
    local playedTime = fullText:match("Played time:%s*([^\n]+)") or ""
	
	-- 17) Guild : On capture la partie après "Guild:" et extrait le nom et l'ID s'ils sont au format "GuildName (ID: 1234)"
    local guildLine = fullText:match("Guild:%s*([^\n]+)") or ""
    local guildName, guildID = "", ""
    if guildLine ~= "" then
        guildName, guildID = guildLine:match("^(.-)%s*%(%s*ID:%s*(%d+)%s*%)")
    end

    -- 18) Rank : capture ce qui suit "Rank:"
    -- On récupère la ligne après "Rank:"
	local rankLine = fullText:match("Rank:%s*([^\n]+)") or ""
	
	local rankName, rankID
	if rankLine ~= "" then
		-- On tente de capturer le format "Guild Master, ID: 0"
		-- c.-à-d. tout ce qui précède la virgule = rankName
		-- et le nombre après "ID:" = rankID
		rankName, rankID = rankLine:match("^(.-),%s*ID:%s*(%d+)$")
	end


    -- Insère tout dans infoTable
    table.insert(infoTable, { label = "Player", value = playerName })
    table.insert(infoTable, { label = "GUID",   value = playerGUID })
    table.insert(infoTable, { label = "GM Mode",value = gmMode })
    table.insert(infoTable, { label = "Phase",  value = phase })
    table.insert(infoTable, { label="Account",  value=account })
    table.insert(infoTable, { label="GMLevel",  value=gmLevel })
    table.insert(infoTable, { label="Last Login", value=lastLogin })
    table.insert(infoTable, { label="OS",         value=os })
    table.insert(infoTable, { label="Latency",    value=latency })

    if regEmail and normalEmail then
        table.insert(infoTable, { label = "Registration Email", value = regEmail })
        table.insert(infoTable, { label = "Email",              value = normalEmail })
    else
        table.insert(infoTable, { label = "Registration Email", value = registrationEmailLine })
    end

    table.insert(infoTable, { label="Last IP",   value=lastIP })
    table.insert(infoTable, { label="Level",     value=level })
    table.insert(infoTable, { label="Race",      value=race })
    table.insert(infoTable, { label="Alive",     value=alive })

    -- PhaseShift si non vide
    if phaseShiftLine then
        local shift = phaseShiftLine:gsub("PhaseShift:", "")
        shift = shift:gsub("^%s*(.-)%s*$", "%1")
        if shift ~= "" and not shift:match("^%*") then
            table.insert(infoTable, { label="PhaseShift", value=shift })
        end
    end

    -- Flags + PersonalGuid
    if flagsLine ~= "" then
        local fl, pg = flagsLine:match("Flags%s+([^,]+),%s*PersonalGuid:%s*(.+)")
        if fl then
            fl = fl:gsub("^%s*(.-)%s*$", "%1")
            table.insert(infoTable, { label = "Flags", value = fl })
        end
        if pg then
            pg = pg:gsub("^%s*(.-)%s*$", "%1")
            table.insert(infoTable, { label = "PersonalGuid", value = pg })
        end
    end

    if visibleSwaps ~= "" then
        table.insert(infoTable, { label="VisibleMapAreaSwaps", value=visibleSwaps })
    end

    table.insert(infoTable, { label="Money",  value=money })
    table.insert(infoTable, { label="Map",    value=mapVal })
    table.insert(infoTable, { label="Zone",   value=zoneVal })
    table.insert(infoTable, { label="Area",   value=areaVal })
	if guildName ~= "" then
    table.insert(infoTable, { label = "Guild", value = guildName })
    end
    if guildID ~= "" then
        table.insert(infoTable, { label = "GuildID", value = guildID })
    end
	if rankName and rankID then
    -- Si on a trouvé le nom de rang + ID, on peut les insérer séparément
    table.insert(infoTable, { label = "RankName", value = rankName })
    table.insert(infoTable, { label = "RankID",   value = rankID   })
	else
    -- Sinon, on stocke la ligne brute dans un seul champ "Rank"
    if rankLine ~= "" then
        table.insert(infoTable, { label = "RankName", value = rankLine })
    end
	end
    table.insert(infoTable, { label="Played time", value=playedTime })

    return infoTable
end

-- ============================================================
-- 3) Fenêtre AceGUI : affichage + redimensionnement
-- ============================================================
local AceGUI = LibStub("AceGUI-3.0")
local pinfoAceFrame

-- Petite fonction utilitaire pour créer une "ligne" (SimpleGroup) en Flow
local function CreateRow(parent)
    local row = AceGUI:Create("SimpleGroup")
    row:SetFullWidth(true)
    row:SetLayout("Flow")
    parent:AddChild(row)
    return row
end

local function ShowPlayerInfoAceGUI(infoTable)
    if pinfoAceFrame then
        AceGUI:Release(pinfoAceFrame)
        pinfoAceFrame = nil
    end

    pinfoAceFrame = AceGUI:Create("Frame")
    pinfoAceFrame:SetTitle("Informations du joueur")
    pinfoAceFrame:SetStatusText("Player Infos")
    pinfoAceFrame:SetLayout("Flow")
    pinfoAceFrame:SetWidth(600)
    pinfoAceFrame:SetHeight(500)
    pinfoAceFrame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        pinfoAceFrame = nil
    end)

    -- On crée un ScrollFrame AceGUI pour gérer le contenu vertical
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    pinfoAceFrame:AddChild(scroll)

    -- Dans le ScrollFrame, on crée un InlineGroup qui contiendra le contenu
    local group = AceGUI:Create("InlineGroup")
    group:SetTitle("Informations générales")
    group:SetFullWidth(true)
    group:SetLayout("Flow")
    scroll:AddChild(group)

    ---------------------------------------------------
    -- On range infoTable dans un dictionnaire data[label] = value
    ---------------------------------------------------
    local data = {}
    for _, row in ipairs(infoTable) do
        data[row.label] = row.value or ""
    end

    -- Pour créer rapidement un EditBox
    local function AddEditBox(parent, lbl, val, width)
        local edit = AceGUI:Create("EditBox")
        edit:SetLabel("|cffffff00" .. lbl .. "|r")
        edit:SetText(val or "")
        if width == "full" then
            edit:SetFullWidth(true)
        else
            edit:SetWidth(width or 200)
        end
        parent:AddChild(edit)
        return edit
    end

    ---------------------------------------------------
    -- Lignes de champs
    ---------------------------------------------------

     ---------------------------------------------------
    -- Lignes de champs (exemple)
    ---------------------------------------------------
    -- 1) Player, GUID
    local row1 = AceGUI:Create("SimpleGroup")
    row1:SetFullWidth(true)
    row1:SetLayout("Flow")
    group:AddChild(row1)
    AddEditBox(row1, "Player", data["Player"], 200)
    AddEditBox(row1, "GUID", data["GUID"], 250)

    -- 2) GM Mode, Phase
    local row2 = AceGUI:Create("SimpleGroup")
    row2:SetFullWidth(true)
    row2:SetLayout("Flow")
    group:AddChild(row2)
    AddEditBox(row2, "GM Mode", data["GM Mode"], 150)
    AddEditBox(row2, "Phase", data["Phase"], 80)

    -- 3) Account, GMLevel
    local row3 = AceGUI:Create("SimpleGroup")
    row3:SetFullWidth(true)
    row3:SetLayout("Flow")
    group:AddChild(row3)
    AddEditBox(row3, "Account", data["Account"], 200)
    AddEditBox(row3, "GMLevel", data["GMLevel"], 80)

    -- 4) Last Login (ligne entière)
    AddEditBox(group, "Last Login", data["Last Login"], "full")

    -- 5) OS, Latency
    local row5 = AceGUI:Create("SimpleGroup")
    row5:SetFullWidth(true)
    row5:SetLayout("Flow")
    group:AddChild(row5)
    AddEditBox(row5, "OS", data["OS"], 150)
    AddEditBox(row5, "Latency", data["Latency"], 50)

    -- 6) Registration Email, Email
    local row6 = AceGUI:Create("SimpleGroup")
    row6:SetFullWidth(true)
    row6:SetLayout("Flow")
    group:AddChild(row6)
    AddEditBox(row6, "Registration Email", data["Registration Email"], 200)
    AddEditBox(row6, "Email", data["Email"], 200)

    -- 7) Last IP, Level
    local row7 = AceGUI:Create("SimpleGroup")
    row7:SetFullWidth(true)
    row7:SetLayout("Flow")
    group:AddChild(row7)
    AddEditBox(row7, "Last IP", data["Last IP"], 200)
    AddEditBox(row7, "Level", data["Level"], 50)

    -- 8) Race, Alive
    local row8 = AceGUI:Create("SimpleGroup")
    row8:SetFullWidth(true)
    row8:SetLayout("Flow")
    group:AddChild(row8)
    AddEditBox(row8, "Race", data["Race"], 200)
    AddEditBox(row8, "Alive", data["Alive"], 50)

    -- 9) PhaseShift (ligne entière si existant)
    if data["PhaseShift"] and data["PhaseShift"] ~= "" then
        AddEditBox(group, "PhaseShift", data["PhaseShift"], "full")
    end

    -- 10) Flags, PersonalGuid
    local row10 = AceGUI:Create("SimpleGroup")
    row10:SetFullWidth(true)
    row10:SetLayout("Flow")
    group:AddChild(row10)
    AddEditBox(row10, "Flags", data["Flags"], 80)
    AddEditBox(row10, "PersonalGuid", data["PersonalGuid"], 200)

    -- 11) VisibleMapAreaSwaps, Money
    local row11 = AceGUI:Create("SimpleGroup")
    row11:SetFullWidth(true)
    row11:SetLayout("Flow")
    group:AddChild(row11)
    AddEditBox(row11, "VisibleMapAreaSwaps", data["VisibleMapAreaSwaps"], 200)
    AddEditBox(row11, "Money", data["Money"], 100)

    -- 12) Map, Zone, Area (sur la même ligne)
    local row12 = AceGUI:Create("SimpleGroup")
    row12:SetFullWidth(true)
    row12:SetLayout("Flow")
    group:AddChild(row12)
    AddEditBox(row12, "Map", data["Map"], 150)
    AddEditBox(row12, "Zone", data["Zone"], 150)
    AddEditBox(row12, "Area", data["Area"], 150)

    -- 13) Guild, Guild ID, Rank (sur la même ligne)
    local row13 = AceGUI:Create("SimpleGroup")
    row13:SetFullWidth(true)
    row13:SetLayout("Flow")
    group:AddChild(row13)
    AddEditBox(row13, "Guild", data["Guild"], 150)
    AddEditBox(row13, "Guild ID", data["GuildID"], 150)
    AddEditBox(row13, "Rank", data["RankName"], 150)
	AddEditBox(row13, "Rank ID", data["RankID"], 150)
	
    -- 14) Played time (ligne entière)
    AddEditBox(group, "Played time", data["Played time"], "full")

    -- Bouton Fermer (optionnel)
    local btnClose = AceGUI:Create("Button")
    btnClose:SetText("Fermer")
    btnClose:SetWidth(100)
    btnClose:SetCallback("OnClick", function()
        if pinfoAceFrame then
            pinfoAceFrame:Hide()
        end
    end)
    pinfoAceFrame:AddChild(btnClose)
end

-- ============================================================
-- 4) Fonction de fin de capture
-- ============================================================
local function FinishCapture()
    capturingPinfo = false
    if #collectedInfo > 0 then
        local infoTable = ParseCapturedPinfo(collectedInfo)
        ShowPlayerInfoAceGUI(infoTable)
        -- print("[DEBUG] Capture terminée. Affichage AceGUI.")
    else
        -- print("[DEBUG] Fin de capture mais aucune info capturée.")
    end
end

-- ============================================================
-- 5) Bouton .pinfo sur la page 7
-- ============================================================
local btnCapturePinfo = CreateFrame("Button", nil, commandsFramePage7, "UIPanelButtonTemplate")
btnCapturePinfo:SetSize(180, 24)
btnCapturePinfo:SetPoint("TOPLEFT", page7Title, "TOPLEFT", 0, -30)
btnCapturePinfo:SetText("Advanced .Pinfo")
btnCapturePinfo:SetScript("OnClick", function()
    SendChatMessage(".pinfo", "SAY")
    capturingPinfo = true
    collectedInfo = {}
    if captureTimer then captureTimer:Cancel() end
    captureTimer = C_Timer.NewTimer(1, FinishCapture)
    -- print("[DEBUG] .pinfo envoyé, capture activée")
end)

-- ============================================================
-- 6) Frame caché : écoute CHAT_MSG_SYSTEM et stocke les messages
-- ============================================================
local captureFrame = CreateFrame("Frame")
captureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
captureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingPinfo then return end

    -- print("[DEBUG] Message CHAT_MSG_SYSTEM reçu : " .. msg)

    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
                       :gsub("|r", "")
                       :gsub("|H.-|h(.-)|h", "%1")
                       :gsub("|T.-|t", "")
                       :gsub("\226[\148-\149][\128-\191]", "")
    table.insert(collectedInfo, cleanMsg)
    -- print("[DEBUG] Ajouté à la capture : " .. cleanMsg)
    if captureTimer then captureTimer:Cancel() end
    captureTimer = C_Timer.NewTimer(1, FinishCapture)
end)

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
    local btnBackFinal = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("CENTER", navPageLabel, "CENTER", 0, 20)
    btnBackFinal:SetText(TrinityAdmin_Translations["Back"])
    btnBackFinal:SetHeight(22)
    btnBackFinal:SetWidth(btnBackFinal:GetTextWidth() + 20)
    -- On augmente le niveau pour qu'il apparaisse au-dessus des pages
    btnBackFinal:SetFrameLevel(panel:GetFrameLevel() + 10)
    -- ou alternativement : btnBackFinal:SetFrameStrata("HIGH")
    
    btnBackFinal:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
	self.pages = pages
end
