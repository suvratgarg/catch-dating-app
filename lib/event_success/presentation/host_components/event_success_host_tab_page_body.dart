import 'package:catch_dating_app/event_success/presentation/event_success_host_keys.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventSuccessHostTabPageBody extends StatelessWidget {
  const EventSuccessHostTabPageBody({
    super.key,
    required this.embedded,
    required this.children,
  });

  final bool embedded;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return CatchSectionList(
        emptyStateOmitted: true,
        gap: 0,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }
    return SingleChildScrollView(
      key: EventSuccessHostKeys.scrollView,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: CatchInsets.contentRelaxed,
      child: CatchSectionList(
        emptyStateOmitted: true,
        gap: 0,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
