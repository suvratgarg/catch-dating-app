import 'package:catch_dating_app/cross_paths/domain/cross_paths_event_consent.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_feature_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all bundled rollout controls fail closed', () {
    expect(kCrossPathsConfigDefaults, {
      CrossPathsFeatureConfig.enableConsentControlsKey: false,
      CrossPathsFeatureConfig.enableExploreSuggestionsKey: false,
    });
    expect(CrossPathsFeatureConfig.disabled.consentControlsEnabled, isFalse);
    expect(CrossPathsFeatureConfig.disabled.exploreSuggestionsEnabled, isFalse);
  });

  test('event consent ids and timestamps decode deterministically', () {
    final updatedAt = Timestamp.fromDate(DateTime.utc(2026, 8, 5));
    final consent = CrossPathsEventConsent.fromJson({
      'eventId': 'event-1',
      'uid': 'runner-1',
      'enabled': true,
      'termsVersion': 1,
      'consentedAt': updatedAt,
      'updatedAt': updatedAt,
      'revokedAt': null,
      'source': 'event_detail',
    });

    expect(consent.enabled, isTrue);
    expect(consent.updatedAt, updatedAt.toDate());
    expect(
      crossPathsEventConsentId(eventId: 'event-1', uid: 'runner-1'),
      'event-1_runner-1',
    );
  });
}
