import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/scrollable_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/preview_tab.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_tile.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
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
      expect(find.byTooltip('More profile actions'), findsNothing);
      expect(
        tester.getTopRight(find.byTooltip('Settings')).dx,
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
    expect(_profileInfoTile('Bio'), findsOneWidget);
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
      expect(_profileInfoTile('Bio'), findsOneWidget);

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

    expect(
      find.descendant(
        of: displayNameTile,
        matching: find.byType(ProfileInlineEditableText),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: displayNameTile,
        matching: find.byType(CatchTextField),
      ),
      findsNothing,
    );
    expect(find.text('Display name'), findsOneWidget);

    var inlineEditable = find.descendant(
      of: displayNameTile,
      matching: find.byType(EditableText),
    );
    await tester.enterText(inlineEditable, '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Display name is required'), findsOneWidget);
    expect(repository.updatedFields, isNull);

    inlineEditable = find.descendant(
      of: displayNameTile,
      matching: find.byType(EditableText),
    );
    await tester.enterText(inlineEditable, ' S. ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {'displayName': 'S.'});
    expect(find.byType(CatchTextField), findsNothing);
  });

  testWidgets('inline editable text underline follows scaled text width', (
    tester,
  ) async {
    final controller = TextEditingController(text: '+919131404263');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.35)),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 340,
                    child: ProfileInlineEditableText(
                      label: 'Phone',
                      controller: controller,
                      focusNode: focusNode,
                      enabled: true,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    final context = tester.element(find.byType(ProfileInlineEditableText));
    final t = CatchTokens.of(context);
    final style = CatchTextStyles.bodyL(context, color: t.ink);
    final painter = TextPainter(
      text: TextSpan(text: controller.text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final underline = find.descendant(
      of: find.byType(ProfileInlineEditableText),
      matching: find.byType(AnimatedContainer),
    );

    expect(tester.getSize(underline).width, closeTo(painter.width, 0.1));
  });

  testWidgets('profile inline drawers animate open and closed', (tester) async {
    final user = buildUser(name: 'Suvrat Garg').copyWith(height: 172);
    await _pumpProfileTab(tester, user);

    final heightTile = _profileInfoTile('Height');
    await _dragProfileTabUntilVisible(tester, heightTile);
    await tester.tap(heightTile);
    await _pumpProfileSheet(tester);

    expect(find.byType(ProfileInlineAnimatedBody), findsWidgets);
    expect(find.byTooltip('Increase height'), findsOneWidget);

    await tester.tap(heightTile);
    await tester.pump();

    expect(find.byTooltip('Increase height'), findsOneWidget);

    await _pumpProfileSheet(tester);

    expect(find.byTooltip('Increase height'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileTab omits private discovery filters', (tester) async {
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpProfileTab(tester, user);

    expect(find.text('Discovery'), findsNothing);
    expect(find.text('Interested in'), findsNothing);
    expect(find.text('Age range'), findsNothing);
    expect(find.textContaining('18 – 60+'), findsNothing);
  });

  testWidgets('Pace range expands inline with shared RangeSlider', (
    tester,
  ) async {
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpProfileTab(tester, user);

    // Scroll to and tap the pace range row.
    await _dragProfileTabUntilVisible(tester, find.text('Pace range'));
    await tester.tap(find.text('Pace range'));
    await _pumpProfileSheet(tester);

    // Inline editor is open with the shared range slider and Done button.
    expect(find.byType(CatchRangeSlider), findsOneWidget);
    expect(find.byType(RangeSlider), findsOneWidget);
    expect(find.text('5:00 - 7:00 /km'), findsNothing);
    expect(find.text('4:00/km'), findsOneWidget);
    expect(find.text('9:00/km'), findsOneWidget);
    final catchRangeSlider = tester.widget<CatchRangeSlider>(
      find.byType(CatchRangeSlider),
    );
    expect(catchRangeSlider.minLabel, '4:00/km');
    expect(catchRangeSlider.maxLabel, '9:00/km');
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
    expect(find.text('Done'), findsOneWidget);

    // Dismiss with Done button.
    await tester.tap(find.text('Done'));
    await _pumpProfileSheet(tester);

    // Sheet closed, no exceptions.
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline text edit owns its controller through dismissal', (
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

  testWidgets('bio edit uses the profile row-owned multiline inline editor', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final bioTile = _profileInfoTile('Bio');
    await tester.tap(bioTile);
    await _pumpProfileSheet(tester);

    expect(
      find.descendant(
        of: bioTile,
        matching: find.byType(ProfileInlineEditableText),
      ),
      findsOneWidget,
    );
    final bioField = tester.widget<ProfileInlineEditableText>(
      find.descendant(
        of: bioTile,
        matching: find.byType(ProfileInlineEditableText),
      ),
    );
    expect(bioField.maxLines, 4);
    expect(bioField.minLines, 3);

    await tester.enterText(
      find.descendant(of: bioTile, matching: find.byType(EditableText)),
      ' Updated bio ',
    );
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {'bio': 'Updated bio'});
    expect(find.byType(ProfileInlineEditableText), findsNothing);
  });

  testWidgets('inline email edit uses the email keyboard', (tester) async {
    final user = buildUser(name: 'Suvrat Garg', email: 'runner@example.com');
    await _pumpProfileTab(tester, user);

    final emailTile = find.byWidgetPredicate(
      (widget) => widget is ProfileInfoTile && widget.label == 'Email',
    );
    await _dragProfileTabUntilVisible(tester, emailTile);
    await tester.tap(emailTile);
    await _pumpProfileSheet(tester);

    expect(find.byType(CatchTextField), findsNothing);
    final field = tester.widget<ProfileInlineEditableText>(
      find.byType(ProfileInlineEditableText),
    );
    expect(field.keyboardType, TextInputType.emailAddress);
    expect(field.autofillHints, contains(AutofillHints.email));
  });

  testWidgets('height inline edit uses bounded plus-minus controls', (
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
    expect(find.text('120-220 cm'), findsNothing);
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

  testWidgets('text edit failure keeps the inline editor open with an error', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository()
      ..updateError = StateError('Save failed');
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final bioTile = _profileInfoTile('Bio');
    await tester.tap(bioTile);
    await _pumpProfileSheet(tester);
    await tester.enterText(
      find.descendant(of: bioTile, matching: find.byType(EditableText)),
      'Updated bio',
    );
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {'bio': 'Updated bio'});
    expect(find.byType(ProfileInlineEditableText), findsOneWidget);
    expect(find.textContaining('Save failed'), findsOneWidget);
  });

  testWidgets('bio edit validates against callable length limit', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final bioTile = _profileInfoTile('Bio');
    await tester.tap(bioTile);
    await _pumpProfileSheet(tester);
    await tester.enterText(
      find.descendant(of: bioTile, matching: find.byType(EditableText)),
      'a' * 2001,
    );
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await tester.pump();

    expect(repository.updatedFields, isNull);
    expect(find.text('Bio must be 2000 characters or fewer'), findsOneWidget);
    expect(find.byType(ProfileInlineEditableText), findsOneWidget);
  });

  testWidgets('text edit waits for save before closing', (tester) async {
    final repository = FakeProfileEditUserProfileRepository()
      ..updateCompleter = Completer<void>();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final bioTile = _profileInfoTile('Bio');
    await tester.tap(bioTile);
    await _pumpProfileSheet(tester);
    await tester.enterText(
      find.descendant(of: bioTile, matching: find.byType(EditableText)),
      'Updated bio',
    );
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await tester.pump();

    expect(repository.updatedFields, {'bio': 'Updated bio'});
    expect(find.byType(ProfileInlineEditableText), findsOneWidget);
    expect(
      tester.widget<CatchButton>(find.byType(CatchButton)).isLoading,
      isTrue,
    );

    repository.updateCompleter!.complete();
    await _pumpProfileSheet(tester);

    expect(find.byType(ProfileInlineEditableText), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'optional single-choice inline editors open with no selected chip',
    (tester) async {
      final repository = FakeProfileEditUserProfileRepository();
      final user = buildUser(name: 'Suvrat Garg');
      await _pumpEditableProfileTab(tester, user, repository);

      for (final field in _nullableSingleChoiceFields) {
        final tile = _profileInfoTile(field.tileLabel);
        await _dragProfileTabUntilVisible(tester, tile);
        await tester.tap(tile);
        await _pumpProfileSheet(tester);

        final firstChip = tester.widget<CatchChip>(
          _catchChip(field.firstLabel),
        );
        expect(firstChip.active, isFalse, reason: field.tileLabel);

        await tester.tap(find.byTooltip('Collapse ${field.tileLabel}'));
        await _pumpProfileSheet(tester);
      }
    },
  );

  testWidgets('nullable drinking inline editor does not preselect Never', (
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

  testWidgets('inline chip editors do not repeat the field label', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final childrenTile = _profileInfoTile('Children');
    await _dragProfileTabUntilVisible(tester, childrenTile);
    await tester.tap(childrenTile);
    await _pumpProfileSheet(tester);

    expect(find.text('Children'), findsOneWidget);
    expect(_catchChip(ChildrenStatus.dontHave.label), findsOneWidget);
  });

  testWidgets('single-choice chip saves only after Done', (tester) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final educationTile = _profileInfoTile('Education');
    await _dragProfileTabUntilVisible(tester, educationTile);
    await tester.tap(educationTile);
    await _pumpProfileSheet(tester);
    await tester.tap(_catchChip(EducationLevel.values.first.label));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, isNull);
    expect(
      tester
          .widget<CatchChip>(_catchChip(EducationLevel.values.first.label))
          .active,
      isTrue,
    );

    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {
      'education': EducationLevel.values.first.name,
    });
    expect(_catchChip(EducationLevel.values.first.label), findsNothing);
  });

  testWidgets('single-choice chip can be deselected and saved as null', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(
      name: 'Suvrat Garg',
    ).copyWith(education: EducationLevel.highSchool);
    await _pumpEditableProfileTab(tester, user, repository);

    final educationTile = _profileInfoTile('Education');
    await _dragProfileTabUntilVisible(tester, educationTile);
    await tester.tap(educationTile);
    await _pumpProfileSheet(tester);

    expect(_catchChip(EducationLevel.highSchool.label), findsOneWidget);
    expect(
      tester
          .widget<CatchChip>(_catchChip(EducationLevel.highSchool.label))
          .active,
      isTrue,
    );

    await tester.tap(_catchChip(EducationLevel.highSchool.label));
    await _pumpProfileSheet(tester);

    expect(find.text('+ Education'), findsOneWidget);
    expect(_catchChip(EducationLevel.highSchool.label), findsOneWidget);
    expect(
      tester
          .widget<CatchChip>(_catchChip(EducationLevel.highSchool.label))
          .active,
      isFalse,
    );

    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {'education': null});
    expect(_catchChip(EducationLevel.highSchool.label), findsNothing);
  });

  testWidgets('single-choice empty draft does not show stale saved value', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(
      name: 'Suvrat Garg',
    ).copyWith(relationshipGoal: RelationshipGoal.relationship);
    await _pumpEditableProfileTab(tester, user, repository);

    final lookingForTile = _profileInfoTile('Looking for');
    await _dragProfileTabUntilVisible(tester, lookingForTile);
    await tester.tap(lookingForTile);
    await _pumpProfileSheet(tester);

    expect(_catchChip(RelationshipGoal.relationship.label), findsOneWidget);

    await tester.tap(_catchChip(RelationshipGoal.relationship.label));
    await _pumpProfileSheet(tester);

    final relationshipTexts = find.text(RelationshipGoal.relationship.label);
    expect(relationshipTexts, findsOneWidget);
    expect(find.text('+ Looking for'), findsOneWidget);
    expect(
      tester
          .widget<CatchChip>(_catchChip(RelationshipGoal.relationship.label))
          .active,
      isFalse,
    );
  });

  testWidgets('multi-choice selected chips move into the row value slot', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(
      name: 'Suvrat Garg',
    ).copyWith(languages: [Language.english]);
    await _pumpEditableProfileTab(tester, user, repository);

    final languagesTile = _profileInfoTile('Languages');
    await _dragProfileTabUntilVisible(tester, languagesTile);
    await tester.tap(languagesTile);
    await _pumpProfileSheet(tester);

    expect(_catchChip(Language.english.label), findsOneWidget);
    final selectedLanguageChip = tester.widget<CatchChip>(
      _catchChip(Language.english.label),
    );
    expect(selectedLanguageChip.active, isTrue);
    expect(selectedLanguageChip.icon, isA<Icon>());
    expect((selectedLanguageChip.icon! as Icon).icon, Icons.check_rounded);

    await tester.tap(_catchChip(Language.english.label));
    await _pumpProfileSheet(tester);

    expect(_catchChip(Language.english.label), findsOneWidget);
    expect(
      tester.widget<CatchChip>(_catchChip(Language.english.label)).active,
      isFalse,
    );
    expect(repository.updatedFields, isNull);
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
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, isNull);

    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await tester.pump();

    expect(repository.updatedFields, {
      'education': EducationLevel.values.first.name,
    });
    expect(
      tester.widget<CatchButton>(find.byType(CatchButton)).isLoading,
      isTrue,
    );
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
    'failed single-choice save clears pending selection and keeps editor open',
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
      await tester.tap(find.widgetWithText(CatchButton, 'Done'));
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
        isTrue,
      );
    },
  );

  testWidgets(
    'failed single-choice editors do not leak selection to another field',
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
      await tester.tap(find.widgetWithText(CatchButton, 'Done'));
      await _pumpProfileSheet(tester);

      expect(
        tester
            .widget<CatchChip>(_catchChip(EducationLevel.values.first.label))
            .active,
        isTrue,
      );

      await tester.tap(educationTile);
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

  testWidgets('pace range edit saves values before closing', (tester) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    await _dragProfileTabUntilVisible(tester, find.text('Pace range'));
    await tester.tap(find.text('Pace range'));
    await _pumpProfileSheet(tester);

    tester.widget<RangeSlider>(find.byType(RangeSlider)).onChanged!(
      const RangeValues(310, 370),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {
      'paceMinSecsPerKm': 310,
      'paceMaxSecsPerKm': 370,
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
