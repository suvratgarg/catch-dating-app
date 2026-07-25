import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_router.g.dart';

/// Role-neutral access to the router selected by the compile-time app root.
///
/// [MyApp] overrides this provider below the selected router implementation so
/// shared services can navigate without importing either product route graph.
// keepalive: the active router is immutable for one installable app lifecycle.
@Riverpod(keepAlive: true)
GoRouter activeGoRouter(Ref ref) => throw StateError(
  'activeGoRouterProvider must be overridden by a Consumer or Host app root.',
);
