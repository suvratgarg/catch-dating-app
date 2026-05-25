import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  UserProfile buildUser({required DateTime dateOfBirth}) => UserProfile(
    uid: 'user-1',
    name: 'Runner',
    dateOfBirth: dateOfBirth,
    gender: Gender.man,
    phoneNumber: '+910000000000',
    profileComplete: true,
    interestedInGenders: const [Gender.woman],
  );

  group('UserProfile.age', () {
    test('#21 birthday earlier this year — full year counted', () {
      final now = DateTime.now();
      // DOB = Jan 1, (now.year - 30). Birthday has already passed this year.
      final dob = DateTime(now.year - 30, 1, 1);
      final user = buildUser(dateOfBirth: dob);
      expect(user.age, 30);
    });

    test('#22 birthday later this year — one year subtracted', () {
      final now = DateTime.now();
      // DOB = Dec 31, (now.year - 30). Birthday not yet reached.
      final dob = DateTime(now.year - 30, 12, 31);
      final user = buildUser(dateOfBirth: dob);
      // If today is before Dec 31, age is still 29.
      final expectedAge = now.isBefore(DateTime(now.year, 12, 31)) ? 29 : 30;
      expect(user.age, expectedAge);
    });

    test('#23 exact birthday today — age is exact integer', () {
      final now = DateTime.now();
      // DOB on today's month/day, 25 years ago.
      final dob = DateTime(now.year - 25, now.month, now.day);
      final user = buildUser(dateOfBirth: dob);
      expect(user.age, 25);
    });
  });

  group('readiness gates', () {
    List<ProfilePromptAnswer> completePrompts() => [
      for (final promptId in defaultProfilePromptIds)
        ProfilePromptAnswer(
          promptId: promptId,
          prompt: profilePromptTitle(promptId),
          answer: 'A real answer for $promptId.',
        ),
    ];
    List<ProfilePhoto> completePhotos() => [
      for (final position in [0, 1])
        ProfilePhoto.uploaded(
          position: position,
          url: 'https://example.test/$position.jpg',
          storagePath: 'users/user-1/photos/${position}_test.jpg',
          now: DateTime(2026, 5, 17),
        ),
    ];

    test('booking-ready identity does not require photos or prompts', () {
      final user = buildUser(
        dateOfBirth: DateTime(1995, 6, 15),
      ).copyWith(profileComplete: false);

      expect(user.hasBookingReadyIdentity, isTrue);
      expect(user.hasSocialReadyProfile, isFalse);
    });

    test('booking-ready identity requires interested-in genders', () {
      final user = buildUser(
        dateOfBirth: DateTime(1995, 6, 15),
      ).copyWith(interestedInGenders: const []);

      expect(user.hasBookingReadyIdentity, isFalse);
      expect(user.hasSocialReadyProfile, isFalse);
    });

    test('social-ready profile requires completion, photos, and prompts', () {
      final user = buildUser(dateOfBirth: DateTime(1995, 6, 15)).copyWith(
        profilePrompts: completePrompts(),
        profilePhotos: completePhotos(),
      );
      final withoutPrompt = user.copyWith(
        profilePrompts: completePrompts().take(2).toList(),
      );

      expect(user.hasSocialReadyProfile, isTrue);
      expect(withoutPrompt.hasSocialReadyProfile, isFalse);
    });

    test('run preferences are separate from social readiness', () {
      final user = buildUser(dateOfBirth: DateTime(1995, 6, 15)).copyWith(
        profilePrompts: completePrompts(),
        profilePhotos: completePhotos(),
        activityPreferences: const ActivityPreferences(),
      );

      expect(user.hasSocialReadyProfile, isTrue);
      expect(user.hasCurrentRunPreferences, isFalse);
      expect(
        user
            .copyWith(
              activityPreferences: const ActivityPreferences(
                running: RunningPreferences(
                  version: currentRunPreferencesVersion,
                ),
              ),
            )
            .hasCurrentRunPreferences,
        isTrue,
      );
    });
  });

  group('profile photo helpers', () {
    ProfilePhoto photo(int position, {PhotoPromptAnswer? prompt}) {
      return ProfilePhoto.uploaded(
        position: position,
        url: 'https://example.test/$position.jpg',
        storagePath: 'users/user-1/photos/${position}_test.jpg',
        prompt: prompt,
        now: DateTime(2026, 5, 17),
      );
    }

    test(
      'removeProfilePhotoAtPosition compacts positions and prompt indexes',
      () {
        final updated = removeProfilePhotoAtPosition(
          profilePhotos: [
            photo(0),
            photo(
              1,
              prompt: const PhotoPromptAnswer(
                photoIndex: 1,
                promptId: 'proofIRun',
                prompt: 'Proof I actually event',
                caption: 'Track day',
              ),
            ),
            photo(2),
          ],
          position: 0,
          updatedAt: DateTime(2026, 5, 18),
        );

        expect(updated.map((photo) => photo.position), [0, 1]);
        expect(updated.first.prompt?.photoIndex, 0);
        expect(updated.first.updatedAt, DateTime(2026, 5, 18));
      },
    );

    test('reorderProfilePhoto keeps the moved photo caption attached', () {
      final updated = reorderProfilePhoto(
        profilePhotos: [
          photo(
            0,
            prompt: const PhotoPromptAnswer(
              photoIndex: 0,
              promptId: 'proofIRun',
              prompt: 'Proof I actually event',
              caption: 'Race day',
            ),
          ),
          photo(1),
          photo(2),
        ],
        fromPosition: 0,
        toPosition: 2,
        updatedAt: DateTime(2026, 5, 18),
      );

      expect(updated.map((photo) => photo.url), [
        'https://example.test/1.jpg',
        'https://example.test/2.jpg',
        'https://example.test/0.jpg',
      ]);
      expect(updated.map((photo) => photo.position), [0, 1, 2]);
      expect(updated.last.prompt?.photoIndex, 2);
    });
  });

  test('toJson omits uid because Firestore stores it in the document path', () {
    final user = buildUser(dateOfBirth: DateTime(1995, 6, 15));

    expect(user.toJson().containsKey('uid'), isFalse);
  });

  test('public display name uses editable display name without last name', () {
    final structured = buildUser(dateOfBirth: DateTime(1995, 6, 15)).copyWith(
      name: 'Suvrat Garg',
      firstName: 'Suvrat',
      lastName: 'Garg',
      displayName: 'S.',
    );
    final firstNameFallback = buildUser(
      dateOfBirth: DateTime(1995, 6, 15),
    ).copyWith(name: 'Suvrat Garg', firstName: 'Suvrat', lastName: 'Garg');
    final legacy = buildUser(
      dateOfBirth: DateTime(1995, 6, 15),
    ).copyWith(name: 'Asha Runner');

    expect(structured.accountDisplayName, 'Suvrat Garg');
    expect(structured.publicDisplayName, 'S.');
    expect(structured.greetingDisplayName, 'S.');
    expect(publicProfileFromUserProfile(structured).name, 'S.');
    expect(firstNameFallback.publicDisplayName, 'Suvrat');
    expect(firstNameFallback.greetingDisplayName, 'Suvrat');
    expect(legacy.publicDisplayName, 'Asha');
    expect(legacy.greetingDisplayName, 'Asha');
  });

  test('public profile projection does not expose exact coordinates', () {
    final user = buildUser(
      dateOfBirth: DateTime(1995, 6, 15),
    ).copyWith(latitude: 19.076, longitude: 72.8777);
    final publicProfileJson = publicProfileFromUserProfile(user).toJson();

    expect(publicProfileJson.containsKey('latitude'), isFalse);
    expect(publicProfileJson.containsKey('longitude'), isFalse);
  });

  test('legacy bio JSON is migrated into the perfect-event prompt', () {
    final user = UserProfile.fromJson({
      'uid': 'user-1',
      'name': 'Runner',
      'dateOfBirth': Timestamp.fromDate(DateTime(1995, 6, 15)),
      'gender': Gender.man.name,
      'phoneNumber': '+910000000000',
      'profileComplete': true,
      'bio': '  Easy miles and coffee.  ',
    });

    expect(user.profilePrompts, hasLength(1));
    expect(user.profilePrompts.single.promptId, profilePromptPerfectEventId);
    expect(user.profilePrompts.single.answer, 'Easy miles and coffee.');
    expect(user.toJson().containsKey('bio'), isFalse);
  });

  test(
    'profile photo thumbnail getters prefer tiny URLs with full-photo fallback',
    () {
      final user = buildUser(dateOfBirth: DateTime(1995, 6, 15)).copyWith(
        profilePhotos: [
          ProfilePhoto.uploaded(
            position: 0,
            url: 'https://example.test/full.jpg',
            storagePath: 'users/user-1/photos/0_test.jpg',
            now: DateTime(2026, 5, 17),
          ).copyWith(thumbnailUrl: 'https://example.test/thumb.jpg'),
        ],
      );
      final fullOnly = user.copyWith(
        profilePhotos: [user.profilePhotos.single.copyWith(thumbnailUrl: '')],
      );
      final publicProfile = publicProfileFromUserProfile(user);

      expect(user.primaryPhotoThumbnailUrl, 'https://example.test/thumb.jpg');
      expect(
        fullOnly.primaryPhotoThumbnailUrl,
        'https://example.test/full.jpg',
      );
      expect(
        publicProfile.primaryPhotoThumbnailUrl,
        'https://example.test/thumb.jpg',
      );
    },
  );

  test('fromJson keeps omitted optional enum fields null', () {
    final user = UserProfile.fromJson({
      'uid': 'user-1',
      'name': 'Runner',
      'dateOfBirth': Timestamp.fromDate(DateTime(1995, 6, 15)),
      'gender': Gender.man.name,
      'phoneNumber': '+910000000000',
      'profileComplete': true,
    });

    expect(user.education, isNull);
    expect(user.religion, isNull);
    expect(user.relationshipGoal, isNull);
    expect(user.drinking, isNull);
    expect(user.smoking, isNull);
    expect(user.workout, isNull);
    expect(user.diet, isNull);
    expect(user.children, isNull);
    expect(user.city, isNull);
    expect(user.displayName, isEmpty);
  });
}
