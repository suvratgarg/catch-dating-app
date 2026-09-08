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
    r'855ae2d92dfe80053e0615f86223ed0c45ad825f';
