import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class to manage settings
/// and change them during the execution of the application
class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool searchEnabled = true;
  bool notifyEnabled = true;

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
              activeTrackColor: Colors.limeAccent,
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
              activeTrackColor: Colors.limeAccent,
              value: notifyEnabled,
              onChanged: (value) {
                setState(() {
                  notifyEnabled = value;
                });
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}