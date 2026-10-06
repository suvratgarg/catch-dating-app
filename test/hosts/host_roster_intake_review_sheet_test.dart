import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/data/host_roster_intake_repository.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_roster_intake_review_sheet.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  testWidgets('explicit exclusion refreshes review before apply', (
    tester,
  ) async {
    final unresolved = _review(
      eligible: false,
      rows: const [
        HostRosterIntakePreviewRow(
          rowId: '2',
          sourceRowNumber: 2,
          kind: 'needsReview',
          changedFields: [],
          issueCode: 'invalid-phone',
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HostRosterIntakeReviewSheet(
            review: unresolved,
            onExclude: (review, ids) async {
              expect(ids, ['2']);
              return _review(
                eligible: true,
                rows: const [
                  HostRosterIntakePreviewRow(
                    rowId: '2',
                    sourceRowNumber: 2,
                    kind: 'excluded',
                    changedFields: [],
                    issueCode: null,
                  ),
                  HostRosterIntakePreviewRow(
                    rowId: '3',
                    sourceRowNumber: 3,
                    kind: 'add',
                    changedFields: ['displayName'],
                    issueCode: null,
                  ),
                ],
              );
            },
            onApply: (review) async => review,
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    final applyBefore = tester.widget<CatchButton>(
      find.byKey(const ValueKey('host-roster-intake-apply')),
    );
    expect(applyBefore.onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('host-roster-intake-exclude')));
    await pumpFeatureUi(tester);
    expect(find.textContaining('invalid-phone'), findsNothing);
    final applyAfter = tester.widget<CatchButton>(
      find.byKey(const ValueKey('host-roster-intake-apply')),
    );
    expect(applyAfter.onPressed, isNotNull);
  });
}

HostRosterIntakeReview _review({
  required bool eligible,
  required List<HostRosterIntakePreviewRow> rows,
}) => HostRosterIntakeReview(
  sessionId: 'hri_${List.filled(48, 'a').join()}',
  revision: eligible ? 2 : 1,
  fileName: 'guests.csv',
  state: 'review',
  reviewHash: List.filled(64, 'b').join(),
  eligibleForApply: eligible,
  counts: {
    'add': rows.where((row) => row.kind == 'add').length,
    'update': 0,
    'unchanged': 0,
    'excluded': rows.where((row) => row.kind == 'excluded').length,
    'needsReview': rows.where((row) => row.kind == 'needsReview').length,
    'identityConflict': 0,
  },
  rows: rows,
  evidenceRows: const [
    {
      'value': {'rowId': '2', 'displayName': '', 'status': 'registered'},
      'sourceRowNumber': 2,
      'fields': <String, Object?>{},
      'rawCells': <String>['', 'bad'],
      'issues': <String>['invalid-phone'],
    },
  ],
  excludedRowIds: eligible ? const ['2'] : const [],
);
