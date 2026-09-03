import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/data/host_application_repository.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_controller.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_screen.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../test_pump_helpers.dart';

void main() {
  testWidgets('accept refreshes application and opens its linked person', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _ReviewController();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const HostApplicationDetailScreen(
            organizerId: 'org-1',
            applicationId: 'app-1',
          ),
        ),
        GoRoute(
          path: '/person/:contactId',
          name: Routes.hostCustomerDetailScreen.name,
          builder: (_, state) => Scaffold(
            body: Text(
              'Person ${state.pathParameters['contactId']} '
              '${state.uri.queryParameters['organizerId']}',
            ),
          ),
        ),
        GoRoute(
          path: '/response/:responseId',
          name: Routes.hostFormResponseDetailScreen.name,
          builder: (_, _) => const Scaffold(body: Text('Original response')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hostApplicationsControllerProvider.overrideWithValue(controller),
          hostApplicationDetailProvider(
            'org-1',
            'app-1',
          ).overrideWith((ref) async => _detail(controller.accepted)),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await pumpFeatureUi(tester);
    await tester.ensureVisible(find.text('Accept and add to People'));
    await tester.tap(find.text('Accept and add to People'));
    await pumpFeatureUi(tester);
    expect(controller.accepted, isTrue);
    final link = find.byKey(const ValueKey('host-application-open-person'));
    await tester.ensureVisible(link);
    await tester.tap(link);
    await pumpFeatureUi(tester);
    expect(find.text('Person person-1 org-1'), findsOneWidget);
  });

  testWidgets('revoked application cannot expose review actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hostApplicationDetailProvider(
            'org-1',
            'app-1',
          ).overrideWith((ref) async => _detail(false, revoked: true)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HostApplicationDetailScreen(
            organizerId: 'org-1',
            applicationId: 'app-1',
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);
    expect(find.text('Accept and add to People'), findsNothing);
  });
}

HostApplicationDetail _detail(bool accepted, {bool revoked = false}) =>
    HostApplicationDetail(
      organizerId: 'org-1',
      applicationId: 'app-1',
      formId: 'form-1',
      formVersionId: 'version-1',
      targetKind: 'organizer',
      targetId: null,
      applicantDisplayName: revoked ? 'Withdrawn applicant' : 'Ada',
      reviewStatus: accepted
          ? HostApplicationReviewStatus.approved
          : HostApplicationReviewStatus.submitted,
      answers: const [],
      outreach: const HostApplicationOutreach(
        phoneE164: null,
        email: null,
        instagramUrl: null,
        linkedinUrl: null,
      ),
      reviewNote: null,
      assignedReviewerUid: null,
      submittedAt: DateTime(2026, 9, 1),
      reviewedAt: null,
      revision: accepted ? 2 : 1,
      contactId: accepted ? 'person-1' : null,
      sourceResponseId: revoked ? null : 'response-1',
      dataAccessState: revoked
          ? 'revokedParticipantGrant'
          : 'submittedFormResponse',
    );

class _ReviewController extends Fake implements HostApplicationsController {
  bool accepted = false;
  @override
  Future<HostApplicationReviewResult> reviewApplication({
    required String organizerId,
    required String applicationId,
    required int expectedRevision,
    required HostApplicationReviewStatus reviewStatus,
    String? reviewNote,
  }) async {
    expect(expectedRevision, 1);
    expect(reviewStatus, HostApplicationReviewStatus.approved);
    accepted = true;
    return HostApplicationReviewResult(
      organizerId: organizerId,
      applicationId: applicationId,
      reviewStatus: reviewStatus,
      reviewedAt: DateTime(2026, 9, 3),
      revision: 2,
      contactId: 'person-1',
    );
  }
}
