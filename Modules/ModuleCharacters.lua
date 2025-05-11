local ModuleCharacter = TrinityAdmin:GetModule("ModuleCharacter")
local L = _G.L

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
    panel.title:SetText(L["Player/Characters/Pets Functions"])

    -------------------------------------------------------------------------------
    -- Création de plusieurs pages dans le panneau
    -------------------------------------------------------------------------------
local totalPages = 8
local currentPage = 1
local pages = {}
local btnPrev, btnNext -- Déclaration avancée des boutons

local function UpdateNavButtons()
    btnPrev:SetEnabled(currentPage > 1)
    btnNext:SetEnabled(currentPage < totalPages)
end

-- Création des pages
for i = 1, totalPages do
    pages[i] = CreateFrame("Frame", nil, panel)
    pages[i]:SetAllPoints(panel)
    pages[i]:Hide()
end

-- Label de navigation
local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
navPageLabel:SetText("Page 1 / " .. totalPages)

-- Fonction changement de page
local function ShowPage(pageIndex)
    for i = 1, totalPages do
        if i == pageIndex then
            pages[i]:Show()
        else
            pages[i]:Hide()
        end
    end
    currentPage = pageIndex
    navPageLabel:SetText("Page " .. pageIndex .. " / " .. totalPages)
    UpdateNavButtons()
end

-- Création des boutons AVANT le premier appel à ShowPage(1)
btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
-- btnPrev:SetSize(80, 22)
btnPrev:SetText(L["Pagination_Preview"])
TrinityAdmin.AutoSize(btnPrev, 20, 16)
btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
btnPrev:SetScript("OnClick", function()
    if currentPage > 1 then
        ShowPage(currentPage - 1)
    end
end)

btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
-- btnNext:SetSize(80, 22)
btnNext:SetText(L["Next"])
TrinityAdmin.AutoSize(btnNext, 20, 16)
btnNext:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
btnNext:SetScript("OnClick", function()
    if currentPage < totalPages then
        ShowPage(currentPage + 1)
    end
end)

-- Afficher la première page après avoir créé tous les éléments requis
ShowPage(1)

local inputFields = {} -- autres variables suivent

--------------------------------------------------------------------
-- Page 1
--------------------------------------------------------------------
local commandsFramePage1 = CreateFrame("Frame", nil, pages[1])
commandsFramePage1:SetPoint("TOPLEFT", pages[1], "TOPLEFT", 20, -40)
commandsFramePage1:SetSize(500, 350)

local page1Title = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page1Title:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, 0)
page1Title:SetText(L["Player Functions Part 1"])

-- Scripte pour actions des boutons simples:
local function CreateServerButtonPage1(name, text, tooltip, cmd)
    local btn = CreateFrame("Button", name, commandsFramePage1, "UIPanelButtonTemplate")
    -- btn:SetSize(150, 22)
    btn:SetText(text)
	TrinityAdmin.AutoSize(btn, 20, 16)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    btn:SetScript("OnClick", function(self)
        SendChatMessage(cmd, "SAY")
        -- TrinityAdmin:Print("Commande envoyée: " .. cmd)
    end)
    return btn
end
	
