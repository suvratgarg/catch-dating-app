import 'dart:io';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_crm_summary.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_summary.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_sheet.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_responses_panel.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_organizer_switcher.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/catch_test_fonts.dart';
import '../test_pump_helpers.dart';
import 'support/capture_device.dart';
import 'support/capture_pump.dart';

// ignore_for_file: riverpod_lint/scoped_providers_should_specify_dependencies
void main() {
  setUpAll(loadCatchTestFonts);
  setUp(() {
    AppConfig.configureEntrypointRole(AppRole.host);
  });
  tearDown(() {
    AppConfig.resetEntrypointRoleOverrideForTesting();
  });
  const output = String.fromEnvironment('SHEET_REVIEW_OUTPUT');
  final cases = <String, WidgetBuilder>{
    'create-event': (_) => HostEventEntrySheet(
      state: HostEventEntryState.resolve(
        organizerId: HostOperationsFixtures.primaryClub.id,
        repeatSource: HostOperationsFixtures.upcomingEvent,
      ),
    ),
    'people-filter': (_) => const HostCustomerFilterSheet(
      selectedFilter: HostCustomerFilter.repeat,
      selectedManualTag: null,
      manualTagVocabulary: [],
      selectedCount: HostCustomerSegmentCount(
        count: 0,
        coverage: HostCustomerMatchCountCoverage.exact,
      ),
      smsReadiness: HostCrmChannelReadiness.currentEventOnly,
    ),
    'people-sort': (_) => HostCustomerDirectoryControls(
      sort: HostCustomerSort.lastSeen,
      onSortChanged: (_) {},
      onOpenFilters: () {},
    ),
    'draft-picker': (_) => DraftPickerSheet(
      drafts: [HostOperationsFixtures.eventDraft],
      onSelectDraft: (_) {},
      onDeleteDraft: (_) async {},
      onStartFresh: () {},
    ),
    'organizer-picker': (_) => HostOrganizerSwitcherSheet(
      clubs: [
        HostOperationsFixtures.primaryClub,
        HostOperationsFixtures.dinnerClub,
      ],
      selectedOrganizerId: HostOperationsFixtures.primaryClub.id,
    ),
  };
  for (final entry in cases.entries) {
    testWidgets(
      'Host sheet review ${entry.key}',
      (tester) async {
        if (output.isEmpty) return;
        await captureCatchWidget(
          tester,
          id: entry.key,
          outputDirectory: Directory(output),
          device: CaptureDevice.iphone17Pro,
          includeOverlays: true,
          builder: (context) => Center(
            child: CatchButton(
              label: 'Open',
              onPressed: () {
                showCatchBottomSheet<void>(
                  context: context,
                  builder: entry.value,
                );
              },
            ),
          ),
          drive: (tester) async {
            await tester.tap(find.text('Open'));
            await pumpFeatureUi(tester);
            if (entry.key == 'people-sort') {
              await tester.tap(find.text('Sort: Last seen'));
              await pumpFeatureUi(tester);
            }
          },
        );
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }
  for (final responses in [false, true]) {
    testWidgets(
      'Host sheet review ${responses ? 'responses' : 'forms'} filters',
      (tester) async {
        if (output.isEmpty) return;
        await captureCatchWidget(
          tester,
          id: responses ? 'responses-filter' : 'forms-filter',
          outputDirectory: Directory(output),
          device: CaptureDevice.iphone17Pro,
          includeOverlays: true,
          providerOverrides: [
            uidProvider.overrideWithValue(const AsyncData('host-review')),
            hostOperableClubsProvider('host-review').overrideWithValue(
              AsyncData([HostOperationsFixtures.primaryClub]),
            ),
            hostFormsDirectoryControllerProvider.overrideWith2((_) => _Forms()),
            hostFormResponsesControllerProvider.overrideWith2(
              (_) => _Responses(),
            ),
          ],
          builder: (_) => responses
              ? const CustomScrollView(
                  slivers: [HostFormResponsesPanel(organizerId: 'review')],
                )
              : const HostFormsScreen(),
          drive: (tester) async {
            await tester.tap(find.text('Filters').hitTestable().first);
            await pumpFeatureUi(tester);
          },
        );
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }
}

class _Forms extends HostFormsDirectoryController {
  @override
  Future<HostFormsDirectoryState> build(HostFormListRequest request) async =>
      const HostFormsDirectoryState(forms: [], nextCursor: null);
}

class _Responses extends HostFormResponsesController {
  @override
  Future<HostFormResponsesState> build(
    HostFormResponseListRequest request,
  ) async => const HostFormResponsesState(responses: [], nextCursor: null);
}
