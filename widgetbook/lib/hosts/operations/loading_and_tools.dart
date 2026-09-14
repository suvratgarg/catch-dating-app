import 'package:catch_dating_app/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/hosts/domain/host_attendance_window.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_club_tools.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_tools.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostRouteLoadingBody,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostSummarySkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostTabRailSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostAnalyticsReportSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostChartSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: CatchSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostInlineSkeletonIcon,
  path: '[P1 product surfaces]/Host operations/Components',
)
Widget hostLoadingSkeletonCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'Host loading skeletons',
    contractId: 'component.host.loading_skeletons',
    children: [
      WidgetbookHostStateCard(
        label: 'route loading body',
        child: WidgetbookHostDeviceFrame(
          child: Scaffold(
            body: HostRouteLoadingBody(
              showTabRail: true,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'summary and tab rail',
        child: Column(
          children: [HostTabRailSkeleton(), gapH12, HostSummarySkeleton()],
        ),
      ),
      WidgetbookHostStateCard(
        label: 'row and settings groups',
        child: Column(
          children: [
            CatchSkeleton.mediaRows(count: 2, divided: true),
            gapH12,
            CatchSkeleton.iconRows(count: 2, divided: true),
          ],
        ),
      ),
      WidgetbookHostStateCard(
        label: 'analytics and roster',
        child: Column(
          children: [
            HostAnalyticsReportSkeleton(),
            gapH12,
            CatchSkeleton.rows(
              count: 3,
              titleWidth: CatchLayout.skeletonTextSectionWidth,
            ),
            gapH12,
            HostInlineSkeletonIcon(),
          ],
        ),
      ),
      WidgetbookHostStateCard(label: 'chart', child: HostChartSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Metric grid skeleton states',
  type: HostAnalyticsMetricGridSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
Widget hostAnalyticsMetricGridSkeletonCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'HostAnalyticsMetricGridSkeleton',
    contractId: 'component.host.analytics.metric_grid_skeleton',
    children: [
      WidgetbookHostStateCard(
        label: 'two metrics',
        child: SizedBox(
          width: WidgetbookPreviewLayout.standardContractWidth,
          child: HostAnalyticsMetricGridSkeleton(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Roster primitive states',
  type: CatchRosterTileCell,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Roster primitive states',
  type: CatchRosterActionCell,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Roster primitive states',
  type: CatchRosterDecideTarget,
  path: '[P1 product surfaces]/Host operations/Components',
)
Widget hostRosterPrimitiveCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'Catch roster primitives',
    contractId: 'component.host.roster_primitives',
    children: [
      WidgetbookHostStateCard(
        label: 'filter tiles',
        child: CatchRosterTiles(
          selected: 'booked',
          onSelect: (_) {},
          items: const [
            CatchRosterTile(id: 'all', value: '42', label: 'All'),
            CatchRosterTile(
              id: 'booked',
              value: '30',
              label: 'Booked',
              tone: CatchBadgeTone.success,
            ),
            CatchRosterTile(
              id: 'waitlist',
              value: '12',
              label: 'Wait',
              tone: CatchBadgeTone.warning,
            ),
          ],
        ),
      ),
      WidgetbookHostStateCard(
        label: 'decision row',
        child: CatchRosterTable(
          columns: const ['Guest', 'Signal', 'Host action'],
          rows: [
            CatchRosterRow(
              person: 'Rhea Kapoor',
              meta: 'Arriving 7:10 PM',
              signal: 'Request',
              tone: CatchBadgeTone.brand,
              action: CatchRosterDecideAction(
                onProfile: () {},
                onApprove: () {},
                onDecline: () {},
              ),
            ),
            CatchRosterRow(
              person: 'Aarav Mehta',
              meta: 'Checked in',
              signal: 'In',
              tone: CatchBadgeTone.success,
              action: CatchRosterButtonAction(label: 'Undo', onPressed: () {}),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tool card states',
  type: HostClubManagementPanel,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Tool card states',
  type: HostStatChip,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Tool card states',
  type: HostEventToolsCarousel,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Tool card states',
  type: HostEventToolsPageIndicator,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Tool card states',
  type: HostEventToolCard,
  path: '[P1 product surfaces]/Host operations/Components',
)
Widget hostToolCardCatalogStates(BuildContext context) {
  final tools = [
    HostEventToolItem(
      event: HostOperationsFixtures.upcomingEvent,
      attendanceState: HostEventAttendanceState.open,
    ),
    HostEventToolItem(
      event: HostOperationsFixtures.privateEvent,
      attendanceState: HostEventAttendanceState.closed,
    ),
  ];
  return WidgetbookHostCatalog(
    title: 'Host tool cards',
    contractId: 'component.host.tool_cards',
    children: [
      WidgetbookHostStateCard(
        label: 'club management panel',
        child: HostClubManagementPanel(
          club: widgetbookClub,
          events:
              HostOperationsFixtures.eventsByClub[widgetbookClub.id] ??
              const [],
          onEditClub: () {},
          onCreateEvent: () {},
        ),
      ),
      WidgetbookHostStateCard(
        label: 'stat chip',
        child: HostStatChip(
          label: 'Booked',
          value: '30',
          icon: CatchIcons.checkCircleOutlineRounded,
        ),
      ),
      WidgetbookHostStateCard(
        label: 'event tools carousel',
        child: HostEventToolsCarousel(
          tools: tools,
          onManageEvent: (_) {},
          onTakeAttendance: (_) {},
          onViewReport: (_) {},
        ),
      ),
      WidgetbookHostStateCard(
        label: 'event tool card',
        child: HostEventToolCard(
          item: tools.first,
          cardIndex: 0,
          cardCount: tools.length,
          onManageEvent: (_) {},
          onTakeAttendance: (_) {},
          onViewReport: (_) {},
        ),
      ),
      const WidgetbookHostStateCard(
        label: 'page indicator',
        child: HostEventToolsPageIndicator(selectedIndex: 0, itemCount: 2),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Action card states',
  type: CatchEmptyState,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
Widget hostEmptyStateStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'CatchEmptyState',
    contractId: 'component.host.empty_action_card',
    children: [
      WidgetbookHostStateCard(
        label: 'single action',
        child: WidgetbookHostHomeSectionFrame(
          child: CatchEmptyState(
            title: 'Create your first club',
            message:
                'Create a club to publish events, manage attendees, and run Event Success.',
            padding: EdgeInsets.zero,
            actions: [
              CatchButton(
                label: 'Create club',
                leading: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'two actions',
        child: WidgetbookHostHomeSectionFrame(
          child: CatchEmptyState(
            title: 'No active events yet',
            message:
                'Create an event for ${HostOperationsFixtures.primaryClub.name} to start filling the host dashboard.',
            padding: EdgeInsets.zero,
            actions: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  CatchButton(
                    label: 'New event',
                    leading: Icon(CatchIcons.addRounded, size: CatchIcon.sm),
                    onPressed: () {},
                  ),
                  CatchButton(
                    label: 'Events',
                    variant: CatchButtonVariant.secondary,
                    size: CatchButtonSize.sm,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'pending action',
        child: WidgetbookHostHomeSectionFrame(
          child: CatchEmptyState(
            title: 'No host profile yet',
            message:
                'Create a professional host identity before editing profile details.',
            padding: EdgeInsets.zero,
            actions: [
              CatchButton(
                label: 'Create host profile',
                leading: Icon(CatchIcons.businessOutlined, size: CatchIcon.md),
                status: CatchButtonStatus.loading,
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostEventManageScreen,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
// Exact host coverage entries. These point narrow promoted classes at the
// catalog route/component state that renders the owning workflow.
@widgetbook.UseCase(
  name: 'Exact catalog',
  type: CatchRosterActionCell,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictCatchRosterActionCellCatalogStates(BuildContext context) =>
    hostRosterPrimitiveCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: CatchRosterDecideTarget,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictCatchRosterDecideTargetCatalogStates(BuildContext context) =>
    hostRosterPrimitiveCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsReportSkeleton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsReportSkeletonCatalogStates(
  BuildContext context,
) => hostLoadingSkeletonCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostChartSkeleton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostChartSkeletonCatalogStates(BuildContext context) =>
    hostLoadingSkeletonCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventToolCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventToolCardCatalogStates(BuildContext context) =>
    hostToolCardCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventToolsCarousel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventToolsCarouselCatalogStates(BuildContext context) =>
    hostToolCardCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventToolsPageIndicator,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventToolsPageIndicatorCatalogStates(
  BuildContext context,
) => hostToolCardCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostInlineSkeletonIcon,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostInlineSkeletonIconCatalogStates(BuildContext context) =>
    hostLoadingSkeletonCatalogStates(context);
