import 'package:flutter/material.dart';

import '../classes/Preference.dart';
import '../classes/University.dart';
import '../services/database_helper.dart';
import '../services/logger_utils.dart';
import 'single_elements/PreferenceCard.dart';

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
  late Set<Preference> _preferenceList; // create local list for the preference one
  late Set<University> _universityList; // create local list for the university

  /// Fuction to init the preference page
  /// and the state with the initial data
  @override
  Future<void> initState() async{
    super.initState();
    final DatabaseService database = DatabaseService.instance;

    try {
      await database.initialize();
      setState(() async {
        _preferenceList = Set.from(await database.getResults());
        _universityList = Set.from(await database.getUniversities());
      });
    } catch (e) {
      logger.e("Error while fetching results from the databae: {$e}");
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
        child:Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Le tue preferenze",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary, // Colore coerente col brand
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24,),
              /* in this case the method build of the private class of the 
              PreferenceCardState is already linked to the PreferenceCard,
              so just need to invoke the constructor to make the widget appear */
              Column(
                children: _preferenceList.map((item) => PreferenceCard(deleteFunction: _deletePreference, preference: item, universities: _universityList,)).toList(),
              )
            ],
          ),
        )
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
      if(await database.deletePreference(preference)){
        logger.w("Could not delete the preference from the database");
      }
    }catch(e){
      logger.e("Error while trying to delete a preference: $e");
    }finally{
      await database.close(); // try every time to close the connection
    }
  }
}