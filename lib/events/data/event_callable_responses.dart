final class MarkEventAttendanceCallableResponse {
  const MarkEventAttendanceCallableResponse({required this.attended});

  factory MarkEventAttendanceCallableResponse.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final attended = map['attended'];
      if (attended is bool) {
        return MarkEventAttendanceCallableResponse(attended: attended);
      }
    }
    throw StateError('markEventAttendance response was missing attended.');
  }

  final bool attended;
}
