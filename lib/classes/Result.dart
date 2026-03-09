import 'University.dart';
import 'TOLCType.dart';

/// Class to represent the result of the research
/// made on the website
class Result{
  /* defining attributes */
  int ID;
  TOLCType tolcType;
  University university;
  String site;
  int availablePlaces;
  DateTime endSubscription;
  DateTime assessmentDate;
  DateTime notifyDate;
  String mode;

  /// Constructor of the result
  Result(this.tolcType, this.university, this.site, this.availablePlaces, 
  this.endSubscription, this.assessmentDate, this.mode, 
  {DateTime ?notifyDate, int ?ID}) 
  : notifyDate = notifyDate ?? DateTime.now(), ID = ID ?? -1;

  /// hash method to compare two results
  @override
  int get hashCode => Object.hash(tolcType, university, site, assessmentDate);

  /// equals method to compare two results
  /// based on the previous hash method
  @override
  bool operator ==(Object other) {
    return other is Result && hashCode == other.hashCode;
  }

  /// Method use to compare the result to 
  /// another one by the date when the system has noticed
  int compareTo(Result other) => notifyDate.compareTo(other.notifyDate);

  /// method to convert a result into a map object
  /// to use it for SQL manipulation
  Map<String, dynamic> toMap() => {
    "tolcType":tolcType.index,
    "university":university.name,
    "site":site,
    "availablePlaces":availablePlaces,
    "endSubscription":endSubscription.toIso8601String(),
    "assessmentDate": assessmentDate.toIso8601String(),
    "mode":mode,
    "notifyDate": notifyDate.toIso8601String()
  };

  /// method to convert a mapped object into a result
  /// in order to use it into the program from a SQL query
  factory Result.fromMap(Map<String, dynamic> map) => Result(
    TOLCType.values[map['tolcType']],
    University(map['university']),
    map['site'],
    map['availablePlaces'],
    DateTime.parse(map['endSubscription']),
    DateTime.parse(map['assessmentDate']),
    map['mode'],
    notifyDate: DateTime.parse(map['notifyDate']),
    ID: map['ID']
  );
}