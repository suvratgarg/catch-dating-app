import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_attendee.freezed.dart';
part 'event_attendee.g.dart';

enum EventAttendeeSource { catchBooking, hostImport, hostManual, webOtp }

enum EventAttendeeStatus {
  invited,
  registered,
  waitlisted,
  checkedIn,
  cancelled,
}

enum EventAttendeeImportFormat { csv, xlsx, manual }

@freezed
abstract class EventAttendee with _$EventAttendee {
  const EventAttendee._();

  const factory EventAttendee({
    @JsonKey(includeToJson: false) required String id,
    required String eventId,
    required String clubId,
    required String organizerId,
    required String displayName,
    required String searchName,
    required EventAttendeeSource source,
    required EventAttendeeStatus status,
    String? linkedUid,
    String? phoneE164,
    String? email,
    String? externalReference,
    String? ticketType,
    String? importId,
    String? sourceRowId,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @NullableTimestampConverter() DateTime? registeredAt,
    @NullableTimestampConverter() DateTime? waitlistedAt,
    @NullableTimestampConverter() DateTime? checkedInAt,
    @NullableTimestampConverter() DateTime? cancelledAt,
    String? checkedInBy,
    @NullableTimestampConverter() DateTime? linkedAt,
  }) = _EventAttendee;

  factory EventAttendee.fromJson(Map<String, dynamic> json) =>
      _$EventAttendeeFromJson(json);

  bool get isCheckedIn => status == EventAttendeeStatus.checkedIn;
  bool get hasEventIdentity => linkedUid != null;
}

class EventAttendeeImportRow {
  const EventAttendeeImportRow({
    required this.rowId,
    required this.displayName,
    required this.status,
    this.phone,
    this.email,
    this.externalReference,
    this.ticketType,
  });

  final String rowId;
  final String displayName;
  final EventAttendeeStatus status;
  final String? phone;
  final String? email;
  final String? externalReference;
  final String? ticketType;

  Map<String, Object?> toJson() => {
    'rowId': rowId,
    'displayName': displayName,
    'status': status.name,
    'phone': phone,
    'email': email,
    'externalReference': externalReference,
    'ticketType': ticketType,
  };
}

class EventAttendeeImportError {
  const EventAttendeeImportError({
    required this.rowId,
    required this.code,
    required this.message,
  });

  final String rowId;
  final String code;
  final String message;
}

class EventAttendeeImportResult {
  const EventAttendeeImportResult({
    required this.importId,
    required this.status,
    required this.rowCount,
    required this.createdCount,
    required this.updatedCount,
    required this.skippedCount,
    required this.errors,
    required this.replayed,
  });

  factory EventAttendeeImportResult.fromCallableData(Object? value) {
    if (value case final Map<Object?, Object?> data) {
      final rawErrors = data['errors'];
      return EventAttendeeImportResult(
        importId: data['importId'] as String,
        status: data['status'] as String,
        rowCount: (data['rowCount'] as num).toInt(),
        createdCount: (data['createdCount'] as num).toInt(),
        updatedCount: (data['updatedCount'] as num).toInt(),
        skippedCount: (data['skippedCount'] as num).toInt(),
        errors: rawErrors is List
            ? rawErrors
                  .map((raw) {
                    final error = raw as Map<Object?, Object?>;
                    return EventAttendeeImportError(
                      rowId: error['rowId'] as String,
                      code: error['code'] as String,
                      message: error['message'] as String,
                    );
                  })
                  .toList(growable: false)
            : const [],
        replayed: data['replayed'] as bool? ?? false,
      );
    }
    throw const FormatException('Invalid event attendee import response.');
  }

  final String importId;
  final String status;
  final int rowCount;
  final int createdCount;
  final int updatedCount;
  final int skippedCount;
  final List<EventAttendeeImportError> errors;
  final bool replayed;
}
