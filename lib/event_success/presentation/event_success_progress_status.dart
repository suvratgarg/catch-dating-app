/// Shared position semantics for Event Success countdown and run-of-show cues.
///
/// Both feature renderers consume this state; each keeps its own layout.
enum EventSuccessProgressStatus {
  future,
  current,
  complete;

  static EventSuccessProgressStatus fromPosition({
    required int index,
    required int currentIndex,
  }) {
    if (index < currentIndex) return complete;
    if (index == currentIndex) return current;
    return future;
  }
}
