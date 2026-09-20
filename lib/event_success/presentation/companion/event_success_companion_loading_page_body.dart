import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// The companion stage and its actions depend on the resolved plan.
/// Keep the route's real header while that structure is unknown.
class EventSuccessCompanionLoadingPageBody extends StatelessWidget {
  const EventSuccessCompanionLoadingPageBody({super.key});

  @override
  Widget build(BuildContext context) =>
      const CatchStateViewport.loading(accountForBottomOverlay: false);
}
