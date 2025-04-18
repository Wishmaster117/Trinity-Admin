local cheat = TrinityAdmin:GetModule("cheat")
local L = _G.L

-- Fonction pour afficher le panneau ServerAdmin
function cheat:ShowcheatPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreatecheatPanel()
    end
    self.panel:Show()
end
-- Fonction pour créer le panneau cheat
function cheat:CreatecheatPanel()
    local panel = CreateFrame("Frame", "TrinityAdmincheatPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre, modifiez selon vos besoins
    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(L["Cheats Panel"])  -- Vous pouvez utiliser L si nécessaire

local bg = panel:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(true)
bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
panel.title:SetPoint("TOPLEFT", 10, -10)
panel.title:SetText(L["Cheats Panel"])

-- local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
-- btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
-- btnBack:SetText(L and L["Back"] or "Back")
-- btnBack:SetSize(btnBack:GetTextWidth() + 20, 22)
-- btnBack:SetScript("OnClick", function()
--     panel:Hide()
--     TrinityAdmin:ShowMainMenu()
-- end)

-- Code à ajouter pour capturer les messages du chat et afficher une popup Ace3
local AceGUI = LibStub("AceGUI-3.0")
local chatMessages = {}

-- Hook du ChatFrame principal pour enregistrer les messages affichés
local originalAddMessage = ChatFrame1.AddMessage
ChatFrame1.AddMessage = function(self, text, ...)
    table.insert(chatMessages, text)
    return originalAddMessage(self, text, ...)
end

-- Fonction pour créer et afficher la fenêtre popup Ace3 avec le contenu du chat
local function ShowChatPopup()
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["Chat Output"])
    frame:SetLayout("Flow")
    frame:SetWidth(400)
    frame:SetHeight(300)
    
    local editBox = AceGUI:Create("MultiLineEditBox")
    editBox:SetLabel("")
    editBox:SetFullWidth(true)
    editBox:SetFullHeight(true)
    local text = table.concat(chatMessages, "\n")
    editBox:SetText(text)
    frame:AddChild(editBox)
    
    -- Réinitialisation des messages pour éviter l'accumulation
    chatMessages = {}
end

local yOffset = -40
local spacing = 30

-- 1. Bouton "Show Enables Cheats"
local btnShowCheats = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
btnShowCheats:SetPoint("TOPLEFT", 10, yOffset)
btnShowCheats:SetText(L["Show Enables Cheats"])
btnShowCheats:SetSize(btnShowCheats:GetTextWidth() + 20, 22)
btnShowCheats:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Shows the cheats you currently have enabled."], 1,1,1,1,true)
    GameTooltip:Show()
end)
btnShowCheats:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnShowCheats:SetScript("OnClick", function()
    chatMessages = {}  -- Vider le cache des messages avant envoi
    SendChatMessage(".cheat status", "SAY")
	-- Délai de 1 seconde pour laisser le temps au chat de s'actualiser avant d'afficher la popup
    C_Timer.After(1, function() ShowChatPopup() end)
end)
yOffset = yOffset - spacing

-- Fonction utilitaire pour créer une ligne avec 2 boutons radio et un bouton de commande
local function CreateRadioCommandRow(parent, y, rowLabel, tooltipText, commandPrefix)
    -- Positionnement direct des boutons radio sans libellé de ligne
    local radioOn = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    radioOn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y - 5)
    radioOn.text = radioOn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    radioOn.text:SetPoint("LEFT", radioOn, "RIGHT", 2, 0)
    radioOn.text:SetText("On")
    radioOn:SetChecked(false)
    
    local radioOff = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    radioOff:SetPoint("TOPLEFT", radioOn, "TOPRIGHT", 60, 0)
    radioOff.text = radioOff:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    radioOff.text:SetPoint("LEFT", radioOff, "RIGHT", 2, 0)
    radioOff.text:SetText("Off")
    radioOff:SetChecked(false)
    
    radioOn:SetScript("OnClick", function(self)
        if self:GetChecked() then
            radioOff:SetChecked(false)
        end
    end)
    radioOff:SetScript("OnClick", function(self)
        if self:GetChecked() then
            radioOn:SetChecked(false)
        end
    end)
    
    local cmdButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    cmdButton:SetPoint("TOPLEFT", radioOff, "TOPRIGHT", 40, -4)
    cmdButton:SetText(rowLabel)
    cmdButton:SetSize(cmdButton:GetTextWidth() + 20, 22)
    cmdButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    cmdButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    cmdButton:SetScript("OnClick", function()
        local value = nil
        if radioOn:GetChecked() then
            value = "on"
        elseif radioOff:GetChecked() then
            value = "off"
        else
            print(L["Select (On or Off) for "] .. rowLabel)
            return
        end
        local fullCommand = commandPrefix .. " " .. value
		chatMessages = {}  -- Vider le cache des messages avant envoi
        SendChatMessage(fullCommand, "SAY")
		-- Délai de 1 seconde pour laisser le temps au chat de s'actualiser avant d'afficher la popup
		C_Timer.After(1, function() ShowChatPopup() end)
    end)
    
    return y - spacing
