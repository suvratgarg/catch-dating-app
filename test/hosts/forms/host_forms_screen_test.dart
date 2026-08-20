// ignore_for_file: riverpod_lint/scoped_providers_should_specify_dependencies

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_tabbed_screen.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../clubs/clubs_test_helpers.dart';
import '../../test_pump_helpers.dart';

void main() {
  setUp(() => AppConfig.configureEntrypointRole(AppRole.host));
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  testWidgets(
    'Forms and Responses use pinned tabs and one view-aware header search',
    (tester) async {
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

      final scaffold = find.byType(CatchTabbedScreenScaffold);
      expect(scaffold, findsOneWidget);
      expect(
        find.byKey(const ValueKey('host-forms-view-tabs')),
        findsOneWidget,
      );
      expect(find.text('Forms'), findsWidgets);
      expect(find.text('Responses'), findsOneWidget);
      expect(find.byKey(const ValueKey('host-forms-create')), findsOneWidget);
      expect(find.byType(CatchSearchField), findsOneWidget);
      expect(
        tester.widget<CatchTabbedScreenScaffold>(scaffold).search?.placeholder,
        'Search forms',
      );

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

      await tester.tap(find.text('Responses'));
      await pumpFeatureUiFor(tester, CatchMotion.base);
      await pumpFeatureUi(tester);
      expect(find.byKey(const ValueKey('host-forms-create')), findsNothing);
      expect(find.byType(CatchSearchField), findsOneWidget);
      expect(
        tester.widget<CatchTabbedScreenScaffold>(scaffold).search?.placeholder,
        'Search responses',
      );

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

class _FixedHostFormsDirectoryController extends HostFormsDirectoryController {
  _FixedHostFormsDirectoryController(this.requests);

  final List<HostFormListRequest> requests;

  @override
  Future<HostFormsDirectoryState> build(HostFormListRequest request) async {
    requests.add(request);
    return const HostFormsDirectoryState(forms: [], nextCursor: null);
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
