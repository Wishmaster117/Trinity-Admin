local L = _G.L
local TrinityAdmin = LibStub("AceAddon-3.0"):GetAddon("TrinityAdmin")
local DatabaseModule = TrinityAdmin:GetModule("DatabasePanel")
local L = LibStub("AceLocale-3.0"):GetLocale("TrinityAdmin")

 -- Liste complète des commandes reload
local reloadOptions = {
				{ text = "reload access_requirement", command = ".reload access_requirement", tooltip = L["reload_access_requirement"] },
				{ text = "reload achievement_reward", command = ".reload achievement_reward", tooltip = L["reload_achievement_reward"] },
				{ text = "reload achievement_reward_locale", command = ".reload achievement_reward_locale", tooltip = L["reload_achievement_reward_locale"] },
				{ text = "reload all", command = ".reload all", tooltip = L["reload_all"] },
				{ text = "reload all achievement", command = ".reload all achievement", tooltip = L["reload_all_achievement"] },
				{ text = "reload all area", command = ".reload all area", tooltip = L["reload_all_area"] },
				{ text = "reload all gossips", command = ".reload all gossips", tooltip = L["reload_all_gossips"] },
				{ text = "reload all item", command = ".reload all item", tooltip = L["reload_all_item"] },
				{ text = "reload all locales", command = ".reload all locales", tooltip = L["reload_all_locales"] },
				{ text = "reload all loot", command = ".reload all loot", tooltip = L["reload_all_loot"] },
				{ text = "reload all npc", command = ".reload all npc", tooltip = L["reload_all_npc"] },
				{ text = "reload all quest", command = ".reload all quest", tooltip = L["reload_all_quest"] },
				{ text = "reload all scripts", command = ".reload all scripts", tooltip = L["reload_all_scripts"] },
				{ text = "reload all spell", command = ".reload all spell", tooltip = L["reload_all_spell"] },
				{ text = "reload areatrigger_involvedrelation", command = ".reload areatrigger_involvedrelation", tooltip = L["reload_areatrigger_involvedrelation"] },
				{ text = "reload areatrigger_tavern", command = ".reload areatrigger_tavern", tooltip = L["reload_areatrigger_tavern"] },
				{ text = "reload areatrigger_teleport", command = ".reload areatrigger_teleport", tooltip = L["reload_areatrigger_teleport"] },
				{ text = "reload auctions", command = ".reload auctions", tooltip = L["reload_auctions"] },
				{ text = "reload autobroadcast", command = ".reload autobroadcast", tooltip = L["reload_autobroadcast"] },
				{ text = "reload battleground_template", command = ".reload battleground_template", tooltip = L["reload_battleground_template"] },
				{ text = "reload conditions", command = ".reload conditions", tooltip = L["reload_conditions"] },
				{ text = "reload config", command = ".reload config", tooltip = L["reload_config"] },
				{ text = "reload conversation_template", command = ".reload conversation_template", tooltip = L["reload_conversation_template"] },
				{ text = "reload creature_linked_respawn", command = ".reload creature_linked_respawn", tooltip = L["reload_creature_linked_respawn"] },
				{ text = "reload creature_loot_template", command = ".reload creature_loot_template", tooltip = L["reload_creature_loot_template"] },
				{ text = "reload creature_movement_override", command = ".reload creature_movement_override", tooltip = L["reload_creature_movement_override"] },
				{ text = "reload creature_onkill_reputation", command = ".reload creature_onkill_reputation", tooltip = L["reload_creature_onkill_reputation"] },
				{ text = "reload creature_questender", command = ".reload creature_questender", tooltip = L["reload_creature_questender"] },
				{ text = "reload creature_queststarter", command = ".reload creature_queststarter", tooltip = L["reload_creature_queststarter"] },
				{ text = "reload creature_summon_groups", command = ".reload creature_summon_groups", tooltip = L["reload_creature_summon_groups"] },
				{ text = "reload creature_template", command = ".reload creature_template", tooltip = L["reload_creature_template"] },
				{ text = "reload creature_template_locale", command = ".reload creature_template_locale", tooltip = L["reload_creature_template_locale"] },
				{ text = "reload creature_text", command = ".reload creature_text", tooltip = L["reload_creature_text"] },
				{ text = "reload creature_text_locale", command = ".reload creature_text_locale", tooltip = L["reload_creature_text_locale"] },
				{ text = "reload criteria_data", command = ".reload criteria_data", tooltip = L["reload_criteria_data"] },
				{ text = "reload disables", command = ".reload disables", tooltip = L["reload_disables"] },
				{ text = "reload disenchant_loot_template", command = ".reload disenchant_loot_template", tooltip = L["reload_disenchant_loot_template"] },
				{ text = "reload event_scripts", command = ".reload event_scripts", tooltip = L["reload_event_scripts"] },
				{ text = "reload fishing_loot_template", command = ".reload fishing_loot_template", tooltip = L["reload_fishing_loot_template"] },
				{ text = "reload game_tele", command = ".reload game_tele", tooltip = L["reload_game_tele"] },
				{ text = "reload gameobject_loot_template", command = ".reload gameobject_loot_template", tooltip = L["reload_gameobject_loot_template"] },
				{ text = "reload gameobject_questender", command = ".reload gameobject_questender", tooltip = L["reload_gameobject_questender"] },
				{ text = "reload gameobject_queststarter", command = ".reload gameobject_queststarter", tooltip = L["reload_gameobject_queststarter"] },
				{ text = "reload gameobject_template_locale", command = ".reload gameobject_template_locale", tooltip = L["reload_gameobject_template_locale"] },
				{ text = "reload gossip_menu", command = ".reload gossip_menu", tooltip = L["reload_gossip_menu"] },
				{ text = "reload gossip_menu_option", command = ".reload gossip_menu_option", tooltip = L["reload_gossip_menu_option"] },
				{ text = "reload gossip_menu_option_locale", command = ".reload gossip_menu_option_locale", tooltip = L["reload_gossip_menu_option_locale"] },
				{ text = "reload graveyard_zone", command = ".reload graveyard_zone", tooltip = L["reload_graveyard_zone"] },
				{ text = "reload item_loot_template", command = ".reload item_loot_template", tooltip = L["reload_item_loot_template"] },
				{ text = "reload item_random_bonus_list_template", command = ".reload item_random_bonus_list_template", tooltip = L["reload_item_random_bonus_list_template"] },
				{ text = "reload lfg_dungeon_rewards", command = ".reload lfg_dungeon_rewards", tooltip = L["reload_lfg_dungeon_rewards"] },
				{ text = "reload mail_level_reward", command = ".reload mail_level_reward", tooltip = L["reload_mail_level_reward"] },
				{ text = "reload mail_loot_template", command = ".reload mail_loot_template", tooltip = L["reload_mail_loot_template"] },
				{ text = "reload milling_loot_template", command = ".reload milling_loot_template", tooltip = L["reload_milling_loot_template"] },
				{ text = "reload npc_spellclick_spells", command = ".reload npc_spellclick_spells", tooltip = L["reload_npc_spellclick_spells"] },
				{ text = "reload npc_vendor", command = ".reload npc_vendor", tooltip = L["reload_npc_vendor"] },
				{ text = "reload page_text", command = ".reload page_text", tooltip = L["reload_page_text"] },
				{ text = "reload page_text_locale", command = ".reload page_text_locale", tooltip = L["reload_page_text_locale"] },
				{ text = "reload pickpocketing_loot_template", command = ".reload pickpocketing_loot_template", tooltip = L["reload_pickpocketing_loot_template"] },
				{ text = "reload points_of_interest", command = ".reload points_of_interest", tooltip = L["reload_points_of_interest"] },
				{ text = "reload points_of_interest_locale", command = ".reload points_of_interest_locale", tooltip = L["reload_points_of_interest_locale"] },
				{ text = "reload prospecting_loot_template", command = ".reload prospecting_loot_template", tooltip = L["reload_prospecting_loot_template"] },
				{ text = "reload quest_greeting", command = ".reload quest_greeting", tooltip = L["reload_quest_greeting"] },
				{ text = "reload quest_locale", command = ".reload quest_locale", tooltip = L["reload_quest_locale"] },
				{ text = "reload quest_poi", command = ".reload quest_poi", tooltip = L["reload_quest_poi"] },
				{ text = "reload quest_template", command = ".reload quest_template", tooltip = L["reload_quest_template"] },
				{ text = "reload rbac", command = ".reload rbac", tooltip = L["reload_rbac"] },
				{ text = "reload reference_loot_template", command = ".reload reference_loot_template", tooltip = L["reload_reference_loot_template"] },
				{ text = "reload reputation_reward_rate", command = ".reload reputation_reward_rate", tooltip = L["reload_reputation_reward_rate"] },
				{ text = "reload reputation_spillover_template", command = ".reload reputation_spillover_template", tooltip = L["reload_reputation_spillover_template"] },
				{ text = "reload reserved_name", command = ".reload reserved_name", tooltip = L["reload_reserved_name"] },
				{ text = "reload scene_template", command = ".reload scene_template", tooltip = L["reload_scene_template"] },
				{ text = "reload skill_discovery_template", command = ".reload skill_discovery_template", tooltip = L["reload_skill_discovery_template"] },
				{ text = "reload skill_extra_item_template", command = ".reload skill_extra_item_template", tooltip = L["reload_skill_extra_item_template"] },
				{ text = "reload skill_fishing_base_level", command = ".reload skill_fishing_base_level", tooltip = L["reload_skill_fishing_base_level"] },
				{ text = "reload skinning_loot_template", command = ".reload skinning_loot_template", tooltip = L["reload_skinning_loot_template"] },
				{ text = "reload smart_scripts", command = ".reload smart_scripts", tooltip = L["reload_smart_scripts"] },
				{ text = "reload spell_area", command = ".reload spell_area", tooltip = L["reload_spell_area"] },
				{ text = "reload spell_group", command = ".reload spell_group", tooltip = L["reload_spell_group"] },
				{ text = "reload spell_group_stack_rules", command = ".reload spell_group_stack_rules", tooltip = L["reload_spell_group_stack_rules"] },
				{ text = "reload spell_learn_spell", command = ".reload spell_learn_spell", tooltip = L["reload_spell_learn_spell"] },
				{ text = "reload spell_linked_spell", command = ".reload spell_linked_spell", tooltip = L["reload_spell_linked_spell"] },
				{ text = "reload spell_loot_template", command = ".reload spell_loot_template", tooltip = L["reload_spell_loot_template"] },
				{ text = "reload spell_pet_auras", command = ".reload spell_pet_auras", tooltip = L["reload_spell_pet_auras"] },
				{ text = "reload spell_proc", command = ".reload spell_proc", tooltip = L["reload_spell_proc"] },
				{ text = "reload spell_required", command = ".reload spell_required", tooltip = L["reload_spell_required"] },
				{ text = "reload spell_script_names", command = ".reload spell_script_names", tooltip = L["reload_spell_script_names"] },
				{ text = "reload spell_scripts", command = ".reload spell_scripts", tooltip = L["reload_spell_scripts"] },
				{ text = "reload spell_target_position", command = ".reload spell_target_position", tooltip = L["reload_spell_target_position"] },
				{ text = "reload spell_threats", command = ".reload spell_threats", tooltip = L["reload_spell_threats"] },
				{ text = "reload support", command = ".reload support", tooltip = L["reload_support"] },
				{ text = "reload trainer", command = ".reload trainer", tooltip = L["reload_trainer"] },
				{ text = "reload trinity_string", command = ".reload trinity_string", tooltip = L["reload_trinity_string"] },
				{ text = "reload vehicle_accessory", command = ".reload vehicle_accessory", tooltip = L["reload_vehicle_accessory"] },
				{ text = "reload vehicle_template", command = ".reload vehicle_template", tooltip = L["reload_vehicle_template"] },
				{ text = "reload vehicle_template_accessory", command = ".reload vehicle_template_accessory", tooltip = L["reload_vehicle_template_accessory"] },
				{ text = "reload waypoint_path", command = ".reload waypoint_path", tooltip = L["reload_waypoint_path"] },
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
    -- btnReload:SetSize(80, 22)
    btnReload:SetText(L["Reload"])
	TrinityAdmin.AutoSize(btnReload, 20, 16)
    btnReload:SetScript("OnClick", function()
   if dropdown.selectedOption then
      -- SendChatMessage(dropdown.selectedOption.command, "SAY")
	  TrinityAdmin:SendCommand(dropdown.selectedOption.command)
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
    panel.title:SetText(L["Database Management"])

    -- Création des 3 groupes de commandes
    -- Par exemple, on commence à y = -40 pour le premier groupe, puis on décale de -80 pour le second, -120 pour le troisième
    CreateDatabaseGroup(panel, L["Database Part 1"], part1Options, -40)
    CreateDatabaseGroup(panel, L["Database Part 2"], part2Options, -140)
    CreateDatabaseGroup(panel, L["Database Part 3"], part3Options, -240)

    -- Bouton Back pour revenir au menu principal
    local btnBack = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    btnBack:SetSize(80, 22)
    btnBack:SetText(L["Back"] or "Back")
    btnBack:SetScript("OnClick", function()
        panel:Hide()
        TrinityAdmin:ShowMainMenu()
    end)

    self.panel = panel
end