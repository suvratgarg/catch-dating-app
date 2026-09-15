import 'dart:convert';

import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart';
import 'package:catch_dating_app/hosts/data/crm/host_crm_callable.dart';
import 'package:catch_dating_app/hosts/domain/crm/crm_response_fields.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience_definition.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience_filter_options.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_saved_audience_repository.g.dart';

class HostSavedAudienceRepository {
  const HostSavedAudienceRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<List<HostStaticAudienceMember>> resolveAudienceMembers(
    String organizerId,
    List<String> contactIds,
  ) => callHostCrm(
    _functions,
    name: 'resolveOrganizerAudienceMembers',
    payload: ResolveOrganizerAudienceMembersCallableRequest(
      organizerId: organizerId,
      contactIds: contactIds,
    ).toJson(),
    action: 'load selected audience people',
    parse: (data) => crmMapList(
      crmRequiredMap(data, 'selected audience people')['members'],
      'selected audience people',
    ).map(HostStaticAudienceMember.fromMap).toList(growable: false),
  );

  Future<HostSavedAudienceFilterOptions> savedAudienceFilterOptions(
    String organizerId,
  ) => callHostCrm(
    _functions,
    name: 'listOrganizerSavedAudiences',
    payload: ListOrganizerSavedAudiencesCallableRequest(
      organizerId: organizerId,
      limit: 1,
      includeFilterOptions: true,
    ).toJson(),
    action: 'load audience filter choices',
    parse: HostSavedAudienceFilterOptions.fromCallableData,
  );

  Future<HostSavedAudiencePage> listSavedAudiences(
    String organizerId, {
    String status = 'active',
    String? cursor,
    int limit = ReadLimitPolicy.directoryPage,
  }) => callHostCrm(
    _functions,
    name: 'listOrganizerSavedAudiences',
    payload: ListOrganizerSavedAudiencesCallableRequest(
      organizerId: organizerId,
      status: status,
      limit: limit > 50 ? 50 : limit,
      cursor: cursor,
    ).toJson(),
    action: 'load organizer saved audiences',
    parse: HostSavedAudiencePage.fromCallableData,
  );

  Future<HostSavedAudience> upsertSavedAudience({
    required String organizerId,
    required String requestId,
    required String name,
    required HostSavedAudienceDefinition definition,
    String? audienceId,
    int? expectedRevision,
  }) => callHostCrm(
    _functions,
    name: 'upsertOrganizerSavedAudience',
    payload: {
      'organizerId': organizerId,
      'audienceId': ?audienceId,
      'requestId': requestId,
      'expectedRevision': ?expectedRevision,
      'scope': 'organizerCrm',
      'name': name,
      'definition': definition.toJson(),
    },
    action: 'save organizer audience',
    parse: (value) =>
        HostSavedAudience.fromMap(crmRequiredMap(value, 'saved audience')),
  );

  Future<HostSavedAudiencePreview> previewSavedAudience({
    required String organizerId,
    required HostSavedAudience audience,
    int sampleLimit = 10,
    String? cursor,
  }) => callHostCrm(
    _functions,
    name: 'previewOrganizerSavedAudience',
    payload: PreviewOrganizerSavedAudienceCallableRequest(
      organizerId: organizerId,
      audienceId: audience.audienceId,
      expectedRevision: audience.revision,
      sampleLimit: sampleLimit,
      cursor: cursor,
    ).toJson(),
    action: 'preview organizer audience',
    parse: HostSavedAudiencePreview.fromCallableData,
  );

  Future<HostSavedAudience> archiveSavedAudience({
    required String organizerId,
    required HostSavedAudience audience,
  }) => callHostCrm(
    _functions,
    name: 'archiveOrganizerSavedAudience',
    payload: ArchiveOrganizerSavedAudienceCallableRequest(
      organizerId: organizerId,
      audienceId: audience.audienceId,
      expectedRevision: audience.revision,
    ).toJson(),
    action: 'archive organizer audience',
    parse: (value) =>
        HostSavedAudience.fromMap(crmRequiredMap(value, 'saved audience')),
  );
}

// keepalive: Reuse the callable client for the saved audience subdomain.
@Riverpod(keepAlive: true)
HostSavedAudienceRepository hostSavedAudienceRepository(Ref ref) =>
    HostSavedAudienceRepository(ref.watch(firebaseFunctionsProvider));

@riverpod
Future<HostSavedAudiencePage> hostSavedAudiences(Ref ref, String organizerId) =>
    ref
        .read(hostSavedAudienceRepositoryProvider)
        .listSavedAudiences(organizerId);

/// Exhaustive saved-audience directory used by the Customers-owned workspace.
///
/// The callable remains cursor-paginated; this bounded provider follows those
/// cursors so client-side name search never silently searches only page one.
@riverpod
Future<HostSavedAudiencePage> hostAllSavedAudiences(
  Ref ref,
  String organizerId,
) async {
  const maximumDefinitions = 2500;
  final repository = ref.read(hostSavedAudienceRepositoryProvider);
  final audiences = <HostSavedAudience>[];
  String? cursor;
  do {
    final page = await repository.listSavedAudiences(
      organizerId,
      cursor: cursor,
      limit: 50,
    );
    audiences.addAll(page.audiences);
    cursor = page.nextCursor;
    if (audiences.length >= maximumDefinitions && cursor != null) {
      throw StateError(
        'Saved audience directory exceeds $maximumDefinitions definitions.',
      );
    }
  } while (cursor != null);
  return HostSavedAudiencePage(audiences: audiences, nextCursor: null);
}

@riverpod
Future<List<HostStaticAudienceMember>> hostStaticAudienceMembers(
  Ref ref,
  String organizerId,
  String selectionKey,
) => ref
    .read(hostSavedAudienceRepositoryProvider)
    .resolveAudienceMembers(
      organizerId,
      crmStringList(jsonDecode(selectionKey)),
    );

@riverpod
Future<HostSavedAudienceFilterOptions> hostSavedAudienceFilterOptions(
  Ref ref,
  String organizerId,
) => ref
    .read(hostSavedAudienceRepositoryProvider)
    .savedAudienceFilterOptions(organizerId);
