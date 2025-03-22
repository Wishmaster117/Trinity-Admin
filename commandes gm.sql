-- --------------------------------------------------------
-- Hôte:                         127.0.0.1
-- Version du serveur:           8.0.34 - MySQL Community Server - GPL
-- SE du serveur:                Win64
-- HeidiSQL Version:             12.10.0.7000
-- --------------------------------------------------------

idées:

Pour npc show loot, afficher les loots dans une fenetre séparée
Pour npc info il faut trier les données a afficher.gobject info il faut trier les données a afficher et creer un builder pour bouger l objet
	
	Amettre dans le panneau GM:
	
	('dev', 'Syntax: .dev [on/off]\r\n\r\nEnable or Disable in game Dev tag or show current state if on/off not provided.'),
	('announce', 'Syntax: .announce $MessageToBroadcast\r\n\r\nSend a global message to all players online in chat log.'), --> Mettre dans le panneau GM
		('gmannounce', 'Syntax: .gmannounce $announcement\r\nSend an announcement to online Gamemasters.'),
	('gmnameannounce', 'Syntax: .gmnameannounce $announcement.\r\nSend an announcement to all online GM\'s, displaying the name of the sender.'),
	('gmnotify', 'Syntax: .gmnotify $notification\r\nDisplays a notification on the screen of all online GM\'s.'),
	
	
	('arena', 'Syntax: arena $subcommand\n Type .arena to see a list of possible subcommands\n or .help arena $subcommand to see info on the subcommand.'),
	('arena captain', 'Syntax: .arena captain #TeamID $name\n\nA command to set new captain to the team $name must be in the team'),
	('arena create', 'Syntax: .arena create $name "arena name" #type\n\nA command to create a new Arena-team in game. #type  = [2/3/5]'),
	('arena disband', 'Syntax: .arena disband #TeamID\n\nA command to disband Arena-team in game.'),
	('arena info', 'Syntax: .arena info #TeamID\n\nA command that show info about arena team'),
	('arena lookup', 'Syntax: .arena lookup $name\n\nA command that give a list of arenateam with the given $name'),
	('arena rename', 'Syntax: .arena rename "oldname" "newname"\n\nA command to rename Arena-team name.'),
	
	
	

	
	('bf', 'Syntax: bf $subcommand\n Type .bf to see a list of possible subcommands\n or .help bf $subcommand to see info on the subcommand.'),
	('bf enable', 'Syntax: .bf enable #battleid'),
	('bf start', 'Syntax: .bf start #battleid'),
	('bf stop', 'Syntax: .bf stop #battleid'),
	('bf switch', 'Syntax: .bf switch #battleid'),
	('bf timer', 'Syntax: .bf timer #battleid #timer'),
	
	
	
	('cast', 'Syntax: .cast #spellid [triggered]\r\n  Cast #spellid to selected target. If no target selected cast to self. If \'triggered\' or part provided then spell casted with triggered flag.'),
	('cast back', 'Syntax: .cast back #spellid [triggered]\r\n  Selected target will cast #spellid to your character. If \'triggered\' or part provided then spell casted with triggered flag.'),
	('cast dest', 'Syntax: .cast dest #spellid #x #y #z [triggered]\r\n  Selected target will cast #spellid at provided destination. If \'triggered\' or part provided then spell casted with triggered flag.'),
	('cast dist', 'Syntax: .cast dist #spellid [#dist [triggered]]\r\n  You will cast spell to pint at distance #dist. If \'triggered\' or part provided then spell casted with triggered flag. Not all spells can be casted as area spells.'),
	('cast self', 'Syntax: .cast self #spellid [triggered]\r\nCast #spellid by target at target itself. If \'triggered\' or part provided then spell casted with triggered flag.'),
	('cast target', 'Syntax: .cast target #spellid [triggered]\r\n  Selected target will cast #spellid to his victim. If \'triggered\' or part provided then spell casted with triggered flag.'),
	('channel', 'Syntax: channel $subcommand\n Type .channel to see a list of possible subcommands\n or .help channel $subcommand to see info on the subcommand.'),
	('channel set', 'Syntax: '),
	('channel set ownership', 'Syntax: .channel set ownership $channel [on/off]\n\nGrant ownership to the first person that joins the channel.'),
	
	
	('cheat', 'Syntax: .cheat $subcommand\r\nType .cheat to see the list of possible subcommands or .help cheat $subcommand to see info on subcommands'),
	('cheat casttime', 'Syntax: .cheat casttime [on/off]\r\nEnables or disables your character\'s spell cast times.'),
	('cheat cooldown', 'Syntax: .cheat cooldown [on/off]\r\nEnables or disables your character\'s spell cooldowns.'),
	('cheat explore', 'Syntax: .cheat explore #flag\r\nReveal or hide all maps for the selected player. If no player is selected, hide or reveal maps to you.\r\nUse a #flag of value 1 to reveal, use a #flag value of 0 to hide all maps.'),
	('cheat god', 'Syntax: .cheat god [on/off]\r\nEnables or disables your character\'s ability to take damage.'),
	('cheat power', 'Syntax: .cheat power [on/off]\r\nEnables or disables your character\'s spell cost (e.g mana).'),
	('cheat status', 'Syntax: .cheat status \n\nShows the cheats you currently have enabled.'),
	('cheat taxi', 'Syntax: .cheat taxi on/off\r\nTemporary grant access or remove to all taxi routes for the selected character.\r\n If no character is selected, hide or reveal all routes to you.Visited taxi nodes sill accessible after removing access.'),
	('cheat waterwalk', 'Syntax: .cheat waterwalk on/off\r\nSet on/off waterwalk state for selected player or self if no player selected.'),
	

	('cometome', 'Syntax: .cometome\nMake selected creature come to your current location (new position not saved to DB).'),
	('commands', 'Syntax: .commands\r\n\r\nDisplay a list of available commands for your account level.'),
	('cooldown', 'Syntax: .cooldown [#spell_id]\r\n\r\nRemove all (if spell_id not provided) or #spel_id spell cooldown from selected character or their pet or you (if no selection).'),
	('damage', 'Syntax: .damage $damage_amount [$school [$spellid]]\r\n\r\nApply $damage to target. If not $school and $spellid provided then this flat clean melee damage without any modifiers. If $school provided then damage modified by armor reduction (if school physical), and target absorbing modifiers and result applied as melee damage to target. If spell provided then damage modified and applied as spell damage. $spellid can be shift-link.'),
	('damage go', 'Syntax: .damage go $guid|$link $damage_amount\n\nApply $damage to destructible gameobject.'),
	
	('debug', 'Syntax: .debug $subcommand\nType .debug to see the list of possible subcommands or .help debug $subcommand to see info on subcommands'),
	('debug anim', 'Syntax: '),
	('debug areatriggers', 'Syntax: .debug areatriggers\nToggle debug mode for areatriggers. In debug mode GM will be notified if reaching an areatrigger'),
	('debug arena', 'Syntax: .debug arena\r\n\r\nToggle debug mode for arenas. In debug mode GM can start arena with single player.'),
	('debug asan', 'Syntax: .debug asan $subcommand\nType .debug asan to see the list of possible subcommands or .help debug asan $subcommand to see info on subcommands.\nUse only when testing dynamic analysis tools.'),
	('debug asan memoryleak', 'Syntax: .debug asan memoryleak\nTriggers a memory leak.\nUse only when testing dynamic analysis tools.'),
	('debug asan outofbounds', 'Syntax: .debug asan outofbounds\nTriggers a stack out of bounds read.\nUse only when testing dynamic analysis tools.'),
	('debug bg', 'Syntax: .debug bg\r\n\r\nToggle debug mode for battlegrounds. In debug mode GM can start battleground with single player.'),
	('debug boundary', 'Syntax: .debug boundary [fill] [duration]\nFlood fills the targeted unit\'s movement boundary and marks the edge of said boundary with debug creatures.\nSpecify \'fill\' as first parameter to fill the entire area with debug creatures.'),
	('debug combat', 'Syntax: .debug combat\n\nLists the target\'s (or own) combat references.'),
	('debug conversation', 'Syntax: .debug conversation $conversationId\r\nPlay given conversation.'),
	('debug dummy', 'Syntax: .debug dummy <???>\n\nCatch-all debug command. Does nothing by default. If you want it to do things for testing, add the things to its script in cs_debug.cpp.'),
	('debug entervehicle', 'Syntax: '),
	('debug getitemstate', 'Syntax: '),
	('debug guidlimits', 'Syntax: .debug guidlimits <optional map id>\nShows the current Creature and GameObject highest Guid for the specified map id or for all maps if none is specified\n'),
	('debug instancespawn', 'Syntax: .debug instancespawn [<groupID>/explain]\n\nDisplays information about the spawn groups being managed by the current instance script. If groupID is specified, additionally explains why that spawn group is in the listed state. If "explain" is specified, explains all spawn groups.'),
	('debug itemexpire', 'Syntax: '),
	('debug loadcells', 'Syntax: .debug loadcells [mapId]\nLoads all cells for debugging purposes'),
	('debug lootrecipient', 'Syntax: '),
	('debug los', 'Syntax: '),
	('debug moveflags', 'Syntax: .debug moveflags [$newMoveFlags [$newMoveFlags2]]\r\nNo params given will output the current moveflags of the target'),
	('debug neargraveyard', 'Syntax: .debug neargraveyard [linked]\nFind the nearest graveyard from dbc or db (if linked)'),
	('debug objectcount', 'Syntax: .debug objectcount <optional map id>\nShows the number of Creatures and GameObjects for the specified map id or for all maps if none is specified\n'),
	('debug phase', 'Syntax: .debug phase\r\n\r\nSends a phase debug report of a player to you.'),
	('debug play', 'Syntax: '),
	('debug play cinematic', 'Syntax: .debug play cinematic #cinematicid\r\n\r\nPlay cinematic #cinematicid for you. You stay at place while your mind fly.\r\n'),
	('debug play movie', 'Syntax: .debug play movie #movieid\r\n\r\nPlay movie #movieid for you.'),
	('debug play music', 'Syntax: .debug play music #musicId\nPlay music with #musicId.\nMusic will be played only for you. Other players will not hear this.'),
	('debug play objectsound', 'Syntax: .debug play objectsound #soundKitId [#broadcastTextId]\nPlay object sound with #soundKitId [and #broadcastTextId].\nSound will be played only for you. Other players will not hear this.'),
	('debug play sound', 'Syntax: .debug play sound #soundid\r\n\r\nPlay sound with #soundid.\r\nSound will be play only for you. Other players do not hear this.\r\nWarning: client may have more 5000 sounds...'),
	('debug questreset', 'Syntax: .debug questreset <daily/weekly/monthly/all>\n\nPerforms quest reset procedure for the specified type (or all types).\nQuest pools will be re-generated, and quest completion status will be reset.'),
	('debug raidreset', 'Syntax: .debug raidreset mapid [difficulty]\nForces a global reset of the specified map on all difficulties (or only the specific difficulty if specified). Effectively the same as setting the specified map\'s reset timer to now.'),
	('debug send', 'Syntax: '),
	('debug send buyerror', 'Syntax: '),
	('debug send channelnotify', 'Syntax: '),
	('debug send chatmessage', 'Syntax: '),
	('debug send equiperror', 'Syntax: '),
	('debug send largepacket', 'Syntax: '),
	('debug send opcode', 'Syntax: '),
	('debug send playerchoice', 'Syntax: .debug send playerchoice $choiceId\r\nSend given choice to player.'),
	('debug send qinvalidmsg', 'Syntax: '),
	('debug send qpartymsg', 'Syntax: '),
	('debug send sellerror', 'Syntax: '),
	('debug send setphaseshift', 'Syntax: '),
	('debug send spellfail', 'Syntax: '),
	('debug setaurastate', 'Syntax: '),
	('debug spawnvehicle', 'Syntax: '),
	('debug threat', 'Syntax: .debug threat\n\nLists the units threatened by target (or self). If target has a threat list, lists that threat list, too.'),
	('debug threatinfo', 'Syntax: .debug threatinfo\n\nDisplays various debug information about the target\'s threat state, modifiers, redirects and similar.'),
	('debug transport', 'Syntax: .debug transport [start/stop]\n\n Allows to stop the current transport at its nearest wait point and start movement of a stopped one. Not all transports can be started or stopped.'),
	('debug warden force', 'Syntax: .debug warden force id1 [id2 [id3 [...]]]\n\nQueues the specified Warden checks for your client. They will be sent according to your Warden settings.'),
	('debug worldstate', 'Syntax: debug worldstate $stateId $value\n\nSends a world state update for the specified state to your client.'),
	
	('deserter', 'Syntax: deserter $subcommand\n Type .deserter to see a list of possible subcommands\n or .help deserter $subcommand to see info on the subcommand.'),
	('deserter bg', 'Syntax: '),
	('deserter bg add', 'Syntax: .deserter bg add $time \n\n Adds the bg deserter debuff to your target with $time duration.'),
	('deserter bg remove', 'Syntax: .deserter bg remove \n\n Removes the bg deserter debuff from your target.'),
	('deserter instance', 'Syntax: '),
	('deserter instance add', 'Syntax: .deserter instance add $time \n\n Adds the instance deserter debuff to your target with $time duration.'),
	('deserter instance remove', 'Syntax: .deserter instance remove \n\n Removes the instance deserter debuff from your target.'),

	
	('disable', 'Syntax: disable $subcommand\n Type .disable to see a list of possible subcommands\n or .help disable $subcommand to see info on the subcommand.'),
	('disable add', 'Syntax: '),
	('disable add battleground', 'Syntax: .disable add battleground $entry $flag $comment'),
	('disable add criteria', 'Syntax: .disable add criteria $entry $flag $comment'),
	('disable add map', 'Syntax: .disable add map $entry $flag $comment'),
	('disable add mmap', 'Syntax: .disable add mmap $entry $flag $comment'),
	('disable add outdoorpvp', 'Syntax: .disable add outdoorpvp $entry $flag $comment'),
	('disable add quest', 'Syntax: .disable add quest $entry $flag $comment'),
	('disable add spell', 'Syntax: .disable add spell $entry $flag $comment'),
	('disable add vmap', 'Syntax: .disable add vmap $entry $flag $comment'),
	('disable remove', 'Syntax: '),
	('disable remove battleground', 'Syntax: .disable remove battleground $entry'),
	('disable remove criteria', 'Syntax: .disable remove criteria $entry'),
	('disable remove map', 'Syntax: .disable remove map $entry'),
	('disable remove mmap', 'Syntax: .disable remove mmap $entry'),
	('disable remove outdoorpvp', 'Syntax: .disable remove outdoorpvp $entry'),
	('disable remove quest', 'Syntax: .disable remove quest $entry'),
	('disable remove spell', 'Syntax: .disable remove spell $entry'),
	('disable remove vmap', 'Syntax: .disable remove vmap $entry'),
	
	('dismount', 'Syntax: .dismount\r\n\r\nDismount you, if you are mounted.'),
	('distance', 'Syntax: .distance [link]\r\n\r\nDisplay the distance from your character to the selected unit or given creature, player or gameobject.'),
	('event activelist', 'Syntax: .event activelist\r\nShow list of currently active events.'),
	('event info', 'Syntax: .event info #event_id\r\nShow details about event with #event_id.'),
	('event start', 'Syntax: .event start #event_id\r\nStart event #event_id. Set start time for event to current moment (change not saved in DB).'),
	('event stop', 'Syntax: .event stop #event_id\r\nStop event #event_id. Set start time for event to time in past that make current moment is event stop time (change not saved in DB).'),
	

	
	Dans ce code existant, il fait m'ajouter la pagination, dans la page 1 on garde les fonctions déjà présentes: world teleportation et Special teleportations.
	Dans la page 2 il me faut ces fonctions:
	pour la fonction : go xyz, il me faut 5 champs de sasisie avec des textes par defaut : X, Y, Z, MapID, O, puis un bouton "Go" quand on clique sur ce bouton on envoi la commande Syntax: .go xyz "Val de X" "Val de Y" "Val de Z" "Val de Map ID" "Val de O", sachant de le champ O n'est pas obligatoirs, ce bouton aura ce tooltip : Syntax: .go xyz <x> <y> [<z> [<mapid> [<o>]]]\nTeleport yourself to the specified location in the specified (or current) map.\nIf no z coordinate is specified, defaults to ground/water level.
    
	En dessous, pour la fonction "go offset" il me faudra 4 champs de saisie avec les textes par defaut respectifs:  dForward, dSideways, dZ, dO puis à coté un bouton "Go" quand on clique sur ce bouton on envoi la commande : go offset et la valeur des 4 champs separées par un espace, sachamp que seul le premier champ est obligatoire et qu'il ne peut pas y'avoir un champ avec le texte par defaut entre deux champs modifiés,
	par exemple 6 dSideways 3 devra donner une erreur. et ce bouton aura pour tooltip: Syntax: .go offset [<dForward> [<dSideways> [<dZ [<dO>]]]]\nTeleport yourself by the specified amount relative to your current position and orientation.
	
	En dessous il me faut 3 champs de saisie avec un menu dropdown avec les options suivantes:
	"go zonexy" pour cette fonction quand elle est choisie dans la dropdown, les textes des box seront respectivement: X, Y, Zone. Zone ne sera pas obligatoire, quand on cliquera sur le bouton d'action, on executera la commande : .go zonexy "Val de X" "Val de Y" "Val de zone" le tooltip a afficher sur le bouton sera: Syntax: .go zonexy <x> <y> [<zone>]\nTeleport yourself to the given local (x,y) position in the specified (or current) zone.
	"go grid" pour cette fonction quand elle est choisie dans la dropdown, les textes des box seront respectivement: gridX, gridY, mapId. mapId ne sera pas obligatoire, quand on cliquera sur le bouton d'action, on executera la commande : .go grid "Val de gridX" "Val de gridY" "Val de mapId" le tooltip a afficher sur le bouton sera : Syntax: .go grid <gridX> <gridY> [<mapId>]\nTeleport yourself to center of grid at the provided indices in specified (or current) map.
    apres le menu déroulant il me faudra un bouton d'action appellé "Go"
	
	Il me faudra un champ de saisie avec un menu derourant, suivi d'un bouton nommé "Go". Les options du dropdown seront les suivantes:
	go areatrigger, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "ArreaTriggerID", quand on cliquera sur le bouton on executera la fonction: .go areatrigger "la valeur de areatriggerId", le tooltip a afficher sera: Syntax: .go areatrigger <areatriggerId>\nTeleport yourself to the specified areatrigger\'s location.\nNote that you may end up at the trigger\'s target location if it is a teleport trigger.
	go boss, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "Boss Name", quand on cliquera sur le bouton on executera la fonction: .go boss "la valeur de Boss Name", le tooltip a afficher sera:Syntax: .go boss <part(s) of name>\nTeleport yourself to the dungeon boss whose name and/or script name best matches the specified search string(s).
	go bugticket, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "TicketId", quand on cliquera sur le bouton on executera la fonction: .go bugticket "la valeur de ticketId", le tooltip a afficher sera: Syntax: .go bugticket <ticketId>\nTeleport yourself to the location at which the specified bug ticket was created.
	go complaintticket, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "TicketId", quand on cliquera sur le bouton on executera la fonction: .go complaintticket "la valeur de ticketId", le tooltip a afficher sera: Syntax: .go complaintticket <ticketId>\nTeleport yourself to the location at which the specified complaint ticket was created.
	go creature, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "SpawnID", quand on cliquera sur le bouton on executera la fonction: .go creature"la valeur de spawnId", le tooltip a afficher sera: Syntax: .go creature <spawnId>\nTeleport yourself to the creature spawn with the specified spawn ID.
	go creature id, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "Creature ID", quand on cliquera sur le bouton on executera la fonction: .go creature id "la valeur de creatureId", le tooltip a afficher sera: Syntax: .go creature id <creatureId>\nTeleport yourself to the first spawn point for the specified creature ID.\nIf multiple spawn points for the creature exist, teleport to the first one found.
	go gameobject, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "SpawnID", quand on cliquera sur le bouton on executera la fonction: .go gameobject "la valeur de spawnId", le tooltip a afficher sera: Syntax: .go gameobject <spawnId>\nTeleport yourself to the gameobject spawn with the specified spawn ID.
	go gameobject id, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "Gobject ID", quand on cliquera sur le bouton on executera la fonction: .go gameobject id "la valeur de goId", le tooltip a afficher sera: Syntax: .go gameobject id <goId>\nTeleport yourself to the first spawn point for the specified gameobject ID.\nIf multiple spawn points for the gameobject exist, teleport to the first one found.
	go graveyard, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "Graveyard ID", quand on cliquera sur le bouton on executera la fonction: .go graveyard "la valeur de graveyardId", le tooltip a afficher sera: Syntax: .go graveyard <graveyardId>\nTeleport yourself to the graveyard with the specified graveyard ID.
	go instance, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "Instance Name", quand on cliquera sur le bouton on executera la fonction: .go instance "la valeur de Instace name", le tooltip a afficher sera: Syntax: .go instance <part(s) of name>\nTeleport yourself to the instance whose name and/or script name best matches the specified search string(s).
	go quest, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "Quest ID", quand on cliquera sur le bouton on executera la fonction: .go quest "la valeur de quest_id", le tooltip a afficher sera: Syntax: .go quest #quest_id\r\n\r\nTeleport your character to first quest poi with id #quest_id.
	go suggestionticket, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "TicketId" , quand on cliquera sur le bouton on executera la fonction: .go suggestionticket "la valeur de ticketId", le tooltip a afficher sera: Syntax: .go suggestionticket <ticketId>\nTeleport yourself to the location at which the specified suggestion ticket was created.
	go taxinode, pour cette fonction quand elle est choisie, le texte par defaut du champ de saisie sera: "Node ID", quand on cliquera sur le bouton on executera la fonction: .go taxinode "la valeur de nodeId", le tooltip a afficher sera: Syntax: .go taxinode <nodeId>\nTeleport yourself to the specified taxi node.
	
	
	('go xyz', 'Syntax: .go xyz <x> <y> [<z> [<mapid> [<o>]]]\nTeleport yourself to the specified location in the specified (or current) map.\nIf no z coordinate is specified, defaults to ground/water level.'),
	('go zonexy', 'Syntax: .go zonexy <x> <y> [<zone>]\nTeleport yourself to the given local (x,y) position in the specified (or current) zone.'),
	('go grid', 'Syntax: .go grid <gridX> <gridY> [<mapId>]\nTeleport yourself to center of grid at the provided indices in specified (or current) map.'),
	('go offset', 'Syntax: .go offset [<dForward> [<dSideways> [<dZ [<dO>]]]]\nTeleport yourself by the specified amount relative to your current position and orientation.'),

	('go areatrigger', 'Syntax: .go areatrigger <areatriggerId>\nTeleport yourself to the specified areatrigger\'s location.\nNote that you may end up at the trigger\'s target location if it is a teleport trigger.'),
	('go boss', 'Syntax: .go boss <part(s) of name>\nTeleport yourself to the dungeon boss whose name and/or script name best matches the specified search string(s).'),
	('go bugticket', 'Syntax: .go bugticket <ticketId>\nTeleport yourself to the location at which the specified bug ticket was created.'),
	('go complaintticket', 'Syntax: .go complaintticket <ticketId>\nTeleport yourself to the location at which the specified complaint ticket was created.'),
	('go creature', 'Syntax: .go creature <spawnId>\nTeleport yourself to the creature spawn with the specified spawn ID.'),
	('go creature id', 'Syntax: .go creature id <creatureId>\nTeleport yourself to the first spawn point for the specified creature ID.\nIf multiple spawn points for the creature exist, teleport to the first one found.'),
	('go gameobject', 'Syntax: .go gameobject <spawnId>\nTeleport yourself to the gameobject spawn with the specified spawn ID.'),
	('go gameobject id', 'Syntax: .go gameobject id <goId>\nTeleport yourself to the first spawn point for the specified gameobject ID.\nIf multiple spawn points for the gameobject exist, teleport to the first one found.'),
	('go graveyard', 'Syntax: .go graveyard <graveyardId>\nTeleport yourself to the graveyard with the specified graveyard ID.'),
	('go instance', 'Syntax: .go instance <part(s) of name>\nTeleport yourself to the instance whose name and/or script name best matches the specified search string(s).'),
	('go quest', 'Syntax: .go quest #quest_id\r\n\r\nTeleport your character to first quest poi with id #quest_id.'),
	('go suggestionticket', 'Syntax: .go suggestionticket <ticketId>\nTeleport yourself to the location at which the specified suggestion ticket was created.'),
	('go taxinode', 'Syntax: .go taxinode <nodeId>\nTeleport yourself to the specified taxi node.'),
	
	
	('gps', 'Syntax: .gps [$name|$shift-link]\r\n\r\nDisplay the position information for a selected character or creature (also if player name $name provided then for named player, or if creature/gameobject shift-link provided then pointed creature/gameobject if it loaded). Position information includes X, Y, Z, and orientation, map Id and zone Id'),
	
	('group', 'Syntax: .group $subcommand\nType .group to see the list of possible subcommands or .help group $subcommand to see info on subcommands'),
	('group disband', 'Syntax: .group disband [$characterName]\n\nDisbands the given character\'s group.'),
	('group join', 'Syntax: .group join $AnyCharacterNameFromGroup [$CharacterName] \r\nAdds to group of player $AnyCharacterNameFromGroup player $CharacterName (or selected).'),
	('group leader', 'Syntax: .group leader [$characterName]\n\nSets the given character as his group\'s leader.'),
	('group level', 'Syntax: .group level [$charactername] Set the level of the given character and his group to #numberoflevels (only positive values 1+). Modify only online group characters level but original selected group member can be offline. All stats and dependent values are not recalculated. At level decrease talents can be reset if need. Also at level decrease equipped items with greater level requirement can be lost. If no character is selected and name not provided, it will modify your level.'),
	('group list', 'Syntax: .group list [$CharacterName] \r\nLists all the members of the group/party the player is in.'),
	('group remove', 'Syntax: .group remove [$characterName]\n\nRemoves the given character from his group.'),
	('group repair', 'Syntax: .group repair [$charactername] Repair the given character and his group. Repair only online group characters but original selected group member can be offline. If no character is selected and name not provided, it will repair yourself.'),
	('group revive', 'Syntax: .group revive [$charactername] Revive the given character and his group. Revive only online group characters but original selected group member can be offline. If no character is selected and name not provided, it will revive yourself.'),
	('group set assistant', 'Syntax: .group set assistant [$characterName]\n\nToggles the given character\'s assistant state in his raid group.'),
	('group set leader', 'Syntax: .group set leader [$characterName]\n\nSets the given character (or selected) as his group\'s leader. Alias for \'.group leader\'.'),
	('group set mainassist', 'Syntax: .group set mainassist [$characterName]\n\nToggles the given character\'s main assist flag in his raid group.'),
	('group set maintank', 'Syntax: .group set maintank [$characterName]\n\nToggles the given character\'s main tank flag in his raid group.'),
	('group summon', 'Syntax: .group summon [$charactername]\r\n\r\nTeleport the given character and his group to you. Teleported only online characters but original selected group member can be offline.'),
	
	('guid', 'Syntax: .guid\r\n\r\nDisplay the GUID for the selected character.'),
	('guild', 'Syntax: .guild $subcommand\nType .guild to see the list of possible subcommands or .help guild $subcommand to see info on subcommands'),
	('guild create', 'Syntax: .guild create [$GuildLeaderName] "$GuildName"\r\n\r\nCreate a guild named $GuildName with the player $GuildLeaderName (or selected) as leader.  Guild name must in quotes.'),
	('guild delete', 'Syntax: .guild delete "$GuildName"\r\n\r\nDelete guild $GuildName. Guild name must in quotes.'),
	('guild info', 'Shows information about target\'s guild or a given guild identifier or name.'),
	('guild invite', 'Syntax: .guild invite [$CharacterName] "$GuildName"\r\n\r\nAdd player $CharacterName (or selected) into a guild $GuildName. Guild name must in quotes.'),
	('guild rank', 'Syntax: .guild rank [$CharacterName] #Rank\r\n\r\nSet for player $CharacterName (or selected) rank #Rank in a guild.'),
	('guild rename', 'Syntax: .guild rename "$GuildName" "$NewGuildName" \n\n Rename a guild named $GuildName with $NewGuildName. Guild name and new guild name must in quotes.'),
	('guild uninvite', 'Syntax: .guild uninvite [$CharacterName]\r\n\r\nRemove player $CharacterName (or selected) from a guild.'),
	
	('help', 'Syntax: .help [$command]\r\n\r\nDisplay usage instructions for the given $command. If no $command provided show list available commands.'),
	('hidearea', 'Syntax: .hidearea #areaid\r\n\r\nHide the area of #areaid to the selected character. If no character is selected, hide this area to you.'),
	

	('honor update', 'Syntax: .honor update\r\n\r\nForce the yesterday\'s honor fields to be updated with today\'s data, which will get reset for the selected player.'), -> Fonction pour serveur
	('instance', 'Syntax: .instance $subcommand\nType .instance to see the list of possible subcommands or .help instance $subcommand to see info on subcommands'),
	('instance getbossstate', 'Syntax: .instance getbossstate $bossId [$Name]\r\nGets the current EncounterState for the provided boss id.\r\nIf no character name is provided, the current map will be used as target.'),
	('instance setbossstate', 'Syntax: .instance setbossstate $bossId $encounterState [$Name]\r\nSets the EncounterState for the given boss id to a new value. EncounterStates range from 0 to 5.\r\nIf no character name is provided, the current map will be used as target.'),
	('instance stats', 'Syntax: .instance stats\r\n  Shows statistics about instances.'),

	
	('itemmove', 'Syntax: .itemmove #sourceslotid #destinationslotid\r\n\r\nMove an item from slots #sourceslotid to #destinationslotid in your inventory\r\n\r\nNot yet implemented'),
	
	('lfg', 'Syntax: lfg $subcommand\n Type .lfg to see a list of possible subcommands\n or .help lfg $subcommand to see info on the subcommand.'),
	('lfg clean', 'Syntax: .flg clean\n Cleans current queue, only for debugging purposes.'),
	('lfg group', 'Syntax: .lfg group\n Shows information about all players in the group  (state, roles, comment, dungeons selected).'),
	('lfg options', 'Syntax: .lfg options [new value]\n Shows current lfg options. New value is set if extra param is present.'),
	('lfg player', 'Syntax: .lfg player\n Shows information about player (state, roles, comment, dungeons selected).'),
	('lfg queue', 'Syntax: .lfg queue\n Shows info about current lfg queues.'),
	
	('linkgrave', 'Syntax: .linkgrave #graveyard_id [alliance|horde]\r\n\r\nLink current zone to graveyard for any (or alliance/horde faction ghosts). This let character ghost from zone teleport to graveyard after die if graveyard is nearest from linked to zone and accept ghost of this faction. Add only single graveyard at another map and only if no graveyards linked (or planned linked at same map).'),
	
	('list', 'Syntax: .list $subcommand\nType .list to see the list of possible subcommands or .help list $subcommand to see info on subcommands'),
	('list auras', 'Syntax: .list auras\nList auras (passive and active) of selected creature or player. If no creature or player is selected, list your own auras.'),
	('list creature', 'Syntax: .list creature #creature_id [#max_count]\r\n\r\nOutput creatures with creature id #creature_id found in world. Output creature guids and coordinates sorted by distance from character. Will be output maximum #max_count creatures. If #max_count not provided use 10 as default value.'),
	('list item', 'Syntax: .list item #item_id [#max_count]\r\n\r\nOutput items with item id #item_id found in all character inventories, mails, auctions, and guild banks. Output item guids, item owner guid, owner account and owner name (guild name and guid in case guild bank). Will be output maximum #max_count items. If #max_count not provided use 10 as default value.'),
	('list mail', 'Syntax: .list mail $character\nList of mails the character received.'),
	('list object', 'Syntax: .list object #gameobject_id [#max_count]\r\n\r\nOutput gameobjects with gameobject id #gameobject_id found in world. Output gameobject guids and coordinates sorted by distance from character. Will be output maximum #max_count gameobject. If #max_count not provided use 10 as default value.'),
	('list respawns', 'Syntax: .list respawns [distance]\n\nLists all pending respawns within <distance> yards, or within current zone if not specified.'),
	('list scenes', 'Syntax: .list scenes\nList of all active scenes for targeted character.'),
	('list spawnpoints', 'Syntax: .list spawnpoints\n\nLists all spawn points (both creatures and GOs) in the current zone.'),
	
	
	('lookup', 'Syntax: .lookup $subcommand\nType .lookup to see the list of possible subcommands or .help lookup $subcommand to see info on subcommands'),
	('lookup area', 'Syntax: .lookup area $namepart\r\n\r\nLooks up an area by $namepart, and returns all matches with their area ID\'s.'),
	('lookup creature', 'Syntax: .lookup creature $namepart\r\n\r\nLooks up a creature by $namepart, and returns all matches with their creature ID\'s.'),
	('lookup event', 'Syntax: .lookup event $name\r\nAttempts to find the ID of the event with the provided $name.'),
	('lookup faction', 'Syntax: .lookup faction $name\r\nAttempts to find the ID of the faction with the provided $name.'),
	('lookup item', 'Syntax: .lookup item $itemname\r\n\r\nLooks up an item by $itemname, and returns all matches with their Item ID\'s.'),
	('lookup item set', 'Syntax: .lookup itemset $itemname\r\n\r\nLooks up an item set by $itemname, and returns all matches with their Item set ID\'s.'),
	('lookup map', 'Syntax: .lookup map $namepart\r\n\r\nLooks up a map by $namepart, and returns all matches with their map ID\'s.'),
	('lookup object', 'Syntax: .lookup object $objname\r\n\r\nLooks up an gameobject by $objname, and returns all matches with their Gameobject ID\'s.'),
	('lookup player', 'Syntax: '),
	('lookup player account', 'Syntax: .lookup player account $account ($limit) \r\n\r\n Searchs players, which account username is $account with optional parametr $limit of results.'),
	('lookup player email', 'Syntax: .lookup player email $email ($limit) \r\n\r\n Searchs players, which account email is $email with optional parametr $limit of results.'),
	('lookup player ip', 'Syntax: .lookup player ip $ip ($limit) \r\n\r\n Searchs players, which account ast_ip is $ip with optional parametr $limit of results.'),
	('lookup quest', 'Syntax: .lookup quest $namepart\r\n\r\nLooks up a quest by $namepart, and returns all matches with their quest ID\'s.'),
	('lookup skill', 'Syntax: .lookup skill $$namepart\r\n\r\nLooks up a skill by $namepart, and returns all matches with their skill ID\'s.'),
	('lookup spell', 'Syntax: .lookup spell $namepart\r\n\r\nLooks up a spell by $namepart, and returns all matches with their spell ID\'s.'),
	('lookup spell id', 'Syntax: .lookup spell id #spellid\n\nLooks up a spell by #spellid, and returns the match with its spell name.'),
	('lookup taxinode', 'Syntax: .lookup taxinode $substring\r\n\r\nSearch and output all taxinodes with provide $substring in name.'),
	('lookup tele', 'Syntax: .lookup tele $substring\r\n\r\nSearch and output all .tele command locations with provide $substring in name.'),
	('lookup title', 'Syntax: .lookup title $$namepart\r\n\r\nLooks up a title by $namepart, and returns all matches with their title ID\'s and index\'s.'),
	
	
	('mmap', 'Syntax: Syntax: .mmaps $subcommand Type .mmaps to see the list of possible subcommands or .help mmaps $subcommand to see info on subcommands'),
	('mmap loadedtiles', 'Syntax: .mmap loadedtiles to show which tiles are currently loaded'),
	('mmap loc', 'Syntax: .mmap loc to print on which tile one is'),
	('mmap path', 'Syntax: .mmap path to calculate and show a path to current select unit'),
	('mmap stats', 'Syntax: .mmap stats to show information about current state of mmaps'),
	('mmap testarea', 'Syntax: .mmap testarea to calculate paths for all nearby npcs to player'),


	
	
	('movegens', 'Syntax: .movegens\r\n  Show movement generators stack for selected creature or player.'),
	


	('nameannounce', 'Syntax: .nameannounce $announcement.\nSend an announcement to all online players, displaying the name of the sender.'),
	('neargrave', 'Syntax: .neargrave [alliance|horde]\r\n\r\nFind nearest graveyard linked to zone (or only nearest from accepts alliance or horde faction ghosts).'),
	('notify', 'Syntax: .notify $MessageToBroadcast\r\n\r\nSend a global message to all players online in screen.'),

	

	

	('playall', 'Syntax: .playall #soundid\r\n\r\nPlayer a sound to whole server.'),
	('possess', 'Syntax: .possess\r\n\r\nPossesses indefinitely the selected creature.'),
	
	('pvpstats', 'Shows number of battleground victories in the last 7 days'),
	
	('quest', 'Syntax: .quest $subcommand\nType .quest to see the list of possible subcommands or .help quest $subcommand to see info on subcommands'),
	('quest add', 'Syntax: .quest add #quest_id\r\n\r\nAdd to character quest log quest #quest_id. Quest started from item can\'t be added by this command but correct .additem call provided in command output.'),
	('quest complete', 'Syntax: .quest complete #questid\r\nMark all quest objectives as completed for target character active quest. After this target character can go and get quest reward.'),
	('quest objective complete', 'Syntax: .quest objective complete #questObjectiveId\nMark specific quest objective as completed for target character.'),
	('quest remove', 'Syntax: .quest remove #quest_id\r\n\r\nSet quest #quest_id state to not completed and not active (and remove from active quest list) for selected player.'),
	('quest reward', 'Syntax: .quest reward #questId\n\nGrants quest reward to selected player and removes quest from his log (quest must be in completed state).'),
	
	('rbac', 'Syntax: bf $subcommand\n Type .rbac to see a list of possible subcommands\n or .help bf $subcommand to see info on the subcommand.'),
	('rbac account', 'Syntax: rbac account $subcommand\n Type .rbac account to see a list of possible subcommands\n or .help rbac account $subcommand to see info on the subcommand.'),
	('rbac account deny', 'Syntax: rbac account deny [$account] #id [#realmId]\n\nDeny a permission to selected player or given account.\n\n#reamID may be -1 for all realms.'),
	('rbac account grant', 'Syntax: rbac account grant [$account] #id [#realmId]\n\nGrant a permission to selected player or given account.\n\n#reamID may be -1 for all realms.'),
	('rbac account list', 'Syntax: rbac account list [$account]\n\nView permissions of selected player or given account\nNote: Only those that affect current realm'),
	('rbac account revoke', 'Syntax: rbac account revoke [$account] #id [#realmId]\n\nRemove a permission from an account\n\nNote: Removes the permission from granted or denied permissions'),
	('rbac list', 'Syntax: rbac list [$id]\n\nView list of all permissions. If $id is given will show only info for that permission.'),
	('recall', 'Syntax: .recall [$playername]\r\n\r\nTeleport $playername or selected player to the place where he has been before last use of a teleportation command. If no $playername is entered and no player is selected, it will teleport you.'),
	
	
	
	
	
	('scene', ''),
	('scene cancel', 'Syntax: .scene cancel #scenePackageId\nCancels scene with package id for targeted player'),
	('scene debug', 'Syntax: .scene debug\nToggle debug mode for scenes. In debug mode GM will be notified in chat when scenes start/stop/trigger event'),
	('scene play', 'Syntax: .scene play #sceneId\nPlays scene with id for targeted player'),
	('scene playpackage', 'Syntax: .scene playpackage #scenePackageId #playbackFlags\nPlays scene with package id and playback flags for targeted player'),
	
	('send', 'Syntax: send $subcommand\n Type .send to see a list of possible subcommands\n or .help send $subcommand to see info on the subcommand.'),
	('send items', 'Syntax: .send items #playername "#subject" "#text" itemid1[:count1] itemid2[:count2] ... itemidN[:countN]\r\n\r\nSend a mail to a player. Subject and mail text must be in "". If for itemid not provided related count values then expected 1, if count > max items in stack then items will be send in required amount stacks. All stacks amount in mail limited to 12.'),
	('send mail', 'Syntax: .send mail #playername "#subject" "#text"\r\n\r\nSend a mail to a player. Subject and mail text must be in "".'),
	('send message', 'Syntax: .send message $playername $message\r\n\r\nSend screen message to player from ADMINISTRATOR.'),
	('send money', 'Syntax: .send money #playername "#subject" "#text" #money\r\n\r\nSend mail with money to a player. Subject and mail text must be in "".'),

	
	('setskill', 'Syntax: .setskill #skill #level [#max]\r\n\r\nSet a skill of id #skill with a current skill value of #level and a maximum value of #max (or equal current maximum if not provide) for the selected character. If no character is selected, you learn the skill.'),
	
	('showarea', 'Syntax: .showarea #areaid\r\n\r\nReveal the area of #areaid to the selected character. If no character is selected, reveal this area to you.'),
	('summon', 'Syntax: .summon [$charactername]\r\n\r\nTeleport the given character to you. Character can be offline.'),
	
	
	('ticket', 'Syntax: .ticket $subcommand\nType .ticket to see the list of possible subcommands or .help ticket $subcommand to see info on subcommands'),
	('ticket bug assign', 'Usage: .ticket bug assign $ticketid $gmname.\r\nAssigns the specified ticket to the specified Game Master.'),
	('ticket bug close', 'Usage: .ticket bug close $ticketid.\r\nCloses the specified ticket. Does not delete permanently.'),
	('ticket bug closedlist', 'Usage: Displays a list of closed bug tickets.'),
	('ticket bug comment', 'Usage: .ticket bug comment $ticketid $comment.\r\nAllows the adding or modifying of a comment to the specified ticket.'),
	('ticket bug delete', 'Usage: .ticket bug delete $ticketid.\r\nDeletes the specified ticket permanently. Ticket must be closed first.'),
	('ticket bug list', 'Usage: Displays a list of open bug tickets.'),
	('ticket bug unassign', 'Usage: .ticket bug unassign $ticketid.\r\nUnassigns the specified ticket from the current assigned Game Master.'),
	('ticket bug view', 'Usage: .ticket bug view $ticketid.\r\nReturns details about specified ticket. Ticket must be open and not deleted.'),
	('ticket complaint assign', 'Usage: .ticket complaint assign $ticketid $gmname.\r\nAssigns the specified ticket to the specified Game Master.'),
	('ticket complaint close', 'Usage: .ticket complaint close $ticketid.\r\nCloses the specified ticket. Does not delete permanently.'),
	('ticket complaint closedlist', 'Usage: Displays a list of closed complaint tickets.'),
	('ticket complaint comment', 'Usage: .ticket complaint comment $ticketid $comment.\r\nAllows the adding or modifying of a comment to the specified ticket.'),
	('ticket complaint delete', 'Usage: .ticket complaint delete $ticketid.\r\nDeletes the specified ticket permanently. Ticket must be closed first.'),
	('ticket complaint list', 'Usage: Displays a list of open complaint tickets.'),
	('ticket complaint unassign', 'Usage: .ticket complaint unassign $ticketid.\r\nUnassigns the specified ticket from the current assigned Game Master.'),
	('ticket complaint view', 'Usage: .ticket complaint view $ticketid.\r\nReturns details about specified ticket. Ticket must be open and not deleted.'),
	('ticket reset', 'Syntax: .ticket reset\nRemoves all closed tickets and resets the counter, if no pending open tickets are existing.'),
	('ticket reset all', 'Usage: Removes all closed tickets and resets the counter, if no pending open tickets exist.'),
	('ticket reset bug', 'Usage: Removes all closed bug tickets and resets the counter, if no pending open tickets exist.'),
	('ticket reset complaint', 'Usage: Removes all closed complaint tickets and resets the counter, if no pending open tickets exist.'),
	('ticket reset suggestion', 'Usage: Removes all closed suggestion tickets and resets the counter, if no pending open tickets exist.'),
	('ticket suggestion assign', 'Usage: .ticket suggestion assign $ticketid $gmname.Assigns the specified ticket to the specified Game Master.'),
	('ticket suggestion close', 'Usage: .ticket suggestion close $ticketid.\r\nCloses the specified ticket. Does not delete permanently.'),
	('ticket suggestion closedlist', 'Usage: Displays a list of closed suggestion tickets.'),
	('ticket suggestion comment', 'Usage: .ticket suggestion comment $ticketid $comment.\r\nAllows the adding or modifying of a comment to the specified ticket.'),
	('ticket suggestion delete', 'Usage: .ticket suggestion delete $ticketid.\r\nDeletes the specified ticket permanently. Ticket must be closed first.'),
	('ticket suggestion list', 'Usage: Displays a list of open suggestion tickets.'),
	('ticket suggestion unassign', 'Usage: .ticket suggestion unassign $ticketid.\r\nUnassigns the specified ticket from the current assigned Game Master.'),
	('ticket suggestion view', 'Usage: .ticket suggestion view $ticketid.\r\nReturns details about specified ticket. Ticket must be open and not deleted.'),
	('ticket togglesystem', 'Syntax: '),
	
	

