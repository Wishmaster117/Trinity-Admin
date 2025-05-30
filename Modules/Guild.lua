--------------------------------------------------------------
-- TrinityAdmin Guild Module (Guild.lua)
--------------------------------------------------------------
local L = _G.L
local TrinityAdmin = LibStub("AceAddon-3.0"):GetAddon("TrinityAdmin")
local Guild = TrinityAdmin:GetModule("Guild")
local L = LibStub("AceLocale-3.0"):GetLocale("TrinityAdmin")

-------------------------------------------------------------
-- 1) Variables pour la capture du .guild info
-------------------------------------------------------------
local capturingGuildInfo = false
local guildInfoCollected = {}
local guildInfoTimer = nil

-------------------------------------------------------------
-- capture pour ".guild create"
-------------------------------------------------------------
local capturingGuildCreate = false
local guildCreateCollected = {}
local guildCreateTimer     = nil

-------------------------------------------------------------
-- capture pour ".guild list"
-------------------------------------------------------------
local capturingGuildList = false
local guildListCollected = {}
local guildListTimer     = nil

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

---------------------------------------------------------------------
-- ParseGuildList : transforme les lignes brutes en table structurée
---------------------------------------------------------------------
local function ParseGuildList(rawLines)
    local guilds = {}

    -- On ne garde que les lignes qui commencent par un ID numérique
    for _, line in ipairs(rawLines) do
        if line:match("^%s*%d+%s*|") then
            local id, name, gm, created, members, level, bank =
                line:match("^%s*(%d+)%s*|%s*(.-)%s*|%s*(.-)%s*|%s*(%d%d%d%d%-%d%d%-%d%d)%s*|%s*(%d+)%s*|%s*(%d+)%s*|%s*(%d+)")
            if id then
                table.insert(guilds, {
                    id      = id,
                    name    = name,
                    gm      = gm,
                    created = created,
                    members = members,
                    level   = level,
                    bank    = bank,
                })
            end
        end
    end

    return guilds
end

----------------------------------------------------------------------------------------------------
-- 3) Fonction ShowGuildInfoAceGUI : crée la fenêtre AceGUI et y place des EditBox pour chaque info
----------------------------------------------------------------------------------------------------
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

    -- Rendre la fenêtre redimensionnable
    --[[
    local f = frame.frame
    f:SetResizable(true)
    f:SetMinResize(400, 300)
    f:SetScript("OnSizeChanged", function(self, w, h)
        frame:SetWidth(w)
        frame:SetHeight(h)
    end)
    ]]

    -- ScrollFrame pour scroller verticalement
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

    -- Bouton Fermer
    local btnClose = AceGUI:Create("Button")
    btnClose:SetText("Close")
    btnClose:SetWidth(80)
    btnClose:SetCallback("OnClick", function()
        frame:Hide()
    end)
    frame:AddChild(btnClose)
end
-------------------------------------------------------------
-- Fenetre pour guild create
-------------------------------------------------------------
local function ShowGuildCreateAceGUI(lines)
    local AceGUI = LibStub("AceGUI-3.0")

    -- 1) Création de la fenêtre principale
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(".guild create result")
    frame:SetStatusText("Guild Creation Infos")
    frame:SetLayout("Fill")      -- le ScrollFrame occupe tout l’espace
    frame:SetWidth(500)
    frame:SetHeight(300)
    frame:EnableResize(true)
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

    -- 2) ScrollFrame en layout List pour empiler verticalement
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("List")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    frame:AddChild(scroll)

    -- 3) Pour chaque ligne, création d’un InlineGroup + EditBox
    for i, line in ipairs(lines) do
        -- Groupe encadré avec titre "Ligne X"
        local grp = AceGUI:Create("InlineGroup")
        grp:SetTitle("Ligne " .. i)
        grp:SetFullWidth(true)
        grp:SetLayout("Fill")
        scroll:AddChild(grp)

        -- Champ texte readonly
        local eb = AceGUI:Create("EditBox")
        eb:SetText(line)
        eb:DisableButton(true)     -- enlève le bouton "OK"
        eb:SetFullWidth(true)
        grp:AddChild(eb)
    end
end

