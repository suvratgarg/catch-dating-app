/// Explicit presentation boundary for a coherent dependent task.
///
/// This declares intent, not a navigation action. A renderer must implement
/// the selected boundary; dependency evaluation must never open a modal.
enum CatchFormDependencyMode { inline, continuation, step }
