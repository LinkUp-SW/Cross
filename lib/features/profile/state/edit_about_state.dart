// lib/features/profile/state/edit_about_state.dart
import 'package:flutter/foundation.dart' show immutable;
import 'package:link_up/features/profile/model/about_model.dart'; // Import AboutModel

@immutable
sealed class EditAboutState {
  const EditAboutState();
}

class EditAboutInitial extends EditAboutState {
  const EditAboutInitial();
}

class EditAboutLoading extends EditAboutState {
  const EditAboutLoading();
}

// State holds the fetched about data
class EditAboutLoaded extends EditAboutState {
  final AboutModel aboutData; // Holds fetched about and skills
  final bool initialAboutExists; // Indicates if initial about data exists
  const EditAboutLoaded({
    required this.aboutData,
    required this.initialAboutExists,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditAboutLoaded &&
           other.aboutData == aboutData &&
           other.initialAboutExists == initialAboutExists; 
  }

  @override
  int get hashCode => aboutData.hashCode^ initialAboutExists.hashCode;
}

// State during the save operation
class EditAboutSaving extends EditAboutState {
   final String aboutTextToSave;
   final bool isCreating;
   const EditAboutSaving({
     required this.aboutTextToSave,
     required this.isCreating,
   });

   @override
   bool operator ==(Object other) {
     if (identical(this, other)) return true;
     return other is EditAboutSaving &&
            other.aboutTextToSave == aboutTextToSave &&
            other.isCreating == isCreating;
   }

   @override
   int get hashCode => aboutTextToSave.hashCode ^ isCreating.hashCode;
}

class EditAboutSuccess extends EditAboutState {
  const EditAboutSuccess();
}

class EditAboutError extends EditAboutState {
  final String message;
  final String? previousAboutText; // Store previous text to show in UI on error
  final bool? initialAboutExists;
  const EditAboutError(
    this.message, {
    this.previousAboutText,
    this.initialAboutExists,
  });

   @override
   bool operator ==(Object other) {
     if (identical(this, other)) return true;
     return other is EditAboutError &&
            other.message == message &&
            other.previousAboutText == previousAboutText &&
            other.initialAboutExists == initialAboutExists;
   }

   @override
   int get hashCode => message.hashCode ^ previousAboutText.hashCode ^ initialAboutExists.hashCode;
}
