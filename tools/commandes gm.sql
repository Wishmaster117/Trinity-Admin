-- --------------------------------------------------------
-- Hôte:                         127.0.0.1
-- Version du serveur:           8.0.34 - MySQL Community Server - GPL
-- SE du serveur:                Win64
-- HeidiSQL Version:             12.10.0.7000
-- --------------------------------------------------------
-- Mettre les autres traductions pour les titres, es, pt, it, etc....



	
idées:

Pour npc info il faut trier les données a afficher
Pour .gobject info il faut trier les données a afficher

voir les commandes .gobject et voir si on peut mettre une frame de preview
	
	
	.refaire bnetaccountset car il y'a les sous commandes en fait faut le virer de la liste
	-- voir pour les . learn des proffessions etc...
	-- finir de mettre les noms des sets et leurs traduction
	-- Revoir les boutond radio de battlenet account et mettre des textes par defaut

	-- Tester les commandes .learn
    -- essayer de trouver une commande reversse à .possess	
    
	-- Tester le panneau donjons

	
Pour ce panneau il me faut:

A ajouter GmFunctionsPanel page 3
('linkgrave', 'Syntax: .linkgrave #graveyard_id [alliance|horde]\r\n\r\nLink current zone to graveyard for any (or alliance/horde faction ghosts). This let character ghost from zone teleport to graveyard after die if graveyard is nearest from linked to zone and accept ghost of this faction. Add only single graveyard at another map and only if no graveyards linked (or planned linked at same map).'),
	
	
	-- Cast Commands
	('cast', 'Syntax: .cast #spellid [triggered]\r\n  Cast #spellid to selected target. If no target selected cast to self. If \'triggered\' or part provided then spell casted with triggered flag.'),
	('cast back', 'Syntax: .cast back #spellid [triggered]\r\n  Selected target will cast #spellid to your character. If \'triggered\' or part provided then spell casted with triggered flag.'),
	('cast dest', 'Syntax: .cast dest #spellid #x #y #z [triggered]\r\n  Selected target will cast #spellid at provided destination. If \'triggered\' or part provided then spell casted with triggered flag.'),
	('cast dist', 'Syntax: .cast dist #spellid [#dist [triggered]]\r\n  You will cast spell to pint at distance #dist. If \'triggered\' or part provided then spell casted with triggered flag. Not all spells can be casted as area spells.'),
	('cast self', 'Syntax: .cast self #spellid [triggered]\r\nCast #spellid by target at target itself. If \'triggered\' or part provided then spell casted with triggered flag.'),
	('cast target', 'Syntax: .cast target #spellid [triggered]\r\n  Selected target will cast #spellid to his victim. If \'triggered\' or part provided then spell casted with triggered flag.'),
	('cooldown', 'Syntax: .cooldown [#spell_id]\r\n\r\nRemove all (if spell_id not provided) or #spel_id spell cooldown from selected character or their pet or you (if no selection).'),
	



	
	
	('cheat', 'Syntax: .cheat $subcommand\r\nType .cheat to see the list of possible subcommands or .help cheat $subcommand to see info on subcommands'),
	('cheat casttime', 'Syntax: .cheat casttime [on/off]\r\nEnables or disables your character\'s spell cast times.'),
	('cheat cooldown', 'Syntax: .cheat cooldown [on/off]\r\nEnables or disables your character\'s spell cooldowns.'),
	('cheat explore', 'Syntax: .cheat explore #flag\r\nReveal or hide all maps for the selected player. If no player is selected, hide or reveal maps to you.\r\nUse a #flag of value 1 to reveal, use a #flag value of 0 to hide all maps.'),
	('cheat god', 'Syntax: .cheat god [on/off]\r\nEnables or disables your character\'s ability to take damage.'),
	('cheat power', 'Syntax: .cheat power [on/off]\r\nEnables or disables your character\'s spell cost (e.g mana).'),
	('cheat status', 'Syntax: .cheat status \n\nShows the cheats you currently have enabled.'),
	('cheat taxi', 'Syntax: .cheat taxi on/off\r\nTemporary grant access or remove to all taxi routes for the selected character.\r\n If no character is selected, hide or reveal all routes to you.Visited taxi nodes sill accessible after removing access.'),
	('cheat waterwalk', 'Syntax: .cheat waterwalk on/off\r\nSet on/off waterwalk state for selected player or self if no player selected.'),
	

	
	
	

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
	

	
	('itemmove', 'Syntax: .itemmove #sourceslotid #destinationslotid\r\n\r\nMove an item from slots #sourceslotid to #destinationslotid in your inventory\r\n\r\nNot yet implemented'),
	

	
	
	
	 Pour ce panneau, il me faut:
	
	
	

	
	
	('mmap', 'Syntax: Syntax: .mmaps $subcommand Type .mmaps to see the list of possible subcommands or .help mmaps $subcommand to see info on subcommands'),
	('mmap loadedtiles', 'Syntax: .mmap loadedtiles to show which tiles are currently loaded'),
	('mmap loc', 'Syntax: .mmap loc to print on which tile one is'),
	('mmap path', 'Syntax: .mmap path to calculate and show a path to current select unit'),
	('mmap stats', 'Syntax: .mmap stats to show information about current state of mmaps'),
	('mmap testarea', 'Syntax: .mmap testarea to calculate paths for all nearby npcs to player'),


	
	-- A ajouter ans Waypoints
	('movegens', 'Syntax: .movegens\r\n  Show movement generators stack for selected creature or player.'),
	



	


	

	

	('playall', 'Syntax: .playall #soundid\r\n\r\nPlayer a sound to whole server.'),
	

    -- Gestion des GM	
	Que fait cette commande ?
    Elle refuse (deny) une permission spécifique à un compte donné, même si ce compte l’a normalement via son rang.

    En gros : c’est un "override" négatif.
    Tu dis : « même si ce compte a la permission via son rang, je lui interdis quand même. »

   📘 Syntaxe détaillée :
	Paramètre	Description
	$account	(Optionnel) Le nom de compte auquel tu veux retirer la permission. Si rien n’est précisé, c’est le compte actuellement sélectionné.
	#id	L’ID de permission RBAC que tu veux refuser.
	#realmId	(Optionnel) Le realm concerné. -1 = tous les royaumes.
	('rbac', 'Syntax: bf $subcommand\n Type .rbac to see a list of possible subcommands\n or .help bf $subcommand to see info on the subcommand.'),
	('rbac account', 'Syntax: rbac account $subcommand\n Type .rbac account to see a list of possible subcommands\n or .help rbac account $subcommand to see info on the subcommand.'),
	('rbac account deny', 'Syntax: rbac account deny [$account] #id [#realmId]\n\nDeny a permission to selected player or given account.\n\n#reamID may be -1 for all realms.'),
	('rbac account grant', 'Syntax: rbac account grant [$account] #id [#realmId]\n\nGrant a permission to selected player or given account.\n\n#reamID may be -1 for all realms.'),
	('rbac account list', 'Syntax: rbac account list [$account]\n\nView permissions of selected player or given account\nNote: Only those that affect current realm'),
	('rbac account revoke', 'Syntax: rbac account revoke [$account] #id [#realmId]\n\nRemove a permission from an account\n\nNote: Removes the permission from granted or denied permissions'),
	('rbac list', 'Syntax: rbac list [$id]\n\nView list of all permissions. If $id is given will show only info for that permission.'),
	
	
	
	
	
	('scene', ''),
	('scene cancel', 'Syntax: .scene cancel #scenePackageId\nCancels scene with package id for targeted player'),
	('scene debug', 'Syntax: .scene debug\nToggle debug mode for scenes. In debug mode GM will be notified in chat when scenes start/stop/trigger event'),
	('scene play', 'Syntax: .scene play #sceneId\nPlays scene with id for targeted player'),
	('scene playpackage', 'Syntax: .scene playpackage #scenePackageId #playbackFlags\nPlays scene with package id and playback flags for targeted player'),

	

	
	
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
	
	
	

	
