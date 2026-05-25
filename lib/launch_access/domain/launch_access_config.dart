/// Remote Config defaults for the launch-access gate.
///
/// The bundled default keeps the gate disabled. Routing can safely depend on
/// this value later without blocking existing users if Remote Config is absent
/// or temporarily unavailable.
const kLaunchAccessConfigDefaults = <String, dynamic>{
  LaunchAccessConfig.enableGateKey: false,
};

class LaunchAccessConfig {
  const LaunchAccessConfig({required this.gateEnabled});

  static const enableGateKey = 'enable_launch_access_gate';

  final bool gateEnabled;

  static const disabled = LaunchAccessConfig(gateEnabled: false);
}