-------------------------------------------------------------
-- ShowGuildList : présentation façon « guild info »
-------------------------------------------------------------
local function ShowGuildListAceGUI(rawLines)
    local guilds  = ParseGuildList(rawLines)      -- même parseur qu’avant
    local AceGUI = LibStub("AceGUI-3.0")

    -- Fenêtre principale
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(".guild list")
    frame:SetStatusText(("Total guilds: %d"):format(#guilds))
    frame:SetLayout("Fill")
    frame:SetWidth(650)
    frame:SetHeight(520)

    -- ScrollFrame (layout List = empilement vertical)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("List")
    frame:AddChild(scroll)

    ----------------------------------------------------------------
    --  utilitaire : ajoute une paire « Label : EditBox » verrouillé
    ----------------------------------------------------------------
    local function AddRow(parent, key, value)
        -- Label
        local lbl = AceGUI:Create("Label")
        lbl:SetText("|cffffff00"..key.."|r")
        lbl:SetFullWidth(true)
        parent:AddChild(lbl)

        -- EditBox readonly
        local eb = AceGUI:Create("EditBox")
        eb:SetText(value or "")
        eb:DisableButton(true)       -- enlève le OK
        eb:SetDisabled(true)         -- non-éditable = grisé
        eb:SetFullWidth(true)
		eb.editbox:SetTextColor(1, 1, 1, 1)
        parent:AddChild(eb)
    end

    ----------------------------------------------------------------
    --  Pour chaque guilde : un Heading + 6 rangées d’infos
    ----------------------------------------------------------------
    for _, g in ipairs(guilds) do
        -- Titre centré type « Guilde « Nom » »
        local heading = AceGUI:Create("Heading")
        heading:SetFullWidth(true)
        heading:SetText(("Guilde « %s »"):format(g.name))
        scroll:AddChild(heading)

        -- Détails
        AddRow(scroll, "ID",         g.id)
        AddRow(scroll, "Guild-Master", g.gm)
        AddRow(scroll, "Created",    g.created)
        AddRow(scroll, "Members",    g.members)
        AddRow(scroll, "Level",      g.level)
        AddRow(scroll, "Bank (g)",   g.bank)
    end
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
-- 5) Frame caché pour écouter les messages serveur
-------------------------------------------------------------
local guildCaptureFrame = CreateFrame("Frame")

-- Événement(s) utilisés par TrinityCore pour les retours console
guildCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")

guildCaptureFrame:SetScript("OnEvent", function(_, _, msg)
    -- Si aucune capture n’est active, on ignore le message
    if not (capturingGuildInfo or capturingGuildCreate or capturingGuildList) then
		return
	end

    -- Nettoyage commun de la ligne
    local cleanMsg = msg
        :gsub("|c%x%x%x%x%x%x%x%x", "")  -- codes couleur
        :gsub("|r", "")
        :gsub("|H.-|h(.-)|h", "%1")      -- liens
        :gsub("|T.-|t", "")              -- textures
        :gsub("\226[\148-\149][\128-\191]", "") -- caractères boîte

    ------------------------------------------------------------------
    -- A)  Capture détaillée : ".guild info"
    ------------------------------------------------------------------
    if capturingGuildInfo then
        table.insert(guildInfoCollected, cleanMsg)

        if guildInfoTimer then guildInfoTimer:Cancel() end
        guildInfoTimer = C_Timer.NewTimer(1, function()
            capturingGuildInfo = false
            if #guildInfoCollected > 0 then
                local fullText = table.concat(guildInfoCollected, "\n")
                ShowGuildInfoAceGUI(fullText)
            else
                TrinityAdmin:Print("No guild info was captured.")
            end
        end)
    end

	------------------------------------------------------------------
	-- C)  Capture de ".guild list"
	------------------------------------------------------------------
	if capturingGuildList then
		table.insert(guildListCollected, cleanMsg)
	
		if guildListTimer then guildListTimer:Cancel() end
		guildListTimer = C_Timer.NewTimer(0.8, function()
			capturingGuildList = false
			if #guildListCollected > 0 then
				local lines = {}
				for ln in table.concat(guildListCollected, "\n"):gmatch("[^\r\n]+") do
					table.insert(lines, ln)
				end
				ShowGuildListAceGUI(lines)
			else
				TrinityAdmin:Print("No guild-list output was captured.")
			end
		end)
	end
		------------------------------------------------------------------
		-- B)  Capture succincte : ".guild create"
		------------------------------------------------------------------
		if capturingGuildCreate then
			table.insert(guildCreateCollected, cleanMsg)
	
			if guildCreateTimer then guildCreateTimer:Cancel() end
			guildCreateTimer = C_Timer.NewTimer(0.8, function()
				capturingGuildCreate = false
				if #guildCreateCollected > 0 then
					local lines = {}
					for ln in table.concat(guildCreateCollected, "\n"):gmatch("[^\r\n]+") do
						table.insert(lines, ln)
					end
					ShowGuildCreateAceGUI(lines)
				else
					TrinityAdmin:Print("No guild-create output was captured.")
				end
			end)
		end
	end)


