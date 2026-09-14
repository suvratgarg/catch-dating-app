import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';

class WidgetbookCompanionNoopEventSuccessLiveEffectsController
    extends EventSuccessLiveEffectsController {
  @override
  Future<void> play(EventSuccessLiveEffectKind kind) async {}

  @override
  Future<void> playAmbientBed(EventSuccessAmbientBed bed) async {}

  @override
  Future<void> stopAmbientBed() async {}

  @override
  Future<void> dispose() async {}
}