end

-- 2. Bouton radio "Cheat Casttime"
yOffset = CreateRadioCommandRow(panel, yOffset, "Cheat Casttime", "Syntax: .cheat casttime [on/off]\nEnables or disables your character's spell cast times.", ".cheat casttime")

-- 3. Bouton radio "Cheat Cooldown"
yOffset = CreateRadioCommandRow(panel, yOffset, "Cheat Cooldown", "Syntax: .cheat cooldown [on/off]\nEnables or disables your character's spell cooldowns.", ".cheat cooldown")

-- 4. Bouton radio "Cheat God"
yOffset = CreateRadioCommandRow(panel, yOffset, "Cheat God", "Syntax: .cheat god [on/off]\nEnables or disables your character's ability to take damage.", ".cheat god")

-- 5. Bouton radio "Cheat Power"
yOffset = CreateRadioCommandRow(panel, yOffset, "Cheat Power", "Syntax: .cheat power [on/off]\nEnables or disables your character's spell cost (e.g. mana).", ".cheat power")

-- 6. Bouton radio "Cheat Taxi"
yOffset = CreateRadioCommandRow(panel, yOffset, "Cheat Taxi", "Syntax: .cheat taxi [on/off]\nTemporary grant access or remove to all taxi routes for the selected character.\nIf no character is selected, hide or reveal all routes (visited taxi nodes remain accessible after removal).", ".cheat taxi")

-- 7. Bouton radio "Cheat Waterwalk"
yOffset = CreateRadioCommandRow(panel, yOffset, "Cheat Waterwalk", "Syntax: .cheat waterwalk [on/off]\nSet on/off waterwalk state for selected player or self if no player selected.", ".cheat waterwalk")

-- 8. Cases à cocher pour "Cheat Explore"
local labelExplore = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
labelExplore:SetPoint("TOPLEFT", 10, yOffset)
yOffset = yOffset - 10

local checkboxHide = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
checkboxHide:SetPoint("TOPLEFT", 10, yOffset)
checkboxHide.text = checkboxHide:CreateFontString(nil, "OVERLAY", "GameFontNormal")
checkboxHide.text:SetPoint("LEFT", checkboxHide, "RIGHT", 2, 0)
checkboxHide.text:SetText("Hide")
checkboxHide:SetChecked(false)

local checkboxReveal = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
checkboxReveal:SetPoint("TOPLEFT", checkboxHide, "TOPRIGHT", 60, 0)
checkboxReveal.text = checkboxReveal:CreateFontString(nil, "OVERLAY", "GameFontNormal")
checkboxReveal.text:SetPoint("LEFT", checkboxReveal, "RIGHT", 2, 0)
checkboxReveal.text:SetText("Reveal")
checkboxReveal:SetChecked(false)

checkboxHide:SetScript("OnClick", function(self)
    if self:GetChecked() then
        checkboxReveal:SetChecked(false)
    end
end)
checkboxReveal:SetScript("OnClick", function(self)
    if self:GetChecked() then
        checkboxHide:SetChecked(false)
    end
end)

local btnExecute = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
btnExecute:SetPoint("TOPLEFT", checkboxReveal, "TOPRIGHT", 60, -4)
btnExecute:SetText("Execute")
btnExecute:SetSize(btnExecute:GetTextWidth() + 20, 22)
btnExecute:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Syntax: .cheat explore #flag\nReveal or hide all maps for the selected player. If no player is selected, hide or reveal maps to you.\nUse a #flag of value 1 to reveal, or 0 to hide all maps.", 1,1,1,1,true)
    GameTooltip:Show()
end)
btnExecute:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnExecute:SetScript("OnClick", function()
    local flag = nil
    if checkboxReveal:GetChecked() then
        flag = 1
    elseif checkboxHide:GetChecked() then
        flag = 0
    else
        print("Veuillez sélectionner Hide ou Reveal pour cheat explore.")
        return
    end
    local fullCommand = ".cheat explore " .. flag
    SendChatMessage(fullCommand, "SAY")
end)

    local btnBack = CreateFrame("Button", "TrinityAdminTeleportBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", 0, 10)
    btnBack:SetText(L["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)
    self.panel = panel
end
