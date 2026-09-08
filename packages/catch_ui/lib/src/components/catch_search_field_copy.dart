/// Caller-resolved search defaults and action labels.
///
/// The clear formatter receives the resolved placeholder, including a caller's
/// override, so it retains that search surface's meaning and locale grammar.
class CatchSearchFieldCopy {
  const CatchSearchFieldCopy({
    required this.searchLabel,
    required this.clearTooltip,
    required this.closeSearchLabel,
  });

  final String searchLabel;
  final String Function(String placeholder) clearTooltip;
  final String closeSearchLabel;
}
