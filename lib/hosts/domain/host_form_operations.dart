import 'package:meta/meta.dart';

enum HostFormResponseStatus { submitted, withdrawn }

enum HostFormResponseIdentityKind {
  anonymous,
  emailVerified,
  phoneVerified,
  catchAccount,
}

enum HostFormDataOrigin {
  anonymous,
  respondentGranted,
  organizerAcquired,
  revoked,
}

enum HostFormExportFormat { csv, xlsx }

enum HostFormExportStatus { pending, running, completed, failed, expired }

enum HostFormConversionKind {
  crmContact,
  application,
  eventAttendeeProposal,
  followUp,
}

enum HostFormAutomationTrigger {
  responseSubmitted,
  responseWithdrawn,
  answerMatches,
}

enum HostFormAutomationActionKind {
  notifyTeam,
  addOrganizerTag,
  createCrmContact,
  addApplicationQueue,
  proposeEventAttendee,
  signedWebhook,
  campaignHandoff,
}

enum HostFormAutomationRunStatus {
  pending,
  running,
  succeeded,
  partiallyFailed,
  failed,
  skipped,
}

@immutable
class HostFormResponseListRequest {
  const HostFormResponseListRequest({
    required this.organizerId,
    this.formId,
    this.versionId,
    this.statuses = const {},
    this.identityKinds = const {},
    this.sourceLinkId,
    this.query,
    this.from,
    this.to,
    this.cursor,
    this.limit = 25,
  });

  final String organizerId;
  final String? formId;
  final String? versionId;
  final Set<HostFormResponseStatus> statuses;
  final Set<HostFormResponseIdentityKind> identityKinds;
  final String? sourceLinkId;
  final String? query;
  final DateTime? from;
  final DateTime? to;
  final String? cursor;
  final int limit;

  HostFormResponseListRequest copyWith({String? cursor}) =>
      HostFormResponseListRequest(
        organizerId: organizerId,
        formId: formId,
        versionId: versionId,
        statuses: statuses,
        identityKinds: identityKinds,
        sourceLinkId: sourceLinkId,
        query: query,
        from: from,
        to: to,
        cursor: cursor,
        limit: limit,
      );

  @override
  bool operator ==(Object other) =>
      other is HostFormResponseListRequest &&
      organizerId == other.organizerId &&
      formId == other.formId &&
      versionId == other.versionId &&
      _setEquals(statuses, other.statuses) &&
      _setEquals(identityKinds, other.identityKinds) &&
      sourceLinkId == other.sourceLinkId &&
      query == other.query &&
      from == other.from &&
      to == other.to &&
      cursor == other.cursor &&
      limit == other.limit;

  @override
  int get hashCode => Object.hash(
    organizerId,
    formId,
    versionId,
    Object.hashAllUnordered(statuses),
    Object.hashAllUnordered(identityKinds),
    sourceLinkId,
    query,
    from,
    to,
    cursor,
    limit,
  );
}

@immutable
class HostFormResponseIdentity {
  const HostFormResponseIdentity({
    required this.displayName,
    required this.email,
    required this.phoneE164,
    required this.origin,
  });

  factory HostFormResponseIdentity.fromMap(Map<Object?, Object?> map) =>
      HostFormResponseIdentity(
        displayName: _nullableString(map['displayName']),
        email: _nullableString(map['email']),
        phoneE164: _nullableString(map['phoneE164']),
        origin: _enumByName(
          HostFormDataOrigin.values,
          _requiredString(map, 'origin'),
        ),
      );

  final String? displayName;
  final String? email;
  final String? phoneE164;
  final HostFormDataOrigin origin;

  String? get primaryLabel => displayName ?? email ?? phoneE164;
}

@immutable
class HostFormResponseHighlight {
  const HostFormResponseHighlight({
    required this.questionId,
    required this.label,
    required this.answer,
  });

