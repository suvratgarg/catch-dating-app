import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Turn on only after private setup commands, reads, and privacy guards are
/// deployed together. Both the create route and its manager inventory use it.
bool privateEventSetupAvailable() => false;

/// Read-only release capability seam; overrides belong to local fixtures.
final privateEventSetupAvailableProvider = Provider<bool>(
  (ref) => privateEventSetupAvailable(),
);
