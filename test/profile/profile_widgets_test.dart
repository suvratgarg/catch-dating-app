import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/scrollable_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/preview_tab.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_tile.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_sliver_header.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';
import '../test_pump_helpers.dart';

Widget _profileTab(UserProfile user) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: ProfileTab(
          user: user,
          uploadState: (loadingIndices: <int>{}, uploadError: null),
        ),
      ),
    ),
  );
}

Future<void> _pumpProfileTab(WidgetTester tester, UserProfile user) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 2200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_profileTab(user));
  await tester.pump();
}

Future<void> _pumpEditableProfileTab(
  WidgetTester tester,
  UserProfile user,
  FakeProfileEditUserProfileRepository repository,
) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 2200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
        userProfileRepositoryProvider.overrideWithValue(repository),
      ],
      child: _ProfileEditProviderPrimer(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ProfileTab(
              user: user,
              uploadState: (loadingIndices: <int>{}, uploadError: null),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _dragProfileTabUntilVisible(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.dragUntilVisible(
    finder,
    find.byKey(ProfileTab.scrollViewKey),
    const Offset(0, -300),
  );
}

Finder _profileInfoTile(String label) => find.byWidgetPredicate(
  (widget) => widget is ProfileInfoTile && widget.label == label,
);

Finder _catchChip(String label) => find.byWidgetPredicate(
  (widget) => widget is CatchChip && widget.label == label,
);

void main() {
  testWidgets(
    'Profile sliver header uses Profile title with Edit and Preview tabs',
    (tester) async {
      const topSafeArea = 47.0;
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MediaQuery(
              data: MediaQueryData(padding: EdgeInsets.only(top: topSafeArea)),
              child: _ProfileHeaderHarness(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Profile').hitTestable(), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Edit profile'), findsNothing);
      expect(find.text('Preview profile'), findsNothing);
      expect(find.text('You'), findsNothing);
      expect(
        tester.getTopRight(find.byTooltip('More profile actions')).dx,
        lessThanOrEqualTo(370),
      );
      expect(tester.getTopLeft(find.byType(TabBar)).dy, lessThan(190));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
      await pumpFeatureUi(tester);

      expect(find.text('Profile').hitTestable(), findsNothing);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(TabBar)).dy,
        greaterThanOrEqualTo(topSafeArea),
      );
    },
  );

  testWidgets('ProfileScreen uses native horizontal tab paging', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser(name: 'Suvrat Garg')),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(ProfileTabSliverBody), findsOneWidget);
    expect(find.byType(PreviewTab), findsNothing);

    await tester.drag(find.byType(TabBarView), const Offset(-320, 0));
    await pumpFeatureUi(tester);

    expect(find.byType(PreviewTab), findsOneWidget);
    expect(find.byType(ProfileTabSliverBody), findsNothing);

    await tester.drag(find.byType(TabBarView), const Offset(320, 0));
    await pumpFeatureUi(tester);

    expect(find.byType(ProfileTabSliverBody), findsOneWidget);
    expect(find.byType(PreviewTab), findsNothing);
  });

  testWidgets('ProfileScreen preserves NestedScrollView overlap contract', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser(name: 'Suvrat Garg')),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(SliverOverlapAbsorber), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().contains('OverlapInjector'),
        skipOffstage: false,
      ),
      findsOneWidget,
    );

    final tabBarBottom = tester.getBottomLeft(find.byType(TabBar)).dy;
    final bodyTop = tester.getTopLeft(find.byType(PhotoGrid)).dy;
    expect(bodyTop, greaterThanOrEqualTo(tabBarBottom));

    await tester.drag(
      find.byKey(const PageStorageKey('profile-edit-tab-scroll')),
      const Offset(0, -260),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Profile').hitTestable(), findsNothing);
    expect(find.text('Edit').hitTestable(), findsOneWidget);
    expect(tester.getTopLeft(find.byType(TabBar)).dy, greaterThanOrEqualTo(0));
  });

  testWidgets(
    'ProfileScreen does not subscribe to profile streams while inactive',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith(
              (ref) => throw StateError('watched user profile'),
            ),
          ],
          child: AppShellActiveTab(
            index: appShellHomeTabIndex,
            child: MaterialApp(
              theme: AppTheme.light,
              home: const ProfileScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Profile'), findsNothing);
    },
  );

  testWidgets('Profile preview card can scroll back to the top', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser(name: 'Suvrat Garg')),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Preview'));
    await pumpFeatureUi(tester);

    final previewScrollView = find.byKey(ScrollableProfile.scrollViewKey);
    final previewScroll = tester.widget<SingleChildScrollView>(
      previewScrollView,
    );
    final previewController = previewScroll.controller!;
    final tabBarBottom = tester.getBottomLeft(find.byType(TabBar)).dy;

    expect(previewController.offset, 0);

    await tester.drag(previewScrollView, const Offset(0, -420));
    await pumpFeatureUi(tester);

    expect(previewController.offset, greaterThan(0));

    await tester.drag(previewScrollView, const Offset(0, 900));
    await pumpFeatureUi(tester);

    expect(previewController.offset, 0);
    expect(
      tester.getTopLeft(previewScrollView).dy,
      greaterThanOrEqualTo(tabBarBottom + 8),
    );
    expect(tester.getTopLeft(previewScrollView).dx, 20);
  });

  testWidgets('Profile preview overscroll expands the profile header', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser(name: 'Suvrat Garg')),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Preview'));
    await pumpFeatureUi(tester);

    await tester.drag(find.byType(TabBar), const Offset(0, -220));
    await pumpFeatureUi(tester);

    expect(find.text('Profile').hitTestable(), findsNothing);

    final previewScrollView = find.byKey(ScrollableProfile.scrollViewKey);
    final previewScroll = tester.widget<SingleChildScrollView>(
      previewScrollView,
    );
    expect(previewScroll.controller!.offset, 0);

    await tester.drag(previewScrollView, const Offset(0, 220));
    await pumpFeatureUi(tester);

    expect(find.text('Profile').hitTestable(), findsOneWidget);
  });

  testWidgets('ProfileInfoTile wraps long values without overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: ProfileInfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'averylongemailaddress@examplecatchdatingapp.com',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      find.text('averylongemailaddress@examplecatchdatingapp.com'),
      findsOneWidget,
    );
  });

  testWidgets('ProfileTab shows add affordance for empty email', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final user = buildUser(
      email: '',
    ).copyWith(phoneNumber: '+919876543210', occupation: 'Engineer');

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ProfileTab(
              user: user,
              uploadState: (loadingIndices: <int>{}, uploadError: null),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Email row is visible with add affordance (shows "+ Email")
    expect(find.textContaining('Email'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Engineer'), findsAtLeastNWidgets(1));
    await _dragProfileTabUntilVisible(tester, find.text('+919876543210'));
    expect(find.text('+919876543210'), findsOneWidget);
  });

  testWidgets('ProfileTab starts with compact profile controls', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final user = buildUser(name: 'Suvrat Garg');

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ProfileTab(
              user: user,
              uploadState: (loadingIndices: <int>{}, uploadError: null),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(PhotoGrid), findsOneWidget);
    expect(find.text('On a perfect run'), findsOneWidget);
  });

  testWidgets(
    'ProfileTab edits display name and keeps legal identity readonly',
    (tester) async {
      final user = buildUser(
        name: 'Suvrat Garg',
        firstName: 'Suvrat',
        lastName: 'Garg',
        displayName: 'S.',
      ).copyWith(instagramHandle: 'suvrat_runs');
      await _pumpProfileTab(tester, user);

      final displayNameTile = tester.widget<ProfileInfoTile>(
        _profileInfoTile('Display name'),
      );
      final dobTile = tester.widget<ProfileInfoTile>(
        _profileInfoTile('Date of birth'),
      );
      final genderTile = tester.widget<ProfileInfoTile>(
        _profileInfoTile('Gender'),
      );

      expect(displayNameTile.value, 'S.');
      expect(displayNameTile.onTap, isNotNull);
      expect(find.text('Name'), findsNothing);
      expect(dobTile.onTap, isNull);
      expect(genderTile.onTap, isNull);
      expect(
        tester
            .widgetList<ProfileInfoTile>(find.byType(ProfileInfoTile))
            .first
            .label,
        'Display name',
      );

      final instagramTile = tester.widget<ProfileInfoTile>(
        _profileInfoTile('Instagram'),
      );
      expect(instagramTile.value, '@suvrat_runs');
      expect(instagramTile.onTap, isNotNull);
    },
  );

  testWidgets('display name edit validates and saves trimmed public name', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(
      name: 'Suvrat Garg',
      firstName: 'Suvrat',
      lastName: 'Garg',
      displayName: 'Suvrat',
    );
    await _pumpEditableProfileTab(tester, user, repository);

    final displayNameTile = _profileInfoTile('Display name');
    await tester.tap(displayNameTile);
    await _pumpProfileSheet(tester);

    await tester.enterText(find.byType(CatchTextField), '   ');
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await tester.pump();

    expect(find.text('Display name is required'), findsOneWidget);
    expect(repository.updatedFields, isNull);

    await tester.enterText(find.byType(CatchTextField), ' S. ');
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {'displayName': 'S.'});
    expect(find.byType(CatchTextField), findsNothing);
  });

  testWidgets('Age range sheet opens via RangeSlider and can be dismissed', (
    tester,
  ) async {
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpProfileTab(tester, user);

    // Scroll to and tap the age range row.
    await _dragProfileTabUntilVisible(tester, find.textContaining('18 – 60+'));
    await tester.tap(find.textContaining('18 – 60+'));
    await _pumpProfileSheet(tester);

    // Bottom sheet is open with RangeSlider and Done button.
    expect(find.byType(RangeSlider), findsOneWidget);
    expect(
      tester
          .widget<SliderTheme>(
            find.ancestor(
              of: find.byType(RangeSlider),
              matching: find.byType(SliderTheme),
            ),
          )
          .data
          .inactiveTickMarkColor,
      Colors.transparent,
    );
    expect(
      tester.widget<RangeSlider>(find.byType(RangeSlider)).divisions,
      preferredMatchAgeOpenEndedDisplayAge - minimumProfileAge,
    );
    expect(find.text('Done'), findsOneWidget);

    // Dismiss with Done button.
    await tester.tap(find.text('Done'));
    await _pumpProfileSheet(tester);

    // Sheet closed, no exceptions.
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Pace range sheet opens via RangeSlider and shows formatted pace',
    (tester) async {
      final user = buildUser(name: 'Suvrat Garg');
      await _pumpProfileTab(tester, user);

      // Scroll to and tap the pace range row.
      await _dragProfileTabUntilVisible(tester, find.text('Pace range'));
      await tester.tap(find.text('Pace range'));
      await _pumpProfileSheet(tester);

      // Bottom sheet is open with RangeSlider and Done button.
      expect(find.byType(RangeSlider), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Dismiss with Done button.
      await tester.tap(find.text('Done'));
      await _pumpProfileSheet(tester);

      // Sheet closed, no exceptions.
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('text edit sheet owns its controller through dismissal', (
    tester,
  ) async {
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpProfileTab(tester, user);

    await tester.tap(find.text('Here for the run.'));
    await _pumpProfileSheet(tester);

    expect(find.widgetWithText(CatchButton, 'Done'), findsOneWidget);

    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('email edit sheet uses the email keyboard', (tester) async {
    final user = buildUser(name: 'Suvrat Garg', email: 'runner@example.com');
    await _pumpProfileTab(tester, user);

    final emailTile = find.byWidgetPredicate(
      (widget) => widget is ProfileInfoTile && widget.label == 'Email',
    );
    await _dragProfileTabUntilVisible(tester, emailTile);
    await tester.tap(emailTile);
    await _pumpProfileSheet(tester);

    final field = tester.widget<CatchTextField>(find.byType(CatchTextField));
    expect(field.keyboardType, TextInputType.emailAddress);
    expect(field.autofillHints, contains(AutofillHints.email));
  });

  testWidgets('height edit sheet uses bounded plus-minus controls', (
    tester,
  ) async {
    final user = buildUser(name: 'Suvrat Garg').copyWith(height: 172);
    await _pumpProfileTab(tester, user);

    final heightTile = find.byWidgetPredicate(
      (widget) => widget is ProfileInfoTile && widget.label == 'Height',
    );
    await _dragProfileTabUntilVisible(tester, heightTile);
    await tester.tap(heightTile);
    await _pumpProfileSheet(tester);

    expect(find.byType(CatchTextField), findsNothing);
    expect(find.text('172 cm'), findsAtLeastNWidgets(1));
    expect(find.byTooltip('Decrease height'), findsOneWidget);
    expect(find.byTooltip('Increase height'), findsOneWidget);
    expect(find.widgetWithText(CatchButton, 'Done'), findsOneWidget);

    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('height edit waits for save before closing', (tester) async {
    final repository = FakeProfileEditUserProfileRepository()
      ..updateCompleter = Completer<void>();
    final user = buildUser(name: 'Suvrat Garg').copyWith(height: 172);
    await _pumpEditableProfileTab(tester, user, repository);

    final heightTile = _profileInfoTile('Height');
    await _dragProfileTabUntilVisible(tester, heightTile);
    await tester.tap(heightTile);
    await _pumpProfileSheet(tester);

    await tester.tap(find.byTooltip('Increase height'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await tester.pump();

    expect(repository.updatedFields, {'height': 173});
    expect(find.byTooltip('Increase height'), findsOneWidget);
    expect(
      tester.widget<CatchButton>(find.byType(CatchButton)).isLoading,
      isTrue,
    );

    repository.updateCompleter!.complete();
    await _pumpProfileSheet(tester);

    expect(find.byTooltip('Increase height'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('text edit failure keeps the sheet open with an error', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository()
      ..updateError = StateError('Save failed');
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    await tester.tap(find.text('Here for the run.'));
    await _pumpProfileSheet(tester);
    await tester.enterText(find.byType(CatchTextField), 'Updated bio');
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {'bio': 'Updated bio'});
    expect(find.byType(CatchTextField), findsOneWidget);
    expect(find.textContaining('Save failed'), findsOneWidget);
  });

  testWidgets('text edit waits for save before closing', (tester) async {
    final repository = FakeProfileEditUserProfileRepository()
      ..updateCompleter = Completer<void>();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    await tester.tap(find.text('Here for the run.'));
    await _pumpProfileSheet(tester);
    await tester.enterText(find.byType(CatchTextField), 'Updated bio');
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await tester.pump();

    expect(repository.updatedFields, {'bio': 'Updated bio'});
    expect(find.byType(CatchTextField), findsOneWidget);
    expect(
      tester.widget<CatchButton>(find.byType(CatchButton)).isLoading,
      isTrue,
    );

    repository.updateCompleter!.complete();
    await _pumpProfileSheet(tester);

    expect(find.byType(CatchTextField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('optional single-choice sheets open with no selected chip', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    for (final field in _nullableSingleChoiceFields) {
      final tile = _profileInfoTile(field.tileLabel);
      await _dragProfileTabUntilVisible(tester, tile);
      await tester.tap(tile);
      await _pumpProfileSheet(tester);

      final firstChip = tester.widget<CatchChip>(_catchChip(field.firstLabel));
      expect(firstChip.active, isFalse, reason: field.tileLabel);

      Navigator.of(tester.element(_catchChip(field.firstLabel))).pop();
      await _pumpProfileSheet(tester);
    }
  });

  testWidgets('nullable drinking sheet does not preselect Never', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final drinkingTile = _profileInfoTile('Drinking');
    await _dragProfileTabUntilVisible(tester, drinkingTile);
    await tester.tap(drinkingTile);
    await _pumpProfileSheet(tester);

    final neverChip = tester.widget<CatchChip>(
      _catchChip(DrinkingHabit.never.label),
    );
    expect(neverChip.active, isFalse);
  });

  testWidgets('first optional single-choice chip saves on first selection', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final educationTile = _profileInfoTile('Education');
    await _dragProfileTabUntilVisible(tester, educationTile);
    await tester.tap(educationTile);
    await _pumpProfileSheet(tester);
    await tester.tap(_catchChip(EducationLevel.values.first.label));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {
      'education': EducationLevel.values.first.name,
    });
    expect(_catchChip(EducationLevel.values.first.label), findsNothing);
  });

  testWidgets('single-choice save shows pending state before closing', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository()
      ..updateCompleter = Completer<void>();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final educationTile = _profileInfoTile('Education');
    await _dragProfileTabUntilVisible(tester, educationTile);
    await tester.tap(educationTile);
    await _pumpProfileSheet(tester);
    await tester.tap(_catchChip(EducationLevel.values.first.label));
    await tester.pump();

    expect(repository.updatedFields, {
      'education': EducationLevel.values.first.name,
    });
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Saving Education...'), findsOneWidget);
    expect(
      tester
          .widget<CatchChip>(_catchChip(EducationLevel.values.first.label))
          .enabled,
      isFalse,
    );

    repository.updateCompleter!.complete();
    await _pumpProfileSheet(tester);

    expect(_catchChip(EducationLevel.values.first.label), findsNothing);
  });

  testWidgets(
    'failed single-choice save clears pending selection and keeps sheet open',
    (tester) async {
      final repository = FakeProfileEditUserProfileRepository()
        ..updateError = StateError('Save failed');
      final user = buildUser(name: 'Suvrat Garg');
      await _pumpEditableProfileTab(tester, user, repository);

      final educationTile = _profileInfoTile('Education');
      await _dragProfileTabUntilVisible(tester, educationTile);
      await tester.tap(educationTile);
      await _pumpProfileSheet(tester);
      await tester.tap(_catchChip(EducationLevel.values.first.label));
      await _pumpProfileSheet(tester);

      expect(repository.updatedFields, {
        'education': EducationLevel.values.first.name,
      });
      expect(find.textContaining('Save failed'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        tester
            .widget<CatchChip>(_catchChip(EducationLevel.values.first.label))
            .active,
        isFalse,
      );
    },
  );

  testWidgets(
    'failed single-choice sheets do not leak selection to another field',
    (tester) async {
      final repository = FakeProfileEditUserProfileRepository()
        ..updateError = StateError('Save failed');
      final user = buildUser(name: 'Suvrat Garg');
      await _pumpEditableProfileTab(tester, user, repository);

      final educationTile = _profileInfoTile('Education');
      await _dragProfileTabUntilVisible(tester, educationTile);
      await tester.tap(educationTile);
      await _pumpProfileSheet(tester);
      await tester.tap(_catchChip(EducationLevel.values.first.label));
      await _pumpProfileSheet(tester);

      expect(
        tester
            .widget<CatchChip>(_catchChip(EducationLevel.values.first.label))
            .active,
        isFalse,
      );

      Navigator.of(
        tester.element(_catchChip(EducationLevel.values.first.label)),
      ).pop();
      await _pumpProfileSheet(tester);

      final drinkingTile = _profileInfoTile('Drinking');
      await _dragProfileTabUntilVisible(tester, drinkingTile);
      await tester.tap(drinkingTile);
      await _pumpProfileSheet(tester);

      expect(
        tester.widget<CatchChip>(_catchChip(DrinkingHabit.never.label)).active,
        isFalse,
      );
    },
  );

  testWidgets('multi-choice edit saves before closing', (tester) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final languagesTile = _profileInfoTile('Languages');
    await _dragProfileTabUntilVisible(tester, languagesTile);
    await tester.tap(languagesTile);
    await _pumpProfileSheet(tester);
    await tester.tap(_catchChip(Language.english.label));
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {
      'languages': [Language.english.name],
    });
    expect(_catchChip(Language.english.label), findsNothing);
  });

  testWidgets('range edit saves normalized values before closing', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    await _dragProfileTabUntilVisible(tester, find.textContaining('18 – 60+'));
    await tester.tap(find.textContaining('18 – 60+'));
    await _pumpProfileSheet(tester);

    tester.widget<RangeSlider>(find.byType(RangeSlider)).onChanged!(
      const RangeValues(20, 60),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {
      'minAgePreference': 20,
      'maxAgePreference': 99,
    });
    expect(find.byType(RangeSlider), findsNothing);
  });
}

Future<void> _pumpProfileSheet(WidgetTester tester) async {
  await pumpFeatureUi(tester);
}

const _nullableSingleChoiceFields = [
  (tileLabel: 'Education', firstLabel: 'High school'),
  (tileLabel: 'Religion', firstLabel: 'Hindu'),
  (tileLabel: 'Looking for', firstLabel: 'Long-term relationship'),
  (tileLabel: 'Drinking', firstLabel: 'Never'),
  (tileLabel: 'Smoking', firstLabel: 'Never'),
  (tileLabel: 'Workout', firstLabel: 'Never'),
  (tileLabel: 'Diet', firstLabel: 'Omnivore'),
  (tileLabel: 'Children', firstLabel: "Don't have"),
  (tileLabel: 'City', firstLabel: 'Mumbai'),
];

class _ProfileHeaderHarness extends StatefulWidget {
  const _ProfileHeaderHarness();

  @override
  State<_ProfileHeaderHarness> createState() => _ProfileHeaderHarnessState();
}

class _ProfileHeaderHarnessState extends State<_ProfileHeaderHarness>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            ...ProfileSliverHeader(
              controller: _controller,
            ).buildSlivers(context),
            SliverList.builder(
              itemCount: 30,
              itemBuilder: (context, index) =>
                  SizedBox(height: 56, child: Text('Profile content $index')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditProviderPrimer extends ConsumerWidget {
  const _ProfileEditProviderPrimer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(uidProvider);
    return child;
  }
}

class FakeProfileEditUserProfileRepository extends Fake
    implements UserProfileRepository {
  Completer<void>? updateCompleter;
  Object? updateError;
  String? updatedUid;
  Map<String, dynamic>? updatedFields;

  @override
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> fields,
  }) async {
    updatedUid = uid;
    updatedFields = Map<String, dynamic>.from(fields);
    final error = updateError;
    if (error != null) throw error;
    final completer = updateCompleter;
    if (completer != null) await completer.future;
  }
}
