// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_hype_avatar_stack.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runHypeAvatars)
final runHypeAvatarsProvider = RunHypeAvatarsFamily._();

final class RunHypeAvatarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PersonAvatarItem>>,
          List<PersonAvatarItem>,
          FutureOr<List<PersonAvatarItem>>
        >
    with
        $FutureModifier<List<PersonAvatarItem>>,
        $FutureProvider<List<PersonAvatarItem>> {
  RunHypeAvatarsProvider._({
    required RunHypeAvatarsFamily super.from,
    required RunHypeAvatarQuery super.argument,
  }) : super(
         retry: null,
         name: r'runHypeAvatarsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$runHypeAvatarsHash();

  @override
  String toString() {
    return r'runHypeAvatarsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PersonAvatarItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PersonAvatarItem>> create(Ref ref) {
    final argument = this.argument as RunHypeAvatarQuery;
    return runHypeAvatars(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RunHypeAvatarsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$runHypeAvatarsHash() => r'3439047d7850a3c0eb241411bed3ea7f0a708454';

final class RunHypeAvatarsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PersonAvatarItem>>,
          RunHypeAvatarQuery
        > {
  RunHypeAvatarsFamily._()
    : super(
        retry: null,
        name: r'runHypeAvatarsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RunHypeAvatarsProvider call(RunHypeAvatarQuery query) =>
      RunHypeAvatarsProvider._(argument: query, from: this);

  @override
  String toString() => r'runHypeAvatarsProvider';
}