  factory HostFormResponseHighlight.fromMap(Map<Object?, Object?> map) =>
      HostFormResponseHighlight(
        questionId: _requiredString(map, 'questionId'),
        label: _requiredString(map, 'label'),
        answer: map['answer'],
      );

  final String questionId;
  final String label;
  final Object? answer;
}

@immutable
class HostFormResponseSummary {
  const HostFormResponseSummary({
    required this.responseId,
    required this.formId,
    required this.formTitle,
    required this.versionId,
    required this.version,
    required this.status,
    required this.identityKind,
    required this.identity,
    required this.sourceLinkId,
    required this.sourceLabel,
    required this.submittedAt,
    required this.withdrawnAt,
    required this.highlights,
    required this.conversionKinds,
  });

  factory HostFormResponseSummary.fromMap(Map<Object?, Object?> map) =>
      HostFormResponseSummary(
        responseId: _requiredString(map, 'responseId'),
        formId: _requiredString(map, 'formId'),
        formTitle: _requiredString(map, 'formTitle'),
        versionId: _requiredString(map, 'versionId'),
        version: _requiredInt(map, 'version'),
        status: _enumByName(
          HostFormResponseStatus.values,
          _requiredString(map, 'status'),
        ),
        identityKind: _enumByName(
          HostFormResponseIdentityKind.values,
          _requiredString(map, 'identityKind'),
        ),
        identity: HostFormResponseIdentity.fromMap(
          _requiredMap(map['identity'], 'response identity'),
        ),
        sourceLinkId: _nullableString(map['sourceLinkId']),
        sourceLabel: _nullableString(map['sourceLabel']),
        submittedAt: _dateTime(map, 'submittedAtMillis'),
        withdrawnAt: _nullableDateTime(map['withdrawnAtMillis']),
        highlights: _mapList(
          map['highlights'],
          'response highlights',
        ).map(HostFormResponseHighlight.fromMap).toList(growable: false),
        conversionKinds: _stringList(map['conversionKinds'])
            .map((value) => _enumByName(HostFormConversionKind.values, value))
            .toSet(),
      );

  final String responseId;
  final String formId;
  final String formTitle;
  final String versionId;
  final int version;
  final HostFormResponseStatus status;
  final HostFormResponseIdentityKind identityKind;
  final HostFormResponseIdentity identity;
  final String? sourceLinkId;
  final String? sourceLabel;
  final DateTime submittedAt;
  final DateTime? withdrawnAt;
  final List<HostFormResponseHighlight> highlights;
  final Set<HostFormConversionKind> conversionKinds;
}

@immutable
class HostFormResponsePage {
  const HostFormResponsePage({
    required this.organizerId,
    required this.items,
    required this.nextCursor,
  });

  factory HostFormResponsePage.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'form responses');
    return HostFormResponsePage(
      organizerId: _requiredString(map, 'organizerId'),
      items: _mapList(
        map['items'],
        'form responses',
      ).map(HostFormResponseSummary.fromMap).toList(growable: false),
      nextCursor: _nullableString(map['nextCursor']),
    );
  }

  final String organizerId;
  final List<HostFormResponseSummary> items;
  final String? nextCursor;
}

@immutable
class HostFormAssetDownload {
  const HostFormAssetDownload({
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.downloadUrl,
    required this.expiresAt,
  });

  factory HostFormAssetDownload.fromMap(Map<Object?, Object?> map) =>
      HostFormAssetDownload(
        fileName: _requiredString(map, 'fileName'),
        contentType: _requiredString(map, 'contentType'),
        sizeBytes: _requiredInt(map, 'sizeBytes'),
        downloadUrl: _requiredString(map, 'downloadUrl'),
        expiresAt: _dateTime(map, 'expiresAtMillis'),
      );

  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String downloadUrl;
  final DateTime expiresAt;
}

@immutable
class HostFormResponseAnswer {
  const HostFormResponseAnswer({
    required this.questionId,
    required this.key,
    required this.label,
    required this.kind,
    required this.privacyClass,
    required this.hostPresentation,
    required this.answer,
    required this.origin,
    required this.assetDownloads,
  });

