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
    return ProviderScope(
      overrides: [
        healthActivityClientProvider.overrideWith(
          (ref) => MobileHealthActivityClient(),
        ),
        razorpayCheckoutFactoryProvider.overrideWithValue(
          PluginRazorpayCheckout.new,
        ),
      ],
      child: MyApp(routerProvider: consumerGoRouterProvider),
    );
  }
}
