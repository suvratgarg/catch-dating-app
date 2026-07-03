class EventSuccessRevealActionState {
  const EventSuccessRevealActionState({this.isLoading = false, this.error});

  factory EventSuccessRevealActionState.resolve({
    required bool startPending,
    required bool revealPending,
    required bool resetPending,
    Object? startError,
    Object? revealError,
    Object? resetError,
  }) {
    return EventSuccessRevealActionState(
      isLoading: startPending || revealPending || resetPending,
      error: startError ?? revealError ?? resetError,
    );
  }

  final bool isLoading;
  final Object? error;
}
