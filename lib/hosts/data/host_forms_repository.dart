import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_forms_repository.g.dart';

class HostFormValidationResult {
  const HostFormValidationResult({required this.valid, required this.issues});

  factory HostFormValidationResult.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'form validation');
    final valid = map['valid'];
    if (valid is! bool) {
      throw const FormatException('Form validation was missing valid.');
    }
    return HostFormValidationResult(
      valid: valid,
      issues: _mapList(
        map['issues'],
        'form validation issues',
      ).map(HostFormValidationIssue.fromMap).toList(growable: false),
    );
  }

  final bool valid;
  final List<HostFormValidationIssue> issues;
}

class HostFormsRepository {
  const HostFormsRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<HostFormPage> listForms(HostFormListRequest request) => _call(
    name: 'listOrganizerForms',
    payload: ListOrganizerFormsCallableRequest(
      organizerId: request.organizerId,
      statuses: request.statuses.map((value) => value.name).toList(),
      purposes: request.purposes.map((value) => value.name).toList(),
      query: request.query?.trim().isEmpty ?? true
          ? null
          : request.query?.trim(),
      cursor: request.cursor,
      limit: request.limit.clamp(1, ReadLimitPolicy.historyPage).toInt(),
    ).toJson(),
    action: 'load organizer forms',
    parse: HostFormPage.fromCallableData,
  );

  Future<List<HostFormTemplateSummary>> listTemplates(String organizerId) =>
      _call(
        name: 'listOrganizerFormTemplates',
        payload: ListOrganizerFormTemplatesCallableRequest(
          organizerId: organizerId,
        ).toJson(),
        action: 'load form templates',
        parse: (data) {
          final map = _requiredMap(data, 'form templates');
          return _mapList(
            map['templates'],
            'form templates',
          ).map(HostFormTemplateSummary.fromMap).toList(growable: false);
        },
      );

  Future<HostFormEditor> createForm({
    required String organizerId,
    required String templateId,
    required String requestId,
    String? title,
  }) => _call(
    name: 'createOrganizerForm',
    payload: CreateOrganizerFormCallableRequest(
      organizerId: organizerId,
      templateId: templateId,
      requestId: requestId,
      title: title?.trim().isEmpty ?? true ? null : title?.trim(),
      defaultTargetKind: HostFormTargetKind.organizer.name,
      defaultTargetId: null,
    ).toJson(),
    action: 'create organizer form',
    parse: HostFormEditor.fromCallableData,
  );

  Future<HostFormEditor> getEditor({
    required String organizerId,
    required String formId,
  }) => _call(
    name: 'getOrganizerFormEditor',
    payload: GetOrganizerFormEditorCallableRequest(
      organizerId: organizerId,
      formId: formId,
    ).toJson(),
    action: 'load organizer form editor',
    parse: HostFormEditor.fromCallableData,
  );

  Future<HostFormEditor> updateDraft({
    required String organizerId,
    required String formId,
    required int expectedRevision,
    required HostFormDefinition definition,
  }) => _call(
    name: 'updateOrganizerFormDraft',
    payload: UpdateOrganizerFormDraftCallableRequest(
      organizerId: organizerId,
      formId: formId,
      expectedRevision: expectedRevision,
      definition: definition.toJson(),
    ).toJson(),
    action: 'save organizer form draft',
    parse: HostFormEditor.fromCallableData,
  );

  Future<HostFormValidationResult> validateDraft({
    required String organizerId,
    required String formId,
    required HostFormDefinition definition,
  }) => _call(
    name: 'validateOrganizerFormDraft',
    payload: ValidateOrganizerFormDraftCallableRequest(
      organizerId: organizerId,
      formId: formId,
      definition: definition.toJson(),
    ).toJson(),
    action: 'validate organizer form draft',
    parse: HostFormValidationResult.fromCallableData,
  );

  Future<HostFormSummary> publish({
    required String organizerId,
    required String formId,
    required int expectedRevision,
  }) => _call(
    name: 'publishOrganizerForm',
    payload: PublishOrganizerFormCallableRequest(
      organizerId: organizerId,
      formId: formId,
      expectedRevision: expectedRevision,
    ).toJson(),
    action: 'publish organizer form',
    parse: (data) =>
        HostFormSummary.fromMap(_requiredMap(data, 'published organizer form')),
  );

  Future<HostFormSummary> setLifecycle({
    required String organizerId,
    required String formId,
    required HostFormLifecycleStatus expectedStatus,
    required HostFormLifecycleAction action,
  }) => _call(
    name: 'setOrganizerFormLifecycle',
    payload: SetOrganizerFormLifecycleCallableRequest(
      organizerId: organizerId,
      formId: formId,
      expectedStatus: expectedStatus.name,
      action: action.name,
    ).toJson(),
    action: '${action.name} organizer form',
    parse: (data) =>
        HostFormSummary.fromMap(_requiredMap(data, 'organizer form lifecycle')),
  );

