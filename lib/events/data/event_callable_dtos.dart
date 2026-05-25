// Generated callable request classes (re-exported here so callers can import
// from a single feature-local path). Generated from contracts/callables/.
export 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show
        CancelEventCallableRequest,
        CreateEventCallableRequest,
        CreateEventPrivateAccess,
        EventJoinRequestDecisionCallableRequest,
        EventIdCallableRequest,
        MarkEventAttendanceCallableRequest,
        SelfCheckInAttendanceCallableRequest,
        UpdateEventCallableRequest;

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
