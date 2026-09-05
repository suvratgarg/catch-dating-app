import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/hosts/data/host_application_repository.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_controller.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';

void main() {
  testWidgets('Application lenses and filters preserve form and person scope', (
    tester,
  ) async {
    final requests = <HostApplicationListRequest>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hostSavedAudienceFilterOptionsProvider('organizer-1').overrideWith(
            (_) async => const HostSavedAudienceFilterOptions(
              forms: [
                HostAudienceSourceOption(
                  id: 'form-1',
                  title: 'Sunday run applications',
                ),
              ],
              events: [],
              questions: [],
              tags: [],
            ),
          ),
          hostApplicationsDirectoryControllerProvider.overrideWith2(
            (_) => _FixedHostApplicationsDirectoryController(requests),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HostApplicationsScreen(
            organizerId: 'organizer-1',
            formId: 'form-1',
            contactId: 'person-1',
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(CatchOptionGroup<String>), findsOneWidget);
    expect(requests.last.reviewStatus, isNull);
    expect(find.text('Sunday run applications'), findsOneWidget);
    await tester.tap(find.text('New applications'));
    await pumpFeatureUi(tester);
    expect(requests.last.reviewStatus, HostApplicationReviewStatus.submitted);
    expect(requests.last.formId, 'form-1');
    expect(requests.last.contactId, 'person-1');

    await tester.tap(
      find.byKey(const ValueKey('host-applications-review-status')),
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Approved'));
    await pumpFeatureUi(tester);

    expect(requests.last.reviewStatus, HostApplicationReviewStatus.approved);
  });
}

class _FixedHostApplicationsDirectoryController
    extends HostApplicationsDirectoryController {
  _FixedHostApplicationsDirectoryController(this.requests);

  final List<HostApplicationListRequest> requests;

  @override
  Future<HostApplicationsDirectoryState> build(
    HostApplicationListRequest request,
  ) async {
    requests.add(request);
    return const HostApplicationsDirectoryState(
      applications: [],
      nextCursor: null,
    );
  }
}
