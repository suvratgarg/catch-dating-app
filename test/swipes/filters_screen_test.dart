import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  testWidgets('saves filters through the controller mutation and pops', (
    tester,
  ) async {
    final repository = _FakeFiltersUserProfileRepository();
    final user = buildUser(uid: 'runner-1').copyWith(
      interestedInGenders: const [Gender.woman],
      preferredDistances: const [],
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/filters'),
              child: const Text('Open filters'),
            ),
          ),
        ),
        GoRoute(
          path: '/filters',
          builder: (context, state) => const FiltersScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(user.uid)),
          watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
          userProfileRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SwipeKeys.genderFilterChip(Gender.man.name)));
    await tester.tap(
      find.byKey(SwipeKeys.distanceFilterChip(PreferredDistance.fiveK.name)),
    );
    await tester.tap(find.byKey(SwipeKeys.applyFiltersButton));
    await tester.pumpAndSettle();

    expect(find.text('Open filters'), findsOneWidget);
    expect(repository.updatedUid, 'runner-1');
    expect(repository.updatedFields, {
      'minAgePreference': 18,
      'maxAgePreference': 99,
      'paceMinSecsPerKm': 300,
      'paceMaxSecsPerKm': 420,
      'interestedInGenders': ['woman', 'man'],
      'preferredDistances': ['fiveK'],
    });
  });
}

class _FakeFiltersUserProfileRepository extends Fake
    implements UserProfileRepository {
  String? updatedUid;
  Map<String, dynamic>? updatedFields;

  @override
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> fields,
  }) async {
    updatedUid = uid;
    updatedFields = Map<String, dynamic>.from(fields);
  }
}
