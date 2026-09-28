// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_stay_actions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stay-lifecycle mutations for the hotel room board: assignment, block,
/// room label, status, and the desk's room-ready / guest-arrived marks.
/// Widgets go through this controller rather than reaching into
/// repository providers directly.

@ProviderFor(ProgramStayActions)
final programStayActionsProvider = ProgramStayActionsProvider._();

/// Stay-lifecycle mutations for the hotel room board: assignment, block,
/// room label, status, and the desk's room-ready / guest-arrived marks.
/// Widgets go through this controller rather than reaching into
/// repository providers directly.
final class ProgramStayActionsProvider
    extends $NotifierProvider<ProgramStayActions, void> {
  /// Stay-lifecycle mutations for the hotel room board: assignment, block,
  /// room label, status, and the desk's room-ready / guest-arrived marks.
  /// Widgets go through this controller rather than reaching into
  /// repository providers directly.
  ProgramStayActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programStayActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programStayActionsHash();

  @$internal
  @override
  ProgramStayActions create() => ProgramStayActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$programStayActionsHash() =>
    r'766fec19ce0992afd6776e7433a83413ab7e6a51';

/// Stay-lifecycle mutations for the hotel room board: assignment, block,
/// room label, status, and the desk's room-ready / guest-arrived marks.
/// Widgets go through this controller rather than reaching into
/// repository providers directly.

abstract class _$ProgramStayActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
