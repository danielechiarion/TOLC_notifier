import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class to manange settings 
/// and change them during the execution of the application
class SettingsPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    

    return Scaffold();
  }

  /* function to control the existance of 
  eventual variables on storage and assign them default values */
  static void checkLocalVariables() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance(); // get the shared preference
    /* check if variables for enabling or disabling
    actions are set, or create it setting them by default */
    if(localStorage.get('search_enabled') == null){
      localStorage.setBool('search_enabled', true);
    } 
    if(localStorage.get('notify_enabled') == null){
      localStorage.setBool('notify_enabled', true);
    }
  }
}