-------------------------------------------------------------
-- 1) Définir la fonction SendCommand pour exécuter une cmd via la fenêtre de chat (ChatFrame1EditBox).
-------------------------------------------------------------
-- function TrinityAdmin:SendCommand(cmd)
--     if not cmd or cmd == "" then
--         return
--     end
--     -- On s'assure que la commande commence par un point (.)
--     if not string.match(cmd, "^%.") then
--         cmd = "." .. cmd
--     end
-- 
--     -- Envoi via la fenêtre de chat
--     local editBox = ChatFrame1EditBox
--     if not editBox then
--         self:Print("Impossible de trouver ChatFrame1EditBox pour exécuter la commande.")
--         return
--     end
-- 
--     if not editBox:IsShown() then
--         -- Ouvre la fenêtre de chat et pré-remplit avec la commande
--         ChatFrame_OpenChat(cmd, DEFAULT_CHAT_FRAME)
--     else
--         -- Si l'editBox est déjà ouvert
--         editBox:SetText(cmd)
--         ChatEdit_SendText(editBox, 0)
--     end
-- end

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
    btnBack:SetText(L["Back"])
	TrinityAdmin.AutoSize(btnBack, 20, 16)
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
    guildCreateLeaderEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildCreateLeaderEB:SetAutoFocus(false)
    guildCreateLeaderEB:SetText(L["GuildLeaderName_Name"])
	TrinityAdmin.AutoSize(guildCreateLeaderEB, 20, 13)

    local guildCreateNameEB = CreateFrame("EditBox", "$parentGuildCreateNameEB", panel, "InputBoxTemplate")
    guildCreateNameEB:SetPoint("LEFT", guildCreateLeaderEB, "RIGHT", 10, 0)
    guildCreateNameEB:SetAutoFocus(false)
    guildCreateNameEB:SetText(L["GuildName_Name"])
	TrinityAdmin.AutoSize(guildCreateNameEB, 20, 13)

    local createButton = CreateFrame("Button", "$parentCreateButton", panel, "UIPanelButtonTemplate")
    createButton:SetPoint("LEFT", guildCreateNameEB, "RIGHT", 10, 0)
    createButton:SetText(L["CreateG"])
	TrinityAdmin.AutoSize(createButton, 20, 16)
    createButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["CreateG_tooltip"], 1, 1, 1)
    end)
    createButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

	createButton:SetScript("OnClick", function()
		----------------------------------------------------------------
		-- 0) fonction « clean » : trim + retrait codes couleur
		----------------------------------------------------------------
		local function clean(s)
			s = strtrim(s or "")
			return s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
		end
	
		-- 1) Récupération & nettoyage
		local leader = clean(guildCreateLeaderEB:GetText())
		local gName  = clean(guildCreateNameEB:GetText())
	
		-- 2) Valeurs par défaut nettoyées
		local defLeader = clean(L["Guild Leader Name"])
		local defName   = clean(L["GuildName_Name"])
	
		-- 3) Tableau de validation
		local checks = {
			{ leader, defLeader, L["enter_valid_guild_leader_name_error"] },
			{ gName,  defName,   L["enter_valid_guild_name_error"]        },
		}
	
		local hasError = false
		for _, item in ipairs(checks) do
			local value, placeholder, errMsg = unpack(item)
			if value == "" or value == placeholder then
				TrinityAdmin:Print(errMsg)     -- affiche l’erreur spécifique
				hasError = true                -- on marque qu’il y a au moins une erreur
			end
		end
	
		if hasError then return end            -- on stoppe si une/des erreurs ont été trouvées
	
		-- 4) Tous les champs OK → envoi de la commande
		guildCreateCollected = {}
		capturingGuildCreate = true
		if guildCreateTimer then guildCreateTimer:Cancel() end
		TrinityAdmin:SendCommand('.guild create ' .. leader .. ' "' .. gName .. '"')
	end)

		offsetY = offsetY - 40

    ----------------------------------------------------------------
    -- 2) GUILD DELETE
    ----------------------------------------------------------------
    local guildDeleteNameEB = CreateFrame("EditBox", "$parentGuildDeleteNameEB", panel, "InputBoxTemplate")
    guildDeleteNameEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildDeleteNameEB:SetAutoFocus(false)
    guildDeleteNameEB:SetText(L["GuildName_Name"])
	TrinityAdmin.AutoSize(guildDeleteNameEB, 20, 13)

    local deleteButton = CreateFrame("Button", "$parentDeleteButton", panel, "UIPanelButtonTemplate")
    deleteButton:SetPoint("LEFT", guildDeleteNameEB, "RIGHT", 10, 0)
    deleteButton:SetText(L["DeleteG"])
	TrinityAdmin.AutoSize(deleteButton, 20, 16)
    deleteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["DeleteG_tooltip"], 1, 1, 1)
    end)
    deleteButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    deleteButton:SetScript("OnClick", function()
        local gName = guildDeleteNameEB:GetText()

        if (not gName or gName == "" or gName == L["GuildName_Name"]) then
            TrinityAdmin:Print(L["enter_valid_guild_name_delete_error"])
            return
        end

        TrinityAdmin:SendCommand('.guild delete "' .. gName .. '"')
    end)

    offsetY = offsetY - 40
	----------------------------------------------------------
	-- New Guild List
	----------------------------------------------------------
	-- Bouton "Guild List" complètement à droite
	local listButton = CreateFrame("Button", "$parentGuildListButton", panel, "UIPanelButtonTemplate")
	listButton:SetPoint("RIGHT", panel, "RIGHT", -30, 0)
	listButton:SetText(L["Guild_List"])
	TrinityAdmin.AutoSize(listButton, 20, 16)
	
	listButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(L["Guild_List_tooltip"], 1, 1, 1, 1, true)
	end)
	listButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	listButton:SetScript("OnClick", function()
		-- réinitialise la capture puis envoie la commande
		guildListCollected = {}
		capturingGuildList  = true
		if guildListTimer then guildListTimer:Cancel() end
		TrinityAdmin:SendCommand(".guild list")
	end)
    ----------------------------------------------------------------
    -- 3) GUILD INFO
    ----------------------------------------------------------------
    local guildInfoNameEB = CreateFrame("EditBox", "$parentGuildInfoNameEB", panel, "InputBoxTemplate")
    guildInfoNameEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildInfoNameEB:SetAutoFocus(false)
    guildInfoNameEB:SetText(L["Guild_ID_Info2"])
	TrinityAdmin.AutoSize(guildInfoNameEB, 20, 13)

    local infoButton = CreateFrame("Button", "$parentInfoButton", panel, "UIPanelButtonTemplate")
    infoButton:SetPoint("LEFT", guildInfoNameEB, "RIGHT", 10, 0)
    infoButton:SetText(L["InfoG2"])
	TrinityAdmin.AutoSize(infoButton, 20, 16)
    infoButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Guild ID Info_tooltip"], 1, 1, 1)
    end)
    infoButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    infoButton:SetScript("OnClick", function()
		local gName = guildInfoNameEB:GetText()
		if (not gName or gName == "" or gName == L["Guild_ID_Info2"]) then
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
    guildInvitePlayerEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildInvitePlayerEB:SetAutoFocus(false)
    guildInvitePlayerEB:SetText(L["Player Name"])
	TrinityAdmin.AutoSize(guildInvitePlayerEB, 20, 13)

    local guildInviteNameEB = CreateFrame("EditBox", "$parentGuildInviteNameEB", panel, "InputBoxTemplate")
    guildInviteNameEB:SetPoint("LEFT", guildInvitePlayerEB, "RIGHT", 10, 0)
    guildInviteNameEB:SetAutoFocus(false)
    guildInviteNameEB:SetText(L["GuildName_Name"])
	TrinityAdmin.AutoSize(guildInviteNameEB, 20, 13)

    local inviteButton = CreateFrame("Button", "$parentInviteButton", panel, "UIPanelButtonTemplate")
    inviteButton:SetPoint("LEFT", guildInviteNameEB, "RIGHT", 10, 0)
    inviteButton:SetText(L["Invite_guild_trinity"])
	TrinityAdmin.AutoSize(inviteButton, 20, 16)
    inviteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Invite_guild_tooltip"], 1, 1, 1)
    end)
    inviteButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    inviteButton:SetScript("OnClick", function()
        local playerName = guildInvitePlayerEB:GetText()
        local gName      = guildInviteNameEB:GetText()

        if (not gName or gName == "" or gName == L["GuildName_Name"]) then
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
    guildRankPlayerEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildRankPlayerEB:SetAutoFocus(false)
    guildRankPlayerEB:SetText(L["Player Name"])
	TrinityAdmin.AutoSize(guildRankPlayerEB, 20, 13)

    local guildRankValueEB = CreateFrame("EditBox", "$parentGuildRankValueEB", panel, "InputBoxTemplate")
    guildRankValueEB:SetPoint("LEFT", guildRankPlayerEB, "RIGHT", 10, 0)
    guildRankValueEB:SetAutoFocus(false)
    guildRankValueEB:SetText(L["GRank"])
	TrinityAdmin.AutoSize(guildRankValueEB, 20, 13)

    local rankButton = CreateFrame("Button", "$parentRankButton", panel, "UIPanelButtonTemplate")
    rankButton:SetPoint("LEFT", guildRankValueEB, "RIGHT", 10, 0)
    rankButton:SetText(L["Set"])
	TrinityAdmin.AutoSize(rankButton, 20, 16)
    rankButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Set_Rank_tooltip"], 1, 1, 1)
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
    guildRenameOldEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildRenameOldEB:SetAutoFocus(false)
    guildRenameOldEB:SetText(L["GuildName_Name"])
	TrinityAdmin.AutoSize(guildRenameOldEB, 20, 13)

    local guildRenameNewEB = CreateFrame("EditBox", "$parentGuildRenameNewEB", panel, "InputBoxTemplate")
    guildRenameNewEB:SetPoint("LEFT", guildRenameOldEB, "RIGHT", 10, 0)
    guildRenameNewEB:SetAutoFocus(false)
    guildRenameNewEB:SetText(L["New_GuildName_Name"])
	TrinityAdmin.AutoSize(guildRenameNewEB, 20, 13)

    local renameButton = CreateFrame("Button", "$parentRenameButton", panel, "UIPanelButtonTemplate")
    renameButton:SetPoint("LEFT", guildRenameNewEB, "RIGHT", 10, 0)
    renameButton:SetText(L["RenameG"])
	TrinityAdmin.AutoSize(renameButton, 20, 16)
    renameButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["RenameG_tooltip"], 1, 1, 1)
    end)
    renameButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    renameButton:SetScript("OnClick", function()
        local oldName = guildRenameOldEB:GetText()
        local newName = guildRenameNewEB:GetText()

        if (not oldName or oldName == "" or oldName == L["GuildName_Name"]) then
            TrinityAdmin:Print(L["enter_current_guild_name_error"])
            return
        end
        if (not newName or newName == "" or newName == L["New_GuildName_Name"]) then
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
    guildUninvitePlayerEB:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, offsetY)
    guildUninvitePlayerEB:SetAutoFocus(false)
    guildUninvitePlayerEB:SetText(L["Player Name"])
	TrinityAdmin.AutoSize(guildUninvitePlayerEB, 20, 13)

    local uninviteButton = CreateFrame("Button", "$parentUninviteButton", panel, "UIPanelButtonTemplate")
    uninviteButton:SetPoint("LEFT", guildUninvitePlayerEB, "RIGHT", 10, 0)
    uninviteButton:SetText(L["UninviteG"])
	TrinityAdmin.AutoSize(uninviteButton, 20, 16)
    uninviteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["UninviteG_tooltip"], 1, 1, 1)
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

    -- Enregistrement du panel
    self.panel = panel
end
