local DatabaseModule = TrinityAdmin:GetModule("DatabasePanel")
 -- Liste complète des commandes reload
local reloadOptions = {
    { text = "reload access_requirement", command = ".reload access_requirement", tooltip = "Syntax: .reload access_requirement" },
    { text = "reload achievement_reward", command = ".reload achievement_reward", tooltip = "Syntax: .reload achievement_reward" },
    { text = "reload achievement_reward_locale", command = ".reload achievement_reward_locale", tooltip = "Syntax: .reload achievement_reward_locale" },
    { text = "reload all", command = ".reload all", tooltip = "Syntax: .reload all" },
    { text = "reload all achievement", command = ".reload all achievement", tooltip = "Syntax: .reload all achievement" },
    { text = "reload all area", command = ".reload all area", tooltip = "Syntax: .reload all area" },
    { text = "reload all gossips", command = ".reload all gossips", tooltip = "Syntax: .reload all gossips" },
    { text = "reload all item", command = ".reload all item", tooltip = "Syntax: .reload all item" },
    { text = "reload all locales", command = ".reload all locales", tooltip = "Syntax: .reload all locales" },
    { text = "reload all loot", command = ".reload all loot", tooltip = "Syntax: .reload all loot" },
    { text = "reload all npc", command = ".reload all npc", tooltip = "Syntax: .reload all npc" },
    { text = "reload all quest", command = ".reload all quest", tooltip = "Syntax: .reload all quest" },
    { text = "reload all scripts", command = ".reload all scripts", tooltip = "Syntax: .reload all scripts" },
    { text = "reload all spell", command = ".reload all spell", tooltip = "Syntax: .reload all spell" },
    { text = "reload areatrigger_involvedrelation", command = ".reload areatrigger_involvedrelation", tooltip = "Syntax: .reload areatrigger_involvedrelation" },
    { text = "reload areatrigger_tavern", command = ".reload areatrigger_tavern", tooltip = "Syntax: .reload areatrigger_tavern" },
    { text = "reload areatrigger_teleport", command = ".reload areatrigger_teleport", tooltip = "Syntax: .reload areatrigger_teleport" },
    { text = "reload auctions", command = ".reload auctions", tooltip = "Syntax: .reload auctions" },
    { text = "reload autobroadcast", command = ".reload autobroadcast", tooltip = "Syntax: .reload autobroadcast" },
    { text = "reload battleground_template", command = ".reload battleground_template", tooltip = "Syntax: .reload battleground_template" },
    { text = "reload conditions", command = ".reload conditions", tooltip = "Syntax: .reload conditions" },
    { text = "reload config", command = ".reload config", tooltip = "Syntax: .reload config" },
    { text = "reload conversation_template", command = ".reload conversation_template", tooltip = "Syntax: .reload conversation_template" },
    { text = "reload creature_linked_respawn", command = ".reload creature_linked_respawn", tooltip = "Syntax: .reload creature_linked_respawn" },
    { text = "reload creature_loot_template", command = ".reload creature_loot_template", tooltip = "Syntax: .reload creature_loot_template" },
    { text = "reload creature_movement_override", command = ".reload creature_movement_override", tooltip = "Syntax: .reload creature_movement_override" },
    { text = "reload creature_onkill_reputation", command = ".reload creature_onkill_reputation", tooltip = "Syntax: .reload creature_onkill_reputation" },
    { text = "reload creature_questender", command = ".reload creature_questender", tooltip = "Syntax: .reload creature_questender" },
    { text = "reload creature_queststarter", command = ".reload creature_queststarter", tooltip = "Syntax: .reload creature_queststarter" },
    { text = "reload creature_summon_groups", command = ".reload creature_summon_groups", tooltip = "Syntax: .reload creature_summon_groups" },
    { text = "reload creature_template", command = ".reload creature_template", tooltip = "Syntax: .reload creature_template" },
    { text = "reload creature_template_locale", command = ".reload creature_template_locale", tooltip = "Syntax: .reload creature_template_locale" },
    { text = "reload creature_text", command = ".reload creature_text", tooltip = "Syntax: .reload creature_text" },
    { text = "reload creature_text_locale", command = ".reload creature_text_locale", tooltip = "Syntax: .reload creature_text_locale" },
    { text = "reload criteria_data", command = ".reload criteria_data", tooltip = "Syntax: .reload criteria_data" },
    { text = "reload disables", command = ".reload disables", tooltip = "Syntax: .reload disables" },
    { text = "reload disenchant_loot_template", command = ".reload disenchant_loot_template", tooltip = "Syntax: .reload disenchant_loot_template" },
    { text = "reload event_scripts", command = ".reload event_scripts", tooltip = "Syntax: .reload event_scripts" },
    { text = "reload fishing_loot_template", command = ".reload fishing_loot_template", tooltip = "Syntax: .reload fishing_loot_template" },
    { text = "reload game_tele", command = ".reload game_tele", tooltip = "Syntax: .reload game_tele" },
    { text = "reload gameobject_loot_template", command = ".reload gameobject_loot_template", tooltip = "Syntax: .reload gameobject_loot_template" },
    { text = "reload gameobject_questender", command = ".reload gameobject_questender", tooltip = "Syntax: .reload gameobject_questender" },
    { text = "reload gameobject_queststarter", command = ".reload gameobject_queststarter", tooltip = "Syntax: .reload gameobject_queststarter" },
    { text = "reload gameobject_template_locale", command = ".reload gameobject_template_locale", tooltip = "Syntax: .reload gameobject_template_locale" },
    { text = "reload gossip_menu", command = ".reload gossip_menu", tooltip = "Syntax: .reload gossip_menu" },
    { text = "reload gossip_menu_option", command = ".reload gossip_menu_option", tooltip = "Syntax: .reload gossip_menu_option" },
    { text = "reload gossip_menu_option_locale", command = ".reload gossip_menu_option_locale", tooltip = "Syntax: .reload gossip_menu_option_locale" },
    { text = "reload graveyard_zone", command = ".reload graveyard_zone", tooltip = "Syntax: .reload graveyard_zone" },
    { text = "reload item_loot_template", command = ".reload item_loot_template", tooltip = "Syntax: .reload item_loot_template" },
    { text = "reload item_random_bonus_list_template", command = ".reload item_random_bonus_list_template", tooltip = "Syntax: .reload item_random_bonus_list_template" },
    { text = "reload lfg_dungeon_rewards", command = ".reload lfg_dungeon_rewards", tooltip = "Syntax: .reload lfg_dungeon_rewards" },
    { text = "reload mail_level_reward", command = ".reload mail_level_reward", tooltip = "Syntax: .reload mail_level_reward" },
    { text = "reload mail_loot_template", command = ".reload mail_loot_template", tooltip = "Syntax: .reload mail_loot_template" },
    { text = "reload milling_loot_template", command = ".reload milling_loot_template", tooltip = "Syntax: .reload milling_loot_template" },
    { text = "reload npc_spellclick_spells", command = ".reload npc_spellclick_spells", tooltip = "Syntax: .reload npc_spellclick_spells" },
    { text = "reload npc_vendor", command = ".reload npc_vendor", tooltip = "Syntax: .reload npc_vendor" },
    { text = "reload page_text", command = ".reload page_text", tooltip = "Syntax: .reload page_text" },
    { text = "reload page_text_locale", command = ".reload page_text_locale", tooltip = "Syntax: .reload page_text_locale" },
    { text = "reload pickpocketing_loot_template", command = ".reload pickpocketing_loot_template", tooltip = "Syntax: .reload pickpocketing_loot_template" },
    { text = "reload points_of_interest", command = ".reload points_of_interest", tooltip = "Syntax: .reload points_of_interest" },
    { text = "reload points_of_interest_locale", command = ".reload points_of_interest_locale", tooltip = "Syntax: .reload points_of_interest_locale" },
    { text = "reload prospecting_loot_template", command = ".reload prospecting_loot_template", tooltip = "Syntax: .reload prospecting_loot_template" },
    { text = "reload quest_greeting", command = ".reload quest_greeting", tooltip = "Syntax: .reload quest_greeting" },
    { text = "reload quest_locale", command = ".reload quest_locale", tooltip = "Syntax: .reload quest_locale" },
    { text = "reload quest_poi", command = ".reload quest_poi", tooltip = "Syntax: .reload quest_poi" },
    { text = "reload quest_template", command = ".reload quest_template", tooltip = "Syntax: .reload quest_template" },
    { text = "reload rbac", command = ".reload rbac", tooltip = "Syntax: .reload rbac" },
    { text = "reload reference_loot_template", command = ".reload reference_loot_template", tooltip = "Syntax: .reload reference_loot_template" },
    { text = "reload reputation_reward_rate", command = ".reload reputation_reward_rate", tooltip = "Syntax: .reload reputation_reward_rate" },
    { text = "reload reputation_spillover_template", command = ".reload reputation_spillover_template", tooltip = "Syntax: .reload reputation_spillover_template" },
    { text = "reload reserved_name", command = ".reload reserved_name", tooltip = "Syntax: .reload reserved_name" },
    { text = "reload scene_template", command = ".reload scene_template", tooltip = "Syntax: .reload scene_template" },
    { text = "reload skill_discovery_template", command = ".reload skill_discovery_template", tooltip = "Syntax: .reload skill_discovery_template" },
    { text = "reload skill_extra_item_template", command = ".reload skill_extra_item_template", tooltip = "Syntax: .reload skill_extra_item_template" },
    { text = "reload skill_fishing_base_level", command = ".reload skill_fishing_base_level", tooltip = "Syntax: .reload skill_fishing_base_level" },
    { text = "reload skinning_loot_template", command = ".reload skinning_loot_template", tooltip = "Syntax: .reload skinning_loot_template" },
    { text = "reload smart_scripts", command = ".reload smart_scripts", tooltip = "Syntax: .reload smart_scripts" },
    { text = "reload spell_area", command = ".reload spell_area", tooltip = "Syntax: .reload spell_area" },
    { text = "reload spell_group", command = ".reload spell_group", tooltip = "Syntax: .reload spell_group" },
    { text = "reload spell_group_stack_rules", command = ".reload spell_group_stack_rules", tooltip = "Syntax: .reload spell_group_stack_rules" },
    { text = "reload spell_learn_spell", command = ".reload spell_learn_spell", tooltip = "Syntax: .reload spell_learn_spell" },
    { text = "reload spell_linked_spell", command = ".reload spell_linked_spell", tooltip = "Syntax: .reload spell_linked_spell" },
    { text = "reload spell_loot_template", command = ".reload spell_loot_template", tooltip = "Syntax: .reload spell_loot_template" },
    { text = "reload spell_pet_auras", command = ".reload spell_pet_auras", tooltip = "Syntax: .reload spell_pet_auras" },
    { text = "reload spell_proc", command = ".reload spell_proc", tooltip = "Syntax: .reload spell_proc" },
    { text = "reload spell_required", command = ".reload spell_required", tooltip = "Syntax: .reload spell_required" },
    { text = "reload spell_script_names", command = ".reload spell_script_names", tooltip = "Syntax: .reload spell_script_names" },
    { text = "reload spell_scripts", command = ".reload spell_scripts", tooltip = "Syntax: .reload spell_scripts" },
    { text = "reload spell_target_position", command = ".reload spell_target_position", tooltip = "Syntax: .reload spell_target_position" },
    { text = "reload spell_threats", command = ".reload spell_threats", tooltip = "Syntax: .reload spell_threats" },
    { text = "reload support", command = ".reload support", tooltip = "Syntax: .reload support" },
    { text = "reload trainer", command = ".reload trainer", tooltip = "Syntax: .reload trainer" },
    { text = "reload trinity_string", command = ".reload trinity_string", tooltip = "Syntax: .reload trinity_string" },
    { text = "reload vehicle_accessory", command = ".reload vehicle_accessory", tooltip = "Reloads GUID-based vehicle accessory definitions from the database." },
    { text = "reload vehicle_template", command = ".reload vehicle_template", tooltip = "Reloads vehicle template definitions from the database." },
    { text = "reload vehicle_template_accessory", command = ".reload vehicle_template_accessory", tooltip = "Reloads entry-based vehicle accessory definitions from the database." },
    { text = "reload waypoint_path", command = ".reload waypoint_path", tooltip = "Will reload waypoint_path and waypoint_path_node tables." },
}

