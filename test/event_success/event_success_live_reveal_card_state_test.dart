import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventSuccessRevealActionState', () {
    test('reports loading when any reveal mutation is pending', () {
      final state = EventSuccessRevealActionState.resolve(
        startPending: false,
        revealPending: true,
        resetPending: false,
      );

      expect(state.isLoading, true);
      expect(state.error, isNull);
    });

    test('uses the first available action error in display order', () {
      final startError = Object();
      final revealError = Object();
      final resetError = Object();

      final state = EventSuccessRevealActionState.resolve(
        startPending: false,
        revealPending: false,
        resetPending: false,
        startError: startError,
        revealError: revealError,
        resetError: resetError,
      );

      expect(state.isLoading, false);
      expect(state.error, same(startError));
    });

    test(
      'falls back to later action errors when earlier actions are clean',
      () {
        final resetError = Object();

        final state = EventSuccessRevealActionState.resolve(
          startPending: false,
          revealPending: false,
          resetPending: false,
          resetError: resetError,
        );

        expect(state.error, same(resetError));
      },
    );
  });
}
