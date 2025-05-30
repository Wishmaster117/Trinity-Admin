local AccountModule = TrinityAdmin:GetModule("AccountPanel")
local L = _G.L

function AccountModule:ShowAccountPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAccountPanel()
    end
    self.panel:Show()
end

function AccountModule:CreateAccountPanel()
    -- Création du panneau principal
    local account = CreateFrame("Frame", "TrinityAdminAccountPanel", TrinityAdminMainFrame)
    account:ClearAllPoints()
    account:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    account:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = account:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    account.title = account:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    account.title:SetPoint("TOPLEFT", 10, -10)
    account.title:SetText(L["Account_Panel"])

    ------------------------------------------------------------------------------
    -- Système de pages
    ------------------------------------------------------------------------------
    local totalPages = 2  -- nombre total de pages
	local currentPage = 1
    local pages = {}
    for i = 1, totalPages do
        pages[i] = CreateFrame("Frame", nil, account)
        pages[i]:SetAllPoints(account)
        pages[i]:Hide()  -- on cache toutes les pages dès le départ
    end

    local pageLabel = account:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pageLabel:SetPoint("BOTTOM", account, "BOTTOM", 0, 10)
	pageLabel:SetText(L["Page"] .. " " .. currentPage .. " / " .. totalPages)
	
	-- 1) On déclare les boutons de navigation
    local btnPrev, btnNext
	
    local function ShowPage(pageIndex)
        for i = 1, totalPages do
            if i == pageIndex then
                pages[i]:Show()
            else
                pages[i]:Hide()
            end
        end
        pageLabel:SetText("Page " .. pageIndex .. " / " .. totalPages)
		
		-- 2) activation ou désactivation des boutons
        if pageIndex <= 1 then
            btnPrev:Disable()
        else
            btnPrev:Enable()
        end
 
        if pageIndex >= totalPages then
            btnNext:Disable()
        else
            btnNext:Enable()
        end
    end

	btnPrev = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    btnPrev:SetText(L["Pagination_Preview"])
	TrinityAdmin.AutoSize(btnPrev, 20, 16)
    btnPrev:SetPoint("BOTTOMLEFT", account, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            ShowPage(currentPage)
        end
    end)

	btnNext = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    btnNext:SetText(L["Next"])
	TrinityAdmin.AutoSize(btnNext, 20, 16)
    btnNext:SetPoint("BOTTOMRIGHT", account, "BOTTOMRIGHT", -10, 10)
    btnNext:SetScript("OnClick", function()
        if currentPage < totalPages then
            currentPage = currentPage + 1
            ShowPage(currentPage)
        end
    end)

	-- 3) initialiser l'état des boutons
    ShowPage(currentPage)

    ------------------------------------------------------------------------------
    -- PAGE 1
    ------------------------------------------------------------------------------
    local commandsFramePage1 = CreateFrame("Frame", nil, pages[1])
    commandsFramePage1:SetPoint("TOPLEFT", pages[1], "TOPLEFT", 10, -10)
    commandsFramePage1:SetSize(500, 350)

    local currentY1 = -30
    local function NextPosition1(height)
        local pos = currentY1
        currentY1 = currentY1 - height - 5
        return pos
    end
	
    local page1Title = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    page1Title:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, NextPosition1(10))
    page1Title:SetText(L["Account Creation"])

    -- EditBox pour l'Account
    local accountEditBox = CreateFrame("EditBox", "TrinityAdminAccountEditBox", commandsFramePage1, "InputBoxTemplate")
    accountEditBox:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, NextPosition1(20))
    accountEditBox:SetAutoFocus(false)
    accountEditBox:SetText(L["Username"])
	TrinityAdmin.AutoSize(accountEditBox, 20, 13, nil, 200)
    accountEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == L["Username"] then self:SetText("") end
    end)
    accountEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self:SetText(L["Username"]) end
    end)
    accountEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Account_Format_Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    accountEditBox:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    -- EditBox pour le Password
    local passwordEditBox = CreateFrame("EditBox", "TrinityAdminPasswordEditBox", commandsFramePage1, "InputBoxTemplate")
    passwordEditBox:SetPoint("TOPLEFT", accountEditBox, "BOTTOMLEFT", 0, -5)
    passwordEditBox:SetAutoFocus(false)
    passwordEditBox:SetText(L["Password"])
	TrinityAdmin.AutoSize(passwordEditBox, 20, 13, nil, 200)
    passwordEditBox:SetPassword(true)
    passwordEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == L["Password"] then self:SetText("") end
    end)
    passwordEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self:SetText(L["Password"]) end
    end)
    passwordEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Account_Password_Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    passwordEditBox:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    -- Bouton "Create"
    local btnCreate = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
    btnCreate:SetPoint("TOPLEFT", passwordEditBox, "BOTTOMLEFT", 0, -5)
    btnCreate:SetText(L["Create"])
	TrinityAdmin.AutoSize(btnCreate, 20, 16)
    btnCreate:SetScript("OnClick", function()
        local accountValue = accountEditBox:GetText()
        local passwordValue = passwordEditBox:GetText()
        if accountValue == "" or accountValue == L["Username"] or
           passwordValue == "" or passwordValue == L["Password"] then
            TrinityAdmin:Print(L["Please enter both account and password."])
            return
        end
        local command = ".bnetaccount create \"" .. accountValue .. "\" \"" .. passwordValue .. "\""
        SendChatMessage(command, "SAY")
    end)

    -- Section "Infos Ban"
    local banInfoLabel = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    banInfoLabel:SetPoint("TOPLEFT", page1Title, "TOPRIGHT", 140, 0)
    banInfoLabel:SetText(L["Infos_Ban"])

    local banInfoInput = CreateFrame("EditBox", "TrinityAdminBanInfoInput", commandsFramePage1, "InputBoxTemplate")
    -- banInfoInput:SetSize(150, 22)
    banInfoInput:SetPoint("TOPLEFT", banInfoLabel, "BOTTOMLEFT", 0, -5)
    banInfoInput:SetAutoFocus(false)
    banInfoInput:SetText("")
	TrinityAdmin.AutoSize(banInfoInput, 20, 26, nil, 200)

	local banInfoOptions = {
		{ value = ".baninfo account", text = "baninfo account", tooltip = L["Baninfo_Account"], needsInput = true },
		{ value = ".baninfo character", text = "baninfo character", tooltip = L["Baninfo_Character"], needsInput = true },
		{ value = ".baninfo ip", text = "baninfo ip", tooltip = L["Baninfo_IP"], needsInput = true },
		{ value = ".banlist account", text = "banlist account", tooltip = L["Banlist_Account"], needsInput = false },
		{ value = ".banlist character", text = "banlist character", tooltip = L["Banlist_Character"], needsInput = true },
		{ value = ".banlist ip", text = "banlist ip", tooltip = L["Banlist_IP"], needsInput = true },
	}
	
	local banInfoDropdown = CreateFrame("Frame", "TrinityAdminBanInfoDropdown", commandsFramePage1, "UIDropDownMenuTemplate")
	banInfoDropdown:SetPoint("LEFT", banInfoInput, "RIGHT", 10, 0)
	
	-- Par défaut, on sélectionne la première option
	banInfoDropdown.selectedID = 1
	banInfoDropdown.selectedOption = banInfoOptions[1]
	
	UIDropDownMenu_Initialize(banInfoDropdown, function(dropdown, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		for i, option in ipairs(banInfoOptions) do
			info.text = option.text
			info.value = option.value
			info.checked = (banInfoDropdown.selectedID == i)
			info.func = function(self)
				banInfoDropdown.selectedID = i
				UIDropDownMenu_SetSelectedID(dropdown, i)
				UIDropDownMenu_SetText(dropdown, option.text)
				banInfoDropdown.selectedOption = option
	
				-- Tooltip sur l'input
				banInfoInput:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetText(option.tooltip, 1, 1, 1)
					GameTooltip:Show()
				end)
				banInfoInput:SetScript("OnLeave", function(self)
					GameTooltip:Hide()
				end)
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end)

	-- Affiche la sélection par défaut
	UIDropDownMenu_SetSelectedID(banInfoDropdown, banInfoDropdown.selectedID)
	UIDropDownMenu_SetText(banInfoDropdown, banInfoOptions[banInfoDropdown.selectedID].text)
	

    local btnGetBanInfo = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
    btnGetBanInfo:SetPoint("LEFT", banInfoDropdown, "RIGHT", 115, 2)
    btnGetBanInfo:SetText(L["Get"])
    -- btnGetBanInfo:SetHeight(22)
    -- btnGetBanInfo:SetWidth(btnGetBanInfo:GetTextWidth() + 20)
	TrinityAdmin.AutoSize(btnGetBanInfo, 20, 16)
    btnGetBanInfo:SetScript("OnClick", function()
        local option = banInfoDropdown.selectedOption
        if not option then
            TrinityAdmin:Print(L["Please_select_option_infoban"])
            return
        end
        local inputValue = banInfoInput:GetText()
        local command = ""
        if option.value == "banlist account" then
            if inputValue and inputValue ~= "" then
                command = option.value .. " " .. inputValue
            else
                command = option.value
            end
        else
            if option.needsInput and (not inputValue or inputValue == "") then
                TrinityAdmin:Print( L["Please_enter_value_for"] .. option.value )
                return
            end
            command = option.value .. " " .. inputValue
        end
        -- print("Debug: Commande envoyée en SAY: " .. command)
        SendChatMessage(command, "SAY")
    end)

    local banLabel = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    banLabel:SetPoint("TOPLEFT", btnCreate, "BOTTOMLEFT", 0, -20)
    banLabel:SetText(L["Ban Account"])

    local banNameEditBox = CreateFrame("EditBox", "TrinityAdminBanNameEditBox", commandsFramePage1, "InputBoxTemplate")
    -- banNameEditBox:SetSize(150, 22)
    banNameEditBox:SetPoint("TOPLEFT", banLabel, "BOTTOMLEFT", 0, -10)
    banNameEditBox:SetAutoFocus(false)
    banNameEditBox:SetText(L["Name"])
	TrinityAdmin.AutoSize(banNameEditBox, 20, 13, nil, 150)
    banNameEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == L["Name"] then self:SetText("") end
    end)
    banNameEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self:SetText(L["Name"]) end
    end)
    banNameEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Name Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    banNameEditBox:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    local banTimeEditBox = CreateFrame("EditBox", "TrinityAdminBanTimeEditBox", commandsFramePage1, "InputBoxTemplate")
    -- banTimeEditBox:SetSize(150, 22)
    banTimeEditBox:SetPoint("TOPLEFT", banNameEditBox, "BOTTOMLEFT", 0, -5)
    banTimeEditBox:SetAutoFocus(false)
    banTimeEditBox:SetText(L["Bantime"])
	TrinityAdmin.AutoSize(banTimeEditBox, 20, 13, nil)
    banTimeEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == L["Bantime"] then self:SetText("") end
    end)
    banTimeEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self:SetText(L["Bantime"]) end
    end)
    banTimeEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Bantime Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    banTimeEditBox:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    local banReasonEditBox = CreateFrame("EditBox", "TrinityAdminBanReasonEditBox", commandsFramePage1, "InputBoxTemplate")
    -- banReasonEditBox:SetSize(150, 22)
    banReasonEditBox:SetPoint("TOPLEFT", banTimeEditBox, "BOTTOMLEFT", 0, -5)
    banReasonEditBox:SetAutoFocus(false)
    banReasonEditBox:SetText(L["Reason"])
	TrinityAdmin.AutoSize(banReasonEditBox, 20, 13, nil, 150)
    banReasonEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == L["Reason"] then self:SetText("") end
    end)
    banReasonEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self:SetText(L["Reason"]) end
    end)

    local banType = "account"
    local radioBanAccount, radioBanCharacter, radioBanIP, radioBanPlayerAccount

    local function UncheckAllRadios()
        if radioBanAccount then radioBanAccount:SetChecked(false) end
        if radioBanCharacter then radioBanCharacter:SetChecked(false) end
        if radioBanIP then radioBanIP:SetChecked(false) end
        if radioBanPlayerAccount then radioBanPlayerAccount:SetChecked(false) end
    end

    radioBanAccount = CreateFrame("CheckButton", "TrinityAdminBanAccountRadio", commandsFramePage1, "UICheckButtonTemplate")
    radioBanAccount:SetPoint("LEFT", banNameEditBox, "RIGHT", 10, 0)
    _G[radioBanAccount:GetName().."Text"]:SetText(L["Ban Account"] or "Ban Account")
    radioBanAccount:SetChecked(true)
    radioBanAccount:SetScript("OnClick", function(self)
        UncheckAllRadios()
        self:SetChecked(true)
        banType = "account"
        banNameEditBox:SetText(L["Name_Account"] or "Compte / Nom / IP")
    end)

    radioBanCharacter = CreateFrame("CheckButton", "TrinityAdminBanCharacterRadio", commandsFramePage1, "UICheckButtonTemplate")
    radioBanCharacter:SetPoint("TOPLEFT", radioBanAccount, "BOTTOMLEFT", 30, 1)
    _G[radioBanCharacter:GetName().."Text"]:SetText(L["Ban Character"] or "Ban Character")
    radioBanCharacter:SetScript("OnClick", function(self)
        UncheckAllRadios()
        self:SetChecked(true)
        banType = "character"
        banNameEditBox:SetText(L["Character"] or "Character")
    end)

    radioBanIP = CreateFrame("CheckButton", "TrinityAdminBanIPRadio", commandsFramePage1, "UICheckButtonTemplate")
    radioBanIP:SetPoint("TOPLEFT", radioBanCharacter, "BOTTOMLEFT", 0, 0)
    _G[radioBanIP:GetName().."Text"]:SetText(L["Ban IP"] or "Ban IP")
    radioBanIP:SetScript("OnClick", function(self)
        UncheckAllRadios()
        self:SetChecked(true)
        banType = "ip"
        banNameEditBox:SetText(L["IP"] or "IP")
    end)

    radioBanPlayerAccount = CreateFrame("CheckButton", "TrinityAdminBanPlayerAccountRadio", commandsFramePage1, "UICheckButtonTemplate")
    radioBanPlayerAccount:SetPoint("TOPLEFT", radioBanIP, "BOTTOMLEFT", 0, 0)
    _G[radioBanPlayerAccount:GetName().."Text"]:SetText(L["Ban PlayerAccount"] or "Ban PlayerAccount")
    radioBanPlayerAccount:SetScript("OnClick", function(self)
        UncheckAllRadios()
        self:SetChecked(true)
        banType = "playeraccount"
        banNameEditBox:SetText(L["PlayerAccount"] or "PlayerAccount")
    end)

    local btnBan = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
    btnBan:SetPoint("TOPLEFT", banReasonEditBox, "BOTTOMLEFT", 0, -10)
    btnBan:SetText(L["Ban"])
    -- btnBan:SetHeight(22)
    -- btnBan:SetWidth(btnBan:GetTextWidth() + 20)
	TrinityAdmin.AutoSize(btnBan, 20, 16)
    btnBan:SetScript("OnClick", function()
        local nameValue = banNameEditBox:GetText()
        local timeValue = banTimeEditBox:GetText()
        local reasonValue = banReasonEditBox:GetText()
        if nameValue == "" or nameValue == L["Name"]
           or timeValue == "" or timeValue == L["Bantime"]
           or reasonValue == "" or reasonValue == L["Reason"] then
            TrinityAdmin:Print(L["Please enter name, bantime and reason."])
            TrinityAdmin:Print(L["Select_ban_type"] .. banType)
            return
        end
        local command
        if banType == "account" then
            command = ".ban account " .. nameValue .. " " .. timeValue .. " " .. reasonValue
            TrinityAdmin:Print(string.format(L["Ban_Account_done"], nameValue, timeValue, reasonValue))
        elseif banType == "character" then
            command = ".ban character " .. nameValue .. " " .. timeValue .. " " .. reasonValue
            TrinityAdmin:Print(string.format(L["Ban_Character_done"], nameValue, timeValue, reasonValue))
        elseif banType == "ip" then
            command = ".ban ip " .. nameValue .. " " .. timeValue .. " " .. reasonValue
            TrinityAdmin:Print(string.format(L["Ban_IP_done"], nameValue, timeValue, reasonValue))
        elseif banType == "playeraccount" then
            command = ".ban playeraccount " .. nameValue .. " " .. timeValue .. " " .. reasonValue
            TrinityAdmin:Print(string.format(L["Ban_PlayerAccount_done"], nameValue, timeValue, reasonValue))
        end
        -- print("Debug: Commande envoyée en SAY: " .. command)
        SendChatMessage(command, "SAY")
    end)

    -- Section "Bnet Account Manage"
    local bnetLabel = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bnetLabel:SetPoint("TOPLEFT", banInfoInput, "BOTTOMLEFT", 0, -20)
    bnetLabel:SetText(L["Bnet Account Management"])

    local bnetDropdown = CreateFrame("Frame", "TrinityAdminBnetDropdown", commandsFramePage1, "UIDropDownMenuTemplate")
    bnetDropdown:SetPoint("LEFT", bnetLabel, "RIGHT", -20, -26)
    UIDropDownMenu_SetWidth(bnetDropdown, 180)
    UIDropDownMenu_SetButtonWidth(bnetDropdown, 240)
    local bnetOptions = {
        { text = "bnetaccount gameaccountcreate", command = ".bnetaccount gameaccountcreate", tooltip = L["bnetaccount gameaccountcreate"] },
        { text = "bnetaccount link", command = ".bnetaccount link", tooltip = L["bnetaccount link"] },
        { text = "bnetaccount listgameaccounts", command = ".bnetaccount listgameaccounts", tooltip = L["bnetaccount listgameaccounts"] },
        { text = "bnetaccount lock country", command = ".bnetaccount lock country", tooltip = L["bnetaccount lock country"] },
        { text = "bnetaccount lock ip", command = ".bnetaccount lock ip", tooltip = L["bnetaccount lock ip"] },
        { text = "bnetaccount password", command = ".bnetaccount password", tooltip = L["bnetaccount password"] },
        { text = "bnetaccount set", command = ".bnetaccount set", tooltip = L["bnetaccount set"] },
        { text = "bnetaccount set password", command = ".bnetaccount set password", tooltip = L["bnetaccount set password"] },
        { text = "bnetaccount unlink", command = ".bnetaccount unlink", tooltip = L["bnetaccount unlink"] },
    }
    if not bnetDropdown.selectedID then bnetDropdown.selectedID = 1 end
    UIDropDownMenu_Initialize(bnetDropdown, function(dropdown, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, option in ipairs(bnetOptions) do
            info.text = option.text
            info.value = option.command
            info.checked = (i == bnetDropdown.selectedID)
            info.func = function(self)
                bnetDropdown.selectedID = i
                UIDropDownMenu_SetSelectedID(bnetDropdown, i)
                UIDropDownMenu_SetText(bnetDropdown, option.text)
                bnetDropdown.selectedOption = option
                -- print("DEBUG: Option sélectionnée: " .. option.text)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetSelectedID(bnetDropdown, bnetDropdown.selectedID)
    UIDropDownMenu_SetText(bnetDropdown, bnetOptions[bnetDropdown.selectedID].text)
    bnetDropdown.selectedOption = bnetOptions[bnetDropdown.selectedID]

    local bnetEdit = CreateFrame("EditBox", "TrinityAdminBnetEditBox", commandsFramePage1, "InputBoxTemplate")
    -- bnetEdit:SetSize(150, 22)
    bnetEdit:SetPoint("TOPLEFT", bnetLabel, "BOTTOMLEFT", 0, -5)
    bnetEdit:SetAutoFocus(false)
    bnetEdit:SetText(L["Enter Value"])
	TrinityAdmin.AutoSize(bnetEdit, 20, 13, nil, 150)
    bnetEdit:SetScript("OnEnter", function(self)
        local opt = bnetDropdown.selectedOption or bnetOptions[1]
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    bnetEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
    bnetEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    local btnBnetGo = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
    -- btnBnetGo:SetSize(70, 22)
    btnBnetGo:SetText(L["Execute"])
	TrinityAdmin.AutoSize(btnBnetGo, 20, 16)
    btnBnetGo:SetPoint("LEFT", bnetDropdown, "LEFT", -20, -40)
    btnBnetGo:SetScript("OnClick", function()
	    local defauttextevalue = L["Enter Value"]
        local inputValue = bnetEdit:GetText()
        local option = bnetDropdown.selectedOption
        local command = option.command
        local finalCommand = command .. " " .. inputValue
        if inputValue == "" or inputValue == defauttextevalue then
            local targetName = UnitName("target")
            if targetName then
                finalCommand = command .. " " .. targetName
            else
                TrinityAdmin:Print(L["Please enter a value or select a player."])
                return
            end
        end
        -- print("Debug: Commande envoyée en SAY: " .. finalCommand)
        SendChatMessage(finalCommand, "SAY")
    end)
    btnBnetGo:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local opt = bnetDropdown.selectedOption or bnetOptions[1]
        GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnBnetGo:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- FIN PAGE 1

    ------------------------------------------------------------------------------
    -- PAGE 2 : Unban
    ------------------------------------------------------------------------------
    local commandsFramePage2 = CreateFrame("Frame", nil, pages[2])
    commandsFramePage2:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 10, -40)
    commandsFramePage2:SetSize(500, 350)

    local page2Title = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    page2Title:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, 0)
    page2Title:SetText(L["Unban Functions"])

    local function CreateUnbanInput(yOffset, defaultText, buttonText, tooltipText, commandPrefix)
    local editBox = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
    -- editBox:SetSize(150, 22)
    editBox:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, yOffset)
    editBox:SetAutoFocus(false)
    editBox:SetText(defaultText)
	TrinityAdmin.AutoSize(editBox, 20, 13, nil, 150)
    editBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == defaultText then self:SetText("") end
    end)
    editBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then self:SetText(defaultText) end
    end)

    local btn = CreateFrame("Button", nil, commandsFramePage2, "UIPanelButtonTemplate")
    -- btn:SetSize(120, 22)
    btn:SetText(buttonText)
	TrinityAdmin.AutoSize(btn, 20, 16)
    btn:SetPoint("LEFT", editBox, "RIGHT", 10, 0)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    local unbanchardefauttext = L["Enter Character"]
	local unbanipdefauttexte = L["Enter IP"]
    btn:SetScript("OnClick", function()
    local inputValue = editBox:GetText()

    if (inputValue == "" or inputValue == defaultText) and commandPrefix == ".unban account" then
        TrinityAdmin:Print(L["Please enter account name to deban.."])
        return

    elseif (inputValue == "" or inputValue == unbanchardefauttext) and commandPrefix == ".unban character" then
        TrinityAdmin:Print(L["Please enter player name to Deban.."])
        return

    elseif (inputValue == "" or inputValue == unbanipdefauttexte) and commandPrefix == ".unban ip" then
        TrinityAdmin:Print(L["Please enter IP to Deban."])
        return

    else 
        TrinityAdmin:Print(L["I give up!"])
    end

    local cmd = commandPrefix .. " \"" .. inputValue .. "\""
    SendChatMessage(cmd, "SAY")
end)
	end

	-- Unban Account
	CreateUnbanInput(-30, L["Enter Account"], L["Unban Account"], L["Syntax: .unban account $Name\nUnban accounts for account name pattern."], ".unban account")
	
	-- Unban Character
	CreateUnbanInput(-60, L["Enter Character"], L["Unban Char"], L["Syntax: .unban character $Name\nUnban accounts for character name pattern."], ".unban character")
	
	-- Unban IP
	CreateUnbanInput(-90, L["Enter IP"], L["Unban IP"], L["Syntax: .unban ip $Ip\nUnban accounts for IP pattern."], ".unban ip")

    ------------------------------------------------------------------------------
    -- Bouton Back final (commun aux pages)
    ------------------------------------------------------------------------------
    local btnBackFinal = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("BOTTOM", pageLabel, "CENTER", 0, 7)
    btnBackFinal:SetText(L["Back"])
    -- btnBackFinal:SetHeight(22)
    -- btnBackFinal:SetWidth(btnBackFinal:GetTextWidth() + 20)
	TrinityAdmin.AutoSize(btnBackFinal, 20, 16)
    btnBackFinal:SetScript("OnClick", function()
        account:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = account
end

return AccountModule
