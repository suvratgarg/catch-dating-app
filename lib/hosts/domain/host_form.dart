import 'package:meta/meta.dart';

enum HostFormPurpose {
  application,
  registration,
  intake,
  waiver,
  feedback,
  survey,
}

enum HostFormLifecycleStatus { draft, published, paused, archived }

enum HostFormIdentityPolicy {
  anonymous,
  emailVerified,
  phoneVerified,
  emailOrPhoneVerified,
  catchAccount,
}

enum HostFormTargetKind { organizer, event, campaign }

enum HostFormQuestionKind {
  shortText,
  longText,
  singleChoice,
  multiChoice,
  date,
  phone,
  email,
  url,
  number,
  boolean,
  file,
  acknowledgement,
  signature,
}

enum HostFormValidationSeverity { error, warning }

enum HostFormLifecycleAction { pause, resume, archive }

@immutable
class HostFormShareAssets {
  const HostFormShareAssets({
    required this.canonicalUrl,
    required this.embedUrl,
    required this.embedSnippet,
  });

  factory HostFormShareAssets.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'form share assets');
    return HostFormShareAssets(
      canonicalUrl: _requiredString(map, 'canonicalUrl'),
      embedUrl: _requiredString(map, 'embedUrl'),
      embedSnippet: _requiredString(map, 'embedSnippet'),
    );
  }

  final String canonicalUrl;
  final String embedUrl;
  final String embedSnippet;
}

@immutable
class HostFormShareLink {
  const HostFormShareLink({
    required this.linkId,
    required this.label,
    required this.source,
    required this.sourceToken,
    required this.url,
  });

  factory HostFormShareLink.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'form share link');
    return HostFormShareLink(
      linkId: _requiredString(map, 'linkId'),
      label: _requiredString(map, 'label'),
      source: _nullableString(map['source']),
      sourceToken: _requiredString(map, 'sourceToken'),
      url: _requiredString(map, 'url'),
    );
  }

  final String linkId;
  final String label;
  final String? source;
  final String sourceToken;
  final String url;
}

@immutable
class HostFormListRequest {
  const HostFormListRequest({
    required this.organizerId,
    this.statuses = const {},
    this.purposes = const {},
    this.query,
    this.cursor,
    this.limit = 25,
  });

  final String organizerId;
  final Set<HostFormLifecycleStatus> statuses;
  final Set<HostFormPurpose> purposes;
  final String? query;
  final String? cursor;
  final int limit;

  HostFormListRequest copyWith({String? cursor}) => HostFormListRequest(
    organizerId: organizerId,
    statuses: statuses,
    purposes: purposes,
    query: query,
    cursor: cursor,
    limit: limit,
  );

  @override
  bool operator ==(Object other) =>
      other is HostFormListRequest &&
      organizerId == other.organizerId &&
      _setEquals(statuses, other.statuses) &&
      _setEquals(purposes, other.purposes) &&
      query == other.query &&
      cursor == other.cursor &&
      limit == other.limit;

  @override
  int get hashCode => Object.hash(
    organizerId,
    Object.hashAllUnordered(statuses),
    Object.hashAllUnordered(purposes),
    query,
    cursor,
    limit,
  );
}

@immutable
class HostFormSummary {
  const HostFormSummary({
    required this.organizerId,
    required this.formId,
    required this.title,
    required this.description,
    required this.purpose,
    required this.status,
    required this.templateId,
    required this.publicFormId,
    required this.defaultTargetKind,
    required this.defaultTargetId,
    required this.activeVersionId,
    required this.draftRevision,
    required this.publishedVersion,
    required this.submittedResponseCount,
    required this.updatedAt,
    required this.publishedAt,
    required this.lastResponseAt,
  });

