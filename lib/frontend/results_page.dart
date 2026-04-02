import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static DateTime _lastFetchTime = DateTime.now();

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
                      /* add the condition to become a new result */
                      children: _results.map((item) => ResultCard(item, 
                      newResult: item.notifyDate.compareTo(_lastFetchTime)>=0)
                      .create(context)).toList()
                    )
                  ],
                ),
        )        
      )
    );
  }

  void _loadData() async {
    /* get the data from the database */
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
    }
    
    /* get the last fetch time
    from the user on the application */
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final raw = sharedPreferences.getString('last_last_access') ?? '';
    setState(() {
      _lastFetchTime = raw.isNotEmpty ? DateTime.parse(raw) : DateTime.now();
    });
  }
}