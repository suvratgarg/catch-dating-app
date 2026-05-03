/// Formats a pace value in seconds-per-km to a "m:ss" display string.
/// Accepts [num] so both [int] and [double] callers work without casts.
String formatPace(num secsPerKm) {
  final totalSeconds = secsPerKm.round();
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
