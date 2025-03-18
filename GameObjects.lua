local GameObjects = TrinityAdmin:GetModule("GameObjects")

-- Fonction pour afficher le panneau GameObjects
function GameObjects:ShowGameObjectsPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateGameObjectsPanel()
    end
    self.panel:Show()
end

-- Fonction pour cr�er le panneau GameObjects
function GameObjects:CreateGameObjectsPanel()
    local panel = CreateFrame("Frame", "TrinityAdminGameObjectsPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)  -- Fond sombre, modifiez selon vos besoins

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("GameObjects Panel")  -- Vous pouvez utiliser TrinityAdmin_Translations si n�cessaire

    -- Section: Game Objects Tools
local toolsTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
toolsTitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -20)
toolsTitle:SetText("Game Objects Tools")

-- Champ de saisie pour la commande sp�ciale
local specialInput = CreateFrame("EditBox", "TrinityAdminSpecialInput", panel, "InputBoxTemplate")
specialInput:SetAutoFocus(false)
specialInput:SetSize(150, 22)
specialInput:SetPoint("TOPLEFT", toolsTitle, "BOTTOMLEFT", 0, -5)
-- On lui affecte une valeur par d�faut (celle de la premi�re option)
specialInput:SetText("Enter Guid")

-- Table des options du menu d�roulant
local specialOptions = {
    { text = "gobject activate", command = ".gobject activate", defaultText = "Enter guid", tooltip = "Syntax: .gobject activate #guid\r\n\r\nActivates an object like a door or a button." },
    { text = "gobject add", command = ".gobject add", defaultText = "Enter Id Spawntime", tooltip = "Syntax: .gobject add #id <spawntimeSecs>\r\n\r\nAdd a game object from game object templates to the world at your current location using the #id.\r\nspawntimesecs sets the spawntime, it is optional.\r\n\r\nNote: this is a copy of .gameobject." },
    { text = "gobject add temp", command = ".gobject add temp", defaultText = "Enter uid or Id", tooltip = "Adds a temporary gameobject that is not saved to DB." },
    { text = "gobject delete", command = ".gobject delete", defaultText = "Enter Gobject guid", tooltip = "Syntax: .gobject delete #go_guid\r\nDelete gameobject with guid #go_guid." },
    { text = "gobject despawngroup", command = ".gobject despawngroup", defaultText = "Enter GroupId", tooltip = "Syntax: .gobject despawngroup $groupId [removerespawntime]." },
    { text = "gobject info", command = ".gobject info", defaultText = "Enter Entry or Link", tooltip = "Syntax: .gobject info [$entry|$link]\r\n\r\nQuery Gameobject information for given gameobject entry or link.\r\nFor example .gobject info 36." },
    { text = "gobject info guid", command = ".gobject info guid", defaultText = "Enter Guid or Link", tooltip = "Syntax: .gobject info guid [$guid|$link]\r\n\r\nQuery Gameobject information for given gameobject guid or link.\r\nFor example .gobject info guid 100" },
    { text = "gobject near", command = ".gobject near", defaultText = "Enter Distance", tooltip = "Syntax: .gobject near [#distance]\r\n\r\nOutput gameobjects at distance #distance from player. If #distance not provided, use 10 as default." },
    { text = "gobject set phase", command = ".gobject set phase", defaultText = "Enter Guid PhaseMask", tooltip = "Syntax: .gobject set phase #guid #phasemask\r\n\r\nGameobject with DB guid #guid phasemask changed to #phasemask and saved to DB." },
    { text = "gobject set state", command = ".gobject set state", defaultText = "Enter State", tooltip = "" },
    { text = "gobject spawngroup", command = ".gobject spawngroup", defaultText = "Enter GroupId", tooltip = "Syntax: .gobject spawngroup $groupId [ignorerespawn] [force]" },
    { text = "gobject target", command = ".gobject target", defaultText = "Enter Guid or Name part", tooltip = "Syntax: .gobject target [#go_id|#go_name_part]\r\n\r\nLocate and show position of the nearest gameobject matching the provided id or name part." },
}

	-- Cr�ation du menu d�roulant pour les options
	local specialDropdown = CreateFrame("Frame", "TrinityAdminSpecialDropdown", panel, "UIDropDownMenuTemplate")
	specialDropdown:SetPoint("LEFT", specialInput, "RIGHT", 10, 0)
	UIDropDownMenu_SetWidth(specialDropdown, 140)
	UIDropDownMenu_SetButtonWidth(specialDropdown, 240)
	-- Initialisation de la s�lection (par d�faut, la premi�re option)
	specialDropdown.selectedID = 1
	UIDropDownMenu_Initialize(specialDropdown, function(dropdownFrame, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		for i, option in ipairs(specialOptions) do
			info.text = option.text
			info.value = option.command
			info.checked = (i == specialDropdown.selectedID)
			info.func = function(buttonFrame)
				specialDropdown.selectedID = i
				UIDropDownMenu_SetSelectedID(specialDropdown, i)
				UIDropDownMenu_SetText(specialDropdown, option.text)
				specialDropdown.selectedOption = option
				-- Met � jour la valeur par d�faut du champ de saisie
				specialInput:SetText(option.defaultText)
				-- Met � jour le tooltip du champ de saisie
				specialInput:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetText(option.tooltip, 1, 1, 1, 1, true)
					GameTooltip:Show()
				end)
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end)
	-- Affiche la premi�re option
	UIDropDownMenu_SetSelectedID(specialDropdown, specialDropdown.selectedID)
	UIDropDownMenu_SetText(specialDropdown, specialOptions[specialDropdown.selectedID].text)
	specialDropdown.selectedOption = specialOptions[specialDropdown.selectedID]
	
	-- Bouton "Execute" pour lancer la commande
	local btnSpecialExecute = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnSpecialExecute:SetSize(60, 22)
	btnSpecialExecute:SetText("Execute")
	btnSpecialExecute:SetPoint("TOPLEFT", specialInput, "BOTTOMLEFT", 0, -10)
	btnSpecialExecute:SetScript("OnClick", function()
		local inputValue = specialInput:GetText()
		local option = specialDropdown.selectedOption
		local command = option.command
		local finalCommand = command .. " " .. inputValue
		if inputValue == "" or inputValue == option.defaultText then
			local targetName = UnitName("target")
			if targetName then
				finalCommand = command .. " " .. targetName
			else
				print("Veuillez saisir une valeur ou cibler un joueur.")
				return
			end
		end
		SendChatMessage(finalCommand, "SAY")
	end)
	btnSpecialExecute:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local option = specialDropdown.selectedOption or specialOptions[1]
		GameTooltip:SetText(option.tooltip, 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnSpecialExecute:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
    ------------------------------------------------------------------
    -- Section: Game Object Advanced
    ------------------------------------------------------------------
    -- Sous-titre "Game Object Advanced"
    local advLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    advLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -180)  -- Ajustez l'offset vertical selon votre layout
    advLabel:SetText("Game Object Advanced")
    
    -- Champ de saisie pour le GUID
    local advGuidEdit = CreateFrame("EditBox", "TrinityAdminAdvGuidEditBox", panel, "InputBoxTemplate")
    advGuidEdit:SetSize(150, 22)
    advGuidEdit:SetPoint("TOPLEFT", advLabel, "BOTTOMLEFT", 0, -5)
    advGuidEdit:SetText("Enter Guid")
    
    -- Champ de saisie pour X
    local advXEdit = CreateFrame("EditBox", "TrinityAdminAdvXEditBox", panel, "InputBoxTemplate")
    advXEdit:SetSize(80, 22)
    advXEdit:SetPoint("TOPLEFT", advGuidEdit, "TOPRIGHT", 10, 0)
    advXEdit:SetText("Enter X")
    
    -- Champ de saisie pour Y
    local advYEdit = CreateFrame("EditBox", "TrinityAdminAdvYEditBox", panel, "InputBoxTemplate")
    advYEdit:SetSize(80, 22)
    advYEdit:SetPoint("TOPLEFT", advXEdit, "TOPRIGHT", 10, 0)
    advYEdit:SetText("Enter Y")
    
    -- Champ de saisie pour Z
    local advZEdit = CreateFrame("EditBox", "TrinityAdminAdvZEditBox", panel, "InputBoxTemplate")
    advZEdit:SetSize(80, 22)
    advZEdit:SetPoint("TOPLEFT", advYEdit, "TOPRIGHT", 10, 0)
    advZEdit:SetText("Enter Z")
    
    -- Dropdown pour choisir l'action ("gobject move" ou "gobject turn")
    local advDropdown = CreateFrame("Frame", "TrinityAdminAdvDropdown", panel, "UIDropDownMenuTemplate")
    advDropdown:SetPoint("TOPLEFT", advGuidEdit, "BOTTOMLEFT", 0, -5)
    UIDropDownMenu_SetWidth(advDropdown, 150)
    UIDropDownMenu_SetButtonWidth(advDropdown, 170)
    local advOptions = {
        { text = "gobject move", command = ".gobject move", defaultText = "Enter Guid", tooltip = "Syntax: .gobject move #goguid [#x #y #z]\r\n\r\nMove gameobject #goguid to character coordinates (or to (#x,#y,#z) coordinates if provided)." },
        { text = "gobject turn", command = ".gobject turn", defaultText = "Enter Guid", tooltip = "Syntax: .gobject turn [guid|link] [oz [oy [ox]]]\r\n\r\nSet the orientation of the gameobject to player's orientation or the given orientation." },
    }
    if not advDropdown.selectedID then advDropdown.selectedID = 1 end
    UIDropDownMenu_Initialize(advDropdown, function(dropdownFrame, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, option in ipairs(advOptions) do
            info.text = option.text
            info.value = option.command
            info.checked = (i == advDropdown.selectedID)
            info.func = function(buttonFrame)
                advDropdown.selectedID = i
                UIDropDownMenu_SetSelectedID(advDropdown, i)
                UIDropDownMenu_SetText(advDropdown, option.text)
                advDropdown.selectedOption = option
                -- Met � jour la valeur par d�faut du champ GUID
                advGuidEdit:SetText(option.defaultText)
                -- Configure le tooltip du champ GUID
                advGuidEdit:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(option.tooltip, 1, 1, 1, 1, true)
                    GameTooltip:Show()
                end)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetSelectedID(advDropdown, advDropdown.selectedID)
    UIDropDownMenu_SetText(advDropdown, advOptions[advDropdown.selectedID].text)
    advDropdown.selectedOption = advOptions[advDropdown.selectedID]
    
    -- Bouton "Move"
    local advButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    advButton:SetSize(60, 22)
    advButton:SetText("Move")
    advButton:SetPoint("LEFT", advDropdown, "RIGHT", 10, 0)
    advButton:SetScript("OnClick", function()
        local guid = advGuidEdit:GetText()
        local x = advXEdit:GetText()
        local y = advYEdit:GetText()
        local z = advZEdit:GetText()
        local option = advDropdown.selectedOption
        local command = option.command
        if guid == "" or guid == option.defaultText then
            print("Veuillez saisir un GUID valide.")
            return
        end
        local finalCommand = command .. " " .. guid .. " " .. x .. " " .. y .. " " .. z
        print("Debug: Commande envoy�e: " .. finalCommand)  -- pour d�bug
        SendChatMessage(finalCommand, "SAY")
    end)
    advButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local opt = advDropdown.selectedOption or advOptions[1]
        GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    advButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
	
-- Supposons que GameObjectsData soit d�j� charg� et accessible

-- Cr�ation du label pour la nouvelle section
local advancedLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- Ici, remplacez "someAnchor" par l'�l�ment auquel vous voulez l'ancrer (par exemple, le titre existant)
advancedLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -200)
advancedLabel:SetText("Game Objects Tools Advanced")