-- Ajout du champ de saisie et bouton Add Aura
local spellIdInput = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
-- spellIdInput:SetSize(150, 22)
spellIdInput:SetPoint("TOPLEFT", page1Title, "BOTTOMLEFT", 0, -15)
spellIdInput:SetAutoFocus(false)
spellIdInput.defaultText = L["Enter SpellId"]
TrinityAdmin.AutoSize(spellIdInput, 20, 24, nil, 180)
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
-- btnAddAura:SetSize(100, 22)
btnAddAura:SetText(L["Add Aura"])
TrinityAdmin.AutoSize(btnAddAura, 20, 16)
btnAddAura:SetPoint("LEFT", spellIdInput, "RIGHT", 10, 0)
btnAddAura:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Add Aura Tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnAddAura:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnAddAura:SetScript("OnClick", function()
    local spellId = spellIdInput:GetText()
    if spellId == "" or spellId == L["Enter SpellId"] then
        TrinityAdmin:Print(L["addauraerror"])
        return
    end
    local cmd = ".aura " .. spellId
    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

-- Ajout du champ de saisie et bouton Remove Aura
local spellIdInputRemove = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
-- spellIdInputRemove:SetSize(150, 22)
spellIdInputRemove:SetPoint("TOPLEFT", spellIdInput, "BOTTOMLEFT", 0, -15)
spellIdInputRemove:SetAutoFocus(false)
spellIdInputRemove.defaultText = L["Enter SpellId"] -- Ajout nécessaire
TrinityAdmin.AutoSize(spellIdInputRemove, 20, 24, nil, 180)
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
-- btnAddAuraRemove:SetSize(100, 22)
btnAddAuraRemove:SetText(L["Remove Aura"])
TrinityAdmin.AutoSize(btnAddAuraRemove, 20, 16)
btnAddAuraRemove:SetPoint("LEFT", spellIdInputRemove, "RIGHT", 10, 0)
btnAddAuraRemove:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Remove Aura Tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnAddAuraRemove:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnAddAuraRemove:SetScript("OnClick", function()
    local spellId = spellIdInputRemove:GetText()
    if spellId == "" or spellId == spellIdInputRemove.defaultText then
        TrinityAdmin:Print(L["addauraerror"])
        return
    end
    local cmd = ".unaura " .. spellId
    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

-- Champ de saisie "Player Name"
local playerNameInput = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
-- playerNameInput:SetSize(150, 22)
playerNameInput:SetPoint("TOPLEFT", spellIdInputRemove, "BOTTOMLEFT", 0, -15)
playerNameInput:SetAutoFocus(false)
playerNameInput.defaultText = L["Player Name"]
TrinityAdmin.AutoSize(playerNameInput, 20, 24, nil, 180)
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
-- durationInput:SetSize(150, 22)
durationInput:SetPoint("LEFT", playerNameInput, "RIGHT", 10, 0)
durationInput:SetAutoFocus(false)
durationInput.defaultText = L["Duration (s)"]
TrinityAdmin.AutoSize(durationInput, 20, 24, nil, 130)
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
-- btnFreeze:SetSize(100, 22)
btnFreeze:SetText(L["Freeze"])
TrinityAdmin.AutoSize(btnFreeze, 20, 16)
btnFreeze:SetPoint("LEFT", durationInput, "RIGHT", 10, 0)
btnFreeze:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Freeze_tooltip"], 1, 1, 1, 1, true)
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
            -- TrinityAdmin:Print("La Cible est : " .. playerName) -- Pour debug
        else
            TrinityAdmin:Print(L["please_enter_valid_pname_or_target"])
            return
        end
    end
	
    -- Vérifie et définit une durée par défaut (60s) si non précisée
    if duration == "" or duration == durationInput.defaultText then
        duration = "60"
    end

    local cmd = ".freeze " .. playerName .. " " .. duration
    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

-- Champ de saisie "Player Name" pour UnFreeze
local playerNameUnfreezeInput = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
-- playerNameUnfreezeInput:SetSize(150, 22)
playerNameUnfreezeInput:SetPoint("TOPLEFT", playerNameInput, "BOTTOMLEFT", 0, -15)
playerNameUnfreezeInput:SetAutoFocus(false)
playerNameUnfreezeInput.defaultText = L["Player Name unfreez"]
TrinityAdmin.AutoSize(playerNameUnfreezeInput, 20, 24, nil, 180)
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
-- btnUnfreeze:SetSize(100, 22)
btnUnfreeze:SetText(L["UnFreeze"])
TrinityAdmin.AutoSize(btnUnfreeze, 20, 16)
btnUnfreeze:SetPoint("LEFT", playerNameUnfreezeInput, "RIGHT", 10, 0)
btnUnfreeze:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["UnFreeze tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnUnfreeze:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnUnfreeze:SetScript("OnClick", function()
    local playerName = playerNameUnfreezeInput:GetText()

    -- Vérifie et remplace automatiquement le nom du joueur par celui de la cible actuelle si vide
    if playerName == "" or playerName == playerNameUnfreezeInput.defaultText then
        playerName = UnitName("target")
        if playerName then
            -- TrinityAdmin:Print("La Cible est : " .. playerName) -- Pour debug
        else
            TrinityAdmin:Print(L["please_enter_valid_pname_or_target"])
            return
        end
    end
	
    local cmd = ".unfreeze " .. playerName
    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)


-- Bouton liste des joueurs Freeze
local btnFreezeList = CreateServerButtonPage1("FreezeListButton", L["Freeze List"], L["Freeze List tooltip"], ".listfreeze")
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
-- btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText(L["Reset"])
TrinityAdmin.AutoSize(btnResetInputs, 20, 16)
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
page2Title:SetText(L["Player Functions Part 2"])

-- Fonction améliorée pour les boutons simples appliquant la commande à la cible ou au GM par défaut
local function CreateServerButtonPage2(name, text, tooltip, cmd)
    local btn = CreateFrame("Button", name, commandsFramePage2, "UIPanelButtonTemplate")
    -- btn:SetSize(150, 22)
    btn:SetText(text)
	TrinityAdmin.AutoSize(btn, 20, 16)
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
        -- TrinityAdmin:Print("Commande envoyée: " .. finalCmd)
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
local btnRepairItems = CreateServerButtonPage2("RepairItemsButton", L["Repair Items"], L["Repair Items tooltip"], ".repairitems")
btnRepairItems:SetPoint("TOPLEFT", page2Title, "BOTTOMLEFT", 0, -15)

-- Bouton unpossess
local btnUnpossess = CreateServerButtonPage2("UnpossessButton", L["Unpossess"], L["Unpossess tooltip"], ".unpossess")
btnUnpossess:SetPoint("TOPLEFT", btnRepairItems, "TOPRIGHT", 10, 0)

----------------------------
-- Section Unstuck
----------------------------	
-- Champ de saisie "Player Name" pour unstuck
local playerNameunstuckInput = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
-- playerNameunstuckInput:SetSize(150, 22)
playerNameunstuckInput:SetPoint("TOPLEFT", btnRepairItems, "BOTTOMLEFT", 0, -15)
playerNameunstuckInput:SetAutoFocus(false)
playerNameunstuckInput.defaultText = L["Player Name"]
TrinityAdmin.AutoSize(playerNameunstuckInput, 20, 24, nil, 180)
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
-- btnUnstuck:SetSize(100, 22)
btnUnstuck:SetText(L["UnStucke"])
TrinityAdmin.AutoSize(btnUnstuck, 20, 16)
btnUnstuck:SetPoint("LEFT", unstuckLocationDropdown, "RIGHT", 10, 0)
btnUnstuck:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["UnStucke tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnUnstuck:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnUnstuck:SetScript("OnClick", function()
    local playerName = playerNameunstuckInput:GetText()

    -- Vérifie et remplace automatiquement le nom du joueur par celui de la cible actuelle si vide
    if playerName == "" or playerName == playerNameunstuckInput.defaultText then
        playerName = UnitName("target")
        if playerName then
            -- TrinityAdmin:Print("La Cible est : " .. playerName) -- Pour debug
        else
            TrinityAdmin:Print(L["please_enter_valid_pname_or_target"])
            return
        end
    end
	
    local cmd = ".unstuck " .. playerName .. " " .. selectedLocation
    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Section Kick
----------------------------
-- Champ de saisie "Player Name"
local kickNameInput = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
-- kickNameInput:SetSize(150, 22)
kickNameInput:SetPoint("TOPLEFT", playerNameunstuckInput, "BOTTOMLEFT", 0, -15)
kickNameInput:SetAutoFocus(false)
kickNameInput.defaultText = L["Player Name"]
TrinityAdmin.AutoSize(kickNameInput, 20, 24, nil, 180)
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
-- reasonInput:SetSize(150, 22)
reasonInput:SetPoint("LEFT", kickNameInput, "RIGHT", 10, 0)
reasonInput:SetAutoFocus(false)
reasonInput.defaultText = L["Reason3"]
TrinityAdmin.AutoSize(reasonInput, 20, 24, nil, 180)
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
-- btnKick:SetSize(100, 22)
btnKick:SetText(L["Kick"])
TrinityAdmin.AutoSize(btnKick, 20, 16)
btnKick:SetPoint("LEFT", reasonInput, "RIGHT", 10, 0)
btnKick:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Kick tooltip"], 1, 1, 1, 1, true)
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
            -- TrinityAdmin:Print("La Cible est : " .. playerName) -- Pour debug
        else
            TrinityAdmin:Print(L["please_enter_valid_pname_or_target"])
            return
        end
    end
	
    -- Vérifie et définit une durée par défaut (60s) si non précisée
    if reason == "" or reason == reasonInput.defaultText then
        reason = "Oust !!"
    end

    local cmd = ".kick " .. playerName .. " " .. reason
    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Section Levelup
----------------------------

-- Champ de saisie "Player Name"
local levelupNameInput = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
-- levelupNameInput:SetSize(150, 22)
levelupNameInput:SetPoint("TOPLEFT", kickNameInput, "BOTTOMLEFT", 0, -15)
levelupNameInput:SetAutoFocus(false)
levelupNameInput.defaultText = L["Player Name"]
TrinityAdmin.AutoSize(levelupNameInput, 20, 24, nil, 180)
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
-- levelsInput:SetSize(150, 22)
levelsInput:SetPoint("LEFT", levelupNameInput, "RIGHT", 10, 0)
levelsInput:SetAutoFocus(false)
levelsInput.defaultText = L["Levels ?"]
TrinityAdmin.AutoSize(levelsInput, 20, 24, nil, 180)
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
-- btnLevelup:SetSize(100, 22)
btnLevelup:SetText(L["LevelUp"])
TrinityAdmin.AutoSize(btnLevelup, 20, 16)
btnLevelup:SetPoint("LEFT", levelsInput, "RIGHT", 10, 0)
btnLevelup:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["LevelUp Tooltip"], 1, 1, 1, 1, true)
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
            -- TrinityAdmin:Print("La Cible est : " .. playerName)
        else
            TrinityAdmin:Print(L["please_enter_valid_pname_or_target"])
            return
        end
    end

    -- Vérifie et définit une durée par défaut (60s) si non précisée
    if level == "" or level == levelsInput.defaultText then
        level = "1"
    end

    local cmd = ".levelup " .. playerName .. " " .. level
    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Section Remove Cooldownd
----------------------------

-- Champ de saisie "Spell ID" pour Remove Cooldownd
local spellIdInput = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
-- spellIdInput:SetSize(150, 22)
spellIdInput:SetPoint("TOPLEFT", levelupNameInput, "BOTTOMLEFT", 0, -15)
spellIdInput:SetAutoFocus(false)
spellIdInput.defaultText = L["Spell ID"]
TrinityAdmin.AutoSize(spellIdInput, 20, 24, nil, 180)
spellIdInput:SetText(spellIdInput.defaultText)
spellIdInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == self.defaultText then self:SetText("") end
end)
spellIdInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(self.defaultText) end
end)
table.insert(inputFields, spellIdInput)

-- Bouton "Remove Cooldownd"
local btnRemoveCooldown = CreateFrame("Button", nil, commandsFramePage2, "UIPanelButtonTemplate")
-- btnRemoveCooldown:SetSize(150, 22)
btnRemoveCooldown:SetText(L["Remove Cooldownd"])
TrinityAdmin.AutoSize(btnRemoveCooldown, 20, 16)
btnRemoveCooldown:SetPoint("LEFT", spellIdInput, "RIGHT", 10, 0)
btnRemoveCooldown:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Remove Cooldownd Tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnRemoveCooldown:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnRemoveCooldown:SetScript("OnClick", function()
    local spellId = spellIdInput:GetText()
    local cmd
    if spellId == "" or spellId == spellIdInput.defaultText then
        cmd = ".cooldown"
    else
        cmd = ".cooldown " .. spellId
    end
    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)
