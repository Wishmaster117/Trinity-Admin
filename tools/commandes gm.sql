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

	-- Pour le module cheat, changer le type de frame ACE3 et virer le bouton accepter
	
	-- Pour le panel debug, voir si dans les dbc je peux chopper la liste des musiques tc....
	
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
	
	
	

	
