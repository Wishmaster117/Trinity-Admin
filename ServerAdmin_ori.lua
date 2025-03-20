local ServerAdmin = TrinityAdmin:GetModule("ServerAdmin")

-- Fonction pour afficher le panneau ServerAdmin
function ServerAdmin:ShowServerAdminPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateServerAdminPanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau ServerAdmin
function ServerAdmin:CreateServerAdminPanel()
    local panel = CreateFrame("Frame", "TrinityAdminServerAdminPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Server Admin Panel")  -- Vous pouvez utiliser TrinityAdmin_Translations si nécessaire

    ------------------------------------------------------------------------------
    -- Création d'un conteneur pour les commandes serveur
    ------------------------------------------------------------------------------
    local commandsFrame = CreateFrame("Frame", nil, panel)
    commandsFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -40)
    commandsFrame:SetSize(500, 350)  -- Ajustez la taille selon vos besoins

    local currentY = -10
    local function NextPosition(height)
        local pos = currentY
        currentY = currentY - height - 5
        return pos
    end

    -- Fonction d'aide pour créer un bouton simple
    local function CreateServerButton(name, text, tooltip, cmd)
        local btn = CreateFrame("Button", name, commandsFrame, "UIPanelButtonTemplate")
        btn:SetSize(150, 22)
        btn:SetText(text)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, 1,1,1,1,true)
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

    ------------------------------------------------------------------------------
    -- Boutons simples (affichant la commande directement)
    ------------------------------------------------------------------------------
    local btnServerCorpses = CreateServerButton("ServerCorpsesButton", "server corpses", "Syntax: .server corpses\r\n\r\nTrigger corpses expire check in world.", ".server corpses")
    btnServerCorpses:SetPoint("TOPLEFT", commandsFrame, "TOPLEFT", 0, NextPosition(22))

    local btnServerDebug = CreateServerButton("ServerDebugButton", "server debug", "Syntax: .server debug\n\nShows detailed information about server setup, useful when reporting a bug.", ".server debug")
    btnServerDebug:SetPoint("TOPLEFT", btnServerCorpses, "TOPRIGHT", 10, 0)

    local btnServerExit = CreateServerButton("ServerExitButton", "server exit", "Syntax: .server exit\r\n\r\nTerminate trinity-core NOW. Exit code 0.", ".server exit")
    btnServerExit:SetPoint("TOPLEFT", btnServerDebug, "TOPRIGHT", 10, 0)

    local btnServerInfo = CreateServerButton("ServerInfoButton", "server info", "Syntax: .server info\r\n\r\nDisplay server version and connected players.", ".server info")
    btnServerInfo:SetPoint("TOPLEFT", btnServerExit, "TOPRIGHT", 10, 0)

    local btnServerMotd = CreateServerButton("ServerMotdButton", "server motd", "Syntax: .server motd\r\n\r\nShow server Message of the day.", ".server motd")
    btnServerMotd:SetPoint("TOPLEFT", btnServerInfo, "TOPRIGHT", 10, 0)

    ------------------------------------------------------------------------------
    -- Bouton server idlerestart avec zones de saisie (Delay et Reason)
    ------------------------------------------------------------------------------
    local btnServerIdleRestart = CreateFrame("Button", "ServerIdleRestartButton", commandsFrame, "UIPanelButtonTemplate")
    btnServerIdleRestart:SetSize(150, 22)
    btnServerIdleRestart:SetText("server idlerestart")
    btnServerIdleRestart:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .server idlerestart #delay [#exit_code] [reason]\r\nRestart the server after #delay seconds if no players are connected. Use exit code 2.", 1,1,1,1,true)
        GameTooltip:Show()
    end)
    btnServerIdleRestart:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    btnServerIdleRestart:SetPoint("TOPLEFT", btnServerCorpses, "BOTTOMLEFT", 0, -10)
	
    local idlerestartDelay = CreateFrame("EditBox", "IdlerestartDelayBox", commandsFrame, "InputBoxTemplate")
    idlerestartDelay:SetSize(80, 22)
    idlerestartDelay:SetText("Delay in s")
    idlerestartDelay:SetPoint("TOPRIGHT", btnServerIdleRestart, "TOPRIGHT", 90, 0)

    local idlerestartReason = CreateFrame("EditBox", "IdlerestartReasonBox", commandsFrame, "InputBoxTemplate")
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

    ------------------------------------------------------------------------------
    -- Bouton server idlerestart cancel
    ------------------------------------------------------------------------------
    local btnServerIdleRestartCancel = CreateServerButton("ServerIdleRestartCancelButton", "idlerestart cancel", "Syntax: .server idlerestart cancel\r\nCancel the restart timer.", ".server idlerestart cancel")
    btnServerIdleRestartCancel:SetPoint("TOPRIGHT", idlerestartReason, "TOPRIGHT", 150, 0)

    ------------------------------------------------------------------------------
    -- Bouton server idleshutdown avec zones de saisie (Delay et Reason)
    ------------------------------------------------------------------------------
    local btnServerIdleShutdown = CreateFrame("Button", "ServerIdleShutdownButton", commandsFrame, "UIPanelButtonTemplate")
    btnServerIdleShutdown:SetSize(150, 22)
    btnServerIdleShutdown:SetText("server idleshutdown")
    btnServerIdleShutdown:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .server idleshutdown #delay [#exit_code] [reason]\r\nShut the server down after #delay seconds if no players are connected. Use exit code 0.", 1,1,1,1,true)
        GameTooltip:Show()
    end)
    btnServerIdleShutdown:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    btnServerIdleShutdown:SetPoint("TOPLEFT", btnServerIdleRestart, "BOTTOMLEFT", 0, -5)
	
    local idleshutdownDelay = CreateFrame("EditBox", "IdleshutdownDelayBox", commandsFrame, "InputBoxTemplate")
    idleshutdownDelay:SetSize(80, 22)
    idleshutdownDelay:SetText("Delay in s")
    idleshutdownDelay:SetPoint("TOPRIGHT", btnServerIdleShutdown, "TOPRIGHT", 90, 0)

    local idleshutdownReason = CreateFrame("EditBox", "IdleshutdownReasonBox", commandsFrame, "InputBoxTemplate")
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
	
    local btnServerIdleShutdownCancel = CreateServerButton("ServerIdleShutdownCancelButton", "idleshutdown cancel", "Syntax: .server idleshutdown cancel\r\nCancel the shutdown timer.", ".server idleshutdown cancel")
    btnServerIdleShutdownCancel:SetPoint("TOPRIGHT", idleshutdownReason, "TOPRIGHT", 150, 0)

    ------------------------------------------------------------------------------
    -- Bouton server plimit
    ------------------------------------------------------------------------------
    local btnServerPlimit = CreateServerButton("ServerPlimitButton", "server plimit", "Syntax: .server plimit [#num|-1|-2|-3|reset|player|moderator|gamemaster|administrator]\r\nWithout arg, show current limit; with arg, set it.", ".server plimit")
    btnServerPlimit:SetPoint("TOPLEFT", btnServerIdleShutdown, "BOTTOMLEFT", 0, -10)

    ------------------------------------------------------------------------------
    -- Bouton server restart
    ------------------------------------------------------------------------------
    local btnServerRestart = CreateServerButton("ServerRestartButton", "server restart", "Syntax: .server restart [force] #delay [#exit_code] [reason]\nRestart the server after #delay seconds. Use exit code 2. Include 'force' to override connected players.", ".server restart")
    btnServerRestart:SetPoint("TOPLEFT", btnServerPlimit, "BOTTOMLEFT", 0, -5)

    ------------------------------------------------------------------------------
    -- Bouton server restart cancel
    ------------------------------------------------------------------------------
    local btnServerRestartCancel = CreateServerButton("ServerRestartCancelButton", "restart cancel", "Syntax: .server restart cancel\r\nCancel the restart timer.", ".server restart cancel")
    btnServerRestartCancel:SetPoint("TOPLEFT", btnServerRestart, "BOTTOMLEFT", 0, -5)

    ------------------------------------------------------------------------------
    -- Bouton server set closed
    ------------------------------------------------------------------------------
    local btnServerSetClosed = CreateServerButton("ServerSetClosedButton", "server set closed", "Syntax: .server set closed on/off\r\nSets whether new connections are allowed.", ".server set closed on")
    btnServerSetClosed:SetPoint("TOPLEFT", btnServerRestartCancel, "BOTTOMLEFT", 0, -10)

    ------------------------------------------------------------------------------
    -- Bouton server set loglevel
    ------------------------------------------------------------------------------
    local btnServerSetLoglevel = CreateServerButton("ServerSetLoglevelButton", "server set loglevel", "Syntax: .server set loglevel $facility $name $loglevel.\n$facility: a (appender) or l (logger).\n$loglevel: 0-disabled, 1-trace, 2-debug, 3-info, 4-warn, 5-error, 6-fatal.", ".server set loglevel")
    btnServerSetLoglevel:SetPoint("TOPLEFT", btnServerSetClosed, "BOTTOMLEFT", 0, -5)

    ------------------------------------------------------------------------------
    -- Bouton server set motd
    ------------------------------------------------------------------------------
    local btnServerSetMotd = CreateServerButton("ServerSetMotdButton", "server set motd", "Syntax: .server set motd $MOTD\r\nSet server Message of the day.", ".server set motd Welcome!")
    btnServerSetMotd:SetPoint("TOPLEFT", btnServerSetLoglevel, "BOTTOMLEFT", 0, -5)

    ------------------------------------------------------------------------------
    -- Bouton server shutdown
    ------------------------------------------------------------------------------
    local btnServerShutdown = CreateServerButton("ServerShutdownButton", "server shutdown", "Syntax: .server shutdown [force] #delay [#exit_code] [reason]\nShut the server down after #delay seconds. Use exit code 0.", ".server shutdown")
    btnServerShutdown:SetPoint("TOPLEFT", btnServerSetMotd, "BOTTOMLEFT", 0, -10)

    ------------------------------------------------------------------------------
    -- Bouton server shutdown cancel
    ------------------------------------------------------------------------------
    local btnServerShutdownCancel = CreateServerButton("ServerShutdownCancelButton", "shutdown cancel", "Syntax: .server shutdown cancel\r\nCancel the shutdown timer.", ".server shutdown cancel")
    btnServerShutdownCancel:SetPoint("TOPLEFT", btnServerShutdown, "BOTTOMLEFT", 0, -5)

    ------------------------------------------------------------------------------
    -- Bouton server shutdown force
    ------------------------------------------------------------------------------
    local btnServerShutdownForce = CreateServerButton("ServerShutdownForceButton", "shutdown force", "Syntax: .server shutdown [force] #delay [#exit_code] [reason]\nShut the server down after #delay seconds. Use exit code 0. Include 'force' to override.", ".server shutdown force")
    btnServerShutdownForce:SetPoint("TOPLEFT", btnServerShutdownCancel, "BOTTOMLEFT", 0, -5)

    ------------------------------------------------------------------------------
    -- Bouton Retour final du panneau
    ------------------------------------------------------------------------------
    local btnBackFinal = CreateFrame("Button", "TrinityAdminTeleportBackButton", panel, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBackFinal:SetText(TrinityAdmin_Translations["Back"])
    btnBackFinal:SetHeight(22)
    btnBackFinal:SetWidth(btnBackFinal:GetTextWidth() + 20)
    btnBackFinal:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)
	
    self.panel = panel
end
