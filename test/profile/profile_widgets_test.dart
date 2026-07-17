import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchFieldTokens, CatchInsets, CatchLayout, CatchMotion, CatchTokens;
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
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

const _obstructedProfileScreenSize = Size(393, 852);
const _profileBottomOverlayInset = 102.0;

Future<void> _pumpObstructedProfileScreen(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = _obstructedProfileScreenSize;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        watchUserProfileProvider.overrideWith(
          (ref) => Stream.value(_profilePreviewScrollFixture()),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const MediaQuery(
          data: MediaQueryData(
            size: _obstructedProfileScreenSize,
            padding: EdgeInsets.only(bottom: 34),
            viewPadding: EdgeInsets.only(bottom: 34),
          ),
          child: AppShellActiveTab(
            index: appShellProfileTabIndex,
            bottomOverlayInset: _profileBottomOverlayInset,
            child: ProfileScreen(),
          ),
        ),
      ),
    ),
  );
  await pumpFeatureUi(tester);
}

Future<ScrollPosition> _positionProfileFieldNearOverlay(
  WidgetTester tester,
  Finder field,
) async {
  await tester.dragUntilVisible(
    field,
    find.byKey(const PageStorageKey('profile-edit-tab-scroll')),
    const Offset(0, -320),
  );
  await tester.pump();

  final position = Scrollable.of(tester.element(field)).position;
  final fieldRect = tester.getRect(field);
  position.jumpTo(
    (position.pixels + fieldRect.bottom - 740)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble(),
  );
  await tester.pump();
  expect(tester.getRect(field).bottom, inInclusiveRange(739, 742.1));
  return position;
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
  await tester.pumpWidget(_editableProfileTab(user, repository));
  await tester.pump();
  await tester.pump();
}

