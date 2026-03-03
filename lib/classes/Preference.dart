import 'TOLCType.dart';

/// Class to define the preference for the application
/// to search on the website
class Preference {
  /* define attributes */
  TOLCType tolcType;
  bool TOLCcasa;
  bool TOLCuni;

  /// Constructor for the preference
  Preference(this.tolcType, this.TOLCcasa, this.TOLCuni);

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
    "TOLCcasa":TOLCcasa,
    "TOLCuni":TOLCuni
  };

  /// method to convert mapped object
  /// into the Preference
  factory Preference.fromMap(Map<String, dynamic> map) => Preference(
    map['tolcType'],
    map['TOLCcasa'],
    map['TOLCuni'],
  );
}