import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_selection_menu.dart';
import 'package:catch_dating_app/hosts/data/host_application_repository.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_controller.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';

void main() {
  testWidgets('Applications uses one adaptive review-status selection', (
    tester,
  ) async {
    final requests = <HostApplicationListRequest>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hostApplicationsDirectoryControllerProvider.overrideWith2(
            (_) => _FixedHostApplicationsDirectoryController(requests),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HostApplicationsScreen(organizerId: 'organizer-1'),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(
      find.byType(CatchAdaptiveSelectionControl<HostApplicationReviewStatus?>),
      findsOneWidget,
    );
    expect(requests.last.reviewStatus, isNull);

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
