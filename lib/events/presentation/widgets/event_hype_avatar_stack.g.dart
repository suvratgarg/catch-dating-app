// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_hype_avatar_stack.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventHypeAvatars)
final eventHypeAvatarsProvider = EventHypeAvatarsFamily._();

final class EventHypeAvatarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PersonAvatarItem>>,
          List<PersonAvatarItem>,
          FutureOr<List<PersonAvatarItem>>
        >
    with
        $FutureModifier<List<PersonAvatarItem>>,
        $FutureProvider<List<PersonAvatarItem>> {
  EventHypeAvatarsProvider._({
    required EventHypeAvatarsFamily super.from,
    required EventHypeAvatarQuery super.argument,
  }) : super(
         retry: null,
         name: r'eventHypeAvatarsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventHypeAvatarsHash();

  @override
  String toString() {
    return r'eventHypeAvatarsProvider'
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
    final argument = this.argument as EventHypeAvatarQuery;
    return eventHypeAvatars(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventHypeAvatarsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventHypeAvatarsHash() => r'b07d40bac4e39bd1bac014a0a44eabda2bb5c343';

final class EventHypeAvatarsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PersonAvatarItem>>,
          EventHypeAvatarQuery
        > {
  EventHypeAvatarsFamily._()
    : super(
        retry: null,
        name: r'eventHypeAvatarsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventHypeAvatarsProvider call(EventHypeAvatarQuery query) =>
      EventHypeAvatarsProvider._(argument: query, from: this);

  @override
  String toString() => r'eventHypeAvatarsProvider';
}
