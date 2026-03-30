# Analisi dei requisiti

## Problema iniziale
Per gli studenti che intendono iscriversi all'Università, spesso devono sostenere un TOLC, prenotabile sul sito dell'ente (CISIA) nelle varie sedi e in due modalità (TOLC@uni e TOLC@casa). 

Tuttavia, spesso, le date disponibili rilasciate vengono riempite in breve tempo, non consentendo ai più di poter prenotare in tempo.
L'alternativa potrebbe essere consultare regolarmente il sito, cosa che però risulta poco comoda e spesso difficile da ricordare. 

Da qui nasce l'idea di creare un'applicazione in grado di leggere periodicamente il sito di CISIA e rilevare i TOLC disponibili secondo le preferenze espresse (di università, tipo di TOLC e modalità di esecuzione).
Dal momento che la ricerca necessita di un dispositivo attivo sempre o quasi, si è pensato di sviluppare un'app per telefono, in quanto quasi sempre attivo e ampiamente utilizzato.

**TOLC notifier** si propone quindi di assolvere questo problema rendendo la ricerca dei TOLC più semplie e immediata, con un'interfaccia intuitiva per configurare la configurazione. 

## Funzionalità da implementare
Nell'applicazione prevista devono essere implementate le seguenti funzionalità: 
- **RICERCA PERIODICA** filtrando le pagine HTML del sito e valutando quali risultati salvare. Tale operazione deve essere fatta in background, quindi non necessita per forza dell'applicazione aperta. 
- **INTERFACCIA DI CONFIGURAZIONE** per esprimere le preferenze e attivare o meno ricerca/notifiche. Dopo un periodo infatti l'utente potrebbe scegliere se continuare a effettuare o ricevere ancora aggiornamenti.
- **NOTIFICHE** per avvisare l'utente dei nuovi risultati trovati. Questa operazione è fondamentale per rendere l'app utile rispetto al normale sito di CISIA.
- **VISIONE DEI RISULTATI** recenti, entro la scadenza e in linea con le preferenze espresse. 

## Requisiti di sviluppo
L'app scelta sarà da sviluppare in *Flutter*, in quando è uno dei framework più utilizzati per lo sviluppo di applicazioni e si presta bene all'installazione su qualsiasi tipo di dispositivo mobile. 

Il salvataggio dei dati dovrà essere fatto in locale, in quanto non si dispone di un server con database accessibile. 

## Requisiti hardware
Perchè l'app funzioni senza problemi si raccomanda che il dispositivo sul quale verrà installata l'applicazione dovrà soddisfare i seguenti requisiti:
- **DIMENSIONI** il telefono deve avere disponibile minimo 1GB di memoria.
- **SISTEMA OPERATIVO** per supportare le funzionalità dell'applicazione è consigliata una versione di Android superiore alla 6.0 e di iOS superiore a 13.0. 
- **RAM** si consiglia un dispositivo con minimo 2GB di RAM. 
- **Connessione** dal momento che l'applicazione deve effettuare uno scraping continuo di pagine presenti su un sito web, si raccomanda di tenere il dispositivo connesso ad Internet.  