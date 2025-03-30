import 'package:flutter/material.dart';


openSnackbar(BuildContext context,{required Widget child,
    Function? onPressed, String? label}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: child,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(minutes: 1),
      backgroundColor: Theme.of(context).colorScheme.primary,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: onPressed != null && label != null
          ? SnackBarAction(
              label: label,
              onPressed: () => onPressed(),
              textColor: Theme.of(context).colorScheme.secondary)
          : null,
      elevation: 15,
    ),
  );
}
