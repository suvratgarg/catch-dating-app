import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'celebration_effects_controller.g.dart';

enum CelebrationMomentKind { eventCreated, eventJoined, eventCheckedIn, match }

@Riverpod(keepAlive: true)
CelebrationEffectsController celebrationEffectsController(Ref ref) =>
    const CelebrationEffectsController();

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
