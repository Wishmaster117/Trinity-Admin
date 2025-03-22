local Waypoints = TrinityAdmin:GetModule("Waypoints")

-- Fonction pour afficher le panneau Waypoints
function Waypoints:ShowWaypointsPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateWaypointsPanel()
    end
    self.panel:Show()
end

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
    panel.title:SetText("Waypoints Panel")
    
    --------------------------------------------------------------------------------
    -- 1 - Bouton Waypoint GSP
    --------------------------------------------------------------------------------
    local btnWpgps = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnWpgps:SetSize(120, 24)
    btnWpgps:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -40)
    btnWpgps:SetText("Waypoint GSP")
    btnWpgps:SetScript("OnClick", function()
        SendChatMessage(".wpgps", "SAY")
        print("[DEBUG] .wpgps envoyé.")
    end)
    btnWpgps:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .wpgps\n\nOutput current position to SQL developer log as partial SQL query to be used in pathing", nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    btnWpgps:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- 2 - Bouton Waypoint Add
    --------------------------------------------------------------------------------
    local btnWpAdd = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnWpAdd:SetSize(120, 24)
    btnWpAdd:SetPoint("TOPLEFT", btnWpgps, "BOTTOMLEFT", 0, -10)
    btnWpAdd:SetText("Waypoint Add")
    btnWpAdd:SetScript("OnClick", function()
        if not UnitExists("target") then
            print("Erreur: Aucun PNJ ciblé.")
            return
        end
        SendChatMessage(".wp add", "SAY")
        print("[DEBUG] .wp add envoyé.")
    end)
    btnWpAdd:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .wp add\n\nAdd a waypoint for the selected creature at your current position.", nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    btnWpAdd:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- 3 - wp load : Champ de saisie + bouton Load
    --------------------------------------------------------------------------------
    local wpLoadEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    wpLoadEdit:SetSize(80, 20)
    wpLoadEdit:SetPoint("TOPLEFT", btnWpAdd, "BOTTOMLEFT", 0, -10)
    wpLoadEdit:SetAutoFocus(false)
    wpLoadEdit:SetText("Path ID")
    
    local btnWpLoad = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnWpLoad:SetSize(80, 24)
    btnWpLoad:SetPoint("LEFT", wpLoadEdit, "RIGHT", 10, 0)
    btnWpLoad:SetText("Load")
    btnWpLoad:SetScript("OnClick", function()
        if not UnitExists("target") then
            print("Erreur: Aucun PNJ ciblé.")
            return
        end
        local pathID = wpLoadEdit:GetText()
        if pathID == "" or pathID == "Path ID" then
            print("Erreur: Veuillez renseigner un Path ID.")
            return
        end
        SendChatMessage(".wp load " .. pathID, "SAY")
        print("[DEBUG] .wp load " .. pathID .. " envoyé.")
    end)
    btnWpLoad:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .wp load $pathid\nLoad pathid number for selected creature. Creature must have no waypoint data.", nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    btnWpLoad:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- 4 - wp reload : Champ de saisie + bouton ReLoad
    --------------------------------------------------------------------------------
    local wpReloadEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    wpReloadEdit:SetSize(80, 20)
    wpReloadEdit:SetPoint("TOPLEFT", wpLoadEdit, "BOTTOMLEFT", 0, -10)
    wpReloadEdit:SetAutoFocus(false)
    wpReloadEdit:SetText("Path ID")
    
    local btnWpReload = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnWpReload:SetSize(80, 24)
    btnWpReload:SetPoint("LEFT", wpReloadEdit, "RIGHT", 10, 0)
    btnWpReload:SetText("ReLoad")
    btnWpReload:SetScript("OnClick", function()
        if not UnitExists("target") then
            print("Erreur: Aucun PNJ ciblé.")
            return
        end
        local pathID = wpReloadEdit:GetText()
        if pathID == "" or pathID == "Path ID" then
            print("Erreur: Veuillez renseigner un Path ID.")
            return
        end
        SendChatMessage(".wp reload " .. pathID, "SAY")
        print("[DEBUG] .wp reload " .. pathID .. " envoyé.")
    end)
    btnWpReload:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .wp reload $pathid\nLoad path changes ingame - IMPORTANT: must be applied first for new paths before .wp load #pathid", nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    btnWpReload:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- 5 - wp unload : Bouton Waypoint Unload
    --------------------------------------------------------------------------------
    local btnWpUnload = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnWpUnload:SetSize(120, 24)
    btnWpUnload:SetPoint("TOPLEFT", wpReloadEdit, "BOTTOMLEFT", 0, -10)
    btnWpUnload:SetText("Waypoint Unload")
    btnWpUnload:SetScript("OnClick", function()
        if not UnitExists("target") then
            print("Erreur: Aucun PNJ ciblé.")
            return
        end
        SendChatMessage(".wp unload", "SAY")
        print("[DEBUG] .wp unload envoyé.")
    end)
    btnWpUnload:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Syntax: .wp unload\nUnload path for selected creature.", nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    btnWpUnload:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- 6 - wp show : Dropdown + EditBox + Bouton Show
    --------------------------------------------------------------------------------
    local wpShowOptions = {
        { text = ".wp show on", value = "on", tooltip = "Syntax: .wp show on $pathid\nDisplay the full waypoint path for the specified path ID.\nIf no path ID, works on selected creature with loaded path." },
        { text = ".wp show first", value = "first", tooltip = "Syntax: .wp show first $pathid\nDisplay only the first waypoint of the path." },
        { text = ".wp show last", value = "last", tooltip = "Syntax: .wp show last $pathid\nDisplay only the last waypoint of the path." },
        { text = ".wp show off", value = "off", tooltip = "Syntax: .wp show off\nHide all displayed paths." },
        { text = ".wp show info", value = "info", tooltip = "Syntax: .wp show info $selected_waypoint\nDisplay detailed info of the selected waypoint." },
    }
    
    local wpShowDropdown = CreateFrame("Frame", "WPShowDropdown", panel, "UIDropDownMenuTemplate")
    wpShowDropdown:SetPoint("TOPLEFT", btnWpUnload, "BOTTOMLEFT", 0, -10)
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
    wpShowEdit:SetSize(80, 20)
    wpShowEdit:SetPoint("TOPLEFT", wpShowDropdown, "TOPRIGHT", 10, 0)
    wpShowEdit:SetAutoFocus(false)
    wpShowEdit:SetText("Path ID")
    
    local btnWpShowExecute = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnWpShowExecute:SetSize(80, 24)
    btnWpShowExecute:SetPoint("TOPLEFT", wpShowEdit, "TOPRIGHT", 10, 0)
    btnWpShowExecute:SetText("Show")
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
            print("Erreur: Aucun PNJ ciblé pour wp show (sauf pour 'off').")
            return
        end
        SendChatMessage(command, "SAY")
        print("[DEBUG] Commande envoyée: " .. command)
    end)
    btnWpShowExecute:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Executes the .wp show command with the selected option and path ID (if provided).", nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    btnWpShowExecute:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    --------------------------------------------------------------------------------
    -- Bouton Back (commun) du panneau Waypoints
    --------------------------------------------------------------------------------
    local btnBack = CreateFrame("Button", "TrinityAdminWaypointsBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)
    
    self.panel = panel
end
