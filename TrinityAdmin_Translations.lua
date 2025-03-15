-- TrinityAdmin_Translations.lua
local L = {}
local locale = GetLocale()

if locale == "frFR" then
	L["GM Functions Panel"]     = "Panneau des Fonctions GM"
    L["TrinityAdmin Main Menu"] = "TrinityAdmin par TheWarlock"
    L["Teleport Panel"]         = "Panneau des Téléportations"
	L["No_Teleport_Data_Found"] = "Aucun continent trouvé dans TeleportData!"
	L["Select_Zone"]            = "Sélectionnez une zone"
	L["Select_Continent"]     	= "Sélectionnez un continent"
	L["Select_Location"]      	= "Sélectionnez un lieu"
	L["Modify_Panel"]         	= "Panneau de Modifications"
	L["Speed"]    				= "Vitesse"
	L["Money"]    				= "Argent"
	L["Hp"]       				= "PV"
	L["Xp"]       				= "XP"
	L["Scale"]    				= "Taille"
	L["Currency"] 				= "Monnaie"
	L["Add_Money"] 				= "Ajoute le montant de Monnaie (Emblemes etc...) = ID au joueur, si aucun joueur n'est selectionné vous l'ajoute à vous. Syntaxe: ID + espace + montant"
	L["Modify_Speed"] 			= "Modifie votre vitesse de déplacement : Valeurs de 1 à 100"
	L["Modify_Money"] 			= "Modifie l'argent du joueur, si aucun joueur n'est selectionné, modifie le votre (en pieces de cuivre 10000 cuivre = 1 or)"
	L["Modify_HP"]   			= "Modifie les HP du joueur, si aucun joueur n'est selectionné, modifie vos HP (Points de vie)"
	L["Modify_XP"]   			= "Modifie le XP du joueur, si aucun joueur n'est selectionné, modifie votre XP"
	L["Modify_Scale"]   		= "Modifie la taille du joueur, si aucun joueur n'est selectionné, modifie votre taille (valeurs de 0.1 à 10)"
	L["Enter_Valid_Value"] 		= "Veuillez entrer une valeur valide."
	L["Enter_Valid_Currency"] 	= "Veuillez entrer un id et un montant séparés par un espace pour la currency."
	L["Free_Panel"]    			= "Panneau à Définir"
	L["Back"]                 	= "Retour"
	
	L["Faction"]                = "Faction"
	L["Gender"]                 = "Genre"
	L["Modify_Faction"]         = "Selectionnez une créature pour lui changer sa faction."
	L["Modify_Gender"]          = "Modifie le genre du Joueur, valeurs possibles (male/female)."
	L["Acoount_Panel"]          = "Panneau de Gestion des comptes"
	
	
    -- Ajoutez ici toutes les chaînes dont vous avez besoin...
elseif locale == "enUS" then
    L["GM Functions Panel"]     = "GM Functions Panel"
	L["TrinityAdmin Main Menu"] = "TrinityAdmin By TheWarlock"
    L["Teleport Panel"]         = "Teleport Panel"
	L["No_Teleport_Data_Found"] = "No continent found in TeleportData!"
	L["Select_Zone"]            = "Select Zone"
	L["Select_Continent"]     	= "Select Continent"
	L["Select_Location"]      	= "Select Location"
	L["Modify_Panel"]         	= "Modifications Panel"
	L["Speed"]    				= "Speed"
	L["Money"]    				= "Money"
	L["Hp"]       				= "Hp"
	L["Xp"]       				= "Xp"
	L["Scale"]    				= "Scale"
	L["Currency"] 				= "Currency"
	L["Modify_Speed"]  	        = "Modifies your movement speed: values from 1 to 100"
	L["Add_Money"] 				= "Adds the specified amount of currency (Emblems, etc.) = ID to the player. If no player is selected, it is added to you. Syntax: ID + space + amount"
	L["Modify_Money"] 			= "Modifies the player's money. If no player is selected, it modifies yours (in copper coins, 10000 copper = 1 gold)"
	L["Modify_HP"] 				= "Modifies the player's HP. If no player is selected, it modifies your HP (Health Points)"
	L["Modify_XP"] 				= "Modifies the player's XP. If no player is selected, it modifies your XP"
	L["Modify_Scale"] 			= "Modifies the player's size. If no player is selected, it modifies your size (values from 0.1 to 10)"
	L["Enter_Valid_Value"] 		= "Please enter a valid value."
	L["Enter_Valid_Currency"] 	= "Please enter an ID and an amount separated by a space for the currency."
	L["Free_Panel"] 			= "Panel to be Defined"
	L["Back"]                 	= "Back"
    
    
    -- Ajoutez ici les traductions en anglais...
end

TrinityAdmin_Translations = L
