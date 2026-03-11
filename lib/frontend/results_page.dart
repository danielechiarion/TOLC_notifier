import 'package:flutter/material.dart';

import '../services/database_helper.dart';
import '../services/logger_utils.dart';
import '../classes/Result.dart';

class ResultsPage {
  static late final List<Result> _results;

  /* private method to init the page with the necessary data
  and get them from the database */
  static Future<void> _init() async{
    final DatabaseService database = DatabaseService.instance;
    await database.initialize();

    List<Result> results;
    try {
      _results = await database.getResults();
    } catch (e) {
      _results = [];
      logger.e(e);
    } finally {
      await database.close();
    }
  }

  /// Method to create the elements that are necessary
  /// to make the result page. 
  /// In this case it will be a list of the appointments found
  static Widget create(){
    return SingleChildScrollView(
      child:ListTile()
    );
  }
}