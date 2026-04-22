import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/profile/presentation/edit_profile_controller.dart';
import 'package:catch_dating_app/profile/presentation/edit_profile_screen.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

class FakeAppUserRepository extends Fake implements AppUserRepository {
  AppUser? lastSavedUser;

  @override
  Future<void> setAppUser({required AppUser appUser}) async {
    lastSavedUser = appUser;
  }
}

Future<void> _pumpEditProfileScreen(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const EditProfileScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('invalid age preferences are rejected before submit', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 2600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final minAgeField = find.widgetWithText(TextFormField, 'Min age').first;
    final maxAgeField = find.widgetWithText(TextFormField, 'Max age').first;
    final saveButton = find.widgetWithText(FilledButton, 'Save changes').first;

    final repository = FakeAppUserRepository();
    final container = ProviderContainer(
      overrides: [
        appUserRepositoryProvider.overrideWith((ref) => repository),
        appUserStreamProvider.overrideWith(
          (ref) => Stream.value(
            buildUser(
              uid: 'runner-42',
            ).copyWith(minAgePreference: 24, maxAgePreference: 35),
          ),
        ),
      ],
    );
    EditProfileController.submitMutation.reset(container);
    addTearDown(container.dispose);

    await _pumpEditProfileScreen(tester, container);

    await tester.enterText(minAgeField, '40');
    await tester.enterText(maxAgeField, '20');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Min age must be less than or equal to max age'),
      findsOneWidget,
    );
    expect(repository.lastSavedUser, isNull);
  });
}
