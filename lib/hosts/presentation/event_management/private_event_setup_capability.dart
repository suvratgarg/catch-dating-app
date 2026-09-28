import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'private_event_setup_capability.g.dart';

/// Turn on only after private setup commands, reads, and privacy guards are
/// deployed together. Both the create route and its manager inventory use it.
bool privateEventSetupAvailable() => false;

/// Read-only release capability seam; overrides belong to local fixtures.
// keepalive: Immutable release capability is shared across routes for the app session.
@Riverpod(keepAlive: true, name: 'privateEventSetupAvailableProvider')
bool privateEventSetupCapability(Ref ref) => privateEventSetupAvailable();
