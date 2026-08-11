import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';

EventSuccessPlan withoutModule(EventSuccessPlan plan, String moduleId) {
  return plan.copyWith(
    selectedModuleIds: plan.selectedModuleIds
        .where((id) => id != moduleId)
        .toList(growable: false),
  );
}
