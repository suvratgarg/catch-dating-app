/// Atomic read/modify/write of one account's command journal. The callback is
/// synchronous: it must not perform networking or change external state.
abstract interface class CommandJournalStorage {
  Future<T> transact<T>(
    String key,
    T Function(Map<String, Object?> state) change,
  );
  Future<void> close();
}
