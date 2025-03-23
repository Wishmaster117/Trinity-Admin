----------------------------------------------
-- TrinityAdmin Guild Module (Guild.lua)
----------------------------------------------

local Guild = TrinityAdmin:GetModule("Guild")

-------------------------------------------------------------
-- 1) Définir la fonction SendCommand pour exécuter une cmd --
--    via la fenêtre de chat (ChatFrame1EditBox).
-------------------------------------------------------------
function TrinityAdmin:SendCommand(cmd)
    if not cmd or cmd == "" then
        return
    end
    -- On s'assure que la commande commence par un point (.)
    if not string.match(cmd, "^%.") then
        cmd = "." .. cmd
    end

    -- Envoi via la fenêtre de chat
    local editBox = ChatFrame1EditBox
    if not editBox then
        self:Print("Impossible de trouver ChatFrame1EditBox pour exécuter la commande.")
        return
    end

    if not editBox:IsShown() then
        -- Ouvre la fenêtre de chat et pré-remplit avec la commande
        ChatFrame_OpenChat(cmd, DEFAULT_CHAT_FRAME)
    else
        -- Si l'editBox est déjà ouvert
        editBox:SetText(cmd)
        ChatEdit_SendText(editBox, 0)
    end
end

--------------------------------------------------------------
-- 2) Fonction pour afficher le panneau Guild
--------------------------------------------------------------
function Guild:ShowGuildPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateGuildPanel()
    end
    self.panel:Show()
end

