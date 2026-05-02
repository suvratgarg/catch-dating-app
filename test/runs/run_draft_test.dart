import 'package:catch_dating_app/runs/domain/run_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunDraft', () {
    group('toJson / fromJson', () {
      test('roundtrip preserves all fields', () {
        final draft = RunDraft(
          id: 'draft-1',
          runClubId: 'club-1',
          savedAt: DateTime(2026, 5, 1, 15, 45),
          distance: '5',
          capacity: '20',
          price: '100',
          description: 'Easy morning run',
          paceName: 'easy',
          meetingPoint: 'Bandra Fort',
          locationDetails: 'Near the gate',
          startingPointLat: 19.0596,
          startingPointLng: 72.8295,
          selectedDateMillis: DateTime(2026, 5, 15).millisecondsSinceEpoch,
          selectedStartHour: 7,
          selectedStartMinute: 30,
          durationMinutes: 90,
          minAge: '18',
          maxAge: '45',
          maxMen: '10',
          maxWomen: '8',
        );

        final json = draft.toJson();
        final restored = RunDraft.fromJson(json);

        expect(restored.id, 'draft-1');
        expect(restored.runClubId, 'club-1');
        expect(restored.savedAt, DateTime(2026, 5, 1, 15, 45));
        expect(restored.distance, '5');
        expect(restored.capacity, '20');
        expect(restored.price, '100');
        expect(restored.description, 'Easy morning run');
        expect(restored.paceName, 'easy');
        expect(restored.meetingPoint, 'Bandra Fort');
        expect(restored.locationDetails, 'Near the gate');
        expect(restored.startingPointLat, 19.0596);
        expect(restored.startingPointLng, 72.8295);
        expect(
          restored.selectedDateMillis,
          DateTime(2026, 5, 15).millisecondsSinceEpoch,
        );
        expect(restored.selectedStartHour, 7);
        expect(restored.selectedStartMinute, 30);
        expect(restored.durationMinutes, 90);
        expect(restored.minAge, '18');
        expect(restored.maxAge, '45');
        expect(restored.maxMen, '10');
        expect(restored.maxWomen, '8');
      });

      test('roundtrip with only required fields', () {
        final draft = RunDraft(
          id: 'draft-2',
          runClubId: 'club-2',
          savedAt: DateTime(2026, 5, 1),
        );

        final json = draft.toJson();
        final restored = RunDraft.fromJson(json);

        expect(restored.id, 'draft-2');
        expect(restored.runClubId, 'club-2');
        expect(restored.distance, isNull);
        expect(restored.capacity, isNull);
        expect(restored.price, isNull);
        expect(restored.description, isNull);
        expect(restored.paceName, isNull);
        expect(restored.meetingPoint, isNull);
        expect(restored.locationDetails, isNull);
        expect(restored.startingPointLat, isNull);
        expect(restored.startingPointLng, isNull);
        expect(restored.selectedDateMillis, isNull);
        expect(restored.selectedStartHour, isNull);
        expect(restored.selectedStartMinute, isNull);
        expect(restored.durationMinutes, 60);
        expect(restored.minAge, isNull);
        expect(restored.maxAge, isNull);
        expect(restored.maxMen, isNull);
        expect(restored.maxWomen, isNull);
      });

      test('fromJson handles missing fields gracefully', () {
        final restored = RunDraft.fromJson({
          'id': 'draft-3',
          'runClubId': 'club-3',
          'savedAt': '2026-05-01T15:45:00.000',
        });

        expect(restored.id, 'draft-3');
        expect(restored.runClubId, 'club-3');
        expect(restored.durationMinutes, 60); // default
        expect(restored.distance, isNull);
      });
    });

    group('isEmpty', () {
      test('returns true when no content fields are set', () {
        final draft = RunDraft(
          id: 'draft-1',
          runClubId: 'club-1',
          savedAt: DateTime.now(),
        );
        expect(draft.isEmpty, isTrue);
      });

      test('returns false when at least one field is populated', () {
        final draft = RunDraft(
          id: 'draft-1',
          runClubId: 'club-1',
          savedAt: DateTime.now(),
          distance: '5',
        );
        expect(draft.isEmpty, isFalse);
      });

      test('returns false when meetingPoint is populated', () {
        final draft = RunDraft(
          id: 'draft-1',
          runClubId: 'club-1',
          savedAt: DateTime.now(),
          meetingPoint: 'Park',
        );
        expect(draft.isEmpty, isFalse);
      });

      test('returns false when date is populated', () {
        final draft = RunDraft(
          id: 'draft-1',
          runClubId: 'club-1',
          savedAt: DateTime.now(),
          selectedDateMillis: 1234567890000,
        );
        expect(draft.isEmpty, isFalse);
      });
    });

    group('summary', () {
      test('returns "Empty draft" when no content fields are set', () {
        final draft = RunDraft(
          id: 'draft-1',
          runClubId: 'club-1',
          savedAt: DateTime.now(),
        );
        expect(draft.summary, 'Empty draft');
      });

      test('includes distance, pace, and meeting point', () {
        final draft = RunDraft(
          id: 'draft-1',
          runClubId: 'club-1',
          savedAt: DateTime.now(),
          distance: '5',
          paceName: 'easy',
          meetingPoint: 'Bandra Fort',
        );
        expect(draft.summary, '5km easy · Bandra Fort');
      });

      test('includes distance and date', () {
        final draft = RunDraft(
          id: 'draft-1',
          runClubId: 'club-1',
          savedAt: DateTime.now(),
          distance: '10',
          selectedDateMillis: DateTime(2026, 12, 15).millisecondsSinceEpoch,
        );
        expect(draft.summary, '10km · 15/12');
      });

      test('handles only meeting point', () {
        final draft = RunDraft(
          id: 'draft-1',
          runClubId: 'club-1',
          savedAt: DateTime.now(),
          meetingPoint: 'Gateway of India',
        );
        expect(draft.summary, 'Gateway of India');
      });
    });

    group('list serialization', () {
      test('listToJson / listFromJson roundtrip', () {
        final drafts = [
          RunDraft(
            id: 'draft-1',
            runClubId: 'club-1',
            savedAt: DateTime(2026, 5, 1),
            distance: '5',
          ),
          RunDraft(
            id: 'draft-2',
            runClubId: 'club-1',
            savedAt: DateTime(2026, 5, 2),
            meetingPoint: 'Park',
          ),
        ];

        final json = RunDraft.listToJson(drafts);
        final restored = RunDraft.listFromJson(json);

        expect(restored.length, 2);
        expect(restored[0].id, 'draft-1');
        expect(restored[0].distance, '5');
        expect(restored[1].id, 'draft-2');
        expect(restored[1].meetingPoint, 'Park');
      });

      test('listFromJson handles malformed JSON gracefully', () {
        expect(
          () => RunDraft.listFromJson('not valid json'),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
