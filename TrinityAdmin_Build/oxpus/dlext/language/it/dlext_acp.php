<?php

/**
 *
 * @package   phpBB Extension - Oxpus Downloads
 * @copyright 2002-2024 OXPUS - www.oxpus.net
 * @license   http://opensource.org/licenses/gpl-2.0.php GNU General Public License v2
 *
 */

/*
* [ english ] language file for Download Extension
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

$lang = array_merge($lang, [
'DL_CFG_EXTERNAL_ONLY'          => 'Consenti solo link esterni (blocca gli upload per i non amministratori)',
'DL_CFG_EXTERNAL_ONLY_EXPLAIN'  => 'Se abilitato, gli utenti possono inviare solo un URL; il caricamento reale è riservato agli amministratori.',

	'DL_LIMIT_TITLE_SHOW'				=> 'Visualizza limiti attuali',
	'DL_LIMIT_TITLE_HIDE'				=> 'Imposta limiti',
	'DL_PHP_LIMITS'						=> 'Impostazioni in PHP',
	'DL_CUR_LIMITS'						=> 'Impostazioni all’interno dell’estensione download',

	'DL_PHP_INI_EXPLAIN'				=> 'Le impostazioni PHP possono essere modificate nel file <strong>%1$s</strong> o in uno dei file di configurazione inclusi; vedi le informazioni PHP.',

	'DL_LIMIT_PHP_FILE_UPLOAD'			=> 'file_upload',
	'DL_LIMIT_PHP_MAX_FILE_UPLOAD'		=> 'max_file_upload',
	'DL_LIMIT_PHP_MAX_INPUT_TIME'		=> 'max_input_time',
	'DL_LIMIT_PHP_MAX_EXECUTION_TIME'	=> 'max_execution_time',
	'DL_LIMIT_PHP_MEMORY_LIMIT'			=> 'memory_limit',
	'DL_LIMIT_PHP_POST_MAX_SIZE'		=> 'post_max_size',
	'DL_LIMIT_PHP_UPLOAD_MAX_FILESIZE'	=> 'upload_max_filesize',

	'DL_LIMIT_TOTAL_REMAIN'				=> 'Spazio rimanente per tutti i file scaricabili',
	'DL_LIMIT_THUMBNAIL_XY_SIZE'		=> 'Dimensioni massime delle miniature caricate',
	'DL_LIMIT_THUMBNAIL_XYSIZE'			=> '%1$s x %2$s pixel',

	'DL_LIMIT_PHP_FILE_UPLOAD_EXPLAIN'			=> 'Default = 1 (On)<br />Permette a PHP di elaborare i file caricati.<br />Altrimenti, questi file non saranno disponibili per PHP.',
	'DL_LIMIT_PHP_MAX_FILE_UPLOAD_EXPLAIN'		=> 'Default = 20, raccomandazione >= 10<br />Limita il numero di file caricati contemporaneamente che PHP può elaborare.',
	'DL_LIMIT_PHP_MAX_INPUT_TIME_EXPLAIN'		=> 'Default = -1 (non attivo)<br />Tempo massimo per elaborare i dati POST e GET in secondi.<br />Il periodo di tempo inizia con l’avvio di PHP e termina con l’inizio del primo script PHP.',
	'DL_LIMIT_PHP_MAX_EXECUTION_TIME_EXPLAIN'	=> 'Default = 30 secondi<br />Tempo massimo di esecuzione di uno script PHP dall’avvio all’esecuzione completa.<br />Trascorso questo tempo, PHP interrompe l’elaborazione, a meno che lo script non sia stato terminato prima.',
	'DL_LIMIT_PHP_MEMORY_LIMIT_EXPLAIN'			=> 'Default = 128 MB (nelle versioni moderne di PHP)<br />Limita la RAM del server che PHP può utilizzare.<br />Dovrebbe essere aumentato in base alla dimensione dei file scaricabili utilizzati.<br />È fortemente consigliato non superare il limite di RAM del server.',
	'DL_LIMIT_PHP_POST_MAX_SIZE_EXPLAIN'		=> 'Default = 8 MB<br />Consumo massimo di memoria per uno stream di caricamento HTTP(S) / modulo HTML.<br />Limitato dal valore impostato in memory_limit.<br />Dovrebbe essere aumentato per consentire il download di file più grandi.',
	'DL_LIMIT_PHP_UPLOAD_MAX_FILESIZE_EXPLAIN'	=> 'Default = 2 MB<br />Dimensione massima per file che PHP può elaborare dopo l’invio da un modulo HTML.<br />I file più grandi non saranno disponibili per PHP.<br />Dovrebbe essere aumentato per file scaricabili di dimensioni maggiori.<br /><strong>Attenzione:</strong><br />Questo limite si applica per ogni singolo file caricato. Se più file vengono caricati insieme, il limite viene moltiplicato per file e limitato dal valore di post_max_size.',

	'DL_LIMIT_TRAFFIC_USER_REMAIN_EXPLAIN'		=> 'Traffico download attualmente disponibile per tutti gli utenti registrati in questo mese.',
	'DL_LIMIT_TRAFFIC_GUESTS_REMAIN_EXPLAIN'	=> 'Traffico download attualmente disponibile per tutti gli ospiti in questo mese.',
	'DL_LIMIT_TOTAL_REMAIN_EXPLAIN'				=> 'Lo spazio massimo disponibile per tutti i file che devono essere offerti per il download.<br /><strong>Importante:</strong><br />Miniature e versioni dei file sono escluse da questo limite!<br /><strong>Attenzione:</strong><br />Questo limite non deve mai raggiungere o superare lo spazio di archiviazione fisicamente disponibile sul server, altrimenti potrebbe causare malfunzionamenti!<br />Assicurati inoltre di includere anche le dimensioni delle directory delle miniature e delle versioni dei file nel calcolo del limite fisico.',
	'DL_LIMIT_THUMBNAIL_SIZE_EXPLAIN'			=> 'Le miniature caricate con dimensioni superiori saranno rifiutate e non verranno incluse nei download.',
	'DL_LIMIT_THUMBNAIL_XY_SIZE_EXPLAIN'		=> 'Dimensioni massime in pixel per la larghezza e l’altezza di tutte le miniature caricate.<br />Le immagini più grandi saranno rifiutate.',
	'DL_LIMIT_THUMBNAIL_XYSIZE_EXPLAIN'			=> '%1$s x %2$s pixel',
]);
