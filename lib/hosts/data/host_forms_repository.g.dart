// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_forms_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostFormsRepository)
final hostFormsRepositoryProvider = HostFormsRepositoryProvider._();

final class HostFormsRepositoryProvider
    extends
        $FunctionalProvider<
          HostFormsRepository,
          HostFormsRepository,
          HostFormsRepository
        >
    with $Provider<HostFormsRepository> {
  HostFormsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostFormsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostFormsRepositoryHash();

  @$internal
  @override
  $ProviderElement<HostFormsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HostFormsRepository create(Ref ref) {
    return hostFormsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostFormsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostFormsRepository>(value),
    );
  }
}

String _$hostFormsRepositoryHash() =>
    r'97dcc5e861025c84d665d7a166fe6815ddc83bff';

@ProviderFor(hostFormTemplates)
final hostFormTemplatesProvider = HostFormTemplatesFamily._();

final class HostFormTemplatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HostFormTemplateSummary>>,
          List<HostFormTemplateSummary>,
          FutureOr<List<HostFormTemplateSummary>>
        >
    with
        $FutureModifier<List<HostFormTemplateSummary>>,
        $FutureProvider<List<HostFormTemplateSummary>> {
  HostFormTemplatesProvider._({
    required HostFormTemplatesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostFormTemplatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostFormTemplatesHash();

  @override
  String toString() {
    return r'hostFormTemplatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HostFormTemplateSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HostFormTemplateSummary>> create(Ref ref) {
    final argument = this.argument as String;
    return hostFormTemplates(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostFormTemplatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostFormTemplatesHash() => r'942341af27b372ea8500e0dd2989265fbeb96be1';

final class HostFormTemplatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<HostFormTemplateSummary>>,
          String
        > {
  HostFormTemplatesFamily._()
    : super(
        retry: null,
        name: r'hostFormTemplatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostFormTemplatesProvider call(String organizerId) =>
      HostFormTemplatesProvider._(argument: organizerId, from: this);

  @override
  String toString() => r'hostFormTemplatesProvider';
}
