local Waypoints = TrinityAdmin:GetModule("Waypoints")
local L = _G.L

-- Fonction pour afficher le panneau Waypoints
function Waypoints:ShowWaypointsPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateWaypointsPanel()
    end
    self.panel:Show()
end

---------------------------------------------------------------------------
--  A)  Variables de capture pour ".wp show"
---------------------------------------------------------------------------
local capturingWPShow = false
local wpShowCollected = {}
local wpShowTimer     = nil

--------------------------------------------------
-- Fenêtre AceGUI réutilisable
--------------------------------------------------
local function ShowWPShowAceGUI(lines)
    local AceGUI = LibStub("AceGUI-3.0")
    local frame  = AceGUI:Create("Frame")
    frame:SetTitle(".wp show result")
    frame:SetStatusText("Output of .wp show")
    frame:SetLayout("Flow")
    frame:SetWidth(600); frame:SetHeight(500)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true); scroll:SetFullHeight(true)
    frame:AddChild(scroll)

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
    btnClose:SetCallback("OnClick", function() AceGUI:Release(frame) end)
    frame:AddChild(btnClose)
end

--------------------------------------------------
-- Frame local à ce module
--------------------------------------------------
local waypointCaptureFrame = CreateFrame("Frame")
waypointCaptureFrame:RegisterEvent("CHAT_MSG_SYSTEM")
waypointCaptureFrame:SetScript("OnEvent", function(_, _, msg)
    if not capturingWPShow then return end

    -- Nettoyage minimal
    local clean = msg:gsub("|c%x%x%x%x%x%x%x%x","")
                   :gsub("|r","")
                   :gsub("|H.-|h(.-)|h","%1")
                   :gsub("|T.-|t","")
                   :gsub("\226[\148-\149][\128-\191]","")

    table.insert(wpShowCollected, clean)
    if wpShowTimer then wpShowTimer:Cancel() end

    wpShowTimer = C_Timer.NewTimer(1, function()
        capturingWPShow = false
        local lines = {}
        for line in table.concat(wpShowCollected,"\n"):gmatch("[^\r\n]+") do
            table.insert(lines, line)
        end
        ShowWPShowAceGUI(lines)
    end)
end)


