// Schema-conformance tests for the generated [UpdateClubPatch].
// Catches generator drift against
// `contracts/callables/update_club_payload.schema.json`.
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/schema_contracts.g.dart'
    as schema_contracts;
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

void main() {
  group('UpdateClubPatch schema parity', () {
    test('every patch named parameter maps to a schema field key', () {
      final allSet = UpdateClubPatch(
        name: 'X',
        description: 'X',
        location: 'x',
        area: 'X',
        hostName: 'X',
        hostAvatarUrl: 'https://example.test/avatar.png',
        imageUrl: 'https://example.test/cover.png',
        profileImageUrl: 'https://example.test/profile.png',
        tags: const ['social'],
        instagramHandle: 'x',
        phoneNumber: '+10000000000',
        email: 'x@example.test',
        hostDefaults: const ClubHostDefaults(),
      );

      final schema =
          schema_contracts.schemaContractsByName['UpdateClubCallablePayload']!;
      final fieldsSchema =
          (schema['properties'] as Map<String, Object?>)['fields']
              as Map<String, Object?>;
      final schemaFields = (fieldsSchema['properties'] as Map<String, Object?>)
          .keys
          .toSet();
      final patchKeys = allSet.keys.toSet();

      final missingFromPatch = schemaFields.difference(patchKeys);
      final extraInPatch = patchKeys.difference(schemaFields);
      expect(missingFromPatch, isEmpty);
      expect(extraInPatch, isEmpty);
    });

    test('omits parameters that were not passed', () {
      final patch = UpdateClubPatch(name: 'New Name');
      expect(patch.toFieldsJson(), {'name': 'New Name'});
    });

    test('nullable fields can be explicitly cleared via null', () {
      final patch = UpdateClubPatch(
        location: null,
        instagramHandle: null,
        phoneNumber: null,
        email: null,
      );
      expect(patch.toFieldsJson(), {
        'location': null,
        'instagramHandle': null,
        'phoneNumber': null,
        'email': null,
      });
    });

    test('typed host defaults serialize to schema-valid JSON', () {
      final patch = UpdateClubPatch(hostDefaults: const ClubHostDefaults());
      final schema = JsonSchema.create(
        schema_contracts.schemaContractsByName['UpdateClubCallablePayload']!,
      );
      expect(
        schema.validate(patch.toCallableJson(clubId: 'club-1')).isValid,
        isTrue,
      );
    });

    test('raw() escape hatch produces a schema-valid patch', () {
      final patch = UpdateClubPatch.raw({'name': 'New Name'});
      final schema = JsonSchema.create(
        schema_contracts.schemaContractsByName['UpdateClubCallablePayload']!,
      );
      expect(
        schema.validate(patch.toCallableJson(clubId: 'club-1')).isValid,
        isTrue,
      );
    });
  });
}
