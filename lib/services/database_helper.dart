import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Class for the definition of a SQL database, 
/// with the necessary methods to manage it even for the most simple and frequent 
/// operations inside the app
class DatabaseService{
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  /// Default constructor
  DatabaseService._init();

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
}