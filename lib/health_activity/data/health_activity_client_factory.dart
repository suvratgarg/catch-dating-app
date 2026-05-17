import 'package:catch_dating_app/health_activity/data/health_activity_client.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_client_stub.dart'
    if (dart.library.io) 'package:catch_dating_app/health_activity/data/health_activity_client_mobile.dart'
    as platform_client;

HealthActivityClient createHealthActivityClient() {
  return platform_client.createHealthActivityClient();
}
