import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EventSuccessLiveEffectKind {
  stepChange,
  countdownStart,
  assignmentRevealed,
  liveEntry,
  guideComplete,
  revealReset,
}

final eventSuccessLiveEffectsControllerProvider =
    Provider<EventSuccessLiveEffectsController>(
      (ref) => const EventSuccessLiveEffectsController(),
    );

class EventSuccessLiveEffectsController {
  const EventSuccessLiveEffectsController();

  Future<void> play(EventSuccessLiveEffectKind kind) async {
    await _playSafely(() async {
      switch (kind) {
        case EventSuccessLiveEffectKind.stepChange:
        case EventSuccessLiveEffectKind.liveEntry:
          await HapticFeedback.lightImpact();
          await SystemSound.play(SystemSoundType.click);
          return;
        case EventSuccessLiveEffectKind.countdownStart:
        case EventSuccessLiveEffectKind.guideComplete:
          await HapticFeedback.mediumImpact();
          await SystemSound.play(SystemSoundType.click);
          return;
        case EventSuccessLiveEffectKind.assignmentRevealed:
          await HapticFeedback.heavyImpact();
          await SystemSound.play(SystemSoundType.alert);
          return;
        case EventSuccessLiveEffectKind.revealReset:
          await HapticFeedback.selectionClick();
          await SystemSound.play(SystemSoundType.click);
          return;
      }
    });
  }

  Future<void> _playSafely(Future<void> Function() playEffect) async {
    try {
      await playEffect();
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
