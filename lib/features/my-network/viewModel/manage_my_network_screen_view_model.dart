import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/services/manage_my_network_screen_services.dart';
import 'package:link_up/features/my-network/state/manage_my_network_screen_state.dart';

class ManageMyNetworkScreenViewModel
    extends StateNotifier<ManageMyNetworkScreenState> {
  final ManageMyNetworkScreenServices _manageMyNetworkScreenServices;

  ManageMyNetworkScreenViewModel(
    this._manageMyNetworkScreenServices,
  ) : super(
          ManageMyNetworkScreenState.initial(),
        );

  // Fetch connections count
  Future<void> getManageMyNetworkScreenCounts() async {
    state = state.copyWith(isLoading: true, error: false);

    try {
      final response =
          await _manageMyNetworkScreenServices.getManageMyNetworkScreenCounts();
      final connectionsCount = response['number_of_connections'];
      final followingCount = response['number_of_following'];

      state = state.copyWith(
        isLoading: false,
        connectionsCount: connectionsCount,
        followingCount: followingCount,
      );
    } catch (e) {
      print(e);
      state = state.copyWith(isLoading: false, error: true);
    }
  }
}

// Provider for the view model
final manageMyNetworkScreenViewModelProvider = StateNotifierProvider<
    ManageMyNetworkScreenViewModel, ManageMyNetworkScreenState>((ref) {
  return ManageMyNetworkScreenViewModel(
      ref.read(manageMyNetworkScreenServicesProvider));
});
