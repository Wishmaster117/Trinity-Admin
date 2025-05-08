--------------------------------------------------------------
-- TrinityAdmin Guild Module (Guild.lua) - version ACEGUI
--------------------------------------------------------------

local Guild = TrinityAdmin:GetModule("Guild")
local L = _G.L
-------------------------------------------------------------
-- 1) Variables pour la capture du .guild info
-------------------------------------------------------------
local capturingGuildInfo = false
local guildInfoCollected = {}
local guildInfoTimer = nil

-------------------------------------------------------------
-- 2) ParseGuildInfo : extrait les infos clés depuis le texte
-------------------------------------------------------------
local function ParseGuildInfo(fullText)
    -- On va découper en lignes
    local lines = {}
    for line in fullText:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    -- Table de paires (label, value) à retourner
    local infoTable = {}

    -- Variables qu'on veut extraire
    local guildName, guildID = "", ""
    local guildMaster = ""
    local creationDate = ""
    local members = ""
    local bank = ""
    local level = ""
    local motd = ""
    local guildInfo = ""

    -- On parcourt chaque ligne et on fait des match
    for _, line in ipairs(lines) do
        line = line:match("^%s*(.-)%s*$")  -- trim

        -- Ex : "Displaying Guild Details for Banana Split (Id: 6)"
        local name, id = line:match("Displaying Guild Details for (.+) %(Id:%s*(%d+)%)")
        if name and id then
            guildName = name
            guildID = id
        end

        -- Ex : "Guild Master: Banana (Player-1-00000004)"
        local gm = line:match("Guild Master:%s*(.+)")
        if gm then
            guildMaster = gm
        end

        -- Ex : "Guild Creation Date: 2025-03-23 15:57:04"
        local cdate = line:match("Guild Creation Date:%s*(.+)")
        if cdate then
            creationDate = cdate
        end

        -- Ex : "Guild Members: 1"
        local mem = line:match("Guild Members:%s*(%d+)")
        if mem then
            members = mem
        end

        -- Ex : "Guild Bank: 0 gold"
        local bk = line:match("Guild Bank:%s*(.+)")
        if bk then
            bank = bk
        end

        -- Ex : "Guild Level: 25"
        local lvl = line:match("Guild Level:%s*(%d+)")
        if lvl then
            level = lvl
        end

        -- Ex : "Guild MOTD: No message set."
        local m = line:match("Guild MOTD:%s*(.*)")
        if m then
            motd = m
        end

        -- Ex : "Guild Information:" => les lignes suivantes ?
        -- Souvent c'est vide ou multi-lignes, ici on suppose c'est la même ligne
        local gi = line:match("Guild Information:%s*(.*)")
        if gi then
            guildInfo = gi
        end
    end

    -- Remplir infoTable
    table.insert(infoTable, { label="Guild Name",       value=guildName })
    table.insert(infoTable, { label="Guild ID",         value=guildID })
    table.insert(infoTable, { label="Guild Master",     value=guildMaster })
    table.insert(infoTable, { label="Creation Date",    value=creationDate })
    table.insert(infoTable, { label="Members",          value=members })
    table.insert(infoTable, { label="Bank",             value=bank })
    table.insert(infoTable, { label="Level",            value=level })
    table.insert(infoTable, { label="MOTD",             value=motd })
    table.insert(infoTable, { label="Guild Info",       value=guildInfo })

    return infoTable
end

-------------------------------------------------------------
-- 3) Fonction ShowGuildInfoAceGUI : crée la fenêtre AceGUI
--    et y place des EditBox pour chaque info
-------------------------------------------------------------
local AceGUI = LibStub("AceGUI-3.0")

