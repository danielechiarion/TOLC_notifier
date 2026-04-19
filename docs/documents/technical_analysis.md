# Analisi tecnica
Questa sezione espone le principali classi e funzionalità del codice scritto in Dart per il funzionamento dell'applicazione.
Dettagli specifici relativi a firma dei metodi, parametri, ecc. sono consultabili nell'apposita [documentazione del codice](../code/index.html).


## Servizi configurati
L'applicazione, per funzionare, necessitava di alcuni servizi utlizzati sia da foreground che da background. 
In particolare, i principali da menzionare sono:

### Database
Il database relazionale, nell'ambiente flutter, può essere gestito con librerie come **Drift** o **sqflite**.
Tuttavia, il primo package menzionato è un derivato del secondo e non consente la scrittura di query come si farebbe in un normale database SQL, ma solo utilizzando metodi d'istanza, come i seguenti:

```dart
import 'package:drift/native.dart';
import 'package:drift/drift.dart';

/* definizione struttura della tabella */
class Utenti extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
}

@DriftDatabase(tables: [Utenti])
class DatabaseEsempio extends _$DatabaseEsempio {
  DatabaseEsempio() : super(NativeDatabase.memory()); // database temporaneo in RAM
  @override int get schemaVersion => 1;
}

Future<void> esempioDatabaseLampo() async {
  final db = DatabaseEsempio();

  /* inserimento di un dato */
  print('Sto inserendo l\'utente...');
  await db.into(db.utenti).insert(UtentiCompanion.insert(nome: 'Mario Rossi'));

  /* recupero di un dato immediatamente dopo */
  final listaUtenti = await db.select(db.utenti).get();

  /* risultato finale */
  for (var utente in listaUtenti) {
    print('Trovato nel DB: ID ${utente.id} - Nome: ${utente.nome}');
  }

  await db.close();
}
```

**sqflite**, invece, propone funzioni che permettono di eseguire query tramite passaggio di parametri separati, oppure inserendo il testo di una query classica, adatto per le richieste più complesse. Inoltre, non necessita di creare istanze per definire tabelle o utilizzare tanti metodi annidati come nel caso precedente. 

```dart
import 'package:sqflite/sqflite.dart';

/* usiamo inMemoryDatabasePath per non
lasciare file residui */
/* definizione di una tabella attraverso classica
query SQL */
final db = await openDatabase(
inMemoryDatabasePath,
version: 1,
onCreate: (db, version) async {
    await db.execute('CREATE TABLE Prodotti (id INTEGER PRIMARY KEY, nome TEXT, prezzo REAL)');
},
);

/* inserimento di valori utilizzando le funzioni
di predefinite con parametri */
await db.insert('Prodotti', {'nome': 'Pizza', 'prezzo': 9.99});
await db.insert('Prodotti', {'nome': 'Birra', 'prezzo': 5.50});

/* query con funzione nativa per ottenere dati.
Più sicura, gestisce tutto e solo dopo compone la stringa per la query */
final List<Map<String, dynamic>> queryNativa = await db.query(
'Prodotti',
columns: ['nome', 'prezzo'],
where: 'prezzo > ?',
whereArgs: [6.00],
);

print('Risultato Helper (Prezzo > 6): $queryNativa');

/* operazione con il database effettuata con la query estesa,
massima personalizzazione e adatta a richieste più complesse */
final List<Map<String, dynamic>> queryRaw = await db.rawQuery(
'SELECT UPPER(nome) as nome_maiuscolo FROM Prodotti WHERE nome LIKE ?',
['%iz%'],
);

print('Risultato Raw SQL (Cerca "iz"): $queryRaw');

await db.close();
```

Dal momento che questa app potrebbe essere aggiornata in seguito, l'utilizzo di **sqflite** permette al programmatore di avere un approccio e una comprensione più immediata, utilizzando query che seguono il formato standard previsto. 

