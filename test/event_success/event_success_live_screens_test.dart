import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_arrival_mission.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/event_success_companion_clock.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart'
    show buildEvent, buildEventParticipation, buildPublicProfile, buildUser;
import '../test_pump_helpers.dart';

void main() {
  testWidgets('host screen exposes setup live mode and report tabs', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 5000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final event = buildEvent(bookedCount: 10, checkedInCount: 6);
    final plan = EventSuccessPlan.defaultForEvent(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['a', 'b', 'c'],
                    checkedInIds: ['a', 'b'],
                    waitlistedIds: [],
                  ),
                  scorecard: const EventSuccessScorecard(
                    bookedCount: 10,
                    checkedInCount: 6,
                    attendeesWhoMetTwoPlusPeople: 4,
                    mutualMatchCount: 2,
                    chatStartedCount: 1,
                    averageWelcomeRating: 4.4,
                    averageStructureRating: 4.1,
                    safetyIncidentCount: 0,
                    catchSentCount: 3,
                    attendeesWhoCaughtSomeone: 2,
                    catchRecipientCount: 3,
                    catchRate: 1 / 3,
                    feedbackResponseCount: 4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Setup'), findsWidgets);
    expect(find.byType(CatchOptionGroup<EventSuccessHostTab>), findsOneWidget);
    expect(find.text('Target attendees'), findsOneWidget);
    expect(find.text('Group flow'), findsWidgets);
    expect(find.text('Host goal'), findsOneWidget);
    expect(find.text('Attendee prompt'), findsOneWidget);
    expect(find.text('Recommended setup'), findsOneWidget);
    expect(find.text('When people arrive'), findsOneWidget);
    expect(find.text('During the event'), findsOneWidget);
    expect(find.text('After the event'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
    expect(find.text('Save setup'), findsOneWidget);
    // Foundation lines and stage-card toggles are inline (no disclosure tap).
    expect(find.text('Check attendees in and confirm groups'), findsOneWidget);
    expect(find.text('Read a brief welcome script'), findsOneWidget);
    expect(find.text('Collect quick attendee feedback'), findsOneWidget);
    expect(find.text('Host coaching summary'), findsOneWidget);
    expect(find.text('"Help me say hi" requests'), findsWidgets);
    expect(find.text('Suggested first-message openers'), findsWidgets);
    expect(
      find.text('Safety, blocking, and report tools always on.'),
      findsOneWidget,
    );
    // Match clue questions lives inside the collapsed Advanced disclosure.
    expect(find.text('Match clue questions'), findsNothing);

    await tester.tap(find.text('Advanced'));
    await pumpFeatureUi(tester);
    expect(find.text('Match clue questions'), findsOneWidget);

    await tester.tap(find.text('Live'));
    await pumpFeatureUi(tester);
    expect(find.text('LIVE NOW'), findsOneWidget);
    expect(find.text('Conversation cues'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('eventSuccessNextStepButton')),
      findsOneWidget,
    );

    await tester.tap(find.text('Report'));
    await pumpFeatureUi(tester);
    expect(find.text('Post-event host report'), findsOneWidget);
  });

  testWidgets('host setup preserves custom format interaction model on save', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 5000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final firestore = FakeFirebaseFirestore();
    final format = EventFormatSnapshot.custom(
      label: 'Salsa night',
      interactionModel: EventInteractionModel.pairedRotations,
    );
    final event = buildEvent(
      eventFormat: format,
      capacityLimit: 24,
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
    );
    final plan = EventSuccessPlan.defaultForEvent(event);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
          eventSuccessRepositoryProvider.overrideWithValue(
            EventSuccessRepository(firestore),
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            ref.watch(uidProvider);
            return MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: EventSuccessHostPanel(
                      event: event,
                      plan: plan,
                      planIsPersisted: true,
                      roster: EventParticipationRoster.empty(),
                      onSaveSetup: (request) =>
                          EventSuccessController.saveSetupMutation.run(
                            ref,
                            (tx) => tx
                                .get(eventSuccessControllerProvider.notifier)
                                .saveSetup(
                                  plan: request.plan,
                                  draft: request.draft,
                                  attendeePrompt: request.attendeePrompt,
                                ),
                          ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Salsa night'), findsWidgets);
    expect(find.text('Paired rotations'), findsWidgets);
    expect(find.text('Open activity'), findsNothing);
    expect(plan.playbookId, EventSuccessPlaybookLibrary.pickleball.id);
    expect(plan.structureConfig.unitKind, EventSuccessUnitKind.pairs);

    await tester.tap(find.text('Save setup'));
    await tester.pump();
    await tester.pump();

    final saved = await EventSuccessRepository(firestore).fetchPlan(event.id);
    expect(saved, isNotNull);
    expect(saved!.playbookId, EventSuccessPlaybookLibrary.pickleball.id);
    expect(
      saved.selectedModuleIds,
      contains(EventSuccessModuleCatalog.guidedRotations.id),
    );
    expect(
      saved.selectedModuleIds,
      contains(EventSuccessModuleCatalog.liveReveal.id),
    );
    expect(
      saved.selectedModuleIds,
      isNot(contains(EventSuccessModuleCatalog.microPods.id)),
    );
    expect(saved.structureConfig.unitKind, EventSuccessUnitKind.pairs);
    expect(saved.structureConfig.unitSize, 2);
    expect(saved.structureConfig.rotationIntervalMinutes, 15);
  });

  testWidgets('host live mode is unavailable until setup is saved', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final event = buildEvent();
    final plan = EventSuccessPlan.defaultForEvent(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: false,
                  roster: EventParticipationRoster.empty(),
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Live mode needs saved setup'), findsOneWidget);
    expect(find.text('Live host mode'), findsNothing);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Mark live guide complete'), findsNothing);
  });

  testWidgets('host live guide skips live streams until setup is saved', (
    tester,
  ) async {
    final event = buildEvent(id: 'event-unsaved-live-guide');
    final rosterController = StreamController<EventParticipationRoster>();
    final assignmentsController =
        StreamController<List<EventSuccessAssignment>>();
    final rotationAssignmentsController =
        StreamController<List<EventSuccessAssignment>>();
    final preferencesController =
        StreamController<List<EventSuccessPreference>>();
    final wingmanRequestsController =
        StreamController<List<EventSuccessWingmanRequest>>();
    addTearDown(() {
      rosterController.close();
      assignmentsController.close();
      rotationAssignmentsController.close();
      preferencesController.close();
      wingmanRequestsController.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(null)),
          watchEventParticipationRosterProvider(
            event.id,
          ).overrideWith((ref) => rosterController.stream),
          watchEventSuccessAssignmentsProvider(
            event.id,
          ).overrideWith((ref) => assignmentsController.stream),
          watchEventSuccessRotationAssignmentsProvider(
            event.id,
          ).overrideWith((ref) => rotationAssignmentsController.stream),
          watchEventSuccessPreferencesProvider(
            event.id,
          ).overrideWith((ref) => preferencesController.stream),
          watchEventSuccessWingmanRequestsProvider(
            event.id,
          ).overrideWith((ref) => wingmanRequestsController.stream),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EventSuccessHostSection(
              event: event,
              initialTab: EventSuccessHostTab.live,
              showTabs: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Live mode needs saved setup'), findsOneWidget);
    expect(find.text('Live host mode'), findsNothing);
  });

  testWidgets('host section renders tab-shaped skeleton while guide loads', (
    tester,
  ) async {
    final event = buildEvent(id: 'event-loading-host-guide');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWithValue(const AsyncLoading<EventSuccessPlan?>()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: EventSuccessHostSection(
                event: event,
                initialTab: EventSuccessHostTab.live,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(EventSuccessHostSectionSkeleton), findsOneWidget);
    expect(find.byType(CatchSkeleton), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  test('host section state maps provider waves to status and retry intent', () {
    final event = buildEvent(id: 'event-host-section-state');
    final plan = EventSuccessPlan.defaultForEvent(event);
    const roster = EventParticipationRoster(
      bookedIds: ['runner-1'],
      checkedInIds: [],
      waitlistedIds: [],
    );

    EventSuccessHostSectionState resolve({
      AsyncValue<EventSuccessPlan?>? planAsync,
      AsyncValue<EventParticipationRoster>? rosterAsync,
      AsyncValue<EventSuccessScorecard?>? scorecardAsync,
      AsyncValue<List<EventSuccessAssignment>>? assignmentsAsync,
      AsyncValue<List<PublicProfile>>? assignmentProfilesAsync,
      AsyncValue<List<EventSuccessAssignment>>? rotationAssignmentsAsync,
      AsyncValue<List<PublicProfile>>? rotationProfilesAsync,
      AsyncValue<List<EventSuccessPreference>>? preferencesAsync,
      AsyncValue<List<EventSuccessWingmanRequest>>? wingmanRequestsAsync,
      AsyncValue<List<PublicProfile>>? wingmanProfilesAsync,
    }) {
      return EventSuccessHostSectionState.resolve(
        event: event,
        planAsync: planAsync ?? AsyncData<EventSuccessPlan?>(plan),
        rosterAsync: rosterAsync ?? const AsyncData(roster),
        scorecardAsync:
            scorecardAsync ?? const AsyncData<EventSuccessScorecard?>(null),
        assignmentsAsync:
            assignmentsAsync ?? const AsyncData(<EventSuccessAssignment>[]),
        assignmentParticipantProfilesAsync:
            assignmentProfilesAsync ?? const AsyncData(<PublicProfile>[]),
        rotationAssignmentsAsync:
            rotationAssignmentsAsync ??
            const AsyncData(<EventSuccessAssignment>[]),
        rotationParticipantProfilesAsync:
            rotationProfilesAsync ?? const AsyncData(<PublicProfile>[]),
        preferencesAsync:
            preferencesAsync ?? const AsyncData(<EventSuccessPreference>[]),
        wingmanRequestsAsync:
            wingmanRequestsAsync ??
            const AsyncData(<EventSuccessWingmanRequest>[]),
        wingmanProfilesAsync:
            wingmanProfilesAsync ?? const AsyncData(<PublicProfile>[]),
      );
    }

    expect(
      resolve(planAsync: const AsyncLoading<EventSuccessPlan?>()).status,
      EventSuccessHostSectionStatus.loading,
    );

    final unsaved = resolve(
      planAsync: const AsyncData<EventSuccessPlan?>(null),
    );
    expect(unsaved.status, EventSuccessHostSectionStatus.ready);
    expect(unsaved.planIsPersisted, isFalse);
    expect(unsaved.plan.eventId, event.id);

    final rosterError = StateError('roster failed');
    final rosterState = resolve(
      rosterAsync: AsyncError<EventParticipationRoster>(
        rosterError,
        StackTrace.empty,
      ),
    );
    expect(rosterState.status, EventSuccessHostSectionStatus.error);
    expect(rosterState.retryIntent, EventSuccessHostRetryIntent.roster);
    expect(rosterState.error, same(rosterError));

    final profileError = StateError('profiles failed');
    expect(
      resolve(
        assignmentProfilesAsync: AsyncError<List<PublicProfile>>(
          profileError,
          StackTrace.empty,
        ),
      ).retryIntent,
      EventSuccessHostRetryIntent.assignmentParticipantProfiles,
    );

    final scorecardError = StateError('scorecard failed');
    expect(
      resolve(
        scorecardAsync: AsyncError<EventSuccessScorecard?>(
          scorecardError,
          StackTrace.empty,
        ),
      ).retryIntent,
      EventSuccessHostRetryIntent.scorecard,
    );
  });

  testWidgets('host report is hidden when host analytics is disabled', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final event = buildEvent();
    final plan = EventSuccessPlan.defaultForEvent(event).copyWith(
      selectedModuleIds: EventSuccessPlaybookLibrary.socialRun.moduleIds
          .where((id) => id != EventSuccessModuleCatalog.hostAnalytics.id)
          .toList(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: EventParticipationRoster.empty(),
                  initialTab: EventSuccessHostTab.report,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Post-event insights are off'), findsOneWidget);
    expect(find.text('Post-event host report'), findsNothing);
  });

  testWidgets('host report summarizes live signal quality', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final event = buildEvent(bookedCount: 6, checkedInCount: 5);
    final plan = EventSuccessPlan.defaultForEvent(event);
    final now = DateTime(2026, 5, 21, 8);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: EventParticipationRoster.empty(),
                  scorecard: const EventSuccessScorecard(
                    bookedCount: 6,
                    checkedInCount: 5,
                    attendeesWhoMetTwoPlusPeople: 2,
                    mutualMatchCount: 0,
                    chatStartedCount: 0,
                    averageWelcomeRating: 5,
                    averageStructureRating: 4,
                    safetyIncidentCount: 0,
                    catchSentCount: 3,
                    attendeesWhoCaughtSomeone: 2,
                    catchRecipientCount: 3,
                    catchRate: 0.4,
                    feedbackResponseCount: 2,
                  ),
                  assignments: [
                    _assignment(
                      event: event,
                      uid: 'runner-1',
                      label: 'Pod A',
                      now: now,
                    ).copyWithPeerUids(['runner-2']),
                  ],
                  rotationAssignments: [
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-3',
                      peerUid: 'runner-4',
                      now: now,
                      roundCount: 1,
                    ),
                  ],
                  preferences: [
                    EventSuccessPreference(
                      id: eventSuccessPreferenceId(
                        eventId: event.id,
                        uid: 'runner-5',
                      ),
                      eventId: event.id,
                      clubId: event.clubId,
                      uid: 'runner-5',
                      microPodsOptedOut: false,
                      guidedRotationsOptedOut: true,
                      createdAt: now,
                      updatedAt: now,
                    ),
                  ],
                  wingmanRequests: [
                    _wingmanRequest(
                      event: event,
                      requesterUid: 'runner-1',
                      targetUid: 'runner-2',
                      now: now,
                    ),
                  ],
                  initialTab: EventSuccessHostTab.report,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('How reliable is this report?'), findsOneWidget);
    expect(find.text('Feedback 40%'), findsOneWidget);
    expect(find.text('Caught someone 40%'), findsWidgets);
    expect(find.text('People included 80%'), findsOneWidget);
    expect(find.text('Opted out 20%'), findsOneWidget);
    expect(find.text('Wingman help 20%'), findsOneWidget);
    expect(find.text('2/5 feedback'), findsOneWidget);
    expect(find.text('2 caught someone'), findsOneWidget);
    expect(find.text('3 catches sent'), findsOneWidget);
    expect(find.text('4 assigned'), findsOneWidget);
    expect(find.text('1 opted out'), findsOneWidget);
    expect(find.text('1 host-help requests'), findsOneWidget);
    expect(find.textContaining('Private notes'), findsOneWidget);
    expect(find.text('Working well'), findsOneWidget);
  });

  testWidgets('host live mode summarizes generated micro-pod groups', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final event = buildEvent();
    final plan = EventSuccessPlan.defaultForEvent(event);
    final now = DateTime(2026, 5, 21, 8);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2', 'runner-3'],
                    checkedInIds: ['runner-1'],
                    waitlistedIds: [],
                  ),
                  assignments: [
                    _assignment(
                      event: event,
                      uid: 'runner-1',
                      label: 'Pod A',
                      now: now,
                    ),
                    _assignment(
                      event: event,
                      uid: 'runner-2',
                      label: 'Pod A',
                      now: now,
                    ),
                    _assignment(
                      event: event,
                      uid: 'runner-3',
                      label: 'Pod B',
                      now: now,
                    ),
                  ],
                  preferences: [
                    EventSuccessPreference(
                      id: eventSuccessPreferenceId(
                        eventId: event.id,
                        uid: 'runner-4',
                      ),
                      eventId: event.id,
                      clubId: event.clubId,
                      uid: 'runner-4',
                      microPodsOptedOut: true,
                      guidedRotationsOptedOut: false,
                      createdAt: now,
                      updatedAt: now,
                    ),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Arrival check-in'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('1 checked in'), findsOneWidget);
    expect(find.text('3 assigned'), findsOneWidget);
    expect(find.text('1 opted out'), findsOneWidget);
    expect(find.text('Pod A · 2 assigned'), findsOneWidget);
    expect(find.text('Pod B · 1 assigned'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
  });

  testWidgets('host live mode excludes opted-out stale pod assignments', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final event = buildEvent();
    final plan = EventSuccessPlan.defaultForEvent(event);
    final now = DateTime(2026, 5, 21, 8);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2', 'runner-3'],
                    checkedInIds: ['runner-1'],
                    waitlistedIds: [],
                  ),
                  assignments: [
                    _assignment(
                      event: event,
                      uid: 'runner-1',
                      label: 'Pod A',
                      now: now,
                    ),
                    _assignment(
                      event: event,
                      uid: 'runner-2',
                      label: 'Pod A',
                      now: now,
                    ),
                    _assignment(
                      event: event,
                      uid: 'runner-3',
                      label: 'Pod B',
                      now: now,
                    ),
                  ],
                  preferences: [
                    EventSuccessPreference(
                      id: eventSuccessPreferenceId(
                        eventId: event.id,
                        uid: 'runner-2',
                      ),
                      eventId: event.id,
                      clubId: event.clubId,
                      uid: 'runner-2',
                      microPodsOptedOut: true,
                      guidedRotationsOptedOut: false,
                      createdAt: now,
                      updatedAt: now,
                    ),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('2 assigned'), findsOneWidget);
    expect(find.text('1 opted out'), findsOneWidget);
    expect(
      find.text(
        'Regenerate to remove opted-out attendee cards from the current pod set.',
      ),
      findsOneWidget,
    );
    expect(find.text('Pod A · 1 assigned'), findsOneWidget);
    expect(find.text('Pod B · 1 assigned'), findsOneWidget);
    expect(find.text('Pod A · 2 assigned'), findsNothing);
  });

  testWidgets('host live mode surfaces active wingman requests', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime.now().add(const Duration(minutes: 10));
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1', 'runner-2'],
                    waitlistedIds: [],
                  ),
                  wingmanRequests: [
                    _wingmanRequest(
                      event: event,
                      requesterUid: 'runner-1',
                      targetUid: 'runner-2',
                      note: 'Please pair us during the second round.',
                      now: start,
                    ),
                  ],
                  wingmanProfiles: [
                    buildPublicProfile(name: 'Arjun'),
                    buildPublicProfile(
                      uid: 'runner-2',
                      name: 'Rhea',
                      gender: Gender.woman,
                    ),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('"Help me say hi" requests'), findsOneWidget);
    expect(find.text('1 active'), findsOneWidget);
    expect(find.text('Arjun'), findsOneWidget);
    expect(find.text('Asked for help meeting Rhea'), findsOneWidget);
    expect(
      find.text('Please pair us during the second round.'),
      findsOneWidget,
    );
  });

  testWidgets('host live mode summarizes generated rotation schedules', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime.now().add(const Duration(minutes: 10));
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
    );
    final plan = _racketPlan(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1', 'runner-2'],
                    waitlistedIds: [],
                  ),
                  rotationAssignments: [
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-1',
                      peerUid: 'runner-2',
                      now: start,
                      roundCount: 2,
                    ),
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-2',
                      peerUid: 'runner-1',
                      now: start,
                      roundCount: 2,
                    ),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Timed partner rotations'), findsOneWidget);
    expect(find.text('2 rounds'), findsOneWidget);
    expect(find.text('2 assigned'), findsOneWidget);
    expect(find.text('2 possible'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
    expect(find.text('Edit rotations'), findsOneWidget);
  });

  testWidgets('host live mode opens group override editor', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 2400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 21, 8);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(minutes: 60)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event);
    final assignments = [
      EventSuccessAssignment(
        id: eventSuccessAssignmentId(
          eventId: event.id,
          moduleId: EventSuccessModuleCatalog.microPods.id,
          uid: 'runner-1',
        ),
        eventId: event.id,
        clubId: event.clubId,
        uid: 'runner-1',
        moduleId: EventSuccessModuleCatalog.microPods.id,
        label: 'Table A',
        displayTitle: 'Table A',
        displaySubtitle: '3 people at this table.',
        peerUids: const ['runner-2', 'runner-3'],
        source: 'server_v1',
        createdAt: start,
        updatedAt: start,
      ),
      EventSuccessAssignment(
        id: eventSuccessAssignmentId(
          eventId: event.id,
          moduleId: EventSuccessModuleCatalog.microPods.id,
          uid: 'runner-2',
        ),
        eventId: event.id,
        clubId: event.clubId,
        uid: 'runner-2',
        moduleId: EventSuccessModuleCatalog.microPods.id,
        label: 'Table A',
        displayTitle: 'Table A',
        displaySubtitle: '3 people at this table.',
        peerUids: const ['runner-1', 'runner-3'],
        source: 'server_v1',
        createdAt: start,
        updatedAt: start,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2', 'runner-3'],
                    checkedInIds: ['runner-1', 'runner-2', 'runner-3'],
                    waitlistedIds: [],
                  ),
                  assignments: assignments,
                  assignmentParticipantProfiles: [
                    buildPublicProfile(name: 'Arjun'),
                    buildPublicProfile(uid: 'runner-2', name: 'Rhea'),
                    buildPublicProfile(uid: 'runner-3', name: 'Naina'),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Edit groups'), findsOneWidget);
    await tester.tap(find.text('Edit groups'));
    await pumpFeatureUi(tester);

    expect(find.text('Host override'), findsOneWidget);
    expect(find.text('Round 1'), findsOneWidget);
    expect(find.text('Group label'), findsOneWidget);
    expect(find.text('Table A'), findsWidgets);
    expect(find.text('Arjun'), findsWidgets);
    expect(find.text('Rhea'), findsWidgets);
    expect(find.text('Naina'), findsWidgets);
    expect(find.text('Save overrides'), findsOneWidget);
  });

  testWidgets('host live mode shows the countdown reveal console', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 5000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 21, 8);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
    );
    final plan = _racketPlan(event).copyWith(activeStepIndex: 2);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1', 'runner-2'],
                    waitlistedIds: [],
                  ),
                  rotationAssignments: [
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-1',
                      peerUid: 'runner-2',
                      now: start,
                      roundCount: 2,
                    ),
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-2',
                      peerUid: 'runner-1',
                      now: start,
                      roundCount: 2,
                    ),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Synchronized partner reveal'), findsOneWidget);
    expect(find.text('Rotation reveal'), findsOneWidget);
    expect(find.text('LIVE NOW'), findsOneWidget);
    expect(find.text('Controls for this step'), findsOneWidget);
    expect(find.textContaining('Attendees at'), findsOneWidget);
    expect(find.text('Create the next room-wide beat'), findsOneWidget);
    expect(find.text('Drop 10s countdown'), findsOneWidget);
    expect(find.text('Reveal now'), findsOneWidget);
  });

  testWidgets('host live actions dispatch ceremony effects once per tap', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 5000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final effects = _FakeEventSuccessLiveEffectsController();
    var nextPressed = 0;
    var completePressed = 0;
    final start = DateTime(2026, 5, 21, 8);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventSuccessLiveEffectsControllerProvider.overrideWithValue(effects),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: _racketPlan(event),
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1'],
                    waitlistedIds: [],
                  ),
                  fixtureActions: EventSuccessHostFixtureActions(
                    onNextStep: () => nextPressed++,
                    onCompletePlan: () => completePressed++,
                  ),
                  onPlayLiveEffect: effects.play,
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('eventSuccessNextStepButton')));
    await tester.pump();
    await tester.tap(
      find.widgetWithText(CatchButton, 'Mark live guide complete'),
    );
    await tester.pump();

    expect(nextPressed, 1);
    expect(completePressed, 1);
    expect(effects.playedKinds, [
      EventSuccessLiveEffectKind.stepChange,
      EventSuccessLiveEffectKind.guideComplete,
    ]);
  });

  testWidgets('host live mode requires generation before rotation edits', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 21, 8);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
    );
    final plan = _racketPlan(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1', 'runner-2'],
                    waitlistedIds: [],
                  ),
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Timed partner rotations'), findsOneWidget);
    expect(find.text('0 rounds'), findsOneWidget);
    expect(find.text('Generate rotations'), findsOneWidget);
    expect(find.text('Edit rotations'), findsNothing);
  });

  testWidgets('host live mode marks host-edited rotations', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 21, 8);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
    );
    final plan = _racketPlan(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1', 'runner-2'],
                    waitlistedIds: [],
                  ),
                  rotationAssignments: [
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-1',
                      peerUid: 'runner-2',
                      now: start,
                      roundCount: 1,
                      source: 'host_override_v1',
                    ),
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-2',
                      peerUid: 'runner-1',
                      now: start,
                      roundCount: 1,
                      source: 'host_override_v1',
                    ),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Host edited'), findsOneWidget);
  });

  testWidgets('host live mode opens rotation override editor', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 21, 8);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
    );
    final plan = _racketPlan(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1', 'runner-2'],
                    waitlistedIds: [],
                  ),
                  rotationAssignments: [
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-1',
                      peerUid: 'runner-2',
                      now: start,
                      roundCount: 1,
                    ),
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-2',
                      peerUid: 'runner-1',
                      now: start,
                      roundCount: 1,
                    ),
                  ],
                  rotationParticipantProfiles: [
                    buildPublicProfile(name: 'Arjun'),
                    buildPublicProfile(
                      uid: 'runner-2',
                      name: 'Rhea',
                      gender: Gender.woman,
                    ),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit rotations'));
    await pumpFeatureUi(tester);

    expect(find.text('Host override'), findsOneWidget);
    expect(find.text('Round 1'), findsOneWidget);
    expect(find.text('Arjun'), findsOneWidget);
    expect(find.text('Rhea'), findsOneWidget);
    expect(find.text('Save overrides'), findsOneWidget);
  });

  testWidgets('host live mode excludes opted-out stale rotations', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 21, 8);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
    );
    final plan = _racketPlan(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1', 'runner-2'],
                    waitlistedIds: [],
                  ),
                  rotationAssignments: [
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-1',
                      peerUid: 'runner-2',
                      now: start,
                      roundCount: 2,
                    ),
                    _rotationAssignment(
                      event: event,
                      uid: 'runner-2',
                      peerUid: 'runner-1',
                      now: start,
                      roundCount: 2,
                    ),
                  ],
                  preferences: [
                    EventSuccessPreference(
                      id: eventSuccessPreferenceId(
                        eventId: event.id,
                        uid: 'runner-2',
                      ),
                      eventId: event.id,
                      clubId: event.clubId,
                      uid: 'runner-2',
                      microPodsOptedOut: false,
                      guidedRotationsOptedOut: true,
                      createdAt: start,
                      updatedAt: start,
                    ),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Timed partner rotations'), findsOneWidget);
    expect(find.text('1 opted out'), findsOneWidget);
    expect(
      find.text(
        'Regenerate to remove opted-out attendees from timed rotations.',
      ),
      findsOneWidget,
    );
    expect(find.text('1 assigned'), findsOneWidget);
  });

  testWidgets(
    'companion screen lets checked-in attendees ask the host for help',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final firestore = FakeFirebaseFirestore();
      final start = DateTime(2026, 5, 18, 7);
      final event = buildEvent(
        startTime: start,
        endTime: start.add(const Duration(hours: 2)),
      );
      final plan = EventSuccessPlan.defaultForEvent(
        event,
      ).copyWith(activeStepIndex: 4);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            eventSuccessRepositoryProvider.overrideWithValue(
              EventSuccessRepository(
                firestore,
                functions: _WingmanTestFirebaseFunctions(
                  firestore,
                  requesterUid: 'runner-1',
                ),
              ),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(uidProvider);
              return MaterialApp(
                theme: AppTheme.light,
                home: EventSuccessCompanionScreen(
                  event: event,
                  plan: plan,
                  userProfile: buildUser(),
                  participation: buildEventParticipation(
                    event: event,
                    uid: 'runner-1',
                    status: EventParticipationStatus.attended,
                  ),
                  wingmanRequestCandidates: [
                    buildPublicProfile(
                      uid: 'runner-2',
                      name: 'Rhea',
                      gender: Gender.woman,
                    ),
                  ],
                  now: start.add(const Duration(hours: 1)),
                  onSaveWingmanRequest: (target, note) async {
                    await EventSuccessController.wingmanRequestMutation.run(
                      ref,
                      (tx) => tx
                          .get(eventSuccessControllerProvider.notifier)
                          .saveWingmanRequest(
                            event: event,
                            target: target,
                            note: note,
                          ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Ask the host for an intro'),
        400,
        scrollable: findPrimaryScrollable(),
      );
      expect(find.text('Host can see'), findsOneWidget);
      expect(find.text('Rhea'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Ask host'),
        200,
        scrollable: findPrimaryScrollable(),
      );
      await tester.tap(find.text('Ask host'));
      await pumpFeatureUi(tester);

      final request = await firestore
          .collection('eventSuccessWingmanRequests')
          .doc('event-1_runner-1')
          .get();
      expect(request.data()?['targetUid'], 'runner-2');
      expect(request.data()?['status'], 'active');
      expect(request.data()?['hostVisibleConsent'], isTrue);
    },
  );

  testWidgets(
    'companion filters host-help candidates to the attendee interested-in genders',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1500);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final start = DateTime(2026, 5, 18, 7);
      final event = buildEvent(
        startTime: start,
        endTime: start.add(const Duration(hours: 2)),
      );
      final plan = EventSuccessPlan.defaultForEvent(
        event,
      ).copyWith(activeStepIndex: 4);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: EventSuccessCompanionScreen(
              event: event,
              plan: plan,
              userProfile: buildUser(
                gender: Gender.woman,
                interestedInGenders: const [Gender.man],
              ),
              participation: buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
              wingmanRequestCandidates: [
                buildPublicProfile(uid: 'runner-2', name: 'Arjun'),
                buildPublicProfile(
                  uid: 'runner-3',
                  name: 'Rhea',
                  gender: Gender.woman,
                ),
              ],
              now: start.add(const Duration(hours: 1)),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Ask the host for an intro'),
        400,
        scrollable: findPrimaryScrollable(),
      );

      expect(find.text('Arjun'), findsOneWidget);
      expect(find.text('Rhea'), findsNothing);
    },
  );

  testWidgets('companion keeps booked attendees in pre-arrival mode', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 18, 7);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = _withLiveReveal(
      _withGuidedRotations(EventSuccessPlan.defaultForEvent(event)),
    );
    final assignment = _rotationAssignment(
      event: event,
      uid: 'runner-1',
      peerUid: 'runner-2',
      now: start,
      roundCount: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionScreen(
            event: event,
            plan: plan,
            userProfile: buildUser(),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
            ),
            wingmanRequestCandidates: const [],
            rotationAssignment: assignment,
            rotationPeerProfiles: [
              buildPublicProfile(
                uid: 'runner-2',
                name: 'Rhea',
                gender: Gender.woman,
              ),
            ],
            now: start.subtract(const Duration(hours: 1)),
          ),
        ),
      ),
    );

    expect(find.text('What to expect'), findsOneWidget);
    expect(
      find.text('Timed partner rotations as the event unfolds.'),
      findsOneWidget,
    );
    expect(find.text('Social prompt'), findsNothing);
    expect(find.text('Conversation cues'), findsNothing);
    expect(find.text('Rotation reveal'), findsNothing);
    expect(find.text('Waiting for the host reveal'), findsNothing);
    expect(find.textContaining('Rhea'), findsNothing);
  });

  testWidgets('companion screen shows assigned First Hello mission', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 18, 19);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 2)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event).copyWith(
      selectedModuleIds: [
        EventSuccessModuleCatalog.checkIn.id,
        EventSuccessModuleCatalog.firstHelloCheckIn.id,
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
      ],
    );
    final mission = EventSuccessArrivalMission(
      id: eventSuccessArrivalMissionId(eventId: event.id, uid: 'runner-1'),
      eventId: event.id,
      clubId: event.clubId,
      observerUid: 'runner-1',
      targetUid: 'runner-2',
      targetDisplayName: 'Arjun',
      targetContext: 'Look for Arjun near the host table.',
      question: 'Ask what kind of partner makes an event feel easy to join.',
      answerOptions: const [
        EventSuccessArrivalMissionAnswerOption(
          id: 'warm_intro',
          label: 'Warm intro',
        ),
        EventSuccessArrivalMissionAnswerOption(
          id: 'playful_energy',
          label: 'Playful energy',
        ),
      ],
      status: EventSuccessArrivalMissionStatus.active,
      createdAt: start.subtract(const Duration(minutes: 1)),
      updatedAt: start.subtract(const Duration(minutes: 1)),
    );
    EventSuccessArrivalMission? completedMission;
    String? completedAnswerId;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionScreen(
            event: event,
            plan: plan,
            userProfile: buildUser(),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
            ),
            wingmanRequestCandidates: const [],
            arrivalMission: mission,
            now: start.subtract(const Duration(minutes: 5)),
            onCompleteArrivalMission: (mission, answerId) async {
              completedMission = mission;
              completedAnswerId = answerId;
            },
          ),
        ),
      ),
    );

    expect(find.text('Your first arrival mission is live.'), findsOneWidget);
    expect(find.text('Find Arjun.'), findsOneWidget);
    expect(
      find.text('Ask what kind of partner makes an event feel easy to join.'),
      findsOneWidget,
    );
    expect(find.text('A few quick questions'), findsNothing);

    await tester.tap(find.text('Playful energy'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CatchButton, 'Complete check-in'));
    await tester.pump();

    expect(completedMission, same(mission));
    expect(completedAnswerId, 'playful_energy');
  });

  testWidgets('companion screen can start First Hello before mission exists', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 18, 19);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 2)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event).copyWith(
      selectedModuleIds: [
        EventSuccessModuleCatalog.checkIn.id,
        EventSuccessModuleCatalog.firstHelloCheckIn.id,
      ],
    );
    var startCalls = 0;
    var skipCalls = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionScreen(
            event: event,
            plan: plan,
            userProfile: buildUser(),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
            ),
            wingmanRequestCandidates: const [],
            now: start.subtract(const Duration(minutes: 5)),
            onStartArrivalMission: () async => startCalls++,
            onSkipArrivalMission: () => skipCalls++,
          ),
        ),
      ),
    );

    expect(find.text('Start your First Hello.'), findsOneWidget);
    expect(find.text('A few quick questions'), findsNothing);

    await tester.tap(find.widgetWithText(CatchButton, 'Start First Hello'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CatchButton, 'Use normal check-in'));
    await tester.pump();

    expect(startCalls, 1);
    expect(skipCalls, 1);
  });

  testWidgets('companion screen saves compatibility questionnaire answers', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final firestore = FakeFirebaseFirestore();
    final start = DateTime(2026, 5, 18, 7);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 2)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event).copyWith(
      selectedModuleIds: [
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
      ],
      compatibilityAffectsRanking: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          eventSuccessRepositoryProvider.overrideWithValue(
            EventSuccessRepository(firestore),
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            ref.watch(uidProvider);
            return MaterialApp(
              theme: AppTheme.light,
              home: EventSuccessCompanionScreen(
                event: event,
                plan: plan,
                userProfile: buildUser(),
                participation: buildEventParticipation(
                  event: event,
                  uid: 'runner-1',
                ),
                wingmanRequestCandidates: const [],
                now: start.add(const Duration(minutes: 30)),
                onSaveCompatibilityAnswers: (answerIds) async {
                  await EventSuccessController.compatibilityResponseMutation
                      .run(
                        ref,
                        (tx) => tx
                            .get(eventSuccessControllerProvider.notifier)
                            .saveCompatibilityResponse(
                              event: event,
                              answerIds: answerIds,
                              questionnaireConfig: plan.questionnaireConfig,
                            ),
                      );
                },
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('eventSuccessCompanionStage')),
      findsOneWidget,
    );
    expect(find.text('A few quick questions'), findsOneWidget);
    expect(find.text('Can guide pairings'), findsOneWidget);

    await tester.tap(find.text('Playful competition'));
    await tester.pump();
    await tester.tap(find.text('Save clues'));
    await pumpFeatureUi(tester);

    final saved = await firestore
        .collection('eventSuccessCompatibilityResponses')
        .doc('event-1_runner-1')
        .get();
    expect(saved.data()?['answerIds'], ['event_energy_playful_competition']);
  });

  testWidgets('companion route shows unanswered questionnaire after check-in', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final firestore = FakeFirebaseFirestore();
    final start = DateTime.now().add(const Duration(minutes: 20));
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 2)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event).copyWith(
      selectedModuleIds: [
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
      ],
      compatibilityAffectsRanking: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchEventProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(event)),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser()),
          ),
          watchEventParticipationProvider(event.id, 'runner-1').overrideWith(
            (ref) => Stream.value(
              buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
            ),
          ),
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(plan)),
          eventSuccessRepositoryProvider.overrideWithValue(
            EventSuccessRepository(firestore),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionRouteScreen(
            clubId: event.clubId,
            eventId: event.id,
            initialEvent: event,
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('A few quick questions'), findsOneWidget);
    expect(find.text('Can guide pairings'), findsOneWidget);
    expect(find.text('The host is running the room'), findsNothing);
  });

  testWidgets('companion route refreshes when event clock crosses end time', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final firestore = FakeFirebaseFirestore();
    final clock = StreamController<DateTime>();
    addTearDown(clock.close);
    final start = DateTime(2026, 5, 18, 7);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchEventProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(event)),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser()),
          ),
          watchEventParticipationProvider(event.id, 'runner-1').overrideWith(
            (ref) => Stream.value(
              buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
            ),
          ),
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(plan)),
          eventSuccessCompanionClockProvider.overrideWith(
            (ref) => clock.stream,
          ),
          eventSuccessRepositoryProvider.overrideWithValue(
            EventSuccessRepository(firestore),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionRouteScreen(
            clubId: event.clubId,
            eventId: event.id,
            initialEvent: event,
          ),
        ),
      ),
    );

    clock.add(start.add(const Duration(minutes: 30)));
    await tester.pump();
    await tester.pump();
    expect(find.text('Suggested first-message openers'), findsNothing);

    clock.add(start.add(const Duration(hours: 2)));
    await tester.pump();
    await tester.pump();
    expect(find.text('Suggested first-message openers'), findsOneWidget);
    expect(find.textContaining('compare routes'), findsOneWidget);
  });

  testWidgets(
    'companion route keeps chrome with content skeleton while loading',
    (tester) async {
      final event = buildEvent(id: 'event-loading-companion');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
            watchEventProvider(
              event.id,
            ).overrideWithValue(const AsyncLoading<Event?>()),
            watchUserProfileProvider.overrideWithValue(AsyncData(buildUser())),
            watchEventParticipationProvider(
              event.id,
              'runner-1',
            ).overrideWithValue(
              AsyncData<EventParticipation?>(
                buildEventParticipation(
                  event: event,
                  uid: 'runner-1',
                  status: EventParticipationStatus.attended,
                ),
              ),
            ),
            watchEventSuccessPlanProvider(event.id).overrideWithValue(
              AsyncData(EventSuccessPlan.defaultForEvent(event)),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: EventSuccessCompanionRouteScreen(
              clubId: event.clubId,
              eventId: event.id,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Event companion'), findsOneWidget);
      expect(find.byType(EventSuccessCompanionLoadingBody), findsOneWidget);
      expect(find.byType(CatchSkeleton), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'companion screen shows post-event openers and feedback after attendance',
    (tester) async {
      final firestore = FakeFirebaseFirestore();
      final start = DateTime(2026, 5, 18, 7);
      final event = buildEvent(
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
      );
      final plan = EventSuccessPlan.defaultForEvent(event);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            eventSuccessRepositoryProvider.overrideWithValue(
              EventSuccessRepository(firestore),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(uidProvider);
              return MaterialApp(
                theme: AppTheme.light,
                home: EventSuccessCompanionScreen(
                  event: event,
                  plan: plan,
                  userProfile: buildUser(),
                  participation: buildEventParticipation(
                    event: event,
                    uid: 'runner-1',
                    status: EventParticipationStatus.attended,
                  ),
                  wingmanRequestCandidates: [
                    buildPublicProfile(
                      uid: 'runner-2',
                      name: 'Rhea',
                      gender: Gender.woman,
                    ),
                  ],
                  now: start.add(const Duration(hours: 2)),
                  onSubmitFeedback: (feedback) async {
                    await EventSuccessController.feedbackMutation.run(
                      ref,
                      (tx) => tx
                          .get(eventSuccessControllerProvider.notifier)
                          .submitFeedback(feedback),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Event companion'), findsOneWidget);
      expect(find.text('Social prompt'), findsNothing);
      expect(find.text('Private afterglow'), findsOneWidget);
      expect(find.textContaining('not a public share card'), findsOneWidget);
      expect(find.text('Suggested first-message openers'), findsOneWidget);
      expect(find.textContaining('compare routes'), findsOneWidget);
      final copyOpener = findFirstByTooltip('Copy opener');
      await tester.ensureVisible(copyOpener);
      await tester.pump();
      expect(copyOpener, findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('How did it feel?'),
        400,
        scrollable: findPrimaryScrollable(),
      );
      expect(find.text('Submit feedback'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Submit feedback'),
        400,
        scrollable: findPrimaryScrollable(),
      );
      final safetyConcernToggle = _toggle(
        'I want Catch to review a safety or comfort concern',
      );
      await tester.ensureVisible(safetyConcernToggle);
      await tester.pump();
      await tester.tap(safetyConcernToggle);
      await tester.pump();
      await tester.drag(findPrimaryScrollable(), const Offset(0, -180));
      await tester.pump();
      await tester.tap(find.text('Submit feedback'));
      await pumpFeatureUi(tester);

      final feedback = await firestore
          .collection('eventSuccessFeedback')
          .doc('event-1_runner-1')
          .get();
      expect(feedback.data()?['welcomeRating'], 4);
      expect(feedback.data()?['safetyConcern'], true);
    },
  );

  testWidgets('companion screen shows assigned micro-pod card', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 18, 7);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event);
    final assignment = EventSuccessAssignment(
      id: eventSuccessAssignmentId(
        eventId: event.id,
        moduleId: EventSuccessModuleCatalog.microPods.id,
        uid: 'runner-1',
      ),
      eventId: event.id,
      clubId: event.clubId,
      uid: 'runner-1',
      moduleId: EventSuccessModuleCatalog.microPods.id,
      label: 'Pod A',
      displayTitle: 'Pod A',
      displaySubtitle: '4 people in this event pod.',
      peerUids: const ['runner-2', 'runner-3', 'runner-4'],
      source: 'server_v1',
      createdAt: start,
      updatedAt: start,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionScreen(
            event: event,
            plan: plan,
            userProfile: buildUser(),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
              status: EventParticipationStatus.attended,
            ),
            wingmanRequestCandidates: const [],
            assignment: assignment,
            assignmentPeerProfiles: [
              buildPublicProfile(
                uid: 'runner-2',
                name: 'Rhea',
                gender: Gender.woman,
              ),
              buildPublicProfile(uid: 'runner-3', name: 'Naina'),
            ],
            now: start.subtract(const Duration(hours: 1)),
          ),
        ),
      ),
    );

    expect(find.text('Pod A'), findsOneWidget);
    expect(find.text('4 people in this event pod.'), findsOneWidget);
    expect(find.text('4 people'), findsOneWidget);
    expect(find.text('Rhea'), findsOneWidget);
    expect(find.text('Naina'), findsOneWidget);
  });

  testWidgets('companion screen shows rotating group slots as tables', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 18, 7);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event);
    final assignment = EventSuccessAssignment(
      id: eventSuccessAssignmentId(
        eventId: event.id,
        moduleId: EventSuccessModuleCatalog.microPods.id,
        uid: 'runner-1',
      ),
      eventId: event.id,
      clubId: event.clubId,
      uid: 'runner-1',
      moduleId: EventSuccessModuleCatalog.microPods.id,
      label: 'Table rotations',
      displayTitle: '2 table rotations',
      displaySubtitle: '20-minute tables across the event.',
      peerUids: const ['runner-2', 'runner-3', 'runner-4', 'runner-5'],
      groupRotationSlots: [
        EventSuccessGroupRotationSlot(
          roundIndex: 0,
          label: 'Round 1',
          unitLabel: 'Table A',
          startsAt: start,
          endsAt: start.add(const Duration(minutes: 20)),
          peerUids: const ['runner-2', 'runner-3'],
          compatibility: 'mixed',
        ),
        EventSuccessGroupRotationSlot(
          roundIndex: 1,
          label: 'Round 2',
          unitLabel: 'Table B',
          startsAt: start.add(const Duration(minutes: 20)),
          endsAt: start.add(const Duration(minutes: 40)),
          peerUids: const ['runner-4', 'runner-5'],
          compatibility: 'social',
        ),
      ],
      source: 'server_v1',
      createdAt: start,
      updatedAt: start,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionScreen(
            event: event,
            plan: plan,
            userProfile: buildUser(),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
              status: EventParticipationStatus.attended,
            ),
            wingmanRequestCandidates: const [],
            assignment: assignment,
            assignmentPeerProfiles: [
              buildPublicProfile(uid: 'runner-2', name: 'Rhea'),
              buildPublicProfile(uid: 'runner-3', name: 'Naina'),
              buildPublicProfile(uid: 'runner-4', name: 'Kabir'),
              buildPublicProfile(uid: 'runner-5', name: 'Dev'),
            ],
            now: start.subtract(const Duration(hours: 1)),
          ),
        ),
      ),
    );

    expect(find.text('2 table rotations'), findsOneWidget);
    expect(find.text('Round 1'), findsOneWidget);
    expect(find.text('Table A'), findsOneWidget);
    expect(find.text('Round 2'), findsOneWidget);
    expect(find.text('Table B'), findsOneWidget);
    expect(find.text('Rhea'), findsOneWidget);
    expect(find.text('Naina'), findsOneWidget);
    expect(find.text('Kabir'), findsOneWidget);
    expect(find.text('Dev'), findsOneWidget);
  });

  testWidgets('companion screen shows assigned rotation schedule', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 18, 7);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = _withoutModule(
      _racketPlan(event),
      EventSuccessModuleCatalog.liveReveal.id,
    );
    final assignment = _rotationAssignment(
      event: event,
      uid: 'runner-1',
      peerUid: 'runner-2',
      now: start,
      roundCount: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionScreen(
            event: event,
            plan: plan,
            userProfile: buildUser(),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
              status: EventParticipationStatus.attended,
            ),
            wingmanRequestCandidates: const [],
            rotationAssignment: assignment,
            rotationPeerProfiles: [
              buildPublicProfile(
                uid: 'runner-2',
                name: 'Rhea',
                gender: Gender.woman,
              ),
            ],
            now: start.subtract(const Duration(hours: 1)),
          ),
        ),
      ),
    );

    expect(find.text('1 guided rotation'), findsOneWidget);
    expect(find.text('Round 1'), findsOneWidget);
    expect(find.textContaining('Rhea'), findsOneWidget);
    expect(find.text('Include me in timed rotations'), findsOneWidget);
  });

  testWidgets('companion live reveal hides rotation partner until revealed', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 18, 7);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = _racketPlan(event).copyWith(
      activeStepIndex: 1,
      revealStatus: EventSuccessRevealStatus.countingDown,
      activeRevealRoundIndex: 0,
      revealStartedAt: start.subtract(const Duration(seconds: 2)),
    );
    final assignment = _rotationAssignment(
      event: event,
      uid: 'runner-1',
      peerUid: 'runner-2',
      now: start,
      roundCount: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionScreen(
            event: event,
            plan: plan,
            userProfile: buildUser(),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
              status: EventParticipationStatus.attended,
            ),
            wingmanRequestCandidates: const [],
            rotationAssignment: assignment,
            rotationPeerProfiles: [
              buildPublicProfile(
                uid: 'runner-2',
                name: 'Rhea',
                gender: Gender.woman,
              ),
            ],
            now: start.subtract(const Duration(hours: 1)),
          ),
        ),
      ),
    );

    expect(find.text('Rotation reveal'), findsWidgets);
    expect(find.text('Room hold'), findsOneWidget);
    expect(find.text('The room is holding together.'), findsOneWidget);
    expect(find.text('No names shown yet'), findsWidgets);
    expect(find.textContaining('Next reveal in'), findsOneWidget);
    expect(find.textContaining('Rhea'), findsNothing);
  });

  testWidgets('companion live reveal shows unlocked rotation partner', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 18, 7);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = _racketPlan(event).copyWith(
      activeStepIndex: 1,
      revealStatus: EventSuccessRevealStatus.revealed,
      activeRevealRoundIndex: 0,
    );
    final assignment = _rotationAssignment(
      event: event,
      uid: 'runner-1',
      peerUid: 'runner-2',
      now: start,
      roundCount: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionScreen(
            event: event,
            plan: plan,
            userProfile: buildUser(),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
              status: EventParticipationStatus.attended,
            ),
            wingmanRequestCandidates: const [],
            rotationAssignment: assignment,
            rotationPeerProfiles: [
              buildPublicProfile(
                uid: 'runner-2',
                name: 'Rhea',
                gender: Gender.woman,
              ),
            ],
            now: start.subtract(const Duration(hours: 1)),
          ),
        ),
      ),
    );

    expect(find.text('Revealed'), findsOneWidget);
    expect(find.text('Unlocked together'), findsOneWidget);
    expect(find.textContaining('Rhea'), findsOneWidget);
    expect(find.textContaining('stronger interest'), findsOneWidget);
  });

  testWidgets('companion reveal dispatches a single stable reveal effect', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final effects = _FakeEventSuccessLiveEffectsController();
    final start = DateTime(2026, 5, 18, 7);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = _racketPlan(event).copyWith(
      activeStepIndex: 1,
      revealStatus: EventSuccessRevealStatus.revealed,
      activeRevealRoundIndex: 0,
    );
    final assignment = _rotationAssignment(
      event: event,
      uid: 'runner-1',
      peerUid: 'runner-2',
      now: start,
      roundCount: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventSuccessLiveEffectsControllerProvider.overrideWithValue(effects),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionScreen(
            event: event,
            plan: plan,
            userProfile: buildUser(),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
              status: EventParticipationStatus.attended,
            ),
            wingmanRequestCandidates: const [],
            rotationAssignment: assignment,
            rotationPeerProfiles: [
              buildPublicProfile(
                uid: 'runner-2',
                name: 'Rhea',
                gender: Gender.woman,
              ),
            ],
            now: start.subtract(const Duration(hours: 1)),
            onPlayLiveEffect: effects.play,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(effects.playedKinds, [
      EventSuccessLiveEffectKind.assignmentRevealed,
    ]);
  });

  testWidgets(
    'companion screen hides stale rotation assignment after opt-out',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final start = DateTime(2026, 5, 18, 7);
      final event = _racketEvent(
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
      );
      final plan = _withoutModule(
        _racketPlan(event),
        EventSuccessModuleCatalog.liveReveal.id,
      );
      final assignment = _rotationAssignment(
        event: event,
        uid: 'runner-1',
        peerUid: 'runner-2',
        now: start,
        roundCount: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: EventSuccessCompanionScreen(
              event: event,
              plan: plan,
              userProfile: buildUser(),
              participation: buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
              wingmanRequestCandidates: const [],
              rotationAssignment: assignment,
              guidedRotationsOptedOut: true,
              now: start.subtract(const Duration(hours: 1)),
            ),
          ),
        ),
      );

      expect(find.text('Timed rotations paused for you'), findsOneWidget);
      expect(
        find.text("You won't be included when the host runs the generator."),
        findsOneWidget,
      );
      expect(find.text('Include me in timed rotations'), findsOneWidget);
      expect(find.text('1 guided rotation'), findsNothing);
    },
  );

  testWidgets('companion screen hides stale pod assignment after opt-out', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 18, 7);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event);
    final assignment = _assignment(
      event: event,
      uid: 'runner-1',
      label: 'Pod A',
      now: start,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionScreen(
            event: event,
            plan: plan,
            userProfile: buildUser(),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
              status: EventParticipationStatus.attended,
            ),
            wingmanRequestCandidates: const [],
            assignment: assignment,
            microPodsOptedOut: true,
            now: start.subtract(const Duration(hours: 1)),
          ),
        ),
      ),
    );

    expect(find.text('Starter groups paused for you'), findsOneWidget);
    expect(
      find.text("You won't be included when the host runs the generator."),
      findsOneWidget,
    );
    expect(find.text('Include me in starter groups'), findsOneWidget);
    expect(find.text('Pod A'), findsNothing);
  });

  testWidgets('companion route fetches assigned podmate public profiles', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final firestore = FakeFirebaseFirestore();
    final event = buildEvent();
    final plan = EventSuccessPlan.defaultForEvent(event);
    final assignment = _assignment(
      event: event,
      uid: 'runner-1',
      label: 'Pod A',
      now: DateTime(2026, 5, 21, 8),
    ).copyWithPeerUids(['runner-2', 'runner-3']);
    await firestore
        .collection('eventSuccessAssignments')
        .doc(assignment.id)
        .set(assignment.toJson());
    await firestore
        .collection('publicProfiles')
        .doc('runner-2')
        .set(
          buildPublicProfile(
            uid: 'runner-2',
            name: 'Rhea',
            gender: Gender.woman,
          ).toJson(),
        );
    await firestore
        .collection('publicProfiles')
        .doc('runner-3')
        .set(buildPublicProfile(uid: 'runner-3', name: 'Naina').toJson());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchEventProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(event)),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser()),
          ),
          watchEventParticipationProvider(event.id, 'runner-1').overrideWith(
            (ref) => Stream.value(
              buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
            ),
          ),
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(plan)),
          eventSuccessRepositoryProvider.overrideWithValue(
            EventSuccessRepository(firestore),
          ),
          publicProfileRepositoryProvider.overrideWithValue(
            PublicProfileRepository(firestore),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionRouteScreen(
            clubId: event.clubId,
            eventId: event.id,
            initialEvent: event,
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Pod A'), findsOneWidget);
    expect(find.text('Rhea'), findsOneWidget);
    expect(find.text('Naina'), findsOneWidget);
  });

  testWidgets('companion route fetches assigned rotation partner profiles', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final firestore = FakeFirebaseFirestore();
    final start = DateTime.now().add(const Duration(minutes: 10));
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );
    final plan = _withoutModule(
      _racketPlan(event),
      EventSuccessModuleCatalog.liveReveal.id,
    );
    final assignment = _rotationAssignment(
      event: event,
      uid: 'runner-1',
      peerUid: 'runner-2',
      now: start,
      roundCount: 1,
    );
    await firestore
        .collection('eventSuccessAssignments')
        .doc(assignment.id)
        .set(assignment.toJson());
    await firestore
        .collection('publicProfiles')
        .doc('runner-2')
        .set(
          buildPublicProfile(
            uid: 'runner-2',
            name: 'Rhea',
            gender: Gender.woman,
          ).toJson(),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchEventProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(event)),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser()),
          ),
          watchEventParticipationProvider(event.id, 'runner-1').overrideWith(
            (ref) => Stream.value(
              buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
            ),
          ),
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(plan)),
          eventSuccessRepositoryProvider.overrideWithValue(
            EventSuccessRepository(firestore),
          ),
          publicProfileRepositoryProvider.overrideWithValue(
            PublicProfileRepository(firestore),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionRouteScreen(
            clubId: event.clubId,
            eventId: event.id,
            initialEvent: event,
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('1 guided rotation'), findsOneWidget);
    expect(find.text('Round 1'), findsOneWidget);
    expect(find.textContaining('Rhea'), findsOneWidget);
  });

  testWidgets(
    'companion hides post-event sections when their modules are disabled',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final start = DateTime(2026, 5, 18, 7);
      final event = buildEvent(
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
      );
      final plan = EventSuccessPlan.defaultForEvent(
        event,
      ).copyWith(selectedModuleIds: [EventSuccessModuleCatalog.checkIn.id]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: EventSuccessCompanionScreen(
              event: event,
              plan: plan,
              userProfile: buildUser(),
              participation: buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
              wingmanRequestCandidates: [
                buildPublicProfile(
                  uid: 'runner-2',
                  name: 'Rhea',
                  gender: Gender.woman,
                ),
              ],
              now: start.add(const Duration(hours: 2)),
            ),
          ),
        ),
      );

      expect(find.text('Ask host for help'), findsNothing);
      expect(find.text('How did it feel?'), findsNothing);
      expect(find.text('The host is running the room'), findsOneWidget);
    },
  );

  testWidgets('companion route is unavailable until host saves setup', (
    tester,
  ) async {
    final event = buildEvent(id: 'event-no-plan');
    final participation = buildEventParticipation(
      event: event,
      uid: 'runner-1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchEventProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(event)),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser()),
          ),
          watchEventParticipationProvider(
            event.id,
            'runner-1',
          ).overrideWith((ref) => Stream.value(participation)),
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionRouteScreen(
            clubId: event.clubId,
            eventId: event.id,
            initialEvent: event,
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Companion not available'), findsOneWidget);
    expect(
      find.text(
        'The host has not enabled the live event guide for this event yet.',
      ),
      findsOneWidget,
    );
    expect(find.text('Social prompt'), findsNothing);
  });
}

