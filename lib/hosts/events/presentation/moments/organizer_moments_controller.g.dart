// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizer_moments_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and mutates the moments for one event or program scope.
/// Lifecycle validation stays with the backend; the controller only
/// applies the returned definitions to the list.

@ProviderFor(OrganizerMomentsController)
final organizerMomentsControllerProvider = OrganizerMomentsControllerFamily._();

/// Loads and mutates the moments for one event or program scope.
/// Lifecycle validation stays with the backend; the controller only
/// applies the returned definitions to the list.
final class OrganizerMomentsControllerProvider
    extends
        $AsyncNotifierProvider<
          OrganizerMomentsController,
          OrganizerMomentsState
        > {
  /// Loads and mutates the moments for one event or program scope.
  /// Lifecycle validation stays with the backend; the controller only
  /// applies the returned definitions to the list.
  OrganizerMomentsControllerProvider._({
    required OrganizerMomentsControllerFamily super.from,
    required OrganizerMomentScope super.argument,
  }) : super(
         retry: null,
         name: r'organizerMomentsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$organizerMomentsControllerHash();

  @override
  String toString() {
    return r'organizerMomentsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OrganizerMomentsController create() => OrganizerMomentsController();

  @override
  bool operator ==(Object other) {
    return other is OrganizerMomentsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$organizerMomentsControllerHash() =>
    r'e158df7762c5eb374a5af8bd2ccdd6fd1e95fca3';

/// Loads and mutates the moments for one event or program scope.
/// Lifecycle validation stays with the backend; the controller only
/// applies the returned definitions to the list.

final class OrganizerMomentsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          OrganizerMomentsController,
          AsyncValue<OrganizerMomentsState>,
          OrganizerMomentsState,
          FutureOr<OrganizerMomentsState>,
          OrganizerMomentScope
        > {
  OrganizerMomentsControllerFamily._()
    : super(
        retry: null,
        name: r'organizerMomentsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads and mutates the moments for one event or program scope.
  /// Lifecycle validation stays with the backend; the controller only
  /// applies the returned definitions to the list.

  OrganizerMomentsControllerProvider call(OrganizerMomentScope scope) =>
      OrganizerMomentsControllerProvider._(argument: scope, from: this);

  @override
  String toString() => r'organizerMomentsControllerProvider';
}

/// Loads and mutates the moments for one event or program scope.
/// Lifecycle validation stays with the backend; the controller only
/// applies the returned definitions to the list.

abstract class _$OrganizerMomentsController
    extends $AsyncNotifier<OrganizerMomentsState> {
  late final _$args = ref.$arg as OrganizerMomentScope;
  OrganizerMomentScope get scope => _$args;

  FutureOr<OrganizerMomentsState> build(OrganizerMomentScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<OrganizerMomentsState>, OrganizerMomentsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<OrganizerMomentsState>,
                OrganizerMomentsState
              >,
              AsyncValue<OrganizerMomentsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
