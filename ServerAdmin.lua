--------------------------------------------------------------
-- ServerAdmin Module (ServerAdmin.lua)
--------------------------------------------------------------

local ServerAdmin = TrinityAdmin:GetModule("ServerAdmin")
local L = _G.L

-- Variables de capture pour .server info
local capturingServerInfo = false
local serverInfoCollected = {}
local serverInfoTimer = nil

-- 1) Fonction de parsing
local function ParseServerInfo(fullText)
    local lines = {}
    for line in fullText:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local versionCore = ""
    local onlinePlayers, onlinePlayersMax = "", ""
    local activeConnections, activeConnectionsMax = "", ""
    local queuedConnections, queuedConnectionsMax = "", ""
    local serverUptime = ""
    local updateTimeDiff = ""

    for _, line in ipairs(lines) do
        line = line:match("^%s*(.-)%s*$")  -- trim

        if line:find("TrinityCore rev") then
            versionCore = line
        end

        local online = line:match("Online players:%s*(%d+)")
        local onlineMax = line:match("Online players:%s*%d+ %(%s*max:%s*(%d+)%)")
        if online then
            onlinePlayers = online
            if onlineMax then
                onlinePlayersMax = onlineMax
            end
        end

        local act = line:match("Active connections:%s*(%d+)")
        local actMax = line:match("Active connections:%s*%d+ %(%s*max:%s*(%d+)%)")
        if act then
            activeConnections = act
            if actMax then
                activeConnectionsMax = actMax
            end
        end
        local queue = line:match("Queued connections:%s*(%d+)")
        local queueMax = line:match("Queued connections:%s*%d+ %(%s*max:%s*(%d+)%)")
        if queue then
            queuedConnections = queue
            if queueMax then
                queuedConnectionsMax = queueMax
            end
        end

        local uptime = line:match("Server uptime:%s*(.+)")
        if uptime then
            serverUptime = uptime
        end

        local utd = line:match("Update time diff:%s*(%d+)")
        if utd then
            updateTimeDiff = utd
        end
    end

    local infoTable = {}
    table.insert(infoTable, { label="Version du core",    value=versionCore })
    table.insert(infoTable, { label="Online Players",     value=onlinePlayers.." (max: "..(onlinePlayersMax or "")..")" })
    table.insert(infoTable, { label="Active Connections", value=activeConnections.." (max: "..(activeConnectionsMax or "")..")" })
    table.insert(infoTable, { label="Queued Connections", value=queuedConnections.." (max: "..(queuedConnectionsMax or "")..")" })
    table.insert(infoTable, { label="Server Uptime",      value=serverUptime })
    table.insert(infoTable, { label="Update time diff",   value=updateTimeDiff })

    return infoTable
end

-- 2) ShowServerInfoAceGUI : crée la fenêtre AceGUI et y place des EditBox
local AceGUI = LibStub("AceGUI-3.0")
local function ShowServerInfoAceGUI(fullText)
    local infoTable = ParseServerInfo(fullText)

    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Server Info")
    frame:SetStatusText("Server informations")
    frame:SetLayout("Flow")
    frame:SetWidth(500)
    frame:SetHeight(400)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    frame:AddChild(scroll)

    local function AddEditBox(lbl, val)
        local edit = AceGUI:Create("EditBox")
        edit:SetLabel("|cffffff00" .. lbl .. "|r")
        edit:SetText(val or "")
        edit:SetFullWidth(true)
        scroll:AddChild(edit)
    end

    for _, row in ipairs(infoTable) do
        AddEditBox(row.label, row.value)
    end

    local btnClose = AceGUI:Create("Button")
    btnClose:SetText("Fermer")
    btnClose:SetWidth(80)
    btnClose:SetCallback("OnClick", function() frame:Hide() end)
    frame:AddChild(btnClose)
end