EventSuccessPlan _withGuidedRotations(EventSuccessPlan plan) {
  final moduleIds = {
    ...plan.selectedModuleIds,
    EventSuccessModuleCatalog.guidedRotations.id,
  }.toList()..sort();
  return plan.copyWith(selectedModuleIds: moduleIds);
}

EventSuccessPlan _withLiveReveal(EventSuccessPlan plan) {
  final moduleIds = {
    ...plan.selectedModuleIds,
    EventSuccessModuleCatalog.liveReveal.id,
  }.toList()..sort();
  return plan.copyWith(selectedModuleIds: moduleIds);
}

EventSuccessPlan _withoutModule(EventSuccessPlan plan, String moduleId) {
  return plan.copyWith(
    selectedModuleIds: plan.selectedModuleIds
        .where((id) => id != moduleId)
        .toList(growable: false),
  );
}

EventSuccessPlan _racketPlan(Event event) {
  final moduleIds =
      EventSuccessPlaybookLibrary.pickleball.moduleIds
          .where(
            (id) =>
                id != EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
          )
          .toList()
        ..sort();
  return EventSuccessPlan.defaultForEvent(event).copyWith(
    playbookId: EventSuccessPlaybookLibrary.pickleball.id,
    selectedModuleIds: moduleIds,
  );
}

