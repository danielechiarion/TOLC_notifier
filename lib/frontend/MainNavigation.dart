import 'package:flutter/material.dart';

import 'results_page.dart';
import 'preference_page.dart';
import 'settings_page.dart';

/// Flutter code for navigation for App
class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NavigationExample());
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
    bool _initialized = false;

    @override
    void initState() {
      super.initState();
      _init();
    }

    Future<void> _init() async {
      await ResultsPage.init();
      setState(() {
        _initialized = true;
      });
    }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

      /* wait until results are loaded */
      if (!_initialized) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.find_in_page_sharp),
            icon: Icon(Icons.find_in_page_outlined),
            label: 'Preferenze',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings_sharp),
            icon: Icon(Icons.settings_outlined),
            label: 'Impostazioni',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        ResultsPage.create(context),

        /// Preference page
        PreferencePage(),

        /// Settings page
        SettingsPage()
      ][currentPageIndex],
    );
  }
}