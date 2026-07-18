import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_attendance_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('roster table uses person rows on compact widths', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _wrap(
        const CatchRosterTable(
          columns: ['Guest', 'Status', 'Action'],
          rows: [
            CatchRosterRow(
              person: 'Taylor',
              meta: 'Booked',
              signal: 'Arrived',
              action: CatchRosterTextAction('Paid'),
            ),
          ],
        ),
      ),
    );

    expect(find.byType(CatchPersonRow), findsOneWidget);
    expect(find.text('GUEST'), findsNothing);
    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('Arrived'), findsOneWidget);
  });

  testWidgets('roster table preserves its tabular layout on wide widths', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _wrap(
        const CatchRosterTable(
          columns: ['Guest', 'Status', 'Action'],
          rows: [
            CatchRosterRow(
              person: 'Taylor',
              signal: 'Arrived',
              action: CatchRosterTextAction('Paid'),
            ),
          ],
        ),
      ),
    );

    expect(find.byType(CatchPersonRow), findsNothing);
    expect(find.text('GUEST'), findsOneWidget);
    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('ACTION'), findsOneWidget);
  });

  testWidgets(
    'host roster controls use canonical search and metric primitives',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              HostRosterFilterHeader(
                title: 'Participation',
                subtitle: 'Review attendance.',
                filters: const [
                  HostRosterFilterSpec(
                    filter: HostRosterFilter.all,
                    label: 'All',
                    value: 2,
                    tone: CatchBadgeTone.neutral,
                  ),
                  HostRosterFilterSpec(
                    filter: HostRosterFilter.attended,
                    label: 'Attended',
                    value: 1,
                    tone: CatchBadgeTone.success,
                  ),
                ],
                selectedFilter: HostRosterFilter.all,
                onFilterChanged: (_) {},
              ),
              HostRosterSearchBar(
                value: '',
                label: 'Search roster',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      );

      expect(find.byType(CatchMetricStrip), findsOneWidget);
      expect(find.byType(CatchSearchField), findsOneWidget);
    },
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SafeArea(child: child)),
  );
}
