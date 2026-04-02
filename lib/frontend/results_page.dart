import 'package:flutter/material.dart';

import '../services/database_helper.dart';
import '../services/logger_utils.dart';
import '../classes/Result.dart';
import '../frontend/single_elements/ResultCard.dart';

class ResultsPage extends StatefulWidget{
  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with WidgetsBindingObserver{
  static List<Result> _results = [];

  /* private method to init the page with the necessary data
  and get them from the database */
  @override
  void initState(){
    super.initState();
    _loadData(); // load the data from the database
    WidgetsBinding.instance.addObserver(this); // add observer to listen to app lifecycle changes
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData(); // reload data when the app is resumed
    }
  }

  /* Method to create the elements that are necessary
    to make the result page. 
    In this case it will be a list of the appointments found */
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("I tuoi risultati",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                    ),
                    centerTitle: true,
                  ),
      body: SingleChildScrollView(
        child:Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
                  children: [
                    Column(
                      children: _results.map((item) => ResultCard(item).create(context)).toList()
                    )
                  ],
                ),
        )        
      )
    );
  }

  void _loadData() async {
    final DatabaseService database = DatabaseService.instance;
    try {
      await database.initialize();
      List<Result> output = await database.getResults();
      setState(() {
          _results = output;
      });
    } catch (e) {
      setState(() {
        _results = [];
      });
      logger.e("Error while fetching results from the databae: {$e}");
    } finally {
      await database.close();
    }
  }
}