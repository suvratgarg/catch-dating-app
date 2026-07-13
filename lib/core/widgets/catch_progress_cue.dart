/// Shared semantic state for ordered progress-cue renderers.
enum CatchProgressCueState {
  future,
  current,
  complete;

  static CatchProgressCueState fromPosition({
    required int index,
    required int currentIndex,
  }) {
    if (index < currentIndex) return complete;
    if (index == currentIndex) return current;
    return future;
  }
}