  factory HostFormSummary.fromMap(Map<Object?, Object?> map) => HostFormSummary(
    organizerId: _requiredString(map, 'organizerId'),
    formId: _requiredString(map, 'formId'),
    title: _requiredString(map, 'title'),
    description: _nullableString(map['description']),
    purpose: _enumByName(
      HostFormPurpose.values,
      _requiredString(map, 'purpose'),
      'form purpose',
    ),
    status: _enumByName(
      HostFormLifecycleStatus.values,
      _requiredString(map, 'status'),
      'form lifecycle',
    ),
    templateId: _nullableString(map['templateId']),
    publicFormId: _requiredString(map, 'publicFormId'),
    defaultTargetKind: _enumByName(
      HostFormTargetKind.values,
      _requiredString(map, 'defaultTargetKind'),
      'form target kind',
    ),
    defaultTargetId: _nullableString(map['defaultTargetId']),
    activeVersionId: _nullableString(map['activeVersionId']),
    draftRevision: _requiredInt(map, 'draftRevision'),
    publishedVersion: _requiredInt(map, 'publishedVersion'),
    submittedResponseCount: _requiredInt(map, 'submittedResponseCount'),
    updatedAt: _dateTimeFromMillis(map, 'updatedAtMillis'),
    publishedAt: _nullableDateTimeFromMillis(map['publishedAtMillis']),
    lastResponseAt: _nullableDateTimeFromMillis(map['lastResponseAtMillis']),
  );

  final String organizerId;
  final String formId;
  final String title;
  final String? description;
  final HostFormPurpose purpose;
  final HostFormLifecycleStatus status;
  final String? templateId;
  final String publicFormId;
  final HostFormTargetKind defaultTargetKind;
  final String? defaultTargetId;
  final String? activeVersionId;
  final int draftRevision;
  final int publishedVersion;
  final int submittedResponseCount;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final DateTime? lastResponseAt;

  bool get canDeleteDraft =>
      status == HostFormLifecycleStatus.draft && publishedVersion == 0;
  bool get canPublish => status != HostFormLifecycleStatus.archived;
  bool get canPause => status == HostFormLifecycleStatus.published;
  bool get canResume => status == HostFormLifecycleStatus.paused;
}

@immutable
class HostFormPage {
  const HostFormPage({
    required this.organizerId,
    required this.items,
    required this.nextCursor,
  });

  factory HostFormPage.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer forms');
    return HostFormPage(
      organizerId: _requiredString(map, 'organizerId'),
      items: _mapList(
        map['items'],
        'organizer forms',
      ).map(HostFormSummary.fromMap).toList(growable: false),
      nextCursor: _nullableString(map['nextCursor']),
    );
  }

  final String organizerId;
  final List<HostFormSummary> items;
  final String? nextCursor;
}

@immutable
class HostFormTemplateSummary {
  const HostFormTemplateSummary({
    required this.templateId,
    required this.version,
    required this.title,
    required this.description,
    required this.purpose,
    required this.identityPolicy,
    required this.sectionCount,
    required this.questionCount,
  });

  factory HostFormTemplateSummary.fromMap(Map<Object?, Object?> map) =>
      HostFormTemplateSummary(
        templateId: _requiredString(map, 'templateId'),
        version: _requiredInt(map, 'version'),
        title: _requiredString(map, 'title'),
        description: _nullableString(map['description']),
        purpose: _enumByName(
          HostFormPurpose.values,
          _requiredString(map, 'purpose'),
          'form purpose',
        ),
        identityPolicy: _enumByName(
          HostFormIdentityPolicy.values,
          _requiredString(map, 'identityPolicy'),
          'form identity policy',
        ),
        sectionCount: _requiredInt(map, 'sectionCount'),
        questionCount: _requiredInt(map, 'questionCount'),
      );

  final String templateId;
  final int version;
  final String title;
  final String? description;
  final HostFormPurpose purpose;
  final HostFormIdentityPolicy identityPolicy;
  final int sectionCount;
  final int questionCount;
}

@immutable
class HostFormValidationIssue {
  const HostFormValidationIssue({
    required this.code,
    required this.path,
    required this.message,
    required this.severity,
  });

  factory HostFormValidationIssue.fromMap(Map<Object?, Object?> map) =>
      HostFormValidationIssue(
        code: _requiredString(map, 'code'),
        path: _requiredString(map, 'path'),
        message: _requiredString(map, 'message'),
        severity: _enumByName(
          HostFormValidationSeverity.values,
          _requiredString(map, 'severity'),
          'validation severity',
        ),
      );

  final String code;
  final String path;
  final String message;
  final HostFormValidationSeverity severity;
}

@immutable
class HostFormEditor {
  const HostFormEditor({
    required this.form,
    required this.definition,
    required this.validationIssues,
  });

