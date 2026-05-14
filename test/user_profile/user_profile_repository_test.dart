import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

class TestFirebaseFunctions extends Fake implements FirebaseFunctions {
  final callables = <String, TestHttpsCallable>{};

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callables.putIfAbsent(name, () => TestHttpsCallable(name));
  }
}

class TestHttpsCallable extends Fake implements HttpsCallable {
  TestHttpsCallable(this.name);

  final String name;
  final calls = <Object?>[];

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    calls.add(parameters);
    return TestHttpsCallableResult<T>(null as T);
  }
}

class TestHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  TestHttpsCallableResult(this.dataValue);

  final T dataValue;

  @override
  T get data => dataValue;
}

void main() {
  group('UserProfileRepository', () {
    late FakeFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late UserProfileRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = TestFirebaseFunctions();
      repository = UserProfileRepository(firestore, functions);
    });

    test('setUserProfile writes the user document', () async {
      final user =
          buildUser(
            uid: 'runner-42',
            name: 'Asha',
            photoUrls: const ['https://img.example/1.jpg'],
            profilePrompts: normalizeProfilePromptAnswers(
              const [],
              legacyBio: 'Long runs, coffee, and easy Sunday plans.',
            ),
          ).copyWith(
            occupation: 'Product Designer',
            company: 'Catch',
            relationshipGoal: RelationshipGoal.relationship,
            drinking: DrinkingHabit.socially,
          );

      await repository.setUserProfile(userProfile: user);

      final stored = await repository.fetchUserProfile(uid: 'runner-42');
      expect(stored, user);
    });

    test('updatePhotoUrls delegates to the profile update callable', () async {
      final urls = ['https://img.example/2.jpg', 'https://img.example/3.jpg'];

      await repository.updatePhotoUrls(uid: 'runner-42', photoUrls: urls);

      final callable =
          functions.httpsCallable('updateUserProfile') as TestHttpsCallable;
      expect(callable.calls, [
        {
          'fields': {'photoUrls': urls},
        },
      ]);
    });

    test('updateUserProfile normalizes date values for the callable', () async {
      final date = DateTime.utc(1998);
      final timestamp = Timestamp.fromDate(date);

      await repository.updateUserProfile(
        uid: 'runner-42',
        fields: {'name': 'Asha', 'dateOfBirth': timestamp},
      );

      final callable =
          functions.httpsCallable('updateUserProfile') as TestHttpsCallable;
      expect(callable.calls, [
        {
          'fields': {
            'name': 'Asha',
            'dateOfBirth': timestamp.millisecondsSinceEpoch,
          },
        },
      ]);
    });
  });
}
