import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchMotion, CatchStroke;
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_upload_controller.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/catch_profile_view.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_surface.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/preview_tab.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_insights_tab.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_sliver_header.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../events/events_test_helpers.dart';
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

Widget _profileWidgetHarness(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
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

UserProfile _profilePreviewScrollFixture() {
  return buildUser(name: 'Suvrat Garg').copyWith(
    relationshipGoal: RelationshipGoal.relationship,
    height: 178,
    occupation: 'Product designer',
    company: 'Catch',
    education: EducationLevel.masters,
    religion: Religion.hindu,
    languages: const [Language.english, Language.hindi],
    drinking: DrinkingHabit.socially,
    smoking: SmokingHabit.never,
    workout: WorkoutFrequency.often,
    diet: DietaryPreference.vegetarian,
    children: ChildrenStatus.wantSomeday,
  );
}

Future<void> _pumpEditableProfileTab(
  WidgetTester tester,
  UserProfile user,
  FakeProfileEditUserProfileRepository repository,
) async {
  repository.latestProfile = user;
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 2200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
        errorLoggerProvider.overrideWithValue(_SilentErrorLogger()),
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
  await tester.ensureVisible(finder);
  await tester.pump();
}

Future<void> _dragProfileTabUntilTappable(
  WidgetTester tester,
  Finder finder,
) async {
  await _dragProfileTabUntilVisible(tester, finder);
  await tester.drag(
    find.byKey(ProfileTab.scrollViewKey),
    const Offset(0, -260),
  );
  await tester.pump();
}

Finder _profileInfoTile(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is CatchField &&
      widget.title == label &&
      widget.variant == CatchFieldVariant.row,
);

Finder _editableTextForProfileField(String label) => find.descendant(
  of: _profileInfoTile(label),
  matching: find.byType(EditableText),
);

Finder _inlinePromptEditableText() => find.descendant(
  of: find.byType(ProfileInlineTextValue),
  matching: find.byType(EditableText),
);

Finder _profileOptionGroup() => find.byType(CatchOptionGroup<int>);

Finder _catchChip(String label) => find.byWidgetPredicate(
  (widget) => widget is CatchChip && widget.label == label,
);

int _loadingCatchButtonCount(WidgetTester tester) => tester
    .widgetList<CatchButton>(find.byType(CatchButton))
    .where((button) => button.isLoading)
    .length;

Future<void> _tapInlineDone(WidgetTester tester) async {
  final doneButton = find.widgetWithText(CatchButton, 'Done');
  tester.widget<CatchButton>(doneButton).onPressed?.call();
  await tester.pump();
}

Future<void> _tapInlineCancel(WidgetTester tester) async {
  final cancelButton = find.widgetWithText(CatchTextButton, 'Cancel');
  tester.widget<CatchTextButton>(cancelButton).onPressed?.call();
  await tester.pump();
}

final _perfectRunPromptTitle = profilePromptDefinition(
  profilePromptPerfectEventId,
).title;

void main() {
  testWidgets('ProfileScreen renders tab-shaped skeletons while loading', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = StreamController<UserProfile?>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchUserProfileProvider.overrideWith((ref) => controller.stream),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(ProfileTabSkeletonSliverBody), findsOneWidget);
    expect(find.byType(CatchLoadingIndicator), findsNothing);

    await tester.tap(find.text('Preview'));
    await tester.pump();
    await tester.pump(CatchMotion.base);

    expect(find.byType(ProfileSurfaceSkeleton), findsOneWidget);
  });

  testWidgets(
    'Profile sliver header uses Your profile title with profile tab options',
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

      expect(find.text('Your profile'), findsOneWidget);
      expect(find.text('Your profile').hitTestable(), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Edit profile'), findsNothing);
      expect(find.text('Preview profile'), findsNothing);
      expect(find.text('You'), findsNothing);
      expect(find.byTooltip('More profile actions'), findsNothing);
      expect(
        tester.getTopRight(find.byTooltip('Settings')).dx,
        lessThanOrEqualTo(370),
      );
      final profileTitleBottom = tester
          .getBottomLeft(find.text('Your profile'))
          .dy;
      final tabsTop = tester.getTopLeft(_profileOptionGroup()).dy;
      expect(tabsTop, greaterThan(profileTitleBottom));
      expect(tabsTop - profileTitleBottom, lessThanOrEqualTo(24));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
      await pumpFeatureUi(tester);

      expect(find.text('Your profile').hitTestable(), findsNothing);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Insights'), findsOneWidget);
      expect(
        tester.getTopLeft(_profileOptionGroup()).dy,
        greaterThanOrEqualTo(topSafeArea),
      );
    },
  );

  testWidgets('Profile settings button routes to account settings', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: Routes.profileScreen.path,
      routes: [
        GoRoute(
          path: Routes.profileScreen.path,
          name: Routes.profileScreen.name,
          builder: (context, state) => const _ProfileHeaderHarness(),
        ),
        GoRoute(
          path: Routes.settingsScreen.path,
          name: Routes.settingsScreen.name,
          builder: (context, state) =>
              const Scaffold(body: Text('Settings route reached')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);

    expect(find.text('Settings route reached'), findsOneWidget);
  });

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
            (ref) => Stream.value(_profilePreviewScrollFixture()),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(ProfileTabSliverBody), findsOneWidget);
    expect(find.byType(PreviewTab), findsNothing);
    expect(find.byType(ProfileInsightsTabSliverBody), findsNothing);

    await tester.drag(find.byType(TabBarView), const Offset(-320, 0));
    await pumpFeatureUi(tester);

    expect(find.byType(PreviewTab), findsOneWidget);
    expect(find.byType(ProfileTabSliverBody), findsNothing);
    expect(find.byType(ProfileInsightsTabSliverBody), findsNothing);

    await tester.drag(find.byType(TabBarView), const Offset(-320, 0));
    await pumpFeatureUi(tester);

    expect(find.byType(ProfileInsightsTabSliverBody), findsOneWidget);
    expect(find.byType(ProfileTabSliverBody), findsNothing);
    expect(find.byType(PreviewTab), findsNothing);

    await tester.drag(find.byType(TabBarView), const Offset(320, 0));
    await pumpFeatureUi(tester);

    expect(find.byType(PreviewTab), findsOneWidget);
    expect(find.byType(ProfileTabSliverBody), findsNothing);
    expect(find.byType(ProfileInsightsTabSliverBody), findsNothing);

    await tester.drag(find.byType(TabBarView), const Offset(320, 0));
    await pumpFeatureUi(tester);

    expect(find.byType(ProfileTabSliverBody), findsOneWidget);
    expect(find.byType(PreviewTab), findsNothing);
    expect(find.byType(ProfileInsightsTabSliverBody), findsNothing);
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
            (ref) => Stream.value(_profilePreviewScrollFixture()),
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

    final tabBarBottom = tester.getBottomLeft(_profileOptionGroup()).dy;
    final bodyTop = tester.getTopLeft(find.byType(PhotoGrid)).dy;
    expect(bodyTop, greaterThanOrEqualTo(tabBarBottom));

    await tester.drag(
      find.byKey(const PageStorageKey('profile-edit-tab-scroll')),
      const Offset(0, -260),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Your profile').hitTestable(), findsNothing);
    expect(find.text('Edit').hitTestable(), findsOneWidget);
    expect(
      tester.getTopLeft(_profileOptionGroup()).dy,
      greaterThanOrEqualTo(0),
    );
  });

  testWidgets('ProfileScreen surfaces profile photo upload failures', (
    tester,
  ) async {
    final user = buildUser();
    final repository = FakeProfileEditUserProfileRepository()
      ..latestProfile = user;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream<UserProfile?>.value(user),
          ),
          userProfileRepositoryProvider.overrideWithValue(repository),
          imageUploadRepositoryProvider.overrideWithValue(
            _FailingProfileImageUploadRepository(),
          ),
          errorLoggerProvider.overrideWithValue(_SilentErrorLogger()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const _ProfileUploadFailureSeeder(),
        ),
      ),
    );

    await pumpFeatureUi(tester);
    await pumpFeatureUi(tester);

    expect(
      find.text(
        'No internet connection. Connect to the internet and try again.',
      ),
      findsOneWidget,
    );
    expect(find.byType(CatchLoadingIndicator), findsNothing);
  });

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
            (ref) => Stream.value(_profilePreviewScrollFixture()),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Preview'));
    await pumpFeatureUi(tester);

    expect(tester.widget<PreviewTab>(find.byType(PreviewTab)).bottomPadding, 0);

    final previewScrollView = find.byKey(CatchProfileView.scrollViewKey);
    final previewScroll = tester.widget<CustomScrollView>(previewScrollView);
    final previewController = previewScroll.controller!;
    final tabBarBottom = tester.getBottomLeft(_profileOptionGroup()).dy;

    expect(previewController.offset, 0);

    await tester.drag(previewScrollView, const Offset(0, -900));
    await pumpFeatureUi(tester);

    expect(previewController.offset, greaterThan(0));

    await tester.drag(previewScrollView, const Offset(0, 900));
    await pumpFeatureUi(tester);

    expect(previewController.offset, 0);
    expect(
      tester.getTopLeft(previewScrollView).dy,
      greaterThanOrEqualTo(tabBarBottom + 8),
    );
    expect(tester.getTopLeft(previewScrollView).dx, 0);
  });

  testWidgets('Profile preview upward drag pins the profile tabs', (
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

    final previewScrollView = find.byKey(CatchProfileView.scrollViewKey);
    final previewScroll = tester.widget<CustomScrollView>(previewScrollView);

    expect(find.text('Your profile').hitTestable(), findsOneWidget);
    expect(previewScroll.controller!.offset, 0);

    await tester.drag(previewScrollView, const Offset(0, -260));
    await pumpFeatureUi(tester);

    expect(find.text('Your profile').hitTestable(), findsNothing);
    expect(find.text('Preview').hitTestable(), findsOneWidget);
    expect(tester.getTopLeft(_profileOptionGroup()).dy, lessThanOrEqualTo(8));
    expect(previewScroll.controller!.offset, lessThan(260));
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

    await tester.drag(_profileOptionGroup(), const Offset(0, -220));
    await pumpFeatureUi(tester);

    expect(find.text('Your profile').hitTestable(), findsNothing);

    final previewScrollView = find.byKey(CatchProfileView.scrollViewKey);
    final previewScroll = tester.widget<CustomScrollView>(previewScrollView);
    expect(previewScroll.controller!.offset, 0);

    await tester.drag(previewScrollView, const Offset(0, 220));
    await pumpFeatureUi(tester);

    expect(find.text('Your profile').hitTestable(), findsOneWidget);
  });

  testWidgets('profile info field wraps long values without overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: CatchField.nav(
                icon: CatchIcons.emailOutlined,
                title: 'Email',
                body: 'averylongemailaddress@examplecatchdatingapp.com',
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
    await _dragProfileTabUntilVisible(tester, find.text('Engineer'));
    expect(find.text('Engineer'), findsOneWidget);
    await _dragProfileTabUntilVisible(tester, find.text('+919876543210'));
    expect(find.text('+919876543210'), findsOneWidget);
  });

  testWidgets('ProfileTab starts with handoff profile edit sections', (
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
    expect(find.text('Profile strength'), findsNothing);
    expect(find.textContaining('PHOTOS', findRichText: true), findsOneWidget);
    expect(find.textContaining('PROMPTS', findRichText: true), findsOneWidget);
    expect(find.text('ABOUT YOU'), findsOneWidget);
    expect(find.text('RUNNING'), findsOneWidget);
    expect(find.text('LIFESTYLE'), findsOneWidget);
    expect(_profileInfoTile(_perfectRunPromptTitle), findsOneWidget);
  });

  testWidgets('ProfileTab field rows honor fixed screen gutters', (
    tester,
  ) async {
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpProfileTab(tester, user);

    final displayNameTile = _profileInfoTile('Display name');
    expect(displayNameTile, findsOneWidget);

    final rowRect = tester.getRect(displayNameTile);
    expect(rowRect.left, CatchSpacing.screenPx);
    expect(rowRect.right, 390 - CatchSpacing.screenPx);

    // Flush contract: within the fixed gutter the row content spans the full
    // section width — the leading icon starts on the row's leading edge.
    final leadingIcon = find
        .descendant(of: displayNameTile, matching: find.byType(Icon))
        .first;
    expect(tester.getRect(leadingIcon).left, rowRect.left);

    // Every section divider aligns to the field text lane (derived from the
    // leading-slot metrics) and terminates on the row's trailing edge.
    final dividers = find.byWidgetPredicate(
      (widget) =>
          widget is ColoredBox &&
          widget.child is SizedBox &&
          (widget.child as SizedBox).height == CatchStroke.hairline,
    );
    expect(dividers, findsWidgets);
    for (final element in dividers.evaluate()) {
      final box = element.renderObject! as RenderBox;
      final dividerRect = box.localToGlobal(Offset.zero) & box.size;
      expect(dividerRect.left - rowRect.left, CatchFieldRow.textLaneInset);
      expect(dividerRect.right, rowRect.right);
    }
  });

  testWidgets(
    'ProfileTab edits display name and keeps legal identity readonly',
    (tester) async {
      final user = buildUser(
        name: 'Suvrat Garg',
        firstName: 'Suvrat',
        lastName: 'Garg',
        displayName: 'S.',
      ).copyWith(instagramHandle: 'suvrat_events');
      await _pumpProfileTab(tester, user);

      final displayNameTile = tester.widget<CatchField>(
        _profileInfoTile('Display name'),
      );
      final dobTile = tester.widget<CatchField>(
        _profileInfoTile('Date of birth'),
      );
      final genderTile = tester.widget<CatchField>(_profileInfoTile('Gender'));

      expect(displayNameTile.mode, CatchFieldMode.edit);
      expect(displayNameTile.enabled, isTrue);
      expect(
        find.descendant(
          of: _profileInfoTile('Display name'),
          matching: find.text('S.'),
        ),
        findsWidgets,
      );
      expect(find.text('Name'), findsNothing);
      expect(dobTile.mode, CatchFieldMode.nav);
      expect(dobTile.onTap, isNull);
      expect(genderTile.mode, CatchFieldMode.nav);
      expect(genderTile.onTap, isNull);
      expect(_profileInfoTile(_perfectRunPromptTitle), findsOneWidget);

      final instagramTile = tester.widget<CatchField>(
        _profileInfoTile('Instagram'),
      );
      expect(instagramTile.mode, CatchFieldMode.edit);
      expect(instagramTile.enabled, isTrue);
      expect(find.text('@suvrat_events'), findsOneWidget);
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

    expect(_editableTextForProfileField('Display name'), findsOneWidget);
    expect(find.text('Display name'), findsOneWidget);

    var inlineEditable = _editableTextForProfileField('Display name');
    await tester.enterText(inlineEditable, '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Display name is required'), findsOneWidget);
    expect(repository.updatedFields, isNull);

    inlineEditable = _editableTextForProfileField('Display name');
    await tester.enterText(inlineEditable, ' S. ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {'displayName': 'S.'});
  });

  testWidgets('inline text value edits through CatchField input primitive', (
    tester,
  ) async {
    final controller = TextEditingController(text: '+919131404263');
    addTearDown(controller.dispose);

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
                    child: ProfileInlineTextValue(
                      label: 'Phone',
                      displayValue: controller.text,
                      controller: controller,
                      isEditing: true,
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

    final input = find.descendant(
      of: find.byType(ProfileInlineTextValue),
      matching: find.byType(CatchField),
    );
    final field = tester.widget<CatchField>(input);
    final textField = tester.widget<TextField>(
      find.descendant(of: input, matching: find.byType(TextField)),
    );

    expect(input, findsOneWidget);
    expect(field.variant, CatchFieldVariant.underline);
    expect(field.size, CatchFieldSize.floating);
    expect(field.showLabel, isFalse);
    expect(field.controller, same(controller));
    expect(textField.controller, same(controller));
    expect(textField.keyboardType, TextInputType.phone);
    expect(textField.autofocus, isTrue);
  });

  testWidgets(
    'multiline prompt text wires formatters through CatchField input',
    (tester) async {
      final controller = TextEditingController(
        text: 'This is the widest prompt line\nshort',
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: ProfileInlineTextValue(
                  label: _perfectRunPromptTitle,
                  displayValue: '',
                  controller: controller,
                  isEditing: true,
                  enabled: true,
                  maxLines: null,
                  maxLength: maximumProfilePromptAnswerLength,
                  collapseStackedBlankLines: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final input = find.descendant(
        of: find.byType(ProfileInlineTextValue),
        matching: find.byType(CatchField),
      );
      final field = tester.widget<CatchField>(input);
      final textField = tester.widget<TextField>(
        find.descendant(of: input, matching: find.byType(TextField)),
      );

      expect(input, findsOneWidget);
      expect(field.maxLines, isNull);
      expect(field.inputFormatters, hasLength(2));
      expect(
        field.inputFormatters!.whereType<LengthLimitingTextInputFormatter>(),
        hasLength(1),
      );
      expect(textField.maxLines, isNull);
      expect(textField.inputFormatters, same(field.inputFormatters));
    },
  );

  testWidgets('profile inline drawers animate open and closed', (tester) async {
    final user = buildUser(name: 'Suvrat Garg').copyWith(height: 172);
    await _pumpProfileTab(tester, user);

    final heightTile = _profileInfoTile('Height');
    await _dragProfileTabUntilVisible(tester, heightTile);
    await tester.tap(heightTile);
    await _pumpProfileSheet(tester);

    expect(find.byTooltip('Increase height'), findsOneWidget);
    expect(find.widgetWithText(CatchButton, 'Done'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await _tapInlineCancel(tester);
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

  testWidgets(
    'ProfileTab keeps the handoff Running section available before setup',
    (tester) async {
      final user = buildUser(name: 'Suvrat Garg', runPreferencesVersion: 0);
      await _pumpProfileTab(tester, user);

      expect(find.text('RUNNING'), findsOneWidget);
      expect(_profileInfoTile('Pace range'), findsOneWidget);
    },
  );

  testWidgets('Pace range expands inline with shared RangeSlider', (
    tester,
  ) async {
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpProfileTab(tester, user);

    // Scroll to and tap the pace range row.
    final paceTile = _profileInfoTile('Pace range');
    await _dragProfileTabUntilTappable(tester, paceTile);
    await tester.tap(paceTile);
    await _pumpProfileSheet(tester);

    // Inline editor is open with the shared range slider and Done button.
    expect(find.byType(CatchRangeSlider), findsOneWidget);
    expect(find.byType(RangeSlider), findsOneWidget);
    expect(find.text('5:00/km - 7:00/km'), findsOneWidget);
    final catchRangeSlider = tester.widget<CatchRangeSlider>(
      find.byType(CatchRangeSlider),
    );
    expect(catchRangeSlider.minLabel, isNull);
    expect(catchRangeSlider.maxLabel, isNull);
    final rangeSlider = tester.widget<RangeSlider>(find.byType(RangeSlider));
    expect(rangeSlider.labels, isNull);
    rangeSlider.onChanged!(const RangeValues(270, 540));
    await tester.pump();
    expect(find.text('4:30/km - 9:00/km'), findsOneWidget);
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

    await tester.tap(find.text('Here for the event.'));
    await _pumpProfileSheet(tester);

    expect(find.widgetWithText(CatchButton, 'Done'), findsOneWidget);

    await _tapInlineDone(tester);
    await _pumpProfileSheet(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('prompt edit uses the stable profile row-owned text primitive', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final promptTile = _profileInfoTile(_perfectRunPromptTitle);
    await tester.tap(promptTile);
    await _pumpProfileSheet(tester);

    expect(find.byType(ProfileInlineTextValue), findsOneWidget);
    final promptField = tester.widget<ProfileInlineTextValue>(
      find.byType(ProfileInlineTextValue),
    );
    expect(promptField.maxLines, isNull);
    expect(promptField.minLines, isNull);
    expect(promptField.maxLength, maximumProfilePromptAnswerLength);

    await tester.enterText(_inlinePromptEditableText(), ' Updated bio ');
    await _tapInlineDone(tester);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields?['profilePrompts'], [
      containsPair('answer', 'Updated bio'),
    ]);
    expect(_inlinePromptEditableText(), findsNothing);
  });

  testWidgets('prompt picker excludes prompts used by other rows', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final favoriteRoute = profilePromptDefinition('favoriteRoute');
    final usedPrompt = profilePromptDefinition('afterEvent');
    final user = buildUser(
      name: 'Suvrat Garg',
      profilePrompts: [
        profilePromptAnswerFor(
          definition: profilePromptDefinition(profilePromptPerfectEventId),
          answer: 'Here for the event.',
        ),
        profilePromptAnswerFor(
          definition: usedPrompt,
          answer: 'Post-run coffee.',
        ),
      ],
    );
    await _pumpEditableProfileTab(tester, user, repository);

    final promptEditor = find.byKey(
      const ValueKey('inline-profilePrompt:2-entry-editor'),
    );
    await tester.tap(promptEditor);
    await _pumpProfileSheet(tester);

    await tester.tap(
      find.descendant(of: promptEditor, matching: find.byType(MenuAnchor)),
    );
    await tester.pump();

    expect(
      find.widgetWithText(MenuItemButton, _perfectRunPromptTitle),
      findsNothing,
    );
    expect(find.widgetWithText(MenuItemButton, usedPrompt.title), findsNothing);
    await tester.tap(find.widgetWithText(MenuItemButton, favoriteRoute.title));
    await tester.pump();

    await tester.enterText(
      find.descendant(of: promptEditor, matching: find.byType(EditableText)),
      'Sunday loops with a view.',
    );
    await _tapInlineDone(tester);
    await _pumpProfileSheet(tester);

    final savedPrompts =
        repository.updatedFields?['profilePrompts'] as List<Object?>;
    expect(savedPrompts.map((prompt) => (prompt as Map)['promptId']), [
      profilePromptPerfectEventId,
      'afterEvent',
      'favoriteRoute',
    ]);
  });

  testWidgets(
    'prompt edit keeps the row anchored with CatchField input chrome',
    (tester) async {
      final user = buildUser(name: 'Suvrat Garg');
      await _pumpProfileTab(tester, user);

      final promptTile = _profileInfoTile(_perfectRunPromptTitle);
      final collapsedTileTop = tester.getTopLeft(promptTile).dy;
      final collapsedTileHeight = tester.getSize(promptTile).height;

      await tester.tap(promptTile);
      await tester.pump();
      await pumpFeatureUiFor(tester, const Duration(milliseconds: 80));

      expect(tester.getTopLeft(promptTile).dy, closeTo(collapsedTileTop, 0.1));
      expect(
        tester.getSize(promptTile).height,
        greaterThan(collapsedTileHeight),
      );

      await _pumpProfileSheet(tester);

      final promptFields = tester.widgetList<CatchField>(
        find.descendant(
          of: find.byType(ProfileInlineTextValue),
          matching: find.byType(CatchField),
        ),
      );
      final promptInput = promptFields.singleWhere(
        (field) =>
            field.variant == CatchFieldVariant.underline &&
            field.size == CatchFieldSize.floating &&
            !field.showLabel,
      );

      expect(tester.getTopLeft(promptTile).dy, closeTo(collapsedTileTop, 0.1));
      expect(promptInput.variant, CatchFieldVariant.underline);
      expect(promptInput.size, CatchFieldSize.floating);
      expect(promptInput.showLabel, isFalse);
    },
  );

  testWidgets('inline email edit uses the email keyboard', (tester) async {
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpProfileTab(tester, user);

    final emailTile = _profileInfoTile('Email');
    await _dragProfileTabUntilVisible(tester, emailTile);
    await tester.tap(emailTile);
    await _pumpProfileSheet(tester);

    final field = tester.widget<CatchField>(_profileInfoTile('Email'));
    expect(field.keyboardType, TextInputType.emailAddress);
    expect(field.autofillHints, contains(AutofillHints.email));
  });

  testWidgets('inline email edit keeps row geometry stable and actions close', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final emailTile = _profileInfoTile('Email');
    await _dragProfileTabUntilVisible(tester, emailTile);
    final collapsedTileHeight = tester.getSize(emailTile).height;

    await tester.tap(emailTile);
    await tester.enterText(
      _editableTextForProfileField('Email'),
      'hi@catch.app',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpProfileSheet(tester);

    final expandedTileHeight = tester.getSize(emailTile).height;

    expect(repository.updatedFields, {'email': 'hi@catch.app'});
    expect(expandedTileHeight, closeTo(collapsedTileHeight, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('height inline edit uses bounded plus-minus controls', (
    tester,
  ) async {
    final user = buildUser(name: 'Suvrat Garg').copyWith(height: 172);
    await _pumpProfileTab(tester, user);

    final heightTile = _profileInfoTile('Height');
    await _dragProfileTabUntilVisible(tester, heightTile);
    await tester.tap(heightTile);
    await _pumpProfileSheet(tester);

    expect(find.text('172 cm'), findsOneWidget);
    expect(find.text('120-220 cm'), findsNothing);
    expect(find.byTooltip('Decrease height'), findsOneWidget);
    expect(find.byTooltip('Increase height'), findsOneWidget);
    expect(find.widgetWithText(CatchButton, 'Done'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase height'));
    await tester.pump();

    expect(find.text('172 cm'), findsNothing);
    expect(find.text('173 cm'), findsOneWidget);

    await _tapInlineDone(tester);
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
    await _tapInlineDone(tester);
    await tester.pump();

    expect(repository.updatedFields, {'height': 173});
    expect(find.byTooltip('Increase height'), findsOneWidget);
    expect(_loadingCatchButtonCount(tester), 1);

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

    final promptTile = _profileInfoTile(_perfectRunPromptTitle);
    await tester.tap(promptTile);
    await _pumpProfileSheet(tester);
    await tester.enterText(_inlinePromptEditableText(), 'Updated bio');
    await _tapInlineDone(tester);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields?['profilePrompts'], [
      containsPair('answer', 'Updated bio'),
    ]);
    expect(_inlinePromptEditableText(), findsOneWidget);
    expect(find.byType(CatchErrorBanner), findsOneWidget);
    expect(find.textContaining('Save failed'), findsOneWidget);
  });

  testWidgets('prompt edit limits input to the callable length limit', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final promptTile = _profileInfoTile(_perfectRunPromptTitle);
    await tester.tap(promptTile);
    await _pumpProfileSheet(tester);
    await tester.enterText(
      _inlinePromptEditableText(),
      'a' * (maximumProfilePromptAnswerLength + 1),
    );
    await tester.pump();
    final editableText = tester.widget<EditableText>(
      _inlinePromptEditableText(),
    );

    expect(
      editableText.controller.text.length,
      maximumProfilePromptAnswerLength,
    );
    final counter = find.text(
      '$maximumProfilePromptAnswerLength / $maximumProfilePromptAnswerLength',
    );
    expect(counter, findsOneWidget);

    await _tapInlineDone(tester);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields?['profilePrompts'], [
      containsPair('answer', 'a' * maximumProfilePromptAnswerLength),
    ]);
    expect(
      find.text(
        'Prompt must be $maximumProfilePromptAnswerLength characters or fewer',
      ),
      findsNothing,
    );
    expect(_inlinePromptEditableText(), findsNothing);
  });

  testWidgets('prompt edit collapses repeated empty lines while typing', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final promptTile = _profileInfoTile(_perfectRunPromptTitle);
    await tester.tap(promptTile);
    await _pumpProfileSheet(tester);
    await tester.enterText(
      _inlinePromptEditableText(),
      'first\n\n\nsecond\n \n \nthird',
    );
    await tester.pump();

    final editableText = tester.widget<EditableText>(
      _inlinePromptEditableText(),
    );
    expect(editableText.controller.text, 'first\n\nsecond\n\nthird');

    await _tapInlineDone(tester);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields?['profilePrompts'], [
      containsPair('answer', 'first\n\nsecond\n\nthird'),
    ]);
  });

  testWidgets('text edit waits for save before closing', (tester) async {
    final repository = FakeProfileEditUserProfileRepository()
      ..updateCompleter = Completer<void>();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final promptTile = _profileInfoTile(_perfectRunPromptTitle);
    await tester.tap(promptTile);
    await _pumpProfileSheet(tester);
    await tester.enterText(_inlinePromptEditableText(), 'Updated bio');
    await _tapInlineDone(tester);
    await tester.pump();

    expect(repository.updatedFields?['profilePrompts'], [
      containsPair('answer', 'Updated bio'),
    ]);
    expect(_inlinePromptEditableText(), findsOneWidget);
    expect(_loadingCatchButtonCount(tester), 1);

    repository.updateCompleter!.complete();
    await _pumpProfileSheet(tester);

    expect(_inlinePromptEditableText(), findsNothing);
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

        await _tapInlineCancel(tester);
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
    await _dragProfileTabUntilTappable(tester, childrenTile);
    await tester.tap(childrenTile);
    await _pumpProfileSheet(tester);

    expect(find.text('Children'), findsOneWidget);
    expect(_catchChip(ChildrenStatus.dontHave.label), findsOneWidget);
  });

  testWidgets('ProfileSingleEnumEntry renders through the inline editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      _profileWidgetHarness(
        ProfileSingleEnumEntry<EducationLevel>(
          icon: CatchIcons.schoolOutlined,
          label: 'Education',
          values: EducationLevel.values,
          value: EducationLevel.masters,
          fieldName: 'education',
          patchForValue: (value) => UpdateUserProfilePatch(education: value),
          isExpanded: false,
          onTap: () {},
          onSaved: () {},
          onCancel: () {},
        ),
      ),
    );

    expect(find.byType(ProfileSingleEnumEntry<EducationLevel>), findsOneWidget);
    expect(
      find.byType(ProfileInlineSingleChoiceEntryEditor<EducationLevel>),
      findsOneWidget,
    );
    expect(find.text('Education'), findsOneWidget);
    expect(find.text(EducationLevel.masters.label), findsOneWidget);
  });

  testWidgets('ProfileMultiEnumEntry renders through the inline editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      _profileWidgetHarness(
        ProfileMultiEnumEntry<Language>(
          icon: CatchIcons.languageOutlined,
          label: 'Languages',
          values: Language.values,
          selected: const [Language.english, Language.hindi],
          fieldName: 'languages',
          placeholder: 'Languages',
          patchForValues: (values) => UpdateUserProfilePatch(languages: values),
          isExpanded: false,
          onTap: () {},
          onSaved: () {},
          onCancel: () {},
        ),
      ),
    );

    expect(find.byType(ProfileMultiEnumEntry<Language>), findsOneWidget);
    expect(
      find.byType(ProfileInlineMultiChoiceEntryEditor<Language>),
      findsOneWidget,
    );
    expect(find.text('Languages'), findsOneWidget);
    expect(find.text('English, Hindi'), findsOneWidget);
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

    await _tapInlineDone(tester);
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

    expect(find.text('+ Education'), findsWidgets);
    expect(_catchChip(EducationLevel.highSchool.label), findsOneWidget);
    expect(
      tester
          .widget<CatchChip>(_catchChip(EducationLevel.highSchool.label))
          .active,
      isFalse,
    );

    await _tapInlineDone(tester);
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
    expect(find.text('+ Looking for'), findsWidgets);
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
    expect((selectedLanguageChip.icon! as Icon).icon, CatchIcons.checkRounded);

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

    await _tapInlineDone(tester);
    await tester.pump();

    expect(repository.updatedFields, {
      'education': EducationLevel.values.first.name,
    });
    expect(_loadingCatchButtonCount(tester), 1);
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
      await _tapInlineDone(tester);
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
      await _tapInlineDone(tester);
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
    await _tapInlineDone(tester);
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

    final paceTile = _profileInfoTile('Pace range');
    await _dragProfileTabUntilTappable(tester, paceTile);
    await tester.tap(paceTile);
    await _pumpProfileSheet(tester);

    tester.widget<RangeSlider>(find.byType(RangeSlider)).onChanged!(
      const RangeValues(310, 370),
    );
    await tester.pump();
    await _tapInlineDone(tester);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {
      'activityPreferences': {
        'running': {
          'paceMinSecsPerKm': 310,
          'paceMaxSecsPerKm': 370,
          'preferredDistances': <String>[],
          'runningReasons': <String>[],
          'preferredRunTimes': <String>[],
          'version': 1,
        },
      },
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
    _controller = TabController(length: 3, vsync: this);
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

class _ProfileUploadFailureSeeder extends ConsumerStatefulWidget {
  const _ProfileUploadFailureSeeder();

  @override
  ConsumerState<_ProfileUploadFailureSeeder> createState() =>
      _ProfileUploadFailureSeederState();
}

class _ProfileUploadFailureSeederState
    extends ConsumerState<_ProfileUploadFailureSeeder> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      PhotoUploadController.uploadPhotoMutation.reset(ref);
      unawaited(
        PhotoUploadController.uploadPhotoMutation
            .run(ref, (tx) async {
              await tx
                  .get(photoUploadControllerProvider.notifier)
                  .pickAndUpload(1);
            })
            .catchError((_) {}),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const ProfileScreen();
}

class _FailingProfileImageUploadRepository extends Fake
    implements ImageUploadRepository {
  @override
  Future<XFile?> pickImage({
    ImageUploadPurpose purpose = ImageUploadPurpose.profilePhoto,
    int? imageQuality,
  }) async {
    return XFile('picked-profile-photo.jpg');
  }

  @override
  Future<UploadedImage> uploadUserProfilePhoto({
    required String uid,
    required int index,
    required XFile image,
  }) async {
    throw obviousOfflineException();
  }
}

class FakeProfileEditUserProfileRepository extends Fake
    implements UserProfileRepository {
  Completer<void>? updateCompleter;
  Object? updateError;
  UserProfile? latestProfile;
  String? updatedUid;
  Map<String, dynamic>? updatedFields;

  @override
  Future<UserProfile?> fetchUserProfile({required String? uid}) async =>
      latestProfile;

  @override
  Future<void> updateUserProfile({
    required String uid,
    required UpdateUserProfilePatch patch,
    String action = 'update_profile',
  }) async {
    updatedUid = uid;
    updatedFields = Map<String, dynamic>.from(patch.toFieldsJson());
    final error = updateError;
    if (error != null) throw error;
    final completer = updateCompleter;
    if (completer != null) await completer.future;
  }
}

class _SilentErrorLogger extends ErrorLogger {
  _SilentErrorLogger() : super(crashReporter: null, shouldReportErrors: false);

  @override
  void log({
    required LogLevel level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, String>? context,
  }) {}
}
