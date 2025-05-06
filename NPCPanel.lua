-- Vérifie qu'une fonction UnitIsNPC n'existe pas déjà, sinon la crée
if not UnitIsNPC then
    function UnitIsNPC(unit)
        return true
    end
end

local NPCModule = TrinityAdmin:GetModule("NPCPanel")
local L = _G.L

-- -------------------------------------------------------------------------
-- 1) ShowNPCPanel : Ouvre le panneau
-- -------------------------------------------------------------------------
function NPCModule:ShowNPCPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateNPCPanel()
    end
    self.panel:Show()
end

-- -------------------------------------------------------------------------
-- 2) Variables de capture pour .npc info
-- -------------------------------------------------------------------------
local capturingNPCInfo = false
local npcInfoCollected = {}
local npcInfoTimer = nil

-- Capture for .npc showloot
local capturingShowLoot = false
local showLootCollected = {}
local showLootTimer = nil

------------------------------------------
-- Affiche le résultat de ".npc showloot"
------------------------------------------
local function ShowShowLootAceGUI(lines)
    local AceGUI = LibStub("AceGUI-3.0")
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["NPC Loot Info"])
    frame:SetStatusText(L["Information from .npc showloot"])
    frame:SetLayout("Flow")
    frame:SetWidth(600)
    frame:SetHeight(500)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    frame:AddChild(scroll)

    -- Chaque ligne => un EditBox (ou un Label, ou MultiLineEditBox, etc.)
    for i, line in ipairs(lines) do
        local edit = AceGUI:Create("EditBox")
        edit:SetLabel("Line " .. i)
        edit:SetText(line)
        edit:SetFullWidth(true)
        scroll:AddChild(edit)
    end

    local btnClose = AceGUI:Create("Button")
    btnClose:SetText("Fermer")
    btnClose:SetWidth(100)
    btnClose:SetCallback("OnClick", function()
        AceGUI:Release(frame)
    end)
    frame:AddChild(btnClose)
end


local npcInfoCaptureFrame = CreateFrame("Frame")
npcInfoCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
npcInfoCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingNPCInfo and not capturingShowLoot then
        return
    end

    -- Nettoyage minimal
    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
                       :gsub("|r", "")
                       :gsub("|H.-|h(.-)|h", "%1")
                       :gsub("|T.-|t", "")
                       :gsub("\226[\148-\149][\128-\191]", "")

    ----------------------------------------
    -- Si on est en mode capturingNPCInfo :
    ----------------------------------------
    if capturingNPCInfo then
        table.insert(npcInfoCollected, cleanMsg)
        if npcInfoTimer then npcInfoTimer:Cancel() end

        npcInfoTimer = C_Timer.NewTimer(1, function()
            capturingNPCInfo = false
            local fullText = table.concat(npcInfoCollected, "\n")
            local lines = {}
            for line in fullText:gmatch("[^\r\n]+") do
                -- Exclure "NPC currently selected..." si besoin
                if not line:match("^NPC currently selected by player:") then
                    table.insert(lines, line)
                end
            end
            ShowNPCInfoAceGUI(lines)
        end)
    end

    ----------------------------------------
    -- Si on est en mode capturingShowLoot :
    ----------------------------------------
    if capturingShowLoot then
        table.insert(showLootCollected, cleanMsg)
        if showLootTimer then showLootTimer:Cancel() end

        showLootTimer = C_Timer.NewTimer(1, function()
            capturingShowLoot = false
            local fullText = table.concat(showLootCollected, "\n")

            -- Ici on split en lignes
            local lines = {}
            for line in fullText:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end

            -- Puis on ouvre la popup Ace3 :
            ShowShowLootAceGUI(lines)
        end)
    end
end)

