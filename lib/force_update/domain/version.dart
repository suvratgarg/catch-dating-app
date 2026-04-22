/// Compares two semver strings of the form "MAJOR.MINOR.PATCH".
///
/// Returns true if [current] is strictly less than [minimum], meaning an
/// update is required.
///
/// Non-parseable strings are treated as "0.0.0" so a missing/malformed
/// Firestore document never blocks the user.
bool isUpdateRequired({
  required String current,
  required String minimum,
}) {
  final cur = _parse(current);
  final min = _parse(minimum);
  for (var i = 0; i < 3; i++) {
    if (cur[i] < min[i]) return true;
    if (cur[i] > min[i]) return false;
  }
  return false; // equal → no update needed
}

List<int> _parse(String version) {
  try {
    final parts = version.split('.');
    return List.generate(3, (i) => i < parts.length ? int.parse(parts[i]) : 0);
  } catch (_) {
    return [0, 0, 0];
  }
}
