import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show GetOrganizerCrmSummaryCallableRequest;
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_crm_repository.g.dart';

enum HostCrmChannelReadiness {
  currentEventOnly,
  providerSetupRequired,
  providerAndDltSetupRequired,
}

class HostCrmSummary {
  const HostCrmSummary({
    required this.organizerId,
    required this.contactCount,
    required this.pastAttendeeCount,
    required this.repeatAttendeeCount,
    required this.linkedAccountCount,
    required this.importedContactCount,
    required this.whatsappOptInCount,
    required this.smsOptInCount,
    required this.truncated,
    required this.inAppReadiness,
    required this.whatsappReadiness,
    required this.smsReadiness,
  });

  factory HostCrmSummary.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final readiness = map['readiness'];
      if (readiness is! Map<Object?, Object?>) {
        throw const FormatException('CRM response was missing readiness.');
      }
      return HostCrmSummary(
        organizerId: _requiredString(map, 'organizerId'),
        contactCount: _requiredInt(map, 'contactCount'),
        pastAttendeeCount: _requiredInt(map, 'pastAttendeeCount'),
        repeatAttendeeCount: _requiredInt(map, 'repeatAttendeeCount'),
        linkedAccountCount: _requiredInt(map, 'linkedAccountCount'),
        importedContactCount: _requiredInt(map, 'importedContactCount'),
        whatsappOptInCount: _requiredInt(map, 'whatsappOptInCount'),
        smsOptInCount: _requiredInt(map, 'smsOptInCount'),
        truncated: _requiredBool(map, 'truncated'),
        inAppReadiness: _readiness(readiness['inApp']),
        whatsappReadiness: _readiness(readiness['whatsapp']),
        smsReadiness: _readiness(readiness['sms']),
      );
    }
    throw const FormatException('Invalid CRM summary response.');
  }

  final String organizerId;
  final int contactCount;
  final int pastAttendeeCount;
  final int repeatAttendeeCount;
  final int linkedAccountCount;
  final int importedContactCount;
  final int whatsappOptInCount;
  final int smsOptInCount;
  final bool truncated;
  final HostCrmChannelReadiness inAppReadiness;
  final HostCrmChannelReadiness whatsappReadiness;
  final HostCrmChannelReadiness smsReadiness;
}

class HostCrmRepository {
  const HostCrmRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<HostCrmSummary> getSummary(String organizerId) =>
      withBackendErrorContext(
        () async {
          final result = await _functions
              .httpsCallable('getOrganizerCrmSummary')
              .call<Object?>(
                GetOrganizerCrmSummaryCallableRequest(
                  organizerId: organizerId,
                ).toJson(),
              );
          return HostCrmSummary.fromCallableData(result.data);
        },
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'load organizer CRM summary',
          resource: 'getOrganizerCrmSummary',
        ),
      );
}

@riverpod
HostCrmRepository hostCrmRepository(Ref ref) =>
    HostCrmRepository(ref.watch(firebaseFunctionsProvider));

@riverpod
Future<HostCrmSummary> hostCrmSummary(Ref ref, String organizerId) =>
    ref.read(hostCrmRepositoryProvider).getSummary(organizerId);

String _requiredString(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('CRM response was missing $key.');
}

int _requiredInt(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is num && value >= 0) return value.toInt();
  throw FormatException('CRM response was missing $key.');
}

bool _requiredBool(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is bool) return value;
  throw FormatException('CRM response was missing $key.');
}

HostCrmChannelReadiness _readiness(Object? value) => switch (value) {
  'currentEventOnly' => HostCrmChannelReadiness.currentEventOnly,
  'providerSetupRequired' => HostCrmChannelReadiness.providerSetupRequired,
  'providerAndDltSetupRequired' =>
    HostCrmChannelReadiness.providerAndDltSetupRequired,
  _ => throw const FormatException('CRM response had invalid readiness.'),
};
