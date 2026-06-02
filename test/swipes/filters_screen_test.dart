import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/update_user_profile_patch.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  testWidgets('saves filters through the controller mutation and pops', (
    tester,
  ) async {
    final repository = _FakeFiltersUserProfileRepository();
    final user = buildUser().copyWith(
      interestedInGenders: const [Gender.woman],
      minAgePreference: 18,
      maxAgePreference: 99,
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
    await pumpFeatureUi(tester);
    expect(find.text('Pace range'), findsNothing);
    expect(find.text('Event type'), findsNothing);
    expect(find.text('18 - 60+'), findsOneWidget);
    expect(find.byKey(SwipeKeys.ageRangeSlider), findsOneWidget);
    expect(find.byType(CatchRangeSlider), findsOneWidget);

    await tester.tap(find.byKey(SwipeKeys.genderFilterChip(Gender.man.name)));
    tester
        .widget<CatchRangeSlider>(find.byKey(SwipeKeys.ageRangeSlider))
        .onChanged!(const RangeValues(20, 60));
    await tester.pump();
    expect(find.text('20 - 60+'), findsOneWidget);

    final applyButton = tester.widget<CatchButton>(
      find.byKey(SwipeKeys.applyFiltersButton),
    );
    expect(applyButton.variant, CatchButtonVariant.primary);

    await tester.tap(find.byKey(SwipeKeys.applyFiltersButton));
    await pumpFeatureUi(tester);

    expect(find.text('Open filters'), findsOneWidget);
    expect(repository.updatedUid, 'runner-1');
    expect(repository.updatedFields, {
      'minAgePreference': 20,
      'maxAgePreference': 99,
      'interestedInGenders': ['woman', 'man'],
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
    required UpdateUserProfilePatch patch,
    String action = 'update_profile',
  }) async {
    updatedUid = uid;
    updatedFields = Map<String, dynamic>.from(patch.toFieldsJson());
  }
}