----------------------------
-- Bouton Reset Inputs
----------------------------
local btnResetInputs = CreateFrame("Button", nil, commandsFramePage2, "UIPanelButtonTemplate")
-- btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText(L["Reset"])
TrinityAdmin.AutoSize(btnResetInputs, 20, 16)
btnResetInputs:SetPoint("TOPRIGHT", page2Title, "TOPRIGHT", 270, 0)
btnResetInputs:SetScript("OnClick", ResetInputs)

---------------------------------------------------------------
-- Page 3
---------------------------------------------------------------
local commandsFramePage3 = CreateFrame("Frame", nil, pages[3])
commandsFramePage3:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
commandsFramePage3:SetSize(500, 350)

local page3Title = commandsFramePage3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page3Title:SetPoint("TOPLEFT", commandsFramePage3, "TOPLEFT", 0, 0)
page3Title:SetText(L["Characters Functions Part 3"])

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
-- renameNameInput:SetSize(150, 22)
renameNameInput:SetPoint("TOPLEFT", page3Title, "BOTTOMLEFT", 0, -20)
renameNameInput:SetAutoFocus(false)
renameNameInput.defaultText = L["Character Name Rename"]
TrinityAdmin.AutoSize(renameNameInput, 20, 24, nil, 180)
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
-- renameNewNameInput:SetSize(150, 22)
renameNewNameInput:SetPoint("LEFT", renameNameInput, "RIGHT", 10, 0)
renameNewNameInput:SetAutoFocus(false)
renameNewNameInput.defaultText = L["New Name"]
TrinityAdmin.AutoSize(renameNewNameInput, 20, 24, nil, 180)
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
-- btnRename:SetSize(100, 22)
btnRename:SetText(L["Rename"])
TrinityAdmin.AutoSize(btnRename, 20, 16)
btnRename:SetPoint("LEFT", renameNewNameInput, "RIGHT", 10, 0)
btnRename:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Rename tooltip"], 1, 1, 1, 1, true)
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
            TrinityAdmin:Print(L["please_enter_valid_pname_or_target"])
            return
        end
    end

    local cmd = ".character rename " .. nameValue

    -- Ajoute le nouveau nom seulement s'il est précisé
    if newNameValue ~= "" and newNameValue ~= renameNewNameInput.defaultText then
        cmd = cmd .. " " .. newNameValue
    end

    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction char reputation
----------------------------

