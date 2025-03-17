local AccountModule = TrinityAdmin:GetModule("AccountPanel")

function AccountModule:ShowAccountPanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateAccountPanel()
    end
    self.panel:Show()
end

function AccountModule:CreateAccountPanel()
    local account = CreateFrame("Frame", "TrinityAdminAccountPanel", TrinityAdminMainFrame)
    account:ClearAllPoints()
    account:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    account:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = account:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    account.title = account:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    account.title:SetPoint("TOPLEFT", 10, -10)
    account.title:SetText(TrinityAdmin_Translations["Account_Panel"])

    -- Label "Création de comptes"
    local creationLabel = account:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    creationLabel:SetPoint("TOPLEFT", account, "TOPLEFT", 10, -30)
    creationLabel:SetText(TrinityAdmin_Translations["Account Creation"])
	
    -- EditBox pour l'Account avec valeur par défaut et tooltip
    local accountEditBox = CreateFrame("EditBox", "TrinityAdminAccountEditBox", account, "InputBoxTemplate")
    accountEditBox:SetSize(200, 22)
    accountEditBox:SetPoint("TOPLEFT", account, "TOPLEFT", 10, -50)
    accountEditBox:SetAutoFocus(false)
    accountEditBox:SetText(TrinityAdmin_Translations["Username"])
    accountEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == TrinityAdmin_Translations["Username"] then
            self:SetText("")
        end
    end)
    accountEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(TrinityAdmin_Translations["Username"])
        end
    end)
    accountEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(TrinityAdmin_Translations["Account_Format_Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    accountEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- EditBox pour le Password avec valeur par défaut
    local passwordEditBox = CreateFrame("EditBox", "TrinityAdminPasswordEditBox", account, "InputBoxTemplate")
    passwordEditBox:SetSize(200, 22)
    passwordEditBox:SetPoint("TOPLEFT", accountEditBox, "BOTTOMLEFT", 0, -10)
    passwordEditBox:SetAutoFocus(false)
    passwordEditBox:SetText(TrinityAdmin_Translations["Password"])
    passwordEditBox:SetPassword(true)
    passwordEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == TrinityAdmin_Translations["Password"] then
            self:SetText("")
        end
    end)
    passwordEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(TrinityAdmin_Translations["Password"])
        end
    end)
    passwordEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(TrinityAdmin_Translations["Account_Password_Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    passwordEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Bouton "Create"
    local btnCreate = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    btnCreate:SetPoint("TOPLEFT", passwordEditBox, "BOTTOMLEFT", 0, -10)
    btnCreate:SetText(TrinityAdmin_Translations["Create"])
    btnCreate:SetHeight(22)
    btnCreate:SetWidth(btnCreate:GetTextWidth() + 20)
    btnCreate:SetScript("OnClick", function()
        local accountValue = accountEditBox:GetText()
        local passwordValue = passwordEditBox:GetText()
        if accountValue == "" or accountValue == TrinityAdmin_Translations["Username"] or
           passwordValue == "" or passwordValue == TrinityAdmin_Translations["Password"] then
            print(TrinityAdmin_Translations["Please enter both account and password."])
            return
        end
        local command = ".bnetaccount create \"" .. accountValue .. "\" \"" .. passwordValue .. "\""
        SendChatMessage(command, "SAY")
    end)
        -- Nouvelle section "Infos Ban"
    local banInfoLabel = account:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    banInfoLabel:SetPoint("TOPLEFT", creationLabel, "TOPRIGHT", 150, 0)
    banInfoLabel:SetText(TrinityAdmin_Translations["Infos_Ban"]) -- Vous pouvez aussi traduire via TrinityAdmin_Translations si besoin

    local banInfoInput = CreateFrame("EditBox", "TrinityAdminBanInfoInput", account, "InputBoxTemplate")
    banInfoInput:SetSize(150, 22)
    banInfoInput:SetPoint("TOPLEFT", banInfoLabel, "BOTTOMLEFT", 0, -10)
    banInfoInput:SetAutoFocus(false)
    banInfoInput:SetText("")

    local banInfoDropdown = CreateFrame("Frame", "TrinityAdminBanInfoDropdown", account, "UIDropDownMenuTemplate")
    banInfoDropdown:SetPoint("LEFT", banInfoInput, "RIGHT", 10, 0)
    
    -- Définition des options pour le menu déroulant
    local banInfoOptions = {
        { value = ".baninfo account", text = "baninfo account", tooltip = TrinityAdmin_Translations["Baninfo_Account"], needsInput = true },
        { value = ".baninfo character", text = "baninfo character", tooltip = TrinityAdmin_Translations["Baninfo_Character"], needsInput = true },
        { value = ".baninfo ip", text = "baninfo ip", tooltip = TrinityAdmin_Translations["Baninfo_IP"], needsInput = true },
        { value = ".banlist account", text = "banlist account", tooltip = TrinityAdmin_Translations["Banlist_Account"], needsInput = false },
        { value = ".banlist character", text = "banlist character", tooltip = TrinityAdmin_Translations["Banlist_Character"], needsInput = true },
        { value = ".banlist ip", text = "banlist ip", tooltip = TrinityAdmin_Translations["Banlist_IP"], needsInput = true },
    }

    UIDropDownMenu_Initialize(banInfoDropdown, function(dropdown, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, option in ipairs(banInfoOptions) do
            info.text = option.text
            info.value = option.value
            info.func = function(self)
                UIDropDownMenu_SetSelectedValue(dropdown, self.value)
                UIDropDownMenu_SetText(dropdown, self.value)
                banInfoDropdown.selectedOption = option
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
    UIDropDownMenu_SetText(banInfoDropdown, "Select Option")

    local btnGetBanInfo = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    btnGetBanInfo:SetPoint("LEFT", banInfoDropdown, "RIGHT", 115, 2)
    btnGetBanInfo:SetText("Get")
    btnGetBanInfo:SetHeight(22)
    btnGetBanInfo:SetWidth(btnGetBanInfo:GetTextWidth() + 20)
    btnGetBanInfo:SetScript("OnClick", function()
        local option = banInfoDropdown.selectedOption
        if not option then
            print("Veuillez sélectionner une option pour Infos Ban.")
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
                print("Veuillez entrer une valeur pour " .. option.value)
                return
            end
            command = option.value .. " " .. inputValue
        end
		print("Debug: Commande envoyée en SAY: " .. command)
        SendChatMessage(command, "SAY")
    end)

    -- Label "Bannir un compte"
    local banLabel = account:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    banLabel:SetPoint("TOPLEFT", btnCreate, "BOTTOMLEFT", 0, -20)
    banLabel:SetText(TrinityAdmin_Translations["Ban Account"])

-- EditBoxes pour le bannissement (Name, Bantime, Reason) :
    local banNameEditBox = CreateFrame("EditBox", "TrinityAdminBanNameEditBox", account, "InputBoxTemplate")
    banNameEditBox:SetSize(150, 22)
    banNameEditBox:SetPoint("TOPLEFT", banLabel, "BOTTOMLEFT", 0, -10)
    banNameEditBox:SetAutoFocus(false)
    banNameEditBox:SetText(TrinityAdmin_Translations["Name"])
    banNameEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == TrinityAdmin_Translations["Name"] then
            self:SetText("")
        end
    end)
    banNameEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(TrinityAdmin_Translations["Name"])
        end
    end)
    banNameEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(TrinityAdmin_Translations["Name Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    banNameEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
	
    local banTimeEditBox = CreateFrame("EditBox", "TrinityAdminBanTimeEditBox", account, "InputBoxTemplate")
    banTimeEditBox:SetSize(150, 22)
    banTimeEditBox:SetPoint("TOPLEFT", banNameEditBox, "BOTTOMLEFT", 0, -10)
    banTimeEditBox:SetAutoFocus(false)
    banTimeEditBox:SetText(TrinityAdmin_Translations["Bantime"])
    banTimeEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == TrinityAdmin_Translations["Bantime"] then
            self:SetText("")
        end
    end)
    banTimeEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(TrinityAdmin_Translations["Bantime"])
        end
    end)
	banTimeEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(TrinityAdmin_Translations["Bantime Tooltip"], 1, 1, 1)
        GameTooltip:Show()
    end)
    banTimeEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
	
    local banReasonEditBox = CreateFrame("EditBox", "TrinityAdminBanReasonEditBox", account, "InputBoxTemplate")
    banReasonEditBox:SetSize(150, 22)
    banReasonEditBox:SetPoint("TOPLEFT", banTimeEditBox, "BOTTOMLEFT", 0, -10)
    banReasonEditBox:SetAutoFocus(false)
    banReasonEditBox:SetText(TrinityAdmin_Translations["Reason"])
    banReasonEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == TrinityAdmin_Translations["Reason"] then
            self:SetText("")
        end
    end)
    banReasonEditBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(TrinityAdmin_Translations["Reason"])
        end
    end)
    
    -- Déclarez les variables radio pour choisir le type de ban
    local banType = "account"
    local radioBanAccount, radioBanCharacter, radioBanIP, radioBanPlayerAccount

    -- Fonction auxiliaire pour désélectionner tous les boutons radio
    local function UncheckAllRadios()
        if radioBanAccount then radioBanAccount:SetChecked(false) end
        if radioBanCharacter then radioBanCharacter:SetChecked(false) end
        if radioBanIP then radioBanIP:SetChecked(false) end
        if radioBanPlayerAccount then radioBanPlayerAccount:SetChecked(false) end
    end

    -- Bouton radio "Ban Account" positionné à droite du champ "Name"
    radioBanAccount = CreateFrame("CheckButton", "TrinityAdminBanAccountRadio", account, "UICheckButtonTemplate")
    radioBanAccount:SetPoint("LEFT", banNameEditBox, "RIGHT", 10, 0)
    _G[radioBanAccount:GetName().."Text"]:SetText(TrinityAdmin_Translations["Ban Account"] or "Ban Account")
    radioBanAccount:SetChecked(true)
    radioBanAccount:SetScript("OnClick", function(self)
        UncheckAllRadios()
        self:SetChecked(true)
        banType = "account"
        banNameEditBox:SetText(TrinityAdmin_Translations["Name_Account"] or "Compte / Nom / IP")
    end)
    
    -- Bouton radio "Ban Character"
    radioBanCharacter = CreateFrame("CheckButton", "TrinityAdminBanCharacterRadio", account, "UICheckButtonTemplate")
    radioBanCharacter:SetPoint("TOPLEFT", radioBanAccount, "BOTTOMLEFT", 0, -5)
    _G[radioBanCharacter:GetName().."Text"]:SetText(TrinityAdmin_Translations["Ban Character"] or "Ban Character")
    radioBanCharacter:SetScript("OnClick", function(self)
        UncheckAllRadios()
        self:SetChecked(true)
        banType = "character"
        banNameEditBox:SetText(TrinityAdmin_Translations["Character"] or "Character")
    end)
    
    -- Bouton radio "Ban IP"
    radioBanIP = CreateFrame("CheckButton", "TrinityAdminBanIPRadio", account, "UICheckButtonTemplate")
    radioBanIP:SetPoint("TOPLEFT", radioBanCharacter, "BOTTOMLEFT", 0, -5)
    _G[radioBanIP:GetName().."Text"]:SetText(TrinityAdmin_Translations["Ban IP"] or "Ban IP")
    radioBanIP:SetScript("OnClick", function(self)
        UncheckAllRadios()
        self:SetChecked(true)
        banType = "ip"
        banNameEditBox:SetText(TrinityAdmin_Translations["IP"] or "IP")
    end)
    
    -- Bouton radio "Ban PlayerAccount"
    radioBanPlayerAccount = CreateFrame("CheckButton", "TrinityAdminBanPlayerAccountRadio", account, "UICheckButtonTemplate")
    radioBanPlayerAccount:SetPoint("TOPLEFT", radioBanIP, "BOTTOMLEFT", 0, -5)
    _G[radioBanPlayerAccount:GetName().."Text"]:SetText(TrinityAdmin_Translations["Ban PlayerAccount"] or "Ban PlayerAccount")
    radioBanPlayerAccount:SetScript("OnClick", function(self)
        UncheckAllRadios()
        self:SetChecked(true)
        banType = "playeraccount"
        banNameEditBox:SetText(TrinityAdmin_Translations["PlayerAccount"] or "PlayerAccount")
    end)

    -- Bouton "Ban" commun qui exécute la commande en fonction du type de ban
    local btnBan = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    btnBan:SetPoint("TOPLEFT", banReasonEditBox, "BOTTOMLEFT", 0, -10)
    btnBan:SetText(TrinityAdmin_Translations["Ban"])
    btnBan:SetHeight(22)
    btnBan:SetWidth(btnBan:GetTextWidth() + 20)
    btnBan:SetScript("OnClick", function()
        local nameValue = banNameEditBox:GetText()
        local timeValue = banTimeEditBox:GetText()
        local reasonValue = banReasonEditBox:GetText()
        if nameValue == "" or nameValue == TrinityAdmin_Translations["Name"]
           or timeValue == "" or timeValue == TrinityAdmin_Translations["Bantime"]
           or reasonValue == "" or reasonValue == TrinityAdmin_Translations["Reason"] then
            print(TrinityAdmin_Translations["Please enter name, bantime and reason."])
            print("Selected ban type: " .. banType)
            return
        end
        local command
        if banType == "account" then
            command = ".ban account " .. nameValue .. " " .. timeValue .. " " .. reasonValue
            print(string.format(TrinityAdmin_Translations["Ban_Account_done"], nameValue, timeValue, reasonValue))
        elseif banType == "character" then
            command = ".ban character " .. nameValue .. " " .. timeValue .. " " .. reasonValue
            print(string.format(TrinityAdmin_Translations["Ban_Character_done"], nameValue, timeValue, reasonValue))
        elseif banType == "ip" then
            command = ".ban ip " .. nameValue .. " " .. timeValue .. " " .. reasonValue
            print(string.format(TrinityAdmin_Translations["Ban_IP_done"], nameValue, timeValue, reasonValue))
        elseif banType == "playeraccount" then
            command = ".ban playeraccount " .. nameValue .. " " .. timeValue .. " " .. reasonValue
            print(string.format(TrinityAdmin_Translations["Ban_PlayerAccount_done"], nameValue, timeValue, reasonValue))
        end
		print("Debug: Commande envoyée en SAY: " .. command)
        SendChatMessage(command, "SAY")
    end)
	
	
	------------------------------------------------------------------