  factory HostFormResponseAnswer.fromMap(Map<Object?, Object?> map) =>
      HostFormResponseAnswer(
        questionId: _requiredString(map, 'questionId'),
        key: _requiredString(map, 'key'),
        label: _requiredString(map, 'label'),
        kind: _requiredString(map, 'kind'),
        privacyClass: _requiredString(map, 'privacyClass'),
        hostPresentation: _requiredString(map, 'hostPresentation'),
        answer: map['answer'],
        origin: _enumByName(
          HostFormDataOrigin.values,
          _requiredString(map, 'origin'),
        ),
        assetDownloads: _mapList(
          map['assetDownloads'],
          'form response assets',
        ).map(HostFormAssetDownload.fromMap).toList(growable: false),
      );

  final String questionId;
  final String key;
  final String label;
  final String kind;
  final String privacyClass;
  final String hostPresentation;
  final Object? answer;
  final HostFormDataOrigin origin;
  final List<HostFormAssetDownload> assetDownloads;
}

@immutable
class HostFormResponseDetail {
  const HostFormResponseDetail({
    required this.response,
    required this.answers,
    required this.consentVersion,
    required this.completionMillis,
  });

  factory HostFormResponseDetail.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'form response detail');
    return HostFormResponseDetail(
      response: HostFormResponseSummary.fromMap(
        _requiredMap(map['response'], 'form response'),
      ),
      answers: _mapList(
        map['answers'],
        'form response answers',
      ).map(HostFormResponseAnswer.fromMap).toList(growable: false),
      consentVersion: _requiredString(map, 'consentVersion'),
      completionMillis: _requiredInt(map, 'completionMillis'),
    );
  }

  final HostFormResponseSummary response;
  final List<HostFormResponseAnswer> answers;
  final String consentVersion;
  final int completionMillis;
}

@immutable
class HostFormQuestionAggregate {
  const HostFormQuestionAggregate({
    required this.questionId,
    required this.label,
    required this.kind,
    required this.privacyClass,
    required this.responseCount,
    required this.choiceCounts,
    required this.numericCount,
    required this.numericSum,
    required this.numericMin,
    required this.numericMax,
  });

  factory HostFormQuestionAggregate.fromMap(Map<Object?, Object?> map) =>
      HostFormQuestionAggregate(
        questionId: _requiredString(map, 'questionId'),
        label: _requiredString(map, 'label'),
        kind: _requiredString(map, 'kind'),
        privacyClass: _requiredString(map, 'privacyClass'),
        responseCount: _requiredInt(map, 'responseCount'),
        choiceCounts: _mapList(map['choiceCounts'], 'choice counts')
            .map((item) => HostFormChoiceCount.fromMap(item))
            .toList(growable: false),
        numericCount: _requiredInt(map, 'numericCount'),
        numericSum: _requiredNum(map, 'numericSum'),
        numericMin: _nullableNum(map['numericMin']),
        numericMax: _nullableNum(map['numericMax']),
      );

  final String questionId;
  final String label;
  final String kind;
  final String privacyClass;
  final int responseCount;
  final List<HostFormChoiceCount> choiceCounts;
  final int numericCount;
  final num numericSum;
  final num? numericMin;
  final num? numericMax;
}

@immutable
class HostFormChoiceCount {
  const HostFormChoiceCount({
    required this.value,
    required this.label,
    required this.count,
  });

  factory HostFormChoiceCount.fromMap(Map<Object?, Object?> map) =>
      HostFormChoiceCount(
        value: map['value'],
        label: _requiredString(map, 'label'),
        count: _requiredInt(map, 'count'),
      );

  final Object? value;
  final String label;
  final int count;
}

@immutable
class HostFormSourceFunnel {
  const HostFormSourceFunnel({
    required this.label,
    required this.opens,
    required this.starts,
    required this.submissions,
  });

