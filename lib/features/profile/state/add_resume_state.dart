import 'dart:io';
import 'package:flutter/foundation.dart' show immutable;

@immutable
sealed class ResumeState {
  const ResumeState();
}

class ResumeInitial extends ResumeState {
  const ResumeInitial();
}

class ResumeLoading extends ResumeState {
  const ResumeLoading();
}

class ResumePresent extends ResumeState {
  final String resumeUrl;
  final String? fileName;
  const ResumePresent(this.resumeUrl, {this.fileName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumePresent &&
          runtimeType == other.runtimeType &&
          resumeUrl == other.resumeUrl &&
          fileName == other.fileName;

  @override
  int get hashCode => resumeUrl.hashCode ^ fileName.hashCode;
}

class ResumeNotPresent extends ResumeState {
  const ResumeNotPresent();
}

class ResumeFileSelected extends ResumeState {
  final File selectedFile;
  const ResumeFileSelected(this.selectedFile);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeFileSelected &&
          runtimeType == other.runtimeType &&
          selectedFile.path == other.selectedFile.path;

  @override
  int get hashCode => selectedFile.path.hashCode;
}

class ResumeUploading extends ResumeState {
  final File uploadingFile;
  const ResumeUploading(this.uploadingFile);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeUploading &&
          runtimeType == other.runtimeType &&
          uploadingFile.path == other.uploadingFile.path;

  @override
  int get hashCode => uploadingFile.path.hashCode;
}

class ResumeUploadSuccess extends ResumeState {
  final String newResumeUrl;
  final String? newFileName;
  const ResumeUploadSuccess(this.newResumeUrl, {this.newFileName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeUploadSuccess &&
          runtimeType == other.runtimeType &&
          newResumeUrl == other.newResumeUrl &&
          newFileName == other.newFileName;

  @override
  int get hashCode => newResumeUrl.hashCode ^ newFileName.hashCode;
}

class ResumeDeleting extends ResumeState {
  const ResumeDeleting();
}

class ResumeDeleteSuccess extends ResumeState {
  const ResumeDeleteSuccess();
}

class ResumeError extends ResumeState {
  final String message;
  const ResumeError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}