import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../classes/Preference.dart';
import '../classes/Result.dart';
import '../classes/University.dart';

/// Class for the definition of a SQL database, 
/// with the necessary methods to manage it even for the most simple and frequent 
/// operations inside the app
class DatabaseService{
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  /// Default constructor
  DatabaseService._init();

  /* !----------------------------------------------------------!
    Definition of the database and of the methods connected to its 
    instantiation, creation, definition and closing. 
    !----------------------------------------------------------!
   */

  /// Method to get the database and, if it doesn't exists,
  /// create it with
  Future<Database> get database async{
    /* if the device is not null
    return it immediately */
    if(_database != null) 
      return _database!; //this syntax means that the value is not null for sure

    /* otherwise, init it and
    return it to the user */
    _database = await _initDatabase('app_data.db');
    return _database!;
  }

  /* function to init the on the specified file path given */
  Future<Database> _initDatabase(String filePath) async{
    /* find the path of the database file and associate it
    with the file path given */
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _defineTables,
      /* to activate the foreign keys */
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      }
    );
  }

  /// Public method to init the database,
  /// without telling the path in which it will be saved
  Future<void> initialize() async{
    /* if the device is not null
    return it immediately */
    if(_database != null) 
      return;

    /* otherwise, init it and
    return it to the user */
    _database = await _initDatabase('app_data.db');
  }

  /* function to define the database tables with all their structure */
  Future<void> _defineTables(Database db, int version) async {
    /* create table of the university */
    await db.execute('''
      CREATE TABLE IF NOT EXISTS University(
        name TEXT PRIMARY KEY
      )
    ''' );

    /* create table for the preference expressed */
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Preference(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tolcType INTEGER,
        tolcCasa INTEGER,
        tolcUni INTEGER
      )
    ''');

    /* table to store the university corresponded to
    each preference given by the user */
    /* the table use references to the primary keys of the other tables
    so as to delete this values in case of deletion of the connected records */
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS Preference_University(
        preference INTEGER,
        university TEXT,

        PRIMARY KEY (preference, university),
        FOREIGN KEY (preference) REFERENCES Preference(id) ON DELETE CASCADE,
        FOREIGN KEY (university) REFERENCES University(name) ON DELETE CASCADE
      )
      '''
    );

    /* create table of the results given by the background research */
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Result(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tolcType INTEGER,
        university TEXT,
        site TEXT,
        availablePlaces INTEGER,
        endSubscription TEXT,
        assessmentDate TEXT,
        notifyDate TEXT,
        mode TEXT,

        UNIQUE(tolcType, university, site, assessmentDate)
      )
    ''');
  }

  /// Close the database if it's open (used when app/background tasks finish).
  Future<void> close() async {
    if (_database != null) {
      try {
        if (_database!.isOpen) {
          await _database!.close();
        }
      } finally {
        _database = null;
      }
    }
  }


  /* !----------------------------------------------------------!
    Methods connected to the specific operations performed
    by the application, which supports the CRUD operations 
    and allows to manage the data easily without SQL queries
    outside this class. 

    This methods are not mandatory for the functioning of the database,
    but could be useful during the tasks performed by the app. 
    !----------------------------------------------------------!
   */
  /// Method to save a Preference into the database, with all
  /// the necessary connections to the associated tables
  Future<bool> savePreference(Preference preference) async{
    int preferenceID = -1;
    
    try{
      /* first save the preference object into the database */
      preferenceID = await _database!.insert(
        'Preference',
        preference.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }catch(e){
      throw Exception('Error saving preference: $e');
    }

    if(preferenceID<0)
      return false;

    try{
      /* then save the univerisities into the specified table.
      In this case there is no use to delete them or save them
      in another function, because they walk along with the preferences*/
      for(University currentUniversity in preference.universities){
        await _database!.insert(
          'University', 
          currentUniversity.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      /* update all the existing connections to the database
      using a transaction to avoid unconsistency. 
      Making different queries can cause problems if the app crash
      in the middle of the two queries, making it impossible to resume */
      await _database!.transaction((txn) async {
        /* first delete all the connections to the preference */
        await txn.delete('Preference_University', where: 'preference=?', 
        whereArgs: [preferenceID]);

        /* then save all the updated connections to the database */
        for(University currentUniversity in preference.universities){
          await txn.insert('Preference_University', {
            'preference':preferenceID,
            'university':currentUniversity.name
          });
        }
      });
    }catch(e){
      throw Exception('Error saving preference-university connections: $e');
    }
    
    return true;
  }

  /// Method to get the preferences saved into the database, 
  /// related to the universities and all the connections between them.
  /// The search is made with the ID of the preference,
  /// to increase the performance of the algorithm.
  Future<List<Preference>> getPreferences() async{
    Map<int, Preference> mapPreferences = {}; // use the map to research by ID

    /* make the request to get the preferences
    from the database */
    List<Map<String, dynamic>> result = [];
    try{
      result = await _database!.rawQuery(
        '''
        SELECT p.id, p.tolcType, p.tolcCasa, p.tolcUni, pu.university
        FROM Preference p LEFT JOIN Preference_University pu
        ON p.id = pu.preference
        '''
      );
    }catch(e){
      throw Exception('Error fetching preferences: $e');
    }

    for(Map<String, dynamic> row in result){
      /* get the ID and add the preference if absent */
      int id = row['id']; 
      mapPreferences.putIfAbsent(id, () => Preference.fromMap({...row, 'ID': id}));

      /* add the universities to the preference only if present */
      if(row['university'] != null){
        mapPreferences[id]!.addUniversity(University(row['university']));
      }
    }

    return mapPreferences.values.toList();
  }

  /// Method to delete a preference from the database,
  /// with all the necessary connections deleted, as well.
  Future<bool> deletePreference(Preference preference) async{
    try{
      /* delete the preference from the database, with all the connections
      to the other tables, thanks to the cascade delete */
      _database!.delete('Preference', where: 'id=?', whereArgs: [preference.ID]);
    }catch(e){
      throw Exception('Error deleting preference: $e');
    }

    return true;
  }

  /// Method to update a preference into the database, 
  /// with overriding all the previous connections to the other
  /// tables and the old values, as well
  Future<bool> updatePreference(Preference preference) async{
    int preferenceID = -1;
    try{
      /* update the preference into the database, with all the connections
      to the other tables, thanks to the cascade delete */
      preferenceID = await _database!.update('Preference', preference.toMap(), where: 'id=?', whereArgs: [preference.ID]);
    }catch(e)
    {
      throw Exception('Error updating preference: $e');
    }

    try{
      /* update all the existing connections to the database
      using a transaction to avoid unconsistency. 
      Making different queries can cause problems if the app crash
      in the middle of the two queries, making it impossible to resume */
      await _database!.transaction((txn) async {
        /* first delete all the connections to the preference */
        await txn.delete('Preference_University', where: 'preference=?', 
        whereArgs: [preference.ID]);

        /* then save all the updated connections to the database */
        for(University currentUniversity in preference.universities){
          await txn.insert('University', {
            'name': currentUniversity.name
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await txn.insert('Preference_University', {
            'preference':preference.ID,
            'university':currentUniversity.name
          });
        }
      });
    }catch(e){
      throw Exception('Error saving preference-university connections: $e');
    }

    /* update the new ID of the preference if 
    it is possible */
    if(preferenceID >=0){
      preference.ID = preferenceID;
    }

    return true;
  }

  /// Method to save a result into the database, with 
  /// all the foreign keys of the other entities. 
  /// According to the design of the app, 
  /// the table of the result doesn't need to be connected to the
  /// other tables of the database. 
  Future<bool> saveResult(Result result) async{
    try{
      /* save the result into the database */
      await _database!.insert(
        'Result',
        result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }catch(e){
      throw Exception('Error saving result: $e');
    }

    return true;
  }

  /// Method to get the result saved into the database
  /// ordered by the date of the notification
  Future<List<Result>> getResults() async{
    /* define lists to use during SQL handling */
    List<Map<String, dynamic>> result = [];
    List<Result> output = [];

    try{
      /* select all the results looking at the date of the notification
      and order them by this date, from the most recent to the oldest one */
      result = await _database!.rawQuery(
        '''
          SELECT ID, tolcType, university, site, availablePlaces, endSubscription, assessmentDate, notifyDate, mode
          FROM Result WHERE endSubscription >= ?
          ORDER BY notifyDate DESC
        ''',
        [DateTime.now().toIso8601String()]
      );
    }catch(e){
      throw Exception('Error fetching results: $e');
    }

    /* now parse all the elements and 
    convert them into a Result object */
    for(Map<String, dynamic> row in result){
      output.add(Result.fromMap(row));
    }

    return output;
  }

  /// Function to get the universities
  /// from the database
  Future<List<University>> getUniversities() async{
    /* define the list of variables */
    List<Map<String, dynamic>> results = [];
    List<University> output = [];

    /* get the results from the database */
    results = await _database!.query('University', columns: ['name']);
    /* convert the result into a list of objects */
    for(Map<String,dynamic> row in results){
      output.add(University.fromMap(row));
    }

    return output;
  }
}