Event _racketEvent({required DateTime startTime, required DateTime endTime}) {
  return buildEvent(
    startTime: startTime,
    endTime: endTime,
    eventFormat: EventFormatSnapshot.fromActivityKind(ActivityKind.pickleball),
    distanceKm: 0,
    meetingPoint: 'Court 2 by the clubhouse',
  );
}

extension on EventSuccessAssignment {
  EventSuccessAssignment copyWithPeerUids(List<String> peerUids) {
    return EventSuccessAssignment(
      id: id,
      eventId: eventId,
      clubId: clubId,
      uid: this.uid,
      moduleId: moduleId,
      label: label,
      displayTitle: displayTitle,
      displaySubtitle: displaySubtitle,
      peerUids: peerUids,
      rotationSlots: rotationSlots,
      groupRotationSlots: groupRotationSlots,
      source: source,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

EventSuccessAssignment _assignment({
  required Event event,
  required String uid,
  required String label,
  required DateTime now,
}) {
  return EventSuccessAssignment(
    id: eventSuccessAssignmentId(
      eventId: event.id,
      moduleId: EventSuccessModuleCatalog.microPods.id,
      uid: uid,
    ),
    eventId: event.id,
    clubId: event.clubId,
    uid: uid,
    moduleId: EventSuccessModuleCatalog.microPods.id,
    label: label,
    displayTitle: label,
    displaySubtitle: 'Generated pod.',
    peerUids: const [],
    source: 'server_v1',
    createdAt: now,
    updatedAt: now,
  );
}

EventSuccessAssignment _rotationAssignment({
  required Event event,
  required String uid,
  required String peerUid,
  required DateTime now,
  required int roundCount,
  String source = 'server_v1',
}) {
  return EventSuccessAssignment(
    id: eventSuccessAssignmentId(
      eventId: event.id,
      moduleId: EventSuccessModuleCatalog.guidedRotations.id,
      uid: uid,
    ),
    eventId: event.id,
    clubId: event.clubId,
    uid: uid,
    moduleId: EventSuccessModuleCatalog.guidedRotations.id,
    label: 'Guided rotations',
    displayTitle: '$roundCount guided rotation${roundCount == 1 ? '' : 's'}',
    displaySubtitle: '15-minute pairings during the event.',
    peerUids: [peerUid],
    rotationSlots: [
      for (var index = 0; index < roundCount; index++)
        EventSuccessRotationSlot(
          roundIndex: index,
          label: 'Round ${index + 1}',
          startsAt: now.add(Duration(minutes: index * 15)),
          endsAt: now.add(Duration(minutes: (index + 1) * 15)),
          peerUid: peerUid,
          compatibility: 'mutual_interest',
        ),
    ],
    source: source,
    createdAt: now,
    updatedAt: now,
  );
}

EventSuccessWingmanRequest _wingmanRequest({
  required Event event,
  required String requesterUid,
  required String targetUid,
  required DateTime now,
  String? note,
}) {
  return EventSuccessWingmanRequest(
    id: eventSuccessWingmanRequestId(eventId: event.id, uid: requesterUid),
    eventId: event.id,
    clubId: event.clubId,
    requesterUid: requesterUid,
    targetUid: targetUid,
    status: EventSuccessWingmanRequestStatus.active,
    hostVisibleConsent: true,
    note: note,
    createdAt: now,
    updatedAt: now,
  );
}

Finder _toggle(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is CatchToggle && widget.semanticLabel == label,
  );
}

class _WingmanTestFirebaseFunctions extends Fake implements FirebaseFunctions {
  _WingmanTestFirebaseFunctions(this._firestore, {required this.requesterUid});

  final FirebaseFirestore _firestore;
  final String requesterUid;

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return _WingmanTestHttpsCallable(
      name,
      firestore: _firestore,
      requesterUid: requesterUid,
    );
  }
}

class _FakeEventSuccessLiveEffectsController
    extends EventSuccessLiveEffectsController {
  _FakeEventSuccessLiveEffectsController();

  final List<EventSuccessLiveEffectKind> playedKinds = [];

  @override
  Future<void> play(EventSuccessLiveEffectKind kind) async {
    playedKinds.add(kind);
  }
}

class _WingmanTestHttpsCallable extends Fake implements HttpsCallable {
  _WingmanTestHttpsCallable(
    this.name, {
    required this._firestore,
    required this.requesterUid,
  });

