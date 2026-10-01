import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/programs/data/program_setup_repository.dart';
import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_guest_desk_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_list_screen.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

const _guests = ProgramGuestListPage(
  programId: 'program',
  guests: [
    ProgramGuestRow(
      guestId: 'guest',
      displayName: 'Guest',
      householdId: 'household',
      groupIds: [],
      invitationStatus: 'invited',
      rsvpStatus: 'pending',
      revision: 1,
    ),
  ],
  households: [
    ProgramHouseholdRow(
      householdId: 'household',
      label: 'Household',
      memberGuestIds: ['guest'],
      revision: 1,
    ),
  ],
  functionGuests: [],
  groups: [],
);

ProgramWorkAccess _access(
  ProgramStaffDuty duty, {
  ProgramStatus status = ProgramStatus.active,
  bool expired = false,
}) {
  final expiry = DateTime.now().add(Duration(hours: expired ? -1 : 1));
  return ProgramWorkAccess(
    programId: 'program',
    organizerId: 'organizer',
    title: 'Program',
    kind: ProgramKind.wedding,
    timezone: 'Asia/Kolkata',
    status: status,
    actorRole: ProgramActorRole.staff,
    duties: [
      ProgramDutyAssignment(
        duty: duty,
        pickupPointIds: {},
        hotelIds: {},
        functionIds: {},
        expiresAt: expiry,
      ),
    ],
    grantExpiresAt: expiry,
    capabilities: {},
    pickupPoints: [],
    hotels: [],
    functions: [],
    vehicleClasses: [],
  );
}

void main() {
  for (final duty in [
    ProgramStaffDuty.guestRelations,
    ProgramStaffDuty.programCoordinator,
  ]) {
    testWidgets('$duty can share RSVP links with independent edit authority', (
      tester,
    ) async {
      final access = _access(duty);
      await tester.pumpWidget(
        ProviderScope(
          // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
          overrides: [
            programWorkEntryProvider('program', null).overrideWith(
              (ref) async =>
                  (value: access, snapshotAt: null, snapshotExpiresAt: null),
            ),
            programGuestListProvider(
              'program',
            ).overrideWith((ref) async => _guests),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ProgramGuestDeskScreen(programId: 'program'),
          ),
        ),
      );
      await pumpFeatureUi(tester);
      expect(find.byTooltip('Share RSVP link'), findsOneWidget);
      expect(
        find.text('Add guest'),
        duty == ProgramStaffDuty.programCoordinator
            ? findsOneWidget
            : findsNothing,
      );
    });
  }

  testWidgets('archived guest desk does not offer RSVP link issuance', (
    tester,
  ) async {
    final access = _access(
      ProgramStaffDuty.guestRelations,
      status: ProgramStatus.archived,
    );
    await tester.pumpWidget(
      ProviderScope(
        // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
        overrides: [
          programWorkEntryProvider('program', null).overrideWith(
            (ref) async =>
                (value: access, snapshotAt: null, snapshotExpiresAt: null),
          ),
          programGuestListProvider(
            'program',
          ).overrideWith((ref) async => _guests),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ProgramGuestDeskScreen(programId: 'program'),
        ),
      ),
    );
    await pumpFeatureUi(tester);
    expect(find.text('Household'), findsOneWidget);
    expect(find.byTooltip('Share RSVP link'), findsNothing);
  });

  testWidgets('expired guest-relations grant does not expose RSVP sharing', (
    tester,
  ) async {
    final access = _access(ProgramStaffDuty.guestRelations, expired: true);
    await tester.pumpWidget(
      ProviderScope(
        // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
        overrides: [
          programWorkEntryProvider('program', null).overrideWith(
            (ref) async =>
                (value: access, snapshotAt: null, snapshotExpiresAt: null),
          ),
          programGuestListProvider(
            'program',
          ).overrideWith((ref) async => _guests),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ProgramGuestDeskScreen(programId: 'program'),
        ),
      ),
    );
    await pumpFeatureUi(tester);
    expect(find.byTooltip('Share RSVP link'), findsNothing);
  });

  test(
    'legacy archive without a deadline remains restorable as on backend',
    () {
      const program = OrganizerProgramSummary(
        programId: 'program',
        title: 'Program',
        kind: ProgramKind.wedding,
        status: ProgramStatus.archived,
        revision: 1,
      );
      expect(program.canUnarchiveAt(DateTime(2026)), isTrue);
    },
  );

  test(
    'restore grace deadline is exclusive and anonymization is irreversible',
    () {
      final deadline = DateTime(2026, 10, 15);
      OrganizerProgramSummary summary({DateTime? anonymizedAt}) =>
          OrganizerProgramSummary(
            programId: 'program',
            title: 'Program',
            kind: ProgramKind.wedding,
            status: ProgramStatus.archived,
            revision: 7,
            anonymizeAt: deadline,
            anonymizedAt: anonymizedAt,
          );
      expect(
        summary().canUnarchiveAt(
          deadline.subtract(const Duration(milliseconds: 1)),
        ),
        isTrue,
      );
      expect(summary().canUnarchiveAt(deadline), isFalse);
      expect(
        summary().canUnarchiveAt(deadline.add(const Duration(days: 1))),
        isFalse,
      );
      expect(
        summary(
          anonymizedAt: deadline,
        ).canUnarchiveAt(deadline.subtract(const Duration(days: 1))),
        isFalse,
      );
    },
  );

  testWidgets('restore menu is disabled after grace expires before sweep', (
    tester,
  ) async {
    final program = OrganizerProgramSummary(
      programId: 'program',
      title: 'Program',
      kind: ProgramKind.wedding,
      status: ProgramStatus.archived,
      revision: 7,
      anonymizeAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    await tester.pumpWidget(
      ProviderScope(
        // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
        overrides: [
          organizerProgramListProvider(
            'organizer',
          ).overrideWith((ref) async => [program]),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ProgramListPageBody(
            organizerId: 'organizer',
            organizerName: 'Organizer',
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);
    final menu = tester.widget<CatchActionMenu<dynamic>>(
      find.byWidgetPredicate((widget) => widget is CatchActionMenu<dynamic>),
    );
    expect(menu.items.single.enabled, isFalse);
    expect(menu.items.single.sublabel, 'The restore window has ended.');
  });
}
