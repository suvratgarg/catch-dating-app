// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_organizer_selection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HostOrganizerSelection)
final hostOrganizerSelectionProvider = HostOrganizerSelectionFamily._();

final class HostOrganizerSelectionProvider
    extends $NotifierProvider<HostOrganizerSelection, String?> {
  HostOrganizerSelectionProvider._({
    required HostOrganizerSelectionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostOrganizerSelectionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostOrganizerSelectionHash();

  @override
  String toString() {
    return r'hostOrganizerSelectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostOrganizerSelection create() => HostOrganizerSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HostOrganizerSelectionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostOrganizerSelectionHash() =>
    r'05ad2a3e8d400dde4bd3ab30c5b092c806cdcbd3';

final class HostOrganizerSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          HostOrganizerSelection,
          String?,
          String?,
          String?,
          String
        > {
  HostOrganizerSelectionFamily._()
    : super(
        retry: null,
        name: r'hostOrganizerSelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  HostOrganizerSelectionProvider call(String uid) =>
      HostOrganizerSelectionProvider._(argument: uid, from: this);

  @override
  String toString() => r'hostOrganizerSelectionProvider';
}

abstract class _$HostOrganizerSelection extends $Notifier<String?> {
  late final _$args = ref.$arg as String;
  String get uid => _$args;

  String? build(String uid);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
