import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card_content.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  group('ProfileCardContent', () {
    test('does not expose exact distance on public swipe cards', () {
      final profile = buildPublicProfile();

      final content = ProfileCardContent.fromProfile(profile);

      final hasDistance = content.attributes.any(
        (a) => a.icon == Icons.near_me_outlined,
      );
      expect(hasDistance, isFalse);
    });

    test('derives trimmed card sections from the public profile', () {
      final profile =
          buildPublicProfile(
            uid: 'runner-2',
            photoUrls: const [
              'https://img.example/1.jpg',
              'https://img.example/2.jpg',
              'https://img.example/3.jpg',
            ],
          ).copyWith(
            bio: '  Long runs and filter coffee.  ',
            height: 170,
            occupation: '  Designer  ',
            company: '  Catch  ',
            education: EducationLevel.masters,
            religion: Religion.hindu,
            languages: const [Language.english, Language.hindi],
            drinking: DrinkingHabit.socially,
            smoking: SmokingHabit.never,
            workout: WorkoutFrequency.often,
            diet: DietaryPreference.vegetarian,
            children: ChildrenStatus.wantSomeday,
          );

      final content = ProfileCardContent.fromProfile(profile);

      expect(content.primaryPhotoUrl, 'https://img.example/1.jpg');
      expect(content.additionalPhotoUrls, [
        'https://img.example/2.jpg',
        'https://img.example/3.jpg',
      ]);
      expect(content.bio, 'Long runs and filter coffee.');
      expect(content.hasBio, isTrue);
      expect(content.attributes.map((fact) => fact.text), [
        '170 cm',
        'Designer at Catch',
        "Master's",
        'Hindu',
        'English, Hindi',
      ]);
      expect(content.lifestyle.map((fact) => fact.text), [
        'Socially',
        'Never',
        'Often',
        'Vegetarian',
        'Want someday',
      ]);
    });

    test('keeps city on the hero overlay and relationship goal in details', () {
      final profile = buildPublicProfile().copyWith(
        city: IndianCity.indore,
        relationshipGoal: RelationshipGoal.casual,
      );

      final content = ProfileCardContent.fromProfile(profile);

      expect(content.attributes.map((fact) => fact.text), ['Something casual']);
      expect(
        content.attributes.any((fact) => fact.text == IndianCity.indore.label),
        isFalse,
      );
    });

    test('drops blank optional text values', () {
      final profile = buildPublicProfile().copyWith(
        bio: '   ',
        occupation: '   ',
        company: '   ',
      );

      final content = ProfileCardContent.fromProfile(profile);

      expect(content.hasBio, isFalse);
      expect(content.attributes, isEmpty);
    });
  });
}
