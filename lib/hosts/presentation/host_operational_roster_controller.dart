import 'package:catch_dating_app/events/data/event_attendee_repository.dart';
import 'package:catch_dating_app/events/data/event_runtime_claim_repository.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/events/domain/event_runtime_claim_request.dart';
import 'package:catch_dating_app/hosts/data/host_provider_repository.dart';
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

  Future<EventAttendeeAttendanceResult> setAttendance({
    required String eventId,
    required EventAttendee attendee,
    required String clientOperationId,
  }) => _ref
      .read(eventAttendeeRepositoryProvider)
      .setAttendance(
        eventId: eventId,
        attendeeId: attendee.id,
        desiredCheckedIn: !attendee.isCheckedIn,
        expectedRevision: attendee.attendanceRevision,
        clientOperationId: clientOperationId,
      );

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

  Future<HostProviderSetup> getProviderSetup({
    required String organizerId,
    required String eventId,
  }) => _ref
      .read(hostProviderRepositoryProvider)
      .getSetup(organizerId: organizerId, eventId: eventId);

  Future<HostProviderEventChoices> listLumaEvents({
    required String organizerId,
    required String eventId,
    required String apiKey,
  }) => _ref
      .read(hostProviderRepositoryProvider)
      .listLumaEvents(
        organizerId: organizerId,
        eventId: eventId,
        apiKey: apiKey,
      );

  Future<HostProviderSetup> connectLuma({
    required String organizerId,
    required String eventId,
    required String externalEventId,
    required String apiKey,
  }) => _ref
      .read(hostProviderRepositoryProvider)
      .connectLuma(
        organizerId: organizerId,
        eventId: eventId,
        externalEventId: externalEventId,
        apiKey: apiKey,
      );

  Future<HostProviderSyncResult> syncProvider({
    required String organizerId,
    required String eventId,
    required String clientOperationId,
  }) => _ref
      .read(hostProviderRepositoryProvider)
      .syncEvent(
        organizerId: organizerId,
        eventId: eventId,
        clientOperationId: clientOperationId,
      );

  Future<HostProviderSetup> disconnectProvider({
    required String organizerId,
    required String eventId,
    required String connectionId,
  }) => _ref
      .read(hostProviderRepositoryProvider)
      .disconnect(
        organizerId: organizerId,
        eventId: eventId,
        connectionId: connectionId,
      );
}
