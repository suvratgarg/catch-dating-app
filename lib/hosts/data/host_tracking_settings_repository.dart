import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_tracking_settings_repository.g.dart';

/// Rotates on every auth transition, including sign-out/re-entry to the same UID.
/// Mutation/editor identity must not survive a previous authenticated session.
final hostTrackingSessionProvider = Provider<Object>((ref) {
  ref.watch(uidProvider);
  return Object();
});

typedef HostTrackingSettingsScope = ({
  String accountId,
  String organizerId,
  Object session,
});

/// Private manager settings. IDs are configuration, never account credentials.
class HostTrackingSettings {
  const HostTrackingSettings({
    required this.organizerId,
    required this.revision,
    required this.metaPixelId,
    required this.googleMeasurementId,
    required this.enabled,
    required this.publicationAllowed,
    required this.canEdit,
    required this.editBlockedReason,
  });
  final String organizerId;
  final int revision;
  final String? metaPixelId;
  final String? googleMeasurementId;
  final bool enabled;
  final bool publicationAllowed;
  final bool canEdit;
  final String editBlockedReason;

  factory HostTrackingSettings.fromResponse(
    Object? data,
    String expectedOrganizerId,
  ) {
    if (data is! Map ||
        data['organizerId'] != expectedOrganizerId ||
        data['revision'] is! int ||
        (data['revision'] as int) < 0 ||
        (data['revision'] as int) > 9007199254740991 ||
        data['enabled'] != false ||
        data['publicationAllowed'] != false ||
        data['policyReason'] != 'policyReviewRequired' ||
        data['canEdit'] is! bool ||
        !const ['none', 'unclaimed'].contains(data['editBlockedReason']) ||
        (data['canEdit'] == true) != (data['editBlockedReason'] == 'none') ||
        (data['metaPixelId'] != null &&
            (data['metaPixelId'] is! String ||
                !RegExp(
                  r'^[0-9]{5,20}$',
                ).hasMatch(data['metaPixelId'] as String))) ||
        (data['googleMeasurementId'] != null &&
            (data['googleMeasurementId'] is! String ||
                !RegExp(
                  r'^G-[A-Z0-9]{4,20}$',
                ).hasMatch(data['googleMeasurementId'] as String)))) {
      throw const FormatException('Invalid organizer tracking settings.');
    }
    return HostTrackingSettings(
      organizerId: expectedOrganizerId,
      revision: data['revision'] as int,
      metaPixelId: data['metaPixelId'] as String?,
      googleMeasurementId: data['googleMeasurementId'] as String?,
      enabled: false,
      publicationAllowed: false,
      canEdit: data['canEdit'] as bool,
      editBlockedReason: data['editBlockedReason'] as String,
    );
  }
}

class HostTrackingSettingsRepository {
  const HostTrackingSettingsRepository(this._functions);
  final FirebaseFunctions _functions;
  Future<HostTrackingSettings> read(String organizerId) => _call(
    'getOrganizerTrackingSettings',
    GetOrganizerTrackingSettingsCallableRequest(
      organizerId: organizerId,
    ).toJson(),
    organizerId,
  );
  Future<HostTrackingSettings> save(
    SetOrganizerTrackingSettingsCallableRequest request,
  ) => _call(
    'setOrganizerTrackingSettings',
    request.toJson(),
    request.organizerId,
  );

  Future<HostTrackingSettings> _call(
    String name,
    Map<String, Object?> payload,
    String organizerId,
  ) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable(name)
          .call<Object?>(payload);
      return HostTrackingSettings.fromResponse(result.data, organizerId);
    },
    context: BackendErrorContext(
      service: BackendService.functions,
      action: name,
      resource: organizerId,
    ),
  );
}

@riverpod
HostTrackingSettingsRepository hostTrackingSettingsRepository(Ref ref) =>
    HostTrackingSettingsRepository(ref.watch(firebaseFunctionsProvider));

@riverpod
Future<HostTrackingSettings> hostTrackingSettings(
  Ref ref,
  String organizerId,
) async {
  final session = ref.watch(hostTrackingSessionProvider);
  final auth = ref.watch(uidProvider);
  final uid = !auth.isLoading && !auth.hasError ? auth.asData?.value : null;
  if (uid == null || uid.isEmpty) {
    throw const SignInRequiredException('read tracking settings');
  }
  final result = await ref
      .watch(hostTrackingSettingsRepositoryProvider)
      .read(organizerId);
  if (!ref.mounted ||
      ref.read(uidProvider).isLoading ||
      ref.read(uidProvider).hasError ||
      ref.read(uidProvider).asData?.value != uid ||
      !identical(ref.read(hostTrackingSessionProvider), session)) {
    throw const SignInRequiredException('read tracking settings');
  }
  return result;
}