-- Fonction pour diviser la liste en trois parties
local function SplitOptions(options)
    local total = #options
    local partSize = math.ceil(total / 3)
    local part1, part2, part3 = {}, {}, {}
    for i = 1, total do
        if i <= partSize then
            table.insert(part1, options[i])
        elseif i <= partSize * 2 then
            table.insert(part2, options[i])
        else
            table.insert(part3, options[i])
        end
    end
    return part1, part2, part3
end

local part1Options, part2Options, part3Options = SplitOptions(reloadOptions)

-- Fonction utilitaire pour créer un groupe (sous‑panel) de commande
local function CreateDatabaseGroup(parent, titleText, options, yOffset)
    -- Titre de la partie
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    title:SetText(titleText)

    -- Crée un nom unique pour le dropdown
local dropdownName = (parent:GetName() or "Parent") .. "Dropdown_" .. yOffset
local dropdown = CreateFrame("Frame", dropdownName, parent, "UIDropDownMenuTemplate")
dropdown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
UIDropDownMenu_SetWidth(dropdown, 220)
UIDropDownMenu_SetButtonWidth(dropdown, 240)

-- On stocke la sélection directement dans le dropdown
dropdown.selectedOption = options[1]

dropdown.selectedID = 1  -- par défaut, on sélectionne la 1re option

