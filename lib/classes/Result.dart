import 'University.dart';
import 'TOLCType.dart';

/// Class to represent the result of the research
/// made on the website
class Result{
  /* defining attributes */
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
  {DateTime ?notifyDate}) 
  : notifyDate = notifyDate ?? DateTime.now();

  /// hash method to compare two results
  @override
  int get hashCode => Object.hash(tolcType, university, site, assessmentDate);

  /// equals method to compare two results
  /// based on the previous hash method
  @override
  bool operator ==(Object other) {
    return other is Result && hashCode == other.hashCode;
  }

  /// method to convert a result into a map object
  /// to use it for SQL manipulation
  Map<String, dynamic> toMap() => {
    "tolcType":tolcType.index,
    "university":university.name,
    "site":site,
    "availablePlaces":availablePlaces,
    "endSubscription":endSubscription.toString(),
    "assessmentDate": assessmentDate.toString(),
    "mode":mode,
    "notifyDate": notifyDate.toString()
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
    notifyDate: DateTime.parse(map['notifyDate'])
  );
}