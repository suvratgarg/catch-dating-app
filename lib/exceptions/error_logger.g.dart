// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_logger.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A no-op default that must be overridden in [main] with the real instance.

@ProviderFor(errorLogger)
final errorLoggerProvider = ErrorLoggerProvider._();

/// A no-op default that must be overridden in [main] with the real instance.

final class ErrorLoggerProvider
    extends $FunctionalProvider<ErrorLogger, ErrorLogger, ErrorLogger>
    with $Provider<ErrorLogger> {
  /// A no-op default that must be overridden in [main] with the real instance.
  ErrorLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorLoggerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorLoggerHash();

  @$internal
  @override
  $ProviderElement<ErrorLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ErrorLogger create(Ref ref) {
    return errorLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ErrorLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ErrorLogger>(value),
    );
  }
}

String _$errorLoggerHash() => r'cd08f879ab039809b96a6c28f4812fdfd8db2bd2';