-- Fonction pour créer le panneau Waypoints
function Waypoints:CreateWaypointsPanel()
    local panel = CreateFrame("Frame", "TrinityAdminWaypointsPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)
    
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre
    
    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(L["Waypoints Panel"])
    
    --------------------------------------------------------------------------------
    -- 1 - Bouton Waypoint GSP
    --------------------------------------------------------------------------------
    local btnWpgps = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnWpgps:SetSize(120, 24)
    btnWpgps:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -40)
    btnWpgps:SetText(L["Waypoint GSP"])
	TrinityAdmin.AutoSize(btnWpgps, 20, 16)
    btnWpgps:SetScript("OnClick", function()
        SendChatMessage(".wpgps", "SAY")
        -- print("[DEBUG] .wpgps envoyé.")
    end)
    btnWpgps:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Output_current_position_to_SQL_developer"], 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnWpgps:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	--------------------------------------------------------------------------------
    -- 1.5 - Bouton Movegen
    --------------------------------------------------------------------------------
    local btnmovegens = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnmovegens:SetSize(120, 24)
    btnmovegens:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -40, -40)
    btnmovegens:SetText(L["Movegens"])
	TrinityAdmin.AutoSize(btnmovegens, 20, 16)
    btnmovegens:SetScript("OnClick", function()
	    		wpShowCollected = {}
		capturingWPShow = true
		if wpShowTimer then wpShowTimer:Cancel() end
        SendChatMessage(".movegens", "SAY")
        -- print("[DEBUG] .wpgps envoyé.")
    end)
    btnmovegens:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Show_movement_generators"], 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnmovegens:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- 2 - Bouton Waypoint Add
    --------------------------------------------------------------------------------
    local btnWpAdd = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnWpAdd:SetSize(120, 24)
    btnWpAdd:SetPoint("TOPLEFT", btnWpgps, "BOTTOMLEFT", 0, -10)
    btnWpAdd:SetText(L["Waypoint Add"])
	TrinityAdmin.AutoSize(btnWpAdd, 20, 16)
    btnWpAdd:SetScript("OnClick", function()
        if not UnitExists("target") then
            print(L["please_select_npc"])
            return
        end
        SendChatMessage(".wp add", "SAY")
        --print("[DEBUG] .wp add envoyé.")
    end)
    btnWpAdd:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Add_waypoint_for_selected_creature"], 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnWpAdd:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- 3 - wp load : Champ de saisie + bouton Load
    --------------------------------------------------------------------------------
    local wpLoadEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    -- wpLoadEdit:SetSize(80, 20)
    wpLoadEdit:SetPoint("TOPLEFT", btnWpAdd, "BOTTOMLEFT", 0, -10)
    wpLoadEdit:SetAutoFocus(false)
    wpLoadEdit:SetText(L["Path ID"])
	TrinityAdmin.AutoSize(wpLoadEdit, 20, 13)
    
    local btnWpLoad = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnWpLoad:SetSize(80, 24)
    btnWpLoad:SetPoint("LEFT", wpLoadEdit, "RIGHT", 10, 0)
    btnWpLoad:SetText(L["Load"])
	TrinityAdmin.AutoSize(btnWpLoad, 20, 16)
    btnWpLoad:SetScript("OnClick", function()
        if not UnitExists("target") then
            print(L["please_select_npc"])
            return
        end
        local pathID = wpLoadEdit:GetText()
        if pathID == "" or pathID == "Path ID" then
            print(L["Error_enter_PathID"])
            return
        end
        SendChatMessage(".wp load " .. pathID, "SAY")
        -- print("[DEBUG] .wp load " .. pathID .. " envoyé.")
    end)
    btnWpLoad:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["pathid_explain"], 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnWpLoad:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- 4 - wp reload : Champ de saisie + bouton ReLoad
    --------------------------------------------------------------------------------
    local wpReloadEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    -- wpReloadEdit:SetSize(80, 20)
    wpReloadEdit:SetPoint("TOPLEFT", wpLoadEdit, "BOTTOMLEFT", 0, -10)
    wpReloadEdit:SetAutoFocus(false)
    wpReloadEdit:SetText(L["Path ID"])
	TrinityAdmin.AutoSize(wpReloadEdit, 20, 13)
    
    local btnWpReload = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnWpReload:SetSize(80, 24)
    btnWpReload:SetPoint("LEFT", wpReloadEdit, "RIGHT", 10, 0)
    btnWpReload:SetText(L["ReLoad"])
	TrinityAdmin.AutoSize(btnWpReload, 20, 16)
    btnWpReload:SetScript("OnClick", function()
        if not UnitExists("target") then
            print(L["please_select_npc"])
            return
        end
        local pathID = wpReloadEdit:GetText()
        if pathID == "" or pathID == "Path ID" then
            print(L["error_pathid_missing"])
            return
        end
        SendChatMessage(".wp reload " .. pathID, "SAY")
        --print("[DEBUG] .wp reload " .. pathID .. " envoyé.")
    end)
    btnWpReload:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["load_pathir_explain"], 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnWpReload:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- 5 - wp unload : Bouton Waypoint Unload
    --------------------------------------------------------------------------------
    local btnWpUnload = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnWpUnload:SetSize(120, 24)
    btnWpUnload:SetPoint("TOPLEFT", wpReloadEdit, "BOTTOMLEFT", 0, -20)
    btnWpUnload:SetText(L["Waypoint Unload"])
	TrinityAdmin.AutoSize(btnWpUnload, 20, 16)
    btnWpUnload:SetScript("OnClick", function()
        if not UnitExists("target") then
            print(L["please_select_npc"])
            return
        end
        SendChatMessage(".wp unload", "SAY")
        -- print("[DEBUG] .wp unload envoyé.")
    end)
    btnWpUnload:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["waypoint_unload_explain"], nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    btnWpUnload:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- 6 - wp show : Dropdown + EditBox + Bouton Show
    --------------------------------------------------------------------------------
    local wpShowOptions = {
        { text = ".wp show on", value = "on", tooltip = L["display_full_waypoint_explain"] },
        { text = ".wp show first", value = "first", tooltip = L["disply_only_fisrt_wp"] },
        { text = ".wp show last", value = "last", tooltip = L["disply_only_wp_path"] },
        { text = ".wp show off", value = "off", tooltip = L["hide_all_path"] },
        { text = ".wp show info", value = "info", tooltip = L["display_detailed_wp"] },
    }
    
    local wpShowDropdown = CreateFrame("Frame", "WPShowDropdown", panel, "UIDropDownMenuTemplate")
    wpShowDropdown:SetPoint("TOPLEFT", btnWpUnload, "BOTTOMLEFT", -13, -25)
    UIDropDownMenu_SetWidth(wpShowDropdown, 150)
    UIDropDownMenu_Initialize(wpShowDropdown, function(self, level, menuList)
        for i, option in ipairs(wpShowOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.text
            info.value = option.value
            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(wpShowDropdown, button.value)
            end
            info.tooltipTitle = option.text
            info.tooltipText = option.tooltip
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(wpShowDropdown, ".wp show options")
    
    local wpShowEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    -- wpShowEdit:SetSize(80, 20)
    wpShowEdit:SetPoint("TOPLEFT", wpShowDropdown, "TOPRIGHT", 5, -1)
    wpShowEdit:SetAutoFocus(false)
    wpShowEdit:SetText(L["Path ID"])
	TrinityAdmin.AutoSize(wpShowEdit, 20, 13)
    
    local btnWpShowExecute = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    -- btnWpShowExecute:SetSize(80, 24)
    btnWpShowExecute:SetPoint("TOPLEFT", wpShowEdit, "TOPRIGHT", 10, 2)
    btnWpShowExecute:SetText(L["Show"])
	TrinityAdmin.AutoSize(btnWpShowExecute, 20, 16)
    btnWpShowExecute:SetScript("OnClick", function()
        local option = UIDropDownMenu_GetSelectedValue(wpShowDropdown)
        local pathID = wpShowEdit:GetText()
        local command = ".wp show"
        if option and option ~= "off" then
            command = command .. " " .. option
            if pathID ~= "" and pathID ~= "Path ID" then
                command = command .. " " .. pathID
            end
        elseif option == "off" then
            command = command .. " off"
        end
        if not UnitExists("target") and option ~= "off" then
            print(L["please_select_npc"])
            return
        end
		wpShowCollected = {}
		capturingWPShow = true
		if wpShowTimer then wpShowTimer:Cancel() end
		
        SendChatMessage(command, "SAY")
        -- print("[DEBUG] Commande envoyée: " .. command)
    end)
    btnWpShowExecute:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["show_wp_explain"], 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnWpShowExecute:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- Bouton Back (commun) du panneau Waypoints
    --------------------------------------------------------------------------------
    local btnBack = CreateFrame("Button", "TrinityAdminWaypointsBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(L["Back"])
	TrinityAdmin.AutoSize(btnBack, 20, 16)
    -- btnBack:SetHeight(22)
    -- btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)
    
    self.panel = panel
end
