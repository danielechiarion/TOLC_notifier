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
  Preference(this.tolcType, this.TOLCcasa, this.TOLCuni, {int ?ID}) 
  : ID = ID ?? -1, _universities = {};

  /// define hash method
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
    "TOLCcasa":TOLCcasa ? 1 : 0, // conver boolean into integer for SQL
    "TOLCuni":TOLCuni ? 1 : 0
  };

  /// method to convert mapped object
  /// into the Preference
  factory Preference.fromMap(Map<String, dynamic> map) => Preference(
    map['tolcType'],
    map['TOLCcasa'] == 1, // convert integer into boolean after SQL extraction
    map['TOLCuni'] == 1,
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

  /// method to get a clone of the list of universities
  /// so as to avoid possibile changes on the original list 
  /// without the recommended methods
  Set<University> get universities => Set<University>.from(_universities);
}