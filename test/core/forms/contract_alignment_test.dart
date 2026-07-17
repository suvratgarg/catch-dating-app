import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/forms/catch_form_descriptors.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_edit_tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../clubs/clubs_test_helpers.dart';

void main() {
  final l10n = AppLocalizationsEn();

  setUp(() => AppConfig.configureEntrypointRole(AppRole.host));
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  test('consumer profile descriptors stay aligned with patch contracts', () {
    final state = SelfProfileEditTabState.fromProfile(
      l10n: l10n,
      user: buildUser(uid: 'profile-contract-user'),
      today: DateTime(2026, 7, 18),
      uploadState: (loadingIndices: <int>{}, uploadError: null),
    );

    expect(
      _alignmentIssues(state.aboutSectionRows, const {
        'displayName': 'updateUserProfilePatch.displayName',
        'email': 'updateUserProfilePatch.email',
        'instagramHandle': 'updateUserProfilePatch.instagramHandle',
        'height': 'updateUserProfilePatch.height',
        'city': 'updateUserProfilePatch.city',
        'occupation': 'updateUserProfilePatch.occupation',
        'company': 'updateUserProfilePatch.company',
        'education': 'updateUserProfilePatch.education',
        'religion': 'updateUserProfilePatch.religion',
        'relationshipGoal': 'updateUserProfilePatch.relationshipGoal',
      }),
      isEmpty,
    );
  });

  testWidgets('host club descriptors stay aligned with patch contracts', (
    tester,
  ) async {
    final club = buildClub(
      id: 'club-contract',
      ownerUserId: 'host-contract-user',
      instagramHandle: 'catch.club',
      phoneNumber: '+91 98765 43210',
      email: 'hello@catch.club',
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HostClubEditTab(
                club: club,
                currentUid: 'host-contract-user',
                isOwner: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final rows = tester
        .widgetList<CatchFormRowList<UpdateClubPatch>>(
          find.byWidgetPredicate(
            (widget) => widget is CatchFormRowList<UpdateClubPatch>,
          ),
        )
        .expand((list) => list.rows)
        .toList(growable: false);
    expect(
      _alignmentIssues(rows, const {
        'name': 'updateClubPatch.name',
        'location': 'updateClubPatch.location',
        'area': 'updateClubPatch.area',
        'description': 'updateClubPatch.description',
        'instagramHandle': 'updateClubPatch.instagramHandle',
        'phoneNumber': 'updateClubPatch.phoneNumber',
        'email': 'updateClubPatch.email',
      }),
      isEmpty,
    );
  });

  test('seeded overlong UI limit proves the alignment gate is non-vacuous', () {
    final seededDrift = CatchFormTextRow<Object?>(
      id: 'displayName',
      icon: Icons.person,
      label: 'Display name',
      currentValue: 'Catch',
      patchForValue: (value) => value,
      contract: CatchContractConstraints.updateUserProfilePatchDisplayName,
      maxLength:
          CatchContractConstraints
              .updateUserProfilePatchDisplayName
              .maxLength! +
          1,
    );

    expect(
      _alignmentIssues(
        [seededDrift],
        const {'displayName': 'updateUserProfilePatch.displayName'},
      ),
      contains(contains('exceeds contract maxLength')),
    );
  });
}

List<String> _alignmentIssues<P>(
  Iterable<CatchFormRowDescriptor<P>> rows,
  Map<String, String> expectedContracts,
) {
  final issues = <String>[];
  final rowsById = {for (final row in rows) row.id: row};
  for (final entry in expectedContracts.entries) {
    final row = rowsById[entry.key];
    if (row == null) {
      issues.add('${entry.key}: descriptor missing');
      continue;
    }
    final contract = _contractFor(row);
    if (contract == null) {
      issues.add('${entry.key}: contract missing');
      continue;
    }
    if (contract.path != entry.value) {
      issues.add(
        '${entry.key}: expected ${entry.value}, found ${contract.path}',
      );
    }
    if (row case CatchFormTextRow<P>(
      maxLength: final explicitMax?,
    ) when contract.maxLength != null && explicitMax > contract.maxLength!) {
      issues.add(
        '${entry.key}: explicit maxLength $explicitMax exceeds contract '
        'maxLength ${contract.maxLength}',
      );
    }
  }
  return issues;
}

CatchContractFieldConstraints? _contractFor<P>(CatchFormRowDescriptor<P> row) {
  if (row is CatchFormTextRow<P>) return row.contract;
  if (row is CatchFormSingleChoiceRow<P, Labelled>) return row.contract;
  if (row is CatchFormMultiChoiceRow<P, Labelled>) return row.contract;
  if (row is CatchFormRangeRow<P>) return row.contract;
  if (row is CatchFormCustomRow<P>) return row.contract;
  return null;
}
