import 'package:catch_dating_app/clubs/data/organizer_projection_fallback.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const canonicalContext = BackendErrorContext(
    service: BackendService.firestore,
    action: 'watch organizers',
    resource: 'organizers',
  );
  const legacyContext = BackendErrorContext(
    service: BackendService.firestore,
    action: 'watch compatibility projection',
    resource: 'clubs',
  );

  test('watch falls back when canonical collection access is denied', () async {
    final values = await watchOrganizerProjectionWithFallback<List<String>>(
      canonical: () => Stream.error(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      ),
      legacy: () => Stream.value(const ['legacy']),
      context: canonicalContext,
      legacyContext: legacyContext,
    ).toList();

    expect(values, [
      const ['legacy'],
    ]);
  });

  test('successful empty canonical result never consults legacy', () async {
    var legacyReads = 0;
    final values = await watchOrganizerProjectionWithFallback<List<String>>(
      canonical: () => Stream.value(const []),
      legacy: () {
        legacyReads += 1;
        return Stream.value(const ['legacy']);
      },
      context: canonicalContext,
      legacyContext: legacyContext,
    ).toList();

    expect(values, [const <String>[]]);
    expect(legacyReads, 0);
  });

  test('non-rollout failures remain canonical errors', () async {
    final stream = watchOrganizerProjectionWithFallback<List<String>>(
      canonical: () => Stream.error(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      ),
      legacy: () => Stream.value(const ['legacy']),
      context: canonicalContext,
      legacyContext: legacyContext,
    );

    await expectLater(
      stream,
      emitsError(
        isA<NetworkException>().having(
          (error) => error.code,
          'code',
          'connection-failed',
        ),
      ),
    );
  });

  test('fetch falls back on access denial', () async {
    final value = await fetchOrganizerProjectionWithFallback<String>(
      canonical: () => Future.error(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      ),
      legacy: () async => 'legacy',
      context: canonicalContext,
      legacyContext: legacyContext,
    );

    expect(value, 'legacy');
  });
}
