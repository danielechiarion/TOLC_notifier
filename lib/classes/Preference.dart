import 'TOLCType.dart';
import 'University.dart';

/// Class to define the preference for the application
/// to search on the website
class Preference {
  /* define attributes */
  int ID;
  TOLCType tolcType;
  bool TOLCcasa;
  bool TOLCuni;
  Set<University> _universities;

  /// Constructor for the preference
  Preference(this.tolcType, this.TOLCcasa, this.TOLCuni, {int ?ID, Set<University>? universities}) 
  : ID = ID ?? -1, _universities = universities ?? {};

  /// define hash method
  @override
  int get hashCode => tolcType.hashCode ^ TOLCcasa.hashCode ^ tolcType.hashCode;

  /// equals for the class preference
  /// using the hashCode to compare them
  bool operator ==(Object other){
    return other is Preference && hashCode == other.hashCode;
  }

  /// method to converted a Preference to 
  /// a map object to use SQL
  Map<String, dynamic> toMap() => {
    "tolcType":tolcType.index,
    "tolcCasa":TOLCcasa ? 1 : 0, // conver boolean into integer for SQL
    "tolcUni":TOLCuni ? 1 : 0
  };

  /// method to convert mapped object
  /// into the Preference
  factory Preference.fromMap(Map<String, dynamic> map) => Preference(
    TOLCType.values[map['tolcType']],
    map['tolcCasa'] == 1, // convert integer into boolean after SQL extraction
    map['tolcUni'] == 1,
    ID: map['ID']
  );

  /// method to add a university to the list of universities
  /// in the preference
  void addUniversity(University university){
    _universities.add(university); // using set to avoid duplicates
  }

  /// method to remove a university from the list
  void removeUniversity(University university){
    _universities.remove(university);
  }

  /// alternative method to remove from the university
  /// using an index 
  void removeUniversitbyIndex(int index){
    _universities.toList().removeAt(index);
  }

  /// method to get a clone of the list of universities
  /// so as to avoid possibile changes on the original list 
  /// without the recommended methods
  Set<University> get universities => Set<University>.from(_universities);

  /// Method to control if a university is inside the list using
  /// the name or part of it
  bool isThereUniverisity(University university){
    return _universities.any((singleUniversity) => university.name.toLowerCase().contains(singleUniversity.name.toLowerCase()));
  }
}