----------- Fonctionalités joueur
   --- Utilité de la commande .unbindsight
   -- Cette commande sert à retirer une liaison visuelle précédemment appliquée à un joueur ou GM via une commande comme .bindsight.
   -- .bindsight permet de voir le jeu à travers les yeux d'une cible sélectionnée, très utile pour surveiller discrètement un joueur (pour s'assurer qu'il respecte les règles ou vérifier des anomalies en jeu).
   -- Lorsque tu as terminé de surveiller ou que tu veux retourner à ta propre vue, tu dois utiliser la commande inverse : .unbindsight.

	('bindsight', 'Syntax: .bindsight\r\n\r\nBinds vision to the selected unit indefinitely. Cannot be used while currently possessing a target.'),
	('unbindsight', 'Syntax: .unbindsight\r\n\r\nRemoves bound vision. Cannot be used while currently possessing a target.'),
	
En dessous du chanp de saisie de Freeze je voudrais ajouter un champ de saisi avec defaut texte "Player Name" et à coté de ce champ un bouton "UnFreeze" avec le tooltip sur le bouton "Syntax: .unfreeze (#player)\r\n"Unfreezes" #player and enables his chat again. When using this without #name it will unfreeze your target.3
quand on clique sur le bouton UnFreeze on envoi la commande .unfreeze [valeur de player] il faut aussi integrer la possiblilité de reset les champs de saisie à leurs valeur par défaut et que si le champ Player Name n'est pas renseigné il faut unfreeze la cible du GM
	
	
	('instance unbind', 'Syntax: .instance unbind <mapid|all> [difficulty]\r\n  Clear all/some of player\'s binds'),
	('instance listbinds', 'Syntax: .instance listbinds\r\n  Lists the binds of the selected player.'),		
	('combatstop', 'Syntax: .combatstop [$playername]\r\nStop combat for selected character. If selected non-player then command applied to self. If $playername provided then attempt applied to online player $playername.'),		
	('honor', 'Syntax: .honor $subcommand\nType .honor to see the list of possible subcommands or .help honor $subcommand to see info on subcommands'),
	('honor add', 'Syntax: .honor add $amount\r\n\r\nAdd a certain amount of honor (gained today) to the selected player.'),
	('honor add kill', 'Syntax: .honor add kill\r\n\r\nAdd the targeted unit as one of your pvp kills today (you only get honor if it\'s a racial leader or a player)'),	


	('titles add', 'Syntax: .titles add #title\r\nAdd title #title (id or shift-link) to known titles list for selected player.'),
	('titles current', 'Syntax: .titles current #title\r\nSet title #title (id or shift-link) as current selected title for selected player. If title is not in known title list for player then it will be added to list.'),
	('titles remove', 'Syntax: .titles remove #title\r\nRemove title #title (id or shift-link) from known titles list for selected player.'),
	('titles set mask', 'Syntax: .titles set mask #mask\r\n\r\nAllows user to use all titles from #mask.\r\n\r\n #mask=0 disables the title-choose-field'),

	('reset', 'Syntax: .reset $subcommand\nType .reset to see the list of possible subcommands or .help reset $subcommand to see info on subcommands'),
	('reset achievements', 'Syntax: .reset achievements [$playername]\r\n\r\nReset achievements data for selected or named (online or offline) character. Achievements for persistance progress data like completed quests/etc re-filled at reset. Achievements for events like kills/casts/etc will lost.'),
	('reset all', 'Syntax: .reset all spells\r\n\r\nSyntax: .reset all talents\r\n\r\nRequest reset spells or talents (including talents for all character\'s pets if any) at next login each existed character.'),
	('reset honor', 'Syntax: .reset honor [Playername]\r\n  Reset all honor data for targeted character.'),
	('reset level', 'Syntax: .reset level [Playername]\r\n  Reset level to 1 including reset stats and talents.  Equipped items with greater level requirement can be lost.'),
	('reset spells', 'Syntax: .reset spells [Playername]\r\n  Removes all non-original spells from spellbook.\r\n. Playername can be name of offline character.'),
	('reset stats', 'Syntax: .reset stats [Playername]\r\n  Resets(recalculate) all stats of the targeted player to their original VALUESat current level.'),
	('reset talents', 'Syntax: .reset talents [Playername]\r\n  Removes all talents of the targeted player or pet or named player. Playername can be name of offline character. With player talents also will be reset talents for all character\'s pets if any.'),
	
	('pinfo', 'Syntax: .pinfo [$player_name/#GUID]\r\n\r\nOutput account information and guild information for selected player or player find by $player_name or #GUID.'), -> Creer une page speciale avec des champs pour afficher les infos "Player advances Infos" A finaliser

	
	
	
	

	('wchange', 'Syntax: .wchange #weathertype #status\r\n\r\nSet current weather to #weathertype with an intensity of #status.\r\n\r\n#weathertype can be 1 for rain, 2 for snow, and 3 for sand. #status can be 0 for disabled, and 1 for enabled.'),

