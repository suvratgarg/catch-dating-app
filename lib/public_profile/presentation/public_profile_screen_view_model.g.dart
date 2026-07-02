// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_screen_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(publicProfileScreenState)
final publicProfileScreenStateProvider = PublicProfileScreenStateFamily._();

final class PublicProfileScreenStateProvider
    extends
        $FunctionalProvider<
          PublicProfileScreenState,
          PublicProfileScreenState,
          PublicProfileScreenState
        >
    with $Provider<PublicProfileScreenState> {
  PublicProfileScreenStateProvider._({
    required PublicProfileScreenStateFamily super.from,
    required PublicProfileScreenStateArgs super.argument,
  }) : super(
         retry: null,
         name: r'publicProfileScreenStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicProfileScreenStateHash();

  @override
  String toString() {
    return r'publicProfileScreenStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<PublicProfileScreenState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PublicProfileScreenState create(Ref ref) {
    final argument = this.argument as PublicProfileScreenStateArgs;
    return publicProfileScreenState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PublicProfileScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PublicProfileScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PublicProfileScreenStateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicProfileScreenStateHash() =>
    r'98b4331e2b238516e7556a3581e5d3eceded4d42';

final class PublicProfileScreenStateFamily extends $Family
    with
        $FunctionalFamilyOverride<
          PublicProfileScreenState,
          PublicProfileScreenStateArgs
        > {
  PublicProfileScreenStateFamily._()
    : super(
        retry: null,
        name: r'publicProfileScreenStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublicProfileScreenStateProvider call(PublicProfileScreenStateArgs args) =>
      PublicProfileScreenStateProvider._(argument: args, from: this);

  @override
  String toString() => r'publicProfileScreenStateProvider';
}
