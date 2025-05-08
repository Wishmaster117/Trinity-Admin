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
	-- PAGE 1 : Learn Panel (modifié)
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
	spellIdEdit:SetSize(100, 22)
	spellIdEdit:SetPoint("TOPLEFT", page1Title, "BOTTOMLEFT", 0, -10)
	spellIdEdit:SetAutoFocus(false)
	spellIdEdit:SetText("Spell ID")
	
	local optionEdit = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	optionEdit:SetSize(100, 22)
	optionEdit:SetPoint("LEFT", spellIdEdit, "RIGHT", 10, 0)
	optionEdit:SetAutoFocus(false)
	optionEdit:SetText("Option")
	
	local btnLearn = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearn:SetHeight(22)
	btnLearn:SetPoint("LEFT", optionEdit, "RIGHT", 10, 0)
	btnLearn:SetText(L["LearnLP"])
	btnLearn:SetWidth(btnLearn:GetTextWidth() + 20)
	btnLearn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["LearnLP tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearn:SetScript("OnClick", function()
		local spellID = spellIdEdit:GetText()
		local optionVal = optionEdit:GetText()
		if spellID == "" or spellID == "Spell ID" then
			print("Erreur: Spell ID requis.")
			return
		end
		if not UnitName("target") then
			print(L["no_player_selected_error"])
			return
		end
		local command = ".learn " .. spellID
		if optionVal ~= "" and optionVal ~= "Option" then
			command = command .. " " .. optionVal
		end
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	
	------------------------------
	-- 2) Learn Him
	------------------------------
	local playerNameEdit = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	playerNameEdit:SetSize(100, 22)
	playerNameEdit:SetPoint("TOPLEFT", spellIdEdit, "BOTTOMLEFT", 0, -10)
	playerNameEdit:SetAutoFocus(false)
	playerNameEdit:SetText("Player Name")
	
	local btnLearnHim = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearnHim:SetHeight(22)
	btnLearnHim:SetPoint("LEFT", playerNameEdit, "RIGHT", 10, 0)
	btnLearnHim:SetText(L["Learn Him"])
	btnLearnHim:SetWidth(btnLearnHim:GetTextWidth() + 20)
	btnLearnHim:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Him Tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnHim:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnHim:SetScript("OnClick", function()
		local playerName = playerNameEdit:GetText()
		local command = ".learn all default"
		if playerName ~= "" and playerName ~= "Player Name" then
			command = command .. " " .. playerName
		else
			if not UnitName("target") then
				print(L["no_player_or_name_error"])
				return
			end
		end
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	
	-- Champ de saisie pour la Profession
	local professionEdit = CreateFrame("EditBox", nil, commandsFramePage1, "InputBoxTemplate")
	professionEdit:SetSize(100, 22)
	professionEdit:SetPoint("TOPLEFT", playerNameEdit, "BOTTOMLEFT", 0, -10)
	professionEdit:SetAutoFocus(false)
	professionEdit:SetText(L["Profession"])
	
	-- Bouton Learn Recipes utilisant la valeur du champ "Profession"
	local btnLearnRecipes = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearnRecipes:SetHeight(22)
	btnLearnRecipes:SetPoint("LEFT", professionEdit, "RIGHT", 10, 0)
	btnLearnRecipes:SetText(L["Learn Recipes"])
	btnLearnRecipes:SetWidth(btnLearnRecipes:GetTextWidth() + 20)
	btnLearnRecipes:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Recipes tooltips"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnRecipes:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnRecipes:SetScript("OnClick", function()
		local profession = professionEdit:GetText()
		local command = ".learn all recipes " .. profession
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	------------------------------
	-- 3) Boutons "Learn all ..." (Crafts, Debug, Languages, Pettalents)
	------------------------------
	-- Bouton Learn Crafts
	local btnLearnCrafts = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearnCrafts:SetHeight(22)
	btnLearnCrafts:SetPoint("TOPLEFT", professionEdit, "BOTTOMLEFT", 0, -20)
	btnLearnCrafts:SetText(L["Learn Crafts"])
	btnLearnCrafts:SetWidth(btnLearnCrafts:GetTextWidth() + 20)
	btnLearnCrafts:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Crafts tooltio"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnCrafts:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnCrafts:SetScript("OnClick", function()
		local command = ".learn all crafts"
		-- Si un joueur est sélectionné, la commande sera envoyée sur le target du GM (sans préfixer le nom)
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	
	-- Bouton Learn Debug
	local btnLearnDebug = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearnDebug:SetHeight(22)
	btnLearnDebug:SetPoint("LEFT", btnLearnCrafts, "RIGHT", 10, 0)
	btnLearnDebug:SetText(L["Learn Debug"])
	btnLearnDebug:SetWidth(btnLearnDebug:GetTextWidth() + 20)
	btnLearnDebug:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Debug Tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnDebug:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnDebug:SetScript("OnClick", function()
		local command = ".learn all debug"
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	
	-- Bouton Learn Languages
	local btnLearnLanguages = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearnLanguages:SetHeight(22)
	btnLearnLanguages:SetPoint("LEFT", btnLearnDebug, "RIGHT", 10, 0)
	btnLearnLanguages:SetText(L["Learn Languages"])
	btnLearnLanguages:SetWidth(btnLearnLanguages:GetTextWidth() + 20)
	btnLearnLanguages:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Languages tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnLanguages:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnLanguages:SetScript("OnClick", function()
		local command = ".learn all languages"
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	
	-- Bouton Learn Pettalents
	local btnLearnPettalents = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearnPettalents:SetHeight(22)
	btnLearnPettalents:SetPoint("LEFT", btnLearnLanguages, "RIGHT", 10, 0)
	btnLearnPettalents:SetText(L["Learn Pettalents"])
	btnLearnPettalents:SetWidth(btnLearnPettalents:GetTextWidth() + 20)
	btnLearnPettalents:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Pettalents tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnPettalents:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnPettalents:SetScript("OnClick", function()
		local command = ".learn all pettalents"
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	
	------------------------------
	-- 4) Boutons  "Learn Talents", "Learn Blizzard"
	------------------------------
	
	local btnLearnTalents = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearnTalents:SetHeight(22)
	btnLearnTalents:SetPoint("LEFT", btnLearnCrafts, "BOTTOMLEFT", 0, -20)
	btnLearnTalents:SetText(L["Learn Talents"])
	btnLearnTalents:SetWidth(btnLearnTalents:GetTextWidth() + 20)
	btnLearnTalents:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Talents tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnTalents:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnTalents:SetScript("OnClick", function()
		local command = ".learn all talents"
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	
	local btnLearnBlizzard = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearnBlizzard:SetHeight(22)
	btnLearnBlizzard:SetPoint("LEFT", btnLearnTalents, "RIGHT", 10, 0)
	btnLearnBlizzard:SetText(L["Learn Blizzard"])
	btnLearnBlizzard:SetWidth(btnLearnBlizzard:GetTextWidth() + 20)
	btnLearnBlizzard:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn Blizzard tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnBlizzard:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnBlizzard:SetScript("OnClick", function()
		local command = ".learn all blizzard"
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	
	------------------------------
	-- 5) Boutons "Learn my ..." (my Quests, my trainer, my talents)
	------------------------------
	local btnLearnMyQuests = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearnMyQuests:SetHeight(22)
	btnLearnMyQuests:SetPoint("LEFT", btnLearnBlizzard, "RIGHT", 10, 0)
	btnLearnMyQuests:SetText(L["Learn my Quests"])
	btnLearnMyQuests:SetWidth(btnLearnMyQuests:GetTextWidth() + 20)
	btnLearnMyQuests:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn my Quests tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnMyQuests:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnMyQuests:SetScript("OnClick", function()
		local command = ".learn my quests"
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	
	local btnLearnMyTrainer = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	btnLearnMyTrainer:SetHeight(22)
	btnLearnMyTrainer:SetPoint("LEFT", btnLearnMyQuests, "RIGHT", 10, 0)
	btnLearnMyTrainer:SetText(L["Learn my trainer"])
	btnLearnMyTrainer:SetWidth(btnLearnMyTrainer:GetTextWidth() + 20)
	btnLearnMyTrainer:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn my trainer tooltip"], 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	btnLearnMyTrainer:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btnLearnMyTrainer:SetScript("OnClick", function()
		local command = ".learn my trainer"
		SendChatMessage(command, "SAY")
		-- print("Commande envoyée: " .. command)
	end)
	
	-- local btnLearnMyTalents = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnMyTalents:SetHeight(22)
	-- btnLearnMyTalents:SetPoint("LEFT", btnLearnMyTrainer, "RIGHT", 10, 0)
	-- btnLearnMyTalents:SetText("Learn my talents")
	-- btnLearnMyTalents:SetWidth(btnLearnMyTalents:GetTextWidth() + 20)
	-- btnLearnMyTalents:SetScript("OnEnter", function(self)
	-- 	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	-- 	GameTooltip:SetText("Syntax: .learn all my talents. Learn all talents (and spells with first rank learned as talent) available for his class.", 1, 1, 1, 1, true)
	-- 	GameTooltip:Show()
	-- end)
	-- btnLearnMyTalents:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- btnLearnMyTalents:SetScript("OnClick", function()
	-- 	local command = ".learn my talents"
	-- 	SendChatMessage(command, "SAY")
	-- 	print("Commande envoyée: " .. command)
	-- end)
	
	------------------------------
	-- 6) Boutons "Learn my ..." (my spells, my pettalents, my class)
	------------------------------
	-- local btnLearnMySpells = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnMySpells:SetHeight(22)
	-- btnLearnMySpells:SetPoint("TOPLEFT", btnLearnTalents, "BOTTOMLEFT", 0, -20)
	-- btnLearnMySpells:SetText("Learn my spells")
	-- btnLearnMySpells:SetWidth(btnLearnMySpells:GetTextWidth() + 20)
	-- btnLearnMySpells:SetScript("OnEnter", function(self)
	-- 	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	-- 	GameTooltip:SetText("Syntax: .learn all my spells. Learn all spells (except talents and spells with first rank learned as talent) available for his class.", 1, 1, 1, 1, true)
	-- 	GameTooltip:Show()
	-- end)
	-- btnLearnMySpells:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- btnLearnMySpells:SetScript("OnClick", function()
	-- 	local command = ".learn my spells"
	-- 	SendChatMessage(command, "SAY")
	-- 	print("Commande envoyée: " .. command)
	-- end)
	-- 
	-- local btnLearnMyPetTalents = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnMyPetTalents:SetHeight(22)
	-- btnLearnMyPetTalents:SetPoint("LEFT", btnLearnMySpells, "RIGHT", 10, 0)
	-- btnLearnMyPetTalents:SetText("Learn my pettalents")
	-- btnLearnMyPetTalents:SetWidth(btnLearnMyPetTalents:GetTextWidth() + 20)
	-- btnLearnMyPetTalents:SetScript("OnEnter", function(self)
	-- 	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	-- 	GameTooltip:SetText("Syntax: .learn all my pettalents. Learn all talents for your pet available for his creature type (only for hunter pets).", 1, 1, 1, 1, true)
	-- 	GameTooltip:Show()
	-- end)
	-- btnLearnMyPetTalents:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- btnLearnMyPetTalents:SetScript("OnClick", function()
	-- 	local command = ".learn my pettalents"
	-- 	SendChatMessage(command, "SAY")
	-- 	print("Commande envoyée: " .. command)
	-- end)
	-- 
	-- local btnLearnMyClass = CreateFrame("Button", nil, commandsFramePage1, "UIPanelButtonTemplate")
	-- btnLearnMyClass:SetHeight(22)
	-- btnLearnMyClass:SetPoint("LEFT", btnLearnMyPetTalents, "RIGHT", 10, 0)
	-- btnLearnMyClass:SetText("Learn my class")
	-- btnLearnMyClass:SetWidth(btnLearnMyClass:GetTextWidth() + 20)
	-- btnLearnMyClass:SetScript("OnEnter", function(self)
	-- 	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	-- 	GameTooltip:SetText("Syntax: .learn all my class. Learn all spells and talents available for his class.", 1, 1, 1, 1, true)
	-- 	GameTooltip:Show()
	-- end)
	-- btnLearnMyClass:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- btnLearnMyClass:SetScript("OnClick", function()
	-- 	local command = ".learn my class"
	-- 	SendChatMessage(command, "SAY")
	-- 	print("Commande envoyée: " .. command)
	-- end)



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
    SendChatMessage(command, "SAY")
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
    SendChatMessage(command, "SAY")
    -- print("Commande envoyée: " .. command)
end)


    ------------------------------------------------------------------------------
    -- Bouton helper pour créer des boutons simples (comme précédemment)
    ------------------------------------------------------------------------------
    -- local function CreateServerButton(name, text, tooltip, cmd)
    --     local btn = CreateFrame("Button", name, nil, "UIPanelButtonTemplate")
    --     btn:SetSize(150, 22)
    --     btn:SetText(text)
    --     btn:SetScript("OnEnter", function(self)
    --         GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    --         GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
    --         GameTooltip:Show()
    --     end)
    --     btn:SetScript("OnLeave", function(self)
    --         GameTooltip:Hide()
    --     end)
    --     btn:SetScript("OnClick", function(self)
    --         SendChatMessage(cmd, "SAY")
    --         print("Commande envoyée: " .. cmd)
    --     end)
    --     return btn
    -- end

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
