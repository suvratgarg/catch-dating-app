// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_lodging_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One state owner fences every async result and retains an uncertain command
/// verbatim for retry. Authority loss/disposal clears private planning data.

@ProviderFor(ProgramLodgingController)
final programLodgingControllerProvider = ProgramLodgingControllerFamily._();

/// One state owner fences every async result and retains an uncertain command
/// verbatim for retry. Authority loss/disposal clears private planning data.
final class ProgramLodgingControllerProvider
    extends
        $AsyncNotifierProvider<ProgramLodgingController, ProgramLodgingView> {
  /// One state owner fences every async result and retains an uncertain command
  /// verbatim for retry. Authority loss/disposal clears private planning data.
  ProgramLodgingControllerProvider._({
    required ProgramLodgingControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'programLodgingControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programLodgingControllerHash();

  @override
  String toString() {
    return r'programLodgingControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProgramLodgingController create() => ProgramLodgingController();

  @override
  bool operator ==(Object other) {
    return other is ProgramLodgingControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programLodgingControllerHash() =>
    r'8151d48b74496b3776de5d1fb7523b156d5d0873';

/// One state owner fences every async result and retains an uncertain command
/// verbatim for retry. Authority loss/disposal clears private planning data.

final class ProgramLodgingControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ProgramLodgingController,
          AsyncValue<ProgramLodgingView>,
          ProgramLodgingView,
          FutureOr<ProgramLodgingView>,
          String
        > {
  ProgramLodgingControllerFamily._()
    : super(
        retry: null,
        name: r'programLodgingControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One state owner fences every async result and retains an uncertain command
  /// verbatim for retry. Authority loss/disposal clears private planning data.

  ProgramLodgingControllerProvider call(String programId) =>
      ProgramLodgingControllerProvider._(argument: programId, from: this);

  @override
  String toString() => r'programLodgingControllerProvider';
}

/// One state owner fences every async result and retains an uncertain command
/// verbatim for retry. Authority loss/disposal clears private planning data.

abstract class _$ProgramLodgingController
    extends $AsyncNotifier<ProgramLodgingView> {
  late final _$args = ref.$arg as String;
  String get programId => _$args;

  FutureOr<ProgramLodgingView> build(String programId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ProgramLodgingView>, ProgramLodgingView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ProgramLodgingView>, ProgramLodgingView>,
              AsyncValue<ProgramLodgingView>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