-- -------------------------------------------------------------------------
-- 3) Fonction qui traite le texte complet pour séparer la ligne Flags/PersonalGuid
-- -------------------------------------------------------------------------
local function ProcessCapturedText(input)
    local text = (type(input) == "table") and table.concat(input, "\n") or input

    local processedLines = {}
    local startCapture = false  -- Flag qui sera activé dès que l'on rencontre "Name:"

    for line in text:gmatch("[^\r\n]+") do
        -- On active la capture seulement si la ligne commence par "Name:"
        if not startCapture then
            if line:find("^Name:") then
                startCapture = true
            end
        end

        if startCapture then
            -- Si la ligne commence par "*" et contient "PersonalGuid:", on la découpe en deux
            if line:find("^%*") and line:find("PersonalGuid:") then
                local part1, part2 = line:match("^(%*%s*Flags%s*%S+),%s*(PersonalGuid:%s*.+)")
                if part1 and part2 then
                    table.insert(processedLines, part1)
                    table.insert(processedLines, part2)
                else
                    table.insert(processedLines, line)
                end

            -- Séparation "PhaseID: ... , PhaseGroup: ..."
            elseif line:find("PhaseID:") and line:find("PhaseGroup:") then
                local p1, p2 = line:match("^(PhaseID:%s*[^,]+),%s*(PhaseGroup:%s*.+)")
                if p1 and p2 then
                    table.insert(processedLines, p1)
                    table.insert(processedLines, p2)
                else
                    table.insert(processedLines, line)
                end

            -- Séparation "Template StringID:" et "Spawn StringID:"
            elseif line:find("Template StringID:") and line:find("Spawn StringID:") then
                local part1, part2 = line:match("^(Template StringID:%s*.-)%s+(Spawn StringID:%s*.+)")
                if part1 and part2 then
                    table.insert(processedLines, part1)
                    table.insert(processedLines, part2)
                else
                    table.insert(processedLines, line)
                end

            else
                table.insert(processedLines, line)
            end
        end
    end
    return processedLines
end

-- -------------------------------------------------------------------------
-- 4) AceGUI pour afficher les infos PNJ
-- -------------------------------------------------------------------------
local AceGUI = LibStub("AceGUI-3.0")
function ShowNPCInfoAceGUI(fullText)
    local lines = ProcessCapturedText(fullText)

    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["NPC Info Frame"])
    frame:SetStatusText(L["Information from npc info"])
    frame:SetLayout("Flow")
    frame:SetWidth(600)
    frame:SetHeight(500)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    frame:AddChild(scroll)

    for i, line in ipairs(lines) do
        local labelText = line:match("^(.-):") or ("Line " .. i)
        local valueText = line:match("^[^:]+:%s*(.+)") or line

        local edit = AceGUI:Create("EditBox")
        edit:SetLabel("|cffffff00" .. labelText .. ":|r")
        edit:SetText(valueText)
        edit:SetFullWidth(true)
        scroll:AddChild(edit)
    end

    local btnClose = AceGUI:Create("Button")
    btnClose:SetText(L["close_frame"])
    btnClose:SetWidth(100)
    btnClose:SetCallback("OnClick", function()
        AceGUI:Release(frame)
    end)
    frame:AddChild(btnClose)
end

