import 'package:cloud_firestore/cloud_firestore.dart';

final class EventSuccessCompatibilityResponse {
  const EventSuccessCompatibilityResponse({
    required this.id,
    required this.eventId,
    required this.clubId,
    required this.uid,
    required this.answerIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventSuccessCompatibilityResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventSuccessCompatibilityResponse(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      clubId: json['clubId'] as String,
      uid: json['uid'] as String,
      answerIds: (json['answerIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      createdAt: _requiredTimestamp(json['createdAt'], 'createdAt'),
      updatedAt: _requiredTimestamp(json['updatedAt'], 'updatedAt'),
    );
  }

  final String id;
  final String eventId;
  final String clubId;
  final String uid;
  final List<String> answerIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'clubId': clubId,
    'uid': uid,
    'answerIds': answerIds,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  String? answerIdFor(String questionId) =>
      EventSuccessCompatibilityQuestionnaire.answerIdForQuestion(
        answerIds,
        questionId,
      );
}

final class EventSuccessCompatibilityQuestion {
  const EventSuccessCompatibilityQuestion({
    required this.id,
    required this.prompt,
    required this.options,
  });

  factory EventSuccessCompatibilityQuestion.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventSuccessCompatibilityQuestion(
      id: _normalizedId(json['id'], fallback: 'question'),
      prompt: _normalizedText(json['prompt'], fallback: 'Question'),
      options: (json['options'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(EventSuccessCompatibilityOption.fromJson)
          .where((option) => option.label.trim().isNotEmpty)
          .take(5)
          .toList(growable: false),
    ).normalized();
  }

  final String id;
  final String prompt;
  final List<EventSuccessCompatibilityOption> options;

  EventSuccessCompatibilityQuestion normalized() {
    final normalizedPrompt = prompt.trim();
    final normalizedOptions = options
        .where((option) => option.label.trim().isNotEmpty)
        .take(5)
        .toList(growable: false);
    return EventSuccessCompatibilityQuestion(
      id: _normalizedId(id, fallback: _slugFrom(normalizedPrompt, 'question')),
      prompt: normalizedPrompt.isEmpty ? 'Question' : normalizedPrompt,
      options: normalizedOptions.length < 2
          ? _fallbackOptionsFor(id)
          : normalizedOptions,
    );
  }

  EventSuccessCompatibilityQuestion copyWith({
    String? id,
    String? prompt,
    List<EventSuccessCompatibilityOption>? options,
  }) {
    return EventSuccessCompatibilityQuestion(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      options: options ?? this.options,
    ).normalized();
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'prompt': prompt,
    'options': options.map((option) => option.toJson()).toList(),
  };
}

final class EventSuccessCompatibilityOption {
  const EventSuccessCompatibilityOption({
    required this.id,
    required this.label,
  });

  factory EventSuccessCompatibilityOption.fromJson(Map<String, dynamic> json) {
    final label = _normalizedText(json['label'], fallback: 'Option');
    return EventSuccessCompatibilityOption(
      id: _normalizedId(json['id'], fallback: _slugFrom(label, 'option')),
      label: label,
    );
  }

  final String id;
  final String label;

  EventSuccessCompatibilityOption copyWith({String? id, String? label}) {
    return EventSuccessCompatibilityOption(
      id: _normalizedId(
        id ?? this.id,
        fallback: _slugFrom(label ?? this.label, 'option'),
      ),
      label: _normalizedText(label ?? this.label, fallback: this.label),
    );
  }

  Map<String, Object?> toJson() => {'id': id, 'label': label};
}

final class EventSuccessQuestionnairePack {
  const EventSuccessQuestionnairePack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.questions,
    this.custom = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<EventSuccessCompatibilityQuestion> questions;
  final bool custom;
}

abstract final class EventSuccessQuestionnairePackLibrary {
  static const balancedId = 'balanced';
  static const flirtyId = 'flirty';
  static const earnestId = 'earnest';
  static const intentionalId = 'intentional';
  static const customId = 'custom';

  static const balanced = EventSuccessQuestionnairePack(
    id: balancedId,
    title: 'Balanced',
    subtitle: 'Light social signal for most event formats.',
    questions: [
      EventSuccessCompatibilityQuestion(
        id: 'event_energy',
        prompt: "Tonight I'm most up for",
        options: [
          EventSuccessCompatibilityOption(
            id: 'event_energy_easy_conversation',
            label: 'Easy conversation',
          ),
          EventSuccessCompatibilityOption(
            id: 'event_energy_playful_competition',
            label: 'Playful competition',
          ),
          EventSuccessCompatibilityOption(
            id: 'event_energy_quiet_chemistry',
            label: 'Quiet chemistry',
          ),
          EventSuccessCompatibilityOption(
            id: 'event_energy_new_people',
            label: 'Meeting a few new people',
          ),
        ],
      ),
      EventSuccessCompatibilityQuestion(
        id: 'first_conversation',
        prompt: 'My best first conversation starts with',
        options: [
          EventSuccessCompatibilityOption(
            id: 'first_conversation_activity',
            label: 'A shared activity',
          ),
          EventSuccessCompatibilityOption(
            id: 'first_conversation_question',
            label: 'A thoughtful question',
          ),
          EventSuccessCompatibilityOption(
            id: 'first_conversation_joke',
            label: 'A joke',
          ),
          EventSuccessCompatibilityOption(
            id: 'first_conversation_recommendation',
            label: 'A practical recommendation',
          ),
        ],
      ),
      EventSuccessCompatibilityQuestion(
        id: 'shared_connection',
        prompt: 'I usually connect over',
        options: [
          EventSuccessCompatibilityOption(
            id: 'shared_connection_movement',
            label: 'Movement',
          ),
          EventSuccessCompatibilityOption(
            id: 'shared_connection_places',
            label: 'Food and places',
          ),
          EventSuccessCompatibilityOption(
            id: 'shared_connection_ideas',
            label: 'Ideas and trivia',
          ),
          EventSuccessCompatibilityOption(
            id: 'shared_connection_future_plans',
            label: 'Future plans',
          ),
        ],
      ),
      EventSuccessCompatibilityQuestion(
        id: 'after_event',
        prompt: "After a good event I'd rather",
        options: [
          EventSuccessCompatibilityOption(
            id: 'after_event_coffee',
            label: 'Grab coffee',
          ),
          EventSuccessCompatibilityOption(
            id: 'after_event_activity',
            label: 'Plan another activity',
          ),
          EventSuccessCompatibilityOption(
            id: 'after_event_text_first',
            label: 'Text first',
          ),
          EventSuccessCompatibilityOption(
            id: 'after_event_keep_casual',
            label: 'Keep it casual',
          ),
        ],
      ),
    ],
  );

  static const flirty = EventSuccessQuestionnairePack(
    id: flirtyId,
    title: 'Flirty',
    subtitle: 'More playful prompts for explicitly dating-forward events.',
    questions: [
      EventSuccessCompatibilityQuestion(
        id: 'flirty_energy',
        prompt: 'The kind of spark I enjoy is',
        options: [
          EventSuccessCompatibilityOption(
            id: 'flirty_energy_banter',
            label: 'Quick banter',
          ),
          EventSuccessCompatibilityOption(
            id: 'flirty_energy_slow_burn',
            label: 'A slow burn',
          ),
          EventSuccessCompatibilityOption(
            id: 'flirty_energy_playful_challenge',
            label: 'A playful challenge',
          ),
        ],
      ),
      EventSuccessCompatibilityQuestion(
        id: 'flirty_first_move',
        prompt: 'I respond best when someone',
        options: [
          EventSuccessCompatibilityOption(
            id: 'flirty_first_move_direct',
            label: 'Is direct',
          ),
          EventSuccessCompatibilityOption(
            id: 'flirty_first_move_witty',
            label: 'Makes me laugh',
          ),
          EventSuccessCompatibilityOption(
            id: 'flirty_first_move_curious',
            label: 'Asks something real',
          ),
        ],
      ),
    ],
  );

  static const earnest = EventSuccessQuestionnairePack(
    id: earnestId,
    title: 'Earnest',
    subtitle: 'Warmer questions for people seeking intentional connection.',
    questions: [
      EventSuccessCompatibilityQuestion(
        id: 'earnest_connection',
        prompt: 'I feel most connected when conversation is about',
        options: [
          EventSuccessCompatibilityOption(
            id: 'earnest_connection_values',
            label: 'Values',
          ),
          EventSuccessCompatibilityOption(
            id: 'earnest_connection_family',
            label: 'Family and community',
          ),
          EventSuccessCompatibilityOption(
            id: 'earnest_connection_growth',
            label: 'Growth and goals',
          ),
        ],
      ),
      EventSuccessCompatibilityQuestion(
        id: 'earnest_date_energy',
        prompt: 'A good first follow-up would feel',
        options: [
          EventSuccessCompatibilityOption(
            id: 'earnest_date_energy_calm',
            label: 'Calm and thoughtful',
          ),
          EventSuccessCompatibilityOption(
            id: 'earnest_date_energy_active',
            label: 'Active and easygoing',
          ),
          EventSuccessCompatibilityOption(
            id: 'earnest_date_energy_deep',
            label: 'Unhurried and deep',
          ),
        ],
      ),
    ],
  );

  static const intentional = EventSuccessQuestionnairePack(
    id: intentionalId,
    title: 'Intentional',
    subtitle: 'Lower-pressure prompts for older or more deliberate groups.',
    questions: [
      EventSuccessCompatibilityQuestion(
        id: 'intentional_pace',
        prompt: 'I prefer new connections to move',
        options: [
          EventSuccessCompatibilityOption(
            id: 'intentional_pace_slow',
            label: 'Slowly',
          ),
          EventSuccessCompatibilityOption(
            id: 'intentional_pace_natural',
            label: 'Naturally',
          ),
          EventSuccessCompatibilityOption(
            id: 'intentional_pace_clear',
            label: 'With clear intent',
          ),
        ],
      ),
      EventSuccessCompatibilityQuestion(
        id: 'intentional_life_fit',
        prompt: 'Compatibility means sharing',
        options: [
          EventSuccessCompatibilityOption(
            id: 'intentional_life_fit_rhythm',
            label: 'A similar life rhythm',
          ),
          EventSuccessCompatibilityOption(
            id: 'intentional_life_fit_values',
            label: 'Core values',
          ),
          EventSuccessCompatibilityOption(
            id: 'intentional_life_fit_curiosity',
            label: 'Curiosity and respect',
          ),
        ],
      ),
    ],
  );

  static const customStarterQuestions = [
    EventSuccessCompatibilityQuestion(
      id: 'custom_question_1',
      prompt: 'I usually connect with someone through',
      options: [
        EventSuccessCompatibilityOption(
          id: 'custom_question_1_option_1',
          label: 'Conversation',
        ),
        EventSuccessCompatibilityOption(
          id: 'custom_question_1_option_2',
          label: 'Shared activities',
        ),
        EventSuccessCompatibilityOption(
          id: 'custom_question_1_option_3',
          label: 'Humor',
        ),
      ],
    ),
    EventSuccessCompatibilityQuestion(
      id: 'custom_question_2',
      prompt: 'The best energy for this event is',
      options: [
        EventSuccessCompatibilityOption(
          id: 'custom_question_2_option_1',
          label: 'Relaxed',
        ),
        EventSuccessCompatibilityOption(
          id: 'custom_question_2_option_2',
          label: 'Playful',
        ),
        EventSuccessCompatibilityOption(
          id: 'custom_question_2_option_3',
          label: 'Intentional',
        ),
      ],
    ),
  ];

  static const allTemplates = <EventSuccessQuestionnairePack>[
    balanced,
    flirty,
    earnest,
    intentional,
  ];

  static EventSuccessQuestionnairePack byIdOrDefault(String id) {
    return allTemplates.firstWhere(
      (pack) => pack.id == id,
      orElse: () => balanced,
    );
  }

  static EventSuccessQuestionnairePack resolve(
    EventSuccessQuestionnaireConfig config,
  ) {
    if (config.usesCustom && config.customQuestions.isNotEmpty) {
      return EventSuccessQuestionnairePack(
        id: customId,
        title: config.customTitle?.trim().isNotEmpty == true
            ? config.customTitle!.trim()
            : 'Custom',
        subtitle: 'Custom questions for this event.',
        questions: config.customQuestions,
        custom: true,
      );
    }
    return byIdOrDefault(config.templateId);
  }
}

final class EventSuccessQuestionnaireConfig {
  const EventSuccessQuestionnaireConfig({
    this.templateId = EventSuccessQuestionnairePackLibrary.balancedId,
    this.customTitle,
    this.customQuestions = const [],
  });

  const EventSuccessQuestionnaireConfig.defaultTemplate()
    : this(templateId: EventSuccessQuestionnairePackLibrary.balancedId);

  const EventSuccessQuestionnaireConfig.customTemplate()
    : this(
        templateId: EventSuccessQuestionnairePackLibrary.customId,
        customTitle: 'Custom question set',
        customQuestions:
            EventSuccessQuestionnairePackLibrary.customStarterQuestions,
      );

  factory EventSuccessQuestionnaireConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EventSuccessQuestionnaireConfig();
    final rawTemplateId = json['templateId'];
    final templateId =
        rawTemplateId is String && rawTemplateId.trim().isNotEmpty
        ? rawTemplateId.trim()
        : EventSuccessQuestionnairePackLibrary.balancedId;
    return EventSuccessQuestionnaireConfig(
      templateId: templateId,
      customTitle: json['customTitle'] as String?,
      customQuestions: (json['customQuestions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(EventSuccessCompatibilityQuestion.fromJson)
          .take(8)
          .toList(growable: false),
    ).normalized();
  }

  final String templateId;
  final String? customTitle;
  final List<EventSuccessCompatibilityQuestion> customQuestions;

  bool get usesCustom =>
      templateId == EventSuccessQuestionnairePackLibrary.customId;

  EventSuccessQuestionnairePack get pack =>
      EventSuccessQuestionnairePackLibrary.resolve(this);

  List<EventSuccessCompatibilityQuestion> get questions => pack.questions;

  EventSuccessQuestionnaireConfig normalized() {
    if (!usesCustom) {
      return EventSuccessQuestionnaireConfig(
        templateId: EventSuccessQuestionnairePackLibrary.byIdOrDefault(
          templateId,
        ).id,
      );
    }
    final questions = customQuestions
        .map((question) => question.normalized())
        .where((question) => question.options.length >= 2)
        .take(8)
        .toList(growable: false);
    return EventSuccessQuestionnaireConfig(
      templateId: EventSuccessQuestionnairePackLibrary.customId,
      customTitle: _normalizedText(customTitle, fallback: 'Custom'),
      customQuestions: questions.isEmpty
          ? EventSuccessQuestionnairePackLibrary.customStarterQuestions
          : questions,
    );
  }

  EventSuccessQuestionnaireConfig copyWith({
    String? templateId,
    Object? customTitle = _sentinel,
    List<EventSuccessCompatibilityQuestion>? customQuestions,
  }) {
    return EventSuccessQuestionnaireConfig(
      templateId: templateId ?? this.templateId,
      customTitle: customTitle == _sentinel
          ? this.customTitle
          : customTitle as String?,
      customQuestions: customQuestions ?? this.customQuestions,
    ).normalized();
  }

  Map<String, Object?> toJson() => {
    'templateId': templateId,
    if (usesCustom) ...{
      'customTitle': customTitle,
      'customQuestions': customQuestions
          .map((question) => question.toJson())
          .toList(),
    },
  };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EventSuccessQuestionnaireConfig &&
            other.templateId == templateId &&
            other.customTitle == customTitle &&
            _sameQuestions(other.customQuestions, customQuestions);
  }

  @override
  int get hashCode =>
      Object.hash(templateId, customTitle, Object.hashAll(customQuestions));
}

abstract final class EventSuccessCompatibilityQuestionnaire {
  static final questions =
      EventSuccessQuestionnairePackLibrary.balanced.questions;

  static List<EventSuccessCompatibilityQuestion> questionsFor(
    EventSuccessQuestionnaireConfig config,
  ) => config.normalized().questions;

  static Set<String> get answerIds =>
      questions.expand((question) => question.options).map((option) {
        return option.id;
      }).toSet();

  static Set<String> answerIdsFor(EventSuccessQuestionnaireConfig config) =>
      questionsFor(config).expand((question) => question.options).map((option) {
        return option.id;
      }).toSet();

  static String? answerIdForQuestion(
    List<String> answerIds,
    String questionId,
  ) => answerIdForQuestionInConfig(
    answerIds,
    questionId,
    const EventSuccessQuestionnaireConfig(),
  );

  static String? answerIdForQuestionInConfig(
    List<String> answerIds,
    String questionId,
    EventSuccessQuestionnaireConfig config,
  ) {
    EventSuccessCompatibilityQuestion? question;
    for (final item in questionsFor(config)) {
      if (item.id == questionId) {
        question = item;
        break;
      }
    }
    if (question == null) return null;
    final optionIds = question.options.map((option) => option.id).toSet();
    for (final answerId in answerIds) {
      if (optionIds.contains(answerId)) return answerId;
    }
    return null;
  }

  static List<String> normalizedAnswerIds(
    Iterable<String> rawAnswerIds, {
    EventSuccessQuestionnaireConfig config =
        const EventSuccessQuestionnaireConfig(),
  }) {
    final allowedAnswerIds = answerIdsFor(config);
    final selectedByQuestion = <String, String>{};
    for (final answerId in rawAnswerIds) {
      if (!allowedAnswerIds.contains(answerId)) continue;
      final questionId = questionIdForAnswer(answerId, config: config);
      if (questionId == null) continue;
      selectedByQuestion[questionId] = answerId;
    }
    return [
      for (final question in questionsFor(config))
        if (selectedByQuestion[question.id] != null)
          selectedByQuestion[question.id]!,
    ];
  }

  static String? questionIdForAnswer(
    String answerId, {
    EventSuccessQuestionnaireConfig config =
        const EventSuccessQuestionnaireConfig(),
  }) {
    for (final question in questionsFor(config)) {
      for (final option in question.options) {
        if (option.id == answerId) return question.id;
      }
    }
    return null;
  }
}

String eventSuccessCompatibilityResponseId({
  required String eventId,
  required String uid,
}) => '${eventId}_$uid';

const _sentinel = Object();

bool _sameQuestions(
  List<EventSuccessCompatibilityQuestion> a,
  List<EventSuccessCompatibilityQuestion> b,
) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left.id != right.id ||
        left.prompt != right.prompt ||
        left.options.length != right.options.length) {
      return false;
    }
    for (var j = 0; j < left.options.length; j++) {
      if (left.options[j].id != right.options[j].id ||
          left.options[j].label != right.options[j].label) {
        return false;
      }
    }
  }
  return true;
}

List<EventSuccessCompatibilityOption> _fallbackOptionsFor(String questionId) {
  final safeId = _normalizedId(questionId, fallback: 'question');
  return [
    EventSuccessCompatibilityOption(
      id: '${safeId}_option_1',
      label: 'Option 1',
    ),
    EventSuccessCompatibilityOption(
      id: '${safeId}_option_2',
      label: 'Option 2',
    ),
  ];
}

String _normalizedText(Object? value, {required String fallback}) {
  if (value is! String) return fallback;
  final normalized = value.trim();
  return normalized.isEmpty ? fallback : normalized;
}

String _normalizedId(Object? value, {required String fallback}) {
  final raw = value is String ? value : fallback;
  return _slugFrom(raw, fallback);
}

String _slugFrom(String raw, String fallback) {
  final slug = raw
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  if (slug.isEmpty) return fallback;
  return slug.length > 80 ? slug.substring(0, 80) : slug;
}

DateTime _requiredTimestamp(Object? value, String field) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  throw StateError('Missing timestamp field $field.');
}