--------------------------------------------------------------
-- 3) Fonction pour créer le panneau Guild
--------------------------------------------------------------
function Guild:CreateGuildPanel()
    local panel = CreateFrame("Frame", "TrinityAdminGuildPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Couleur de fond (ajustez si besoin)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Guild's Management")

    ------------------------------------------------------
    -- Bouton "Back" pour revenir au menu principal
    ------------------------------------------------------
    local btnBack = CreateFrame("Button", "TrinityAdminTeleportBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"] or "Back")
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    ------------------------------------------------------
    -- Gestion de l'offset Y pour empiler les widgets
    ------------------------------------------------------
    local offsetY = -20

    ----------------------------------------------------------------
    -- 1) GUILD CREATE
    ----------------------------------------------------------------
    local guildCreateLeaderEB = CreateFrame("EditBox", "$parentGuildCreateLeaderEB", panel, "InputBoxTemplate")
    guildCreateLeaderEB:SetSize(120, 20)
    guildCreateLeaderEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildCreateLeaderEB:SetAutoFocus(false)
    guildCreateLeaderEB:SetText("Guild Leader Name")

    local guildCreateNameEB = CreateFrame("EditBox", "$parentGuildCreateNameEB", panel, "InputBoxTemplate")
    guildCreateNameEB:SetSize(120, 20)
    guildCreateNameEB:SetPoint("LEFT", guildCreateLeaderEB, "RIGHT", 10, 0)
    guildCreateNameEB:SetAutoFocus(false)
    guildCreateNameEB:SetText("Guild Name")

    local createButton = CreateFrame("Button", "$parentCreateButton", panel, "UIPanelButtonTemplate")
    createButton:SetSize(80, 22)
    createButton:SetPoint("LEFT", guildCreateNameEB, "RIGHT", 10, 0)
    createButton:SetText("Create")
    createButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .guild create <LeaderName> \"Guild Name\"\r\n\r\nCreate a guild named \"Guild Name\" with the player LeaderName as leader.")
    end)
    createButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    createButton:SetScript("OnClick", function()
        local leader = guildCreateLeaderEB:GetText()
        local gName  = guildCreateNameEB:GetText()

        if (not leader or leader == "" or leader == "Guild Leader Name") then
            TrinityAdmin:Print("Please specify a valid Guild Leader Name!")
            return
        end
        if (not gName or gName == "" or gName == "Guild Name") then
            TrinityAdmin:Print("Please specify a valid Guild Name!")
            return
        end

        -- IMPORTANT: seul le nom de la guilde doit être entre guillemets
        -- Exemple : .guild create Banana "Banana Team"
        TrinityAdmin:SendCommand('.guild create ' .. leader .. ' "' .. gName .. '"')
    end)

    offsetY = offsetY - 40

    ----------------------------------------------------------------
    -- 2) GUILD DELETE
    ----------------------------------------------------------------
    local guildDeleteNameEB = CreateFrame("EditBox", "$parentGuildDeleteNameEB", panel, "InputBoxTemplate")
    guildDeleteNameEB:SetSize(120, 20)
    guildDeleteNameEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildDeleteNameEB:SetAutoFocus(false)
    guildDeleteNameEB:SetText("Guild Name")

    local deleteButton = CreateFrame("Button", "$parentDeleteButton", panel, "UIPanelButtonTemplate")
    deleteButton:SetSize(80, 22)
    deleteButton:SetPoint("LEFT", guildDeleteNameEB, "RIGHT", 10, 0)
    deleteButton:SetText("Delete")
    deleteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .guild delete \"Guild Name\"\r\n\r\nDelete guild named \"Guild Name\".")
    end)
    deleteButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    deleteButton:SetScript("OnClick", function()
        local gName = guildDeleteNameEB:GetText()

        if (not gName or gName == "" or gName == "Guild Name") then
            TrinityAdmin:Print("Please specify a valid Guild Name to delete!")
            return
        end

        TrinityAdmin:SendCommand('.guild delete "' .. gName .. '"')
    end)

    offsetY = offsetY - 40

    ----------------------------------------------------------------
    -- 3) GUILD INFO
    ----------------------------------------------------------------
    local guildInfoNameEB = CreateFrame("EditBox", "$parentGuildInfoNameEB", panel, "InputBoxTemplate")
    guildInfoNameEB:SetSize(120, 20)
    guildInfoNameEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildInfoNameEB:SetAutoFocus(false)
    guildInfoNameEB:SetText("Guild ID")

    local infoButton = CreateFrame("Button", "$parentInfoButton", panel, "UIPanelButtonTemplate")
    infoButton:SetSize(80, 22)
    infoButton:SetPoint("LEFT", guildInfoNameEB, "RIGHT", 10, 0)
    infoButton:SetText("Info")
    infoButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .guild info \"Guild ID\"\r\n\r\nShows information about the guild \"Guild ID\".")
    end)
    infoButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    infoButton:SetScript("OnClick", function()
        local gName = guildInfoNameEB:GetText()

        if (not gName or gName == "" or gName == "Guild ID") then
            TrinityAdmin:Print("Please specify a valid Guild ID for info!")
            return
        end

        TrinityAdmin:SendCommand('.guild info ' .. gName)
    end)

    offsetY = offsetY - 40

    ----------------------------------------------------------------
    -- 4) GUILD INVITE
    ----------------------------------------------------------------
    local guildInvitePlayerEB = CreateFrame("EditBox", "$parentGuildInvitePlayerEB", panel, "InputBoxTemplate")
    guildInvitePlayerEB:SetSize(120, 20)
    guildInvitePlayerEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildInvitePlayerEB:SetAutoFocus(false)
    guildInvitePlayerEB:SetText("Player Name")

    local guildInviteNameEB = CreateFrame("EditBox", "$parentGuildInviteNameEB", panel, "InputBoxTemplate")
    guildInviteNameEB:SetSize(120, 20)
    guildInviteNameEB:SetPoint("LEFT", guildInvitePlayerEB, "RIGHT", 10, 0)
    guildInviteNameEB:SetAutoFocus(false)
    guildInviteNameEB:SetText("Guild Name")

    local inviteButton = CreateFrame("Button", "$parentInviteButton", panel, "UIPanelButtonTemplate")
    inviteButton:SetSize(80, 22)
    inviteButton:SetPoint("LEFT", guildInviteNameEB, "RIGHT", 10, 0)
    inviteButton:SetText("Invite")
    inviteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .guild invite <PlayerName> \"Guild Name\"\r\n\r\nAdd player <PlayerName> into the guild \"Guild Name\".")
    end)
    inviteButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    inviteButton:SetScript("OnClick", function()
        local playerName = guildInvitePlayerEB:GetText()
        local gName      = guildInviteNameEB:GetText()

        if (not gName or gName == "" or gName == "Guild Name") then
            TrinityAdmin:Print("Please specify a valid Guild Name for invite!")
            return
        end

        -- Si champ Player Name vide/par défaut => utilisation de la cible du MJ
        if (not playerName or playerName == "" or playerName == "Player Name") then
            if UnitExists("target") then
                playerName = UnitName("target")
            else
                TrinityAdmin:Print("No valid player name or target selected!")
                return
            end
        end

        -- .guild invite <PlayerName> "Guild Name"
        TrinityAdmin:SendCommand('.guild invite ' .. playerName .. ' "' .. gName .. '"')
    end)

    offsetY = offsetY - 40

    ----------------------------------------------------------------
    -- 5) GUILD RANK
    ----------------------------------------------------------------
    local guildRankPlayerEB = CreateFrame("EditBox", "$parentGuildRankPlayerEB", panel, "InputBoxTemplate")
    guildRankPlayerEB:SetSize(120, 20)
    guildRankPlayerEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildRankPlayerEB:SetAutoFocus(false)
    guildRankPlayerEB:SetText("Player Name")

    local guildRankValueEB = CreateFrame("EditBox", "$parentGuildRankValueEB", panel, "InputBoxTemplate")
    guildRankValueEB:SetSize(120, 20)
    guildRankValueEB:SetPoint("LEFT", guildRankPlayerEB, "RIGHT", 10, 0)
    guildRankValueEB:SetAutoFocus(false)
    guildRankValueEB:SetText("Rank")

    local rankButton = CreateFrame("Button", "$parentRankButton", panel, "UIPanelButtonTemplate")
    rankButton:SetSize(80, 22)
    rankButton:SetPoint("LEFT", guildRankValueEB, "RIGHT", 10, 0)
    rankButton:SetText("Set")
    rankButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .guild rank <PlayerName> <Rank>\r\n\r\nSet rank <Rank> for player <PlayerName> in a guild.")
    end)
    rankButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    rankButton:SetScript("OnClick", function()
        local playerName = guildRankPlayerEB:GetText()
        local rankValue  = guildRankValueEB:GetText()

        if (not rankValue or rankValue == "" or rankValue == "Rank") then
            TrinityAdmin:Print("Please specify a valid Rank!")
            return
        end

        -- Si champ Player Name vide/par défaut => utilisation de la cible du MJ
        if (not playerName or playerName == "" or playerName == "Player Name") then
            if UnitExists("target") then
                playerName = UnitName("target")
            else
                TrinityAdmin:Print("No valid player name or target selected!")
                return
            end
        end

        -- .guild rank <PlayerName> <Rank>
        TrinityAdmin:SendCommand('.guild rank ' .. playerName .. ' ' .. rankValue)
    end)

    offsetY = offsetY - 40

    ----------------------------------------------------------------
    -- 6) GUILD RENAME
    ----------------------------------------------------------------
    local guildRenameOldEB = CreateFrame("EditBox", "$parentGuildRenameOldEB", panel, "InputBoxTemplate")
    guildRenameOldEB:SetSize(120, 20)
    guildRenameOldEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildRenameOldEB:SetAutoFocus(false)
    guildRenameOldEB:SetText("Guild Name")

    local guildRenameNewEB = CreateFrame("EditBox", "$parentGuildRenameNewEB", panel, "InputBoxTemplate")
    guildRenameNewEB:SetSize(120, 20)
    guildRenameNewEB:SetPoint("LEFT", guildRenameOldEB, "RIGHT", 10, 0)
    guildRenameNewEB:SetAutoFocus(false)
    guildRenameNewEB:SetText("New Guild Name")

    local renameButton = CreateFrame("Button", "$parentRenameButton", panel, "UIPanelButtonTemplate")
    renameButton:SetSize(80, 22)
    renameButton:SetPoint("LEFT", guildRenameNewEB, "RIGHT", 10, 0)
    renameButton:SetText("Rename")
    renameButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .guild rename \"Old Name\" \"New Name\"\n\nRename guild \"Old Name\" to \"New Name\".")
    end)
    renameButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    renameButton:SetScript("OnClick", function()
        local oldName = guildRenameOldEB:GetText()
        local newName = guildRenameNewEB:GetText()

        if (not oldName or oldName == "" or oldName == "Guild Name") then
            TrinityAdmin:Print("Please specify the current Guild Name!")
            return
        end
        if (not newName or newName == "" or newName == "New Guild Name") then
            TrinityAdmin:Print("Please specify the New Guild Name!")
            return
        end

        -- .guild rename "Old Name" "New Name"
        TrinityAdmin:SendCommand('.guild rename "' .. oldName .. '" "' .. newName .. '"')
    end)

    offsetY = offsetY - 40

    ----------------------------------------------------------------
    -- 7) GUILD UNINVITE
    ----------------------------------------------------------------
    local guildUninvitePlayerEB = CreateFrame("EditBox", "$parentGuildUninvitePlayerEB", panel, "InputBoxTemplate")
    guildUninvitePlayerEB:SetSize(120, 20)
    guildUninvitePlayerEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildUninvitePlayerEB:SetAutoFocus(false)
    guildUninvitePlayerEB:SetText("Player Name")

    local uninviteButton = CreateFrame("Button", "$parentUninviteButton", panel, "UIPanelButtonTemplate")
    uninviteButton:SetSize(80, 22)
    uninviteButton:SetPoint("LEFT", guildUninvitePlayerEB, "RIGHT", 10, 0)
    uninviteButton:SetText("Uninvite")
    uninviteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .guild uninvite <PlayerName>\r\n\r\nRemove player <PlayerName> from a guild.")
    end)
    uninviteButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    uninviteButton:SetScript("OnClick", function()
        local playerName = guildUninvitePlayerEB:GetText()

        -- Si champ Player Name vide/par défaut => utilisation de la cible du MJ
        if (not playerName or playerName == "" or playerName == "Player Name") then
            if UnitExists("target") then
                playerName = UnitName("target")
            else
                TrinityAdmin:Print("No valid player name or target selected!")
                return
            end
        end

        -- .guild uninvite <PlayerName>
        TrinityAdmin:SendCommand('.guild uninvite ' .. playerName)
    end)

    ------------------------------------------------------
    -- Enregistrer le panel dans le module
    ------------------------------------------------------
    self.panel = panel
end
