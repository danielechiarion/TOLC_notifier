import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../utility/NumericalRangeFormatter.dart';

/// Class to manage settings
/// and change them during the execution of the application
class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool searchEnabled = true;
  bool notifyEnabled = true;
  int backgroundTaskInterval = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      searchEnabled = localStorage.getBool('search_enabled') ?? true;
      notifyEnabled = localStorage.getBool('notify_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    await localStorage.setBool('search_enabled', searchEnabled);
    await localStorage.setBool('notify_enabled', notifyEnabled);
    await localStorage.setInt('background_task_interval', backgroundTaskInterval);
  }

  /* function to update the background task 
  erasing the old one and creating a new one */
  void _updateBackgroundTask() async{
    /* erase the previous task */
    await Workmanager().cancelByUniqueName('TOLC_notifier_background');
    /* create the new task */
    Workmanager().registerPeriodicTask(
      'TOLC_notifier_background', 
      'TOLC_finder',
      frequency: Duration(hours: 5), // time for testing, to be changed
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace // force the replacement
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Impostazioni",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                    ),
                    centerTitle: true,
                    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Abilita ricerca"),
              activeTrackColor: Colors.purple,
              value: searchEnabled,
              onChanged: (value) {
                setState(() {
                  searchEnabled = value;
                });
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: const Text("Abilita notifiche"),
              activeTrackColor: Colors.purple,
              value: notifyEnabled,
              onChanged: (value) {
                setState(() {
                  notifyEnabled = value;
                });
                _saveSettings();
              },
            ),
            ListTile(
              title: const Text("Intervallo di ricerca (ore)"),
              /* the widget to the right */
              trailing: SizedBox(
                width: 70, // fixed width to contain the input
                child: TextFormField(
                  initialValue: backgroundTaskInterval.toString(), 
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end, // align number to the right
                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none, // remove number bottom border
                    hintText: "0",
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    NumericalRangeFormatter(min: 1, max: 72), // custom formatter
                  ],
                  onChanged: (value) {
                    setState(() {
                      /* convert and save the value */
                      int? numericValue = int.tryParse(value);
                      if (numericValue != null) {
                        backgroundTaskInterval = numericValue;
                      }
                    });
                    _saveSettings(); // call the save method
                    _updateBackgroundTask();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}