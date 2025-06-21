<?php

/**
 *
 * @package   phpBB Extension - Oxpus Downloads
 * @copyright 2002-2021 OXPUS - www.oxpus.net
 * @license   http://opensource.org/licenses/gpl-2.0.php GNU General Public License v2
 *
 */

/**
 * Language pack for Extension permissions [English]
 */

/**
 * DO NOT CHANGE
 */
if (!defined('IN_PHPBB'))
{
	exit;
}

if (empty($lang) || !is_array($lang))
{
	$lang = [];
}

// Download Extension Permissions
$lang = array_merge($lang, [
	'ACP_DOWNLOADS'			=> 'Pannello Download',

	'ACL_A_DL_OVERVIEW'		=> 'Può vedere la schermata iniziale',
	'ACL_A_DL_CONFIG'		=> 'Può gestire le impostazioni generali',
	'ACL_A_DL_TRAFFIC'		=> 'Può gestire il traffico',
	'ACL_A_DL_CATEGORIES'	=> 'Può gestire le categorie',
	'ACL_A_DL_FILES'		=> 'Può gestire i download',
	'ACL_A_DL_PERMISSIONS'	=> 'Può gestire i permessi',
	'ACL_A_DL_STATS'		=> 'Può visualizzare e gestire le statistiche',
	'ACL_A_DL_BLACKLIST'	=> 'Può gestire la blacklist delle estensioni dei file',
	'ACL_A_DL_TOOLBOX'		=> 'Può utilizzare la toolbox',
	'ACL_A_DL_FIELDS'		=> 'Può gestire i campi definiti dall’utente',
	'ACL_A_DL_PERM_CHECK'	=> 'Può controllare i permessi degli utenti',
	'ACL_A_DL_ASSISTANT'	=> 'Può eseguire la procedura guidata di configurazione',

]);
