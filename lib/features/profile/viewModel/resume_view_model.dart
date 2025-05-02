// profile/viewModel/resume_view_model.dart
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/add_resume_state.dart';
import 'package:link_up/features/profile/viewModel/add_section_view_model.dart'; // Import to refresh AddSection state

class ResumeViewModel extends StateNotifier<ResumeState> {
  final Ref _ref;
  final ProfileService _profileService;
  final String _userId = InternalEndPoints.userId;

  ResumeViewModel(this._ref, this._profileService) : super(const ResumeInitial()) {
    // Fetch initial status when the ViewModel is created
    fetchResumeStatus();
  }

  /// Check if the user has an existing resume and update state.
  Future<void> fetchResumeStatus() async {
    if (_userId.isEmpty) {
      state = const ResumeError("User not logged in.");
      return;
    }
    // Don't refetch if already present or loading
    if (state is ResumePresent || state is ResumeLoading) return;

    log("ResumeViewModel: Fetching resume status...");
    state = const ResumeLoading();
    try {
      final resumeUrl = await _profileService.getCurrentResumeUrl(_userId);
      if (!mounted) return; // Check if ViewModel is still mounted

      if (resumeUrl != null && resumeUrl.isNotEmpty) {
        final fileName = Uri.parse(resumeUrl).pathSegments.last; // Basic filename extraction
        state = ResumePresent(resumeUrl, fileName: fileName);
        log("ResumeViewModel: Resume present. URL: $resumeUrl");
      } else {
        state = const ResumeNotPresent();
        log("ResumeViewModel: Resume not present.");
      }
    } catch (e) {
      log("ResumeViewModel: Error fetching resume status: $e");
      if (mounted) {
        state = ResumeError("Failed to check resume status: ${e.toString()}");
      }
    }
     // Refresh the AddSectionViewModel state after checking
     _ref.read(addSectionViewModelProvider.notifier).refreshStatus();
  }

  /// Pick a PDF file using the file picker.
  Future<void> pickResumeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Only allow PDF files
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        // Optional: Check file size (e.g., < 2MB)
        int fileSize = await file.length();
        if (fileSize > 2 * 1024 * 1024) { // 2MB limit
             if (mounted) state = const ResumeError("File size exceeds 2MB limit.");
             return;
        }

        if (mounted) {
           log("ResumeViewModel: File selected: ${file.path}");
           state = ResumeFileSelected(file);
        }
      } else {
        // User canceled the picker
        log("ResumeViewModel: File selection cancelled.");
        // Revert to previous non-selection state if needed
        if (state is ResumeFileSelected) {
            fetchResumeStatus(); // Or revert based on previous state logic
        }
      }
    } catch (e) {
      log("ResumeViewModel: Error picking file: $e");
      if (mounted) {
        state = ResumeError("Failed to pick file: ${e.toString()}");
      }
    }
  }

  /// Upload the selected resume file.
  Future<void> uploadResume(File file) async {
     if (_userId.isEmpty) {
       state = const ResumeError("User not logged in.");
       return;
     }
     // Determine if this is an update or initial upload
     bool isUpdating = state is ResumePresent; // Assume update if resume was present before selection
     // More robust: check the status fetched initially before selection if needed

     log("ResumeViewModel: Uploading resume. isUpdating: $isUpdating");
     state = ResumeUploading(file);

     try {
        final newUrl = await _profileService.uploadOrUpdateResume(file, isUpdating);
        if (!mounted) return;

        final newFileName = Uri.parse(newUrl).pathSegments.last;
        state = ResumeUploadSuccess(newUrl, newFileName: newFileName);
        log("ResumeViewModel: Upload successful. New URL: $newUrl");

        // Optionally transition back to ResumePresent state after a delay
        await Future.delayed(const Duration(seconds: 1));
        if(mounted && state is ResumeUploadSuccess) {
           state = ResumePresent(newUrl, fileName: newFileName);
        }
        // Refresh AddSection state as resume is now present
         _ref.read(addSectionViewModelProvider.notifier).refreshStatus();


     } catch (e) {
        log("ResumeViewModel: Error uploading resume: $e");
        if (mounted) {
           // Revert to file selected on error? Or show persistent error?
           // state = ResumeFileSelected(file); // Revert to allow retry
           state = ResumeError("Upload failed: ${e.toString()}");
        }
     }
  }

   /// Delete the current resume.
   Future<void> deleteResume() async {
     if (_userId.isEmpty) {
       state = const ResumeError("User not logged in.");
       return;
     }
     // Ensure there is a resume to delete conceptually
     if (state is! ResumePresent) {
        log("ResumeViewModel: No resume present state to delete from.");
        // Optionally fetch status again to be sure
        // await fetchResumeStatus();
        return;
     }

     log("ResumeViewModel: Deleting resume...");
     state = const ResumeDeleting();

     try {
       final success = await _profileService.deleteResume();
        if (!mounted) return;

        if (success) {
           state = const ResumeDeleteSuccess();
           log("ResumeViewModel: Resume deleted successfully.");
           // Transition to NotPresent state
           await Future.delayed(const Duration(milliseconds: 500));
            if (mounted && state is ResumeDeleteSuccess) {
                state = const ResumeNotPresent();
            }
             // Refresh AddSection state as resume is now gone
            _ref.read(addSectionViewModelProvider.notifier).refreshStatus();
        } else {
            log("ResumeViewModel: Delete failed (service returned false).");
            state = const ResumeError("Failed to delete resume.");
            // Revert to previous present state on failure?
            // Consider refetching status here
        }
     } catch (e) {
        log("ResumeViewModel: Error deleting resume: $e");
        if (mounted) {
          state = ResumeError("Delete failed: ${e.toString()}");
          // Consider refetching status here
        }
     }
   }
}

final resumeViewModelProvider =
    StateNotifierProvider.autoDispose<ResumeViewModel, ResumeState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ResumeViewModel(ref, profileService);
});