-- 3) Frame de capture : écoute CHAT_MSG_SYSTEM
local serverInfoCaptureFrame = CreateFrame("Frame")
serverInfoCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
serverInfoCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingServerInfo then return end

    local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
                        :gsub("|r", "")
                        :gsub("|H.-|h(.-)|h", "%1")
                        :gsub("|T.-|t", "")
                        :gsub("\226[\148-\149][\128-\191]", "")

    table.insert(serverInfoCollected, cleanMsg)
    if serverInfoTimer then serverInfoTimer:Cancel() end
    serverInfoTimer = C_Timer.NewTimer(1, function()
        capturingServerInfo = false
        local fullText = table.concat(serverInfoCollected, "\n")
        ShowServerInfoAceGUI(fullText)
    end)
end)

-- 4) ShowServerAdminPanel / CreateServerAdminPanel
function ServerAdmin:ShowServerAdminPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateServerAdminPanel()
    end
    self.panel:Show()
end

function ServerAdmin:CreateServerAdminPanel()
    local panel = CreateFrame("Frame", "TrinityAdminServerAdminPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Server Admin Panel")

    -------------------------------------------------------------------------------
    -- Création de plusieurs pages
    -------------------------------------------------------------------------------
    local totalPages = 2
    local pages = {}
    for i = 1, totalPages do
        pages[i] = CreateFrame("Frame", nil, panel)
        pages[i]:SetAllPoints(panel)
        pages[i]:Hide()
    end

    local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
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

    ShowPage(1)

    -------------------------------------------------------------------------------
    -- PAGE 1
    -------------------------------------------------------------------------------
    local commandsFramePage1 = CreateFrame("Frame", nil, pages[1])
    commandsFramePage1:SetPoint("TOPLEFT", pages[1], "TOPLEFT", 20, -40)
    commandsFramePage1:SetSize(500, 350)

    local page1Title = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    page1Title:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, 0)
    page1Title:SetText("Page 1")

    local currentY1 = -20
    local function NextPosition1(height)
        local pos = currentY1
        currentY1 = currentY1 - height - 5
        return pos
    end
	
    local function CreateServerButtonPage1(name, text, tooltip, cmd)
        local btn = CreateFrame("Button", name, commandsFramePage1, "UIPanelButtonTemplate")
        btn:SetSize(150, 22)
        btn:SetText(text)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        btn:SetScript("OnClick", function(self)
            SendChatMessage(cmd, "SAY")
            print("Commande envoyée: " .. cmd)
        end)
        return btn
    end
	
    -- Ajout des boutons sur la page 1
    local btnServerCorpses = CreateServerButtonPage1("ServerCorpsesButton", "server corpses", "Syntax: .server corpses\r\nTrigger corpses expire check.", ".server corpses")
    btnServerCorpses:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, NextPosition1(22))

    local btnServerDebug = CreateServerButtonPage1("ServerDebugButton", "server debug", "Syntax: .server debug\nShows detailed server info.", ".server debug")
    btnServerDebug:SetPoint("TOPLEFT", btnServerCorpses, "TOPRIGHT", 10, 0)

     local btnServerMotd = CreateServerButtonPage1("ServerMotdButton", "server motd", "Syntax: .server motd\r\nShow server Message of the day.", ".server motd")
    btnServerMotd:SetPoint("TOPLEFT", btnServerDebug, "TOPRIGHT", 10, 0)

    -- Bouton server info => active la capture
    local btnServerInfo = CreateFrame("Button", "ServerInfoButton", panel, "UIPanelButtonTemplate")
    btnServerInfo:SetSize(150, 22)
    btnServerInfo:SetText("server info")
    btnServerInfo:SetPoint("TOPLEFT", btnServerMotd, "TOPRIGHT", 10, 0)
    btnServerInfo:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .server info\r\nDisplay server version and connected players.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnServerInfo:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btnServerInfo:SetScript("OnClick", function()
        capturingServerInfo = true
        serverInfoCollected = {}
        if serverInfoTimer then serverInfoTimer:Cancel() end
        serverInfoTimer = C_Timer.NewTimer(1, function()
            capturingServerInfo = false
            local fullText = table.concat(serverInfoCollected, "\n")
            ShowServerInfoAceGUI(fullText)
        end)
        SendChatMessage(".server info", "SAY")
        print("Commande envoyée: .server info")
    end)

    local btnServerIdleRestart = CreateFrame("Button", "ServerIdleRestartButton", commandsFramePage1, "UIPanelButtonTemplate")
    btnServerIdleRestart:SetSize(150, 22)
    btnServerIdleRestart:SetText("server idlerestart")
    btnServerIdleRestart:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .server idlerestart #delay [#exit_code] [reason]\nRestart after delay if no players are connected. Use exit code 2.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnServerIdleRestart:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    btnServerIdleRestart:SetPoint("TOPRIGHT", btnServerCorpses, "BOTTOMRIGHT", 0, -10)

    local idlerestartDelay = CreateFrame("EditBox", "IdlerestartDelayBox", commandsFramePage1, "InputBoxTemplate")
    idlerestartDelay:SetSize(80, 22)
    idlerestartDelay:SetText("Delay in s")
    idlerestartDelay:SetPoint("TOPRIGHT", btnServerIdleRestart, "TOPRIGHT", 90, 0)

    local idlerestartReason = CreateFrame("EditBox", "IdlerestartReasonBox", commandsFramePage1, "InputBoxTemplate")
    idlerestartReason:SetSize(120, 22)
    idlerestartReason:SetText("Reason")
    idlerestartReason:SetPoint("TOPRIGHT", idlerestartDelay, "TOPRIGHT", 130, 0)

    btnServerIdleRestart:SetScript("OnClick", function(self)
        local delay = idlerestartDelay:GetText()
        local reason = idlerestartReason:GetText()
        local cmd = ".server idlerestart " .. delay .. " 2 " .. reason
        SendChatMessage(cmd, "SAY")
        print("Commande envoyée: " .. cmd)
    end)

    local btnserveridlerestartcancel = CreateServerButtonPage1("ServerIdleRestartCancelButton", "idlerestart cancel", "Syntax: .server idlerestart cancel\r\n\r\nCancel the restart/shutdown timer if any.", ".server idlerestart cancel")
    btnserveridlerestartcancel:SetPoint("TOPLEFT", btnServerIdleRestart, "TOPRIGHT", 230, 0)
    
	local btnServerIdleShutdown = CreateServerButtonPage1("ServerIdleShutdownButton", "server idleshutdown", "Syntax: .server idleshutdown #delay [#exit_code] [reason]\nShut down after delay if no players are connected. Use exit code 0.", ".server idleshutdown")
    btnServerIdleShutdown:SetPoint("TOPLEFT", btnServerIdleRestart, "BOTTOMLEFT", 0, -10)

    local idleshutdownDelay = CreateFrame("EditBox", "IdleshutdownDelayBox", commandsFramePage1, "InputBoxTemplate")
    idleshutdownDelay:SetSize(80, 22)
    idleshutdownDelay:SetText("Delay in s")
    idleshutdownDelay:SetPoint("TOPRIGHT", btnServerIdleShutdown, "TOPRIGHT", 90, 0)

    local idleshutdownReason = CreateFrame("EditBox", "IdleshutdownReasonBox", commandsFramePage1, "InputBoxTemplate")
    idleshutdownReason:SetSize(120, 22)
    idleshutdownReason:SetText("Reason")
    idleshutdownReason:SetPoint("TOPRIGHT", idleshutdownDelay, "TOPRIGHT", 130, 0)

    btnServerIdleShutdown:SetScript("OnClick", function(self)
        local delay = idleshutdownDelay:GetText()
        local reason = idleshutdownReason:GetText()
        local cmd = ".server idleshutdown " .. delay .. " 0 " .. reason
        SendChatMessage(cmd, "SAY")
        print("Commande envoyée: " .. cmd)
    end)
	
    local btnServerIdleShutdownCancel = CreateServerButtonPage1("ServerIdleShutdownCancelButton", "idleshutdown cancel", "Syntax: .server idleshutdown cancel\r\nCancel the shutdown timer.", ".server idleshutdown cancel")
    btnServerIdleShutdownCancel:SetPoint("TOPLEFT", idleshutdownReason, "TOPRIGHT", 10, 0)
	
	-------------------------------------------------------------------------------
	-- Server Restart Button
	-------------------------------------------------------------------------------
	local btnServerRestart = CreateServerButtonPage1("ServerRestartButton", "Server Restart", "Syntax: .server restart [force] #delay [#exit_code] [reason]\n\nRestart the server after #delay seconds. Use #exit_code or 2 as program exit code. Specify \'force\' to allow short-term shutdown despite other players being connected.", ".server restart")
    btnServerRestart:SetPoint("TOPLEFT", btnServerIdleShutdown, "BOTTOMLEFT", 0, -10)

    local ServerRestartDelay = CreateFrame("EditBox", "ServerRestartDelayBox", commandsFramePage1, "InputBoxTemplate")
    ServerRestartDelay:SetSize(80, 22)
    ServerRestartDelay:SetText("Delay in s")
    ServerRestartDelay:SetPoint("TOPRIGHT", btnServerRestart, "TOPRIGHT", 90, 0)

    local ServerRestartReason = CreateFrame("EditBox", "IdleshutdownReasonBox", commandsFramePage1, "InputBoxTemplate")
    ServerRestartReason:SetSize(120, 22)
    ServerRestartReason:SetText("Reason")
    ServerRestartReason:SetPoint("TOPRIGHT", ServerRestartDelay, "TOPRIGHT", 130, 0)

    btnServerRestart:SetScript("OnClick", function(self)
        local delay = ServerRestartDelay:GetText()
        local reason = ServerRestartReason:GetText()
        local cmd = ".server restart " .. delay .. " 2 " .. reason
        SendChatMessage(cmd, "SAY")
        print("Commande envoyée: " .. cmd)
    end)	

	-------------------------------------------------------------------------------
	-- Server Restart CANCEL Button
	-------------------------------------------------------------------------------
    local btnServerRestartCancel = CreateServerButtonPage1("ServerRestartCancelButton", "restart cancel", "Syntax: .server restart cancel\r\nCancel the restart timer.", ".server restart cancel")
    btnServerRestartCancel:SetPoint("TOPLEFT", btnServerRestart, "TOPRIGHT", 230, 0)
	
	-------------------------------------------------------------------------------
	-- Server Restart FORCE Button
	-------------------------------------------------------------------------------
	local btnServerRestartForce = CreateServerButtonPage1("btnServerRestartForceButton", "Restart Force", "Syntax: .server restart [force] #delay [#exit_code] [reason]\n\nRestart the server after #delay seconds. Use #exit_code or 2 as program exit code. Specify \'force\' to allow short-term shutdown despite other players being connected.", ".server restart force")
    btnServerRestartForce:SetPoint("TOPLEFT", btnServerRestart, "BOTTOMLEFT", 0, -10)
	
	local ServerRestartForceDelay = CreateFrame("EditBox", "ServerRestartForceDelayBox", commandsFramePage1, "InputBoxTemplate")
    ServerRestartForceDelay:SetSize(80, 22)
    ServerRestartForceDelay:SetText("Delay in s")
    ServerRestartForceDelay:SetPoint("TOPRIGHT", btnServerRestartForce, "TOPRIGHT", 90, 0)

    local ServerRestartForceReason = CreateFrame("EditBox", "IdleshutdownReasonBox", commandsFramePage1, "InputBoxTemplate")
    ServerRestartForceReason:SetSize(120, 22)
    ServerRestartForceReason:SetText("Reason")
    ServerRestartForceReason:SetPoint("TOPRIGHT", ServerRestartForceDelay, "TOPRIGHT", 130, 0)

    btnServerRestartForce:SetScript("OnClick", function(self)
        local delay = ServerRestartForceDelay:GetText()
        local reason = ServerRestartForceReason:GetText()
        local cmd = ".server restart force " .. delay .. " 2 " .. reason
        SendChatMessage(cmd, "SAY")
        print("Commande envoyée: " .. cmd)
    end)	
	
	-------------------------------------------------------------------------------
	-- Server Shutdown Button
	-------------------------------------------------------------------------------
    local btnServerShutdown = CreateServerButtonPage1("ServerShutdownButton", "server shutdown", "Syntax: .server shutdown #delay [#exit_code] [reason]\nShut the server down after delay. Use exit code 0.", ".server shutdown")
    btnServerShutdown:SetPoint("TOPLEFT", btnServerRestartForce, "BOTTOMLEFT", 0, -10)

    local ServerShutdownDelay = CreateFrame("EditBox", "ServerShutdownDelayBox", commandsFramePage1, "InputBoxTemplate")
    ServerShutdownDelay:SetSize(80, 22)
    ServerShutdownDelay:SetText("Delay in s")
    ServerShutdownDelay:SetPoint("TOPRIGHT", btnServerShutdown, "TOPRIGHT", 90, 0)

    local ServerShutdownReason = CreateFrame("EditBox", "ServerShutdownReasonBox", commandsFramePage1, "InputBoxTemplate")
    ServerShutdownReason:SetSize(120, 22)
    ServerShutdownReason:SetText("Reason")
    ServerShutdownReason:SetPoint("TOPRIGHT", ServerShutdownDelay, "TOPRIGHT", 130, 0)

    btnServerShutdown:SetScript("OnClick", function(self)
        local delay = ServerShutdownDelay:GetText()
        local reason = ServerShutdownReason:GetText()
        local cmd = ".server shutdown " .. delay .. " 0 " .. reason
        SendChatMessage(cmd, "SAY")
        print("Commande envoyée: " .. cmd)
    end)	

	local btnServerShutdownCancel = CreateServerButtonPage1("ServerShutdownCancelButton", "shutdown cancel", "Syntax: .server shutdown cancel\r\nCancel the shutdown timer.", ".server shutdown cancel")
    btnServerShutdownCancel:SetPoint("TOPLEFT", btnServerShutdown, "TOPRIGHT", 230, 0)

	-------------------------------------------------------------------------------
	-- Server Shutdown FORCE Button
	-------------------------------------------------------------------------------	
    local btnServerShutdownForce = CreateServerButtonPage1("ServerShutdownForceButton", "shutdown force", "Syntax: .server shutdown [force] #delay [#exit_code] [reason]\n\nShut the server down after #delay seconds. Use #exit_code or 0 as program exit code. Specify \'force\' to allow short-term shutdown despite other players being connected.", ".server shutdown force")
    btnServerShutdownForce:SetPoint("TOPLEFT", btnServerShutdown, "BOTTOMLEFT", 0, -10)
	
    local ServerShutdownForceDelay = CreateFrame("EditBox", "ServerShutdownForceDelayBox", commandsFramePage1, "InputBoxTemplate")
    ServerShutdownForceDelay:SetSize(80, 22)
    ServerShutdownForceDelay:SetText("Delay in s")
    ServerShutdownForceDelay:SetPoint("TOPRIGHT", btnServerShutdownForce, "TOPRIGHT", 90, 0)

    local ServerShutdownForceReason = CreateFrame("EditBox", "ServerShutdownReasonBox", commandsFramePage1, "InputBoxTemplate")
    ServerShutdownForceReason:SetSize(120, 22)
    ServerShutdownForceReason:SetText("Reason")
    ServerShutdownForceReason:SetPoint("TOPRIGHT", ServerShutdownForceDelay, "TOPRIGHT", 130, 0)

    btnServerShutdownForce:SetScript("OnClick", function(self)
        local delay = ServerShutdownForceDelay:GetText()
        local reason = ServerShutdownForceReason:GetText()
        local cmd = ".server shutdown force " .. delay .. " 0 " .. reason
        SendChatMessage(cmd, "SAY")
        print("Commande envoyée: " .. cmd)
    end)
	
	-------------------------------------------------------------------------------
    -- PAGE 2
    -------------------------------------------------------------------------------
    local commandsFramePage2 = CreateFrame("Frame", nil, pages[2])
    commandsFramePage2:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
    commandsFramePage2:SetSize(500, 350)

    local page2Title = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    page2Title:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, 0)
    page2Title:SetText("Page 2")

    local currentY2 = -20
    local function NextPosition2(height)
        local pos = currentY2
        currentY2 = currentY2 - height - 5
        return pos
    end

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
            SendChatMessage(cmd, "SAY")
            print("Commande envoyée: " .. cmd)
        end)
        return btn
    end

	-- Créez d'abord le bouton pour la commande server set motd
	local btnServerSetMotd = CreateServerButtonPage2("ServerSetMotdButton", "server set motd", "Syntax: .server set motd $MOTD\r\nSet server Message of the day.", ".server set motd")
	btnServerSetMotd:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, NextPosition2(22))
	
	-- Créez ensuite l'EditBox pour saisir le message MOTD
	local editServerMotd = CreateFrame("EditBox", "ServerSetMotdMessageBox", commandsFramePage2, "InputBoxTemplate")
	editServerMotd:SetSize(350, 22)
	editServerMotd:SetText("Set Message Of The Day")
	editServerMotd:SetPoint("TOPRIGHT", btnServerSetMotd, "TOPRIGHT", 360, 0)
	
	-- Ajoutez le script OnClick au bouton pour récupérer le texte de l'editbox et envoyer la commande
	btnServerSetMotd:SetScript("OnClick", function(self)
		local message = editServerMotd:GetText()
		local cmd = ".server set motd " .. message
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)

 	-------------------------------------------------------------------------------
	-- Server Shutdown FORCE Button
	-------------------------------------------------------------------------------	

	-- On crée un frame conteneur qui regroupe les radio boutons, le séparateur et le bouton "Set"
	local closedFrame = CreateFrame("Frame", nil, commandsFramePage2)
	closedFrame:SetPoint("TOPLEFT", btnServerSetMotd, "BOTTOMLEFT", 0, -10)
	closedFrame:SetSize(500, 22)
	
	-- Créez un label pour afficher "Allow Server Connections :"
	local allowLabel = closedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	allowLabel:SetPoint("LEFT", closedFrame, "LEFT", 0, 0)
	allowLabel:SetText("Desable Server Connections : ")
	
	-- Création du bouton radio "On" et positionnement à droite du label
	local radioOn = CreateFrame("CheckButton", "ServerSetClosedRadioOn", closedFrame, "UIRadioButtonTemplate")
	radioOn:SetPoint("LEFT", allowLabel, "RIGHT", 5, 0)
	_G[radioOn:GetName().."Text"]:SetText("On")
	radioOn:SetChecked(true)  -- Par défaut, "On" est sélectionné
	
	-- Création du bouton radio "Off"
	local radioOff = CreateFrame("CheckButton", "ServerSetClosedRadioOff", closedFrame, "UIRadioButtonTemplate")
	radioOff:SetPoint("LEFT", radioOn, "RIGHT", 30, 0)
	_G[radioOff:GetName().."Text"]:SetText("Off")
	radioOff:SetChecked(false)
	
	-- Fonction pour mettre à jour les boutons radio (mutuellement exclusifs)
	local function UpdateRadioButtons(selected)
		if selected == "On" then
			radioOn:SetChecked(true)
			radioOff:SetChecked(false)
		else
			radioOn:SetChecked(false)
			radioOff:SetChecked(true)
		end
	end
	
	radioOn:SetScript("OnClick", function(self)
		UpdateRadioButtons("On")
	end)
	
	radioOff:SetScript("OnClick", function(self)
		UpdateRadioButtons("Off")
	end)
	
	-- -- Création d'un séparateur "|" entre les radio boutons et le bouton "Set"
	-- local separator = closedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	-- separator:SetPoint("LEFT", radioOn, "RIGHT", 20, 0)
	-- separator:SetText("|")
	
	-- Création du bouton "Set" qui lance la commande .server set closed
	local btnServerSetClosed = CreateFrame("Button", "ServerSetClosedButton", closedFrame, "UIPanelButtonTemplate")
	btnServerSetClosed:SetSize(80, 22)
	btnServerSetClosed:SetText("Set")
	btnServerSetClosed:SetPoint("LEFT", radioOff, "RIGHT", 50, 0)
	btnServerSetClosed:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Syntax: .server set closed on/off\r\nSets whether the world accepts new client connections.", 1,1,1,1,true)
		GameTooltip:Show()
	end)
	btnServerSetClosed:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	btnServerSetClosed:SetScript("OnClick", function(self)
		local state = radioOn:GetChecked() and "on" or "off"
		local cmd = ".server set closed " .. state
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)
	
 	-------------------------------------------------------------------------------
	-- Server Plimits Button
	-------------------------------------------------------------------------------	
	-- Création d'un frame pour la commande server plimit
	local plimitFrame = CreateFrame("Frame", nil, commandsFramePage2)
	plimitFrame:SetPoint("TOPLEFT", closedFrame, "BOTTOMLEFT", 0, -10)
	plimitFrame:SetSize(500, 22)
	
	-- Label pour indiquer la commande
	local plimitLabel = plimitFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	plimitLabel:SetPoint("LEFT", plimitFrame, "LEFT", 0, 0)
	plimitLabel:SetText("Player Limit: ")
	
	-- Champ de saisie pour l'argument (par défaut "Arg")
	local plimitInput = CreateFrame("EditBox", "ServerPlimitInputBox", plimitFrame, "InputBoxTemplate")
	plimitInput:SetSize(100, 22)
	plimitInput:SetText("Arg. or Number")
	plimitInput:SetPoint("LEFT", plimitLabel, "RIGHT", 5, 0)
	
	-- Bouton "Set" qui envoie la commande .server plimit [argument]
	local btnServerPlimit = CreateFrame("Button", "ServerPlimitButton", plimitFrame, "UIPanelButtonTemplate")
	btnServerPlimit:SetSize(80, 22)
	btnServerPlimit:SetText("Set")
	btnServerPlimit:SetPoint("LEFT", plimitInput, "RIGHT", 10, 0)
	btnServerPlimit:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Syntax: .server plimit [#num|-1|-2|-3||reset|player|moderator|gamemaster|administrator]\r\nWithout arg, show current limit; with arg, set the limit.\r\nAvec argument numérique positif :Par exemple, .server plimit 100 définira que 100 joueurs maximum peuvent se connecter au serveur.\r\nAvec argument numérique négatif : Un nombre négatif est utilisé pour définir une limitation de sécurité (par exemple, .server plimit -1). Cela signifie que seuls les joueurs ayant un certain niveau de sécurité (ou mieux) peuvent se connecter. Les valeurs négatives correspondent souvent à des niveaux de sécurité internes.\r\nAvec argument textuel (player, moderator, gamemaster, administrator) : Vous pouvez aussi utiliser des mots-clés qui représentent des niveaux de sécurité. Par exemple, .server plimit moderator limiterait les connexions aux joueurs qui possèdent un niveau de modérateur ou supérieur.", 1,1,1,1,true)
		GameTooltip:Show()
	end)
	btnServerPlimit:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	btnServerPlimit:SetScript("OnClick", function(self)
		local arg = plimitInput:GetText()
		local cmd = ""
		if arg == "" or arg == "Arg" then
			cmd = ".server plimit"
		else
			cmd = ".server plimit " .. arg
		end
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)
	
	-- Bouton "Reset" placé à droite du bouton "Set"
	local btnServerPlimitReset = CreateFrame("Button", "ServerPlimitResetButton", plimitFrame, "UIPanelButtonTemplate")
	btnServerPlimitReset:SetSize(80, 22)
	btnServerPlimitReset:SetText("Reset")
	btnServerPlimitReset:SetPoint("LEFT", btnServerPlimit, "RIGHT", 10, 0)
	btnServerPlimitReset:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Reset des Valeurs", 1,1,1,1,true)
		GameTooltip:Show()
	end)
	btnServerPlimitReset:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	btnServerPlimitReset:SetScript("OnClick", function(self)
		local cmd = ".server plimit reset"
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)

 	-------------------------------------------------------------------------------
	-- Server Set Log Level
	-------------------------------------------------------------------------------	
	-- Création d'un frame pour la commande server set loglevel
	local loglevelFrame = CreateFrame("Frame", nil, commandsFramePage2)
	loglevelFrame:SetPoint("TOPLEFT", plimitFrame, "BOTTOMLEFT", 0, -10)  -- Placer en dessous du bloc plimit
	loglevelFrame:SetSize(500, 22)
	
	-- Label indiquant la commande
	local loglevelLabel = loglevelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	loglevelLabel:SetPoint("LEFT", loglevelFrame, "LEFT", 0, 0)
	loglevelLabel:SetText("Set Loglevel: ")
	
	-- Zone de saisie pour le facility ($facility)
	local editFacility = CreateFrame("EditBox", "ServerSetLoglevelFacility", loglevelFrame, "InputBoxTemplate")
	editFacility:SetSize(50, 22)
	editFacility:SetText("a")  -- Valeur par défaut : "a" pour appender (vous pouvez modifier)
	editFacility:SetPoint("LEFT", loglevelLabel, "RIGHT", 5, 0)
	
	-- Zone de saisie pour le nom ($name)
	local editName = CreateFrame("EditBox", "ServerSetLoglevelName", loglevelFrame, "InputBoxTemplate")
	editName:SetSize(100, 22)
	editName:SetText("Name")
	editName:SetPoint("LEFT", editFacility, "RIGHT", 5, 0)
	
	-- Zone de saisie pour le niveau de log ($loglevel)
	local editLevel = CreateFrame("EditBox", "ServerSetLoglevelLevel", loglevelFrame, "InputBoxTemplate")
	editLevel:SetSize(50, 22)
	editLevel:SetText("3")  -- Par défaut "3" (info) ; vous pouvez adapter
	editLevel:SetPoint("LEFT", editName, "RIGHT", 5, 0)
	
	-- Bouton "Set Loglevel" qui envoie la commande
	local btnSetLoglevel = CreateFrame("Button", "ServerSetLoglevelButton", loglevelFrame, "UIPanelButtonTemplate")
	btnSetLoglevel:SetSize(100, 22)
	btnSetLoglevel:SetText("Set Loglevel")
	btnSetLoglevel:SetPoint("LEFT", editLevel, "RIGHT", 10, 0)
	btnSetLoglevel:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Syntax: .server set loglevel $facility $name $loglevel\r\n$facility: appender (a) or logger (l).\r\n$loglevel: 0-disabled, 1-trace, 2-debug, 3-info, 4-warn, 5-error, 6-fatal.", 1,1,1,1,true)
		GameTooltip:Show()
	end)
	btnSetLoglevel:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	btnSetLoglevel:SetScript("OnClick", function(self)
		local facility = editFacility:GetText()
		local name = editName:GetText()
		local level = editLevel:GetText()
		local cmd = ".server set loglevel " .. facility .. " " .. name .. " " .. level
		SendChatMessage(cmd, "SAY")
		print("Commande envoyée: " .. cmd)
	end)



    ------------------------------------------------------------------------------
    -- Boutons de navigation (Précédent / Suivant)
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

    -- local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
    -- navPageLabel:SetText("Page " .. currentPage .. " / " .. totalPages)
	-- 
    -- local function ShowPage(pageIndex)
    --     for i = 1, totalPages do
    --         if i == pageIndex then
    --             pages[i]:Show()
    --         else
    --             pages[i]:Hide()
    --         end
    --     end
    --     navPageLabel:SetText("Page " .. pageIndex .. " / " .. totalPages)
    -- end
	-- 
    -- ShowPage(1)

    ------------------------------------------------------------------------------
    -- Bouton Back final
    ------------------------------------------------------------------------------
    local btnBackFinal = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("TOPRIGHT", navPageLabel, "TOPRIGHT", 0, 30)
    btnBackFinal:SetText(L["Back"])
    btnBackFinal:SetHeight(22)
    btnBackFinal:SetWidth(btnBackFinal:GetTextWidth() + 20)
    btnBackFinal:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
