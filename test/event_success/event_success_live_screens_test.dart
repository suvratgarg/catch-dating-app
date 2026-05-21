import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart'
    show buildEvent, buildEventParticipation, buildPublicProfile, buildUser;

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
                  feedback: const [],
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Setup'), findsWidgets);
    expect(find.text('Target attendees'), findsOneWidget);
    expect(find.text('Event structure'), findsWidgets);
    expect(find.text('Host goal'), findsOneWidget);
    expect(find.text('Attendee prompt'), findsOneWidget);
    expect(find.text('Recommended setup'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Default on'), findsOneWidget);
    expect(find.text('Recommended'), findsWidgets);
    expect(find.text('Delivery moments'), findsOneWidget);
    expect(find.text('Wingman requests'), findsWidgets);
    expect(find.text('Post-match openers'), findsWidgets);
    expect(find.text('Save setup'), findsOneWidget);

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();
    expect(find.text('Live host mode'), findsOneWidget);
    expect(find.text('Conversation cues'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(find.text('Post-event host report'), findsOneWidget);
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
                  feedback: const [],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                  embedded: true,
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
    expect(find.text('Mark event-success plan complete'), findsNothing);
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
                  feedback: const [],
                  initialTab: EventSuccessHostTab.report,
                  showTabs: false,
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Host analytics disabled'), findsOneWidget);
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
                  feedback: [
                    _feedback(event: event, uid: 'runner-1', now: now),
                    _feedback(event: event, uid: 'runner-2', now: now),
                  ],
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
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Host signal quality'), findsOneWidget);
    expect(find.text('Feedback 40%'), findsOneWidget);
    expect(find.text('Assignment coverage 80%'), findsOneWidget);
    expect(find.text('Assignment opt-out 20%'), findsOneWidget);
    expect(find.text('Wingman help 20%'), findsOneWidget);
    expect(find.text('2/5 feedback'), findsOneWidget);
    expect(find.text('4 assigned'), findsOneWidget);
    expect(find.text('1 opted out'), findsOneWidget);
    expect(find.text('1 wingman requests'), findsOneWidget);
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
                  feedback: const [],
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
                  embedded: true,
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
                  feedback: const [],
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
                  embedded: true,
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
                  feedback: const [],
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
                    buildPublicProfile(uid: 'runner-1', name: 'Arjun'),
                    buildPublicProfile(
                      uid: 'runner-2',
                      name: 'Rhea',
                      gender: Gender.woman,
                    ),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Wingman requests'), findsOneWidget);
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
                  feedback: const [],
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
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Guided rotations'), findsOneWidget);
    expect(find.text('2 rounds'), findsOneWidget);
    expect(find.text('2 assigned'), findsOneWidget);
    expect(find.text('2 possible'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
    expect(find.text('Edit rotations'), findsOneWidget);
  });

  testWidgets('host live mode shows the countdown reveal console', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 2200);
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
                  feedback: const [],
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
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Live reveal'), findsOneWidget);
    expect(find.text('Rotation reveal'), findsOneWidget);
    expect(find.text('Create the next room-wide beat'), findsOneWidget);
    expect(find.text('Drop 10s countdown'), findsOneWidget);
    expect(find.text('Reveal now'), findsOneWidget);
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
                  feedback: const [],
                  rotationAssignments: const [],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Guided rotations'), findsOneWidget);
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
                  feedback: const [],
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
                  embedded: true,
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
                  feedback: const [],
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
                    buildPublicProfile(uid: 'runner-1', name: 'Arjun'),
                    buildPublicProfile(
                      uid: 'runner-2',
                      name: 'Rhea',
                      gender: Gender.woman,
                    ),
                  ],
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit rotations'));
    await tester.pumpAndSettle();

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
                  feedback: const [],
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
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Guided rotations'), findsOneWidget);
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
                EventParticipationRepository(firestore),
                PublicProfileRepository(firestore),
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
                  userProfile: buildUser(uid: 'runner-1'),
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
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Ask the host to help'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Host visible'), findsOneWidget);
      expect(find.text('Rhea'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Ask host'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Ask host'));
      await tester.pumpAndSettle();

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
                uid: 'runner-1',
                gender: Gender.woman,
                interestedInGenders: const [Gender.man],
              ),
              participation: buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
              wingmanRequestCandidates: [
                buildPublicProfile(
                  uid: 'runner-2',
                  name: 'Arjun',
                  gender: Gender.man,
                ),
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
        find.text('Ask the host to help'),
        400,
        scrollable: find.byType(Scrollable).first,
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
            userProfile: buildUser(uid: 'runner-1'),
            participation: buildEventParticipation(
              event: event,
              uid: 'runner-1',
              status: EventParticipationStatus.signedUp,
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

    expect(find.text('Before you arrive'), findsOneWidget);
    expect(find.text('Pre-arrival'), findsOneWidget);
    expect(find.text('Skip micro-pods'), findsOneWidget);
    expect(find.text('Skip rotations'), findsOneWidget);
    expect(find.text('Social prompt'), findsNothing);
    expect(find.text('Conversation cues'), findsNothing);
    expect(find.text('Rotation reveal'), findsNothing);
    expect(find.text('Waiting for the host reveal'), findsNothing);
    expect(find.textContaining('Rhea'), findsNothing);
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
            EventSuccessRepository(
              firestore,
              EventParticipationRepository(firestore),
              PublicProfileRepository(firestore),
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
                userProfile: buildUser(uid: 'runner-1'),
                participation: buildEventParticipation(
                  event: event,
                  uid: 'runner-1',
                  status: EventParticipationStatus.signedUp,
                ),
                wingmanRequestCandidates: const [],
                now: start.add(const Duration(minutes: 30)),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Compatibility questionnaire'), findsOneWidget);
    expect(find.text('Can affect rotations'), findsOneWidget);

    await tester.tap(find.text('A shared activity'));
    await tester.pump();
    await tester.tap(find.text('Save answers'));
    await tester.pumpAndSettle();

    final saved = await firestore
        .collection('eventSuccessCompatibilityResponses')
        .doc('event-1_runner-1')
        .get();
    expect(saved.data()?['answerIds'], ['first_conversation_activity']);
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
            (ref) => Stream.value(buildUser(uid: 'runner-1')),
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
            EventSuccessRepository(
              firestore,
              EventParticipationRepository(firestore),
              PublicProfileRepository(firestore),
            ),
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
    await tester.pumpAndSettle();

    expect(find.text('Compatibility questionnaire'), findsOneWidget);
    expect(find.text('Can affect rotations'), findsOneWidget);
    expect(
      find.text('No companion actions are active for this event.'),
      findsNothing,
    );
  });

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
              EventSuccessRepository(
                firestore,
                EventParticipationRepository(firestore),
                PublicProfileRepository(firestore),
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
                  userProfile: buildUser(uid: 'runner-1'),
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
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Event companion'), findsOneWidget);
      expect(find.text('Social prompt'), findsNothing);
      expect(find.text('Post-match openers'), findsOneWidget);
      expect(find.textContaining('compare routes'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Event feedback'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Submit feedback'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Submit feedback'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -180));
      await tester.pump();
      await tester.tap(find.text('Submit feedback'));
      await tester.pumpAndSettle();

      final feedback = await firestore
          .collection('eventSuccessFeedback')
          .doc('event-1_runner-1')
          .get();
      expect(feedback.data()?['welcomeRating'], 4);
      expect(feedback.data()?['safetyConcern'], false);
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
            userProfile: buildUser(uid: 'runner-1'),
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
            userProfile: buildUser(uid: 'runner-1'),
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
    expect(find.text('Skip rotations'), findsOneWidget);
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
      revealEndsAt: start.add(const Duration(seconds: 8)),
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
            userProfile: buildUser(uid: 'runner-1'),
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

    expect(find.text('Rotation reveal'), findsOneWidget);
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
            userProfile: buildUser(uid: 'runner-1'),
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
    expect(find.textContaining('Rhea'), findsOneWidget);
    expect(find.textContaining('compatibility signal'), findsOneWidget);
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
              userProfile: buildUser(uid: 'runner-1'),
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

      expect(find.text('Rotations paused for you'), findsOneWidget);
      expect(
        find.text(
          'You will not be included when the host generates timed rotations.',
        ),
        findsOneWidget,
      );
      expect(find.text('Join rotations'), findsOneWidget);
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
            userProfile: buildUser(uid: 'runner-1'),
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

    expect(find.text('Micro-pods paused for you'), findsOneWidget);
    expect(
      find.text('You will not be included when the host generates pods.'),
      findsOneWidget,
    );
    expect(find.text('Join micro-pods'), findsOneWidget);
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
            (ref) => Stream.value(buildUser(uid: 'runner-1')),
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
            EventSuccessRepository(
              firestore,
              EventParticipationRepository(firestore),
              PublicProfileRepository(firestore),
            ),
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
    await tester.pumpAndSettle();

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
            (ref) => Stream.value(buildUser(uid: 'runner-1')),
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
            EventSuccessRepository(
              firestore,
              EventParticipationRepository(firestore),
              PublicProfileRepository(firestore),
            ),
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
    await tester.pumpAndSettle();

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
              userProfile: buildUser(uid: 'runner-1'),
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
      expect(find.text('Event feedback'), findsNothing);
      expect(
        find.text('No companion actions are active for this event.'),
        findsOneWidget,
      );
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
            (ref) => Stream.value(buildUser(uid: 'runner-1')),
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
    await tester.pumpAndSettle();

    expect(find.text('Companion not available'), findsOneWidget);
    expect(
      find.text(
        'The host has not enabled event companion tools for this event yet.',
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

EventSuccessFeedback _feedback({
  required Event event,
  required String uid,
  required DateTime now,
}) {
  return EventSuccessFeedback(
    id: eventSuccessFeedbackId(eventId: event.id, uid: uid),
    eventId: event.id,
    clubId: event.clubId,
    uid: uid,
    welcomeRating: 5,
    structureRating: 4,
    metNewPeopleCount: 3,
    safetyConcern: false,
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
