import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_saved_audience_members_controller.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../test_pump_helpers.dart';

void main() {
  test(
    'member controller follows the server cursor and preserves the full list',
    () async {
      final repository = _AudienceRepository();
      final container = ProviderContainer(
        overrides: [hostCrmRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final provider = hostSavedAudienceMembersControllerProvider(
        repository.audience,
      );
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await container.read(provider.future);
      await container.read(provider.notifier).loadMore();
      expect(repository.cursors, [null, 'page-2']);
      expect(
        container.read(provider).requireValue.members.map((m) => m.contactId),
        ['ada', 'grace'],
      );
    },
  );

  testWidgets(
    'audience overview inspects members and hands its scope to Messaging',
    (tester) async {
      final repository = _AudienceRepository();
      await _pump(tester, repository);
      expect(
        find.byKey(const ValueKey('host-saved-audience-name')),
        findsNothing,
      );
      expect(find.text('Ada'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const ValueKey('host-saved-audience-more-members')),
      );
      await tester.tap(
        find.byKey(const ValueKey('host-saved-audience-more-members')),
      );
      await pumpFeatureUi(tester);
      expect(find.text('Grace'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const ValueKey('host-saved-audience-message')),
      );
      await tester.tap(
        find.byKey(const ValueKey('host-saved-audience-message')),
      );
      await pumpFeatureUi(tester);
      expect(find.text('Compose org-1 audience-1'), findsOneWidget);
    },
  );

  testWidgets(
    'form-answer authoring saves the selected published version and choice',
    (tester) async {
      final repository = _AudienceRepository();
      await _pump(tester, repository);
      await tester.tap(find.byKey(const ValueKey('host-saved-audience-edit')));
      await pumpFeatureUi(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('host-saved-audience-rule-type-1')),
      );
      await tester.tap(
        find.byKey(const ValueKey('host-saved-audience-rule-type-1')),
      );
      await pumpFeatureUi(tester);
      await tester.tap(find.text('Form answer').last);
      await pumpFeatureUi(tester);
      await tester.ensureVisible(find.text('Choose a published question').last);
      await tester.tap(find.text('Choose a published question').last);
      await pumpFeatureUi(tester);
      await tester.tap(
        find.text('Published application · v1 · Favorite drink').last,
      );
      await pumpFeatureUi(tester);
      await tester.ensureVisible(find.text('Tea').last);
      await tester.tap(find.text('Tea').last);
      await pumpFeatureUi(tester);
      await tester.tap(find.text('Coffee').last);
      await pumpFeatureUi(tester);
      await tester.tap(find.byKey(const ValueKey('host-saved-audience-save')));
      await pumpFeatureUi(tester);
      final saved =
          repository.saved!.predicates.single as HostSavedAudienceFormAnswer;
      expect(saved.formId, 'form-1');
      expect(saved.versionId, 'version-1');
      expect(saved.questionId, 'drink');
      expect(saved.value, 'coffee');
      expect(
        find.byKey(const ValueKey('host-saved-audience-name')),
        findsNothing,
      );
      expect(
        find.text('Published application · v1 · Favorite drink: Coffee'),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pump(WidgetTester tester, _AudienceRepository repository) async {
  await tester.binding.setSurfaceSize(const Size(1000, 1100));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => HostSavedAudienceEditorScreen(
          organizerId: 'org-1',
          initialAudience: repository.audience,
        ),
      ),
      GoRoute(
        path: '/compose',
        name: Routes.hostInboxScreen.name,
        builder: (_, state) => Scaffold(
          body: Text(
            'Compose ${state.uri.queryParameters['organizerId']} '
            '${state.uri.queryParameters['audienceId']}',
          ),
        ),
      ),
      GoRoute(
        path: '/person/:contactId',
        name: Routes.hostCustomerDetailScreen.name,
        builder: (_, state) =>
            Scaffold(body: Text('Person ${state.pathParameters['contactId']}')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [hostCrmRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await pumpFeatureUi(tester);
}

class _UnusedFunctions extends Fake implements FirebaseFunctions {}

class _AudienceRepository extends HostCrmRepository {
  _AudienceRepository() : super(_UnusedFunctions());
  final cursors = <String?>[];
  HostSavedAudienceDefinition? saved;
  HostSavedAudience get audience => _audience(
    saved ??
        const HostSavedAudienceDefinition(
          join: HostSavedAudienceJoin.all,
          predicates: [
            HostSavedAudienceComputedSegment(HostAudienceSegment.regular),
          ],
        ),
  );

  @override
  Future<HostSavedAudienceFilterOptions> savedAudienceFilterOptions(
    String organizerId,
  ) async => const HostSavedAudienceFilterOptions(
    forms: [
      HostAudienceSourceOption(id: 'form-1', title: 'Published application'),
    ],
    questions: [
      HostAudienceQuestionOption(
        formId: 'form-1',
        versionId: 'version-1',
        version: 1,
        formTitle: 'Published application',
        questionId: 'drink',
        label: 'Favorite drink',
        options: [
          HostAudienceAnswerOption(label: 'Tea', value: 'tea'),
          HostAudienceAnswerOption(label: 'Coffee', value: 'coffee'),
        ],
      ),
    ],
    events: [HostAudienceSourceOption(id: 'event-1', title: 'Sunday social')],
    tags: [],
  );

  @override
  Future<HostSavedAudiencePreview> previewSavedAudience({
    required String organizerId,
    required HostSavedAudience audience,
    int sampleLimit = 10,
    String? cursor,
  }) async {
    cursors.add(cursor);
    return HostSavedAudiencePreview(
      audience: audience,
      matchCount: 2,
      reachSummary: const HostAudienceReachSummary(
        inCatch: 0,
        automatic: 0,
        byHand: 2,
        unavailable: 0,
      ),
      sample: [
        cursor == null
            ? const HostSavedAudiencePreviewContact(
                contactId: 'ada',
                displayName: 'Ada',
              )
            : const HostSavedAudiencePreviewContact(
                contactId: 'grace',
                displayName: 'Grace',
              ),
      ],
      nextCursor: cursor == null ? 'page-2' : null,
      evaluatedAt: DateTime(2026, 9, 3),
    );
  }

  @override
  Future<HostSavedAudience> upsertSavedAudience({
    required String organizerId,
    required String requestId,
    required String name,
    required HostSavedAudienceDefinition definition,
    String? audienceId,
    int? expectedRevision,
  }) async {
    saved = definition;
    return audience;
  }
}

HostSavedAudience _audience(HostSavedAudienceDefinition definition) =>
    HostSavedAudience(
      organizerId: 'org-1',
      audienceId: 'audience-1',
      name: 'Sunday regulars',
      status: 'active',
      definition: definition,
      definitionHash: 'hash',
      definitionVersion: 2,
      revision: 1,
      lastPreviewMatchCount: 2,
      lastPreviewAt: DateTime(2026, 9, 3),
      createdAt: DateTime(2026, 9),
      updatedAt: DateTime(2026, 9, 3),
    );
