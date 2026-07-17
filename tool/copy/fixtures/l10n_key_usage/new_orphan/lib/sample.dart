String renderFixture(dynamic l10n) {
  // A comment mentioning l10n.knownOrphan is not a production use.
  /* Nested comments are ignored too: /* knownOrphan */ stringOnly. */
  const ignoredText = 'stringOnly';
  const ignoredRawText = r'generatedOnly';
  final direct = l10n.usedKey;
  final interpolated = '${l10n.usedInInterpolation}';
  return '$direct $interpolated $ignoredText $ignoredRawText';
}
