import 'package:flutter/services.dart';

/// Class to format the input of a TextField
/// to only allow numerical values within a specified range
class NumericalRangeFormatter extends TextInputFormatter{
  /* define attributes */
  int min;
  int max;

  /// Constructor for the NumericalRangeFormatter
  /// having minum and maximum values
  NumericalRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue){
    /* if the value is empty, return it allowing
    to reset the input */
    if(newValue.text.isEmpty){
      return newValue;
    }

    /* then try the conversion and 
    establish if it's proper to range given */
    int ?value = int.tryParse(newValue.text);

    /* if the value is null return the old value */
    if(value == null){
      return oldValue;
    }

    /* if the value is outside the range, return
    either the maximum or the minimum */
    if(value < min){
      return TextEditingValue(text: min.toString());
    }
    if(value > max){
      return TextEditingValue(text: max.toString());
    }
    return newValue; // otherwise, return the new value
  }
}