import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_stride_actions_controller.g.dart';

class DashboardStrideActions {
  const DashboardStrideActions(this._repository, this._refreshWeeklyActivity);

  final HealthActivityRepository _repository;
  final void Function() _refreshWeeklyActivity;

  Future<bool> requestActivityReadPermission() {
    return _repository.requestActivityReadPermission();
  }

  Future<void> installHealthConnect() {
    return _repository.installHealthConnect();
  }

  void refreshWeeklyActivity() {
    _refreshWeeklyActivity();
  }
}

@riverpod
DashboardStrideActions dashboardStrideActions(Ref ref) {
  return DashboardStrideActions(
    ref.watch(healthActivityRepositoryProvider),
    () => ref.invalidate(weeklyActivityProvider),
  );
}
