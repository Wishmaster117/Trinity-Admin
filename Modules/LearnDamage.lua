local LearnDamage = TrinityAdmin:GetModule("LearnDamage")
local L = _G.L

-- Fonction pour afficher le panneau LearnDamage
function LearnDamage:ShowLearnDamagePanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateLearnDamagePanel()
    end
    self.panel:Show()
end

-- Fonction pour créer le panneau LearnDamage
function LearnDamage:CreateLearnDamagePanel()
    local panel = CreateFrame("Frame", "TrinityAdminServerAdminPanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText(L["Learn and Damage Funcs"])

    -------------------------------------------------------------------------------
    -- Création de plusieurs pages dans le panneau
    -------------------------------------------------------------------------------
	local totalPages = 2  -- nombre de pages
	local pages = {}
	for i = 1, totalPages do
		pages[i] = CreateFrame("Frame", nil, panel)
		pages[i]:SetAllPoints(panel)
		pages[i]:Hide()  -- on cache toutes les pages au départ
	end
	
	-- Label de navigation unique (affiché en bas du panneau)
	local navPageLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	navPageLabel:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
	navPageLabel:SetText("Page 1 / " .. totalPages)
	
	-- Fonction de changement de page
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
	
	------------------------------------------------
	-- PAGE 1 : Learn Panel
	------------------------------------------------
	local commandsFramePage1 = CreateFrame("Frame", nil, pages[1])
	commandsFramePage1:SetPoint("TOPLEFT", pages[1], "TOPLEFT", 20, -40)
	commandsFramePage1:SetSize(500, 500)  -- Ajustement de la hauteur pour intégrer tous les éléments
	
	local page1Title = commandsFramePage1:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	page1Title:SetPoint("TOPLEFT", commandsFramePage1, "TOPLEFT", 0, 0)
	page1Title:SetText(L["Learn Panel"])
	
	------------------------------
	-- 1) Spell Learning
	------------------------------
	local spellIdEdit = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	-- spellIdEdit:SetSize(100, 22)
	spellIdEdit:SetPoint("TOPLEFT", page1Title, "BOTTOMLEFT", 0, -10)
	spellIdEdit:SetAutoFocus(false)
	spellIdEdit:SetText(L["SpellID1"])
	TrinityAdmin.AutoSize(spellIdEdit, 20, 13)
	
	local optionEdit = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	-- optionEdit:SetSize(100, 22)
	optionEdit:SetPoint("LEFT", spellIdEdit, "RIGHT", 10, 0)
	optionEdit:SetAutoFocus(false)
	optionEdit:SetText(L["Option_Spell"])
	TrinityAdmin.AutoSize(optionEdit, 20, 13)
	
	local btnLearn = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearn:SetHeight(22)
	btnLearn:SetPoint("LEFT", optionEdit, "RIGHT", 10, 0)
	btnLearn:SetText(L["LearnLP"])
	TrinityAdmin.AutoSize(btnLearn, 20, 16)
	-- btnLearn:SetWidth(btnLearn:GetTextWidth() + 20)
	btnLearn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["LearnLP tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearn:SetScript("OnClick", function()
		local spellID = spellIdEdit:GetText()
		local optionVal = optionEdit:GetText()
		if spellID == "" or spellID == L["SpellID1"] then
			print("Erreur: Spell ID requis.")
			return
		end
		if not UnitName("target") then
			print(L["no_player_selected_error"])
			return
		end
		local command = ".learn " .. spellID
		if optionVal ~= "" and optionVal ~= L["Option_Spell"] then
			command = command .. " " .. optionVal
		end
		-- SendChatMessage(command, "SAY")
		 TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	
	------------------------------
	-- 2) Learn Him
	------------------------------
	local playerNameEdit = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	-- playerNameEdit:SetSize(100, 22)
	playerNameEdit:SetPoint("TOPLEFT", spellIdEdit, "BOTTOMLEFT", 0, -10)
	playerNameEdit:SetAutoFocus(false)
	playerNameEdit:SetText(L["Player Name"])
	TrinityAdmin.AutoSize(playerNameEdit, 20, 13)
	
	local btnLearnHim = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnHim:SetHeight(22)
	btnLearnHim:SetPoint("LEFT", playerNameEdit, "RIGHT", 10, 0)
	btnLearnHim:SetText(L["Learn Him"])
	TrinityAdmin.AutoSize(btnLearnHim, 20, 16)
	-- btnLearnHim:SetWidth(btnLearnHim:GetTextWidth() + 20)
	btnLearnHim:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Him Tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnHim:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnHim:SetScript("OnClick", function()
		local playerName = playerNameEdit:GetText()
		local command = ".learn all default"
		if playerName ~= "" and playerName ~= L["Player Name"] then
			command = command .. " " .. playerName
		else
			if not UnitName("target") then
				print(L["no_player_or_name_error"])
				return
			end
		end
		-- SendChatMessage(command, "SAY")
		TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	
	-- Champ de saisie pour la Profession
	local professionEdit = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	-- professionEdit:SetSize(100, 22)
	professionEdit:SetPoint("TOPLEFT", playerNameEdit, "BOTTOMLEFT", 0, -10)
	professionEdit:SetAutoFocus(false)
	professionEdit:SetText(L["Profession"])
	TrinityAdmin.AutoSize(professionEdit, 20, 13)
	
	-- Bouton Learn Recipes utilisant la valeur du champ "Profession"
	local btnLearnRecipes = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnRecipes:SetHeight(22)
	btnLearnRecipes:SetPoint("LEFT", professionEdit, "RIGHT", 10, 0)
	btnLearnRecipes:SetText(L["Learn Recipes"])
	TrinityAdmin.AutoSize(btnLearnRecipes, 20, 13)
	-- btnLearnRecipes:SetWidth(btnLearnRecipes:GetTextWidth() + 20)
	btnLearnRecipes:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Recipes tooltips"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnRecipes:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnRecipes:SetScript("OnClick", function()
		local profession = professionEdit:GetText()
		local command = ".learn all recipes " .. profession
		-- SendChatMessage(command, "SAY")
		TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	------------------------------
	-- 3) Boutons "Learn all ..." (Crafts, Debug, Languages, Pettalents)
	------------------------------
	-- Bouton Learn Crafts
	local btnLearnCrafts = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnCrafts:SetHeight(22)
	btnLearnCrafts:SetPoint("TOPLEFT", professionEdit, "BOTTOMLEFT", 0, -20)
	btnLearnCrafts:SetText(L["Learn Crafts"])
	TrinityAdmin.AutoSize(btnLearnCrafts, 20, 16)
	-- btnLearnCrafts:SetWidth(btnLearnCrafts:GetTextWidth() + 20)
	btnLearnCrafts:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn All Crafts tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnCrafts:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnCrafts:SetScript("OnClick", function()
		local command = ".learn all crafts"
		-- Si un joueur est sélectionné, la commande sera envoyée sur le target du GM (sans préfixer le nom)
		-- SendChatMessage(command, "SAY")
		TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	
	-- Bouton Learn Debug
	local btnLearnDebug = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnDebug:SetHeight(22)
	btnLearnDebug:SetPoint("LEFT", btnLearnCrafts, "RIGHT", 10, 0)
	btnLearnDebug:SetText(L["Learn Debug"])
	TrinityAdmin.AutoSize(btnLearnDebug, 20, 16)
	-- btnLearnDebug:SetWidth(btnLearnDebug:GetTextWidth() + 20)
	btnLearnDebug:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Debug Tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnDebug:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnDebug:SetScript("OnClick", function()
		local command = ".learn all debug"
		-- SendChatMessage(command, "SAY")
		TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	
	-- Bouton Learn Languages
	local btnLearnLanguages = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnLanguages:SetHeight(22)
	btnLearnLanguages:SetPoint("LEFT", btnLearnDebug, "RIGHT", 10, 0)
	btnLearnLanguages:SetText(L["Learn Languages"])
	TrinityAdmin.AutoSize(btnLearnLanguages, 20, 16)
	-- btnLearnLanguages:SetWidth(btnLearnLanguages:GetTextWidth() + 20)
	btnLearnLanguages:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Languages tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnLanguages:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnLanguages:SetScript("OnClick", function()
		local command = ".learn all languages"
		-- SendChatMessage(command, "SAY")
		TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	
	-- Bouton Learn Pettalents
	local btnLearnPettalents = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnPettalents:SetHeight(22)
	btnLearnPettalents:SetPoint("LEFT", btnLearnLanguages, "RIGHT", 10, 0)
	btnLearnPettalents:SetText(L["Learn Pettalents"])
	TrinityAdmin.AutoSize(btnLearnPettalents, 20, 16)
	-- btnLearnPettalents:SetWidth(btnLearnPettalents:GetTextWidth() + 20)
	btnLearnPettalents:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Pettalents tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnPettalents:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnPettalents:SetScript("OnClick", function()
		local command = ".learn all pettalents"
		-- SendChatMessage(command, "SAY")
		TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	
	------------------------------
	-- 4) Boutons  "Learn Talents", "Learn Blizzard"
	------------------------------
	
	local btnLearnTalents = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnTalents:SetHeight(22)
	btnLearnTalents:SetPoint("LEFT", btnLearnCrafts, "BOTTOMLEFT", 0, -20)
	btnLearnTalents:SetText(L["Learn Talents"])
	TrinityAdmin.AutoSize(btnLearnTalents, 20, 16)
	-- btnLearnTalents:SetWidth(btnLearnTalents:GetTextWidth() + 20)
	btnLearnTalents:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Talents tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnTalents:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnTalents:SetScript("OnClick", function()
		local command = ".learn all talents"
		-- SendChatMessage(command, "SAY")
		TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	
	local btnLearnBlizzard = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnBlizzard:SetHeight(22)
	btnLearnBlizzard:SetPoint("LEFT", btnLearnTalents, "RIGHT", 10, 0)
	btnLearnBlizzard:SetText(L["Learn Blizzard"])
	TrinityAdmin.AutoSize(btnLearnBlizzard, 20, 16)
	-- btnLearnBlizzard:SetWidth(btnLearnBlizzard:GetTextWidth() + 20)
	btnLearnBlizzard:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Blizzard tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnBlizzard:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnBlizzard:SetScript("OnClick", function()
		local command = ".learn all blizzard"
		--SendChatMessage(command, "SAY")
		TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	
	------------------------------
	-- 5) Boutons "Learn my ..." (my Quests, my trainer, my talents)
	------------------------------
	local btnLearnMyQuests = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnMyQuests:SetHeight(22)
	btnLearnMyQuests:SetPoint("LEFT", btnLearnBlizzard, "RIGHT", 10, 0)
	btnLearnMyQuests:SetText(L["Learn my Quests"])
	TrinityAdmin.AutoSize(btnLearnMyQuests, 20, 16)
	-- btnLearnMyQuests:SetWidth(btnLearnMyQuests:GetTextWidth() + 20)
	btnLearnMyQuests:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn my Quests tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnMyQuests:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnMyQuests:SetScript("OnClick", function()
		local command = ".learn my quests"
		-- SendChatMessage(command, "SAY")
		TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	
	local btnLearnMyTrainer = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnMyTrainer:SetHeight(22)
	btnLearnMyTrainer:SetPoint("LEFT", btnLearnMyQuests, "RIGHT", 10, 0)
	btnLearnMyTrainer:SetText(L["Learn my trainer"])
	TrinityAdmin.AutoSize(btnLearnMyTrainer, 20, 16)
	-- btnLearnMyTrainer:SetWidth(btnLearnMyTrainer:GetTextWidth() + 20)
	btnLearnMyTrainer:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn my trainer tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnMyTrainer:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnMyTrainer:SetScript("OnClick", function()
		local command = ".learn my trainer"
		-- SendChatMessage(command, "SAY")
		TrinityAdmin:SendCommand(command)
		-- print("Commande envoyée: " .. command)
	end)
	
-- Pour la page 2 :
local commandsFramePage2 = CreateFrame("Frame", nil, pages[2])
commandsFramePage2:SetPoint("TOPLEFT", pages[2], "TOPLEFT", 20, -40)
commandsFramePage2:SetSize(500, 350)

local page2Title = commandsFramePage2:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
page2Title:SetPoint("TOPLEFT", commandsFramePage2, "TOPLEFT", 0, 0)
page2Title:SetText(L["Damages Panel"])

------------------------------
-- 1) Deal Damage
------------------------------
local damageAmountEdit = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
damageAmountEdit:SetSize(100, 22)
damageAmountEdit:SetPoint("TOPLEFT", page2Title, "BOTTOMLEFT", 0, -20)
damageAmountEdit:SetAutoFocus(false)
damageAmountEdit:SetText("Damage Amount")

local schoolEdit = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
schoolEdit:SetSize(100, 22)
schoolEdit:SetPoint("LEFT", damageAmountEdit, "RIGHT", 10, 0)
schoolEdit:SetAutoFocus(false)
schoolEdit:SetText("School")

local spellIdEdit2 = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
spellIdEdit2:SetSize(100, 22)
spellIdEdit2:SetPoint("LEFT", schoolEdit, "RIGHT", 10, 0)
spellIdEdit2:SetAutoFocus(false)
spellIdEdit2:SetText("Spell ID")

local btnDealDamage = CreateFrame("Button", nil, commandsFramePage2, "UIPanelButtonTemplate")
btnDealDamage:SetText(L["Deal Damage"])
btnDealDamage:SetHeight(22)
btnDealDamage:SetPoint("LEFT", spellIdEdit2, "RIGHT", 10, 0)
btnDealDamage:SetScript("OnShow", function(self)
    self:SetWidth(self:GetTextWidth() + 20)
end)
btnDealDamage:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Deal Damage tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnDealDamage:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnDealDamage:SetScript("OnClick", function()
    local dmgAmount = damageAmountEdit:GetText()
    if dmgAmount == "" or dmgAmount == "Damage Amount" then
        print(L["Deal_damage_error"])
        return
    end
    local command = ".damage " .. dmgAmount
    local school = schoolEdit:GetText()
    if school ~= "" and school ~= "School" then
        command = command .. " " .. school
    end
    local spellid = spellIdEdit2:GetText()
    if spellid ~= "" and spellid ~= "Spell ID" then
        command = command .. " " .. spellid
    end
    -- SendChatMessage(command, "SAY")
	TrinityAdmin:SendCommand(command)
    -- print("Commande envoyée: " .. command)
end)

------------------------------
-- 2) Damage GameObject
------------------------------
local guidEdit = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
guidEdit:SetSize(100, 22)
guidEdit:SetPoint("TOPLEFT", damageAmountEdit, "BOTTOMLEFT", 0, -30)
guidEdit:SetAutoFocus(false)
guidEdit:SetText("Guid")

local goDamageAmountEdit = CreateFrame("EditBox", nil, commandsFramePage2, "InputBoxTemplate")
goDamageAmountEdit:SetSize(100, 22)
goDamageAmountEdit:SetPoint("LEFT", guidEdit, "RIGHT", 10, 0)
goDamageAmountEdit:SetAutoFocus(false)
goDamageAmountEdit:SetText("Damage Amount")

local btnDamageGameObject = CreateFrame("Button", nil, commandsFramePage2, "UIPanelButtonTemplate")
btnDamageGameObject:SetText(L["Damage GameObject"])
btnDamageGameObject:SetHeight(22)
btnDamageGameObject:SetPoint("LEFT", goDamageAmountEdit, "RIGHT", 10, 0)
btnDamageGameObject:SetScript("OnShow", function(self)
    self:SetWidth(self:GetTextWidth() + 20)
end)
btnDamageGameObject:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Damage GameObject tooltip"], 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
btnDamageGameObject:SetScript("OnLeave", function() GameTooltip:Hide() end)
btnDamageGameObject:SetScript("OnClick", function()
    local guid = guidEdit:GetText()
    local dmgAmountGO = goDamageAmountEdit:GetText()
    if guid == "" or guid == "Guid" or dmgAmountGO == "" or dmgAmountGO == "Damage Amount" then
        print(L["deal_damage_gob_erreor"])
        return
    end
    local command = ".damage go " .. guid .. " " .. dmgAmountGO
    -- SendChatMessage(command, "SAY")
	TrinityAdmin:SendCommand(command)
    -- print("Commande envoyée: " .. command)
end)

     ------------------------------------------------------------------------------
    -- Boutons de navigation (précédent / suivant)
    ------------------------------------------------------------------------------
    local currentPage = 1

    local btnPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnPrev:SetSize(80, 22)
    btnPrev:SetText(L["Preview"])
    btnPrev:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    btnPrev:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            ShowPage(currentPage)
        end
    end)

    local btnNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnNext:SetSize(80, 22)
    btnNext:SetText(L["Next"])
    btnNext:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
    btnNext:SetScript("OnClick", function()
        if currentPage < totalPages then
            currentPage = currentPage + 1
            ShowPage(currentPage)
        end
    end)


    ------------------------------------------------------------------------------
    -- Fin du panneau, bouton Back déjà présent
    ------------------------------------------------------------------------------
    local btnBackFinal = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBackFinal:SetPoint("BOTTOM", panel, "BOTTOM", 0, 30)
    btnBackFinal:SetText(L["Back"])
    btnBackFinal:SetHeight(22)
    btnBackFinal:SetWidth(btnBackFinal:GetTextWidth() + 20)
    btnBackFinal:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end
