local NPCModule = TrinityAdmin:GetModule("NPCPanel")

function NPCModule:ShowNPCPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateNPCPanel()
    end
    self.panel:Show()
end

function NPCModule:CreateNPCPanel()
    local npc = CreateFrame("Frame", "TrinityAdminNPCPanel", TrinityAdminMainFrame)
    npc:ClearAllPoints()
    npc:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    npc:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = npc:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    npc.title = npc:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    npc.title:SetPoint("TOPLEFT", 10, -10)
    npc.title:SetText(TrinityAdmin_Translations["NPC_Panel"])

    -- Champ de saisie
    local inputBox = CreateFrame("EditBox", "NPCCommandInput", npc, "InputBoxTemplate")
    inputBox:SetSize(120, 22)
    inputBox:SetPoint("TOPLEFT", 10, -40)
    inputBox:SetAutoFocus(false)
    inputBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Menu déroulant
    local dropdown = CreateFrame("Frame", "NPCCommandDropdown", npc, "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", inputBox, "RIGHT", 10, 0)

    local commands = {
        { text = "npc add", command = ".npc add", tooltip = TrinityAdmin_Translations["NPC_Add_Tooltip"] },
        { text = "npc delete", command = ".npc delete", tooltip = TrinityAdmin_Translations["NPC_Delete_Tooltip"] },
        { text = "npc move", command = ".npc move", tooltip = TrinityAdmin_Translations["NPC_Move_Tooltip"] },
        { text = "npc info", command = ".npc info", tooltip = TrinityAdmin_Translations["NPC_Info_Tooltip"] },
        { text = "npc set model", command = ".npc set model", tooltip = TrinityAdmin_Translations["NPC_SetModel_Tooltip"] },
        { text = "npc set flag", command = ".npc set flag", tooltip = TrinityAdmin_Translations["NPC_SetFlag_Tooltip"] },
        { text = "npc set phase", command = ".npc set phase", tooltip = TrinityAdmin_Translations["NPC_SetPhase_Tooltip"] },
        { text = "npc set factionid", command = ".npc set factionid", tooltip = TrinityAdmin_Translations["NPC_SetFaction_Tooltip"] },
        { text = "npc set level", command = ".npc set level", tooltip = TrinityAdmin_Translations["NPC_SetLevel_Tooltip"] },
        { text = "npc delete item", command = ".npc delete item", tooltip = TrinityAdmin_Translations["NPC_DeleteItem_Tooltip"] },
        { text = "npc add formation", command = ".npc add formation", tooltip = TrinityAdmin_Translations["NPC_AddFormation_Tooltip"] },
        { text = "npc set entry", command = ".npc set entry", tooltip = TrinityAdmin_Translations["NPC_SetEntry_Tooltip"] },
        { text = "npc set link", command = ".npc set link", tooltip = TrinityAdmin_Translations["NPC_SetLink_Tooltip"] },
        { text = "npc say", command = ".npc say", tooltip = TrinityAdmin_Translations["NPC_Say_Tooltip"] },
        { text = "npc playemote", command = ".npc playemote", tooltip = TrinityAdmin_Translations["NPC_PlayEmote_Tooltip"] },
        { text = "npc follow", command = ".npc follow", tooltip = TrinityAdmin_Translations["NPC_Follow_Tooltip"] },
        { text = "npc follow stop", command = ".npc follow stop", tooltip = TrinityAdmin_Translations["NPC_FollowStop_Tooltip"] },
        { text = "npc set allowmove", command = ".npc set allowmove", tooltip = TrinityAdmin_Translations["NPC_SetAllowMove_Tooltip"] },
    }
    
    local selectedCommand = commands[1].command
    local selectedTooltip = commands[1].tooltip or "Aucun tooltip défini"

    -- Met à jour le tooltip sur le champ de saisie
    inputBox:SetScript("OnEnter", function()
        GameTooltip:SetOwner(inputBox, "ANCHOR_RIGHT")
        GameTooltip:SetText(selectedTooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    inputBox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Initialisation du menu déroulant
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local function OnClick(self)
		    -- MàJ du menu
            UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
			-- MàJ de la commande + tooltip
            selectedCommand = commands[self:GetID()].command
            selectedTooltip = commands[self:GetID()].tooltip or "Aucun tooltip défini"
			-- Si la souris est déjà sur inputBox, on rafraîchit le tooltip immédiatement
            if GameTooltip:IsOwned(inputBox) then
                GameTooltip:SetText(selectedTooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end
        for i, cmd in ipairs(commands) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = cmd.text
            info.value = cmd.command
            info.tooltipKey = cmd.tooltipKey
            info.func = OnClick
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetWidth(dropdown, 120)
    UIDropDownMenu_SetButtonWidth(dropdown, 140)
    UIDropDownMenu_SetSelectedID(dropdown, 1)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")

     -- Bouton Action
    local actionButton = CreateFrame("Button", nil, npc, "UIPanelButtonTemplate")
    actionButton:SetPoint("LEFT", dropdown, "RIGHT", 10, 0)
    actionButton:SetSize(80, 22)
    actionButton:SetText("Action")
    actionButton:SetScript("OnClick", function()
        local value = inputBox:GetText()
        if value and value ~= "" then
            SendChatMessage(selectedCommand .. " " .. value, "SAY")
        else
            print("Veuillez entrer une valeur pour la commande.")
        end
    end)

    -- Bouton Retour
    local btnBack = CreateFrame("Button", nil, npc, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", npc, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetSize(80, 22)
    btnBack:SetScript("OnClick", function()
        npc:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = npc
end