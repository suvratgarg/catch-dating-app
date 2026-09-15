import 'package:catch_dating_app/hosts/domain/forms/form_operation_fields.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_conversion.dart';
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
      formOperationSetEquals(statuses, other.statuses) &&
      formOperationSetEquals(identityKinds, other.identityKinds) &&
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
        displayName: formOperationNullableString(map['displayName']),
        email: formOperationNullableString(map['email']),
        phoneE164: formOperationNullableString(map['phoneE164']),
        origin: formOperationEnumByName(
          HostFormDataOrigin.values,
          formOperationRequiredString(map, 'origin'),
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
        questionId: formOperationRequiredString(map, 'questionId'),
        label: formOperationRequiredString(map, 'label'),
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
        responseId: formOperationRequiredString(map, 'responseId'),
        formId: formOperationRequiredString(map, 'formId'),
        formTitle: formOperationRequiredString(map, 'formTitle'),
        versionId: formOperationRequiredString(map, 'versionId'),
        version: formOperationRequiredInt(map, 'version'),
        status: formOperationEnumByName(
          HostFormResponseStatus.values,
          formOperationRequiredString(map, 'status'),
        ),
        identityKind: formOperationEnumByName(
          HostFormResponseIdentityKind.values,
          formOperationRequiredString(map, 'identityKind'),
        ),
        identity: HostFormResponseIdentity.fromMap(
          formOperationRequiredMap(map['identity'], 'response identity'),
        ),
        sourceLinkId: formOperationNullableString(map['sourceLinkId']),
        sourceLabel: formOperationNullableString(map['sourceLabel']),
        submittedAt: formOperationDateTime(map, 'submittedAtMillis'),
        withdrawnAt: formOperationNullableDateTime(map['withdrawnAtMillis']),
        highlights: formOperationMapList(
          map['highlights'],
          'response highlights',
        ).map(HostFormResponseHighlight.fromMap).toList(growable: false),
        conversionKinds: formOperationStringList(map['conversionKinds'])
            .map(
              (value) =>
                  formOperationEnumByName(HostFormConversionKind.values, value),
            )
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
    final map = formOperationRequiredMap(data, 'form responses');
    return HostFormResponsePage(
      organizerId: formOperationRequiredString(map, 'organizerId'),
      items: formOperationMapList(
        map['items'],
        'form responses',
      ).map(HostFormResponseSummary.fromMap).toList(growable: false),
      nextCursor: formOperationNullableString(map['nextCursor']),
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
        fileName: formOperationRequiredString(map, 'fileName'),
        contentType: formOperationRequiredString(map, 'contentType'),
        sizeBytes: formOperationRequiredInt(map, 'sizeBytes'),
        downloadUrl: formOperationRequiredString(map, 'downloadUrl'),
        expiresAt: formOperationDateTime(map, 'expiresAtMillis'),
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
        questionId: formOperationRequiredString(map, 'questionId'),
        key: formOperationRequiredString(map, 'key'),
        label: formOperationRequiredString(map, 'label'),
        kind: formOperationRequiredString(map, 'kind'),
        privacyClass: formOperationRequiredString(map, 'privacyClass'),
        hostPresentation: formOperationRequiredString(map, 'hostPresentation'),
        answer: map['answer'],
        origin: formOperationEnumByName(
          HostFormDataOrigin.values,
          formOperationRequiredString(map, 'origin'),
        ),
        assetDownloads: formOperationMapList(
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
    this.applicationId,
    this.contactId,
    required this.answers,
    required this.consentVersion,
    required this.completionMillis,
  });

  factory HostFormResponseDetail.fromCallableData(Object? data) {
    final map = formOperationRequiredMap(data, 'form response detail');
    return HostFormResponseDetail(
      applicationId: formOperationNullableString(map['applicationId']),
      contactId: formOperationNullableString(map['contactId']),
      response: HostFormResponseSummary.fromMap(
        formOperationRequiredMap(map['response'], 'form response'),
      ),
      answers: formOperationMapList(
        map['answers'],
        'form response answers',
      ).map(HostFormResponseAnswer.fromMap).toList(growable: false),
      consentVersion: formOperationRequiredString(map, 'consentVersion'),
      completionMillis: formOperationRequiredInt(map, 'completionMillis'),
    );
  }

  final HostFormResponseSummary response;
  final String? applicationId;
  final String? contactId;
  final List<HostFormResponseAnswer> answers;
  final String consentVersion;
  final int completionMillis;
}
