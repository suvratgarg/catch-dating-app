import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';

enum EventAdmissionPreset {
  openCapacity,
  inviteOnly,
  requestToJoin,
  balancedSingles,
}

extension EventAdmissionPresetX on EventAdmissionPreset {
  String get label => switch (this) {
    EventAdmissionPreset.openCapacity => 'OPEN',
    EventAdmissionPreset.inviteOnly => 'INVITE',
    EventAdmissionPreset.requestToJoin => 'REQUEST',
    EventAdmissionPreset.balancedSingles => 'BALANCED',
  };

  String get title => switch (this) {
    EventAdmissionPreset.openCapacity => 'Open capacity',
    EventAdmissionPreset.inviteOnly => 'Invite only',
    EventAdmissionPreset.requestToJoin => 'Request to join',
    EventAdmissionPreset.balancedSingles => 'Balanced singles',
  };

  String get description => switch (this) {
    EventAdmissionPreset.openCapacity =>
      'Anyone eligible can book until the event reaches capacity.',
    EventAdmissionPreset.inviteOnly =>
      'Only people with the invite code or private link can book. Waitlist is off by default.',
    EventAdmissionPreset.requestToJoin =>
      'People request a spot first. The host reviews their public profile before confirming who gets in.',
    EventAdmissionPreset.balancedSingles =>
      'Straight men and women are kept within one spot of each other. Queer, open, non-binary, and other attendees can book within total capacity.',
  };
}

class CreateEventPolicyState {
  const CreateEventPolicyState({
    this.admissionPreset = EventAdmissionPreset.openCapacity,
    this.cohortCapsEnabled = false,
    this.dynamicPricingEnabled = false,
    this.cancellationPolicyId = EventCancellationPolicyId.standard,
  });

  factory CreateEventPolicyState.fromDefaults(EventPolicyDefaults defaults) {
    return CreateEventPolicyState(
      admissionPreset: admissionPresetFromDefault(defaults.admissionPreset),
      cohortCapsEnabled:
          defaults.admissionPreset ==
              EventAdmissionDefaultPreset.fixedCohortCaps ||
          defaults.maxMen != null ||
          defaults.maxWomen != null,
      dynamicPricingEnabled: defaults.dynamicPricingEnabled,
      cancellationPolicyId: defaults.cancellationPolicyId,
    );
  }

  factory CreateEventPolicyState.fromDraft({
    required String? admissionPreset,
    required String? cancellationPolicy,
    required String? maxMen,
    required String? maxWomen,
    required bool dynamicPricingEnabled,
  }) {
    return CreateEventPolicyState(
      admissionPreset: admissionPresetFromName(admissionPreset),
      cohortCapsEnabled:
          admissionPreset == 'fixedCohortCaps' ||
          maxMen != null ||
          maxWomen != null,
      dynamicPricingEnabled: dynamicPricingEnabled,
      cancellationPolicyId: cancellationPolicyFromName(cancellationPolicy),
    );
  }

  final EventAdmissionPreset admissionPreset;
  final bool cohortCapsEnabled;
  final bool dynamicPricingEnabled;
  final EventCancellationPolicyId cancellationPolicyId;

  CreateEventPolicyState selectAdmissionPreset(EventAdmissionPreset preset) {
    return CreateEventPolicyState(
      admissionPreset: preset,
      cohortCapsEnabled: preset == EventAdmissionPreset.openCapacity
          ? cohortCapsEnabled
          : false,
      dynamicPricingEnabled: preset == EventAdmissionPreset.balancedSingles
          ? dynamicPricingEnabled
          : false,
      cancellationPolicyId: cancellationPolicyId,
    );
  }

  CreateEventPolicyState setCohortCapsEnabled(bool enabled) {
    return CreateEventPolicyState(
      admissionPreset: admissionPreset,
      cohortCapsEnabled: enabled,
      dynamicPricingEnabled: dynamicPricingEnabled,
      cancellationPolicyId: cancellationPolicyId,
    );
  }

  CreateEventPolicyState setDynamicPricingEnabled(bool enabled) {
    return CreateEventPolicyState(
      admissionPreset: admissionPreset,
      cohortCapsEnabled: cohortCapsEnabled,
      dynamicPricingEnabled: enabled,
      cancellationPolicyId: cancellationPolicyId,
    );
  }

  CreateEventPolicyState setCancellationPolicy(
    EventCancellationPolicyId policyId,
  ) {
    return CreateEventPolicyState(
      admissionPreset: admissionPreset,
      cohortCapsEnabled: cohortCapsEnabled,
      dynamicPricingEnabled: dynamicPricingEnabled,
      cancellationPolicyId: policyId,
    );
  }

  String get draftAdmissionPresetName =>
      admissionPreset == EventAdmissionPreset.openCapacity && cohortCapsEnabled
      ? 'fixedCohortCaps'
      : admissionPreset.name;

  EventAdmissionDefaultPreset get admissionDefaultPreset {
    if (admissionPreset == EventAdmissionPreset.openCapacity &&
        cohortCapsEnabled) {
      return EventAdmissionDefaultPreset.fixedCohortCaps;
    }
    return switch (admissionPreset) {
      EventAdmissionPreset.openCapacity =>
        EventAdmissionDefaultPreset.openCapacity,
      EventAdmissionPreset.inviteOnly => EventAdmissionDefaultPreset.inviteOnly,
      EventAdmissionPreset.requestToJoin =>
        EventAdmissionDefaultPreset.openCapacity,
      EventAdmissionPreset.balancedSingles =>
        EventAdmissionDefaultPreset.balancedSingles,
    };
  }

