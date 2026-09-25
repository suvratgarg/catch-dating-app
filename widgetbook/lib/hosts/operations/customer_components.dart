import 'package:catch_ui/catch_ui.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_applications_panel.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_tabs.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_memory.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_timeline.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_no_organizer_empty_state.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_crm_summary.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'customer_routes.dart';

@widgetbook.UseCase(
  name: 'Populated component',
  type: HostCustomerApplicationsPanel,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerApplicationsPanelComponentStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) => HostCustomerApplicationsPanel(
        organizerId: customer.organizerId,
        contactId: customer.contactId,
        onOpenApplication: (_) {},
        onOpenContact: (_) {},
      ),
    );

@widgetbook.UseCase(
  name: 'Populated component',
  type: HostCustomerApplicationSnapshot,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerApplicationSnapshotComponentStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) => HostCustomerApplicationSnapshot(
        organizerId: customer.organizerId,
        applicationId: 'design-application-1',
        onOpen: () {},
        onOpenContact: (_) {},
      ),
    );

@widgetbook.UseCase(
  name: 'Populated component',
  type: HostCustomerDetailsSection,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerDetailsSectionComponentStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) => HostCustomerDetailsSection(
        customer: customer,
        onCall: () {},
        onEmail: () {},
      ),
    );

@widgetbook.UseCase(
  name: 'Populated component',
  type: HostCustomerRecentEvents,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerRecentEventsComponentStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) =>
          HostCustomerRecentEvents(customer: customer, onOpenEvent: (_) {}),
    );

@widgetbook.UseCase(
  name: 'Populated component',
  type: HostCustomerRevenueBreakdown,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerRevenueBreakdownComponentStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) =>
          HostCustomerRevenueBreakdown(customer: customer, onOpenEvent: (_) {}),
    );

@widgetbook.UseCase(
  name: 'Populated component',
  type: HostCustomerMemoryPreview,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerMemoryPreviewComponentStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) =>
          HostCustomerMemoryPreview(customer: customer, onOpenMemory: () {}),
    );

@widgetbook.UseCase(
  name: 'Populated component',
  type: HostCustomerHistoryFilters,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerHistoryFiltersComponentStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) => HostCustomerHistoryFilters(
        builder: (filter) => HostCustomerTimelineSection(
          customer: customer,
          filter: filter,
          onOpenFormResponse: (_) {},
          onOpenEvent: (_) {},
          onOpenCatchThread: (_) {},
          onOpenWhatsappThread: (_) {},
        ),
      ),
    );

@widgetbook.UseCase(
  name: 'Populated component',
  type: CatchField,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerTimelineRecordComponentStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) => CatchSection.containedRows(
        children: [
          for (final entry in customer.timeline)
            hostCustomerTimelineField(
              context,
              entry: entry,
              onOpenFormResponse: (_) {},
              onOpenEvent: (_) {},
              onOpenCatchThread: (_) {},
              onOpenWhatsappThread: (_) {},
            ),
        ],
      ),
    );

@widgetbook.UseCase(
  name: 'Populated component',
  type: HostCustomerDetailOverview,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerDetailOverviewComponentStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) =>
          HostCustomerDetailOverview(customer: customer, onOpenRevenue: () {}),
    );

@widgetbook.UseCase(
  name: 'Populated component',
  type: HostCustomerDetailTabs,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerDetailTabsComponentStates(
  BuildContext context,
) => hostCustomersStates(
  context,
  detailBuilder: (customer) => HostCustomerDetailTabs(
    overviewBuilder: (_) =>
        HostCustomerDetailOverview(customer: customer, onOpenRevenue: () {}),
    details: HostCustomerDetailsSection(
      customer: customer,
      onCall: () {},
      onEmail: () {},
    ),
    memory: HostCustomerMemoryPreview(customer: customer, onOpenMemory: () {}),
    history: HostCustomerTimelineSection(
      customer: customer,
      onOpenFormResponse: (_) {},
      onOpenEvent: (_) {},
      onOpenCatchThread: (_) {},
      onOpenWhatsappThread: (_) {},
    ),
  ),
);

@widgetbook.UseCase(
  name: 'Directory states',
  type: HostCustomersDirectory,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomersDirectoryStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Directory control states',
  type: HostCustomerDirectoryControls,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerDirectoryControlsStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Full-page add state',
  type: HostAddCustomerScreen,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostAddCustomerScreenStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Identity input states',
  type: HostCustomerIdentityInputSection,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerIdentityInputStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Detail states',
  type: HostCustomerDetailScreen,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerDetailStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Detail composition states',
  type: HostCustomerDetailBody,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerDetailBodyStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Identity states',
  type: HostCustomerIdentityCard,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerIdentityStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Attendance stats',
  type: HostCustomerAttendanceCard,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerAttendanceStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Revenue coverage states',
  type: HostCustomerRevenueCard,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerRevenueStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Unified timeline states',
  type: HostCustomerTimelineSection,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerTimelineStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'No-organizer state',
  type: HostAudienceNoOrganizerEmptyState,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomersNoOrganizerStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Reach and provenance states',
  type: HostCustomerReachSection,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerConversationStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Summary states',
  type: HostCustomersSummary,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomersSummaryStates(BuildContext context) =>
    hostCustomersStates(context);

@widgetbook.UseCase(
  name: 'Loaded history',
  type: HostCustomerHistoryPanel,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
Widget hostCustomerHistoryPanelStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) => HostCustomerHistoryPanel(
        customer: customer,
        onOpenFormResponse: (_) {},
        onOpenEvent: (_) {},
        onOpenCatchThread: (_) {},
        onOpenWhatsappThread: (_) {},
        onUndoMerge: (_) {},
      ),
    );

@widgetbook.UseCase(
  name: 'Loaded submissions',
  type: HostCustomerSubmissionsSection,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerSubmissionsSectionStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) =>
          HostCustomerSubmissionsSection(customer: customer, onOpen: (_) {}),
    );

@widgetbook.UseCase(
  name: 'Provenance states',
  type: HostCustomerSourcesSection,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerSourcesSectionStates(BuildContext context) =>
    hostCustomersStates(
      context,
      detailBuilder: (customer) => HostCustomerSourcesSection(
        customer: customer,
        onReviewDuplicates: () {},
      ),
    );

@widgetbook.UseCase(
  name: 'Combined filter chips',
  type: HostCustomerFilterSheet,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostCustomerFilterSheetStates(BuildContext context) => Scaffold(
  body: Center(
    child: CatchButton(
      label: 'Open people filters',
      onPressed: () => showCatchBottomSheet<void>(
        context: context,
        builder: (_) => const HostCustomerFilterSheet(
          selectedFilters: {
            HostCustomerFilter.firstTime,
            HostCustomerFilter.repeat,
            HostCustomerFilter.reliable,
          },
          manualTagVocabulary: [
            HostCustomerManualTag(tagId: 'runners', label: 'Runners'),
            HostCustomerManualTag(tagId: 'volunteers', label: 'Volunteers'),
          ],
          smsReadiness: HostCrmChannelReadiness.currentEventOnly,
        ),
      ),
    ),
  ),
);
