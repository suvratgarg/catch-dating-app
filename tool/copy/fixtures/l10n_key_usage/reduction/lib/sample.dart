String renderFixture(dynamic l10n) {
  final recovered = l10n.recoveredKey;
  final used = l10n.usedKey;
  return '$recovered $used';
}
