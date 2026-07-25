import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Role-neutral access to the router selected by the compile-time app root.
///
/// [MyApp] overrides this provider below the selected router implementation so
/// shared services can navigate without importing either product route graph.
final activeGoRouterProvider = Provider<GoRouter>(
  (ref) => throw StateError(
    'activeGoRouterProvider must be overridden by a Consumer or Host app root.',
  ),
);
