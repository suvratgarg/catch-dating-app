import 'package:catch_dating_app/health_activity/data/health_activity_client.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_client_stub.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Installable app packages override this when they own a native health SDK.
///
/// The Host package deliberately retains the unsupported default so HealthKit
/// and Health Connect are absent from its native dependency graph.
final healthActivityClientProvider = Provider<HealthActivityClient>(
  (ref) => const UnsupportedHealthActivityClient(),
);
