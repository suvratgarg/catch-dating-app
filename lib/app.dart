import 'package:catch_dating_app/force_update/data/force_update_provider.dart';
import 'package:catch_dating_app/force_update/presentation/update_required_screen.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final forceUpdate = ref.watch(forceUpdateRequiredProvider);

    return MaterialApp.router(
      title: 'Catch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: goRouter,
      builder: forceUpdate
          ? (context, _) => const UpdateRequiredScreen()
          : null,
    );
  }
}