local function ShowGuildInfoAceGUI(fullText)
    -- Parse
    local infoTable = ParseGuildInfo(fullText)

    -- Crée la fenêtre
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["Guild Info"])
    frame:SetStatusText(L["Information about the guild"])
    frame:SetLayout("Flow")
    frame:SetWidth(500)
    frame:SetHeight(400)

    -- (Optionnel) Rendez la fenêtre redimensionnable
    --[[
    local f = frame.frame
    f:SetResizable(true)
    f:SetMinResize(400, 300)
    f:SetScript("OnSizeChanged", function(self, w, h)
        frame:SetWidth(w)
        frame:SetHeight(h)
    end)
    ]]

    -- On peut mettre un ScrollFrame si on veut scroller verticalement
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    frame:AddChild(scroll)

    -- Petite fonction utilitaire pour ajouter un EditBox
    local function AddEditBox(lbl, val)
        local edit = AceGUI:Create("EditBox")
        edit:SetLabel("|cffffff00"..lbl.."|r")
        edit:SetText(val or "")
        edit:SetFullWidth(true)  -- prend toute la largeur
        scroll:AddChild(edit)
    end

    -- Parcourt infoTable et crée un EditBox par champ
    for _, row in ipairs(infoTable) do
        AddEditBox(row.label, row.value)
    end

    -- Bouton Fermer (optionnel, la croix existe déjà)
    local btnClose = AceGUI:Create("Button")
    btnClose:SetText("Close")
    btnClose:SetWidth(80)
    btnClose:SetCallback("OnClick", function()
        frame:Hide()
    end)
    frame:AddChild(btnClose)
end

-------------------------------------------------------------
-- 4) FinishGuildInfoCapture : quand la capture se termine,
--    on ouvre la fenêtre AceGUI
-------------------------------------------------------------
local function FinishGuildInfoCapture()
    capturingGuildInfo = false
    if #guildInfoCollected > 0 then
        local fullText = table.concat(guildInfoCollected, "\n")
        ShowGuildInfoAceGUI(fullText)
    else
        TrinityAdmin:Print("No guild info was captured.")
    end
end

