import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CelebrationMomentKind { runCreated, runJoined, runCheckedIn, match }

final celebrationEffectsControllerProvider =
    Provider<CelebrationEffectsController>(
      (ref) => const CelebrationEffectsController(),
    );

class CelebrationEffectsController {
  const CelebrationEffectsController();

  Future<void> play(CelebrationMomentKind kind) async {
    switch (kind) {
      case CelebrationMomentKind.runCreated:
      case CelebrationMomentKind.runJoined:
        await HapticFeedback.mediumImpact();
        return;
      case CelebrationMomentKind.runCheckedIn:
        await HapticFeedback.lightImpact();
        return;
      case CelebrationMomentKind.match:
        await HapticFeedback.heavyImpact();
        return;
    }
  }
}