-- Cr�ation d'un EditBox pour filtrer le dropdown
local filterEditBox = CreateFrame("EditBox", "TrinityAdminGOFilterEditBox", panel, "InputBoxTemplate")
filterEditBox:SetSize(150, 22)
-- Ancrez-le sous le label advancedLabel avec un l�ger offset vertical
filterEditBox:SetPoint("TOPLEFT", advancedLabel, "BOTTOMLEFT", 0, -10)
filterEditBox:SetText("Search...")

filterEditBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
    local searchText = self:GetText():lower()
    local filteredOptions = {}
    for _, option in ipairs(GameObjectsData) do
        if option.name:lower():find(searchText) then
            table.insert(filteredOptions, option)
        end
    end
    -- R�initialiser le dropdown avec la liste filtr�e
    UIDropDownMenu_Initialize(dataDropdown, function(dropdownFrame, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, option in ipairs(filteredOptions) do
            info.text = option.name
            info.value = option.entry  -- stocke l'entry
            info.checked = (i == dataDropdown.selectedID)
            info.func = function(buttonFrame)
                dataDropdown.selectedID = i
                UIDropDownMenu_SetSelectedID(dataDropdown, i)
                UIDropDownMenu_SetText(dataDropdown, option.name)
                dataDropdown.selectedOption = option
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    if #filteredOptions > 0 then
        UIDropDownMenu_SetSelectedID(dataDropdown, 1)
        UIDropDownMenu_SetText(dataDropdown, filteredOptions[1].name)
        dataDropdown.selectedOption = filteredOptions[1]
    else
        UIDropDownMenu_SetText(dataDropdown, "No match")
        dataDropdown.selectedOption = nil
    end
end)

-- Cr�ation de la dropdown aliment�e par GameObjectsData
local dataDropdown = CreateFrame("Frame", "TrinityAdminGODropdown", panel, "TrinityAdminDropdownTemplate")
dataDropdown:SetPoint("TOPLEFT", filterEditBox, "BOTTOMLEFT", 0, -5)
UIDropDownMenu_SetWidth(dataDropdown, 220)
UIDropDownMenu_SetButtonWidth(dataDropdown, 240)
-- Initialiser l'ID s�lectionn� s'il n'est pas d�j� d�fini
if not dataDropdown.selectedID then dataDropdown.selectedID = 1 end

UIDropDownMenu_Initialize(dataDropdown, function(dropdownFrame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for i, row in ipairs(GameObjectsData) do
        info.text = row.name
        info.value = row.entry  -- on stocke l'entry ici
        info.checked = (i == dataDropdown.selectedID)
        info.func = function(buttonFrame)
            dataDropdown.selectedID = i
            UIDropDownMenu_SetSelectedID(dataDropdown, i)
            UIDropDownMenu_SetText(dataDropdown, row.name)
            dataDropdown.selectedOption = row
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)
UIDropDownMenu_SetSelectedID(dataDropdown, dataDropdown.selectedID)
UIDropDownMenu_SetText(dataDropdown, GameObjectsData[dataDropdown.selectedID].name)
dataDropdown.selectedOption = GameObjectsData[dataDropdown.selectedID]

-- Cr�ation du bouton "Add" � c�t� de la dropdown
local btnAdd = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
btnAdd:SetSize(80, 22)
btnAdd:SetText("Add")
btnAdd:SetPoint("LEFT", dataDropdown, "RIGHT", 10, 0)
btnAdd:SetScript("OnClick", function()
    local selected = dataDropdown.selectedOption
    if selected then
        local command = ".gobject add " .. selected.entry
        SendChatMessage(command, "SAY")
        print("Commande envoy�e: " .. command)  -- Pour d�bug
    else
        print("Aucune option s�lectionn�e.")
    end
end)
btnAdd:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if dataDropdown.selectedOption then
        GameTooltip:SetText("Envoie la commande: .gobject add " .. dataDropdown.selectedOption.entry, 1,1,1,1,true)
    else
        GameTooltip:SetText("S�lectionnez un gameobject.", 1,1,1,1,true)
    end
    GameTooltip:Show()
end)
btnAdd:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Bouton back
    local btnBack = CreateFrame("Button", "TrinityAdminTeleportBackButton", panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)
	
    self.panel = panel
end
