// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_account.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventAssistanceAccount)
final eventAssistanceAccountProvider = EventAssistanceAccountProvider._();

final class EventAssistanceAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventAssistanceAccount>,
          AsyncValue<EventAssistanceAccount>,
          AsyncValue<EventAssistanceAccount>
        >
    with $Provider<AsyncValue<EventAssistanceAccount>> {
  EventAssistanceAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventAssistanceAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceAccountHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<EventAssistanceAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<EventAssistanceAccount> create(Ref ref) {
    return eventAssistanceAccount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<EventAssistanceAccount> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<EventAssistanceAccount>>(
        value,
      ),
    );
  }
}

String _$eventAssistanceAccountHash() =>
    r'b3958b15ec0e5e0e2ee2d11ed2afca4a9b76009c';
