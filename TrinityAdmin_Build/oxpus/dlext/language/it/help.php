<?PHP

/**
 *
 * @package   phpBB Extension - Oxpus Downloads
 * @copyright 2002-2021 OXPUS - www.oxpus.net
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
'DL_EXTERNAL_ONLY'              => 'Blocca gli upload interni',
	'HELP_TITLE' => 'Guida online Download Extension',

	'DL_NO_HELP_AVAILABLE' => 'Nessun aiuto disponibile per questa opzione',

	'HELP_DL_ACTIVE'			=> 'Attiva o disattiva i download in base alle opzioni seguenti.',
	'HELP_DL_ANTISPAM'			=> 'Questa opzione blocca i download se l’utente ha il traffico richiesto e il numero minimo di messaggi, e ha raggiunto questo numero di messaggi nelle ultime ore.<br /><br />Esempio:<br />L’impostazione contiene 25 messaggi in 24 ore.<br />Con questa configurazione, i download saranno bloccati per l’utente se ha postato 25 o più messaggi nelle ultime 24 ore.<br />Questa opzione serve a prevenire lo spam per i download, in particolare da parte di nuovi utenti, prima che un membro del team ne venga a conoscenza e possa intervenire.<br />Il download sarà comunque visibile per attirare l’utente, ma verrà mostrato un messaggio che indica la mancanza di autorizzazioni.<br /><br />Per disabilitare questo controllo, imposta uno o entrambi i valori a 0.',
	'HELP_DL_APPROVE'			=> 'Approvazione immediata del download dopo l’invio del modulo.<br />Altrimenti il download sarà nascosto finché non verrà approvato da un moderatore o amministratore.',
	'HELP_DL_APPROVE_COMMENTS'	=> 'Se disabiliti questa opzione, ogni nuovo commento dovrà essere approvato da un moderatore o amministratore prima che altri utenti possano visualizzarlo.',

	'HELP_DL_BUG_TRACKER_CAT'	=> 'Attiva il Bug Tracker per i download in questa categoria.<br />I bug possono essere segnalati e visualizzati da tutti gli utenti registrati per i download correlati e per le altre categorie in cui il tracker è attivo.<br />Solo gli amministratori e moderatori del forum possono gestire i bug.<br />Per ogni modifica alla segnalazione, l’autore riceverà una notifica e anche il membro del team incaricato verrà informato.',

	'HELP_DL_CAT_DESCRIPTION'	=> 'Una breve descrizione della categoria.<br />I BBCode sono disponibili solo se la descrizione viene sempre mostrata nell’indice.<br />Questa descrizione sarà visibile nell’indice download e nelle sottocategorie.',
	'HELP_DL_CAT_EDIT_LINK'		=> 'Determina chi può vedere e usare il link per modificare un download dalla vista categoria, a condizione che questa opzione non sia disattivata.<br />"Download propri" è attivo solo se l’opzione per modificare i propri download è abilitata.',
	'HELP_DL_CAT_ICON'			=> 'L’icona della categoria deve essere già caricata nel forum, ad esempio nella cartella /images/dl_icons/ (deve essere creata prima).<br />Inserisci l’URL relativo dalla root del forum, es. images/dl_icon.gif.<br /><br />Utilizza solo icone compatibili con il browser.<br />I formati consigliati sono JPG, GIF o PNG.<br />Fai attenzione alle dimensioni per evitare che rovinino l’indice, perché non verranno ridimensionate automaticamente.',
	'HELP_DL_CAT_NAME'			=> 'Nome della categoria che verrà mostrato ovunque.<br />Evita caratteri speciali per non creare problemi nella jump box.',
	'HELP_DL_CAT_PARENT'		=> 'Il livello superiore o un’altra categoria a cui assegnare questa categoria.<br />Puoi creare strutture gerarchiche dinamiche con questo menu a discesa.',
	'HELP_DL_CAT_PATH'			=> 'Inserisci un percorso esistente ai tuoi download.<br />Il valore deve essere il nome di una sottocartella della cartella principale (es. downloads/) definita nelle impostazioni principali.<br />Inserisci il nome della cartella con una barra finale.<br />Esempio: per la cartella esistente ´downloads/mods/´ inserisci ´mods/´.<br />Dopo l’invio, il percorso verrà verificato.<br />Assicurati che la cartella esista davvero!<br />Per cartelle nidificate, inserisci l’intera gerarchia.<br />Esempio: ´downloads/mods/misc/´ diventa ´mods/misc/´.<br />Verifica che tutte le sottocartelle abbiano permessi CHMOD 777 e considera che i sistemi Unix/Linux fanno distinzione tra maiuscole e minuscole.',
	'HELP_DL_CAT_RULES'			=> 'Queste regole verranno mostrate sopra le sottocategorie e i download nella vista categoria.',
	'HELP_DL_CAT_TRAFFIC'		=> 'Inserisci il traffico mensile massimo per questa categoria.<br />Questo non aumenta il traffico globale!<br />Inserisci 0 per disattivare il limite.',
	'HELP_DL_CHOOSE_CATEGORY'	=> 'Scegli la categoria che conterrà il download.<br />Il file deve essere già presente nella cartella specificata nella gestione delle categorie.<br />Altrimenti riceverai un messaggio di errore.',
	'HELP_DL_COMMENTS'			=> 'Attiva il sistema di commenti per questa categoria.<br />Gli utenti autorizzati potranno vedere e/o scrivere commenti.<br />Gli amministratori e i moderatori possono modificare e cancellare tutti i commenti, mentre gli autori possono gestire i propri.',
	'HELP_DL_COPY_PERMISSIONS'	=> 'Copia i permessi dalla categoria selezionata.<br />Se hai selezionato la categoria genitore, questa categoria erediterà i suoi permessi.<br />Se il genitore è l’indice (livello superiore), non verranno assegnati permessi. In tal caso imposta i permessi manualmente.',

	'HELP_DL_DELAY_AUTO_TRAFFIC'	=> 'Inserisci il numero di giorni dopo i quali un nuovo utente riceverà il primo traffico automatico.<br />Il conteggio parte dalla data di registrazione.<br />Inserisci 0 per disabilitare.',
	'HELP_DL_DELAY_POST_TRAFFIC'	=> 'Inserisci il numero di giorni dopo i quali un nuovo utente riceverà il primo traffico per i messaggi.<br />Il conteggio parte dalla data di registrazione.<br />Inserisci 0 per disabilitare.',
	'HELP_DL_DISABLE_NOTIFY'		=> 'Questa opzione consente di abilitare o disabilitare completamente le notifiche per nuovi o modificati download.<br />Se attiva, può essere disabilitata individualmente durante l’aggiunta o modifica di un download.<br />Gli utenti riceveranno notifiche solo se le hanno attivate nel proprio UCP.',
	'HELP_DL_DISABLE_POPUP_NOTIFY'	=> 'Se abilitato, non viene registrato il timestamp quando un download viene modificato.',
	'HELP_DL_DROP_TRAFFIC_POSTDEL'	=> 'Se attivo, il traffico guadagnato per un post verrà scalato all’autore in caso di eliminazione (se si elimina un topic, viene scalato solo all’autore del topic!).<br />Nota: il valore originale potrebbe essere diverso da quello attuale, quindi il traffico sottratto potrebbe non corrispondere.',

	'HELP_DL_EDIT_OWN_DOWNLOADS'	=> 'Se abilitata, ogni utente può modificare i propri file caricati anche senza essere amministratore o moderatore.',
	'HELP_DL_EDIT_TIME'				=> 'Numero di giorni per cui un download modificato rimane contrassegnato.<br />Inserisci 0 per disabilitare.',
	'HELP_DL_ENABLE_INDEX_DESC'		=> 'Nasconde la descrizione dei download nella vista categoria.<br />Se abilitata, la lunghezza della descrizione visibile può essere regolata.',
	'HELP_DL_ENABLE_JUMPBOX'		=> 'Mostra o nasconde la jumpbox nel footer dei download.<br />Disattivarla migliora le prestazioni del pannello download.',
	'HELP_DL_ENABLE_POST_TRAFFIC'	=> 'Le due opzioni seguenti definiscono il traffico guadagnato per ogni nuovo topic, risposta o citazione.',
	'HELP_DL_ENABLE_RATE'			=> 'Questa opzione attiva o disattiva il sistema di valutazione.<br />I punteggi esistenti non verranno eliminati ma saranno nuovamente visibili se si riattiva il sistema.',
	'HELP_DL_ENABLE_SEARCH_DESC'	=> 'Nasconde la descrizione del download nei risultati di ricerca.<br />Se disattivata, la lunghezza visualizzata può essere impostata con l’opzione seguente.',
	'HELP_DL_ENABLE_TOPIC'			=> 'Consente la creazione di una discussione nel forum scelto per ogni nuovo download aggiunto dall’amministrazione. Se il download richiede approvazione, la discussione verrà creata successivamente nel pannello di moderazione.',
	'HELP_DL_EXT_NEW_WINDOW'		=> 'Apre i download esterni in una nuova finestra o nella finestra corrente.',
	'HELP_DL_EXTERN'				=> 'Abilita questa funzione per inserire un URL esterno (es. http://www.esempio.com/media.mp3).<br />In questo caso l’opzione "gratuito" non si applica più.<br />Puoi anche inserire la dimensione del file per i download esterni, che sarà visibile e modificabile.<br />Nota: se il download non è segnato come esterno, la dimensione sarà sovrascritta con quella reale del file.',
	'HELP_DL_EXTERN_UP'				=> 'Abilita questa funzione per consentire l’inserimento di un URL esterno nel campo a destra (es. http://www.esempio.com/media.mp3).<br />In questo caso l’opzione "gratuito" non si applica più.',

	'HELP_DL_FILE_DESCRIPTION'	=> 'Una breve descrizione per questo download.<br />Verrà mostrata anche nella categoria del download.<br />I BBCode sono disattivati per questo testo.<br />Inserisci un testo breve per ridurre il carico di dati durante l’apertura della categoria.',
	'HELP_DL_FILE_EDIT_HINT'	=> 'Consente l’inserimento di un testo esplicativo durante l’aggiunta o la modifica di un download. Questo testo è visibile all’inizio del modulo.<br />I BBCode sono ammessi.',
	'HELP_DL_FILE_HASH_ALGO'	=> 'Definisce il metodo utilizzato per calcolare il valore hash di ogni download.<br />Un valore hash sarà calcolato per tutti i download e per tutte le varianti esistenti, ma verrà mostrato nei dettagli del download solo se le impostazioni corrispondenti sono abilitate.<br />I metodi disponibili sono md5 e sha1, in quanto comunemente supportati dai server.<br />L’estensione calcolerà automaticamente il valore hash all’aggiunta o modifica di un download. Il valore verrà anche calcolato all’apertura dei dettagli se non esisteva ancora.<br /><br /><strong>Nota:</strong><br />Se cambi il metodo di calcolo, tutti i valori hash esistenti verranno eliminati perché non corrispondono al nuovo metodo scelto!',
	'HELP_DL_FILES_EXTERN'		=> 'URL da un file esterno',
	'HELP_DL_FILES_INTERN'		=> 'Il nome del file per questo download.<br />Inserisci il nome senza percorso o slash iniziale.<br />Il file deve esistere prima del salvataggio, altrimenti verrà visualizzato un messaggio di errore.<br />Nota che l’uso di estensioni vietate impedisce il salvataggio del file!',

	'HELP_DL_GLOBAL_BOTS'		=> 'Questa opzione consente o nega l’accesso all’area download ai bot.<br />Tutti gli altri permessi non sono influenzati da questa opzione.',
	'HELP_DL_GLOBAL_GUESTS'		=> 'Questa opzione consente o nega l’accesso all’area download agli ospiti.<br />Tutti gli altri permessi non sono influenzati da questa opzione.',
	'HELP_DL_GUEST_STATS_SHOW'	=> 'Include o esclude i dati statistici sugli ospiti dalle statistiche pubbliche per categoria.<br />Lo script continua comunque a raccogliere i dati.<br />Lo strumento statistiche nell’ACP mostra sempre i dati completi.',

	'HELP_DL_HACK_AUTOR'			=> 'L’autore di questo file di download.<br />Lascia vuoto per non mostrare il valore nei dettagli e nella panoramica.',
	'HELP_DL_HACK_AUTOR_EMAIL'		=> 'Indirizzo email dell’autore.<br />Lascia vuoto per non mostrarlo.',
	'HELP_DL_HACK_AUTOR_WEBSITE'	=> 'Sito web dell’autore.<br />Questo URL deve essere il sito dell’autore, non il link diretto al download.<br />Non inserire link a siti con contenuti dubbi o proprietari.',
	'HELP_DL_HACK_DL_URL'			=> 'URL alternativo per scaricare il file.<br />Può essere il sito dell’autore o un’altra fonte.<br />Inserire solo link diretti se l’autore ha dato il permesso esplicito.',
	'HELP_DL_HACK_VERSION'			=> 'Versione del file scaricabile.<br />Verrà mostrata solo nella pagina del download.<br />Non è un campo ricercabile.',
	'HELP_DL_HACKLIST'				=> 'Selezionando `Sì` aggiungerai il download alla lista hack (se attiva).<br />`No` impedisce l’aggiunta alla lista, e `Mostrare info extra` visualizzerà il blocco solo nei dettagli del download.',
	'HELP_DL_HOTLINK_ACTION'		=> 'Qui puoi decidere cosa accade quando un link diretto al download viene intercettato (vedi anche l’ultima opzione).<br />Può mostrare un messaggio (riduce il carico del server) oppure reindirizzare al download (genera più traffico).',

	'HELP_DL_ICON_FREE_FOR_REG'		=> 'Se attivata, l’icona per i download gratuiti sarà bianca anche per i visitatori.<br />Se disattivata, gli ospiti vedranno l’icona rossa invece della bianca.',
	'HELP_DL_INDEX_DESC_HIDE'		=> 'Nasconde le descrizioni delle categorie nell’indice dei download e nelle sottocategorie.<br />Le descrizioni appariranno al passaggio del mouse sulla riga della categoria.',
	'HELP_DL_IS_FREE'				=> 'Attiva questa opzione se il download deve essere gratuito per tutti e non addebitato sul traffico.<br />Scegli "Gratuito per utenti registrati" per permettere il download gratuito solo a questi ultimi.',

	'HELP_DL_KLICKS_RESET'			=> 'Questa opzione azzera i click del mese corrente.<br />Utile se vuoi controllare i click dopo aver aggiornato il file.',

	'HELP_DL_LATEST_COMMENTS'		=> 'Mostra gli ultimi X commenti nei dettagli del download. Inserisci 0 per disattivare.',
	'HELP_DL_LATEST_DOWNLOADS'		=> 'Determina se la lista è disattivata, mostra tutti i download (come nella vista generale), o solo gli ultimi aggiunti/modificati.',
	'HELP_DL_LIMIT_DESC_ON_INDEX'	=> 'Tronca le descrizioni dei download nelle categorie dopo il numero specificato di caratteri.<br />Imposta a 0 per disattivare.',
	'HELP_DL_LIMIT_DESC_ON_SEARCH'	=> 'Tronca le descrizioni dei download nei risultati di ricerca dopo il numero specificato di caratteri.<br />Imposta a 0 per disattivare.',
	'HELP_DL_LINKS_PER_PAGE'		=> 'Numero di download visualizzati per pagina nelle categorie e nelle statistiche ACP.<br />Per hack list e panoramica si usa il valore di “topic per pagina” impostato nel forum.',

	'HELP_DL_MOD_DESC'			=> 'Descrizione dettagliata dell’estensione inserita.<br />È possibile utilizzare BBCode e smiley, e anche gli a-capo saranno rispettati.<br />Questo testo verrà mostrato solo nei dettagli del download.',
	'HELP_DL_MOD_DESC_ALLOW'	=> 'Attiva il blocco delle informazioni sull’estensione durante l’aggiunta o la modifica di un download.',
	'HELP_DL_MOD_LIST'			=> 'Attiva la visualizzazione di questo blocco nei dettagli del download.<br />Se disattivato, l’intero blocco non verrà mostrato.',
	'HELP_DL_MOD_REQUIRE'		=> 'Indica quali altre estensioni sono necessarie per usare o installare questo download.<br />Questo testo verrà mostrato solo nei dettagli del download.',
	'HELP_DL_MOD_TEST'			=> 'Specifica su quale versione di phpBB è stata testata con successo questa estensione.<br />Inserisci solo la versione testata (es. "3.3").<br />Lo script visualizzerà "phpBB X", quindi devi inserire solo "X".<br />Questo testo sarà visibile solo nei dettagli del download.',
	'HELP_DL_MOD_TODO'			=> 'Qui puoi inserire le prossime attività previste per questa estensione o quelle attualmente in lavorazione.<br />Questo testo verrà usato per generare la lista To-do, accessibile dal footer del download.<br />Serve a informare gli utenti sullo stato di sviluppo dell’estensione.<br />Gli a-capo saranno rispettati, ma i BBCode non sono disponibili.<br />La lista può essere compilata anche se il blocco è disattivato.',
	'HELP_DL_MOD_WARNING'		=> 'Avviso importante su questa estensione da tenere in considerazione durante installazione, utilizzo o interazione con altre estensioni.<br />Il testo verrà evidenziato nei dettagli (di default in rosso).<br />Gli a-capo saranno rispettati.<br />I BBCode non sono disponibili.',
	'HELP_DL_MUST_APPROVE'		=> 'Attiva questa opzione per obbligare l’approvazione di ogni nuovo file caricato prima che venga visualizzato in questa categoria.<br />Amministratori e moderatori riceveranno una notifica via email sui nuovi download in attesa.',

	'HELP_DL_NAME'					=> 'Questo è il nome del download che verrà visualizzato in tutta l’estensione.<br />Evita caratteri speciali per prevenire errori.',
	'HELP_DL_NEW_TIME'				=> 'Numero di giorni in cui un download verrà contrassegnato come nuovo.<br />Inserisci 0 per disattivare questa funzione.',
	'HELP_DL_NEWTOPIC_TRAFFIC'		=> 'Quantità di traffico accreditato all’autore per la creazione di un nuovo topic.',
	'HELP_DL_NO_CHANGE_EDIT_TIME'	=> 'Seleziona questa opzione per non aggiornare la data di ultima modifica del download.<br />Le notifiche via email, popup o messaggi nel forum non saranno influenzate.',

	'HELP_DL_OFF_HIDE'					=> 'Nasconde il link nella navigazione del forum.<br />In alternativa l’area download mostrerà solo un messaggio.',
	'HELP_DL_OFF_NOW_TIME'				=> 'Disattiva l’area download immediatamente o in modo programmato tra gli orari indicati.',
	'HELP_DL_OFF_PERIOD'				=> 'Intervallo temporale in cui l’area download sarà automaticamente disattivata.',
	'HELP_DL_OFF_PERIOD_TILL'			=> 'Intervallo temporale in cui l’area download sarà automaticamente disattivata.',
	'HELP_DL_ON_ADMINS'					=> 'Permette agli amministratori del forum di accedere e gestire l’area download anche quando l’estensione è disattivata.<br />Altrimenti anche loro saranno esclusi.',
	'HELP_DL_OVERALL_TRAFFIC'			=> 'Limite globale per gli utenti registrati per tutti i download e, se attivato, anche per gli upload nel mese corrente.<br />Una volta raggiunto il limite, ogni download verrà bloccato e, se attivo, gli upload saranno disabilitati.',
	'HELP_DL_OVERALL_GUEST_TRAFFIC'		=> 'Limite globale per gli ospiti per tutti i download e, se attivato, anche per gli upload nel mese corrente.<br />Una volta raggiunto il limite, ogni download verrà bloccato e, se attivo, gli upload saranno disabilitati.',
	'HELP_DL_OVERVIEW_LINK'				=> 'Mostra o nasconde il link alla lista completa.<br />Nota:<br />Se il link è disabilitato, non sarà possibile accedere alla lista completa nemmeno tramite link diretto!',

	'HELP_DL_PHYSICAL_QUOTA'	=> 'Limite fisica complessiva che l’estensione può utilizzare per salvare e gestire i download.<br />Se viene raggiunta questa soglia, nuovi download potranno essere aggiunti solo tramite client FTP e la gestione file nell’ACP.',
	'HELP_DL_POSTS'				=> 'Ogni utente, inclusi amministratori e moderatori download, deve aver pubblicato almeno questo numero di messaggi per poter scaricare file non contrassegnati come gratuiti.<br />Si consiglia vivamente di installare un modulo antispam per evitare abusi.<br />Inserisci 0 per disattivare la funzione (consigliato per forum appena creati).',
	'HELP_DL_PREVENT_HOTLINK'	=> 'Abilita questa opzione per impedire i link diretti ai download (hotlink), tranne che dai dettagli del download.<br />Questa opzione <strong>non</strong> protegge le cartelle dei download!',

	'HELP_DL_RATE_POINTS'			=> 'Imposta il numero massimo di punti che un utente può assegnare a un download.<br /><br /><strong>Nota:</strong><br />Modificando questo valore, tutti i punteggi assegnati saranno azzerati affinché l’estensione possa ricalcolare i voti correttamente!',
	'HELP_DL_REPLY_TRAFFIC'			=> 'L’utente riceverà l’importo di traffico specificato per ogni nuova risposta o citazione.',
	'HELP_DL_REPORT_BROKEN'			=> 'Attiva o disattiva la funzione per segnalare download non funzionanti.<br />Se impostato su `non per ospiti`, solo gli utenti registrati potranno inviare segnalazioni.',
	'HELP_DL_REPORT_BROKEN_LOCK'	=> 'Se attivata, questa opzione disattiva il download quando viene segnalato come non funzionante.<br />Il pulsante di download sarà nascosto finché un amministratore o moderatore non riattiverà il file.',
	'HELP_DL_REPORT_BROKEN_MESSAGE'	=> 'Se un download è stato segnalato come difettoso, verrà mostrato un messaggio.<br />Se attivato, il messaggio apparirà solo al posto del pulsante di download finché il file è disattivato.',
	'HELP_DL_REPORT_BROKEN_VC'		=> 'Abilita un codice di conferma visivo (CAPTCHA) per la segnalazione di download non funzionanti.<br />La segnalazione sarà salvata solo se il codice corretto viene inserito, e amministratori o moderatori riceveranno una notifica via email.',

	'HELP_DL_RSS_ENABLE'				=> 'Abilita il feed RSS per i download.<br />Se disabilitato, le due opzioni seguenti determinano cosa verrà mostrato all’utente.',
	'HELP_DL_RSS_OFF_ACTION'			=> 'Questa opzione definisce il comportamento del feed disabilitato.',
	'HELP_DL_RSS_OFF_TEXT'				=> 'Questo testo sarà mostrato al posto dei download nel feed RSS se il feed è stato disattivato e l’opzione precedente è impostata per mostrare un messaggio.<br />Se invece è stato impostato un reindirizzamento, il testo rimane attivo ma non viene visualizzato.',
	'HELP_DL_RSS_CATS'					=> 'Le voci nel feed RSS saranno prese da tutte o da specifiche categorie selezionate nella lista.<br />Per selezionare più categorie, tieni premuto CTRL e fai clic sui nomi.<br />Puoi scegliere se includere le categorie selezionate o escluse nel feed.',
	'HELP_DL_RSS_PERMS'					=> 'Oltre alla selezione delle categorie, è consigliabile configurare i permessi dell’utente in modo simile a quelli degli ospiti o bot per evitare che il feed mostri contenuti non accessibili.<br />Con l’impostazione `per ospiti`, solo le categorie visibili agli ospiti verranno incluse.<br />Se il feed non mostra alcun contenuto a causa dei permessi, si comporterà come se fosse disattivato.',
	'HELP_DL_RSS_NEW_UPDATE'			=> 'Questa opzione contrassegna i download nuovi o aggiornati, come avviene con l’icona miniatura nella vista categoria.',
	'HELP_DL_RSS_NUMBER'				=> 'Numero massimo di download visualizzati nel feed.',
	'HELP_DL_RSS_SELECT'				=> 'Questa opzione determina se elencare i download più recenti o casuali nel feed, in base alle categorie, permessi e quantità selezionata.',
	'HELP_DL_RSS_DESC_LENGTH'			=> 'Con questa opzione puoi mostrare la descrizione completa del download o una versione abbreviata (secondo l’impostazione dell’indice download).<br /><br /><strong>Attenzione:</strong><br />Non tutti i lettori RSS interpretano correttamente l’HTML. Alcuni potrebbero mostrare il testo in modo errato o non mostrarlo affatto. In questi casi, l’utente dovrà usare un altro lettore o disattivare le descrizioni.',
	'HELP_DL_RSS_DESC_LENGTH_SHORTEN'	=> 'Tronca la descrizione dopo un numero definito di caratteri (x), se la descrizione abbreviata è attivata (vedi opzione precedente).<br />Imposta 0 per non mostrare alcuna descrizione!',

	'HELP_DL_SET_ADD'				=> 'Con questa opzione puoi selezionare l’utente con cui verranno pubblicati i nuovi download.<br />Puoi selezionare l’utente corrente, un utente definito nelle impostazioni della categoria (se hai scelto “selezione categoria” qui) o un altro utente registrato nel forum.<br /><br />Nota: il topic del download generato automaticamente nel forum userà comunque l’utente previsto per quella funzione. Questa opzione cambia solo il valore di “utente aggiunto” nei nuovi download.<br /><br /><strong>Avviso:</strong><br />L’ID utente non viene verificato direttamente dall’estensione, quindi un ID non valido può causare errori!',
	'HELP_DL_SHORTEN_EXTERN_LINKS'	=> 'Inserisci la lunghezza del link esterno da visualizzare nei dettagli del download.<br />In base alla lunghezza, il link sarà troncato al centro o dalla fine.<br />Lascia vuoto o inserisci 0 per disattivare questa funzione.',
	'HELP_DL_SHOW_FOOTER_EXT_STATS'	=> 'Mostra nel footer dei download il traffico complessivo per utenti registrati e ospiti e il numero di clic nel mese corrente.',
	'HELP_DL_SHOW_FILE_HASH'		=> 'Mostra o nasconde il valore hash del file nei dettagli del download.',
	'HELP_DL_SHOW_FOOTER_LEGEND'	=> 'Questa opzione attiva o disattiva la legenda delle icone di stato nel footer dei download.<br />Le icone accanto ai download non saranno modificate da questa opzione.',
	'HELP_DL_SHOW_FOOTER_STAT'		=> 'Questa opzione attiva o disattiva le mini statistiche nel footer dei download.<br />Anche se disattivata, la statistica continuerà a raccogliere dati.',
	'HELP_DL_SHOW_REAL_FILETIME'	=> 'Questa opzione mostra l’ora reale dell’ultima modifica del file nei dettagli del download.<br />È l’orario più preciso, anche per file caricati via FTP o aggiornati più volte senza tracciamento.',
	'HELP_DL_SIMILAR_DL'			=> 'Mostra download simili dalla stessa categoria nella vista dettagliata.<br /><br />Nota: Con molte voci nel database, questa funzione può rallentare il caricamento della pagina, quindi si consiglia di disattivarla.',
	'HELP_DL_SIMILAR_DL_LIMIT'		=> 'Numero di download simili da mostrare nella pagina dei dettagli.',
	'HELP_DL_SORT_PREFORM'			=> 'Con l’opzione “Predefinito” tutti i download verranno ordinati per tutti gli utenti come definito nell’ACP.<br />Con l’opzione “Utente” ogni utente può scegliere come ordinare i download e se mantenere l’ordinamento fisso o espanderlo con altri criteri.',
	'HELP_DL_STAT_PERM'				=> 'Seleziona da quale livello utente è possibile visualizzare le statistiche dei download.<br />Ad esempio, se attivi solo per Moderatori Download, solo loro e gli amministratori potranno accedere alla pagina (non i moderatori del forum).<br />Attenzione: questa pagina può richiedere molto tempo per il caricamento su forum grandi o con molti download, quindi si raccomanda di limitarne l’accesso.',
	'HELP_DL_STATISTICS'			=> 'Abilita le statistiche dettagliate sui file scaricabili.<br />Nota che queste statistiche generano ulteriori query e dati nel database, in una tabella separata.',
	'HELP_DL_STATS_PRUNE'			=> 'Inserisci il numero massimo di righe dati che la statistica per questa categoria può contenere.<br />Ogni nuova riga eliminerà la più vecchia.<br />Inserisci 0 per disattivare il pruning.',
	'HELP_DL_STOP_UPLOADS'			=> 'Con questa opzione puoi abilitare o disabilitare i caricamenti.<br />Se disattivata, solo gli amministratori potranno caricare nuovi file tramite il modulo upload.<br />Attivala per consentire agli utenti il caricamento in base ai permessi di categoria e gruppo.',

	'HELP_DL_THUMB'						=> 'Con questo campo puoi caricare un’immagine di anteprima (thumbnail) da visualizzare nei dettagli del download (nota le dimensioni massime e la dimensione del file indicate sotto questo campo).<br />Se esiste già una miniatura, puoi caricarne una nuova per sostituirla.<br />Se selezioni la casella “elimina” di una miniatura esistente, essa verrà cancellata.',
	'HELP_DL_THUMB_CAT'					=> 'Questa opzione abilita le miniature per i download in questa categoria.<br />La dimensione massima di queste miniature è definita nelle impostazioni generali dell’estensione.',
	'HELP_DL_THUMB_MAX_DIM_X'			=> 'Questo valore limita la larghezza massima dell’immagine delle miniature caricate.<br />Le miniature sono limitate a 150 x 100 pixel e possono essere visualizzate in una finestra popup cliccandoci sopra.<br /><br />Inserisci 0 per disattivare le miniature (non consigliato se è impostata la dimensione del file).<br />Le miniature esistenti verranno comunque visualizzate a meno che la dimensione del file non sia impostata a 0.',
	'HELP_DL_THUMB_MAX_DIM_Y'			=> 'Questo valore limita l’altezza massima dell’immagine delle miniature caricate.<br />Le miniature sono limitate a 150 x 100 pixel e possono essere visualizzate in una finestra popup cliccandoci sopra.<br /><br />Inserisci 0 per disattivare le miniature (non consigliato se è impostata la dimensione del file).<br />Le miniature esistenti verranno comunque visualizzate a meno che la dimensione del file non sia impostata a 0.',
	'HELP_DL_THUMB_MAX_SIZE'			=> 'Inserisci 0 come dimensione per disattivare completamente le miniature in tutte le categorie.<br />Se abiliti le miniature definendo una dimensione massima, specifica la dimensione dell’immagine da cui verranno create.<br />Se disattivi le miniature, quelle esistenti non verranno più visualizzate nei dettagli.',
	'HELP_DL_TODO_LINK'					=> 'Abilita o disabilita il collegamento alla lista delle cose da fare (to-do) nel piè di pagina del download.<br />I dati della lista to-do e la loro gestione non sono influenzati da questa opzione.',
	'HELP_DL_USE_TODOLIST'				=> 'Abilita o disabilita la lista delle cose da fare (to-do).',
	'HELP_DL_TOPIC_DETAILS'				=> 'Mostra nei topic del forum la descrizione del download, il nome del file, la dimensione o, per i download esterni, l’URL.<br />Questo testo può essere posizionato sopra o sotto il testo inserito precedentemente.<br />Se il topic viene creato tramite la categoria del download, l’opzione nella configurazione generale verrà ignorata.',
	'HELP_DL_TOPIC_FORUM'				=> 'Il forum in cui verranno visualizzati tutti i nuovi topic sui download.<br />Per selezionare un forum per categoria, scegli l’opzione “Selezione categoria” invece di un forum specifico.',
	'HELP_DL_TOPIC_FORUM_C'				=> 'Il forum in cui verranno visualizzati tutti i nuovi topic per i download di questa categoria.',
	'HELP_DL_TOPIC_POST_CATNAME'		=> 'Aggiunge il nome della categoria nel messaggio del topic generato per i download. Il nome verrà inserito dopo il titolo del download.<br />Nota:<br />I topic esistenti non verranno aggiornati a meno che il download non venga modificato.',
	'HELP_DL_TOPIC_TEXT'				=> 'Testo libero per la creazione dei topic sui download. BBCodes, HTML e smiley non sono consentiti poiché il testo serve solo da introduzione.',
	'HELP_DL_TOPIC_TITLE_CATNAME'		=> 'Aggiunge il nome della categoria al titolo del topic che verrà generato per un download. Il nome verrà separato dal nome del download tramite “-”.<br />Nota:<br />I topic esistenti non verranno aggiornati a meno che il download non venga modificato.',
	'HELP_DL_TOPIC_TYPE'				=> 'Questa opzione definisce il tipo di topic per i download.<br />Dopo aver cambiato tipo, tutti i nuovi download o quelli modificati verranno pubblicati con il nuovo tipo. I topic esistenti non verranno modificati.',
	'HELP_DL_TOPIC_USER'				=> 'Seleziona l’utente che sarà indicato come autore dei topic relativi ai download.<br />Se vuoi che sia l’utente corrente, seleziona “utente corrente”. L’opzione “selezione da categoria” permette di scegliere un utente diverso per ogni categoria. Può essere l’utente corrente o un utente selezionato tramite ID utente inserito nel campo accanto.<br /><br /><strong>Avviso:</strong><br />L’ID utente non viene verificato direttamente, quindi un ID inesistente può causare problemi!',
	'HELP_DL_TRAFFIC'					=> 'Il traffico massimo che un file può generare.<br />Un valore di 0 disattiva il controllo del traffico.<br />Nota: se il download è esterno, il traffico sarà impostato automaticamente a 0.',
	'HELP_DL_TRAFFIC_OFF'				=> 'Disattiva completamente la gestione del traffico nell’area download e disabilita tutte le relative opzioni.<br />Quando è attivo, tutti i riferimenti al traffico nei testi del forum saranno nascosti e nessun limite verrà applicato. Il traffico non sarà aggiornato per download/upload/post.<br />Gli utenti possono comunque ricevere traffico tramite il modulo di gestione del traffico nell’ACP.<br />Le funzionalità e i moduli ACP relativi alla gestione del traffico restano disponibili.',
	'HELP_DL_TRAFFICS_FOUNDER'			=> 'Se il traffico è disabilitato per i founder, questi potranno continuare a scaricare/caricare file senza limiti.<br />Anche se il traffico per post/topic è abilitato, i founder non saranno interessati.<br />Questa opzione congela il traffico attuale finché non verrà disattivata.',
	'HELP_DL_TRAFFICS_OVERALL'			=> 'Questa opzione limita il traffico complessivo per gli utenti registrati.<br />Può essere abilitato/disabilitato per tutti o solo per membri di determinati gruppi, selezionabili nell’opzione successiva.<br />Se disabilitato, gli utenti avranno traffico illimitato.',
	'HELP_DL_TRAFFICS_OVERALL_GROUPS'	=> 'Applica l’opzione precedente ai gruppi utenti selezionati e ai loro membri.',
	'HELP_DL_TRAFFICS_USERS'			=> 'Limita il traffico per utenti registrati.<br />Può essere abilitato/disabilitato per tutti o solo per gruppi specifici.<br />Se disattivato, nessun limite verrà applicato, anche se attivo il credito per topic/post.<br />Gli utenti non riceveranno traffico aggiuntivo.',
	'HELP_DL_TRAFFICS_USERS_GROUPS'		=> 'Applica l’opzione precedente ai gruppi selezionati se si limita il traffico per gruppi.',
	'HELP_DL_TRAFFICS_GUESTS'			=> 'Abilita o disabilita il traffico per gli ospiti.<br />Se disabilitato, gli ospiti avranno traffico illimitato.<br />Questa opzione può generare carichi elevati sul server fino a causarne il blocco, quindi è sconsigliato disattivarla.',

	'HELP_DL_UPLOAD_FILE'			=> 'Il file da caricare dal tuo computer.<br />Assicurati che la dimensione del file sia inferiore al limite indicato e che l’estensione del file non sia inclusa nell’elenco visibile sotto questo campo.',
	'HELP_DL_UPLOAD_TRAFFIC_COUNT'	=> 'Se questa opzione è abilitata, i caricamenti ridurranno il traffico mensile complessivo.<br />Una volta raggiunto il limite complessivo, non sarà più possibile caricare file e i nuovi file dovranno essere caricati tramite un client FTP e aggiunti dal pannello di amministrazione (ACP).',
	'HELP_DL_USE_EXT_BLACKLIST'		=> 'Se abiliti la blacklist, tutti i tipi di file specificati saranno bloccati per i nuovi caricamenti o modifiche ai download.',
	'HELP_DL_USE_HACKLIST'			=> 'Questa opzione abilita o disabilita la lista hack.<br />Se abilitata, potrai inserire informazioni hack durante l’aggiunta o la modifica di un download per inserirlo nella lista.<br />Se disabilitata, la lista hack sarà completamente nascosta per tutti gli utenti, ma potrai riattivarla in qualsiasi momento.<br />Nota che tutte le informazioni hack verranno perse se modifichi un download dopo aver disattivato questa lista.',
	'HELP_DL_USER_TRAFFIC_ONCE'		=> 'Seleziona se i download devono ridurre il traffico dell’utente solo la prima volta che scarica un file.<br /><strong>Nota:</strong><br />Questa opzione NON modifica lo stato del download stesso!',
	'HELP_DL_VISUAL_CONFIRMATION'	=> 'Attiva questa opzione per richiedere agli utenti l’inserimento di un codice di conferma a 5 cifre prima di scaricare un file.<br />Se l’utente inserisce un codice errato o nessun codice, l’estensione mostrerà un messaggio invece di avviare il download.<br />Se questa opzione è disattivata, l’utente potrà scaricare direttamente dalla pagina dei dettagli.',
	'HELP_NUMBER_RECENT_DL_ON_PORTAL'	=> 'Il numero di ultimi download che l’utente vedrà nel portale.<br />L’estensione utilizza la data dell’ultima modifica per questa lista, quindi è possibile che un download più vecchio appaia in cima.',

]);
