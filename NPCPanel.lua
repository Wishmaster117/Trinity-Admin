if not UnitIsNPC then
    function UnitIsNPC(unit)
        return true
    end
end

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

    ----------------------------------------------------------------------------
    -- Partie supérieure fixe : champ de saisie principal, dropdown et bouton Action
    ----------------------------------------------------------------------------
    local inputBox = CreateFrame("EditBox", "NPCCommandInput", npc, "InputBoxTemplate")
    inputBox:SetSize(200, 22)
    inputBox:SetPoint("TOPLEFT", 10, -40)
    inputBox:SetAutoFocus(false)
    inputBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local dropdown = CreateFrame("Frame", "NPCCommandDropdown", npc, "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", inputBox, "RIGHT", 10, 0)

    local commands = {
        { text = "npc add", command = ".npc add", tooltip = TrinityAdmin_Translations["NPC_Add_Tooltip"], defaultText = "Enter Creature ID" },
        { text = "npc delete", command = ".npc delete", tooltip = TrinityAdmin_Translations["NPC_Delete_Tooltip"], defaultText = "Enter GUID" },
        { text = "npc move", command = ".npc move", tooltip = TrinityAdmin_Translations["NPC_Move_Tooltip"], defaultText = "Enter GUID" },
        { text = "npc info", command = ".npc info", tooltip = TrinityAdmin_Translations["NPC_Info_Tooltip"], defaultText = "Select a NPC" },
        { text = "npc set model", command = ".npc set model", tooltip = TrinityAdmin_Translations["NPC_SetModel_Tooltip"], defaultText = "Enter DisplayID" },
        { text = "npc set flag", command = ".npc set flag", tooltip = TrinityAdmin_Translations["NPC_SetFlag_Tooltip"], defaultText = "Enter Flag" },
        { text = "npc set phase", command = ".npc set phase", tooltip = TrinityAdmin_Translations["NPC_SetPhase_Tooltip"], defaultText = "Enter PhaseMask" },
        { text = "npc set factionid", command = ".npc set factionid", tooltip = TrinityAdmin_Translations["NPC_SetFaction_Tooltip"], defaultText = "Enter Faction ID" },
        { text = "npc set level", command = ".npc set level", tooltip = TrinityAdmin_Translations["NPC_SetLevel_Tooltip"], defaultText = "Enter Level Number" },
        { text = "npc delete item", command = ".npc delete item", tooltip = TrinityAdmin_Translations["NPC_DeleteItem_Tooltip"], defaultText = "Enter Item ID" },
        { text = "npc add formation", command = ".npc add formation", tooltip = TrinityAdmin_Translations["NPC_AddFormation_Tooltip"], defaultText = "Enter Leader" },
        { text = "npc set entry", command = ".npc set entry", tooltip = TrinityAdmin_Translations["NPC_SetEntry_Tooltip"], defaultText = "Enter New Entry" },
        { text = "npc set link", command = ".npc set link", tooltip = TrinityAdmin_Translations["NPC_SetLink_Tooltip"], defaultText = "Enter Creature GUID" },
        { text = "npc say", command = ".npc say", tooltip = TrinityAdmin_Translations["NPC_Say_Tooltip"], defaultText = "Enter Message" },
        { text = "npc playemote", command = ".npc playemote", tooltip = TrinityAdmin_Translations["NPC_PlayEmote_Tooltip"], defaultText = "Enter Emote ID" },
        { text = "npc follow", command = ".npc follow", tooltip = TrinityAdmin_Translations["NPC_Follow_Tooltip"], defaultText = "Select Someone" },
        { text = "npc follow stop", command = ".npc follow stop", tooltip = TrinityAdmin_Translations["NPC_FollowStop_Tooltip"], defaultText = "Select a NPC" },
        { text = "npc set allowmove", command = ".npc set allowmove", tooltip = TrinityAdmin_Translations["NPC_SetAllowMove_Tooltip"], defaultText = "Select a NPC" },
    }

    local selectedCommand = commands[1].command
    local selectedTooltip = commands[1].tooltip or "Aucun tooltip défini"
    local selectedDefaultText = commands[1].defaultText or ""
    inputBox:SetText(selectedDefaultText)
    inputBox:SetScript("OnEnter", function()
        GameTooltip:SetOwner(inputBox, "ANCHOR_RIGHT")
        GameTooltip:SetText(selectedTooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    inputBox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local function OnClick(self)
            UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
            selectedCommand = commands[self:GetID()].command
            selectedTooltip = commands[self:GetID()].tooltip or "Aucun tooltip défini"
            selectedDefaultText = commands[self:GetID()].defaultText or ""
            inputBox:SetText(selectedDefaultText)
            if GameTooltip:IsOwned(inputBox) then
                GameTooltip:SetText(selectedTooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end
        for i, cmd in ipairs(commands) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = cmd.text
            info.value = cmd.command
            info.func = OnClick
            info.tooltipTitle = cmd.text
            info.tooltipText = cmd.tooltip
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetWidth(dropdown, 120)
    UIDropDownMenu_SetButtonWidth(dropdown, 140)
    UIDropDownMenu_SetSelectedID(dropdown, 1)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")

    local actionButton = CreateFrame("Button", nil, npc, "UIPanelButtonTemplate")
    actionButton:SetPoint("LEFT", dropdown, "RIGHT", 10, 0)
    actionButton:SetSize(80, 22)
    actionButton:SetText("Action")
    actionButton:SetScript("OnClick", function()
        local value = inputBox:GetText()
        if value and value ~= "" and value ~= selectedDefaultText then
            SendChatMessage(selectedCommand .. " " .. value, "SAY")
            print("[DEBUG] Commande envoyée: " .. selectedCommand .. " " .. value)
        else
            if UnitExists("target") and UnitIsNPC("target") then
                local targetName = UnitName("target")
                SendChatMessage(selectedCommand .. " " .. targetName, "SAY")
                print("[DEBUG] Commande envoyée: " .. selectedCommand .. " " .. targetName)
            else
                print("Veuillez entrer une valeur pour la commande ou sélectionner un PNJ cible.")
                return
            end
        end
    end)

    ----------------------------------------------------------------------------
    -- Création d'un conteneur de contenu paginé
    ----------------------------------------------------------------------------
    local contentContainer = CreateFrame("Frame", nil, npc)
    contentContainer:SetPoint("TOPLEFT", inputBox, "BOTTOMLEFT", 0, -20)
    contentContainer:SetSize(600, 200)  -- zone de contenu pour les commandes

    local totalPages = 2
    local pages = {}
    for i = 1, totalPages do
        pages[i] = CreateFrame("Frame", nil, contentContainer)
        pages[i]:SetAllPoints(contentContainer)
        pages[i]:Hide()  -- on cache toutes les pages au départ
    end

    ----------------------------------------------------------------------------
    -- Préparation des données de commandes
    ----------------------------------------------------------------------------
    local fullCommands = {
        {
            name = "npc add item",
            command = ".npc add item",
            tooltip = "'Syntax: .npc add item #itemId <#maxcount><#incrtime><#extendedcost><#bonusListIDs>\r\nAdd item #itemid to item list of selected vendor. Also optionally set max count item in vendor item list and time to item count restoring and items ExtendedCost.\r\n#bonusListIDs is a semicolon separated list of bonuses to add to item (such as Mythic/Heroic/Warforged/socket))",
            fields = {
                { defaultText = "Item ID", width = 80 },
                { defaultText = "Max Count", width = 80 },
                { defaultText = "Wait Time", width = 80 },
                { defaultText = "Extendedcost", width = 100 },
                { defaultText = "Bonus List IDs", width = 120 },
            },
        },
        {
            name = "npc spawngroup",
            command = ".npc spawngroup",
            tooltip = "Syntax: .npc spawngroup $groupId [ignorerespawn] [force]",
            fields = {
                { defaultText = "GroupId", width = 100 },
                { defaultText = "Ignorerespawn", width = 120 },
                { defaultText = "Force", width = 80 },
            },
        },
    }

    local pairedCommands = {
        {
            name = "npc add move",
            command = ".npc add move",
            tooltip = "Syntax: .npc add move #creature_guid [#waittime]\r\n\r\nAdd your current location as a waypoint for creature with guid #creature_guid. And optional add wait time.",
            fields = {
                { defaultText = "Creature Guid", width = 120 },
                { defaultText = "Waittime", width = 100 },
            },
        },
        {
            name = "npc add temp",
            command = ".npc add temp",
            tooltip = "Syntax: .npc add temp [loot/noloot] #entry\nAdds temporary NPC, not saved to database.\n  Specify \'loot\' to have the NPC\'s corpse stick around for some time after death, allowing it to be looted.\n  Specify \'noloot\' to have the corpse disappear immediately.).",
            fields = {
                { defaultText = "[loot / noloot]", width = 120 },
                { defaultText = "Entry", width = 100 },
            },
        },
        {
            name = "npc despawngroup",
            command = ".npc despawngroup",
            tooltip = "Syntax: .npc despawngroup $groupId [removerespawntime]",
            fields = {
                { defaultText = "GroupId", width = 100 },
                { defaultText = "Remove Respawntime", width = 120 },
            },
        },
        {
            name = "npc evade",
            command = ".npc evade",
            tooltip = "Syntax: .npc evade [reason] [force]\nMakes the targeted NPC enter evade mode.\nDefaults to specifying EVADE_REASON_OTHER, override this by providing the reason string (ex.: .npc evade EVADE_REASON_BOUNDARY).\nSpecify \'force\' to clear any pre-existing evade state before evading - this may cause weirdness, use at your own risk.",
            fields = {
                { defaultText = "Reason", width = 100 },
                { defaultText = "Force", width = 100 },
            },
        },
        {
            name = "npc set data",
            command = ".npc set data",
            tooltip = "Syntax: .npc set data $field $data\nSets data for the selected creature. Used for testing Scripting.",
            fields = {
                { defaultText = "Field", width = 120 },
                { defaultText = "Data", width = 120 },
            },
        },
        {
            name = "npc set movetype",
            command = ".npc set movetype",
            tooltip = "Syntax: .npc set movetype [#creature_guid] stay/random/way [NODEL]\r\n\r\nSet for creature pointed by #creature_guid (or selected if #creature_guid not provided) movement type and move it to respawn position (if creature alive). Any existing waypoints for creature will be removed from the database if you do not use NODEL. If the creature is dead then movement type will applied at creature respawn.\r\nMake sure you use NODEL, if you want to keep the waypoints.",
            fields = {
                { defaultText = "Creature Guid", width = 100 },
                { defaultText = "Movement type (opt.)", width = 120 },
            },
        },
        {
            name = "npc set spawntime",
            command = ".npc set spawntime",
            tooltip = "Syntax: .npc set spawntime #time \r\n\r\nAdjust spawntime of selected creature to time.",
            fields = {
                { defaultText = "Time", width = 120 },
            },
        },
        {
            name = "npc set wanderdistance",
            command = ".npc set wanderdistance",
            tooltip = "Syntax: .npc set wanderdistance #dist\r\n\r\nAdjust wander distance of selected creature to dist.",
            fields = {
                { defaultText = "Distance", width = 120 },
            },
        },
        {
            name = "npc textemote",
            command = ".npc textemote",
            tooltip = "Syntax: .npc textemote #emoteid\r\n\r\nMake the selected creature to do textemote with an emote of id #emoteid.",
            fields = {
                { defaultText = "Emote ID", width = 120 },
            },
        },
        {
            name = "npc whisper",
            command = ".npc whisper",
            tooltip = "Syntax: .npc whisper #playerguid #text\r\nMake the selected npc whisper #text to  #playerguid.",
            fields = {
                { defaultText = "Player Guid", width = 120 },
                { defaultText = "Text", width = 140 },
            },
        },
        {
            name = "npc yell",
            command = ".npc yell",
            tooltip = "Syntax: .npc yell $message\nMake selected creature yell specified message.",
            fields = {
                { defaultText = "Message", width = 200 },
            },
        },
		{
            name = "npc showloot",
            command = ".npc showloot",
            tooltip = "Syntax: .npc showloot [all]\n\nShows the loot contained in targeted dead creature.",
            fields = {
                { defaultText = "all", width = 200 },
            },
        },
    }

    local pairedCommandsFiltered = {}
    local singleInputCommands = {}
    for i, cmd in ipairs(pairedCommands) do
        if #cmd.fields == 1 and (cmd.command == ".npc set spawntime" or cmd.command == ".npc set wanderdistance" or cmd.command == ".npc textemote" or cmd.command == ".npc yell" or cmd.command == ".npc showloot") then
            table.insert(singleInputCommands, cmd)
        else
            table.insert(pairedCommandsFiltered, cmd)
        end
    end

    ----------------------------------------------------------------------------
    -- Remplissage de la page 1
    ----------------------------------------------------------------------------
    local page1 = pages[1]
    local yOffset = 0

    -- Affichage des commandes full
    for i, cmd in ipairs(fullCommands) do
        local blockFrame = CreateFrame("Frame", nil, page1)
        blockFrame:SetPoint("TOPLEFT", page1, "TOPLEFT", 0, -yOffset)
        blockFrame:SetSize(600, 40)
        local title = blockFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", blockFrame, "TOPLEFT", 0, 0)
        title:SetText(cmd.name)
        title:SetTextColor(1, 1, 0, 1)
        local fieldXOffset = 0
        local fieldInputs = {}
        for j, field in ipairs(cmd.fields) do
            local editBox = CreateFrame("EditBox", nil, blockFrame, "InputBoxTemplate")
            editBox:SetSize(field.width, 22)
            editBox:SetPoint("TOPLEFT", blockFrame, "TOPLEFT", fieldXOffset, -20)
            editBox:SetAutoFocus(false)
            editBox:SetText(field.defaultText)
            fieldInputs[j] = editBox
            fieldXOffset = fieldXOffset + field.width + 10
        end
        local sendButton = CreateFrame("Button", nil, blockFrame, "UIPanelButtonTemplate")
        sendButton:SetSize(60, 22)
        sendButton:SetPoint("TOPLEFT", blockFrame, "TOPLEFT", fieldXOffset, -20)
        sendButton:SetText("Send")
        sendButton:SetScript("OnClick", function()
            local args = {}
            for j, editBox in ipairs(fieldInputs) do
                table.insert(args, editBox:GetText())
            end
            local fullCommand = cmd.command .. " " .. table.concat(args, " ")
            SendChatMessage(fullCommand, "SAY")
            print("[DEBUG] Commande envoyée: " .. fullCommand)
        end)
        sendButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(cmd.tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        sendButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

        yOffset = yOffset + 50
    end

    ----------------------------------------------------------------------------
    -- Affichage de la première moitié des commandes par paire sur la page 1
    ----------------------------------------------------------------------------
    local totalPaired = #pairedCommandsFiltered
    local half = math.ceil(totalPaired / 2)
    local pairIndex = 1  -- Déclaration locale de pairIndex
    while pairIndex <= half do
        local rowFrame = CreateFrame("Frame", nil, page1)
        rowFrame:SetPoint("TOPLEFT", page1, "TOPLEFT", 0, -yOffset)
        rowFrame:SetSize(600, 40)

        -- Commande 1
        local cmd1 = pairedCommandsFiltered[pairIndex]
        local block1 = CreateFrame("Frame", nil, rowFrame)
        block1:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 0, 0)
        block1:SetSize(280, 40)
        local title1 = block1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title1:SetPoint("TOPLEFT", block1, "TOPLEFT", 0, 0)
        title1:SetText(cmd1.name)
        title1:SetTextColor(1, 1, 0, 1)
        local fieldXOffset1 = 0
        local fieldInputs1 = {}
        for j, field in ipairs(cmd1.fields) do
            local editBox = CreateFrame("EditBox", nil, block1, "InputBoxTemplate")
            editBox:SetSize(field.width, 22)
            editBox:SetPoint("TOPLEFT", block1, "TOPLEFT", fieldXOffset1, -20)
            editBox:SetAutoFocus(false)
            editBox:SetText(field.defaultText)
            fieldInputs1[j] = editBox
            fieldXOffset1 = fieldXOffset1 + field.width + 5
        end
        local sendButton1 = CreateFrame("Button", nil, block1, "UIPanelButtonTemplate")
        sendButton1:SetSize(60, 22)
        sendButton1:SetPoint("TOPLEFT", block1, "TOPLEFT", fieldXOffset1, -20)
        sendButton1:SetText("Send")
        sendButton1:SetScript("OnClick", function()
            local args = {}
            for j, editBox in ipairs(fieldInputs1) do
                table.insert(args, editBox:GetText())
            end
            local fullCommand = cmd1.command .. " " .. table.concat(args, " ")
            SendChatMessage(fullCommand, "SAY")
            print("[DEBUG] Commande envoyée: " .. fullCommand)
        end)
        sendButton1:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(cmd1.tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        sendButton1:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Commande 2, si présente
        if pairIndex + 1 <= half then
            local cmd2 = pairedCommandsFiltered[pairIndex + 1]
            local block2 = CreateFrame("Frame", nil, rowFrame)
            block2:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 300, 0)
            block2:SetSize(280, 40)
            local title2 = block2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            title2:SetPoint("TOPLEFT", block2, "TOPLEFT", 0, 0)
            title2:SetText(cmd2.name)
            title2:SetTextColor(1, 1, 0, 1)
            local fieldXOffset2 = 0
            local fieldInputs2 = {}
            for j, field in ipairs(cmd2.fields) do
                local editBox = CreateFrame("EditBox", nil, block2, "InputBoxTemplate")
                editBox:SetSize(field.width, 22)
                editBox:SetPoint("TOPLEFT", block2, "TOPLEFT", fieldXOffset2, -20)
                editBox:SetAutoFocus(false)
                editBox:SetText(field.defaultText)
                fieldInputs2[j] = editBox
                fieldXOffset2 = fieldXOffset2 + field.width + 5
            end
            local sendButton2 = CreateFrame("Button", nil, block2, "UIPanelButtonTemplate")
            sendButton2:SetSize(60, 22)
            sendButton2:SetPoint("TOPLEFT", block2, "TOPLEFT", fieldXOffset2, -20)
            sendButton2:SetText("Send")
            sendButton2:SetScript("OnClick", function()
                local args = {}
                for j, editBox in ipairs(fieldInputs2) do
                    table.insert(args, editBox:GetText())
                end
                local fullCommand = cmd2.command .. " " .. table.concat(args, " ")
                SendChatMessage(fullCommand, "SAY")
                print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
            sendButton2:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(cmd2.tooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            sendButton2:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end

        yOffset = yOffset + 50
        pairIndex = pairIndex + 2
    end

    ----------------------------------------------------------------------------
    -- Remplissage de la page 2
    ----------------------------------------------------------------------------
    local page2 = pages[2]
    yOffset = 0
    local totalPairedFiltered = #pairedCommandsFiltered
    local startIndex = math.floor(totalPairedFiltered / 2) + 1
    local pairIndex2 = startIndex
    while pairIndex2 <= totalPairedFiltered do
        local rowFrame = CreateFrame("Frame", nil, page2)
        rowFrame:SetPoint("TOPLEFT", page2, "TOPLEFT", 0, -yOffset)
        rowFrame:SetSize(600, 40)
        -- Commande 1
        local cmd1 = pairedCommandsFiltered[pairIndex2]
        local block1 = CreateFrame("Frame", nil, rowFrame)
        block1:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 0, 0)
        block1:SetSize(280, 40)
        local title1 = block1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title1:SetPoint("TOPLEFT", block1, "TOPLEFT", 0, 0)
        title1:SetText(cmd1.name)
        title1:SetTextColor(1, 1, 0, 1)
        local fieldXOffset1 = 0
        local fieldInputs1 = {}
        for j, field in ipairs(cmd1.fields) do
            local editBox = CreateFrame("EditBox", nil, block1, "InputBoxTemplate")
            editBox:SetSize(field.width, 22)
            editBox:SetPoint("TOPLEFT", block1, "TOPLEFT", fieldXOffset1, -20)
            editBox:SetAutoFocus(false)
            editBox:SetText(field.defaultText)
            fieldInputs1[j] = editBox
            fieldXOffset1 = fieldXOffset1 + field.width + 5
        end
        local sendButton1 = CreateFrame("Button", nil, block1, "UIPanelButtonTemplate")
        sendButton1:SetSize(60, 22)
        sendButton1:SetPoint("TOPLEFT", block1, "TOPLEFT", fieldXOffset1, -20)
        sendButton1:SetText("Send")
        sendButton1:SetScript("OnClick", function()
            local args = {}
            for j, editBox in ipairs(fieldInputs1) do
                table.insert(args, editBox:GetText())
            end
            local fullCommand = cmd1.command .. " " .. table.concat(args, " ")
            SendChatMessage(fullCommand, "SAY")
            print("[DEBUG] Commande envoyée: " .. fullCommand)
        end)
        sendButton1:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(cmd1.tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        sendButton1:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        if pairIndex2 + 1 <= totalPairedFiltered then
            local cmd2 = pairedCommandsFiltered[pairIndex2 + 1]
            local block2 = CreateFrame("Frame", nil, rowFrame)
            block2:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 300, 0)
            block2:SetSize(280, 40)
            local title2 = block2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            title2:SetPoint("TOPLEFT", block2, "TOPLEFT", 0, 0)
            title2:SetText(cmd2.name)
            title2:SetTextColor(1, 1, 0, 1)
            local fieldXOffset2 = 0
            local fieldInputs2 = {}
            for j, field in ipairs(cmd2.fields) do
                local editBox = CreateFrame("EditBox", nil, block2, "InputBoxTemplate")
                editBox:SetSize(field.width, 22)
                editBox:SetPoint("TOPLEFT", block2, "TOPLEFT", fieldXOffset2, -20)
                editBox:SetAutoFocus(false)
                editBox:SetText(field.defaultText)
                fieldInputs2[j] = editBox
                fieldXOffset2 = fieldXOffset2 + field.width + 5
            end
            local sendButton2 = CreateFrame("Button", nil, block2, "UIPanelButtonTemplate")
            sendButton2:SetSize(60, 22)
            sendButton2:SetPoint("TOPLEFT", block2, "TOPLEFT", fieldXOffset2, -20)
            sendButton2:SetText("Send")
            sendButton2:SetScript("OnClick", function()
                local args = {}
                for j, editBox in ipairs(fieldInputs2) do
                    table.insert(args, editBox:GetText())
                end
                local fullCommand = cmd2.command .. " " .. table.concat(args, " ")
                SendChatMessage(fullCommand, "SAY")
                print("[DEBUG] Commande envoyée: " .. fullCommand)
            end)
            sendButton2:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(cmd2.tooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            sendButton2:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end

        yOffset = yOffset + 50
        pairIndex2 = pairIndex2 + 2
    end

    ----------------------------------------------------------------------------
    -- Insertion du panneau Single Input dans la page 2
    ----------------------------------------------------------------------------
    local singleFrame = CreateFrame("Frame", nil, page2)
    singleFrame:SetPoint("TOPLEFT", page2, "TOPLEFT", 0, -yOffset)
    singleFrame:SetSize(600, 40)

    local singleEditBox = CreateFrame("EditBox", nil, singleFrame, "InputBoxTemplate")
    singleEditBox:SetSize(singleInputCommands[1].fields[1].width, 22)
    singleEditBox:SetPoint("LEFT", singleFrame, "LEFT", 0, 0)
    singleEditBox:SetAutoFocus(false)
    singleEditBox:SetText(singleInputCommands[1].fields[1].defaultText)

    local singleDropdown = CreateFrame("Frame", nil, singleFrame, "TrinityAdminDropdownTemplate")
    singleDropdown:SetPoint("LEFT", singleEditBox, "RIGHT", 10, 0)
    UIDropDownMenu_SetText(singleDropdown, singleInputCommands[1].name)

UIDropDownMenu_Initialize(singleDropdown, function(self, level, menuList)
    for i, cmd in ipairs(singleInputCommands) do
        local info = UIDropDownMenu_CreateInfo()
        info.text  = cmd.name
        info.value = i
        -- Définir si l'option est cochée (petit bouton jaune)
        info.checked = (UIDropDownMenu_GetSelectedID(singleDropdown) == i)

        info.func = function(button, arg1, arg2, checked)
            -- Met à jour l'ID sélectionné et le texte du dropdown
            UIDropDownMenu_SetSelectedID(singleDropdown, i)
            UIDropDownMenu_SetText(singleDropdown, cmd.name)

            -- Met à jour la commande sélectionnée
            singleFrame.selectedCommand = singleInputCommands[i]
            singleEditBox:SetText(cmd.fields[1].defaultText or "")
        end

        UIDropDownMenu_AddButton(info, level)
    end
end)



    local singleSendButton = CreateFrame("Button", nil, singleFrame, "UIPanelButtonTemplate")
    singleSendButton:SetSize(60, 22)
    singleSendButton:SetPoint("LEFT", singleDropdown, "RIGHT", 10, 0)
    singleSendButton:SetText("Send")
    singleSendButton:SetScript("OnClick", function()
        local value = singleEditBox:GetText()
        if not value or value == "" or value == "Enter Value" then
            print("Veuillez entrer une valeur valide.")
            return
        end
        local cmd = singleFrame.selectedCommand or singleInputCommands[1]
        local fullCommand = cmd.command .. " " .. value
        SendChatMessage(fullCommand, "SAY")
        print("[DEBUG] Commande envoyée: " .. fullCommand)
    end)
    singleSendButton:SetScript("OnEnter", function(self)
        local cmd = singleFrame.selectedCommand or singleInputCommands[1]
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(cmd.tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    singleSendButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ----------------------------------------------------------------------------
    -- Bouton Retour commun
    ----------------------------------------------------------------------------
    local btnBack = CreateFrame("Button", "TrinityAdminNPCBackButton", npc, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", npc, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetSize(80, 22)
    btnBack:SetScript("OnClick", function()
        npc:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    ----------------------------------------------------------------------------
    -- Boutons de navigation pour la pagination (affichés en bas du panneau)
    ----------------------------------------------------------------------------
    local currentPage = 1
    local navPageLabel = npc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    navPageLabel:SetPoint("BOTTOM", npc, "BOTTOM", 0, 12)
    navPageLabel:SetText("Page 1 / " .. totalPages)

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

    local btnPrev = CreateFrame("Button", nil, npc, "UIPanelButtonTemplate")
    btnPrev:SetSize(80, 22)
    btnPrev:SetText("Précédent")
    btnPrev:SetPoint("BOTTOMLEFT", npc, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            ShowPage(currentPage)
        end
    end)

    local btnNext = CreateFrame("Button", nil, npc, "UIPanelButtonTemplate")
    btnNext:SetSize(80, 22)
    btnNext:SetText("Suivant")
    btnNext:SetPoint("BOTTOMRIGHT", npc, "BOTTOMRIGHT", -10, 10)
    btnNext:SetScript("OnClick", function()
        if currentPage < totalPages then
            currentPage = currentPage + 1
            ShowPage(currentPage)
        end
    end)

    ShowPage(1)

    self.panel = npc
end
