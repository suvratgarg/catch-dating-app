import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_client_provider.dart';
import 'package:catch_dating_app/payments/data/razorpay_checkout.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_consumer_app/mobile_health_activity_client.dart';
import 'package:catch_consumer_app/razorpay_checkout_adapter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Consumer-owned native capability bindings around the shared Consumer UI.
class ConsumerPlatformApp extends StatelessWidget {
  const ConsumerPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConsumerPlatformScope(
      child: MyApp(routerProvider: consumerGoRouterProvider),
    );
  }
}

/// The production native bindings, reusable by supervised native entrypoints.
///
/// Keeping these bindings in one scope prevents an acceptance harness from
/// substituting a fake checkout while leaving the shipped app unchanged.
class ConsumerPlatformScope extends StatelessWidget {
  const ConsumerPlatformScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        healthActivityClientProvider.overrideWith(
          (ref) => MobileHealthActivityClient(),
        ),
        razorpayCheckoutFactoryProvider.overrideWithValue(
          PluginRazorpayCheckout.new,
        ),
      ],
      child: child,
    );
  }
}