Widget _editableProfileTab(
  UserProfile user,
  FakeProfileEditUserProfileRepository repository,
) {
  return ProviderScope(
    overrides: [
      // Test-only scoped overrides deliberately replace app-root providers.
      // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
      uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
      // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
      errorLoggerProvider.overrideWithValue(_SilentErrorLogger()),
      // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
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
  );
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
      (widget.title == label || widget.body == label) &&
      widget.variant == CatchFieldVariant.row,
);

Finder _editableTextForProfileField(String label) => find.descendant(
  of: _profileInfoTile(label),
  matching: find.byType(EditableText),
);

Finder _inlinePromptEditableText() => find.descendant(
  of: find.byKey(const ValueKey('profile-prompt-answer-0')),
  matching: find.byType(EditableText),
);

Finder _promptQuestionField(int index) =>
    find.byKey(ValueKey('profile-prompt-question-$index'));

Finder _promptAnswerField(int index) =>
    find.byKey(ValueKey('profile-prompt-answer-$index'));

Finder _promptAnswerEditableText(int index) => find.descendant(
  of: _promptAnswerField(index),
  matching: find.byType(EditableText),
);

Finder _profileOptionGroup() => find.byType(CatchOptionGroup<SelfProfileTab>);

Finder _catchChip(String label) => find.byWidgetPredicate(
  (widget) => widget is CatchFieldChoiceChip && widget.label == label,
);

int _loadingCatchButtonCount(WidgetTester tester) => find
    .descendant(
      of: find.byKey(const ValueKey('catch-field-done')),
      matching: find.byKey(const ValueKey('catch-field-spinner')),
    )
    .evaluate()
    .length;

int _promptAnswerSavingCount(int index) => find
    .descendant(
      of: _promptAnswerField(index),
      matching: find.byKey(const ValueKey('catch-field-spinner')),
    )
    .evaluate()
    .length;

Future<void> _blurPromptAnswer(WidgetTester tester, {int index = 0}) async {
  tester
      .widget<EditableText>(_promptAnswerEditableText(index))
      .focusNode
      .unfocus();
  await tester.pump();
}

Future<void> _tapInlineDone(WidgetTester tester) async {
  final doneButton = find.descendant(
    of: find.byKey(const ValueKey('catch-field-done')),
    matching: find.byType(TextButton),
  );
  tester.widget<TextButton>(doneButton).onPressed?.call();
  await tester.pump();
}

Future<void> _tapInlineCancel(WidgetTester tester) async {
  final cancelButton = find.descendant(
    of: find.byKey(const ValueKey('catch-field-cancel')),
    matching: find.byType(TextButton),
  );
  tester.widget<TextButton>(cancelButton).onPressed?.call();
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

  testWidgets('ProfileScreen accepts a typed initial tab', (tester) async {
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
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ProfileScreen(initialTab: SelfProfileTab.insights),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(ProfileInsightsTabSliverBody), findsOneWidget);
    expect(find.byType(ProfileTabSliverBody), findsNothing);
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

  testWidgets('ProfileScreen limits field terminal clearance to Edit', (
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

    Finder activeTabWrapper(PageStorageKey<String> key) => find.ancestor(
      of: find.byKey(key),
      matching: find.byType(ProfileTabScrollView),
    );

    final editWrapper = activeTabWrapper(
      const PageStorageKey<String>('profile-edit-tab-scroll'),
    );
    expect(editWrapper, findsOneWidget);
    expect(
      tester.widget<ProfileTabScrollView>(editWrapper).managesFieldVisibility,
      isTrue,
    );
    expect(
      tester
          .widget<CustomScrollView>(
            find.byKey(const PageStorageKey<String>('profile-edit-tab-scroll')),
          )
          .slivers
          .whereType<CatchSliverTerminalPadding>(),
      hasLength(1),
    );

    await tester.tap(find.text('Preview'));
    await pumpFeatureUi(tester);
    final previewWrapper = activeTabWrapper(
      const PageStorageKey<String>('profile-preview-tab-scroll'),
    );
    expect(previewWrapper, findsOneWidget);
    expect(
      tester
          .widget<ProfileTabScrollView>(previewWrapper)
          .managesFieldVisibility,
      isFalse,
    );
    expect(
      tester
          .widget<CustomScrollView>(
            find.byKey(
              const PageStorageKey<String>('profile-preview-tab-scroll'),
            ),
          )
          .slivers
          .whereType<CatchSliverTerminalPadding>(),
      isEmpty,
    );

    await tester.tap(find.text('Insights'));
    await pumpFeatureUi(tester);
    final insightsWrapper = activeTabWrapper(
      const PageStorageKey<String>('profile-insights-tab-scroll'),
    );
    expect(insightsWrapper, findsOneWidget);
    expect(
      tester
          .widget<ProfileTabScrollView>(insightsWrapper)
          .managesFieldVisibility,
      isFalse,
    );
    expect(
      tester
          .widget<CustomScrollView>(
            find.byKey(
              const PageStorageKey<String>('profile-insights-tab-scroll'),
            ),
          )
          .slivers
          .whereType<CatchSliverTerminalPadding>(),
      isEmpty,
    );
  });

  testWidgets(
    'ProfileScreen reveals expanded Diet actions above floating navigation',
    (tester) async {
      await _pumpObstructedProfileScreen(tester);

      final dietTile = _profileInfoTile('Diet');
      final position = await _positionProfileFieldNearOverlay(tester, dietTile);
      final beforeOpenPixels = position.pixels;
      final beforeOpenTop = tester.getTopLeft(dietTile).dy;

      await tester.tap(dietTile);
      await tester.pump();
      await pumpFeatureUiFor(tester, const Duration(milliseconds: 16));
      await pumpFeatureUiFor(
        tester,
        Duration(
          milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2 - 16,
        ),
      );
      expect(
        position.pixels > beforeOpenPixels ||
            tester.getTopLeft(dietTile).dy < beforeOpenTop,
        isTrue,
      );
      await pumpFeatureUi(tester);

      final doneRect = tester.getRect(
        find.byKey(const ValueKey('catch-field-done')),
      );
      expect(
        doneRect.bottom,
        lessThanOrEqualTo(
          _obstructedProfileScreenSize.height -
              _profileBottomOverlayInset +
              0.1,
        ),
      );
    },
  );

  testWidgets(
    'ProfileScreen terminal clearance reveals final Children actions',
    (tester) async {
      await _pumpObstructedProfileScreen(tester);

      final childrenTile = _profileInfoTile('Children');
      final position = await _positionProfileFieldNearOverlay(
        tester,
        childrenTile,
      );

      await tester.tap(childrenTile);
      await tester.pump();
      final framesBeforeEnd =
          (CatchFieldTokens.reveal.inMilliseconds + 15) ~/ 16 - 1;
      for (var frame = 0; frame < framesBeforeEnd; frame++) {
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 16));
      }
      final offsetBeforeExpansionEnd = position.pixels;
      for (var frame = 0; frame < 2; frame++) {
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 16));
      }
      await tester.pump();
      expect(
        (position.pixels - offsetBeforeExpansionEnd).abs(),
        lessThan(12),
        reason: 'The final extent correction must not create a visible snap.',
      );

      final doneRect = tester.getRect(
        find.byKey(const ValueKey('catch-field-done')),
      );
      expect(
        doneRect.bottom,
        lessThanOrEqualTo(
          _obstructedProfileScreenSize.height -
              _profileBottomOverlayInset +
              0.1,
        ),
      );
    },
  );

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
        'We are having trouble connecting. Please check your internet and try again.',
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

  testWidgets('ProfileTab derives consistent empty editable-row copy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final user = buildUser(email: '').copyWith(phoneNumber: '+919876543210');

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

    await _dragProfileTabUntilVisible(tester, find.text('+919876543210'));
    expect(find.text('+919876543210'), findsOneWidget);

    for (final (label, emptyValue) in [
      ('Email', 'Add email'),
      ('Instagram', 'Add instagram'),
      ('Job title', 'Add job title'),
      ('Company', 'Add company'),
    ]) {
      final tile = _profileInfoTile(label);
      await _dragProfileTabUntilVisible(tester, tile);
      expect(
        find.descendant(of: tile, matching: find.text(emptyValue)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: tile, matching: find.text(label)),
        findsNothing,
      );
      expect(find.text('+ $label'), findsNothing);
    }

    final workoutTile = _profileInfoTile('Workout');
    await _dragProfileTabUntilVisible(tester, workoutTile);
    expect(
      find.descendant(
        of: workoutTile,
        matching: find.textContaining('Add workout', findRichText: true),
      ),
      findsOneWidget,
    );
    expect(find.text('+ Workout'), findsNothing);
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

    final photosSection = find.ancestor(
      of: find.byType(PhotoGrid),
      matching: find.byType(CatchSection),
    );
    final photosRule = find.descendant(
      of: photosSection,
      matching: find.byType(CatchDivider),
    );
    expect(photosRule, findsOneWidget);
    expect(tester.getRect(photosRule).left, tester.getRect(photosSection).left);
    expect(
      tester.getRect(photosRule).right,
      tester.getRect(photosSection).right,
    );
    expect(
      tester.getRect(find.byType(PhotoGrid)).top -
          tester.getRect(photosRule).bottom,
      CatchSpacing.s3,
    );
  });

  testWidgets('Profile photo skeleton preserves the ready header rule rhythm', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _profileWidgetHarness(
        const Padding(
          padding: CatchInsets.content,
          child: ProfilePhotosSkeletonSection(),
        ),
      ),
    );

    final section = find.byType(CatchSection);
    final rule = find.descendant(
      of: section,
      matching: find.byType(CatchDivider),
    );
    final grid = find.byType(GridView);
    expect(rule, findsOneWidget);
    expect(tester.getRect(rule).left, tester.getRect(section).left);
    expect(tester.getRect(rule).right, tester.getRect(section).right);
    expect(
      tester.getRect(grid).top - tester.getRect(rule).bottom,
      CatchSpacing.s3,
    );
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
    final aboutSection = find.ancestor(
      of: displayNameTile,
      matching: find.byType(CatchSection),
    );
    final dividers = find.descendant(
      of: aboutSection,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is CatchDivider && widget.role == CatchDividerRole.fieldRow,
      ),
    );
    expect(dividers, findsWidgets);
    for (final element in dividers.evaluate()) {
      final coloredBox = find.descendant(
        of: find.byElementPredicate((candidate) => candidate == element),
        matching: find.byType(ColoredBox),
      );
      final box = tester.renderObject<RenderBox>(coloredBox);
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
      expect(displayNameTile.showClearButton, isTrue);
      expect(
        find.descendant(
          of: _profileInfoTile('Display name'),
          matching: find.text('S.'),
        ),
        findsWidgets,
      );
      expect(find.text('Name'), findsNothing);
      expect(dobTile.mode, CatchFieldMode.read);
      expect(dobTile.onTap, isNull);
      expect(genderTile.mode, CatchFieldMode.read);
      expect(genderTile.onTap, isNull);
      expect(
        find.descendant(
          of: _profileInfoTile('Display name'),
          matching: find.byIcon(CatchIcons.expandMoreRounded),
        ),
        findsNothing,
      );
      for (final label in ['Date of birth', 'Gender']) {
        expect(
          find.descendant(
            of: _profileInfoTile(label),
            matching: find.byIcon(CatchIcons.chevronRightRounded),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: _profileInfoTile(label),
            matching: find.byIcon(CatchIcons.expandMoreRounded),
          ),
          findsNothing,
        );
      }
      expect(_profileInfoTile(_perfectRunPromptTitle), findsOneWidget);

      final instagramTile = tester.widget<CatchField>(
        _profileInfoTile('Instagram'),
      );
      expect(instagramTile.mode, CatchFieldMode.edit);
      expect(instagramTile.enabled, isTrue);
      expect(instagramTile.leadingUnit, '@');
      expect(instagramTile.showClearButton, isTrue);
      expect(find.text('@'), findsOneWidget);
      expect(find.text('suvrat_events'), findsOneWidget);
      expect(
        find.descendant(
          of: _profileInfoTile('Instagram'),
          matching: find.byIcon(CatchIcons.clearCircle),
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(_profileInfoTile('Display name')).height,
        closeTo(tester.getSize(_profileInfoTile('Date of birth')).height, 0.1),
      );
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

  testWidgets('direct text Saved state survives an equal profile refresh', (
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
    await tester.enterText(_editableTextForProfileField('Display name'), 'S.');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpProfileSheet(tester);

    Finder savedStatus() => find.descendant(
      of: displayNameTile,
      matching: find.byKey(const ValueKey('catch-field-saved')),
    );
    expect(savedStatus(), findsOneWidget);

    final refreshed = user.copyWith(displayName: 'S.');
    repository.latestProfile = refreshed;
    await tester.pumpWidget(_editableProfileTab(refreshed, repository));
    await tester.pump();

    expect(savedStatus(), findsOneWidget);
  });

  testWidgets('profile inline drawers animate open and closed', (tester) async {
    final user = buildUser(name: 'Suvrat Garg').copyWith(height: 172);
    await _pumpProfileTab(tester, user);

    final heightTile = _profileInfoTile('Height');
    await _dragProfileTabUntilVisible(tester, heightTile);
    final collapsedTop = tester.getTopLeft(heightTile).dy;
    final collapsedHeight = tester.getSize(heightTile).height;
    await tester.tap(heightTile);
    await tester.pump();
    await pumpFeatureUiFor(
      tester,
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    final openingHeight = tester.getSize(heightTile).height;
    expect(openingHeight, greaterThan(collapsedHeight));
    expect(tester.getTopLeft(heightTile).dy, closeTo(collapsedTop, 0.1));

    await pumpFeatureUiFor(
      tester,
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    final expandedHeight = tester.getSize(heightTile).height;
    expect(openingHeight, lessThan(expandedHeight));

    expect(find.byTooltip('Increase height'), findsOneWidget);
    expect(find.byKey(const ValueKey('catch-field-done')), findsOneWidget);
    expect(
      find.descendant(
        of: heightTile,
        matching: find.textContaining('Optional'),
      ),
      findsNothing,
    );
    expect(find.text('Cancel'), findsOneWidget);

    await _tapInlineCancel(tester);
    await pumpFeatureUiFor(
      tester,
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    final closingHeight = tester.getSize(heightTile).height;
    expect(closingHeight, greaterThan(collapsedHeight));
    expect(closingHeight, lessThan(expandedHeight));

    await pumpFeatureUiFor(
      tester,
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );

    expect(find.byTooltip('Increase height'), findsNothing);
    expect(tester.getSize(heightTile).height, closeTo(collapsedHeight, 0.1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('choice tiles keep their controls through the close animation', (
    tester,
  ) async {
    var open = true;

    await tester.pumpWidget(
      _profileWidgetHarness(
        StatefulBuilder(
          builder: (context, setState) => ProfileMultiEnumEntry<Language>(
            icon: CatchIcons.languageOutlined,
            label: 'Languages',
            values: Language.values,
            selected: const [Language.english, Language.hindi],
            fieldName: 'languages',
            patchForValues: (values) =>
                UpdateUserProfilePatch(languages: values),
            isExpanded: open,
            onTap: () => setState(() => open = !open),
            onSaved: () => setState(() => open = false),
            onCancel: () => setState(() => open = false),
          ),
        ),
      ),
    );

    expect(_catchChip(Language.english.label), findsOneWidget);
    await _tapInlineCancel(tester);
    await pumpFeatureUiFor(
      tester,
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );

    expect(_catchChip(Language.english.label), findsOneWidget);

    await pumpFeatureUiFor(
      tester,
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    expect(_catchChip(Language.english.label), findsNothing);
  });

  testWidgets('equal profile refresh preserves a multi-choice draft', (
    tester,
  ) async {
    late StateSetter rebuild;
    var selected = <Language>[Language.english];

    await tester.pumpWidget(
      _profileWidgetHarness(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return ProfileMultiEnumEntry<Language>(
              icon: CatchIcons.languageOutlined,
              label: 'Languages',
              values: Language.values,
              selected: List<Language>.of(selected),
              fieldName: 'languages',
              patchForValues: (values) =>
                  UpdateUserProfilePatch(languages: values),
              isExpanded: true,
              onTap: () {},
              onSaved: () {},
              onCancel: () {},
            );
          },
        ),
      ),
    );

    await tester.tap(_catchChip(Language.hindi.label));
    await _pumpProfileSheet(tester);
    expect(
      tester
          .widget<CatchFieldChoiceChip>(_catchChip(Language.hindi.label))
          .selected,
      isTrue,
    );

    rebuild(() => selected = <Language>[Language.english]);
    await _pumpProfileSheet(tester);

    expect(
      tester
          .widget<CatchFieldChoiceChip>(_catchChip(Language.hindi.label))
          .selected,
      isTrue,
    );
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

  testWidgets('prompt card separates explicit question and blur-save answer', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    final card = find.byKey(const ValueKey('profile-prompt-card-0'));
    final question = _promptQuestionField(0);
    final answer = _promptAnswerField(0);
    expect(card, findsOneWidget);
    expect(
      find.descendant(of: card, matching: find.byType(CatchField)),
      findsNWidgets(2),
    );

    final collapsedQuestion = tester.widget<CatchField>(question);
    expect(collapsedQuestion.title, 'Prompt 1');
    expect(collapsedQuestion.body, _perfectRunPromptTitle);
    expect(collapsedQuestion.open, isFalse);

    final answerField = tester.widget<CatchField>(answer);
    expect(answerField.title, 'Answer');
    expect(answerField.variant, CatchFieldVariant.row);
    expect(answerField.keyboardType, TextInputType.multiline);
    expect(answerField.textInputAction, TextInputAction.newline);
    expect(answerField.maxLines, isNull);
    expect(answerField.minLines, 1);
    expect(answerField.maxLength, maximumProfilePromptAnswerLength);
    expect(answerField.inputFormatters, hasLength(1));
    expect(_promptAnswerEditableText(0), findsOneWidget);
    expect(
      find.descendant(of: question, matching: find.byType(TextField)),
      findsNothing,
    );

    await tester.tap(question);
    await _pumpProfileSheet(tester);

    expect(tester.widget<CatchField>(question).open, isTrue);
    expect(find.byKey(const ValueKey('catch-field-cancel')), findsOneWidget);
    expect(find.byKey(const ValueKey('catch-field-done')), findsOneWidget);
    expect(_catchChip(_perfectRunPromptTitle), findsOneWidget);
    expect(_promptAnswerEditableText(0), findsOneWidget);

    BoxDecoration promptSurfaceDecoration() {
      final surface = tester.widget<AnimatedContainer>(
        find
            .descendant(of: card, matching: find.byType(AnimatedContainer))
            .first,
      );
      return surface.foregroundDecoration! as BoxDecoration;
    }

    int highlightedPromptFields() => tester
        .widgetList<AnimatedContainer>(
          find.descendant(
            of: card,
            matching: find.byKey(const ValueKey('catch-field-active-overlay')),
          ),
        )
        .where(
          (overlay) => (overlay.decoration! as BoxDecoration).border != null,
        )
        .length;

    Rect highlightedPromptFieldRect() {
      final overlays = find.descendant(
        of: card,
        matching: find.byKey(
          const ValueKey<String>('catch-field-active-overlay'),
        ),
      );
      final activeIndex =
          List.generate(
            overlays.evaluate().length,
            (index) => index,
          ).singleWhere((index) {
            final overlay = tester.widget<AnimatedContainer>(
              overlays.at(index),
            );
            return (overlay.decoration! as BoxDecoration).border != null;
          });
      return tester.getRect(overlays.at(activeIndex));
    }

    Rect promptSurfaceRect() => tester.getRect(
      find.descendant(
        of: card,
        matching: find.byType(CatchSectionFocusSurface),
      ),
    );

    void expectPromptEdgesShareGeometry() {
      final surfaceRect = promptSurfaceRect();
      final fieldRect = highlightedPromptFieldRect();
      expect(fieldRect.left, closeTo(surfaceRect.left, 0.1));
      expect(fieldRect.right, closeTo(surfaceRect.right, 0.1));
    }

    expect(
      promptSurfaceDecoration().border,
      Border.all(color: CatchTokens.editorialLight.line2),
    );
    expect(highlightedPromptFields(), 1);
    expectPromptEdgesShareGeometry();

    await tester.tap(_promptAnswerEditableText(0));
    await _pumpProfileSheet(tester);
    expect(tester.widget<CatchField>(question).open, isFalse);
    expect(
      promptSurfaceDecoration().border,
      Border.all(color: CatchTokens.editorialLight.line2),
    );
    expect(highlightedPromptFields(), 1);
    expectPromptEdgesShareGeometry();
    expect(find.byKey(const ValueKey('catch-field-cancel')), findsNothing);
    expect(find.byKey(const ValueKey('catch-field-done')), findsNothing);
    expect(_promptAnswerEditableText(0), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('prompt answer trims and saves implicitly when focus leaves', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    await tester.enterText(_inlinePromptEditableText(), ' Updated bio ');
    expect(find.byKey(const ValueKey('catch-field-done')), findsNothing);

    await _blurPromptAnswer(tester);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields?['profilePrompts'], [
      containsPair('answer', 'Updated bio'),
    ]);
    expect(
      tester
          .widget<EditableText>(_inlinePromptEditableText())
          .focusNode
          .hasFocus,
      isFalse,
    );
    expect(find.byKey(const ValueKey('catch-field-saved')), findsOneWidget);
  });

  testWidgets(
    'prompt answer blur preserves a question selection until explicit Done',
    (tester) async {
      final repository = FakeProfileEditUserProfileRepository();
      final user = buildUser(name: 'Suvrat Garg');
      final originalPromptId = user.profilePrompts.first.promptId;
      final alternatePrompt = profilePromptDefinition('favoriteRoute');
      await _pumpEditableProfileTab(tester, user, repository);

      await tester.tap(_promptQuestionField(0));
      await _pumpProfileSheet(tester);
      await tester.tap(_catchChip(alternatePrompt.title));
      await tester.pump();
      expect(
        tester.widget<CatchField>(_promptQuestionField(0)).body,
        alternatePrompt.title,
      );

      await tester.enterText(
        _promptAnswerEditableText(0),
        'Answer saved against the committed question.',
      );
      await _blurPromptAnswer(tester);
      await _pumpProfileSheet(tester);

      final savedPrompts =
          repository.updatedFields?['profilePrompts'] as List<Object?>;
      expect((savedPrompts.single as Map)['promptId'], originalPromptId);
      expect(
        (savedPrompts.single as Map)['answer'],
        'Answer saved against the committed question.',
      );
      expect(
        tester.widget<CatchField>(_promptQuestionField(0)).body,
        alternatePrompt.title,
      );
    },
  );

  testWidgets('prompt Done and answer blur serialize without dropping either', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository()
      ..updateCompleter = Completer<void>();
    final user = buildUser(name: 'Suvrat Garg');
    final originalAnswer = user.profilePrompts.first.answer;
    final alternatePrompt = profilePromptDefinition('favoriteRoute');
    const updatedAnswer = 'The answer that blurred while Done was saving.';
    await _pumpEditableProfileTab(tester, user, repository);

    await tester.tap(_promptQuestionField(0));
    await _pumpProfileSheet(tester);
    await tester.tap(_catchChip(alternatePrompt.title));
    await tester.pump();
    await tester.enterText(_promptAnswerEditableText(0), updatedAnswer);

    final doneButton = tester.widget<TextButton>(
      find.descendant(
        of: find.byKey(const ValueKey('catch-field-done')),
        matching: find.byType(TextButton),
      ),
    );
    doneButton.onPressed!.call();
    tester
        .widget<EditableText>(_promptAnswerEditableText(0))
        .focusNode
        .unfocus();
    await tester.pump();

    expect(repository.updateHistory, hasLength(1));
    final questionSave =
        repository.updateHistory.single['profilePrompts'] as List<Object?>;
    expect((questionSave.single as Map)['promptId'], alternatePrompt.id);
    expect((questionSave.single as Map)['answer'], originalAnswer);

    repository.updateCompleter!.complete();
    await _pumpProfileSheet(tester);

    expect(repository.updateHistory, hasLength(2));
    final answerSave =
        repository.updateHistory.last['profilePrompts'] as List<Object?>;
    expect((answerSave.single as Map)['promptId'], alternatePrompt.id);
    expect((answerSave.single as Map)['answer'], updatedAnswer);
    expect(repository.updatedFields, repository.updateHistory.last);
  });

  testWidgets(
    'profile prompt cards remain capped at the three-prompt contract',
    (tester) async {
      final prompts = [
        for (final promptId in defaultProfilePromptIds.take(
          maxProfilePromptAnswers,
        ))
          profilePromptAnswerFor(
            definition: profilePromptDefinition(promptId),
            answer: 'Answer for $promptId',
          ),
      ];
      await _pumpProfileTab(
        tester,
        buildUser(name: 'Suvrat Garg', profilePrompts: prompts),
      );

      expect(
        find.byType(ProfileInlinePromptEntryEditor),
        findsNWidgets(maxProfilePromptAnswers),
      );
      for (var index = 0; index < maxProfilePromptAnswers; index++) {
        expect(
          find.byKey(ValueKey('profile-prompt-card-$index')),
          findsOneWidget,
        );
      }
      expect(
        find.byKey(const ValueKey('inline-profilePrompt-3-entry-editor')),
        findsNothing,
      );
    },
  );

  testWidgets('inline prompt choices exclude questions used by other cards', (
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
      const ValueKey('inline-profilePrompt-2-entry-editor'),
    );
    await _dragProfileTabUntilVisible(tester, promptEditor);
    tester.widget<ProfileInlinePromptEntryEditor>(promptEditor).onTap();
    await tester.pump();
    await _pumpProfileSheet(tester);
    expect(tester.widget<CatchField>(_promptQuestionField(2)).open, isTrue);
    expect(_catchChip(_perfectRunPromptTitle), findsNothing);
    expect(_catchChip(usedPrompt.title), findsNothing);
    expect(_catchChip(favoriteRoute.title), findsOneWidget);

    await tester.tap(_catchChip(favoriteRoute.title));
    await _pumpProfileSheet(tester);

    expect(
      tester.widget<CatchField>(_promptQuestionField(2)).body,
      favoriteRoute.title,
    );
    expect(repository.updatedFields, isNull);

    tester
        .widget<EditableText>(_promptAnswerEditableText(2))
        .focusNode
        .requestFocus();
    await tester.pump();
    await tester.enterText(
      _promptAnswerEditableText(2),
      'Sunday loops with a view.',
    );
    await _blurPromptAnswer(tester, index: 2);
    await _pumpProfileSheet(tester);

    expect(repository.updateHistory, isEmpty);
    expect(find.byKey(const ValueKey('catch-field-done')), findsOneWidget);

    await _tapInlineDone(tester);
    await _pumpProfileSheet(tester);

    expect(promptEditor, findsOneWidget);
    expect(find.byKey(const ValueKey('profile-prompt-card-2')), findsOneWidget);
    expect(_promptAnswerField(2), findsOneWidget);
    expect(repository.updateHistory, hasLength(1));

    final savedPrompts =
        repository.updatedFields?['profilePrompts'] as List<Object?>;
    expect(savedPrompts.map((prompt) => (prompt as Map)['promptId']), [
      profilePromptPerfectEventId,
      'afterEvent',
      'favoriteRoute',
    ]);
    expect((savedPrompts.last as Map)['answer'], 'Sunday loops with a view.');
    expect(find.byKey(const ValueKey('profile-prompt-add-3')), findsNothing);
  });

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

    expect(tester.widget<CatchField>(heightTile).isOptional, isFalse);
    expect(find.text('172 cm'), findsNWidgets(2));
    expect(find.text('120-220 cm'), findsNothing);
    expect(find.byTooltip('Decrease height'), findsOneWidget);
    expect(find.byTooltip('Increase height'), findsOneWidget);
    expect(find.byKey(const ValueKey('catch-field-done')), findsOneWidget);

    await tester.tap(find.byTooltip('Increase height'));
    await tester.pump();

    expect(find.text('172 cm'), findsNothing);
    expect(find.text('173 cm'), findsNWidgets(2));

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
    expect(find.byType(CatchFieldSpinner), findsOneWidget);

    repository.updateCompleter!.complete();
    await _pumpProfileSheet(tester);

    expect(find.byTooltip('Increase height'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('prompt answer save failure stays inline with field error', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository()
      ..updateError = StateError('Save failed');
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    await tester.enterText(_inlinePromptEditableText(), 'Updated bio');
    await _blurPromptAnswer(tester);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields?['profilePrompts'], [
      containsPair('answer', 'Updated bio'),
    ]);
    expect(_inlinePromptEditableText(), findsOneWidget);
    expect(tester.widget<CatchField>(_promptAnswerField(0)).error, isNotNull);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('prompt edit limits input to the callable length limit', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

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
    final answerBottom = tester.getBottomLeft(_inlinePromptEditableText()).dy;
    final counterTop = tester.getTopLeft(counter).dy;
    expect(answerBottom, lessThan(counterTop));
    expect(find.byKey(const ValueKey('catch-field-cancel')), findsNothing);
    expect(find.byKey(const ValueKey('catch-field-done')), findsNothing);

    await _blurPromptAnswer(tester);
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
  });

  testWidgets('prompt edit collapses repeated empty lines while typing', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    await tester.enterText(
      _inlinePromptEditableText(),
      'first\n\n\nsecond\n \n \nthird',
    );
    await tester.pump();

    final editableText = tester.widget<EditableText>(
      _inlinePromptEditableText(),
    );
    expect(editableText.controller.text, 'first\n\nsecond\n\nthird');

    await _blurPromptAnswer(tester);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields?['profilePrompts'], [
      containsPair('answer', 'first\n\nsecond\n\nthird'),
    ]);
  });

  testWidgets('prompt answer shows saving then saved status after blur', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository()
      ..updateCompleter = Completer<void>();
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpEditableProfileTab(tester, user, repository);

    await tester.enterText(_inlinePromptEditableText(), 'Updated bio');
    await _blurPromptAnswer(tester);

    expect(repository.updatedFields?['profilePrompts'], [
      containsPair('answer', 'Updated bio'),
    ]);
    expect(_inlinePromptEditableText(), findsOneWidget);
    expect(_promptAnswerSavingCount(0), 1);
    expect(tester.widget<CatchField>(_promptAnswerField(0)).readOnly, isTrue);

    repository.updateCompleter!.complete();
    await _pumpProfileSheet(tester);

    expect(_promptAnswerSavingCount(0), 0);
    expect(find.byKey(const ValueKey('catch-field-saved')), findsOneWidget);
    expect(tester.widget<CatchField>(_promptAnswerField(0)).readOnly, isFalse);
    expect(
      tester
          .widget<EditableText>(_inlinePromptEditableText())
          .focusNode
          .hasFocus,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'clearable single-choice inline editors open with no selected chip',
    (tester) async {
      final repository = FakeProfileEditUserProfileRepository();
      final user = buildUser(name: 'Suvrat Garg');
      await _pumpEditableProfileTab(tester, user, repository);

      for (final field in _nullableSingleChoiceFields) {
        final tile = _profileInfoTile(field.tileLabel);
        await _dragProfileTabUntilVisible(tester, tile);
        await tester.tap(tile);
        await _pumpProfileSheet(tester);

        final firstChip = tester.widget<CatchFieldChoiceChip>(
          _catchChip(field.firstLabel),
        );
        expect(firstChip.selected, isFalse, reason: field.tileLabel);

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

    final neverChip = tester.widget<CatchFieldChoiceChip>(
      _catchChip(DrinkingHabit.never.label),
    );
    expect(neverChip.selected, isFalse);
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
    expect(find.text('English · Hindi'), findsOneWidget);
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
          .widget<CatchFieldChoiceChip>(
            _catchChip(EducationLevel.values.first.label),
          )
          .selected,
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

    expect(
      find.descendant(
        of: educationTile,
        matching: find.textContaining('Optional'),
      ),
      findsNothing,
    );
    expect(_catchChip(EducationLevel.highSchool.label), findsOneWidget);
    expect(
      tester
          .widget<CatchFieldChoiceChip>(
            _catchChip(EducationLevel.highSchool.label),
          )
          .selected,
      isTrue,
    );

    await tester.tap(_catchChip(EducationLevel.highSchool.label));
    await _pumpProfileSheet(tester);

    expect(find.text('Add education'), findsWidgets);
    expect(_catchChip(EducationLevel.highSchool.label), findsOneWidget);
    expect(
      tester
          .widget<CatchFieldChoiceChip>(
            _catchChip(EducationLevel.highSchool.label),
          )
          .selected,
      isFalse,
    );

    await _tapInlineDone(tester);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {'education': null});
    expect(_catchChip(EducationLevel.highSchool.label), findsNothing);
  });

  testWidgets('languages can clear the last value without Optional copy', (
    tester,
  ) async {
    final repository = FakeProfileEditUserProfileRepository();
    final user = buildUser(
      name: 'Suvrat Garg',
    ).copyWith(languages: const [Language.english]);
    await _pumpEditableProfileTab(tester, user, repository);

    final languagesTile = _profileInfoTile('Languages');
    await _dragProfileTabUntilVisible(tester, languagesTile);
    await tester.tap(languagesTile);
    await _pumpProfileSheet(tester);

    expect(
      find.descendant(
        of: languagesTile,
        matching: find.textContaining('Optional'),
      ),
      findsNothing,
    );
    await tester.tap(_catchChip(Language.english.label));
    await _pumpProfileSheet(tester);
    expect(
      tester
          .widget<CatchFieldChoiceChip>(_catchChip(Language.english.label))
          .selected,
      isFalse,
    );

    await _tapInlineDone(tester);
    await _pumpProfileSheet(tester);

    expect(repository.updatedFields, {'languages': <String>[]});
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
    expect(find.text('Add looking for'), findsWidgets);
    expect(
      tester
          .widget<CatchFieldChoiceChip>(
            _catchChip(RelationshipGoal.relationship.label),
          )
          .selected,
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
    final selectedLanguageChip = tester.widget<CatchFieldChoiceChip>(
      _catchChip(Language.english.label),
    );
    expect(selectedLanguageChip.selected, isTrue);
    expect(selectedLanguageChip.multi, isTrue);
    expect(
      find.descendant(
        of: _catchChip(Language.english.label),
        matching: find.byIcon(CatchIcons.checkRounded),
      ),
      findsOneWidget,
    );

    await tester.tap(_catchChip(Language.english.label));
    await _pumpProfileSheet(tester);

    expect(_catchChip(Language.english.label), findsOneWidget);
    expect(
      tester
          .widget<CatchFieldChoiceChip>(_catchChip(Language.english.label))
          .selected,
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
    expect(find.byType(CatchFieldSpinner), findsOneWidget);
    expect(
      tester
          .widget<CatchFieldChoiceChip>(
            _catchChip(EducationLevel.values.first.label),
          )
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
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        tester
            .widget<CatchFieldChoiceChip>(
              _catchChip(EducationLevel.values.first.label),
            )
            .selected,
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
            .widget<CatchFieldChoiceChip>(
              _catchChip(EducationLevel.values.first.label),
            )
            .selected,
        isTrue,
      );

      await tester.tap(educationTile);
      await _pumpProfileSheet(tester);

      final drinkingTile = _profileInfoTile('Drinking');
      await _dragProfileTabUntilVisible(tester, drinkingTile);
      await tester.tap(drinkingTile);
      await _pumpProfileSheet(tester);

      expect(
        tester
            .widget<CatchFieldChoiceChip>(_catchChip(DrinkingHabit.never.label))
            .selected,
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
    _controller = TabController(
      length: SelfProfileTab.values.length,
      vsync: this,
    );
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
            ...CatchSliverHeader(
              title: const CatchScreenHeaderTitle.block(
                title: 'Your profile',
                actions: [ProfileSettingsButton()],
              ),
              bottomHeight: CatchLayout.tabRailHeight,
              bottom: ProfileTabBar(controller: _controller),
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
  final List<Map<String, dynamic>> updateHistory = [];

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
    final fields = Map<String, dynamic>.from(patch.toFieldsJson());
    updatedFields = fields;
    updateHistory.add(fields);
    final error = updateError;
    if (error != null) throw error;
    final completer = updateCompleter;
    if (completer != null) await completer.future;

    final promptFields = fields['profilePrompts'];
    if (promptFields case final List<Object?> promptValues) {
      latestProfile = latestProfile?.copyWith(
        profilePrompts: [
          for (final promptValue in promptValues)
            ProfilePromptAnswer.fromJson(
              Map<String, dynamic>.from(promptValue! as Map),
            ),
        ],
      );
    }
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
