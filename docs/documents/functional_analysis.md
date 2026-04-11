# Analisi funzionale

## Potenziali problemi
Lo sviluppo delle funzionalità precedentemente esposte nell'[analisi dei requisiti](./requirements.md) porta con sè alcuni problemi da implementare nella fase di sviluppo:
1. **Scheduling processi** lo scheduling delle azioni potrebbe essere bloccato all'interno dei sistemi operativi (per iOS potrebbero non esserci sufficienti permessi) se effettuate troppo frequentemente. 
2. **Errori in background** se il processo di ricerca viene eseguito in background, non è possibile salvare eventuali allarmi né mostrarli al momento. Si propone di utilizzare un logger per il salvataggio delle informazioni relative a tali azioni. 
3. **Limitazioni background** anche se l'esecuzione dei processi è attiva in background, le operazioni potrebbero essere limitate. Occorre quindi chiedere i permessi per un utilizzo completo delle risorse, sapendo che l'applicazione è in funzione in background per un lasso di tempo decisamente ridotto. 
4. **Aggiornamento in tempo reale** in caso delle funzioni in background i risultati devono essere immediatamente visibile in caso di app aperta. In caso di eliminazione o modifica dei valori, il responso grafico deve essere immediato. Per l'utente, inoltre, deve essere sempre possibile poter disabilitare il processo di ricerca o notifiche, quando desidera. 


## Sviluppo pagine
Dato le funzionalità che l'app si intende di offrire, di seguito vengono riportate le singole pagine scelte con le funzionalità di ciascuna. 
Non si specificano nel dettaglio le caratteristiche in grafiche in quanto l'applicazione userà gli elementi standard forniti da flutter, data la sua semplicità.

### Risultati - Home page
La home page coincide con la pagina degli ultimi risultati.
Tali risultati sono il frutto di preferenze espresse in un'altra sezione, che vengono mostrati a partire dalla data meno recente, in modo da esibire subito le novità. 

**N.B.** I risultati mostrati saranno solo quelli la cui data di iscrizione non sia precedente al momento della visita della pagina, per evitare di mostrare posti quando ormai le iscrizioni sono concluse. 

I risultati nuovi, per una maggiore visibilità, dovranno essere evidenziati da un flag o badge, in modo che siano immediatamente visibili una volta che l'utente clicca sulla notifica. 

Ogni risultato dovrà essere costituito dai seguenti elementi:
- ***Università*** sarà il nome completo derivato dallo scraping delle pagine
- ***TOLC*** la sua tipologia, definendo anche se si tratta di TOLC@CASA o TOLC@UNI. 
- ***Data dell'esame*** una delle informazioni principali che l'utente deve sapere.
- ***Luogo*** spesso non coincide con il nome dell'università (ad esempio l'Università di Bologna ha anche la sede di Rimini).
- ***Data di iscrizione*** importante da rispettare per l'iscrizione.
- ***Posti disponibili*** per indicare se effettivamente l'utente ha ancora possibilità di accedere all'esame. 

*Altre informazioni circa l'orario e l'edificio in cui si svolgerà l'esame (se TOLC@UNI) verrà indicato una volta effettuata la prenotazione nell'area riservata di CISIA*. 

### Preferenze
La pagina delle preferenze deve essere personalizzata dall'utente in modo da ricevere i risultati. 
Le operazioni concesse saranno:
- **Aggiunta** di una preferenza. Ogni preferenza si identifica univocamente dal tipo di TOLC e dall'impostazione di TOLC@CASA e TOLC@UNI (posso infatti voler prenotare il TOLC-I in università in certe sedi, mentre voler prenotare sia il TOLC-I università e a casa in altre).
- **Modifica** dal momento che i dati univoci sono il tipo di TOLC e i flag di TOLC@UNI e TOLC@CASA, la modifica riguarderà soltanto i nomi dell'università. 
- **Rimozione** rimozione della preferenza completa.

**N.B.** Le università inserite dall'utente potrebbero non essere il nome completo, ma necessariamente una porzione. Ovviamente, più è dettagliato il nome più sarà ristretta la ricerca. 

### Impostazioni
Le impostazioni sono la pagina che è utile all'utente per poter agire sull'abilitazione delle principali funzionalità dell'applicazione. 
In particolare, l'utente può agire su:
- ***Notifiche*** che l'utente che può abilitare o disabilitare.
- ***Ricerca background*** che può essere disattivata (se per esempio per il momento sono si desiderà più fare TOLC).
- ***Intervallo di ricerca*** che indica il numero di ore che devono passare tra una ricerca in background e l'altra. Può essere utile se l'utente vuole richiedere a


## Notifiche
Le notifiche sono uno degli aspetti più importanti dell'applicazione, in quanto consentono di avvisare l'utente dei nuovi aggiornamenti. 

Una notifica deve in particolare contenere i seguenti dati, che sintetizzano il risultato trovato:
- **TOLC**
- **Luogo** si intende università e sede
- **Data** si intende la data di sostenimento dell'esame