  factory HostFormSourceFunnel.fromMap(Map<Object?, Object?> map) =>
      HostFormSourceFunnel(
        label: _requiredString(map, 'label'),
        opens: _requiredInt(map, 'opens'),
        starts: _requiredInt(map, 'starts'),
        submissions: _requiredInt(map, 'submissions'),
      );

  final String label;
  final int opens;
  final int starts;
  final int submissions;
}

@immutable
class HostFormAnalytics {
  const HostFormAnalytics({
    required this.formId,
    required this.versionId,
    required this.version,
    required this.opens,
    required this.starts,
    required this.submissions,
    required this.withdrawals,
    required this.completionRate,
    required this.medianCompletionMillis,
    required this.questions,
    required this.sources,
    required this.privacyThreshold,
  });

  factory HostFormAnalytics.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'form analytics');
    return HostFormAnalytics(
      formId: _requiredString(map, 'formId'),
      versionId: _requiredString(map, 'versionId'),
      version: _requiredInt(map, 'version'),
      opens: _requiredInt(map, 'opens'),
      starts: _requiredInt(map, 'starts'),
      submissions: _requiredInt(map, 'submissions'),
      withdrawals: _requiredInt(map, 'withdrawals'),
      completionRate: _requiredNum(map, 'completionRate').toDouble(),
      medianCompletionMillis: _nullableInt(map['medianCompletionMillis']),
      questions: _mapList(
        map['questions'],
        'question analytics',
      ).map(HostFormQuestionAggregate.fromMap).toList(growable: false),
      sources: _mapList(
        map['sources'],
        'source analytics',
      ).map(HostFormSourceFunnel.fromMap).toList(growable: false),
      privacyThreshold: _requiredInt(map, 'privacyThreshold'),
    );
  }

  final String formId;
  final String versionId;
  final int version;
  final int opens;
  final int starts;
  final int submissions;
  final int withdrawals;
  final double completionRate;
  final int? medianCompletionMillis;
  final List<HostFormQuestionAggregate> questions;
  final List<HostFormSourceFunnel> sources;
  final int privacyThreshold;
}

@immutable
class HostFormExportReceipt {
  const HostFormExportReceipt({
    required this.exportId,
    required this.status,
    required this.format,
    required this.rowCount,
    required this.downloadUrl,
    required this.expiresAt,
    required this.errorMessage,
  });

  factory HostFormExportReceipt.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'form export');
    return HostFormExportReceipt(
      exportId: _requiredString(map, 'exportId'),
      status: _enumByName(
        HostFormExportStatus.values,
        _requiredString(map, 'status'),
      ),
      format: _enumByName(
        HostFormExportFormat.values,
        _requiredString(map, 'format'),
      ),
      rowCount: _requiredInt(map, 'rowCount'),
      downloadUrl: _nullableString(map['downloadUrl']),
      expiresAt: _dateTime(map, 'expiresAtMillis'),
      errorMessage: _nullableString(map['errorMessage']),
    );
  }

  final String exportId;
  final HostFormExportStatus status;
  final HostFormExportFormat format;
  final int rowCount;
  final String? downloadUrl;
  final DateTime expiresAt;
  final String? errorMessage;
}

@immutable
class HostFormConversionPreview {
  const HostFormConversionPreview({
    required this.kind,
    required this.allowed,
    required this.fields,
    required this.warnings,
    required this.existingResultId,
  });

  factory HostFormConversionPreview.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'form conversion preview');
    return HostFormConversionPreview(
      kind: _enumByName(
        HostFormConversionKind.values,
        _requiredString(map, 'kind'),
      ),
      allowed: _requiredBool(map, 'allowed'),
      fields: _mapList(
        map['fields'],
        'conversion fields',
      ).map(HostFormConversionField.fromMap).toList(growable: false),
      warnings: _stringList(map['warnings']),
      existingResultId: _nullableString(map['existingResultId']),
    );
  }

  final HostFormConversionKind kind;
  final bool allowed;
  final List<HostFormConversionField> fields;
  final List<String> warnings;
  final String? existingResultId;
}

