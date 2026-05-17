import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CelebrationMomentKind { eventCreated, eventJoined, eventCheckedIn, match }

final celebrationEffectsControllerProvider =
    Provider<CelebrationEffectsController>(
      (ref) => const CelebrationEffectsController(),
    );

class CelebrationEffectsController {
  const CelebrationEffectsController();

  Future<void> play(CelebrationMomentKind kind) async {
    switch (kind) {
      case CelebrationMomentKind.eventCreated:
      case CelebrationMomentKind.eventJoined:
        await HapticFeedback.mediumImpact();
        return;
      case CelebrationMomentKind.eventCheckedIn:
        await HapticFeedback.lightImpact();
        return;
      case CelebrationMomentKind.match:
        await HapticFeedback.heavyImpact();
        return;
    }
  }
}
