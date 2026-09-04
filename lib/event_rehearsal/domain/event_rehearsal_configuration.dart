import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/events/domain/event.dart';

/// Editable practice configuration. Source objects are immutable; changing this
/// value never edits the organizer, event, plan, or production roster.
final class EventRehearsalConfiguration {
  const EventRehearsalConfiguration({
    required this.organizerDefaults,
    required this.format,
    required this.successDefaults,
    required this.actorCount,
    this.sourceEvent,
    this.sourcePlan,
    this.sampleActivityKind,
    this.scenario = EventRehearsalScenario.smoothRun,
    this.useSimulatedGuests = true,
    this.customActorCount = false,
    this.savedSimulatedCount,
    this.title,
    this.locationName,
    this.durationMinutes,
    this.hostGoal,
    this.attendeePrompt,
    this.moduleOverrides = const {},
  });

  factory EventRehearsalConfiguration.defaults({
    required ClubHostDefaults organizerDefaults,
    Event? event,
    EventSuccessPlan? plan,
    ActivityKind? activityKind,
    EventRehearsalScenario scenario = EventRehearsalScenario.smoothRun,
  }) {
    final format =
        event?.eventFormat ??
        EventFormatSnapshot.fromActivityKind(
          activityKind ?? organizerDefaults.primaryActivityKind,
        );
    final count =
        event?.signedUpCount ?? recommendedGuestCount(format, scenario);
    final defaults = plan == null
        ? organizerDefaults.eventSuccessForFormat(
            format,
            targetAttendeeCount: count,
          )
        : EventSuccessDefaults.fromDraft(
            plan.hostDraft,
            attendeePrompt: plan.attendeePrompt,
          );
    return EventRehearsalConfiguration(
      organizerDefaults: organizerDefaults,
      sourceEvent: event,
      sourcePlan: plan,
      sampleActivityKind: event == null ? format.activityKind : null,
      format: format,
      successDefaults: defaults,
      actorCount: count,
      scenario: scenario,
      useSimulatedGuests: event == null,
    );
  }

  final ClubHostDefaults organizerDefaults;
  final Event? sourceEvent;
  final EventSuccessPlan? sourcePlan;
  final ActivityKind? sampleActivityKind;
  final EventFormatSnapshot format;
  final EventSuccessDefaults successDefaults;
  final EventRehearsalScenario scenario;
  final int actorCount;
  final bool useSimulatedGuests;
  final bool customActorCount;
  final int? savedSimulatedCount;
  final String? title;
  final String? locationName;
  final int? durationMinutes;
  final String? hostGoal;
  final String? attendeePrompt;
  final Map<EventRehearsalModule, bool> moduleOverrides;

  static int recommendedGuestCount(
    EventFormatSnapshot format,
    EventRehearsalScenario scenario,
  ) => math.max(
    scenario.defaultActorCount,
    EventSuccessPlaybookLibrary.recommendedFor(
      activityType: format.activityKind,
    ).capacity.min,
  );

  EventRehearsalConfiguration reset() => EventRehearsalConfiguration.defaults(
    organizerDefaults: organizerDefaults,
    event: sourceEvent,
    plan: sourcePlan,
    activityKind: sampleActivityKind,
    scenario: scenario,
  );

  bool get isCustom =>
      format !=
          (sourceEvent?.eventFormat ??
              EventFormatSnapshot.fromActivityKind(
                sampleActivityKind ?? organizerDefaults.primaryActivityKind,
              )) ||
      (sourceEvent != null && useSimulatedGuests) ||
      customActorCount ||
      title != null ||
      locationName != null ||
      durationMinutes != null ||
      hostGoal != null ||
      attendeePrompt != null ||
      moduleOverrides.isNotEmpty;

  EventRehearsalConfiguration changeScenario(EventRehearsalScenario value) =>
      copyWith(
        scenario: value,
        actorCount: useSimulatedGuests && !customActorCount
            ? recommendedGuestCount(format, value)
            : actorCount,
      );

  EventRehearsalConfiguration changeActivity(ActivityKind kind) {
    final nextFormat = EventFormatSnapshot.fromActivityKind(kind);
    final count = useSimulatedGuests && !customActorCount
        ? recommendedGuestCount(nextFormat, scenario)
        : actorCount;
    return copyWith(
      format: nextFormat,
      actorCount: count,
      successDefaults: organizerDefaults.eventSuccessForFormat(
        nextFormat,
        targetAttendeeCount: count,
      ),
    );
  }

  EventRehearsalConfiguration changeGuestSource(bool simulated) => copyWith(
    useSimulatedGuests: simulated,
    savedSimulatedCount: simulated ? savedSimulatedCount : actorCount,
    actorCount: simulated
        ? (savedSimulatedCount ??
              (customActorCount
                  ? actorCount
                  : math
                        .max(2, sourceEvent?.signedUpCount ?? actorCount)
                        .clamp(2, 50)))
        : sourceEvent!.signedUpCount,
  );

  Set<EventRehearsalModule> get selectedModules {
    final selected = successDefaults
        .toDraft(targetAttendeeCount: actorCount)
        .selectedModuleIds;
    return {
      for (final module in EventRehearsalModule.values)
        if (moduleOverrides[module] ??
            selected.contains(eventRehearsalSuccessModuleId(module)))
          module,
    };
  }

  EventRehearsalConfiguration copyWith({
    EventFormatSnapshot? format,
    EventSuccessDefaults? successDefaults,
    EventRehearsalScenario? scenario,
    int? actorCount,
    bool? useSimulatedGuests,
    bool? customActorCount,
    int? savedSimulatedCount,
    String? title,
    String? locationName,
    int? durationMinutes,
    String? hostGoal,
    String? attendeePrompt,
    Map<EventRehearsalModule, bool>? moduleOverrides,
  }) => EventRehearsalConfiguration(
    organizerDefaults: organizerDefaults,
    sourceEvent: sourceEvent,
    sourcePlan: sourcePlan,
    sampleActivityKind: sampleActivityKind,
    format: format ?? this.format,
    successDefaults: successDefaults ?? this.successDefaults,
    scenario: scenario ?? this.scenario,
    actorCount: actorCount ?? this.actorCount,
    useSimulatedGuests: useSimulatedGuests ?? this.useSimulatedGuests,
    customActorCount: customActorCount ?? this.customActorCount,
    savedSimulatedCount: savedSimulatedCount ?? this.savedSimulatedCount,
    title: title ?? this.title,
    locationName: locationName ?? this.locationName,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    hostGoal: hostGoal ?? this.hostGoal,
    attendeePrompt: attendeePrompt ?? this.attendeePrompt,
    moduleOverrides: Map.unmodifiable(moduleOverrides ?? this.moduleOverrides),
  );
}

String eventRehearsalSuccessModuleId(EventRehearsalModule module) =>
    switch (module) {
      EventRehearsalModule.arrival => EventSuccessModuleCatalog.checkIn.id,
      EventRehearsalModule.firstHello =>
        EventSuccessModuleCatalog.firstHelloCheckIn.id,
      EventRehearsalModule.pods => EventSuccessModuleCatalog.microPods.id,
      EventRehearsalModule.rotations =>
        EventSuccessModuleCatalog.guidedRotations.id,
      EventRehearsalModule.conversationCues =>
        EventSuccessModuleCatalog.socialMissions.id,
      EventRehearsalModule.reveal => EventSuccessModuleCatalog.liveReveal.id,
      EventRehearsalModule.afterglow =>
        EventSuccessModuleCatalog.hostAnalytics.id,
      EventRehearsalModule.accountability =>
        EventSuccessModuleCatalog.safetyControls.id,
    };