@immutable
class HostFormConversionField {
  const HostFormConversionField({
    required this.destinationField,
    required this.label,
    required this.value,
    required this.origin,
    required this.conflict,
  });

  factory HostFormConversionField.fromMap(Map<Object?, Object?> map) =>
      HostFormConversionField(
        destinationField: _requiredString(map, 'destinationField'),
        label: _requiredString(map, 'label'),
        value: map['value'],
        origin: _requiredString(map, 'origin'),
        conflict: _nullableString(map['conflict']),
      );

  final String destinationField;
  final String label;
  final Object? value;
  final String origin;
  final String? conflict;
}

@immutable
class HostFormConversionReceipt {
  const HostFormConversionReceipt({
    required this.receiptId,
    required this.kind,
    required this.status,
    required this.resultId,
  });

  factory HostFormConversionReceipt.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'form conversion receipt');
    return HostFormConversionReceipt(
      receiptId: _requiredString(map, 'receiptId'),
      kind: _enumByName(
        HostFormConversionKind.values,
        _requiredString(map, 'kind'),
      ),
      status: _requiredString(map, 'status'),
      resultId: _nullableString(map['resultId']),
    );
  }

  final String receiptId;
  final HostFormConversionKind kind;
  final String status;
  final String? resultId;
}

@immutable
class HostFormAutomationAction {
  const HostFormAutomationAction({
    required this.actionId,
    required this.kind,
    required this.tagId,
    required this.eventId,
    required this.webhookUrl,
    required this.webhookSecretConfigured,
    required this.channel,
  });

  factory HostFormAutomationAction.fromMap(Map<Object?, Object?> map) =>
      HostFormAutomationAction(
        actionId: _requiredString(map, 'actionId'),
        kind: _enumByName(
          HostFormAutomationActionKind.values,
          _requiredString(map, 'kind'),
        ),
        tagId: _nullableString(map['tagId']),
        eventId: _nullableString(map['eventId']),
        webhookUrl: _nullableString(map['webhookUrl']),
        webhookSecretConfigured: _requiredBool(map, 'webhookSecretConfigured'),
        channel: _nullableString(map['channel']),
      );

  final String actionId;
  final HostFormAutomationActionKind kind;
  final String? tagId;
  final String? eventId;
  final String? webhookUrl;
  final bool webhookSecretConfigured;
  final String? channel;
}

@immutable
class HostFormAutomationRule {
  const HostFormAutomationRule({
    required this.ruleId,
    required this.organizerId,
    required this.formId,
    required this.name,
    required this.enabled,
    required this.revision,
    required this.trigger,
    required this.condition,
    required this.actions,
    required this.updatedAt,
  });

  factory HostFormAutomationRule.fromMap(Map<Object?, Object?> map) =>
      HostFormAutomationRule(
        ruleId: _requiredString(map, 'ruleId'),
        organizerId: _requiredString(map, 'organizerId'),
        formId: _requiredString(map, 'formId'),
        name: _requiredString(map, 'name'),
        enabled: _requiredBool(map, 'enabled'),
        revision: _requiredInt(map, 'revision'),
        trigger: _enumByName(
          HostFormAutomationTrigger.values,
          _requiredString(map, 'trigger'),
        ),
        condition: map['condition'] == null
            ? null
            : _requiredMap(map['condition'], 'automation condition'),
        actions: _mapList(
          map['actions'],
          'automation actions',
        ).map(HostFormAutomationAction.fromMap).toList(growable: false),
        updatedAt: _dateTime(map, 'updatedAtMillis'),
      );

  final String ruleId;
  final String organizerId;
  final String formId;
  final String name;
  final bool enabled;
  final int revision;
  final HostFormAutomationTrigger trigger;
  final Map<Object?, Object?>? condition;
  final List<HostFormAutomationAction> actions;
  final DateTime updatedAt;
}

