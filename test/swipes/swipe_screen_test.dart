import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/swipes/presentation/profile_surface.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SwipeScreen shows profile-shaped skeleton while queue loads', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(const AsyncLoading<String?>()),
          watchUserProfileProvider.overrideWithValue(
            const AsyncData<UserProfile?>(null),
          ),
          watchEventProvider(
            'event-1',
          ).overrideWithValue(const AsyncData(null)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SwipeScreen(eventId: 'event-1'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CatchesProfileReviewSkeleton), findsOneWidget);
    expect(find.byType(ProfileSurfaceSkeleton), findsOneWidget);
    expect(find.byType(CatchSkeleton), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No catches left'), findsNothing);
  });
}
