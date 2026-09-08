/// Already-localized chat and accessibility copy supplied by the caller.
class CatchPersonRowCopy {
  const CatchPersonRowCopy({
    required this.typingLabel,
    required this.newMatchLabel,
    required this.unreadCountLabel,
  });

  final String typingLabel;
  final String newMatchLabel;
  final String Function(int count) unreadCountLabel;
}
