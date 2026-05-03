import 'package:catch_dating_app/swipes/presentation/profile_card_content.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  group('ProfileCardContent', () {
    test('shows distance when both user locations are available', () {
      final profile = buildPublicProfile().copyWith(
        latitude: 19.0760,
        longitude: 72.8777,
      );
      const currentLocation = LatLng(19.0860, 72.8777);

      final content = ProfileCardContent.fromProfile(
        profile,
        currentUserLocation: currentLocation,
      );

      final distanceAttr = content.attributes.firstWhere(
        (a) => a.icon == Icons.near_me_outlined,
      );
      expect(distanceAttr.text, contains('away'));
    });

    test('omits distance when profile has no coordinates', () {
      final profile = buildPublicProfile(); // no lat/lng
      const currentLocation = LatLng(19.0760, 72.8777);

      final content = ProfileCardContent.fromProfile(
        profile,
        currentUserLocation: currentLocation,
      );

      final hasDistance = content.attributes.any(
        (a) => a.icon == Icons.near_me_outlined,
      );
      expect(hasDistance, isFalse);
    });

    test('omits distance when current location is null', () {
      final profile = buildPublicProfile().copyWith(
        latitude: 19.0760,
        longitude: 72.8777,
      );

      final content = ProfileCardContent.fromProfile(
        profile,
        currentUserLocation: null,
      );

      final hasDistance = content.attributes.any(
        (a) => a.icon == Icons.near_me_outlined,
      );
      expect(hasDistance, isFalse);
    });

    test('does not break when currentUserLocation is not passed', () {
      final profile = buildPublicProfile().copyWith(
        latitude: 19.0760,
        longitude: 72.8777,
      );

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
