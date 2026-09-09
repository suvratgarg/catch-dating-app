/// Visual contact and committed route selection for a navigation destination.
enum CatchNavigationButtonStatus {
  /// Neither the active route nor the pointer's current preview.
  unselected,

  /// Active route with its selection indicator on this destination.
  selected,

  /// Pointer preview only; the route has not changed yet.
  preview,

  /// Active route while the pointer previews another destination.
  retainedSelection,
}
