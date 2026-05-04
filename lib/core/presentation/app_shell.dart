import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Tab indices — kept in sync with branch order in go_router.dart
//   0  Home      (DashboardScreen)
//   1  Clubs     (RunClubsListScreen)
//   2  Catches   (SwipeHubScreen)
//   3  Chats     (MatchesListScreen)
//   4  You       (ProfileScreen)

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _fcmInitialized = false;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFcm());
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((results) {
      if (!mounted) return;
      final offline = results.isEmpty ||
          results.every((r) => r == ConnectivityResult.none);
      if (offline != _isOffline) {
        setState(() => _isOffline = offline);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  void _initFcm() {
    final uid = ref.read(uidProvider).value;
    final fcmService = ref.read(fcmServiceProvider);
    if (uid == null || _fcmInitialized || !fcmService.isSupportedPlatform) {
      return;
    }
    _fcmInitialized = true;
    unawaited(
      fcmService
          .initialize(uid: uid, router: ref.read(goRouterProvider))
          .catchError((Object error, StackTrace stackTrace) {
            if (mounted) _fcmInitialized = false;
            FlutterError.reportError(
              FlutterErrorDetails(
                exception: error,
                stack: stackTrace,
                library: 'catch_fcm',
                context: ErrorDescription(
                  'while initializing Firebase Messaging',
                ),
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider).value ?? '';
    final unreadCount = ref.watch(totalUnreadCountProvider(uid));

    // Keep Crashlytics user ID in sync with auth state. Also invalidate
    // the user profile stream on sign-out so the next user starts fresh.
    ref.listen(uidProvider, (prev, next) {
      final uid = next.asData?.value;
      ref.read(errorLoggerProvider).setUserId(uid);
      if (uid == null && prev?.asData?.value != null) {
        ref.invalidate(watchUserProfileProvider);
      }
    });

    // Pre-warm the clubs list stream so switching to the Clubs tab shows
    // data immediately instead of flashing a loading spinner. The stream
    // stays alive as long as AppShell is mounted.
    final cityName = ref.watch(selectedRunClubCityProvider).name;
    ref.watch(
      watchRunClubsByLocationProvider(
        IndianCity.fromName(cityName) ?? IndianCity.mumbai,
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          if (_isOffline) _ConnectivityBanner(),
          Expanded(child: widget.navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        destinations: [
          // 0 — Home
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          // 1 — Clubs
          const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Clubs',
          ),
          // 2 — Catches
          const NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Catches',
          ),
          // 3 — Chats
          NavigationDestination(
            icon: unreadCount > 0
                ? Badge(
                    label: Text('$unreadCount'),
                    child: const Icon(Icons.chat_bubble_outline_rounded),
                  )
                : const Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: unreadCount > 0
                ? Badge(
                    label: Text('$unreadCount'),
                    child: const Icon(Icons.chat_bubble_rounded),
                  )
                : const Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          // 4 — You
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'You',
          ),
        ],
      ),
    );
  }
}

class _ConnectivityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      backgroundColor: t.primarySoft,
      leading: Icon(Icons.cloud_off_rounded, color: t.primary, size: 20),
      content: Text(
        "You're offline. Content may not be up to date.",
        style: CatchTextStyles.bodyS(context, color: t.ink),
      ),
      actions: const [SizedBox.shrink()],
    );
  }
}
