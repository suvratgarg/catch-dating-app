// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'self_profile_screen_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(selfProfileScreenState)
final selfProfileScreenStateProvider = SelfProfileScreenStateProvider._();

final class SelfProfileScreenStateProvider
    extends
        $FunctionalProvider<
          SelfProfileScreenState,
          SelfProfileScreenState,
          SelfProfileScreenState
        >
    with $Provider<SelfProfileScreenState> {
  SelfProfileScreenStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selfProfileScreenStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selfProfileScreenStateHash();

  @$internal
  @override
  $ProviderElement<SelfProfileScreenState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SelfProfileScreenState create(Ref ref) {
    return selfProfileScreenState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelfProfileScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelfProfileScreenState>(value),
    );
  }
}

String _$selfProfileScreenStateHash() =>
    r'c5ce73a1a658f83c93c46e31e2334e5f16c7661a';