  EventPolicyDefaults defaultsFromFields({
    required String minAge,
    required String maxAge,
    required String maxMen,
    required String maxWomen,
    required String dynamicPricingStep,
    required String dynamicPricingMax,
    required String currencyCode,
  }) {
    return EventPolicyDefaults(
      admissionPreset: admissionDefaultPreset,
      minAge: int.tryParse(minAge.trim()) ?? 0,
      maxAge: int.tryParse(maxAge.trim()) ?? 99,
      maxMen: int.tryParse(maxMen.trim()),
      maxWomen: int.tryParse(maxWomen.trim()),
      dynamicPricingEnabled: dynamicPricingEnabled,
      dynamicPricingStepInPaise: currencyTextInMinorUnits(
        dynamicPricingStep,
        currencyCode: currencyCode,
      ),
      dynamicPricingMaxInPaise: currencyTextInMinorUnits(
        dynamicPricingMax,
        currencyCode: currencyCode,
      ),
      cancellationPolicyId: cancellationPolicyId,
    );
  }

  EventPolicyBundle eventPolicyFromFields({
    required String capacity,
    required String basePrice,
    required String inviteCode,
    required String minAge,
    required String maxAge,
    required String maxMen,
    required String maxWomen,
    required String dynamicPricingStep,
    required String dynamicPricingMax,
    required String currencyCode,
  }) {
    final capacityLimit = int.parse(capacity.trim());
    final basePriceInPaise = currencyTextInMinorUnits(
      basePrice,
      currencyCode: currencyCode,
    )!;
    final defaults = defaultsFromFields(
      minAge: minAge,
      maxAge: maxAge,
      maxMen: maxMen,
      maxWomen: maxWomen,
      dynamicPricingStep: dynamicPricingStep,
      dynamicPricingMax: dynamicPricingMax,
      currencyCode: currencyCode,
    );
    if (admissionPreset == EventAdmissionPreset.requestToJoin) {
      return EventPolicyBundle.requestToJoinEvent(
        capacityLimit: capacityLimit,
        basePriceInPaise: basePriceInPaise,
        cancellationPolicy: defaults.cancellationPolicy,
      );
    }
    return defaults.toEventPolicyBundle(
      capacityLimit: capacityLimit,
      basePriceInPaise: basePriceInPaise,
      inviteCodeHint: inviteCodeHint(inviteCode),
    );
  }

  static EventAdmissionPreset admissionPresetFromName(String? name) {
    if (name == null) return EventAdmissionPreset.openCapacity;
    if (name == 'fixedCohortCaps') {
      return EventAdmissionPreset.openCapacity;
    }
    return EventAdmissionPreset.values.firstWhere(
      (preset) => preset.name == name,
      orElse: () => EventAdmissionPreset.openCapacity,
    );
  }

  static EventAdmissionPreset admissionPresetFromDefault(
    EventAdmissionDefaultPreset preset,
  ) {
    return switch (preset) {
      EventAdmissionDefaultPreset.openCapacity =>
        EventAdmissionPreset.openCapacity,
      EventAdmissionDefaultPreset.inviteOnly => EventAdmissionPreset.inviteOnly,
      EventAdmissionDefaultPreset.balancedSingles =>
        EventAdmissionPreset.balancedSingles,
      EventAdmissionDefaultPreset.fixedCohortCaps =>
        EventAdmissionPreset.openCapacity,
    };
  }

  static EventCancellationPolicyId cancellationPolicyFromName(String? name) {
    if (name == null) return EventCancellationPolicyId.standard;
    return EventCancellationPolicyId.values.firstWhere(
      (policyId) => policyId.name == name,
      orElse: () => EventCancellationPolicyId.standard,
    );
  }

  static String? inviteCodeHint(String inviteCode) {
    final code = inviteCode.trim();
    if (code.isEmpty) return null;
    if (code.length <= 4) return code;
    return '${code.substring(0, 2)}...${code.substring(code.length - 2)}';
  }

  static int? currencyTextInMinorUnits(
    String text, {
    required String currencyCode,
  }) => parseMajorCurrencyAmountToMinorUnits(text, currencyCode: currencyCode);

  static String minorUnitsText(int? value, {required String currencyCode}) =>
      minorCurrencyAmountInputText(value, currencyCode: currencyCode);
}

class CreateEventPolicyDefaultsFormState {
  const CreateEventPolicyDefaultsFormState({
    required this.policyState,
    required this.minAgeText,
    required this.maxAgeText,
    required this.maxMenText,
    required this.maxWomenText,
    required this.dynamicPricingStepText,
    required this.dynamicPricingMaxText,
  });

  factory CreateEventPolicyDefaultsFormState.fromDefaults(
    EventPolicyDefaults defaults, {
    required String currencyCode,
  }) {
    return CreateEventPolicyDefaultsFormState(
      policyState: CreateEventPolicyState.fromDefaults(defaults),
      minAgeText: defaults.minAge == 0 ? '' : defaults.minAge.toString(),
      maxAgeText: defaults.maxAge == 99 ? '' : defaults.maxAge.toString(),
      maxMenText: defaults.maxMen?.toString() ?? '',
      maxWomenText: defaults.maxWomen?.toString() ?? '',
      dynamicPricingStepText: CreateEventPolicyState.minorUnitsText(
        defaults.dynamicPricingStepInPaise,
        currencyCode: currencyCode,
      ),
      dynamicPricingMaxText: CreateEventPolicyState.minorUnitsText(
        defaults.dynamicPricingMaxInPaise,
        currencyCode: currencyCode,
      ),
    );
  }

  final CreateEventPolicyState policyState;
  final String minAgeText;
  final String maxAgeText;
  final String maxMenText;
  final String maxWomenText;
  final String dynamicPricingStepText;
  final String dynamicPricingMaxText;
}
