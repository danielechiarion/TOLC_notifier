import 'package:flutter/material.dart';

/// Enumerator to define the different type
/// of toasts to appear in the application
enum ToastType{
  /* define different values of the enumerator */
  success(Colors.green),
  error(Colors.red),
  warning(Colors.amber),
  fatal(Colors.purple);

  /* define the variables for the enumerator */
  final Color color;

  /* define constructor for the enumerator */
  const ToastType(this.color);
}

/// Class to manage the app toast display
class AppToast{
  /* define attributes */
  final BuildContext context;
  final String message;
  final ToastType toastType;

  AppToast.show(this.context, this.message, this.toastType){
    /* get the scaffold messenger and remove 
    previous toast put in the page, if they exists */
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.removeCurrentSnackBar();

    /* show the snackbar */
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: toastType.color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3), // duration to set
      ),
    );
  }
}