  factory HostFormEditor.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'organizer form editor');
    return HostFormEditor(
      form: HostFormSummary.fromMap(
        _requiredMap(map['form'], 'organizer form summary'),
      ),
      definition: HostFormDefinition.fromMap(
        _requiredMap(map['definition'], 'organizer form definition'),
      ),
      validationIssues: _mapList(
        map['validationIssues'],
        'form validation issues',
      ).map(HostFormValidationIssue.fromMap).toList(growable: false),
    );
  }

  final HostFormSummary form;
  final HostFormDefinition definition;
  final List<HostFormValidationIssue> validationIssues;

  HostFormEditor copyWith({
    HostFormSummary? form,
    HostFormDefinition? definition,
    List<HostFormValidationIssue>? validationIssues,
  }) => HostFormEditor(
    form: form ?? this.form,
    definition: definition ?? this.definition,
    validationIssues: validationIssues ?? this.validationIssues,
  );
}

@immutable
class HostFormDefinition {
  HostFormDefinition._(Map<String, Object?> json)
    : _json = Map.unmodifiable(_deepStringMap(json));

  factory HostFormDefinition.fromMap(Map<Object?, Object?> map) =>
      HostFormDefinition._(_deepStringMap(map));

  final Map<String, Object?> _json;

  String get title => _stringValue(_json['title']);
  String? get description => _nullableString(_json['description']);
  HostFormPurpose get purpose => _enumByName(
    HostFormPurpose.values,
    _stringValue(_json['purpose']),
    'form purpose',
  );
  HostFormIdentityPolicy get identityPolicy => _enumByName(
    HostFormIdentityPolicy.values,
    _stringValue(_json['identityPolicy']),
    'form identity policy',
  );
  List<HostFormSection> get sections => _jsonList(_json['sections'])
      .map((item) => HostFormSection._(_deepStringMap(item)))
      .toList(growable: false);
  String get completionTitle =>
      _stringValue(_deepStringMap(_json['completion'])['title']);
  String? get completionMessage =>
      _nullableString(_deepStringMap(_json['completion'])['message']);

  Map<String, Object?> toJson() => _deepStringMap(_json);

  HostFormDefinition copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    HostFormPurpose? purpose,
    HostFormIdentityPolicy? identityPolicy,
    String? completionTitle,
    String? completionMessage,
  }) {
    final next = toJson();
    if (title != null) next['title'] = title;
    if (description != null || clearDescription) {
      next['description'] = clearDescription ? null : description;
    }
    if (purpose != null) next['purpose'] = purpose.name;
    if (identityPolicy != null) {
      next['identityPolicy'] = identityPolicy.name;
    }
    if (completionTitle != null || completionMessage != null) {
      final completion = _deepStringMap(next['completion']);
      if (completionTitle != null) completion['title'] = completionTitle;
      if (completionMessage != null) {
        completion['message'] = completionMessage;
      }
      next['completion'] = completion;
    }
    return HostFormDefinition._(next);
  }

  HostFormDefinition replaceSection(int index, HostFormSection section) {
    final next = toJson();
    final sections = _jsonList(next['sections']);
    sections[index] = section.toJson();
    next['sections'] = sections;
    return HostFormDefinition._(next);
  }

  HostFormDefinition addSection(HostFormSection section) {
    final next = toJson();
    final sections = _jsonList(next['sections'])..add(section.toJson());
    next['sections'] = sections;
    return HostFormDefinition._(next);
  }

  HostFormDefinition removeSection(int index) {
    final next = toJson();
    final sections = _jsonList(next['sections'])..removeAt(index);
    next['sections'] = sections;
    return HostFormDefinition._(next);
  }

  HostFormDefinition moveSection(int oldIndex, int newIndex) {
    final next = toJson();
    final sections = _jsonList(next['sections']);
    final section = sections.removeAt(oldIndex);
    sections.insert(newIndex, section);
    next['sections'] = sections;
    return HostFormDefinition._(next);
  }
}

@immutable
class HostFormSection {
  HostFormSection._(Map<String, Object?> json)
    : _json = Map.unmodifiable(_deepStringMap(json));

  factory HostFormSection.create({required String sectionId, String? title}) =>
      HostFormSection._({
        'sectionId': sectionId,
        'title': title ?? 'New section',
        'description': null,
        'pageBreak': false,
        'questions': const <Object?>[],
      });

