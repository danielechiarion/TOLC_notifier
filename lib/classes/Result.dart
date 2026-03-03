import 'Preference.dart';

/// Class to represent the result of the research
/// made on the website
class Result{
  /* defining attributes */
  Preference preference;
  int availablePlaces;
  DateTime endSubscription;
  DateTime assessmentDate;
  DateTime notifyDate;
  String mode;

  /// Constructor of the result
  Result(this.preference, this.availablePlaces, this.endSubscription, this.assessmentDate, this.mode, {DateTime ?notifyDate}) : notifyDate = notifyDate ?? DateTime.now();
}