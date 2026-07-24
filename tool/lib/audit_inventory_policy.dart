bool matchesAuditPattern(String path, String pattern) {
  final doubleStar = '\u0000';
  final escaped = RegExp.escape(pattern)
      .replaceAll(r'\*\*', doubleStar)
      .replaceAll(r'\*', '[^/]*')
      .replaceAll(r'\?', '[^/]')
      .replaceAll(doubleStar, '.*');
  return RegExp('^$escaped\$').hasMatch(path);
}

Map<String, dynamic>? auditPolicyFor(
  String path,
  Map<String, dynamic> rootManifest,
) {
  final policies = rootManifest['auditPolicies'];
  if (policies is! List) return null;
  for (final policy in policies.whereType<Map>()) {
    final pattern = policy['pattern'];
    if (pattern is String && matchesAuditPattern(path, pattern)) {
      return Map<String, dynamic>.from(policy);
    }
  }
  return null;
}