-- -------------------------------------------------------------------------
-- 5) Creation du panneau NPC sur 3 pages
-- -------------------------------------------------------------------------
function NPCModule:CreateNPCPanel()
    local npc = CreateFrame("Frame", "TrinityAdminNPCPanel", TrinityAdminMainFrame)
    npc:ClearAllPoints()
    npc:SetPoint("TOPLEFT",  TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    npc:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = npc:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    npc.title = npc:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    npc.title:SetPoint("TOPLEFT", 10, -10)
    npc.title:SetText(L["NPC_Panel"])

    -- Bouton Retour (en bas)
    local btnBack = CreateFrame("Button", nil, npc, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", npc, "BOTTOM", 0, 10)
    btnBack:SetText(L["Back"])
    btnBack:SetSize(btnBack:GetTextWidth() + 20, 22)
    btnBack:SetScript("OnClick", function()
        npc:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    -- Conteneur principal pour la pagination
    local contentContainer = CreateFrame("Frame", nil, npc)
    contentContainer:SetPoint("TOPLEFT", npc, "TOPLEFT", 10, -80)
    contentContainer:SetSize(600, 300)

    local totalPages = 3
    local pages = {}
    for i = 1, totalPages do
        pages[i] = CreateFrame("Frame", nil, contentContainer)
        pages[i]:SetAllPoints(contentContainer)
        pages[i]:Hide()
        pages[i].yOffset = 0
    end

    -- Boutons de navigation
    local navPageLabel = npc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    navPageLabel:SetPoint("BOTTOM", npc, "BOTTOM", 0, 40)
    navPageLabel:SetText("Page 1 / " .. totalPages)

    local currentPage = 1
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
    btnPrev:SetText(L["Preview"])
    btnPrev:SetPoint("BOTTOMLEFT", npc, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            ShowPage(currentPage)
        end
    end)

    local btnNext = CreateFrame("Button", nil, npc, "UIPanelButtonTemplate")
    btnNext:SetSize(80, 22)
    btnNext:SetText(L["Next"])
    btnNext:SetPoint("BOTTOMRIGHT", npc, "BOTTOMRIGHT", -10, 10)
    btnNext:SetScript("OnClick", function()
        if currentPage < totalPages then
            currentPage = currentPage + 1
            ShowPage(currentPage)
        end
    end)

    -------------------------------------------------------------------------
    -- Données de base
    -------------------------------------------------------------------------
    local commands = {
        { text = "npc add",            command = ".npc add",            tooltip = L["NPC_Add_Tooltip"],        defaultText = L["Enter Creature ID"] },
        { text = "npc delete",         command = ".npc delete",         tooltip = L["NPC_Delete_Tooltip"],     defaultText = L["Enter GUID"] },
        { text = "npc move",           command = ".npc move",           tooltip = L["NPC_Move_Tooltip"],       defaultText = L["Enter GUID"] },
        { text = "npc info",           command = ".npc info",           tooltip = L["NPC_Info_Tooltip"],       defaultText = L["Select a NPC"] },
        { text = "npc set model",      command = ".npc set model",      tooltip = L["NPC_SetModel_Tooltip"],   defaultText = L["Enter DisplayID"] },
        { text = "npc set flag",       command = ".npc set flag",       tooltip = L["NPC_SetFlag_Tooltip"],    defaultText = L["Enter Flag"] },
        { text = "npc set phase",      command = ".npc set phase",      tooltip = L["NPC_SetPhase_Tooltip"],   defaultText = L["Enter PhaseMask"] },
        { text = "npc set factionid",  command = ".npc set factionid",  tooltip = L["NPC_SetFaction_Tooltip"], defaultText = L["Enter Faction ID"] },
        { text = "npc set level",      command = ".npc set level",      tooltip = L["NPC_SetLevel_Tooltip"],   defaultText = L["Enter Level Number"] },
        { text = "npc delete item",    command = ".npc delete item",    tooltip = L["NPC_DeleteItem_Tooltip"], defaultText = L["Enter Item ID"] },
        { text = "npc add formation",  command = ".npc add formation",  tooltip = L["NPC_AddFormation_Tooltip"], defaultText = L["Enter Leader"] },
        { text = "npc set entry",      command = ".npc set entry",      tooltip = L["NPC_SetEntry_Tooltip"],   defaultText = L["Enter New Entry"] },
        { text = "npc set link",       command = ".npc set link",       tooltip = L["NPC_SetLink_Tooltip"],    defaultText = L["Enter Creature GUID"] },
        { text = "npc say",            command = ".npc say",            tooltip = L["NPC_Say_Tooltip"],        defaultText = L["Enter Message"] },
        { text = "npc playemote",      command = ".npc playemote",      tooltip = L["NPC_PlayEmote_Tooltip"],  defaultText = L["Enter Emote ID"] },
        { text = "npc follow",         command = ".npc follow",         tooltip = L["NPC_Follow_Tooltip"],     defaultText = L["Select Someone"] },
        { text = "npc follow stop",    command = ".npc follow stop",    tooltip = L["NPC_FollowStop_Tooltip"], defaultText = L["Select a NPC"] },
        { text = "npc set allowmove",  command = ".npc set allowmove",  tooltip = L["NPC_SetAllowMove_Tooltip"], defaultText = L["Select a NPC"] },
    }

    local fullCommands = {
        {
            name = "npc add item",
            command = ".npc add item",
            tooltip = L["npc add item tooltip"],
            fields = {
                { defaultText = "Item ID",         width = 80 },
                { defaultText = "Max Count",       width = 80 },
                { defaultText = "Wait Time",       width = 80 },
                { defaultText = "Extendedcost",    width = 100 },
                { defaultText = "Bonus List IDs",  width = 120 },
            },
        },
        {
            name = "npc spawngroup",
            command = ".npc spawngroup",
            tooltip = L["npc spawngroup tooltip"],
            fields = {
                { defaultText = "GroupId",        width = 100 },
                { defaultText = "Ignorerespawn",  width = 120 },
                { defaultText = "Force",          width = 80 },
            },
        },
    }

    local pairedCommands = {
        {
            name = "npc add move",
            command = ".npc add move",
            tooltip = L["npc add move tooltip"],
            fields = {
                { defaultText = "Creature Guid", width = 120 },
                { defaultText = "Waittime",      width = 100 },
            },
        },
        {
            name = "npc add temp",
            command = ".npc add temp",
            tooltip = L["npc add temp tooltip"],
            fields = {
                { defaultText = "[loot / noloot]", width = 120 },
                { defaultText = "Entry",           width = 100 },
            },
        },
        {
            name = "npc despawngroup",
            command = ".npc despawngroup",
            tooltip = L["npc add despawngroup tooltip"],
            fields = {
                { defaultText = "GroupId",            width = 100 },
                { defaultText = "Remove Respawntime", width = 120 },
            },
        },
        {
            name = "npc evade",
            command = ".npc evade",
            tooltip = L["npc evade tooltip"],
            fields = {
                { defaultText = "Reason", width = 100 },
                { defaultText = "Force",  width = 100 },
            },
        },
        {
            name = "npc set data",
            command = ".npc set data",
            tooltip = L["npc set data tooltip"],
            fields = {
                { defaultText = "Field", width = 120 },
                { defaultText = "Data",  width = 120 },
            },
        },
        {
            name = "npc set movetype",
            command = ".npc set movetype",
            tooltip = L["npc set movetype tooltip"],
            fields = {
                { defaultText = "Creature Guid",        width = 100 },
                { defaultText = "Movement type (opt.)", width = 120 },
            },
        },
        {
            name = "npc set spawntime",
            command = ".npc set spawntime",
            tooltip = L["npc set spawntime tooltip"],
            fields = {
                { defaultText = "Time", width = 120 },
            },
        },
        {
            name = "npc set wanderdistance",
            command = ".npc set wanderdistance",
            tooltip = L["npc set wanderdistance tooltip"],
            fields = {
                { defaultText = "Distance", width = 120 },
            },
        },
        {
            name = "npc textemote",
            command = ".npc textemote",
            tooltip = L["npc textemote tooltip"],
            fields = {
                { defaultText = "Emote ID", width = 120 },
            },
        },
        {
            name = "npc whisper",
            command = ".npc whisper",
            tooltip = L["npc whisper tooltip"],
            fields = {
                { defaultText = "Player Guid", width = 120 },
                { defaultText = "Text",        width = 140 },
            },
        },
        {
            name = "npc yell",
            command = ".npc yell",
            tooltip = L["npc yell tooltip"],
            fields = {
                { defaultText = "Message", width = 200 },
            },
        },
        {
            name = "npc showloot",
            command = ".npc showloot",
            tooltip = L["npc showloot tooltip"],
            fields = {
                { defaultText = "all", width = 200 },
            },
        },
    }

    -- Sépare "pairedCommands" en "pairedCommandsFiltered" et "singleInputCommands"
    local pairedCommandsFiltered = {}
    local singleInputCommands = {}
    for _, cmd in ipairs(pairedCommands) do
        if #cmd.fields == 1 and (
            cmd.command == ".npc set spawntime" or
            cmd.command == ".npc set wanderdistance" or
            cmd.command == ".npc textemote" or
            cmd.command == ".npc yell" or
            cmd.command == ".npc showloot"
        ) then
            table.insert(singleInputCommands, cmd)
        else
            table.insert(pairedCommandsFiltered, cmd)
        end
    end

    ----------------------------------------------------------------------------
    -- PAGE 1 : "header" (inputBox, dropdown, actionButton) + fullCommands
    ----------------------------------------------------------------------------
    local page1 = pages[1]

    -- On place inputBox, dropdown, actionButton DANS page1
    local inputBox = CreateFrame("EditBox", "NPCCommandInput", page1, "InputBoxTemplate")
    inputBox:SetSize(200, 22)
    inputBox:SetPoint("TOPLEFT", 10, -10)
    inputBox:SetAutoFocus(false)
    inputBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local dropdown = CreateFrame("Frame", "NPCCommandDropdown", page1, "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", inputBox, "RIGHT", 10, 0)

    -- On recopie le tableau 'commands' localement
    local selectedCommand = commands[1].command
    local selectedTooltip = commands[1].tooltip or "No tooltip"
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
        local function OnClick(frameBtn)
            UIDropDownMenu_SetSelectedID(dropdown, frameBtn:GetID())
            local idx = frameBtn:GetID()
            selectedCommand = commands[idx].command
            selectedTooltip = commands[idx].tooltip or "No tooltip"
            selectedDefaultText = commands[idx].defaultText or ""
            inputBox:SetText(selectedDefaultText)

            if GameTooltip:IsOwned(inputBox) then
                GameTooltip:SetText(selectedTooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end

        for i, cmd in ipairs(commands) do
            local info = UIDropDownMenu_CreateInfo()
            info.text  = cmd.text
            info.value = cmd.command
            info.func  = OnClick
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    UIDropDownMenu_SetWidth(dropdown, 120)
    UIDropDownMenu_SetButtonWidth(dropdown, 140)
    UIDropDownMenu_SetSelectedID(dropdown, 1)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")

    local actionButton = CreateFrame("Button", nil, page1, "UIPanelButtonTemplate")
    actionButton:SetPoint("LEFT", dropdown, "RIGHT", 10, 0)
    actionButton:SetSize(80, 22)
    actionButton:SetText(L["Action"])
    actionButton:SetScript("OnClick", function()
        if selectedCommand == ".npc info" then
            if not (UnitExists("target") and UnitIsNPC("target")) then
                print(L["Select a NPC"])
                return
            end
            npcInfoCollected = {}
            capturingNPCInfo = true
            if npcInfoTimer then npcInfoTimer:Cancel() end
            npcInfoTimer = C_Timer.NewTimer(1, function()
                capturingNPCInfo = false
                local fullText = table.concat(npcInfoCollected, "\n")
                local lines = {}
                for line in fullText:gmatch("[^\r\n]+") do
                    table.insert(lines, line)
                end
                ShowNPCInfoAceGUI(lines)
            end)
        end

        local value = inputBox:GetText()
        if value and value ~= "" and value ~= selectedDefaultText then
            SendChatMessage(selectedCommand .. " " .. value, "SAY")
            -- print("[DEBUG] Commande envoyée 1: " .. selectedCommand .. " " .. value)
        else
            if UnitExists("target") and UnitIsNPC("target") then
                -- pas de param => juste .npc ...
                SendChatMessage(selectedCommand, "SAY")
            else
                print(L["Please_enter_npc_vanue"])
            end
        end
    end)

    -- On place "fullCommands" en dessous
    local yOffset = 50

    for _, cmd in ipairs(fullCommands) do
        local blockFrame = CreateFrame("Frame", nil, page1)
        blockFrame:SetPoint("TOPLEFT", page1, "TOPLEFT", 0, -yOffset)
        blockFrame:SetSize(600, 40)

        local title = blockFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", blockFrame, "TOPLEFT", 0, 0)
        title:SetText(cmd.name)
        title:SetTextColor(1, 1, 0, 1)

        local fieldXOffset = 0
        local fieldInputs = {}

        for _, field in ipairs(cmd.fields) do
            local editBox = CreateFrame("EditBox", nil, blockFrame, "InputBoxTemplate")
            editBox:SetSize(field.width, 22)
            editBox:SetPoint("TOPLEFT", blockFrame, "TOPLEFT", fieldXOffset, -20)
            editBox:SetAutoFocus(false)
            editBox:SetText(field.defaultText)
            table.insert(fieldInputs, editBox)
            fieldXOffset = fieldXOffset + field.width + 10
        end

        local sendButton = CreateFrame("Button", nil, blockFrame, "UIPanelButtonTemplate")
        sendButton:SetSize(60, 22)
        sendButton:SetPoint("TOPLEFT", blockFrame, "TOPLEFT", fieldXOffset, -20)
        sendButton:SetText(L["Send"])
        sendButton:SetScript("OnClick", function()
            local args = {}
            for _, eb in ipairs(fieldInputs) do
                table.insert(args, eb:GetText())
            end
            local fullCommand = cmd.command .. " " .. table.concat(args, " ")
            SendChatMessage(fullCommand, "SAY")
            -- print("[DEBUG] Commande envoyée 2: " .. fullCommand)
        end)
        sendButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(cmd.tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        sendButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        yOffset = yOffset + 50
    end

    -------------------------------------------------------------------------
    -- PAGE 2 : première moitié de pairedCommandsFiltered
    -------------------------------------------------------------------------
    local page2 = pages[2]
    local yOffset2 = 0

    local totalPaired = #pairedCommandsFiltered
    local half = math.ceil(totalPaired / 2)
    local pairIndex = 1

    while pairIndex <= half do
        local cmd1 = pairedCommandsFiltered[pairIndex]
        if cmd1 then
            local rowFrame = CreateFrame("Frame", nil, page2)
            rowFrame:SetPoint("TOPLEFT", page2, "TOPLEFT", 0, -yOffset2)
            rowFrame:SetSize(600, 40)

            local title1 = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            title1:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 0, 0)
            title1:SetText(cmd1.name)
            title1:SetTextColor(1, 1, 0, 1)

            local fieldXOffset1 = 0
            local fieldInputs1 = {}
            for _, field in ipairs(cmd1.fields) do
                local eb = CreateFrame("EditBox", nil, rowFrame, "InputBoxTemplate")
                eb:SetSize(field.width, 22)
                eb:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", fieldXOffset1, -20)
                eb:SetAutoFocus(false)
                eb:SetText(field.defaultText)
                table.insert(fieldInputs1, eb)
                fieldXOffset1 = fieldXOffset1 + field.width + 5
            end

            local sendButton1 = CreateFrame("Button", nil, rowFrame, "UIPanelButtonTemplate")
            sendButton1:SetSize(60, 22)
            sendButton1:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", fieldXOffset1, -20)
            sendButton1:SetText(L["Send"])
            sendButton1:SetScript("OnClick", function()
                local args = {}
                for _, eb in ipairs(fieldInputs1) do
                    table.insert(args, eb:GetText())
                end
                local fullCommand = cmd1.command .. " " .. table.concat(args, " ")
                SendChatMessage(fullCommand, "SAY")
                -- print("[DEBUG] Commande envoyée 3: " .. fullCommand)
            end)
            sendButton1:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(cmd1.tooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            sendButton1:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            yOffset2 = yOffset2 + 50
        end

        pairIndex = pairIndex + 1
    end

    -------------------------------------------------------------------------
    -- PAGE 3 : seconde moitié + singleInputCommands
    -------------------------------------------------------------------------
    local page3 = pages[3]
    local yOffset3 = 0

    -- Seconde moitié
    local pairIndex2 = half + 1
    while pairIndex2 <= totalPaired do
        local cmdData = pairedCommandsFiltered[pairIndex2]
        if cmdData then
            local rowFrame = CreateFrame("Frame", nil, page3)
            rowFrame:SetPoint("TOPLEFT", page3, "TOPLEFT", 0, -yOffset3)
            rowFrame:SetSize(600, 40)

            local title = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            title:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 0, 0)
            title:SetText(cmdData.name)
            title:SetTextColor(1, 1, 0, 1)

            local fieldXOffset = 0
            local fieldInputs = {}
            for _, field in ipairs(cmdData.fields) do
                local eb = CreateFrame("EditBox", nil, rowFrame, "InputBoxTemplate")
                eb:SetSize(field.width, 22)
                eb:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", fieldXOffset, -20)
                eb:SetAutoFocus(false)
                eb:SetText(field.defaultText)
                table.insert(fieldInputs, eb)
                fieldXOffset = fieldXOffset + field.width + 5
            end

            local sendButton = CreateFrame("Button", nil, rowFrame, "UIPanelButtonTemplate")
            sendButton:SetSize(60, 22)
            sendButton:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", fieldXOffset, -20)
            sendButton:SetText(L["Send"])
            sendButton:SetScript("OnClick", function()
                local args = {}
                for _, eb in ipairs(fieldInputs) do
                    table.insert(args, eb:GetText())
                end
                local fullCommand = cmdData.command .. " " .. table.concat(args, " ")
                SendChatMessage(fullCommand, "SAY")
                -- print("[DEBUG] Commande envoyée 4: " .. fullCommand)
            end)

            sendButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(cmdData.tooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            sendButton:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            yOffset3 = yOffset3 + 50
        end

        pairIndex2 = pairIndex2 + 1
    end

    -- Single Input
    if #singleInputCommands > 0 then
        local singleFrame = CreateFrame("Frame", nil, page3)
        singleFrame:SetPoint("TOPLEFT", page3, "TOPLEFT", 0, -yOffset3)
        singleFrame:SetSize(600, 40)
        yOffset3 = yOffset3 + 45

        local defaultCmd = singleInputCommands[1]
        local singleEditBox = CreateFrame("EditBox", nil, singleFrame, "InputBoxTemplate")
        singleEditBox:SetSize(defaultCmd.fields[1].width, 22)
        singleEditBox:SetPoint("LEFT", singleFrame, "LEFT", 0, 0)
        singleEditBox:SetAutoFocus(false)
        singleEditBox:SetText(defaultCmd.fields[1].defaultText)

        local singleDropdown = CreateFrame("Frame", nil, singleFrame, "TrinityAdminDropdownTemplate")
        singleDropdown:SetPoint("LEFT", singleEditBox, "RIGHT", 10, 0)
        UIDropDownMenu_SetText(singleDropdown, defaultCmd.name)

        UIDropDownMenu_Initialize(singleDropdown, function(self, level, menuList)
            for i, ccmd in ipairs(singleInputCommands) do
                local info = UIDropDownMenu_CreateInfo()
                info.text    = ccmd.name
                info.value   = i
                info.checked = (UIDropDownMenu_GetSelectedID(singleDropdown) == i)

                info.func = function(button)
                    UIDropDownMenu_SetSelectedID(singleDropdown, i)
                    UIDropDownMenu_SetText(singleDropdown, ccmd.name)
                    singleFrame.selectedCommand = ccmd
                    singleEditBox:SetText(ccmd.fields[1].defaultText or "")
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)

        local singleSendButton = CreateFrame("Button", nil, singleFrame, "UIPanelButtonTemplate")
        singleSendButton:SetSize(60, 22)
        singleSendButton:SetPoint("LEFT", singleDropdown, "RIGHT", 10, 0)
        singleSendButton:SetText(L["Send"])

        singleSendButton:SetScript("OnClick", function()
            local ccmd = singleFrame.selectedCommand or singleInputCommands[1]
            local value = singleEditBox:GetText()
            if not value or value == "" or value == "Enter Value" then
                print(L["pleaseentervalidvalue"])
                return
            end
            local fullCommand = ccmd.command .. " " .. value
			    -- (1) ICI on place le test
    if ccmd.command == ".npc showloot" then
        capturingShowLoot = true
        wipe(showLootCollected)
    end
            SendChatMessage(fullCommand, "SAY")
            -- print("[DEBUG] Commande envoyée5: " .. fullCommand)
        end)

        singleSendButton:SetScript("OnEnter", function(self)
            local ccmd = singleFrame.selectedCommand or singleInputCommands[1]
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(ccmd.tooltip or "No tooltip", 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        singleSendButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    ShowPage(1)
    self.panel = npc
end
