import 'package:catch_dating_app/hosts/presentation/event_management/private_event_setup_capability.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RemoteConfig extends Fake implements FirebaseRemoteConfig {
  final values = <String, bool>{};

  @override
  bool getBool(String key) => values[key] ?? false;
}

void main() {
  test(
    'host release flags default closed and read independent remote keys',
    () {
      expect(hostReleaseConfigDefaults[hostPrivateEventSetupFlagKey], false);
      expect(
        hostReleaseConfigDefaults[hostProgressiveEventDefaultsFlagKey],
        false,
      );

      final remote = _RemoteConfig();
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(privateEventSetupAvailableProvider), false);
      expect(container.read(progressiveEventDefaultsAvailableProvider), false);

      remote.values[hostPrivateEventSetupFlagKey] = true;
      expect(hostReleaseFlagValue(remote, hostPrivateEventSetupFlagKey), true);
      expect(
        hostReleaseFlagValue(remote, hostProgressiveEventDefaultsFlagKey),
        false,
      );

      remote.values[hostProgressiveEventDefaultsFlagKey] = true;
      expect(
        hostReleaseFlagValue(remote, hostProgressiveEventDefaultsFlagKey),
        true,
      );

      remote.values[hostPrivateEventSetupFlagKey] = false;
      expect(hostReleaseFlagValue(remote, hostPrivateEventSetupFlagKey), false);
    },
  );

  test(
    'realtime update activates only its key and retains cache on failure',
    () async {
      var activations = 0;
      var refreshes = 0;
      Future<bool> activate() async {
        activations++;
        return true;
      }

      await activateHostReleaseUpdate(
        updatedKeys: {hostProgressiveEventDefaultsFlagKey},
        key: hostPrivateEventSetupFlagKey,
        activate: activate,
        onActivated: () => refreshes++,
      );
      expect(activations, 0);
      expect(refreshes, 0);

      await activateHostReleaseUpdate(
        updatedKeys: {hostPrivateEventSetupFlagKey},
        key: hostPrivateEventSetupFlagKey,
        activate: activate,
        onActivated: () => refreshes++,
      );
      expect(activations, 1);
      expect(refreshes, 1);

      await expectLater(
        activateHostReleaseUpdate(
          updatedKeys: {hostPrivateEventSetupFlagKey},
          key: hostPrivateEventSetupFlagKey,
          activate: () async => throw StateError('network unavailable'),
          onActivated: () => refreshes++,
        ),
        throwsStateError,
      );
      expect(refreshes, 1);
    },
  );
}
