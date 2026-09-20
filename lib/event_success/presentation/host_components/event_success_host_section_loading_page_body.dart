import 'package:catch_dating_app/event_success/presentation/event_success_host_screen_state.dart';
import 'package:catch_dating_app/event_success/presentation/host_components/event_success_host_tab_bar.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// The tabs are known before the plan resolves; their content is not.
class EventSuccessHostSectionLoadingPageBody extends StatelessWidget {
  const EventSuccessHostSectionLoadingPageBody({
    super.key,
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
  });

  final EventSuccessHostTab initialTab;
  final bool showTabs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTabs) ...[
          IgnorePointer(
            child: EventSuccessHostTabBar(
              selectedTab: initialTab,
              onChanged: (_) {},
            ),
          ),
          gapH16,
        ],
        const Padding(
          padding: CatchInsets.pageBodyRelaxed,
          child: CatchLoadingIndicator(),
        ),
      ],
    );
  }
}
