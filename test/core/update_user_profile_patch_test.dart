// Schema-conformance tests for [UpdateUserProfilePatch]. Catches drift
// between the hand-written typed patch class and
// `contracts/patches/update_user_profile.schema.json`.
import 'package:catch_dating_app/core/schema_contracts/generated/schema_contracts.g.dart'
    as schema_contracts;
import 'package:catch_dating_app/user_profile/domain/update_user_profile_patch.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

void main() {
  group('UpdateUserProfilePatch schema parity', () {
    test('every patch named parameter maps to a schema field key', () {
      // Construct a patch that sets every typed setter at once, then assert
      // the resulting keys are exactly the schema's fields.properties keys.
      // This guarantees the typed constructor cannot have a key the schema
      // doesn't accept, and the schema cannot have a key the patch doesn't
      // expose.
      final allSet = UpdateUserProfilePatch(
        name: 'X',
        displayName: 'X',
        email: 'x@example.test',
        instagramHandle: 'x',
        profilePrompts: const [],
        phoneNumber: '+10000000000',
        dateOfBirth: DateTime.utc(1990, 1, 1),
        gender: Gender.other,
        profileComplete: true,
        photoUrls: const [],
        photoThumbnailUrls: const [],
        photoPrompts: const [],
        profilePhotos: const [],
        city: 'x',
        latitude: 0,
        longitude: 0,
        interestedInGenders: const [Gender.other],
        minAgePreference: 18,
        maxAgePreference: 99,
        height: 170,
        occupation: 'x',
        company: 'x',
        education: EducationLevel.other,
        religion: Religion.other,
        languages: const [Language.other],
        relationshipGoal: RelationshipGoal.unsure,
        drinking: DrinkingHabit.never,
        smoking: SmokingHabit.never,
        workout: WorkoutFrequency.sometimes,
        diet: DietaryPreference.other,
        children: ChildrenStatus.dontHave,
        paceMinSecsPerKm: 300,
        paceMaxSecsPerKm: 420,
        preferredDistances: const [PreferredDistance.fiveK],
        runningReasons: const [RunReason.fitness],
        preferredRunTimes: const [PreferredRunTime.morning],
        runPreferencesVersion: 1,
        prefsNewCatches: true,
        prefsMessages: true,
        prefsEventReminders: true,
        prefsRunStatusUpdates: true,
        prefsClubUpdates: true,
        prefsWeeklyDigest: true,
        prefsShowOnMap: true,
      );

      final schema = schema_contracts
          .schemaContractsByName['UpdateUserProfileCallablePayload']!;
      final fieldsSchema =
          (schema['properties'] as Map<String, Object?>)['fields']
              as Map<String, Object?>;
      final schemaFields =
          (fieldsSchema['properties'] as Map<String, Object?>).keys.toSet();
      final patchKeys = allSet.keys.toSet();

      final missingFromPatch = schemaFields.difference(patchKeys);
      final extraInPatch = patchKeys.difference(schemaFields);
      expect(
        missingFromPatch,
        isEmpty,
        reason:
            'Schema declares fields that UpdateUserProfilePatch does not expose: '
            '$missingFromPatch. Add named parameters to keep them reachable.',
      );
      expect(
        extraInPatch,
        isEmpty,
        reason:
            'UpdateUserProfilePatch sets keys not declared by the schema: '
            '$extraInPatch. Either remove them or update the schema.',
      );
    });

    test('toFieldsJson omits parameters that were not passed', () {
      final patch = UpdateUserProfilePatch(profileComplete: true);
      expect(patch.toFieldsJson(), {'profileComplete': true});
    });

    test('DateTime fields serialize as integer milliseconds', () {
      final dob = DateTime.utc(1994, 5, 20);
      final patch = UpdateUserProfilePatch(dateOfBirth: dob);
      final encoded = patch.toFieldsJson();
      expect(encoded['dateOfBirth'], dob.millisecondsSinceEpoch);
      expect(encoded['dateOfBirth'], isA<int>());
    });

    test('Enum fields serialize as enum names', () {
      final patch = UpdateUserProfilePatch(
        gender: Gender.nonBinary,
        relationshipGoal: RelationshipGoal.marriage,
      );
      final encoded = patch.toFieldsJson();
      expect(encoded['gender'], 'nonBinary');
      expect(encoded['relationshipGoal'], 'marriage');
    });

    test('Lists of enum values serialize as lists of enum names', () {
      final patch = UpdateUserProfilePatch(
        interestedInGenders: const [Gender.man, Gender.woman],
        preferredDistances: const [
          PreferredDistance.fiveK,
          PreferredDistance.tenK,
        ],
      );
      final encoded = patch.toFieldsJson();
      expect(encoded['interestedInGenders'], ['man', 'woman']);
      expect(encoded['preferredDistances'], ['fiveK', 'tenK']);
    });

    test('Nullable fields can be explicitly cleared via null', () {
      // `city`, `instagramHandle`, `latitude`, `longitude` use the sentinel
      // pattern: not passing = omit, passing null = explicitly clear.
      final cleared = UpdateUserProfilePatch(city: null);
      expect(cleared.toFieldsJson(), {'city': null});

      final omitted = UpdateUserProfilePatch();
      expect(omitted.toFieldsJson(), isEmpty);
    });

    test('raw() escape hatch produces a schema-valid patch', () {
      final patch = UpdateUserProfilePatch.raw({
        'prefsShowOnMap': false,
        'height': 175,
      });
      final wireJson = {'fields': patch.toFieldsJson()};
      final schema = JsonSchema.create(
        schema_contracts
            .schemaContractsByName['UpdateUserProfileCallablePayload']!,
      );
      expect(schema.validate(wireJson).isValid, isTrue);
    });
  });
}