-------------------------------------------------------------
-- 5) Frame caché pour écouter CHAT_MSG_SYSTEM
-------------------------------------------------------------
local guildCaptureFrame = CreateFrame("Frame")
guildCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
guildCaptureFrame:SetScript("OnEvent", function(self, event, msg)
    if not capturingGuildInfo then
        return
    end
    
    local cleanMsg = msg
    cleanMsg = cleanMsg:gsub("|c%x%x%x%x%x%x%x%x", "")
    cleanMsg = cleanMsg:gsub("|r", "")
    cleanMsg = cleanMsg:gsub("|H.-|h(.-)|h", "%1")
    cleanMsg = cleanMsg:gsub("|T.-|t", "")
    cleanMsg = cleanMsg:gsub("\226[\148-\149][\128-\191]", "")

    table.insert(guildInfoCollected, cleanMsg)

    if guildInfoTimer then guildInfoTimer:Cancel() end
    guildInfoTimer = C_Timer.NewTimer(1, FinishGuildInfoCapture)
end)

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
    panel.title:SetText(L["Guild's Management"])

    ------------------------------------------------------
    -- Bouton "Back" pour revenir au menu principal
    ------------------------------------------------------
    local btnBack = CreateFrame("Button", "TrinityAdminTeleportBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", 0, 10)
    btnBack:SetText(L["Back"] or "Back")
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
    guildCreateLeaderEB:SetText(L["Guild Leader Name"])

    local guildCreateNameEB = CreateFrame("EditBox", "$parentGuildCreateNameEB", panel, "InputBoxTemplate")
    guildCreateNameEB:SetSize(120, 20)
    guildCreateNameEB:SetPoint("LEFT", guildCreateLeaderEB, "RIGHT", 10, 0)
    guildCreateNameEB:SetAutoFocus(false)
    guildCreateNameEB:SetText(L["Guild Name"])

    local createButton = CreateFrame("Button", "$parentCreateButton", panel, "UIPanelButtonTemplate")
    createButton:SetSize(80, 22)
    createButton:SetPoint("LEFT", guildCreateNameEB, "RIGHT", 10, 0)
    createButton:SetText(L["CreateG"])
    createButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["CreateG_tooltip"])
    end)
    createButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    createButton:SetScript("OnClick", function()
        local leader = guildCreateLeaderEB:GetText()
        local gName  = guildCreateNameEB:GetText()

        if (not leader or leader == "" or leader == L["Guild Leader Name"]) then
            TrinityAdmin:print(L["enter_valid_guild_leader_name_error"])
            return
        end
        if (not gName or gName == "" or gName == L["Guild Name"]) then
            TrinityAdmin:print(L["enter_valid_guild_name_error"])
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
    guildDeleteNameEB:SetText(L["Guild Name"])

    local deleteButton = CreateFrame("Button", "$parentDeleteButton", panel, "UIPanelButtonTemplate")
    deleteButton:SetSize(80, 22)
    deleteButton:SetPoint("LEFT", guildDeleteNameEB, "RIGHT", 10, 0)
    deleteButton:SetText(L["DeleteG"])
    deleteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["DeleteG_tooltip"])
    end)
    deleteButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    deleteButton:SetScript("OnClick", function()
        local gName = guildDeleteNameEB:GetText()

        if (not gName or gName == "" or gName == L["Guild Name"]) then
            TrinityAdmin:Print(L["enter_valid_guild_name_delete_error"])
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
    guildInfoNameEB:SetText(L["Guild ID Info"])

    local infoButton = CreateFrame("Button", "$parentInfoButton", panel, "UIPanelButtonTemplate")
    infoButton:SetSize(80, 22)
    infoButton:SetPoint("LEFT", guildInfoNameEB, "RIGHT", 10, 0)
    infoButton:SetText(L["InfoG2"])
    infoButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Guild ID Info_tooltip"])
    end)
    infoButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    infoButton:SetScript("OnClick", function()
		local gName = guildInfoNameEB:GetText()
		if (not gName or gName == "" or gName == L["Guild ID Info"]) then
			TrinityAdmin:Print(L["enter_valid_guild_id_info_error"])
			return
		end

        -- 1) On efface l'ancien texte et vide la table
        guildInfoCollected = {}

        -- 2) Active le mode capture
        capturingGuildInfo = true

        -- 3) Envoie la commande
        TrinityAdmin:SendCommand('.guild info ' .. gName)

        -- 4) Lance un timer pour clôturer la capture s'il n'y a plus de message
        if guildInfoTimer then
            guildInfoTimer:Cancel()
        end
        guildInfoTimer = C_Timer.NewTimer(1, FinishGuildInfoCapture)
    end)

    offsetY = offsetY - 40

    ----------------------------------------------------------------
    -- 4) GUILD INVITE
    ----------------------------------------------------------------
    local guildInvitePlayerEB = CreateFrame("EditBox", "$parentGuildInvitePlayerEB", panel, "InputBoxTemplate")
    guildInvitePlayerEB:SetSize(120, 20)
    guildInvitePlayerEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildInvitePlayerEB:SetAutoFocus(false)
    guildInvitePlayerEB:SetText(L["Player Name"])

    local guildInviteNameEB = CreateFrame("EditBox", "$parentGuildInviteNameEB", panel, "InputBoxTemplate")
    guildInviteNameEB:SetSize(120, 20)
    guildInviteNameEB:SetPoint("LEFT", guildInvitePlayerEB, "RIGHT", 10, 0)
    guildInviteNameEB:SetAutoFocus(false)
    guildInviteNameEB:SetText(L["Guild Name"])

    local inviteButton = CreateFrame("Button", "$parentInviteButton", panel, "UIPanelButtonTemplate")
    inviteButton:SetSize(80, 22)
    inviteButton:SetPoint("LEFT", guildInviteNameEB, "RIGHT", 10, 0)
    inviteButton:SetText(L["Invite_guild"])
    inviteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Invite_guild_tooltip"])
    end)
    inviteButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    inviteButton:SetScript("OnClick", function()
        local playerName = guildInvitePlayerEB:GetText()
        local gName      = guildInviteNameEB:GetText()

        if (not gName or gName == "" or gName == L["Guild Name"]) then
            TrinityAdmin:Print(L["enter_valid_guild_name_invite_error"])
            return
        end

        -- Si champ Player Name vide/par défaut => utilisation de la cible du MJ
        if (not playerName or playerName == "" or playerName == L["Player Name"]) then
            if UnitExists("target") then
                playerName = UnitName("target")
            else
                TrinityAdmin:Print(L["no_valid_player_or_target_error"])
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
    guildRankPlayerEB:SetText(L["Player Name"])

    local guildRankValueEB = CreateFrame("EditBox", "$parentGuildRankValueEB", panel, "InputBoxTemplate")
    guildRankValueEB:SetSize(120, 20)
    guildRankValueEB:SetPoint("LEFT", guildRankPlayerEB, "RIGHT", 10, 0)
    guildRankValueEB:SetAutoFocus(false)
    guildRankValueEB:SetText(L["GRank"])

    local rankButton = CreateFrame("Button", "$parentRankButton", panel, "UIPanelButtonTemplate")
    rankButton:SetSize(80, 22)
    rankButton:SetPoint("LEFT", guildRankValueEB, "RIGHT", 10, 0)
    rankButton:SetText(L["Set"])
    rankButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Set_Rank_tooltip"])
    end)
    rankButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    rankButton:SetScript("OnClick", function()
        local playerName = guildRankPlayerEB:GetText()
        local rankValue  = guildRankValueEB:GetText()

        if (not rankValue or rankValue == "" or rankValue == L["GRank"]) then
            TrinityAdmin:Print(L["enter_valid_rank_error"])
            return
        end

        -- Si champ Player Name vide/par défaut => utilisation de la cible du MJ
        if (not playerName or playerName == "" or playerName == L["Player Name"]) then
            if UnitExists("target") then
                playerName = UnitName("target")
            else
                TrinityAdmin:Print(L["no_valid_player_or_target_error"])
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
    guildRenameOldEB:SetText(L["Guild Name"])

    local guildRenameNewEB = CreateFrame("EditBox", "$parentGuildRenameNewEB", panel, "InputBoxTemplate")
    guildRenameNewEB:SetSize(120, 20)
    guildRenameNewEB:SetPoint("LEFT", guildRenameOldEB, "RIGHT", 10, 0)
    guildRenameNewEB:SetAutoFocus(false)
    guildRenameNewEB:SetText(L["New Guild Name"])

    local renameButton = CreateFrame("Button", "$parentRenameButton", panel, "UIPanelButtonTemplate")
    renameButton:SetSize(80, 22)
    renameButton:SetPoint("LEFT", guildRenameNewEB, "RIGHT", 10, 0)
    renameButton:SetText(L["RenameG"])
    renameButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["RenameG_tooltip"])
    end)
    renameButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    renameButton:SetScript("OnClick", function()
        local oldName = guildRenameOldEB:GetText()
        local newName = guildRenameNewEB:GetText()

        if (not oldName or oldName == "" or oldName == L["Guild Name"]) then
            TrinityAdmin:Print(L["enter_current_guild_name_error"])
            return
        end
        if (not newName or newName == "" or newName == L["New Guild Name"]) then
            TrinityAdmin:Print(L["enter_new_guild_name_error"])
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
    guildUninvitePlayerEB:SetText(L["Player Name"])

    local uninviteButton = CreateFrame("Button", "$parentUninviteButton", panel, "UIPanelButtonTemplate")
    uninviteButton:SetSize(80, 22)
    uninviteButton:SetPoint("LEFT", guildUninvitePlayerEB, "RIGHT", 10, 0)
    uninviteButton:SetText(L["UninviteG"])
    uninviteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["UninviteG_tooltip"])
    end)
    uninviteButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    uninviteButton:SetScript("OnClick", function()
        local playerName = guildUninvitePlayerEB:GetText()

        -- Si champ Player Name vide/par défaut => utilisation de la cible du MJ
        if (not playerName or playerName == "" or playerName == L["Player Name"]) then
            if UnitExists("target") then
                playerName = UnitName("target")
            else
                TrinityAdmin:Print(L["no_valid_player_or_target_error"])
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