  final Map<String, Object?> _json;

  String get sectionId => _stringValue(_json['sectionId']);
  String get title => _stringValue(_json['title']);
  String? get description => _nullableString(_json['description']);
  bool get pageBreak => _json['pageBreak'] == true;
  List<HostFormQuestion> get questions => _jsonList(_json['questions'])
      .map((item) => HostFormQuestion._(_deepStringMap(item)))
      .toList(growable: false);

  Map<String, Object?> toJson() => _deepStringMap(_json);

  HostFormSection copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    bool? pageBreak,
  }) {
    final next = toJson();
    if (title != null) next['title'] = title;
    if (description != null || clearDescription) {
      next['description'] = clearDescription ? null : description;
    }
    if (pageBreak != null) next['pageBreak'] = pageBreak;
    return HostFormSection._(next);
  }

  HostFormSection addQuestion(HostFormQuestion question) {
    final next = toJson();
    final questions = _jsonList(next['questions'])..add(question.toJson());
    next['questions'] = questions;
    return HostFormSection._(next);
  }

  HostFormSection replaceQuestion(int index, HostFormQuestion question) {
    final next = toJson();
    final questions = _jsonList(next['questions']);
    questions[index] = question.toJson();
    next['questions'] = questions;
    return HostFormSection._(next);
  }

  HostFormSection removeQuestion(int index) {
    final next = toJson();
    final questions = _jsonList(next['questions'])..removeAt(index);
    next['questions'] = questions;
    return HostFormSection._(next);
  }

  HostFormSection moveQuestion(int oldIndex, int newIndex) {
    final next = toJson();
    final questions = _jsonList(next['questions']);
    final question = questions.removeAt(oldIndex);
    questions.insert(newIndex, question);
    next['questions'] = questions;
    return HostFormSection._(next);
  }
}

@immutable
class HostFormQuestion {
  HostFormQuestion._(Map<String, Object?> json)
    : _json = Map.unmodifiable(_deepStringMap(json));

  factory HostFormQuestion.create({
    required String questionId,
    required HostFormQuestionKind kind,
  }) {
    final choice =
        kind == HostFormQuestionKind.singleChoice ||
        kind == HostFormQuestionKind.multiChoice;
    return HostFormQuestion._({
      'questionId': questionId,
      'key': 'question_${questionId.replaceAll(RegExp('[^A-Za-z0-9_]'), '_')}',
      'label': 'Untitled question',
      'helpText': null,
      'kind': kind.name,
      'required': false,
      'options': choice
          ? [
              {
                'optionId': '${questionId}_option_1',
                'label': 'Option 1',
                'value': 'option_1',
              },
              {
                'optionId': '${questionId}_option_2',
                'label': 'Option 2',
                'value': 'option_2',
              },
            ]
          : <Object?>[],
      'canonicalFieldId': null,
      'privacyClass': 'organizerCustom',
      'prefillPolicy': 'never',
      'hostPresentation': 'detailOnly',
      'validation': const {
        'minLength': null,
        'maxLength': null,
        'minNumber': null,
        'maxNumber': null,
        'earliestDate': null,
        'latestDate': null,
        'minSelections': null,
        'maxSelections': null,
        'maxFileCount': null,
        'maxFileSizeBytes': null,
        'allowedMimeTypes': <Object?>[],
        'patternPreset': null,
        'customError': null,
      },
    });
  }

  final Map<String, Object?> _json;

  String get questionId => _stringValue(_json['questionId']);
  String get label => _stringValue(_json['label']);
  String? get helpText => _nullableString(_json['helpText']);
  HostFormQuestionKind get kind => _enumByName(
    HostFormQuestionKind.values,
    _stringValue(_json['kind']),
    'form question kind',
  );
  bool get required => _json['required'] == true;
  List<HostFormQuestionOption> get options => _jsonList(_json['options'])
      .map((item) => HostFormQuestionOption._(_deepStringMap(item)))
      .toList(growable: false);

  Map<String, Object?> toJson() => _deepStringMap(_json);

