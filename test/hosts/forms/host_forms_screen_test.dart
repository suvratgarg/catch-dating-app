// ignore_for_file: riverpod_lint/scoped_providers_should_specify_dependencies

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_responses_panel.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_view.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../clubs/clubs_test_helpers.dart';
import '../../test_pump_helpers.dart';

void main() {
  setUp(() => AppConfig.configureEntrypointRole(AppRole.host));
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  testWidgets('Responses opens application review for the selected form', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: SingleChildScrollView(
              child: HostFormResponsesPanel(
                organizerId: 'org-1',
                formId: 'form-1',
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/applications',
          name: Routes.hostApplicationsScreen.name,
          builder: (_, state) => Text(
            '${state.uri.queryParameters['organizerId']}/${state.uri.queryParameters['formId']}',
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hostFormResponsesControllerProvider.overrideWith2(
            (_) => _FixedHostFormResponsesController([]),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Applications'));
    await pumpFeatureUi(tester);
    expect(find.text('org-1/form-1'), findsOneWidget);
  });

  testWidgets('Host Forms keeps Audience composition across route states', (
    tester,
  ) async {
    for (final (screen, view) in [
      (const HostFormsScreen(), HostAudienceView.forms),
      (
        const HostFormsScreen(initialResponses: true),
        HostAudienceView.responses,
      ),
    ]) {
      await _pumpFormsRouteState(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(const AsyncLoading<String?>()),
        ],
        settle: false,
      );
      _expectFormsAudienceStateOwner(tester, selected: view);
      expect(find.byType(HostRouteLoadingBody), findsOneWidget);
      expect(find.byType(CatchSliverStateViewport), findsOneWidget);

      await _pumpFormsRouteState(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(
            AsyncError<String?>(StateError('uid failed'), StackTrace.current),
          ),
        ],
        settle: false,
      );
      _expectFormsAudienceStateOwner(tester, selected: view);
      expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);

      await _pumpFormsRouteState(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>(null)),
        ],
        settle: false,
      );
      _expectFormsAudienceStateOwner(tester, selected: view);
      expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);
      expect(find.text('Sign in required'), findsOneWidget);

      await _pumpFormsRouteState(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>('host-1')),
          hostOperableClubsProvider(
            'host-1',
          ).overrideWithValue(const AsyncLoading<List<Club>>()),
        ],
        settle: false,
      );
      _expectFormsAudienceStateOwner(tester, selected: view);
      expect(find.byType(HostRouteLoadingBody), findsOneWidget);
      expect(find.byType(CatchSliverStateViewport), findsOneWidget);

      await _pumpFormsRouteState(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>('host-1')),
          hostOperableClubsProvider('host-1').overrideWithValue(
            AsyncError<List<Club>>(
              StateError('clubs failed'),
              StackTrace.current,
            ),
          ),
        ],
        settle: false,
      );
      _expectFormsAudienceStateOwner(tester, selected: view);
      expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);

      await _pumpFormsRouteState(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>('host-1')),
          hostOperableClubsProvider(
            'host-1',
          ).overrideWithValue(const AsyncData<List<Club>>([])),
        ],
        settle: false,
      );
      _expectFormsAudienceStateOwner(tester, selected: view);
      expect(find.byType(HostFormsNoOrganizer), findsOneWidget);
      expect(find.byType(CatchSliverEmptyState), findsOneWidget);
    }
  });

  for (final width in [402.0, 1200.0]) {
    testWidgets(
      'Audience Forms and Responses use shared tabs and view-aware search at $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 874);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final formRequests = <HostFormListRequest>[];
        final responseRequests = <HostFormResponseListRequest>[];
        final club = buildClub(id: 'forms-club', ownerUserId: 'host-1');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uidProvider.overrideWith((ref) => Stream.value('host-1')),
              hostOperableClubsProvider(
                'host-1',
              ).overrideWithValue(AsyncData([club])),
              hostFormsDirectoryControllerProvider.overrideWith2(
                (_) => _FixedHostFormsDirectoryController(formRequests),
              ),
              hostFormResponsesControllerProvider.overrideWith2(
                (_) => _FixedHostFormResponsesController(responseRequests),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const HostFormsScreen(),
            ),
          ),
        );
        await pumpFeatureUi(tester);

        final scaffold = find.byType(CatchRootScreenScaffold);
        expect(scaffold, findsOneWidget);
        expect(
          find.byKey(const ValueKey('host-audience-view-tabs')),
          findsOneWidget,
        );
        expect(find.text('People'), findsOneWidget);
        expect(find.text('Groups'), findsOneWidget);
        expect(find.text('Forms'), findsWidgets);
        expect(find.text('Responses'), findsOneWidget);
        expect(find.byKey(const ValueKey('host-forms-create')), findsOneWidget);
        expect(find.byType(CatchTopBarPrimaryAction), findsOneWidget);
        expect(find.byType(CatchSearchField), findsOneWidget);
        expect(
          tester
              .widget<CatchSearchField>(find.byType(CatchSearchField))
              .placeholder,
          'Search forms',
        );
        expect(
          find.byType(CatchOptionGroup<HostFormLifecycleStatus?>),
          findsOneWidget,
        );

        await tester.tap(find.text('Published'));
        await pumpFeatureUi(tester);
        expect(formRequests.last.statuses, {HostFormLifecycleStatus.published});

        await tester.tap(find.byIcon(CatchIcons.search));
        await pumpFeatureUiFor(tester, CatchMotion.base);
        await pumpFeatureUi(tester);
        final search = find.byType(CatchSearchField);
        expect(
          tester.widget<CatchSearchField>(search).mode,
          CatchSearchFieldMode.expanding,
        );
        await tester.enterText(
          find.descendant(of: search, matching: find.byType(TextField)),
          '  waiver  ',
        );
        await pumpFeatureUiFor(tester, CatchMotion.searchDebounce);
        await pumpFeatureUi(tester);
        expect(formRequests.last.query, 'waiver');
        expect(responseRequests, isEmpty);
        await tester.tap(find.text('All purposes'));
        await pumpFeatureUi(tester);
        await tester.tap(find.text('Waiver'));
        await pumpFeatureUi(tester);
        expect(formRequests.last.purposes, {HostFormPurpose.waiver});
        expect(formRequests.last.statuses, {HostFormLifecycleStatus.published});
        expect(formRequests.last.query, 'waiver');
        await tester.tap(find.text('Waiver'));
        await pumpFeatureUi(tester);
        await tester.tap(find.text('All purposes'));
        await pumpFeatureUi(tester);
        expect(formRequests.last.purposes, isEmpty);

        await tester.tap(find.text('Responses'));
        await pumpFeatureUiFor(tester, CatchMotion.base);
        await pumpFeatureUi(tester);
        expect(find.byKey(const ValueKey('host-forms-create')), findsNothing);
        expect(find.byType(CatchSearchField), findsOneWidget);
        expect(
          tester
              .widget<CatchSearchField>(find.byType(CatchSearchField))
              .placeholder,
          'Search responses',
        );
        await tester.tap(find.text('All statuses'));
        await pumpFeatureUi(tester);
        await tester.tap(find.text('Submitted'));
        await pumpFeatureUi(tester);
        expect(responseRequests.last.statuses, {
          HostFormResponseStatus.submitted,
        });

        await tester.enterText(
          find.descendant(
            of: find.byType(CatchSearchField),
            matching: find.byType(TextField),
          ),
          '  submitted  ',
        );
        await pumpFeatureUiFor(tester, CatchMotion.searchDebounce);
        await pumpFeatureUi(tester);
        expect(responseRequests.last.query, 'submitted');
        expect(formRequests.last.query, 'waiver');
      },
    );
  }

  testWidgets('Response form scope survives tab changes and route updates', (
    tester,
  ) async {
    final requests = <HostFormResponseListRequest>[];
    final router = GoRouter(
      initialLocation:
          '/host/audience?view=responses&organizerId=forms-club&formId=first',
      routes: [
        GoRoute(
          path: Routes.hostAudienceScreen.path,
          name: Routes.hostAudienceScreen.name,
          builder: (context, state) => HostFormsScreen(
            initialResponses: state.uri.queryParameters['view'] == 'responses',
            initialOrganizerId: state.uri.queryParameters['organizerId'],
            initialFormId: state.uri.queryParameters['formId'],
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>('host-1')),
          hostOperableClubsProvider('host-1').overrideWithValue(
            AsyncData([buildClub(id: 'forms-club', ownerUserId: 'host-1')]),
          ),
          hostFormsDirectoryControllerProvider.overrideWith2(
            (_) => _FixedHostFormsDirectoryController([]),
          ),
          hostFormResponsesControllerProvider.overrideWith2(
            (_) => _FixedHostFormResponsesController(requests),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await pumpFeatureUi(tester);
    expect(requests.last.formId, 'first');
    await tester.tap(find.text('Forms'));
    await pumpFeatureUi(tester);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['view'],
      'forms',
    );
    expect(
      router.routeInformationProvider.value.uri.queryParameters['formId'],
      'first',
    );
    await tester.tap(find.text('Responses'));
    await pumpFeatureUi(tester);
    expect(requests.last.formId, 'first');
    router.go(
      '/host/audience?view=responses&organizerId=forms-club&formId=second',
    );
    await pumpFeatureUi(tester);
    expect(requests.last.formId, 'second');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Forms directory is flat and published row menus stay bounded', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final club = buildClub(id: 'forms-club', ownerUserId: 'host-1');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
          hostOperableClubsProvider(
            'host-1',
          ).overrideWithValue(AsyncData([club])),
          hostFormsDirectoryControllerProvider.overrideWith2(
            (_) => _FixedHostFormsDirectoryController(
              <HostFormListRequest>[],
              forms: [
                _formSummary(
                  id: 'published',
                  status: HostFormLifecycleStatus.published,
                ),
                _formSummary(
                  id: 'paused',
                  status: HostFormLifecycleStatus.paused,
                ),
                _formSummary(
                  id: 'legacy',
                  status: HostFormLifecycleStatus.published,
                  consequences: const HostFormConsequences.unavailable(),
                ),
              ],
            ),
          ),
          hostFormResponsesControllerProvider.overrideWith2(
            (_) => _FixedHostFormResponsesController(
              <HostFormResponseListRequest>[],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HostFormsScreen(),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byKey(CatchSectionFocusSurface.rowGroupClipKey), findsNothing);
    expect(find.byKey(const ValueKey('host-form-published')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('host-form-published'))).width,
      lessThanOrEqualTo(CatchLayout.hostFormsDirectoryMaxContentWidth),
    );
    expect(find.byKey(const ValueKey('host-form-paused')), findsOneWidget);
    expect(find.textContaining('Published · 12 responses'), findsNWidgets(2));
    expect(find.textContaining('Paused · 12 responses'), findsOneWidget);
    expect(find.textContaining('Verifies email'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpFormsRouteState(
  WidgetTester tester,
  HostFormsScreen screen, {
  required List overrides,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [...overrides],
      child: MaterialApp(theme: AppTheme.light, home: screen),
    ),
  );
  if (settle) {
    await pumpFeatureUi(tester);
  } else {
    await tester.pump();
  }
}

void _expectFormsAudienceStateOwner(
  WidgetTester tester, {
  required HostAudienceView selected,
}) {
  expect(find.byType(HostAudienceStateScaffold), findsOneWidget);
  expect(find.byType(CatchRootScreenScaffold), findsOneWidget);
  expect(find.byType(CatchRootScreenPageScrollView), findsOneWidget);
  expect(find.byType(HostAudienceTabRail), findsOneWidget);
  expect(find.byType(CatchErrorScaffold), findsNothing);
  expect(find.byType(HostLoadingScreen), findsNothing);
  expect(
    tester
        .widget<HostAudienceTabRail>(find.byType(HostAudienceTabRail))
        .selected,
    selected,
  );
  expect(
    tester
        .widget<CatchRootScreenPageScrollView>(
          find.byType(CatchRootScreenPageScrollView),
        )
        .bodyLayout,
    CatchScreenBodyLayout.standard,
  );
}

class _FixedHostFormsDirectoryController extends HostFormsDirectoryController {
  _FixedHostFormsDirectoryController(
    this.requests, {
    this.forms = const <HostFormSummary>[],
  });

  final List<HostFormListRequest> requests;
  final List<HostFormSummary> forms;

  @override
  Future<HostFormsDirectoryState> build(HostFormListRequest request) async {
    requests.add(request);
    return HostFormsDirectoryState(forms: forms, nextCursor: null);
  }
}

class _FixedHostFormResponsesController extends HostFormResponsesController {
  _FixedHostFormResponsesController(this.requests);

  final List<HostFormResponseListRequest> requests;

  @override
  Future<HostFormResponsesState> build(
    HostFormResponseListRequest request,
  ) async {
    requests.add(request);
    return const HostFormResponsesState(responses: [], nextCursor: null);
  }
}

HostFormSummary _formSummary({
  required String id,
  required HostFormLifecycleStatus status,
  HostFormConsequences consequences = const HostFormConsequences(
    coverage: HostFormConsequenceCoverage.exact,
    identityPolicy: HostFormIdentityPolicy.emailVerified,
    enabledAutomationActionKinds: {
      HostFormAutomationActionKind.createCrmContact,
    },
  ),
}) => HostFormSummary(
  organizerId: 'forms-club',
  formId: id,
  title: '$id form',
  description: null,
  purpose: HostFormPurpose.application,
  status: status,
  templateId: null,
  publicFormId: 'public-$id',
  defaultTargetKind: HostFormTargetKind.organizer,
  defaultTargetId: 'forms-club',
  activeVersionId: 'version-$id',
  draftRevision: 1,
  publishedVersion: 1,
  submittedResponseCount: 12,
  consequences: consequences,
  updatedAt: DateTime(2026, 8, 26),
  publishedAt: DateTime(2026, 8, 20),
  lastResponseAt: DateTime(2026, 8, 26),
);
