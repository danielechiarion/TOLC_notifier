import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importante
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/TOLC_finder.dart';
import 'services/logger_utils.dart';

import 'frontend/MainNavigation.dart';

/// Periodic function to be executed
/// with the different functionalities
/// to be activated in background
@pragma('vm:entry-point') // mandatory to make the code removable on the compilation phase
void callbackDispatcher(){
  Workmanager().executeTask((taskName, inputData) async {
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

/// Function to save the last access
/// date and time in the shared preferences,
/// to be used for the results
Future<void> saveLastAccess() async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance(); // get the local storage

  sharedPreferences.setString('last_last_access', sharedPreferences.getString('last_access') ?? ''); // move the last access to the last last
  sharedPreferences.setString('last_access', DateTime.now().toIso8601String()); // then update the last access with current date and time
}

/// Functions to request permissions
/// to make the app work with all the tools available
Future<void> requestPermissions() async {
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      FlutterLocalNotificationsPlugin().
      resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  if (androidImplementation != null) {
    /* ask for notification approve */
    await androidImplementation.requestNotificationsPermission();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ensure that the binding is initialized before running the app
  /* Initialize sqflite for desktop (Windows/Linux/macOS) */
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  /* get the shared preferences
  date and get the interval from the period tasks */
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  int backgroundTaskInterval = localStorage.getInt('background_task_interval') ?? 5; 
  backgroundTaskInterval = backgroundTaskInterval == 0 ? 5 : backgroundTaskInterval; // make sure that the interval is not 0

  /* initialize workmanager and set in production.
  Debug mode sends you a notification if the task
  has been activated */
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false // debug to send notification when the task is activated
  );
  /* set how often the workmanager has to be activated.
  The starting configuration will repeat the background task
  every 5 HOURS with the use of INTERNET CONNECTION, which is
  necessary to perform the scraping of the webpages for the TOLC */
  Workmanager().registerPeriodicTask(
    'TOLC_notifier_background', 
    'TOLC_finder',
    frequency: Duration(hours: backgroundTaskInterval),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace
  );
  /* add also one-off task to do at the beginning */
  Workmanager().registerOneOffTask(
    'TOLC_notifier_start',
    'TOLC_finder',
    constraints: Constraints(networkType: NetworkType.connected),
    initialDelay: Duration(minutes: 15) // put an initial delay 
  );

  /* add functions before the start
  of the application */
  await requestPermissions(); // request priviledges for notifications
  await saveLastAccess(); // save the last access date and time

  runApp(const MainNavigation());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  /// Method to init the state of the application
  /// and do operations for the execution of the page
  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}