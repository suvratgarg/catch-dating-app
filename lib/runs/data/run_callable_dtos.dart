import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';

final class CreateRunCallableRequest {
  const CreateRunCallableRequest({
    required this.runId,
    required this.runClubId,
    required this.details,
    required this.capacityLimit,
    required this.priceInPaise,
    required this.constraints,
  });

  factory CreateRunCallableRequest.fromRun(Run run) => CreateRunCallableRequest(
    runId: run.id,
    runClubId: run.runClubId,
    details: RunDetailsCallableFields.fromRun(run),
    capacityLimit: run.capacityLimit,
    priceInPaise: run.priceInPaise,
    constraints: RunConstraintsCallableDto.fromDomain(run.constraints),
  );

  final String runId;
  final String runClubId;
  final RunDetailsCallableFields details;
  final int capacityLimit;
  final int priceInPaise;
  final RunConstraintsCallableDto constraints;

  Map<String, Object?> toJson() => {
    'runId': runId,
    'runClubId': runClubId,
    ...details.toJson(),
    'capacityLimit': capacityLimit,
    'priceInPaise': priceInPaise,
    'constraints': constraints.toJson(),
  };
}

final class UpdateRunCallableRequest {
  const UpdateRunCallableRequest({required this.runId, required this.fields});

  factory UpdateRunCallableRequest.fromRun(Run run) => UpdateRunCallableRequest(
    runId: run.id,
    fields: RunDetailsCallableFields.fromRun(run),
  );

  final String runId;
  final RunDetailsCallableFields fields;

  Map<String, Object?> toJson() => {'runId': runId, 'fields': fields.toJson()};
}

final class RunDetailsCallableFields {
  const RunDetailsCallableFields({
    required this.startTimeMillis,
    required this.endTimeMillis,
    required this.meetingPoint,
    required this.startingPointLat,
    required this.startingPointLng,
    required this.locationDetails,
    required this.distanceKm,
    required this.pace,
    required this.description,
  });

  factory RunDetailsCallableFields.fromRun(Run run) => RunDetailsCallableFields(
    startTimeMillis: run.startTime.millisecondsSinceEpoch,
    endTimeMillis: run.endTime.millisecondsSinceEpoch,
    meetingPoint: run.meetingPoint,
    startingPointLat: run.startingPointLat,
    startingPointLng: run.startingPointLng,
    locationDetails: run.locationDetails,
    distanceKm: run.distanceKm,
    pace: run.pace.name,
    description: run.description,
  );

  final int startTimeMillis;
  final int endTimeMillis;
  final String meetingPoint;
  final double? startingPointLat;
  final double? startingPointLng;
  final String? locationDetails;
  final double distanceKm;
  final String pace;
  final String description;

  Map<String, Object?> toJson() => {
    'startTimeMillis': startTimeMillis,
    'endTimeMillis': endTimeMillis,
    'meetingPoint': meetingPoint,
    'startingPointLat': startingPointLat,
    'startingPointLng': startingPointLng,
    'locationDetails': locationDetails,
    'distanceKm': distanceKm,
    'pace': pace,
    'description': description,
  };
}

final class RunConstraintsCallableDto {
  const RunConstraintsCallableDto({
    required this.minAge,
    required this.maxAge,
    required this.maxMen,
    required this.maxWomen,
  });

  factory RunConstraintsCallableDto.fromDomain(RunConstraints constraints) =>
      RunConstraintsCallableDto(
        minAge: constraints.minAge,
        maxAge: constraints.maxAge,
        maxMen: constraints.maxMen,
        maxWomen: constraints.maxWomen,
      );

  final int minAge;
  final int maxAge;
  final int? maxMen;
  final int? maxWomen;

  Map<String, Object?> toJson() => {
    'minAge': minAge,
    'maxAge': maxAge,
    'maxMen': maxMen,
    'maxWomen': maxWomen,
  };
}

final class RunIdCallableRequest {
  const RunIdCallableRequest(this.runId);

  final String runId;

  Map<String, Object?> toJson() => {'runId': runId};
}

final class MarkRunAttendanceCallableRequest {
  const MarkRunAttendanceCallableRequest({
    required this.runId,
    required this.userId,
  });

  final String runId;
  final String userId;

  Map<String, Object?> toJson() => {'runId': runId, 'userId': userId};
}

final class MarkRunAttendanceCallableResponse {
  const MarkRunAttendanceCallableResponse({required this.attended});

  factory MarkRunAttendanceCallableResponse.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final attended = map['attended'];
      if (attended is bool) {
        return MarkRunAttendanceCallableResponse(attended: attended);
      }
    }
    throw StateError('markRunAttendance response was missing attended.');
  }

  final bool attended;
}

final class SelfCheckInAttendanceCallableRequest {
  const SelfCheckInAttendanceCallableRequest({
    required this.runId,
    required this.latitude,
    required this.longitude,
  });

  final String runId;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toJson() => {
    'runId': runId,
    'latitude': ?latitude,
    'longitude': ?longitude,
  };
}
