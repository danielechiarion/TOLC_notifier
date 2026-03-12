import 'package:flutter/material.dart';

import '../services/database_helper.dart';
import '../services/logger_utils.dart';
import '../classes/Result.dart';
import '../frontend/single_elements/ResultCard.dart';

class ResultsPage {
  static List<Result> _results = [];

  /* private method to init the page with the necessary data
  and get them from the database */
  static Future<void> init() async{
    final DatabaseService database = DatabaseService.instance;
    await database.initialize();

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
  static Widget create(BuildContext context){
    return SingleChildScrollView(
      child:Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("I tuoi risultati",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary, // Colore coerente col brand
                  ),
                )
              ],
            ),
            const SizedBox(height: 24,),
            Column(
              children: _results.map((item) => ResultCard(item).create(context)).toList()
            )
          ],
        ),
      )
    );
  }
}