  HostFormQuestion copyWith({
    String? label,
    String? helpText,
    bool clearHelpText = false,
    HostFormQuestionKind? kind,
    bool? required,
  }) {
    final next = toJson();
    if (label != null) next['label'] = label;
    if (helpText != null || clearHelpText) {
      next['helpText'] = clearHelpText ? null : helpText;
    }
    if (required != null) next['required'] = required;
    if (kind != null && kind != this.kind) {
      next['kind'] = kind.name;
      final choice =
          kind == HostFormQuestionKind.singleChoice ||
          kind == HostFormQuestionKind.multiChoice;
      if (!choice) {
        next['options'] = <Object?>[];
      } else if (_jsonList(next['options']).isEmpty) {
        next['options'] = [
          {
            'optionId': '${questionId}_option_1',
            'label': 'Option 1',
            'value': 'option_1',
          },
          {
            'optionId': '${questionId}_option_2',
            'label': 'Option 2',
            'value': 'option_2',
          },
        ];
      }
    }
    return HostFormQuestion._(next);
  }

  HostFormQuestion replaceOption(int index, HostFormQuestionOption option) {
    final next = toJson();
    final options = _jsonList(next['options']);
    options[index] = option.toJson();
    next['options'] = options;
    return HostFormQuestion._(next);
  }

  HostFormQuestion addOption(HostFormQuestionOption option) {
    final next = toJson();
    final options = _jsonList(next['options'])..add(option.toJson());
    next['options'] = options;
    return HostFormQuestion._(next);
  }

  HostFormQuestion removeOption(int index) {
    final next = toJson();
    final options = _jsonList(next['options'])..removeAt(index);
    next['options'] = options;
    return HostFormQuestion._(next);
  }
}

@immutable
class HostFormQuestionOption {
  HostFormQuestionOption._(Map<String, Object?> json)
    : _json = Map.unmodifiable(_deepStringMap(json));

  factory HostFormQuestionOption.create({
    required String optionId,
    required int ordinal,
  }) => HostFormQuestionOption._({
    'optionId': optionId,
    'label': 'Option $ordinal',
    'value': 'option_$ordinal',
  });

  final Map<String, Object?> _json;

  String get optionId => _stringValue(_json['optionId']);
  String get label => _stringValue(_json['label']);
  String get value => _stringValue(_json['value']);

  Map<String, Object?> toJson() => _deepStringMap(_json);

  HostFormQuestionOption copyWith({String? label, String? value}) {
    final next = toJson();
    if (label != null) next['label'] = label;
    if (value != null) next['value'] = value;
    return HostFormQuestionOption._(next);
  }
}

Map<Object?, Object?> _requiredMap(Object? value, String label) {
  if (value is Map<Object?, Object?>) return value;
  throw FormatException('Invalid $label.');
}

List<Map<Object?, Object?>> _mapList(Object? value, String label) {
  if (value is! List<Object?>) throw FormatException('Invalid $label.');
  return value.map((item) => _requiredMap(item, label)).toList(growable: false);
}

String _requiredString(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Response was missing $key.');
}

String _stringValue(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  throw const FormatException('Expected a non-empty string.');
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  throw const FormatException('Expected a nullable string.');
}

int _requiredInt(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is num && value >= 0) return value.toInt();
  throw FormatException('Response was missing $key.');
}

DateTime _dateTimeFromMillis(Map<Object?, Object?> map, String key) =>
    DateTime.fromMillisecondsSinceEpoch(_requiredInt(map, key));

DateTime? _nullableDateTimeFromMillis(Object? value) {
  if (value == null) return null;
  if (value is num && value >= 0) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  throw const FormatException('Expected nullable epoch milliseconds.');
}

T _enumByName<T extends Enum>(List<T> values, String name, String label) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Invalid $label.');
}

Map<String, Object?> _deepStringMap(Object? value) {
  if (value is! Map) return <String, Object?>{};
  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: _deepJsonValue(entry.value),
  };
}

Object? _deepJsonValue(Object? value) {
  if (value is Map) return _deepStringMap(value);
  if (value is List) return value.map(_deepJsonValue).toList(growable: true);
  return value;
}

List<Map<String, Object?>> _jsonList(Object? value) {
  if (value is! List) return <Map<String, Object?>>[];
  return value.map(_deepStringMap).toList(growable: true);
}

bool _setEquals<T>(Set<T> left, Set<T> right) =>
    left.length == right.length && left.containsAll(right);
