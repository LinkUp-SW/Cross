class ManageMyNetworkScreenState {
  final int? connectionsCount;
  final int? followingCount;
  final int? pagesCount;
  final bool isLoading;
  final bool error;

  const ManageMyNetworkScreenState({
    this.connectionsCount,
    this.followingCount,
    this.pagesCount,
    required this.isLoading,
    required this.error,
  });

  factory ManageMyNetworkScreenState.initial() {
    return const ManageMyNetworkScreenState(
      connectionsCount: 0,
      followingCount: 0,
      pagesCount: 0,
      isLoading: true,
      error: false,
    );
  }

  ManageMyNetworkScreenState copyWith({
    final int? connectionsCount,
    final int? followingCount,
    final int? pagesCount,
    final bool? isLoading,
    final bool? error,
  }) {
    return ManageMyNetworkScreenState(
      connectionsCount: connectionsCount ?? this.connectionsCount,
      followingCount: followingCount ?? this.followingCount,
      pagesCount: pagesCount ?? this.pagesCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
