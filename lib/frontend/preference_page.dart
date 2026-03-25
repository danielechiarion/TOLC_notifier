import 'package:flutter/material.dart';

import '../classes/Preference.dart';
import '../classes/University.dart';
import '../services/database_helper.dart';
import '../services/logger_utils.dart';
import 'single_elements/PreferenceCard.dart';
import 'single_elements/Toast.dart';
import 'new-preference_section.dart';

/// Class to present the list of preferences 
/// and give them to possibilty to be changed,
/// added, or eliminated
class PreferencePage extends StatefulWidget{

  /// Define constructor for the preference page
  const PreferencePage({super.key}); 

  @override
  State<PreferencePage> createState() => _PreferencePageState();
}

/* class to handle changes in the 
preference list */
class _PreferencePageState extends State<PreferencePage>{
  // Use List instead of Set: Set deduplicates based on hashCode/==,
  // so if Preference doesn't override them, all items collapse to one.
  List<Preference> _preferenceList = [];
  Set<University> _universityList = {};

  /// Function to init the preference page
  /// and the state with the initial data
  @override
  void initState(){
    super.initState();
    _loadData();
  }

  /// Load preference and university data asynchronously.
  /// NOTE: only called on first load — NOT on every card update,
  /// to avoid destroying card state (editing mode, local changes).
  Future<void> _loadData() async {
    final DatabaseService database = DatabaseService.instance;

    try {
      await database.initialize();
      final preferences = await database.getPreferences();
      final universities = await database.getUniversities();
      
      setState(() {
        _preferenceList = List.from(preferences); // List preserves all items
        _universityList = Set.from(universities);
      });
    } catch (e) {
      logger.e("Error while fetching results from the database: {$e}");
    } finally {
      await database.close();
    }
  }
  
  /// Function to return the widget expected 
  /// with the possibility to add new preferences
  @override
  Widget build(BuildContext context){
    return Scaffold(
      /* list of the existing preferences */
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Le tue preferenze",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Column(
                children: _preferenceList.map((item) => PreferenceCard(
                  // ValueKey ensures Flutter reuses the correct card state
                  // when the list changes, instead of reassigning states by position.
                  key: ValueKey(item.ID),
                  deleteFunction: _deletePreference, 
                  // onUpdate no longer reloads all data from DB — the card
                  // manages its own local state. This callback is kept for
                  // future use (e.g. showing a snackbar from the parent).
                  onUpdate: () {},
                  preference: item, 
                  universities: _universityList,
                )).toList(),
              )
            ],
          ),
        )
      ),

      /* button to add an element
      and return from the section the result */
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Aggiungi preferenza"),
        backgroundColor: Colors.greenAccent,
        onPressed: _addPreference,
      ),
    );
  }

  /* function to pass to the Preference Card in order to 
  destroy itself and update the page */
  Future<void> _deletePreference(Preference preference) async {
    /* initialization of the database */
    DatabaseService database = DatabaseService.instance;

    try{
      await database.initialize();
      if(!await database.deletePreference(preference)){
        logger.w("Could not delete the preference from the database");
      }
    }catch(e){
      logger.e("Error while trying to delete a preference: $e");
    }finally{
      await database.close();
    }

    /* delete the preference from the list so as to update the page */
    await _loadData();
  }

  /* function to add a new preference or manage
  the canceled action and display the result
  with the toast */
  Future<void> _addPreference() async{
    /* get the preference from the section */
    Preference? preference = await Navigator.push(context, 
                                MaterialPageRoute(builder: (context) => NewPreferenceSection(universities: _universityList)));

    /* get the value and understand if 
    it's possible to proceed or not */
    if(preference == null){
      AppToast.show(context, "Creazione preferenza annullata", ToastType.success);
      return;
    }

    /* instantiate database and save the preference */
    DatabaseService database = DatabaseService.instance;

    try{
      await database.initialize();
      if(!await database.savePreference(preference)){
        logger.w("Could not save the preference into the database");
        AppToast.show(context, "Non è stato possibile eliminare la preferenza dal database", ToastType.warning);
      }
    }catch(e){
      logger.e("Error while trying to save a preference: $e");
      AppToast.show(context, "Errore durante il salvataggio preferenza nel DB: $e", ToastType.error);
    }finally{
      await database.close();
    }

    /* add preference to the list */
    await _loadData(); // reload the data from the database
    AppToast.show(context, "Preferenza aggiunta nell'app", ToastType.success);
  }
}