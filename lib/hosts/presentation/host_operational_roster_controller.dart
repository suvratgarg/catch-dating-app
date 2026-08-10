import 'package:catch_dating_app/events/data/event_attendee_repository.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
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
}
