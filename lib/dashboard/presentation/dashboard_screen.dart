import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_empty.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _lastVisibleUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isHomeTabActive) {
      _invalidateBookedRunsSubscription();
    }
  }

  bool get _isHomeTabActive {
    final activeTabIndex = AppShellActiveTab.maybeIndexOf(context);
    return activeTabIndex == null || activeTabIndex == 0;
  }

  void _invalidateBookedRunsSubscription() {
    final uid = _lastVisibleUid;
    if (uid == null) return;
    _lastVisibleUid = null;
    ref.invalidate(watchSignedUpRunsProvider(uid));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isHomeTabActive) {
      return const SizedBox.shrink();
    }

    final userAsync = ref.watch(watchUserProfileProvider);

    return userAsync.when(
      loading: () => const _DashboardLoadingScreen(),
      error: (e, _) => const _DashboardMessageScreen(
        message: 'Unable to load your dashboard.',
      ),
      data: (user) {
        if (user == null) {
          _lastVisibleUid = null;
          return DashboardEmpty(user: null);
        }

        _lastVisibleUid = user.uid;

        final signedUpRunsAsync = ref.watch(
          watchSignedUpRunsProvider(user.uid),
        );
        return signedUpRunsAsync.when(
          loading: () => const _DashboardLoadingScreen(),
          error: (e, _) => const _DashboardMessageScreen(
            message: 'Unable to load your booked runs.',
          ),
          data: (signedUpRuns) => signedUpRuns.isEmpty
              ? DashboardEmpty(user: user)
              : DashboardFull(user: user, signedUpRuns: signedUpRuns),
        );
      },
    );
  }
}

class _DashboardLoadingScreen extends StatelessWidget {
  const _DashboardLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CatchLoadingIndicator());
  }
}

class _DashboardMessageScreen extends StatelessWidget {
  const _DashboardMessageScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}
