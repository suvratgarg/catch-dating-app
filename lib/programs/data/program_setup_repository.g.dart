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
    required (String, {String? cursor}) super.argument,
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
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProgramStaffList> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramStaffList> create(Ref ref) {
    final argument = this.argument as (String, {String? cursor});
    return programStaffList(ref, argument.$1, cursor: argument.cursor);
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

String _$programStaffListHash() => r'57533bfb2443d4f8e1308095dcc75081231a6e9f';

final class ProgramStaffListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProgramStaffList>,
          (String, {String? cursor})
        > {
  ProgramStaffListFamily._()
    : super(
        retry: null,
        name: r'programStaffListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgramStaffListProvider call(String programId, {String? cursor}) =>
      ProgramStaffListProvider._(
        argument: (programId, cursor: cursor),
        from: this,
      );

  @override
  String toString() => r'programStaffListProvider';
}