  Future<HostFormEditor> duplicate({
    required String organizerId,
    required String sourceFormId,
    required String requestId,
    String? title,
  }) => _call(
    name: 'duplicateOrganizerForm',
    payload: DuplicateOrganizerFormCallableRequest(
      organizerId: organizerId,
      sourceFormId: sourceFormId,
      requestId: requestId,
      title: title?.trim().isEmpty ?? true ? null : title?.trim(),
    ).toJson(),
    action: 'duplicate organizer form',
    parse: HostFormEditor.fromCallableData,
  );

  Future<void> deleteDraft({
    required String organizerId,
    required String formId,
    required int expectedRevision,
  }) => _call<void>(
    name: 'deleteOrganizerFormDraft',
    payload: DeleteOrganizerFormDraftCallableRequest(
      organizerId: organizerId,
      formId: formId,
      expectedRevision: expectedRevision,
    ).toJson(),
    action: 'delete organizer form draft',
    parse: (data) {
      final map = _requiredMap(data, 'deleted organizer form draft');
      if (map['deleted'] != true) {
        throw const FormatException('Organizer form draft was not deleted.');
      }
    },
  );

  Future<HostFormShareAssets> getShareAssets({
    required String organizerId,
    required String formId,
  }) => _call(
    name: 'getOrganizerFormShareAssets',
    payload: GetOrganizerFormShareAssetsCallableRequest(
      organizerId: organizerId,
      formId: formId,
    ).toJson(),
    action: 'load organizer form share assets',
    parse: HostFormShareAssets.fromCallableData,
  );

  Future<HostFormShareLink> createShareLink({
    required String organizerId,
    required String formId,
    required String label,
    required String? source,
    required String requestId,
  }) => _call(
    name: 'createOrganizerFormShareLink',
    payload: CreateOrganizerFormShareLinkCallableRequest(
      organizerId: organizerId,
      formId: formId,
      label: label.trim(),
      source: source?.trim().isEmpty ?? true ? null : source?.trim(),
      requestId: requestId,
    ).toJson(),
    action: 'create organizer form share link',
    parse: HostFormShareLink.fromCallableData,
  );

  Future<HostFormResponsePage> listResponses(
    HostFormResponseListRequest request,
  ) => _call(
    name: 'listOrganizerFormResponses',
    payload: ListOrganizerFormResponsesCallableRequest(
      organizerId: request.organizerId,
      formId: request.formId,
      versionId: request.versionId,
      statuses: request.statuses.map((value) => value.name).toList(),
      identityKinds: request.identityKinds.map((value) => value.name).toList(),
      sourceLinkId: request.sourceLinkId,
      query: request.query?.trim().isEmpty ?? true
          ? null
          : request.query?.trim(),
      fromMillis: request.from?.millisecondsSinceEpoch,
      toMillis: request.to?.millisecondsSinceEpoch,
      cursor: request.cursor,
      limit: request.limit.clamp(1, ReadLimitPolicy.historyPage).toInt(),
    ).toJson(),
    action: 'load organizer form responses',
    parse: HostFormResponsePage.fromCallableData,
  );

  Future<HostFormResponseDetail> getResponseDetail({
    required String organizerId,
    required String responseId,
  }) => _call(
    name: 'getOrganizerFormResponseDetail',
    payload: GetOrganizerFormResponseDetailCallableRequest(
      organizerId: organizerId,
      responseId: responseId,
    ).toJson(),
    action: 'load organizer form response',
    parse: HostFormResponseDetail.fromCallableData,
  );

  Future<HostFormAnalytics> getAnalytics({
    required String organizerId,
    required String formId,
    String? versionId,
  }) => _call(
    name: 'getOrganizerFormAnalytics',
    payload: GetOrganizerFormAnalyticsCallableRequest(
      organizerId: organizerId,
      formId: formId,
      versionId: versionId,
    ).toJson(),
    action: 'load organizer form analytics',
    parse: HostFormAnalytics.fromCallableData,
  );

  Future<HostFormExportReceipt> requestExport({
    required String organizerId,
    required String formId,
    required String requestId,
    required HostFormExportFormat format,
    Set<HostFormResponseStatus> statuses = const {},
    String? versionId,
    DateTime? from,
    DateTime? to,
  }) => _call(
    name: 'requestOrganizerFormExport',
    payload: RequestOrganizerFormExportCallableRequest(
      organizerId: organizerId,
      formId: formId,
      requestId: requestId,
      format: format.name,
      statuses: statuses.map((value) => value.name).toList(),
      versionId: versionId,
      fromMillis: from?.millisecondsSinceEpoch,
      toMillis: to?.millisecondsSinceEpoch,
    ).toJson(),
    action: 'export organizer form responses',
    parse: HostFormExportReceipt.fromCallableData,
  );