Siccome il database verrà utilizzato in più pagine e in più contesti (background e foreground) si è pensato di creare una classe **DatabaseService** che permetta di interfacciarsi con il database e gestire eventuali accessi concorrenti alla risorsa, in modo da evitare crash inattesi. 
Le principali funzioni che offre la classe sono:
- ***initialize()*** cerca il database nel percorso predefinito, se esiste.
- ***get database*** ritorna il database se è stato trovato, altrimenti lo crea sul momento definendo tutte le tabelle previste per le entità. 
- ***close()*** chiude il database una volta finito l'utilizzo. Non è prevista la chiusura automatica una volta terminato il blocco di codice. Si prevede infatti che al database possano essere fatte più chiamate e quindi debba essere il programmatore a decidere quando interrompere la connessione. È quindi buona norma, al termine delle operazioni con il database, invocare questo metodo. 
- ***savePreference(Preference preference)*** salva la preferenza all'interno del database gestendo tutte le operazioni.
- ***getPreferences()*** ritorna la lista di preferenze salvate nel database. 
- ***updatePreference(Preference preference)*** aggiorna la preferenza indicata aggiornando anche le entità correlate.
- ***saveResult(Result result)*** salva il risultato nel database.
- ***saveResults(List<Result> results)*** salva una lista di risultati nel database
- ***getResults()*** ritorna la lista di risultati dal database che possono essere ancora utili per l'utente. In questo caso vengono selezionati solo i TOLC che hanno data di scadenza per l'iscrizione uguale o superiore a quella di esecuzione del programma. 
- ***getUniversities()*** ritorna la lista di università già inserite. Tale lista può essere utile per i suggerimenti in fase di aggiunta o modifiche di preferenze per aiutare l'utente ed evitare ripetizioni di record all'interno del database. 

### Logger
Il logger viene utilizzato per salvare nell'applicazione eventuali warning, errori, o informazioni sullo stato di attività dell'applicazione.

Il log sfrutterà una rotazione periodica, dove verranno mantenuti solo i file più recenti, per evitare un riempimento eccessivo della memoria.

Per far sì che il logger venga utilizzato è stato creato il modulo **logger_utils.dart** basato sulla libreria **logger** disponibile su flutter. Tale modulo contiene l'istanziazione del logger per poter essere utilizzato nelle varie circostante. Il modulo presenta circa la seguente struttura:
```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

/* definizione della tipologia di output del logger.
In genere i messaggi vengono mostrati a schermo, 
mentre in questo caso ho aggiunto un file specifico. */
class FileOutput extends LogOutput {
  @override
  void output(OutputEvent event) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/app_logs.log');
    
    for (var line in event.lines) {
      await file.writeAsString('$line\n', mode: FileMode.append);
    }
  }
}

/* definizione dell'istanza del logger */
final logger = Logger(
  printer: PrettyPrinter(
    colors: true,
    printEmojis: true,
  ),
  output: MultiOutput(
    [
      ConsoleOutput(),
      FileOutput()
    ]
  )
);
```

### Notifiche
Le notifiche sono la funzione primaria del programma, in quanto sono il risultato del processo in background di ricerca. Le notifiche devono essere acconsentite dall'utente in fase di installazione, mediante appositi permessi. 

Dal momento che le notifiche sono molteplici, è stata creata una classe per definire il canale di comunicazione e il contenuto della notifica. 
La classe **NotificationsService** si basa quindi sulla libreria **flutter_local_notification** ed è costituita dai seguenti metodi:
- ***init()*** inizializzazione del canale di notifica, con impostazioni dedicate in particolare all'OS android.
- ***showNotification(String title, String body)*** mostra una notifica immediata con titolo e corpo della notifica. Se la notifica viene cliccata viene aperta l'app nella pagina principale, ossia quella dei risultati.
- ***scheduleNotification(String title, String body, DateTime scheduledTime)*** mostra una notifica con lo stesso formato di prima, soltanto che viene inserita una data e un'ora specifica nella quale la notifica dovrà apparire.

