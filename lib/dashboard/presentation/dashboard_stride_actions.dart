import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final dashboardStrideActionsProvider = Provider<DashboardStrideActions>((ref) {
  return DashboardStrideActions(
    ref.watch(healthActivityRepositoryProvider),
    () => ref.invalidate(weeklyActivityProvider),
  );
});
