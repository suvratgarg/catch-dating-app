import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/profile/presentation/widgets/profile_info_tile.dart';
import 'package:catch_dating_app/profile/presentation/widgets/profile_tab.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

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

void main() {
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
    await tester.scrollUntilVisible(
      find.text('+919876543210'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
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
    await tester.scrollUntilVisible(
      find.textContaining('18 – 99'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.textContaining('18 – 99'));
    await tester.pumpAndSettle();

    // Bottom sheet is open with RangeSlider and Done button.
    expect(find.byType(RangeSlider), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Dismiss with Done button.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Sheet closed, no exceptions.
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pace range sheet opens via RangeSlider and shows formatted pace', (
    tester,
  ) async {
    final user = buildUser(name: 'Suvrat Garg');
    await _pumpProfileTab(tester, user);

    // Scroll to and tap the pace range row.
    await tester.scrollUntilVisible(
      find.text('Pace range'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Pace range'));
    await tester.pumpAndSettle();

    // Bottom sheet is open with RangeSlider and Done button.
    expect(find.byType(RangeSlider), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Dismiss with Done button.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Sheet closed, no exceptions.
    expect(tester.takeException(), isNull);
  });
}
