import 'package:catch_dating_app/hosts/data/host_release_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:catch_dating_app/hosts/data/host_release_config.dart'
    show
        activateHostReleaseUpdate,
        hostPrivateEventSetupFlagKey,
        hostProgressiveEventDefaultsFlagKey,
        hostReleaseConfigDefaults,
        hostReleaseFlagValue;

part 'private_event_setup_capability.g.dart';

/// Read-only release capability seam; overrides belong to local fixtures.
// keepalive: The flag is shared across routes and refreshed on app resume.
@Riverpod(keepAlive: true, name: 'privateEventSetupAvailableProvider')
bool privateEventSetupCapability(Ref ref) =>
    ref.watch(hostReleaseFlagProvider(hostPrivateEventSetupFlagKey));

// keepalive: The same remote rollout is shared by every organizer defaults view.
@Riverpod(keepAlive: true, name: 'progressiveEventDefaultsAvailableProvider')
bool progressiveEventDefaultsCapability(Ref ref) =>
    ref.watch(hostReleaseFlagProvider(hostProgressiveEventDefaultsFlagKey));
