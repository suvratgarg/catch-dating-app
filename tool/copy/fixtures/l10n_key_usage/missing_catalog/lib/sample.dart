String renderFixture(dynamic l10n) {
  final valid = l10n.validKey;
  final missing = l10n.missingCatalogKey;
  final transformed = resolve(l10n).toUpperCase();
  final locale = l10n.localeName;
  // l10n.commentOnly must not become a missing catalog reference.
  const ignored = 'l10n.stringOnly';
  return '$valid $missing $transformed $locale $ignored';
}
