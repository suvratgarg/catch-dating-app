import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActivityKind', () {
    test('keeps event format defaults separate from health import kinds', () {
      expect(
        ActivityKind.socialRun.defaultInteractionModel,
        EventInteractionModel.pacePods,
      );
      expect(ActivityKind.socialRun.healthActivityKind, ActivityKind.running);
      expect(ActivityKind.running.isHealthImportSupported, isTrue);
      expect(ActivityKind.socialRun.isHealthImportSupported, isFalse);
    });

    test('sets useful defaults for common event structures', () {
      expect(
        ActivityKind.pickleball.defaultInteractionModel,
        EventInteractionModel.pairedRotations,
      );
      expect(
        ActivityKind.dinner.defaultInteractionModel,
        EventInteractionModel.seatedTable,
      );
      expect(
        ActivityKind.pubQuiz.defaultInteractionModel,
        EventInteractionModel.teamRotations,
      );
    });
  });

  group('EventFormatSnapshot', () {
    test('round-trips the default social run snapshot', () {
      const snapshot = EventFormatSnapshot.socialRun();

      expect(EventFormatSnapshot.fromJson(snapshot.toJson()), snapshot);
    });

    test('falls back safely for missing and unknown values', () {
      final snapshot = EventFormatSnapshot.fromJson({
        'version': 1,
        'activityKind': 'not_real',
        'interactionModel': 'not_real',
      });

      expect(snapshot.activityKind, ActivityKind.socialRun);
      expect(snapshot.interactionModel, EventInteractionModel.pacePods);
    });

    test('derives defaults from activity kind', () {
      final snapshot = EventFormatSnapshot.fromActivityKind(
        ActivityKind.pickleball,
      );

      expect(snapshot.activityKind, ActivityKind.pickleball);
      expect(snapshot.interactionModel, EventInteractionModel.pairedRotations);
      expect(snapshot.defaultPlaybookId, 'pickleball_rotations');
    });

    test('does not infer a playbook when reading a saved custom format', () {
      final snapshot = EventFormatSnapshot.fromJson({
        'version': 1,
        'activityKind': 'openActivity',
        'interactionModel': 'teamRotations',
        'customActivityLabel': 'Trivia night',
      });

      expect(snapshot.activityKind, ActivityKind.openActivity);
      expect(snapshot.interactionModel, EventInteractionModel.teamRotations);
      expect(snapshot.defaultPlaybookId, isNull);
      expect(snapshot.label, 'Trivia night');
    });

    test(
      'builds custom open formats without forcing the open preset playbook',
      () {
        final snapshot = EventFormatSnapshot.custom(
          label: 'Salsa night',
          interactionModel: EventInteractionModel.pairedRotations,
          activityDetails: const {'danceStyle': 'salsa'},
        );

        expect(snapshot.activityKind, ActivityKind.openActivity);
        expect(snapshot.label, 'Salsa night');
        expect(
          snapshot.interactionModel,
          EventInteractionModel.pairedRotations,
        );
        expect(snapshot.defaultPlaybookId, isNull);
        expect(snapshot.activityDetails['danceStyle'], 'salsa');
        expect(snapshot.activityDetails['formatSource'], 'custom');
      },
    );
  });
}