Perchè le notifiche funzionino su Android, è però necessario configurare i seguenti permessi:
```dart
final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    FlutterLocalNotificationsPlugin().
    resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

if (androidImplementation != null) {
    /* popup per richiesta approvazione 
    utilizzo di notifiche da parte dell'applicazione */
    await androidImplementation.requestNotificationsPermission();
}
```
Nel file `android/app/src/main/AndroidManifest.xml` assicurarsi di avere tra i permessi i seguenti indicati:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

Inoltre il file `android/app/src/main/kotlin/com/example/tolc_notifier/MainActivity.kt` deve avere i parametri del canale di notifica che devono corrispondere a quelli inseriti durante la sua creazione in dart, in particolare:
```kotlin
package com.example.tolc_notifier

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNELBATTERY = "com.example.tolc_notifier/battery"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        /* creo canale notifica per le versioni
        di android 8+ */
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            /* popolare le variabili con il nome del canale e gli attributi
            definiti su dart per le notifiche */
            val channelId = "channel_id"
            val channelName = "channel_name"
            val channelDescription = "Channel description"
            val importance = NotificationManager.IMPORTANCE_MAX
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
            }
            
            val notificationManager: NotificationManager =
                getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }

        /* configurazione per l'ottimizzazione della batteria */
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNELBATTERY)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestIgnoreBatteryOptimization" -> {
                        requestIgnoreBatteryOptimization()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestIgnoreBatteryOptimization() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val powerManager = getSystemService(POWER_SERVICE) as PowerManager
            val isIgnoringBatteryOptimizations = powerManager.isIgnoringBatteryOptimizations(packageName)
            
            if (!isIgnoringBatteryOptimizations) {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
            }
        }
    }
}
```

### Ricerca in background
Il servizio di ricerca in background è forse il task principale dell'applicazione, che la rende utile per l'utilizzatore. Il modulo **TOLC_finder.dart** si occupa quindi di effettuare lo scraping via html ricercando tutti i risultati di interesse e salvandoli nel database dopo aver inviato una notifica. 

I metodi utilizzabili dal programmatore relativi a questo modulo sono:
- ***TOLC_finder_main()*** funzione che esegue tutto i passaggi per leggere, valutare, salvare e notificare il risultato. Ritorna un booleano per indicare la corretta riuscita o meno del task. 

Tuttavia, affinché questa funzione venga eseguita periodicamente in background occorre configurarla su dart e aggiumgere i relativi permessi per Android, in modo tale che venga concesso anche un'utilizzo maggiore della batteria. 

```dart
/* funzione che viene eseguita periodicamente e che, in base al tipo di task, 
indica la quali istruzioni eseguire.
(nel nostro caso invoca la funzione per la ricerca dei TOLC) */
@pragma('vm:entry-point') // mandatory to make the code removable on the compilation phase
void callbackDispatcher(){
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized(); // background binding

    await initializeNotificationsAsync(); // initialize the notifications service

    switch (taskName) {
      /* case where to use the TOLC finder */
      case "TOLC_finder":
        logger.i("TOLC finder process started at ${DateTime.now()}"); // using loggers to write date and time of actions
        bool result = await TOLC_finder_main();
        logger.i("TOLC finder process ended at ${DateTime.now()} with result $result");
        break;
    }
    return Future.value(true); // Ritorna true se il task è riuscito
  });
}

Future<void> main() async{
  /* inizio del main... */

  /* inizializzazione del workmanager,
  libreria per eseguire i task in background su flutter */
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false // debug to send notification when the task is activated
  );
  /* configurazione del task periodico con nome univoco del task 
  e nome della funzionalità da eseguire, che deve corrispondere ad una
  dello switch case della funzione precedente */
  Workmanager().registerPeriodicTask(
    'TOLC_notifier_background', 
    'TOLC_finder',
    frequency: Duration(hours: backgroundTaskInterval),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace
  );

  /* resto del main... */
}
```
Sul file `android/app/src/main/AndroidManifest.xml` assicurarsi di avere i seguenti permessi:
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
<uses-permission android:name="android.permission.INTERNET" />
```