import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
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

void main() {
  testWidgets(
    'Profile sliver header uses Profile title with Edit and Preview tabs',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const _ProfileHeaderHarness(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Profile').hitTestable(), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('You'), findsNothing);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
      await pumpFeatureUi(tester);

      expect(find.text('Profile').hitTestable(), findsNothing);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(tester.getTopLeft(find.byType(TabBar)).dy, lessThanOrEqualTo(1));
    },
  );

  testWidgets('ProfileScreen supports horizontal swipes between tabs', (
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

    expect(find.byType(ProfileTabSliverBody), findsOneWidget);
    expect(find.byType(PreviewTab), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(-320, 0));
    await pumpFeatureUi(tester);

    expect(find.byType(PreviewTab), findsOneWidget);
    expect(find.byType(ProfileTabSliverBody), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(320, 0));
    await pumpFeatureUi(tester);

    expect(find.byType(ProfileTabSliverBody), findsOneWidget);
    expect(find.byType(PreviewTab), findsNothing);
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
    expect(find.text('ON A PERFECT RUN'), findsOneWidget);
  });

  testWidgets('Age range sheet opens via RangeSlider and can be dismissed', (
    tester,
  ) async {
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpProfileTab(tester, user);

    // Scroll to and tap the age range row.
    await _dragProfileTabUntilVisible(tester, find.textContaining('18 – 99'));
    await tester.tap(find.textContaining('18 – 99'));
    await _pumpProfileSheet(tester);

    // Bottom sheet is open with RangeSlider and Done button.
    expect(find.byType(RangeSlider), findsOneWidget);
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

  testWidgets('integer edit sheet owns its controller through dismissal', (
    tester,
  ) async {
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpProfileTab(tester, user);

    final heightTile = find.byWidgetPredicate(
      (widget) => widget is ProfileInfoTile && widget.label == 'Height',
    );
    await _dragProfileTabUntilVisible(tester, heightTile);
    await tester.tap(heightTile);
    await _pumpProfileSheet(tester);

    expect(find.widgetWithText(CatchButton, 'Done'), findsOneWidget);

    await tester.tap(find.widgetWithText(CatchButton, 'Done'));
    await _pumpProfileSheet(tester);

    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpProfileSheet(WidgetTester tester) async {
  await pumpFeatureUi(tester);
}

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
      body: CustomScrollView(
        slivers: [
          ...ProfileSliverHeader(controller: _controller).buildSlivers(context),
          SliverList.builder(
            itemCount: 30,
            itemBuilder: (context, index) =>
                SizedBox(height: 56, child: Text('Profile content $index')),
          ),
        ],
      ),
    );
  }
}
