import 'package:catch_dating_app/events/data/event_attendee_repository.dart';
import 'package:catch_dating_app/events/data/event_runtime_claim_repository.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/events/domain/event_runtime_claim_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_operational_roster_controller.g.dart';

@riverpod
HostOperationalRosterController hostOperationalRosterController(Ref ref) =>
    HostOperationalRosterController(ref);

class HostOperationalRosterController {
  const HostOperationalRosterController(this._ref);

  final Ref _ref;

  Future<EventAttendeeImportResult> importAttendees({
    required String eventId,
    required String importKey,
    required String fileName,
    required EventAttendeeImportFormat format,
    required List<EventAttendeeImportRow> rows,
  }) => _ref
      .read(eventAttendeeRepositoryProvider)
      .importAttendees(
        eventId: eventId,
        importKey: importKey,
        fileName: fileName,
        format: format,
        rows: rows,
      );

  Future<bool> markAttendance({
    required String eventId,
    required String attendeeId,
  }) => _ref
      .read(eventAttendeeRepositoryProvider)
      .markAttendance(eventId: eventId, attendeeId: attendeeId);

  Future<EventRuntimeClaimStatus> reviewRuntimeClaim({
    required String eventId,
    required String uid,
    required EventRuntimeClaimDecision decision,
    String? attendeeId,
  }) async {
    final status = await _ref
        .read(eventRuntimeClaimRepositoryProvider)
        .review(
          eventId: eventId,
          uid: uid,
          decision: decision,
          attendeeId: attendeeId,
        );
    _ref.invalidate(watchPendingEventRuntimeClaimsProvider(eventId));
    _ref.invalidate(watchEventAttendeesProvider(eventId));
    return status;
  }

  Future<EventRosterHandoffInstructions> createRosterHandoff({
    required String eventId,
  }) => _ref
      .read(eventAttendeeRepositoryProvider)
      .createRosterHandoff(eventId: eventId);
}