  final String name;
  final FirebaseFirestore _firestore;
  final String requesterUid;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    final payload = Map<String, Object?>.from(parameters as Map);
    final eventId = payload['eventId'] as String;
    if (name == 'submitEventSuccessWingmanRequest') {
      final now = Timestamp.fromDate(DateTime(2026, 5, 21));
      await _firestore
          .collection('eventSuccessWingmanRequests')
          .doc(
            eventSuccessWingmanRequestId(eventId: eventId, uid: requesterUid),
          )
          .set({
            'eventId': eventId,
            'clubId': 'club-1',
            'requesterUid': requesterUid,
            'targetUid': payload['targetUid'],
            'status': 'active',
            'hostVisibleConsent': true,
            'note': payload['note'],
            'createdAt': now,
            'updatedAt': now,
          });
    } else if (name == 'withdrawEventSuccessWingmanRequest') {
      await _firestore
          .collection('eventSuccessWingmanRequests')
          .doc(
            eventSuccessWingmanRequestId(eventId: eventId, uid: requesterUid),
          )
          .update({'status': 'withdrawn'});
    }
    return _WingmanTestHttpsCallableResult<T>(null as T);
  }
}

class _WingmanTestHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  _WingmanTestHttpsCallableResult(this.dataValue);

  final T dataValue;

  @override
  T get data => dataValue;
}
