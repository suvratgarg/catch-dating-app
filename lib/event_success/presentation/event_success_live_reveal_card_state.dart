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

class EventSuccessOutcomeActionState {
  const EventSuccessOutcomeActionState({this.isLoading = false, this.error});

  final bool isLoading;
  final Object? error;
}

final class EventSuccessOutcomeUnit {
  const EventSuccessOutcomeUnit({required this.id, required this.label});

  final String id;
  final String label;
}
