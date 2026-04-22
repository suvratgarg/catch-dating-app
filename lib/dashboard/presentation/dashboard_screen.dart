import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_empty.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(appUserStreamProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (user) {
        if (user == null) return DashboardEmpty(user: null);

        final signedUpRunsAsync = ref.watch(signedUpRunsProvider(user.uid));
        final hasBookedRun =
            signedUpRunsAsync.asData?.value.isNotEmpty ?? false;

        return hasBookedRun
            ? DashboardFull(user: user)
            : DashboardEmpty(user: user);
      },
    );
  }
}