  Future<HostFormConversionPreview> previewConversion({
    required String organizerId,
    required String responseId,
    required HostFormConversionKind kind,
    String? eventId,
    Map<String, Object?> overrides = const {},
  }) => _call(
    name: 'previewOrganizerFormConversion',
    payload: PreviewOrganizerFormConversionCallableRequest(
      organizerId: organizerId,
      responseId: responseId,
      kind: kind.name,
      eventId: eventId,
      overrides: overrides,
    ).toJson(),
    action: 'preview organizer form response conversion',
    parse: HostFormConversionPreview.fromCallableData,
  );

  Future<HostFormConversionReceipt> convertResponse({
    required String organizerId,
    required String responseId,
    required HostFormConversionKind kind,
    required String requestId,
    String? eventId,
    Map<String, Object?> overrides = const {},
  }) => _call(
    name: 'convertOrganizerFormResponse',
    payload: ConvertOrganizerFormResponseCallableRequest(
      organizerId: organizerId,
      responseId: responseId,
      kind: kind.name,
      eventId: eventId,
      overrides: overrides,
      requestId: requestId,
    ).toJson(),
    action: 'convert organizer form response',
    parse: HostFormConversionReceipt.fromCallableData,
  );

  Future<HostFormAutomationRule> saveAutomation({
    required String organizerId,
    required String formId,
    required String requestId,
    required String name,
    required bool enabled,
    required HostFormAutomationTrigger trigger,
    required List<Map<String, Object?>> actions,
    String? ruleId,
    int? expectedRevision,
    Map<String, Object?>? condition,
  }) => _call(
    name: 'createOrganizerFormAutomation',
    payload: CreateOrganizerFormAutomationCallableRequest(
      organizerId: organizerId,
      formId: formId,
      ruleId: ruleId,
      requestId: requestId,
      expectedRevision: expectedRevision,
      name: name,
      enabled: enabled,
      trigger: trigger.name,
      condition: condition,
      actions: actions,
    ).toJson(),
    action: 'save organizer form automation',
    parse: (data) =>
        HostFormAutomationRule.fromMap(_requiredMap(data, 'form automation')),
  );

  Future<HostFormAutomationRule> setAutomationEnabled({
    required String organizerId,
    required String ruleId,
    required int expectedRevision,
    required bool enabled,
  }) => _call(
    name: 'setOrganizerFormAutomationState',
    payload: SetOrganizerFormAutomationStateCallableRequest(
      organizerId: organizerId,
      ruleId: ruleId,
      expectedRevision: expectedRevision,
      enabled: enabled,
    ).toJson(),
    action: 'update organizer form automation',
    parse: (data) =>
        HostFormAutomationRule.fromMap(_requiredMap(data, 'form automation')),
  );

  Future<HostFormAutomationPage> listAutomations({
    required String organizerId,
    required String formId,
    String? ruleId,
    String? cursor,
    int limit = ReadLimitPolicy.historyPage,
  }) => _call(
    name: 'listOrganizerFormAutomationRuns',
    payload: ListOrganizerFormAutomationRunsCallableRequest(
      organizerId: organizerId,
      formId: formId,
      ruleId: ruleId,
      cursor: cursor,
      limit: limit.clamp(1, ReadLimitPolicy.historyPage).toInt(),
    ).toJson(),
    action: 'load organizer form automations',
    parse: HostFormAutomationPage.fromCallableData,
  );

  Future<T> _call<T>({
    required String name,
    required Map<String, Object?> payload,
    required String action,
    required T Function(Object?) parse,
  }) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable(name)
          .call<Object?>(payload);
      return parse(result.data);
    },
    context: BackendErrorContext(
      service: BackendService.functions,
      action: action,
      resource: name,
    ),
    mapper: mapMissingCallableAsUnavailable,
  );
}

// keepalive: one stateless callable facade is shared by every Forms route.
@Riverpod(keepAlive: true)
HostFormsRepository hostFormsRepository(Ref ref) =>
    HostFormsRepository(ref.watch(firebaseFunctionsProvider));

@riverpod
Future<List<HostFormTemplateSummary>> hostFormTemplates(
  Ref ref,
  String organizerId,
) => ref.read(hostFormsRepositoryProvider).listTemplates(organizerId);

@riverpod
Future<HostFormShareAssets> hostFormShareAssets(
  Ref ref, {
  required String organizerId,
  required String formId,
}) => ref
    .read(hostFormsRepositoryProvider)
    .getShareAssets(organizerId: organizerId, formId: formId);

Map<Object?, Object?> _requiredMap(Object? value, String label) {
  if (value is Map<Object?, Object?>) return value;
  throw FormatException('Invalid $label.');
}

List<Map<Object?, Object?>> _mapList(Object? value, String label) {
  if (value is! List<Object?>) throw FormatException('Invalid $label.');
  return value.map((item) => _requiredMap(item, label)).toList(growable: false);
}
