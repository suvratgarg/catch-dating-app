import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _fcmInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFcm());
  }

  void _initFcm() {
    final uid = ref.read(uidProvider).value;
    if (uid == null || _fcmInitialized) return;
    _fcmInitialized = true;
    ref.read(fcmServiceProvider).initialize(
          uid: uid,
          router: ref.read(goRouterProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider).value ?? '';
    final unreadCount = ref.watch(totalUnreadCountProvider(uid));

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Clubs',
          ),
          const NavigationDestination(
            icon: Icon(Icons.swipe_outlined),
            selectedIcon: Icon(Icons.swipe),
            label: 'Swipe',
          ),
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
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
