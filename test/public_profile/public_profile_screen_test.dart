import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen.dart';
import 'package:catch_dating_app/swipes/presentation/profile_surface.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  testWidgets('PublicProfileScreen renders profile skeleton while loading', (
    tester,
  ) async {
    final controller = StreamController<PublicProfile?>();
    addTearDown(controller.close);

    await _pumpPublicProfile(tester, targetStream: controller.stream);
    await tester.pump();

    expect(find.byType(ProfileSurfaceSkeleton), findsOneWidget);
    expect(find.byType(CatchLoadingIndicator), findsNothing);
  });

  testWidgets(
    'PublicProfileScreen keeps initial profile visible while stream loads',
    (tester) async {
      final controller = StreamController<PublicProfile?>();
      final profile = buildPublicProfile(name: 'Riya');
      addTearDown(controller.close);

      await _pumpPublicProfile(
        tester,
        targetStream: controller.stream,
        initialProfile: profile,
      );
      await tester.pump();

      expect(find.byType(PublicProfileBody), findsOneWidget);
      expect(find.byType(ProfileSurfaceSkeleton), findsNothing);
      expect(find.text('Riya'), findsWidgets);
    },
  );

  testWidgets(
    'PublicProfileScreen shows branded empty state when unavailable',
    (tester) async {
      await _pumpPublicProfile(
        tester,
        targetStream: Stream<PublicProfile?>.value(null),
      );
      await pumpFeatureUi(tester);

      expect(find.byType(CatchEmptyState), findsOneWidget);
      expect(find.text('Profile unavailable'), findsOneWidget);
      expect(
        find.text('This profile is no longer available on Catch.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('PublicProfileScreen shows branded error state on load failure', (
    tester,
  ) async {
    await _pumpPublicProfile(
      tester,
      targetStream: Stream<PublicProfile?>.error(
        StateError('profile stream failed'),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(CatchErrorState), findsOneWidget);
    expect(find.text('Profile unavailable'), findsOneWidget);
    expect(find.text('Reload profile'), findsOneWidget);
  });

  testWidgets('PublicProfileScreen report sheet uses shared action rows', (
    tester,
  ) async {
    final profile = buildPublicProfile(name: 'Riya');
    await _pumpPublicProfile(
      tester,
      targetStream: Stream<PublicProfile?>.value(profile),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.byIcon(CatchIcons.moreHorizRounded));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Report'));
    await pumpFeatureUi(tester);

    expect(find.text('Report Riya'), findsOneWidget);
    expect(find.byType(CatchField), findsNWidgets(4));
    expect(find.text('Harassment or abuse'), findsOneWidget);
  });
}

Future<void> _pumpPublicProfile(
  WidgetTester tester, {
  required Stream<PublicProfile?> targetStream,
  PublicProfile? initialProfile,
}) async {
  final viewer = buildUser(uid: 'viewer-1', name: 'Viewer');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        watchUserProfileProvider.overrideWith((ref) => Stream.value(viewer)),
        watchPublicProfileProvider(
          'runner-1',
        ).overrideWith((ref) => targetStream),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: PublicProfileScreen(
          uid: 'runner-1',
          initialProfile: initialProfile,
        ),
      ),
    ),
  );
}
