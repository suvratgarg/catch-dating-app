// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_setup_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(programSetupRepository)
final programSetupRepositoryProvider = ProgramSetupRepositoryProvider._();

final class ProgramSetupRepositoryProvider
    extends
        $FunctionalProvider<
          ProgramSetupRepository,
          ProgramSetupRepository,
          ProgramSetupRepository
        >
    with $Provider<ProgramSetupRepository> {
  ProgramSetupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programSetupRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programSetupRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProgramSetupRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgramSetupRepository create(Ref ref) {
    return programSetupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramSetupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramSetupRepository>(value),
    );
  }
}

String _$programSetupRepositoryHash() =>
    r'9f9eece111a504886873fa3950d5ef2f08769e35';

@ProviderFor(programStaffList)
final programStaffListProvider = ProgramStaffListFamily._();

final class ProgramStaffListProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramStaffList>,
          ProgramStaffList,
          FutureOr<ProgramStaffList>
        >
    with $FutureModifier<ProgramStaffList>, $FutureProvider<ProgramStaffList> {
  ProgramStaffListProvider._({
    required ProgramStaffListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'programStaffListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programStaffListHash();

  @override
  String toString() {
    return r'programStaffListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramStaffList> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramStaffList> create(Ref ref) {
    final argument = this.argument as String;
    return programStaffList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramStaffListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programStaffListHash() => r'd822b6ee3cea34745a7cdd085dd98f58fb700b81';

final class ProgramStaffListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProgramStaffList>, String> {
  ProgramStaffListFamily._()
    : super(
        retry: null,
        name: r'programStaffListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramStaffListProvider call(String programId) =>
      ProgramStaffListProvider._(argument: programId, from: this);

  @override
  String toString() => r'programStaffListProvider';
}