UIDropDownMenu_Initialize(dropdown, function(dropdownFrame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for i, option in ipairs(options) do
        info.text = option.text
        info.value = option.command

        -- Marque l'élément «coché» si c'est celui qu'on a sélectionné
        info.checked = (i == dropdown.selectedID)

        -- Quand on clique sur cet élément
        info.func = function(buttonFrame)
            -- Mémorise l'ID sélectionné
            dropdown.selectedID = i
            -- Met à jour le texte et la «valeur» du dropdown
            UIDropDownMenu_SetSelectedID(dropdown, i)
            -- Stocke les données de l’option choisie
            dropdown.selectedOption = option
        end

        UIDropDownMenu_AddButton(info, level)
    end
end)

-- Pour afficher le texte de la première option dès le départ
UIDropDownMenu_SetSelectedID(dropdown, dropdown.selectedID)
UIDropDownMenu_SetText(dropdown, options[dropdown.selectedID].text)
dropdown.selectedOption = options[dropdown.selectedID]
UIDropDownMenu_SetText(dropdown, options[1].text)
	
    -- Bouton Reload pour ce groupe
    local btnReload = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btnReload:SetPoint("LEFT", dropdown, "RIGHT", 10, 0)
    btnReload:SetSize(80, 22)
    btnReload:SetText("Reload")
    btnReload:SetScript("OnClick", function()
   if dropdown.selectedOption then
      SendChatMessage(dropdown.selectedOption.command, "SAY")
   end
end)
btnReload:SetScript("OnEnter", function(self)
   GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
   GameTooltip:SetText(dropdown.selectedOption.tooltip, 1, 1, 1, 1, true)
   GameTooltip:Show()
end)
btnReload:SetScript("OnLeave", function(self)
   GameTooltip:Hide()
end)
end

function DatabaseModule:ShowDatabasePanel()
    TrinityAdmin:HideMainMenu()
    if not self.panel then
        self:CreateDatabasePanel()
    end
    self.panel:Show()
end

function DatabaseModule:CreateDatabasePanel()
    local panel = CreateFrame("Frame", "TrinityAdminDatabasePanel", TrinityAdminMainFrame)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", TrinityAdminMainFrame, "TOPLEFT", 10, -50)
    panel:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", -10, 10)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.2, 0.2, 0.5, 0.7)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 10, -10)
    panel.title:SetText("Database Panel")

    -- Création des 3 groupes de commandes
    -- Par exemple, on commence à y = -40 pour le premier groupe, puis on décale de -80 pour le second, -120 pour le troisième
    CreateDatabaseGroup(panel, "Database Part 1", part1Options, -40)
    CreateDatabaseGroup(panel, "Database Part 2", part2Options, -140)
    CreateDatabaseGroup(panel, "Database Part 3", part3Options, -240)

    -- Bouton Back pour revenir au menu principal
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetSize(80, 22)
    btnBack:SetText(TrinityAdmin_Translations["Back"] or "Back")
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end