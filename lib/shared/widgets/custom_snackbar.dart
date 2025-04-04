import 'package:flutter/material.dart';
import 'package:link_up/core/utils/global_keys.dart';


openSnackbar({required Widget child,
    Function? onPressed, String? label}) {
  final context = navigatorKey.currentContext!;
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