@immutable
class HostFormAutomationRun {
  const HostFormAutomationRun({
    required this.runId,
    required this.ruleId,
    required this.ruleRevision,
    required this.responseId,
    required this.eventKind,
    required this.status,
    required this.attemptCount,
    required this.actionResults,
    required this.errorMessage,
    required this.createdAt,
    required this.completedAt,
  });

  factory HostFormAutomationRun.fromMap(Map<Object?, Object?> map) =>
      HostFormAutomationRun(
        runId: _requiredString(map, 'runId'),
        ruleId: _requiredString(map, 'ruleId'),
        ruleRevision: _requiredInt(map, 'ruleRevision'),
        responseId: _requiredString(map, 'responseId'),
        eventKind: _requiredString(map, 'eventKind'),
        status: _enumByName(
          HostFormAutomationRunStatus.values,
          _requiredString(map, 'status'),
        ),
        attemptCount: _requiredInt(map, 'attemptCount'),
        actionResults: _mapList(
          map['actionResults'],
          'automation action results',
        ),
        errorMessage: _nullableString(map['errorMessage']),
        createdAt: _dateTime(map, 'createdAtMillis'),
        completedAt: _nullableDateTime(map['completedAtMillis']),
      );

  final String runId;
  final String ruleId;
  final int ruleRevision;
  final String responseId;
  final String eventKind;
  final HostFormAutomationRunStatus status;
  final int attemptCount;
  final List<Map<Object?, Object?>> actionResults;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
}

@immutable
class HostFormAutomationPage {
  const HostFormAutomationPage({
    required this.rules,
    required this.runs,
    required this.nextCursor,
  });

  factory HostFormAutomationPage.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'form automations');
    return HostFormAutomationPage(
      rules: _mapList(
        map['rules'],
        'automation rules',
      ).map(HostFormAutomationRule.fromMap).toList(growable: false),
      runs: _mapList(
        map['runs'],
        'automation runs',
      ).map(HostFormAutomationRun.fromMap).toList(growable: false),
      nextCursor: _nullableString(map['nextCursor']),
    );
  }

  final List<HostFormAutomationRule> rules;
  final List<HostFormAutomationRun> runs;
  final String? nextCursor;
}

bool _setEquals<T>(Set<T> left, Set<T> right) =>
    left.length == right.length && left.containsAll(right);

Map<Object?, Object?> _requiredMap(Object? value, String label) {
  if (value is Map<Object?, Object?>) return value;
  throw FormatException('Invalid $label.');
}

List<Map<Object?, Object?>> _mapList(Object? value, String label) {
  if (value is! List<Object?>) throw FormatException('Invalid $label.');
  return value.map((item) => _requiredMap(item, label)).toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value is! List<Object?> || value.any((item) => item is! String)) {
    throw const FormatException('Invalid string list.');
  }
  return value.cast<String>();
}

String _requiredString(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Missing $key.');
}

String? _nullableString(Object? value) =>
    value == null ? null : value as String;

int _requiredInt(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is int) return value;
  throw FormatException('Missing $key.');
}

int? _nullableInt(Object? value) => value == null ? null : value as int;

num _requiredNum(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is num) return value;
  throw FormatException('Missing $key.');
}

num? _nullableNum(Object? value) => value == null ? null : value as num;

bool _requiredBool(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is bool) return value;
  throw FormatException('Missing $key.');
}

DateTime _dateTime(Map<Object?, Object?> map, String key) =>
    DateTime.fromMillisecondsSinceEpoch(_requiredInt(map, key));

DateTime? _nullableDateTime(Object? value) =>
    value == null ? null : DateTime.fromMillisecondsSinceEpoch(value as int);

T _enumByName<T extends Enum>(
  Iterable<T> values,
  String name, [
  String? label,
]) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Invalid ${label ?? 'enum'}: $name.');
}
