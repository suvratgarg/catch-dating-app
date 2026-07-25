// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Role-neutral access to the router selected by the compile-time app root.
///
/// [MyApp] overrides this provider below the selected router implementation so
/// shared services can navigate without importing either product route graph.
// keepalive: the active router is immutable for one installable app lifecycle.

@ProviderFor(activeGoRouter)
final activeGoRouterProvider = ActiveGoRouterProvider._();

/// Role-neutral access to the router selected by the compile-time app root.
///
/// [MyApp] overrides this provider below the selected router implementation so
/// shared services can navigate without importing either product route graph.
// keepalive: the active router is immutable for one installable app lifecycle.

final class ActiveGoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Role-neutral access to the router selected by the compile-time app root.
  ///
  /// [MyApp] overrides this provider below the selected router implementation so
  /// shared services can navigate without importing either product route graph.
  // keepalive: the active router is immutable for one installable app lifecycle.
  ActiveGoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeGoRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeGoRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return activeGoRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$activeGoRouterHash() => r'08f566e28d33b61db2097a314450d2817cef7a8f';
