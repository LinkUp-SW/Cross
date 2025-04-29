import 'package:link_up/features/jobs/model/save_job_model.dart';



class SaveJobState {
  final SaveJobModel? saveJobModel;
  final bool isLoading;
  final bool isError;
  final String errorMessage;
  


const SaveJobState({
  required this.saveJobModel,
  this.isLoading = true,
  this.isError = false,
  this.errorMessage = '',
});

factory SaveJobState.initial() {
  return const SaveJobState(
    saveJobModel:null,
    isLoading: true,
    isError: false,
    errorMessage: '',
  );
}

SaveJobState copyWith({
  final SaveJobModel? saveJobModel,
  final bool? isLoading,
  final bool? isError,
  final String? errorMessage,
}) {
  return SaveJobState(
    saveJobModel: saveJobModel ?? this.saveJobModel,
    isLoading: isLoading ?? this.isLoading,
    isError: isError ?? this.isError,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

}