-- Nouvelle section "Bnet Account Manage"
------------------------------------------------------------------
local bnetLabel = account:CreateFontString(nil, "OVERLAY", "GameFontNormal")
bnetLabel:SetPoint("TOPLEFT", banInfoInput, "BOTTOMLEFT", 0, -20)
bnetLabel:SetText("Bnet Account Manage")

-- Créez le menu déroulant pour Bnet Account Manage AVANT le champ de saisie
local bnetDropdown = CreateFrame("Frame", "TrinityAdminBnetDropdown", account, "UIDropDownMenuTemplate")
bnetDropdown:SetPoint("LEFT", bnetLabel, "RIGHT", 10, -23)
UIDropDownMenu_SetWidth(bnetDropdown, 180)
UIDropDownMenu_SetButtonWidth(bnetDropdown, 240)
local bnetOptions = {
    { text = "bnetaccount gameaccountcreate", command = ".bnetaccount gameaccountcreate", tooltip = TrinityAdmin_Translations["bnetaccount gameaccountcreate"] },
    { text = "bnetaccount link", command = ".bnetaccount link", tooltip = TrinityAdmin_Translations["bnetaccount link"]},
    { text = "bnetaccount listgameaccounts", command = ".bnetaccount listgameaccounts", tooltip = TrinityAdmin_Translations["bnetaccount listgameaccounts"] },
    { text = "bnetaccount lock country", command = ".bnetaccount lock country", tooltip = TrinityAdmin_Translations["bnetaccount lock country"] },
    { text = "bnetaccount lock ip", command = ".bnetaccount lock ip", tooltip = TrinityAdmin_Translations["bnetaccount lock ip"] },
    { text = "bnetaccount password", command = ".bnetaccount password", tooltip = TrinityAdmin_Translations["bnetaccount password"] },
    { text = "bnetaccount set", command = ".bnetaccount set", tooltip = TrinityAdmin_Translations["bnetaccount set"] },
    { text = "bnetaccount set password", command = ".bnetaccount set password", tooltip = TrinityAdmin_Translations["bnetaccount set password"] },
    { text = "bnetaccount unlink", command = ".bnetaccount unlink", tooltip = TrinityAdmin_Translations["bnetaccount unlink"] },
}
if not bnetDropdown.selectedID then bnetDropdown.selectedID = 1 end
UIDropDownMenu_Initialize(bnetDropdown, function(dropdownFrame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for i, option in ipairs(bnetOptions) do
        info.text = option.text
        info.value = option.command
        info.checked = (i == bnetDropdown.selectedID)
        info.func = function(buttonFrame)
            bnetDropdown.selectedID = i
            UIDropDownMenu_SetSelectedID(bnetDropdown, i)
            UIDropDownMenu_SetText(bnetDropdown, option.text)
            bnetDropdown.selectedOption = option
			print("DEBUG: Option sélectionnée: " .. option.text)       -- Affiche l'option sélectionnée pour débug
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)
UIDropDownMenu_SetSelectedID(bnetDropdown, bnetDropdown.selectedID)
UIDropDownMenu_SetText(bnetDropdown, bnetOptions[bnetDropdown.selectedID].text)
bnetDropdown.selectedOption = bnetOptions[bnetDropdown.selectedID]

-- Maintenant, créez le champ de saisie qui utilise le menu déroulant
local bnetEdit = CreateFrame("EditBox", "TrinityAdminBnetEditBox", account, "InputBoxTemplate")
bnetEdit:SetSize(150, 22)
bnetEdit:SetPoint("TOPLEFT", bnetLabel, "BOTTOMLEFT", 0, -5)
bnetEdit:SetAutoFocus(false)
bnetEdit:SetText("Enter Value")
bnetEdit:SetScript("OnEnter", function(self)
    local opt = bnetDropdown.selectedOption or bnetOptions[1]
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(opt.tooltip, 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
bnetEdit:SetScript("OnLeave", function() GameTooltip:Hide() end)
bnetEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

-- Bouton "Execute" pour Bnet Account Manage
local btnBnetGo = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
btnBnetGo:SetSize(60, 22)
btnBnetGo:SetText("Execute")
btnBnetGo:SetPoint("LEFT", bnetDropdown, "LEFT", 0, -30)
btnBnetGo:SetScript("OnClick", function()
    local inputValue = bnetEdit:GetText()
    local option = bnetDropdown.selectedOption
    local command = option.command
    local finalCommand = command .. " " .. inputValue
    if inputValue == "" or inputValue == "Enter Value" then
        local targetName = UnitName("target")
        if targetName then
            finalCommand = command .. " " .. targetName
        else
            print("Veuillez saisir une valeur ou cibler un joueur.")
			print("Debug: Commande envoyée en SAY: " .. finalCommand) -- Pour debug
            return
        end
    end
    print("Debug: Commande envoyée en SAY: " .. finalCommand) -- Pour debug
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

    -- Bouton "Back"
    local btnBack = CreateFrame("Button", nil, account, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", account, "BOTTOM", 0, 10)
    btnBack:SetText(TrinityAdmin_Translations["Back"])
    btnBack:SetHeight(22)
    btnBack:SetWidth(btnBack:GetTextWidth() + 20)
    btnBack:SetScript("OnClick", function()
        account:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = account
end