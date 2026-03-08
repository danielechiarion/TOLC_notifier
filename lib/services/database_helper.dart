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

    return await openDatabase(path, version: 1, onCreate: _defineTables);
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
      CREATE TABLE IF NOT EXISTS Preference-University(
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
        mode TEXT
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
  Future<bool> save_preference(Preference preference) async{
    int preferenceID = 0;
    
    try{
      /* first save the preference object into the database */
      preferenceID = await _database!.insert(
        'Preference',
        preference.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }catch(e){
      throw Exception('Error saving preference: $e');
    }

    try{
      /* update all the existing connections to the database
      using a transaction to avoid unconsistency. 
      Making different queries can cause problems if the app crash
      in the middle of the two queries, making it impossible to resume */
      await _database!.transaction((txn) async {
        /* first delete all the connections to the preference */
        await txn.delete('Preference-University', where: 'preference=?', 
        whereArgs: [preferenceID]);

        /* then save all the updated connections to the database */
        for(University currentUniversity in preference.universities){
          await txn.insert('Preference-University', {
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
}