-- Champ de saisie "Name"
local reputationNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
-- reputationNameInput:SetSize(150, 22)
reputationNameInput:SetPoint("TOPLEFT", renameNameInput, "BOTTOMLEFT", 0, -10)
reputationNameInput:SetAutoFocus(false)
reputationNameInput.defaultText = L["Character Name Rename"]
TrinityAdmin.AutoSize(reputationNameInput, 20, 24, nil, 180)
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
-- btnReputation:SetSize(130, 22)
btnReputation:SetText(L["Show Reputation"])
TrinityAdmin.AutoSize(btnReputation, 20, 16)
btnReputation:SetPoint("LEFT", reputationNameInput, "RIGHT", 10, 0)
btnReputation:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Show Reputation tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnReputation:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnReputation:SetScript("OnClick", function()
    local nameValue = reputationNameInput:GetText()

    -- Si "Name" vide, utilise la cible du GM
    if nameValue == "" or nameValue == reputationNameInput.defaultText then
        nameValue = UnitName("target")
        if not nameValue then
            TrinityAdmin:Print(L["please_enter_valid_pname_or_target"])
            return
        end
    end

    local cmd = ".character reputation " .. nameValue

    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction char Titles
----------------------------

-- Champ de saisie "Name"
local titlesNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
-- titlesNameInput:SetSize(150, 22)
titlesNameInput:SetPoint("TOPLEFT", reputationNameInput, "BOTTOMLEFT", 0, -10)
titlesNameInput:SetAutoFocus(false)
titlesNameInput.defaultText = L["Character Name Rename"]
TrinityAdmin.AutoSize(titlesNameInput, 20, 24, nil, 180)
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
-- btnTitles:SetSize(110, 22)
btnTitles:SetText(L["Show Titles"])
TrinityAdmin.AutoSize(btnTitles, 20, 16)
btnTitles:SetPoint("LEFT", titlesNameInput, "RIGHT", 10, 0)
btnTitles:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Show Titles Tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnTitles:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnTitles:SetScript("OnClick", function()
    local nameValue = titlesNameInput:GetText()

    -- Si "Name" vide, utilise la cible du GM
    if nameValue == "" or nameValue == titlesNameInput.defaultText then
        nameValue = UnitName("target")
        if not nameValue then
            TrinityAdmin:Print(L["please_enter_valid_pname_or_target"])
            return
        end
    end

    local cmd = ".character titles " .. nameValue

    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction char Changerace
----------------------------

-- Champ de saisie "Name"
local changeraceNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
-- changeraceNameInput:SetSize(150, 22)
changeraceNameInput:SetPoint("TOPLEFT", titlesNameInput, "BOTTOMLEFT", 0, -10)
changeraceNameInput:SetAutoFocus(false)
changeraceNameInput.defaultText = L["Character Name Rename"]
TrinityAdmin.AutoSize(changeraceNameInput, 20, 24, nil, 180)
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
-- btnChangeRace:SetSize(120, 22)
btnChangeRace:SetText(L["Change Race"])
TrinityAdmin.AutoSize(btnChangeRace, 20, 16)
btnChangeRace:SetPoint("LEFT", changeraceNameInput, "RIGHT", 10, 0)
btnChangeRace:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Change Race Tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnChangeRace:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnChangeRace:SetScript("OnClick", function()
    local nameValue = changeraceNameInput:GetText()

    -- Si "Name" est vide, utilise automatiquement la cible actuelle
    if nameValue == "" or nameValue == changeraceNameInput.defaultText or not nameValue then
        TrinityAdmin:Print(L["please_enter_valid_pname_or_target"])
        return
    end

    local cmd = ".character changerace " .. nameValue

    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction char Changefaction
----------------------------

-- Champ de saisie "Name"
local changefactionNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
-- changefactionNameInput:SetSize(150, 22)
changefactionNameInput:SetPoint("TOPLEFT", changeraceNameInput, "BOTTOMLEFT", 0, -10)
changefactionNameInput:SetAutoFocus(false)
changefactionNameInput.defaultText = L["Character Name Rename"]
TrinityAdmin.AutoSize(changefactionNameInput, 20, 24, nil, 180)
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
-- btnChangefaction:SetSize(120, 22)
btnChangefaction:SetText(L["Change Faction"])
TrinityAdmin.AutoSize(btnChangefaction, 20, 16)
btnChangefaction:SetPoint("LEFT", changefactionNameInput, "RIGHT", 10, 0)
btnChangefaction:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Change Faction Tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnChangefaction:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnChangefaction:SetScript("OnClick", function()
    local nameValue = changefactionNameInput:GetText()

    -- Si "Name" est vide, utilise automatiquement la cible actuelle
    if nameValue == "" or nameValue == changefactionNameInput.defaultText or not nameValue then
        TrinityAdmin:Print(L["please_enter_value_or_select_player"])
        return
    end

    local cmd = ".character changefaction " .. nameValue

    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction char Customize
----------------------------
	
-- Champ de saisie "Name"
local customizeNameInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
-- customizeNameInput:SetSize(150, 22)
customizeNameInput:SetPoint("TOPLEFT", changefactionNameInput, "BOTTOMLEFT", 0, -10)
customizeNameInput:SetAutoFocus(false)
customizeNameInput.defaultText = L["Character Name Rename"]
TrinityAdmin.AutoSize(customizeNameInput, 20, 24, nil, 180)
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
-- btnCustomize:SetSize(140, 22)
btnCustomize:SetText(L["Character Customize"])
TrinityAdmin.AutoSize(btnCustomize, 20, 16)
btnCustomize:SetPoint("LEFT", customizeNameInput, "RIGHT", 10, 0)
btnCustomize:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Character Customize Tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnCustomize:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnCustomize:SetScript("OnClick", function()
    local nameValue = customizeNameInput:GetText()

    -- Si "Name" est vide, utilise automatiquement la cible actuelle
    if nameValue == "" or nameValue == customizeNameInput.defaultText or not nameValue then
        TrinityAdmin:Print(L["please_enter_value_or_select_player"])
        return
    end

    local cmd = ".character customize " .. nameValue

    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction change level
----------------------------
-- Champ de saisie "Character Name"
local charNameLevelInput = CreateFrame("EditBox", nil, commandsFramePage3, "InputBoxTemplate")
-- charNameLevelInput:SetSize(150, 22)
charNameLevelInput:SetPoint("TOPLEFT", customizeNameInput, "BOTTOMLEFT", 0, -10)
charNameLevelInput:SetAutoFocus(false)
charNameLevelInput.defaultText = L["Character Name Rename"]
TrinityAdmin.AutoSize(charNameLevelInput, 20, 24, nil, 180)
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
-- levelValueInput:SetSize(100, 22)
levelValueInput:SetPoint("LEFT", charNameLevelInput, "RIGHT", 10, 0)
levelValueInput:SetAutoFocus(false)
levelValueInput.defaultText = L["Level5"]
TrinityAdmin.AutoSize(levelValueInput, 20, 24, nil, 100)
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
-- btnSetLevel:SetSize(100, 22)
btnSetLevel:SetText(L["Set"])
TrinityAdmin.AutoSize(btnSetLevel, 20, 16)
btnSetLevel:SetPoint("LEFT", levelValueInput, "RIGHT", 10, 0)
btnSetLevel:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["set level tooltip"] , 1, 1, 1, 1, true)
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
            TrinityAdmin:Print(L["please_enter_value_or_select_player"])
            return
        end
    end

    local cmd = ".character level " .. charName

    -- Si un niveau est renseigné, ajoute-le à la commande
    if level ~= "" and level ~= levelValueInput.defaultText then
        cmd = cmd .. " " .. level
    end

    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)
----------------------------
-- Bouton Reset Inputs
----------------------------
local btnResetInputs = CreateFrame("Button", nil, commandsFramePage3, "UIPanelButtonTemplate")
-- btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText(L["Reset"])
TrinityAdmin.AutoSize(btnResetInputs, 20, 16)
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
page4Title:SetText(L["Characters Functions Part 4"])

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
-- characterchangeaccountNameInput:SetSize(150, 22)
characterchangeaccountNameInput:SetPoint("TOPLEFT", page3Title, "BOTTOMLEFT", 0, -20)
characterchangeaccountNameInput:SetAutoFocus(false)
characterchangeaccountNameInput.defaultText = L["Character Name Rename"]
TrinityAdmin.AutoSize(characterchangeaccountNameInput, 20, 24, nil, 150)
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
-- accountNewAccountInput:SetSize(150, 22)
accountNewAccountInput:SetPoint("LEFT", characterchangeaccountNameInput, "RIGHT", 10, 0)
accountNewAccountInput:SetAutoFocus(false)
accountNewAccountInput.defaultText = L["Account6"]
TrinityAdmin.AutoSize(accountNewAccountInput, 20, 24, nil, 150)
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
-- btnRename:SetSize(120, 22)
btnRename:SetText(L["Change Account"])
TrinityAdmin.AutoSize(btnRename, 20, 16)
btnRename:SetPoint("LEFT", accountNewAccountInput, "RIGHT", 10, 0)
btnRename:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Change Account tooltip"], 1, 1, 1, 1, true)
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
            TrinityAdmin:Print(L["change account error"])
            return
        end
    end
	
    local cmd = ".character changeaccount " .. nameValue .. " " ..newAccountValue
	
    SendChatMessage(cmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- character deleted delete and others
----------------------------
-- Vérifie l'existence de la table inputFields
if not inputFields then inputFields = {} end

-- Définition des options du dropdown
local dropdownOptions = {
    { text = "character deleted delete", defaultText = L["Enter Char Name or Guid"], command = ".character deleted delete", tooltip = L["Enter Char Name or Guid delet tooltip"] },
    { text = "character deleted list", defaultText = L["Enter Char Name or Guid"], command = ".character deleted list", tooltip = L["Enter Char Name or Guid delete list tooltip"] },
    { text = "character deleted old", defaultText = L["Enter keepDays Value"], command = ".character deleted old", tooltip = L["Enter keepDays Value tooltip"] },
    { text = "character erase", defaultText = L["Enter Char Name"], command = ".character erase", tooltip = L["Enter Char Name erase tooltip"] },
}

local selectedOption = dropdownOptions[1] -- Option par défaut initiale

-- Création du champ de saisie dynamique
local dynamicInput = CreateFrame("EditBox", nil, commandsFramePage4, "InputBoxTemplate")
-- dynamicInput:SetSize(150, 22)
dynamicInput:SetPoint("TOPLEFT", characterchangeaccountNameInput, "BOTTOMLEFT", 0, -20)
dynamicInput:SetAutoFocus(false)
dynamicInput.defaultText = selectedOption.defaultText
dynamicInput:SetText(dynamicInput.defaultText)
TrinityAdmin.AutoSize(dynamicInput, 20, 12, nil, 150)

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
-- btnExecute:SetSize(100, 22)
btnExecute:SetText(L["Execute3"])
TrinityAdmin.AutoSize(btnExecute, 20, 16)
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
        TrinityAdmin:Print(L["Please enter a valid value in the input field."])
        return
    end

    local finalCmd = selectedOption.command .. " " .. inputValue

    SendChatMessage(finalCmd, "SAY")
    -- TrinityAdmin:Print("Commande envoyée : " .. finalCmd)
end)


----------------------------
-- Fonction Restore
----------------------------

-- Champ obligatoire "Enter Char Name or Guid"
local restoreCharGuidInput = CreateFrame("EditBox", nil, commandsFramePage4, "InputBoxTemplate")
-- restoreCharGuidInput:SetSize(170, 22)
restoreCharGuidInput:SetPoint("TOPLEFT", dynamicInput, "TOPLEFT", 0, -40)
restoreCharGuidInput:SetAutoFocus(false)
restoreCharGuidInput.defaultText = L["Enter Char Name or Guid"]
TrinityAdmin.AutoSize(restoreCharGuidInput, 20, 24, nil, 240)
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
-- restoreNewNameInput:SetSize(150, 22)
restoreNewNameInput:SetPoint("LEFT", restoreCharGuidInput, "RIGHT", 10, 0)
restoreNewNameInput:SetAutoFocus(false)
restoreNewNameInput.defaultText = L["New Name7"]
TrinityAdmin.AutoSize(restoreNewNameInput, 20, 24, nil, 150)
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
-- restoreNewAccountInput:SetSize(150, 22)
restoreNewAccountInput:SetPoint("LEFT", restoreNewNameInput, "RIGHT", 10, 0)
restoreNewAccountInput:SetAutoFocus(false)
restoreNewAccountInput.defaultText = L["New Account7"]
TrinityAdmin.AutoSize(restoreNewAccountInput, 20, 24, nil, 150)
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
-- btnRestore:SetSize(100, 22)
btnRestore:SetText(L["Restore7"])
TrinityAdmin.AutoSize(btnRestore, 20, 16)
btnRestore:SetPoint("LEFT", restoreNewAccountInput, "RIGHT", 10, 0)

btnRestore:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Restore7 tooltip"] , 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnRestore:SetScript("OnLeave", function() GameTooltip:Hide() end)

btnRestore:SetScript("OnClick", function()
    local guidOrName = restoreCharGuidInput:GetText()
    local newName = restoreNewNameInput:GetText()
    local newAccount = restoreNewAccountInput:GetText()

    -- Vérifie si le premier champ est renseigné
    if guidOrName == "" or guidOrName == restoreCharGuidInput.defaultText then
        TrinityAdmin:Print(L["error restore"])
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
    -- TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)


local btnResetInputs = CreateFrame("Button", nil, commandsFramePage4, "UIPanelButtonTemplate")
-- btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText(L["Reset"])
TrinityAdmin.AutoSize(btnResetInputs, 20, 16)
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
page5Title:SetText(L["Pets Functions"])

-- Fonction améliorée pour les boutons simples appliquant la commande à la cible ou au GM par défaut
local function CreateServerButtonPage5(name, text, tooltip, cmd)
    local btn = CreateFrame("Button", name, commandsFramePage5, "UIPanelButtonTemplate")
    -- btn:SetSize(150, 22)
    btn:SetText(text)
	TrinityAdmin.AutoSize(btn, 20, 16)
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
        -- TrinityAdmin:Print("Commande envoyée: " .. finalCmd)
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
local btnPetCreate = CreateServerButtonPage5("PetCreateButton", L["Create Pet"], L["Create Pet Tooltip"], ".pet create")
btnPetCreate:SetPoint("TOPLEFT", page5Title, "BOTTOMLEFT", 0, -15)

----------------------------
-- Fonction Learn Pet
----------------------------
-- Champ de saisie "Enterspell"
local petlearnInput = CreateFrame("EditBox", nil, commandsFramePage5, "InputBoxTemplate")
-- petlearnInput:SetSize(90, 22)
petlearnInput:SetPoint("TOPLEFT", btnPetCreate, "BOTTOMLEFT", 0, -10)
petlearnInput:SetAutoFocus(false)
petlearnInput.defaultText = L["Spell ID"]
TrinityAdmin.AutoSize(petlearnInput, 20, 24, nil, 110)
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
-- btnLearnPet:SetSize(120, 22)
btnLearnPet:SetText(L["Learn to Pet"])
TrinityAdmin.AutoSize(btnLearnPet, 20, 16)
btnLearnPet:SetPoint("LEFT", petlearnInput, "RIGHT", 10, 0)
btnLearnPet:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Learn to Pet tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnLearnPet:SetScript("OnLeave", function() GameTooltip:Hide() end)

btnLearnPet:SetScript("OnClick", function()
    local petName = petlearnInput:GetText()
	-- Si "petName" vide, on envoi erreur
        if not petName or petName == "" or petName == petlearnInput.defaultText then
            TrinityAdmin:Print(L["pet learn error"])
            return
		end
    local cmd = ".pet learn " .. petName
    SendChatMessage(cmd, "SAY")
   --  TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction Pet Level
----------------------------
-- Champ de saisie "Level"
local petlevelInput = CreateFrame("EditBox", nil, commandsFramePage5, "InputBoxTemplate")
-- petlevelInput:SetSize(90, 22)
petlevelInput:SetPoint("TOPLEFT", petlearnInput, "BOTTOMLEFT", 0, -10)
petlevelInput:SetAutoFocus(false)
petlevelInput.defaultText = L["Level69"]
TrinityAdmin.AutoSize(petlevelInput, 20, 24, nil, 70)
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
-- btnPetlevel:SetSize(120, 22)
btnPetlevel:SetText(L["Set Level69"])
TrinityAdmin.AutoSize(btnPetlevel, 20, 16)
btnPetlevel:SetPoint("LEFT", petlevelInput, "RIGHT", 10, 0)
btnPetlevel:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Set Level69 tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnPetlevel:SetScript("OnLeave", function() GameTooltip:Hide() end)

btnPetlevel:SetScript("OnClick", function()
    local petLevel = petlevelInput:GetText()
	 -- Si "level" vide, on envoi erreur
        if not petLevel or petLevel == "" or petLevel == petlevelInput.defaultText then
            TrinityAdmin:Print(L["Set Level69 error"])
            return
		end
    local cmd = ".pet level " .. petLevel
    SendChatMessage(cmd, "SAY")
   --  TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- Fonction Pet unlearn
----------------------------
-- Champ de spellid "Level"
local spellidInput = CreateFrame("EditBox", nil, commandsFramePage5, "InputBoxTemplate")
-- spellidInput:SetSize(90, 22)
spellidInput:SetPoint("TOPLEFT", petlevelInput, "BOTTOMLEFT", 0, -10)
spellidInput:SetAutoFocus(false)
spellidInput.defaultText = L["Level69"]
TrinityAdmin.AutoSize(spellidInput, 20, 24, nil, 70)
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
-- btnPetUnlearn:SetSize(120, 22)
btnPetUnlearn:SetText(L["Unlearn69"])
TrinityAdmin.AutoSize(btnPetUnlearn, 20, 16)
btnPetUnlearn:SetPoint("LEFT", spellidInput, "RIGHT", 10, 0)
btnPetUnlearn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Unlearn69 tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnPetUnlearn:SetScript("OnLeave", function() GameTooltip:Hide() end)

btnPetUnlearn:SetScript("OnClick", function()
    local petSpell = spellidInput:GetText()
    -- Si "level" vide, on envoi erreur
        if not petSpell or petSpell == "" or petSpell == spellidInput.defaultText then
            TrinityAdmin:Print(L["Unlearn69 error"])
            return
		end
	
    local cmd = ".pet unleran " .. petSpell
    SendChatMessage(cmd, "SAY")
   --  TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)
	
local btnResetInputs = CreateFrame("Button", nil, commandsFramePage5, "UIPanelButtonTemplate")
-- btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText(L["Reset"])
TrinityAdmin.AutoSize(btnResetInputs, 20, 16)
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
page6Title:SetText(L["Player Dumps"])

-- Fonction améliorée pour les boutons simples appliquant la commande à la cible ou au GM par défaut
local function CreateServerButtonPage5(name, text, tooltip, cmd)
    local btn = CreateFrame("Button", name, commandsFramePage6, "UIPanelButtonTemplate")
    -- btn:SetSize(150, 22)
    btn:SetText(text)
	TrinityAdmin.AutoSize(btn, 20, 16)
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
       --  TrinityAdmin:Print("Commande envoyée: " .. finalCmd)
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
-- pdumpcopyNameInput:SetSize(150, 22)
pdumpcopyNameInput:SetPoint("TOPLEFT", page6Title, "BOTTOMLEFT", 0, -20)
pdumpcopyNameInput:SetAutoFocus(false)
pdumpcopyNameInput.defaultText = L["Player NameOrGUID"]
TrinityAdmin.AutoSize(pdumpcopyNameInput, 20, 24, nil, 150)
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
-- accountInput:SetSize(70, 22)
accountInput:SetPoint("LEFT", pdumpcopyNameInput, "RIGHT", 10, 0)
accountInput:SetAutoFocus(false)
accountInput.defaultText = L["Account69"]
TrinityAdmin.AutoSize(accountInput, 20, 24, nil, 150)
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
-- newnameInput:SetSize(120, 22)
newnameInput:SetPoint("LEFT", accountInput, "RIGHT", 10, 0)
newnameInput:SetAutoFocus(false)
newnameInput.defaultText = L["New Name70"]
TrinityAdmin.AutoSize(newnameInput, 20, 24, nil, 150)
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
-- newguidInput:SetSize(70, 22)
newguidInput:SetPoint("LEFT", newnameInput, "RIGHT", 10, 0)
newguidInput:SetAutoFocus(false)
newguidInput.defaultText = L["New Guid70"]
TrinityAdmin.AutoSize(newguidInput, 20, 24, nil, 150)
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
-- btnDumpCopy:SetSize(70, 22)
btnDumpCopy:SetText(L["Dump70"])
TrinityAdmin.AutoSize(btnDumpCopy, 20, 16)
btnDumpCopy:SetPoint("LEFT", newguidInput, "RIGHT", 10, 0)
btnDumpCopy:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Dump70 Tooltip"], 1, 1, 1, 1, true)
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
        TrinityAdmin:Print(L["pdump_error"])
        return
    end

    -- Construction de la commande
    local cmd = ".pdump copy " .. nameValue .. " " .. accountValue .. " " .. newNameValue
    -- Ajout du champ newguid s'il est renseigné (différent de vide ou du texte par défaut)
    if newGuidValue ~= "" and newGuidValue ~= newguidInput.defaultText then
        cmd = cmd .. " " .. newGuidValue
    end

    SendChatMessage(cmd, "SAY")
   --  TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- pdumpload
----------------------------
-- Champ de saisie "Filename"
local pdumploadFileInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
-- pdumploadFileInput:SetSize(150, 22)
pdumploadFileInput:SetPoint("TOPLEFT", pdumpcopyNameInput, "BOTTOMLEFT", 0, -20)
pdumploadFileInput:SetAutoFocus(false)
pdumploadFileInput.defaultText = L["Enter Filename"]
TrinityAdmin.AutoSize(pdumploadFileInput, 20, 24, nil, 150)
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
-- accountLoadInput:SetSize(70, 22)
accountLoadInput:SetPoint("LEFT", pdumploadFileInput, "RIGHT", 10, 0)
accountLoadInput:SetAutoFocus(false)
accountLoadInput.defaultText = L["Account69"]
TrinityAdmin.AutoSize(accountLoadInput, 20, 24, nil, 150)
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
-- newnameLoadInput:SetSize(120, 22)
newnameLoadInput:SetPoint("LEFT", accountLoadInput, "RIGHT", 10, 0)
newnameLoadInput:SetAutoFocus(false)
newnameLoadInput.defaultText = L["New Name70"]
TrinityAdmin.AutoSize(newnameLoadInput, 20, 24, nil, 150)
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
-- newguidLoadInput:SetSize(70, 22)
newguidLoadInput:SetPoint("LEFT", newnameLoadInput, "RIGHT", 10, 0)
newguidLoadInput:SetAutoFocus(false)
newguidLoadInput.defaultText = L["New Guid70"]
TrinityAdmin.AutoSize(newguidLoadInput, 20, 24, nil, 150)
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
-- btnDumpLoad:SetSize(70, 22)
btnDumpLoad:SetText(L["Load70"])
TrinityAdmin.AutoSize(btnDumpLoad, 20, 16)
btnDumpLoad:SetPoint("LEFT", newguidLoadInput, "RIGHT", 10, 0)
btnDumpLoad:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Load70 Tooltip"], 1, 1, 1, 1, true)
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
        TrinityAdmin:Print(L["Load70 error"])
        return
    end

    -- Construction de la commande
    local cmd = ".pdump copy " .. nameValue .. " " .. accountValue .. " " .. newNameValue
    -- Ajout du champ newguid s'il est renseigné (différent de vide ou du texte par défaut)
    if newGuidValue ~= "" and newGuidValue ~= newguidLoadInput.defaultText then
        cmd = cmd .. " " .. newGuidValue
    end

    SendChatMessage(cmd, "SAY")
   --  TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)

----------------------------
-- pdumpwrite
----------------------------
-- Champ de saisie "Filename"
local pdumpwriteFileInput = CreateFrame("EditBox", nil, commandsFramePage6, "InputBoxTemplate")
-- pdumpwriteFileInput:SetSize(120, 22)
pdumpwriteFileInput:SetPoint("TOPLEFT", pdumploadFileInput, "BOTTOMLEFT", 0, -20)
pdumpwriteFileInput:SetAutoFocus(false)
pdumpwriteFileInput.defaultText = L["Enter Filename"]
TrinityAdmin.AutoSize(pdumpwriteFileInput, 20, 24, nil, 150)
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
-- playerNameWriteInput:SetSize(150, 22)
playerNameWriteInput:SetPoint("LEFT", pdumpwriteFileInput, "RIGHT", 10, 0)
playerNameWriteInput:SetAutoFocus(false)
playerNameWriteInput.defaultText = L["Player NameOrGUID"]
TrinityAdmin.AutoSize(playerNameWriteInput, 20, 24, nil, 150)
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
-- btnDumpWrite:SetSize(70, 22)
btnDumpWrite:SetText(L["Write"])
TrinityAdmin.AutoSize(btnDumpWrite, 20, 16)
btnDumpWrite:SetPoint("LEFT", playerNameWriteInput, "RIGHT", 10, 0)
btnDumpWrite:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Write tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnDumpWrite:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnDumpWrite:SetScript("OnClick", function()
    local nameValueWrite    = pdumpwriteFileInput:GetText()
    local accountValueWrite = playerNameWriteInput:GetText()

    -- Vérification des champs obligatoires
    if nameValueWrite == "" or nameValueWrite == pdumpwriteFileInput.defaultText or
       accountValueWrite == "" or accountValueWrite == playerNameWriteInput.defaultText then
        TrinityAdmin:Print(L["write error"])
        return
    end

    -- Construction de la commande
    local cmd = ".pdump write " .. nameValueWrite .. " " .. accountValueWrite

    SendChatMessage(cmd, "SAY")
   --  TrinityAdmin:Print("Commande envoyée : " .. cmd)
end)
	
-----------------------------
-- Bouton reset
----------------------------
local btnResetInputs = CreateFrame("Button", nil, commandsFramePage6, "UIPanelButtonTemplate")
-- btnResetInputs:SetSize(100, 22)
btnResetInputs:SetText(L["Reset"])
TrinityAdmin.AutoSize(btnResetInputs, 20, 16)
btnResetInputs:SetPoint("TOPRIGHT", btnDumpWrite, "BOTTOMLEFT", 0, -15)
btnResetInputs:SetScript("OnClick", ResetInputs)

---------------------------------------------------------------
-- Page 7 : Player Info Capture (.pinfo)
---------------------------------------------------------------

local commandsFramePage7 = CreateFrame("Frame", nil, pages[7])
commandsFramePage7:SetPoint("TOPLEFT", pages[7], "TOPLEFT", 20, -40)
commandsFramePage7:SetSize(500, 350)

local page7Title = commandsFramePage7:CreateFontString(nil, "OVERLAY", "GameFontNormal")
page7Title:SetPoint("TOPLEFT", commandsFramePage7, "TOPLEFT", 0, 0)
page7Title:SetText(L["Advances Player Info And Items Send"])

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
    pinfoAceFrame:SetTitle(L["Informations du joueur"])
    pinfoAceFrame:SetStatusText(L["Player Infos var"])
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
    group:SetTitle(L["Informations générales"])
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
        -- TrinityAdmin:Print("[DEBUG] Capture terminée. Affichage AceGUI.")
    else
        -- TrinityAdmin:Print("[DEBUG] Fin de capture mais aucune info capturée.")
    end
end

-- ============================================================
-- 5) Bouton .pinfo sur la page 7
-- ============================================================
local btnCapturePinfo = CreateFrame("Button", nil, commandsFramePage7, "UIPanelButtonTemplate")
btnCapturePinfo:SetPoint("TOPLEFT", page7Title, "TOPLEFT", 0, -20)
btnCapturePinfo:SetText(L["Advanced .Pinfo"])
TrinityAdmin.AutoSize(btnCapturePinfo, 20, 16)
-- btnCapturePinfo:SetHeight(22)
-- btnCapturePinfo:SetWidth(btnCapturePinfo:GetTextWidth() + 20)
btnCapturePinfo:SetScript("OnClick", function()
    SendChatMessage(".pinfo", "SAY")
    capturingPinfo = true
    collectedInfo = {}
    if captureTimer then captureTimer:Cancel() end
    captureTimer = C_Timer.NewTimer(1, FinishCapture)
    -- TrinityAdmin:Print("[DEBUG] .pinfo envoyé, capture activée")
end)

local mailSubtitle = commandsFramePage7:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mailSubtitle:SetPoint("TOPLEFT", btnCapturePinfo, "BOTTOMLEFT", 0, -10)
mailSubtitle:SetText(L["Send Items by Mail to Player"])

-- Création des champs de saisie Player Name, Subject, Email Text
local playerNameEditBox = CreateFrame("EditBox", nil, commandsFramePage7, "InputBoxTemplate")
-- playerNameEditBox:SetSize(150, 22)
playerNameEditBox:SetPoint("TOPLEFT", mailSubtitle, "BOTTOMLEFT", 0, -10)
playerNameEditBox:SetAutoFocus(false)
playerNameEditBox:SetText(L["Player Name"])
TrinityAdmin.AutoSize(playerNameEditBox, 20, 13, nil, 150)

local subjectEditBox = CreateFrame("EditBox", nil, commandsFramePage7, "InputBoxTemplate")
-- subjectEditBox:SetSize(150, 22)
subjectEditBox:SetPoint("LEFT", playerNameEditBox, "RIGHT", 10, 0)
subjectEditBox:SetAutoFocus(false)
subjectEditBox:SetText(L["Subject"])
TrinityAdmin.AutoSize(subjectEditBox, 20, 13, nil, 150)

local emailTextEditBox = CreateFrame("EditBox", nil, commandsFramePage7, "InputBoxTemplate")
-- emailTextEditBox:SetSize(150, 22)
emailTextEditBox:SetPoint("LEFT", subjectEditBox, "RIGHT", 10, 0)
emailTextEditBox:SetAutoFocus(false)
emailTextEditBox:SetText(L["Email Text"])
TrinityAdmin.AutoSize(emailTextEditBox, 20, 13, nil, 150)

-- Création des 24 champs de saisie pour les Items et Counts, alignés précisément 3 paires par ligne
local itemEditBoxes = {}
local startX = 0
local startY = -25
local xSpacing = 220 -- espacement horizontal entre chaque paire Item-Count
local ySpacing = -25 -- espacement vertical entre chaque ligne
local pairsPerLine = 3

local currentXOffset = startX
local currentYOffset = startY

for i = 1, 12 do
    -- Item Count en premier
    local itemCountEditBox = CreateFrame("EditBox", nil, commandsFramePage7, "InputBoxTemplate")
    itemCountEditBox:SetSize(100, 22)
    itemCountEditBox:SetPoint("TOPLEFT", playerNameEditBox, "BOTTOMLEFT", currentXOffset, currentYOffset)
    itemCountEditBox:SetAutoFocus(false)
    itemCountEditBox:SetText("Item " .. i .. " Count")

    -- Item ID ensuite
    local itemIdEditBox = CreateFrame("EditBox", nil, commandsFramePage7, "InputBoxTemplate")
    itemIdEditBox:SetSize(100, 22)
    itemIdEditBox:SetPoint("LEFT", itemCountEditBox, "RIGHT", 10, 0) -- ajustement mineur (5 pixels)
    itemIdEditBox:SetAutoFocus(false)
    itemIdEditBox:SetText("Item " .. i)

    -- Sauvegarde des boîtes
    itemEditBoxes[#itemEditBoxes + 1] = {itemIdEditBox, itemCountEditBox}

    -- Gestion de la disposition (3 paires par ligne)
    if i % pairsPerLine == 0 then
        currentXOffset = startX -- réinitialisation en début de ligne
        currentYOffset = currentYOffset + ySpacing
    else
        currentXOffset = currentXOffset + xSpacing
    end
end

-- Positionnement correct du bouton en dessous des champs
local btnSendItems = CreateFrame("Button", nil, commandsFramePage7, "UIPanelButtonTemplate")
btnSendItems:SetPoint("TOPLEFT", playerNameEditBox, "BOTTOMLEFT", 0, currentYOffset)
btnSendItems:SetText(L["Send_Items"])
TrinityAdmin.AutoSize(btnSendItems, 20, 16)
-- btnSendItems:SetHeight(22)
-- btnSendItems:SetWidth(btnSendItems:GetTextWidth() + 20)


local tooltipSendItems = L["tooltipSendItems tooltip"]

btnSendItems:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(tooltipSendItems, 1, 1, 1, 1, true)
    GameTooltip:Show()
end)

btnSendItems:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

btnSendItems:SetScript("OnClick", function()
    local command = ".send items " .. playerNameEditBox:GetText() ..
                    " \"" .. subjectEditBox:GetText() .. "\"" ..
                    " \"" .. emailTextEditBox:GetText() .. "\""

    for _, boxes in ipairs(itemEditBoxes) do
        local item = boxes[1]:GetText()
        local count = boxes[2]:GetText()

        if item and item ~= "" and not item:find("Item") then
            command = command .. " " .. item
            if count and count ~= "" and not count:find("Count") then
                command = command .. ":" .. count
            end
        end
    end

    SendChatMessage(command, "SAY")
    -- TrinityAdmin:Print("[DEBUG] Commande envoyée: " .. command)
end)

---------------------------------------------------------------
-- Page 8 : Mails send
---------------------------------------------------------------

local commandsFramePage8 = CreateFrame("Frame", nil, pages[8])
commandsFramePage8:SetPoint("TOPLEFT", pages[8], "TOPLEFT", 20, -40)
commandsFramePage8:SetSize(500, 350)

local page8Title = commandsFramePage8:CreateFontString(nil, "OVERLAY", "GameFontNormal")
page8Title:SetPoint("TOPLEFT", commandsFramePage8, "TOPLEFT", 0, 0)
page8Title:SetText(L["Send Mails Funcs"])

-- Send Mail Section
local mailPlayerName = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- mailPlayerName:SetSize(150, 22)
mailPlayerName:SetPoint("TOPLEFT", page8Title, "BOTTOMLEFT", 0, -15)
mailPlayerName:SetAutoFocus(false)
mailPlayerName:SetText(L["Player Name"])
TrinityAdmin.AutoSize(mailPlayerName, 20, 13, nil, 150)

local mailSubject = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- mailSubject:SetSize(150, 22)
mailSubject:SetPoint("LEFT", mailPlayerName, "RIGHT", 10, 0)
mailSubject:SetAutoFocus(false)
mailSubject:SetText(L["Subject"])
TrinityAdmin.AutoSize(mailSubject, 20, 13, nil, 150)

local mailText = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- mailText:SetSize(150, 22)
mailText:SetPoint("LEFT", mailSubject, "RIGHT", 10, 0)
mailText:SetAutoFocus(false)
mailText:SetText("Text")
TrinityAdmin.AutoSize(mailText, 20, 13, nil, 150)

local btnSendMail = CreateFrame("Button", nil, commandsFramePage8, "UIPanelButtonTemplate")
btnSendMail:SetPoint("LEFT", mailText, "RIGHT", 10, 0)
btnSendMail:SetText(L["Email Text"])
TrinityAdmin.AutoSize(btnSendMail, 20, 16)
-- btnSendMail:SetHeight(22)
-- btnSendMail:SetWidth(btnSendMail:GetTextWidth() + 20)
btnSendMail:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["sendemail tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnSendMail:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnSendMail:SetScript("OnClick", function()
    local playerName = mailPlayerName:GetText()
    local subject = mailSubject:GetText()
    local text = mailText:GetText()
    if playerName == "" or subject == "" or text == "" then
        TrinityAdmin:Print(L["sendmail error"])
        return
    end
    local cmd = '.send mail ' .. playerName .. ' "' .. subject .. '" "' .. text .. '"'
    SendChatMessage(cmd, "SAY")
end)

-- Send Message Section
local msgPlayerName = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- msgPlayerName:SetSize(150, 22)
msgPlayerName:SetPoint("TOPLEFT", mailPlayerName, "BOTTOMLEFT", 0, -30)
msgPlayerName:SetAutoFocus(false)
msgPlayerName:SetText(L["Player Name"])
TrinityAdmin.AutoSize(msgPlayerName, 20, 13, nil, 150)

local msgText = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- msgText:SetSize(310, 22)
msgText:SetPoint("LEFT", msgPlayerName, "RIGHT", 10, 0)
msgText:SetAutoFocus(false)
msgText:SetText(L["PMessage"])
TrinityAdmin.AutoSize(msgText, 20, 13, nil, 310)

local btnSendMessage = CreateFrame("Button", nil, commandsFramePage8, "UIPanelButtonTemplate")
btnSendMessage:SetPoint("LEFT", msgText, "RIGHT", 10, 0)
btnSendMessage:SetText(L["Send Message"])
TrinityAdmin.AutoSize(btnSendMessage, 20, 16)
-- btnSendMessage:SetHeight(22)
-- btnSendMessage:SetWidth(btnSendMessage:GetTextWidth() + 20)
btnSendMessage:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Send Message tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnSendMessage:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnSendMessage:SetScript("OnClick", function()
    local playerName = msgPlayerName:GetText()
    local message = msgText:GetText()
    if playerName == "" or message == "" then
        TrinityAdmin:Print(L["sendmail error"])
        return
    end
    local cmd = '.send message ' .. playerName .. ' ' .. message
    SendChatMessage(cmd, "SAY")
end)

-- Send Money Section
local moneyPlayerName = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- moneyPlayerName:SetSize(120, 22)
moneyPlayerName:SetPoint("TOPLEFT", msgPlayerName, "BOTTOMLEFT", 0, -30)
moneyPlayerName:SetAutoFocus(false)
moneyPlayerName:SetText(L["Player Name"])
TrinityAdmin.AutoSize(moneyPlayerName, 20, 13, nil, 150)

local moneySubject = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- moneySubject:SetSize(120, 22)
moneySubject:SetPoint("LEFT", moneyPlayerName, "RIGHT", 10, 0)
moneySubject:SetAutoFocus(false)
moneySubject:SetText(L["Subject"])
TrinityAdmin.AutoSize(moneySubject, 20, 13, nil, 120)

local moneyText = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- moneyText:SetSize(120, 22)
moneyText:SetPoint("LEFT", moneySubject, "RIGHT", 10, 0)
moneyText:SetAutoFocus(false)
moneyText:SetText(L["Money_Text"])
TrinityAdmin.AutoSize(moneyText, 20, 13, nil, 120)

local moneyAmount = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- moneyAmount:SetSize(80, 22)
moneyAmount:SetPoint("LEFT", moneyText, "RIGHT", 10, 0)
moneyAmount:SetAutoFocus(false)
moneyAmount:SetText(L["V_Money"])
TrinityAdmin.AutoSize(moneyAmount, 20, 13, nil, 90)

local btnSendMoney = CreateFrame("Button", nil, commandsFramePage8, "UIPanelButtonTemplate")
btnSendMoney:SetPoint("LEFT", moneyAmount, "RIGHT", 10, 0)
btnSendMoney:SetText(L["Send Money"])
-- btnSendMoney:SetHeight(22)
TrinityAdmin.AutoSize(btnSendMoney, 20, 16)
-- btnSendMoney:SetWidth(btnSendMoney:GetTextWidth() + 20)
btnSendMoney:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Send Money tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnSendMoney:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnSendMoney:SetScript("OnClick", function()
    local playerName = moneyPlayerName:GetText()
    local subject = moneySubject:GetText()
    local text = moneyText:GetText()
    local money = moneyAmount:GetText()
    if playerName == "" or subject == "" or text == "" or money == "" then
        TrinityAdmin:Print(L["sendmail error"])
        return
    end
    local cmd = '.send money ' .. playerName .. ' "' .. subject .. '" "' .. text .. '" ' .. money
    SendChatMessage(cmd, "SAY")
end)

local convertSubtitle = commandsFramePage8:CreateFontString(nil, "OVERLAY", "GameFontNormal")
convertSubtitle:SetPoint("TOPLEFT", moneyPlayerName, "BOTTOMLEFT", 0, -20)
convertSubtitle:SetText(L["To copper converter"])
-- Champs Gold, Silver, Copper
local goldInput = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- goldInput:SetSize(80, 22)
goldInput:SetPoint("TOPLEFT", convertSubtitle, "BOTTOMLEFT", 0, -10)
goldInput:SetAutoFocus(false)
goldInput:SetText("Gold")
TrinityAdmin.AutoSize(goldInput, 20, 13, nil, 80)

local silverInput = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- silverInput:SetSize(80, 22)
silverInput:SetPoint("LEFT", goldInput, "RIGHT", 10, 0)
silverInput:SetAutoFocus(false)
silverInput:SetText("Silver")
TrinityAdmin.AutoSize(silverInput, 20, 13, nil, 80)

local copperInput = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- copperInput:SetSize(80, 22)
copperInput:SetPoint("LEFT", silverInput, "RIGHT", 10, 0)
copperInput:SetAutoFocus(false)
copperInput:SetText("Copper")
TrinityAdmin.AutoSize(copperInput, 20, 13, nil, 80)

-- Bouton Convert
local btnConvert = CreateFrame("Button", nil, commandsFramePage8, "UIPanelButtonTemplate")
btnConvert:SetPoint("LEFT", copperInput, "RIGHT", 10, 0)
btnConvert:SetText("Convert")
-- btnConvert:SetHeight(22)
-- btnConvert:SetWidth(btnConvert:GetTextWidth() + 20)
TrinityAdmin.AutoSize(btnConvert, 20, 16)

-- Champ résultat vide
local resultInput = CreateFrame("EditBox", nil, commandsFramePage8, "InputBoxTemplate")
-- resultInput:SetSize(100, 22)
resultInput:SetPoint("LEFT", btnConvert, "RIGHT", 10, 0)
resultInput:SetAutoFocus(false)
resultInput:SetText("Push Convert")
TrinityAdmin.AutoSize(resultInput, 20, 13, nil, 120)

-- Fonction de conversion
btnConvert:SetScript("OnClick", function()
    local gold = tonumber(goldInput:GetText()) or 0
    local silver = tonumber(silverInput:GetText()) or 0
    local copper = tonumber(copperInput:GetText()) or 0

    local totalCopper = (gold * 10000) + (silver * 100) + copper

    resultInput:SetText(totalCopper)
end)


-- ============================================================
-- 6) Frame caché : écoute CHAT_MSG_SYSTEM et stocke les messages
-- ============================================================
local captureFrame = CreateFrame("Frame")
captureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
captureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingPinfo then return end

    -- TrinityAdmin:Print("[DEBUG] Message CHAT_MSG_SYSTEM reçu : " .. msg)

    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
                       :gsub("|r", "")
                       :gsub("|H.-|h(.-)|h", "%1")
                       :gsub("|T.-|t", "")
                       :gsub("\226[\148-\149][\128-\191]", "")
    table.insert(collectedInfo, cleanMsg)
    -- TrinityAdmin:Print("[DEBUG] Ajouté à la capture : " .. cleanMsg)
    if captureTimer then captureTimer:Cancel() end
    captureTimer = C_Timer.NewTimer(1, FinishCapture)
end)

    ------------------------------------------------------------------------------
    -- Bouton Back final (commun aux pages)
    ------------------------------------------------------------------------------
    local btnBackFinal = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("CENTER", navPageLabel, "CENTER", 0, 20)
    btnBackFinal:SetText(L["Back"])
	TrinityAdmin.AutoSize(btnBackFinal, 20, 16)
    -- btnBackFinal:SetHeight(22)
    -- btnBackFinal:SetWidth(btnBackFinal:GetTextWidth() + 20)
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
