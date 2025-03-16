local module = TrinityAdmin:GetModule("GMFunctionsPanel")

-- Table listant tous les boutons, dans l'ordre où vous voulez les créer
local buttonDefs = {
    {
        name = "btnFly",
        textON = "GM Fly ON",       -- Pour le toggle
        textOFF = "GM Fly OFF",     -- idem
        tooltip = "Active ou désactive la possibilité de voler en GM",
        commandON = ".gm fly on",
        commandOFF = ".gm fly off",
        isToggle = true,
        anchorTo = "TOPLEFT",       -- Ancre relative
        anchorOffsetX = 10,
        anchorOffsetY = -50,
        linkTo = nil,              -- pas de bouton précédent
        stateVar = "gmFlyOn",      -- variable de module pour l'état ON/OFF
    },
    {
        name = "btnGmOn",
        textON = "GM ON",
        textOFF = "GM OFF",
        tooltip = "Active ou désactive le mode GM",
        commandON = ".gm on",
        commandOFF = ".gm off",
        isToggle = true,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnFly",         -- on va s’ancrer à droite de btnFly
        stateVar = "gmOn",
    },
    {
        name = "btnGmChat",
        textON = "GM Chat ON",
        textOFF = "GM Chat OFF",
        tooltip = "Active ou désactive le chat GM",
        commandON = ".gm chat on",
        commandOFF = ".gm chat off",
        isToggle = true,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnGmOn",
        stateVar = "gmChatOn",
    },
    {
        name = "btnGmIngame",
        text = "GM Ingame",
        tooltip = "Active le mode GM ingame (sans toggle).",
        command = ".gm ingame",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnGmChat",
    },
    {
        name = "btnGmList",
        text = "GM List",
        tooltip = "Affiche la liste des GMs en jeu.",
        command = ".gm list",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnGmIngame",
    },
    {
        name = "btnGmVisible",
        textON = "GM Visible ON",
        textOFF = "GM Visible OFF",
        tooltip = "Active ou désactive la visibilité GM.",
        commandON = ".gm visible on",
        commandOFF = ".gm visible off",
        isToggle = true,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnGmList",
        stateVar = "gmVisible",
    },
    {
        name = "btnAppear",
        text = "Appear",
        tooltip = "Se téléporte au joueur ciblé.",
        command = ".appear",
        isToggle = false,
        anchorTo = "TOPLEFT",
        anchorOffsetX = 0,
        anchorOffsetY = -20,
        linkTo = "btnFly", -- ancré sous btnFly
    },
    {
        name = "btnRevive",
        text = "Revive",
        tooltip = "Ressuscite le personnage.",
        command = ".revive",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnAppear",
    },
    {
        name = "btnDie",
        text = "Die",
        tooltip = "Fait mourir instantanément le personnage.",
        command = ".die",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnRevive",
    },
    {
        name = "btnSave",
        text = "Save",
        tooltip = "Sauvegarde votre personnage.",
        command = ".save",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnDie",
    },
    {
        name = "btnSaveAll",
        text = "Save All",
        tooltip = "Sauvegarde tous les personnages.",
        command = ".saveall",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnSave",
    },
    {
        name = "btnRespawn",
        text = "Respawn",
        tooltip = "Respawn toutes les créatures mortes autour.",
        command = ".respawn",
        isToggle = false,
        anchorTo = "LEFT",
        anchorOffsetX = 10,
        anchorOffsetY = 0,
        linkTo = "btnSaveAll",
    },
}

-- Petite fonction utilitaire pour fixer le tooltip
local function SetTooltipScripts(btn, tooltipText)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltipText or "", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- Fonction pour créer un bouton à partir de la définition
local function CreateGMButton(panel, def, module, buttonRefs)
    local btn = CreateFrame("Button", def.name, panel, "UIPanelButtonTemplate")
    
    -- On récupère le bouton référence "linkTo"
    local anchorRelative = panel
    local anchorPoint    = def.anchorTo or "TOPLEFT"
    local relativePoint  = def.anchorTo
    if def.linkTo and buttonRefs[def.linkTo] then
        anchorRelative = buttonRefs[def.linkTo]
        relativePoint  = "RIGHT"
    end

    btn:SetPoint(anchorPoint, anchorRelative, relativePoint, def.anchorOffsetX, def.anchorOffsetY)
    
    -- Gère le texte selon toggle ou pas
    if def.isToggle and def.stateVar then
        local state = module[def.stateVar]
        if state then
            btn:SetText(def.textON)
        else
            btn:SetText(def.textOFF)
        end
    else
        btn:SetText(def.text)
    end
    
    btn:SetHeight(22)
    btn:SetWidth(btn:GetTextWidth() + 20)
    
    -- Script OnClick
    if def.isToggle and def.stateVar then
        btn:SetScript("OnClick", function()
            if module[def.stateVar] then
                -- OFF
                SendChatMessage(def.commandOFF, "SAY")
                btn:SetText(def.textOFF)
                module[def.stateVar] = false
            else
                -- ON
                SendChatMessage(def.commandON, "SAY")
                btn:SetText(def.textON)
                module[def.stateVar] = true
            end
        end)
    else
        -- Pas un toggle
        btn:SetScript("OnClick", function()
            SendChatMessage(def.command, "SAY")
        end)
    end
    
    -- Tooltip
    SetTooltipScripts(btn, def.tooltip)
    
    -- On stocke ce bouton dans un tableau de références
    buttonRefs[def.name] = btn
end

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
    panel.title:SetText(TrinityAdmin_Translations["GM Functions Panel"] or "GM Functions Panel")

    -- Tableau pour stocker les références de nos boutons
    local buttonRefs = {}

    -- Création de tous les boutons à partir de la table buttonDefs
    for _, def in ipairs(buttonDefs) do
        CreateGMButton(panel, def, self, buttonRefs)
    end

    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"] or "Back")
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
