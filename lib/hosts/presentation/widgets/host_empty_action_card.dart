import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:flutter/material.dart';

/// Compatibility adapter for cataloged host empty states.
///
/// Product call sites use [CatchEmptyState] or [CatchSliverEmptyState]
/// directly. Keeping this adapter uncontained prevents older Widgetbook
/// stories from reintroducing a card-shaped empty-state contract.
@Deprecated('Use CatchEmptyState or CatchSliverEmptyState directly.')
class HostEmptyActionCard extends StatelessWidget {
  const HostEmptyActionCard({
    super.key,
    required this.title,
    required this.body,
    this.actions = const <Widget>[],
  });

  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return CatchEmptyState(
      title: title,
      message: body,
      padding: EdgeInsets.zero,
      action: actions.isEmpty
          ? null
          : Wrap(
              alignment: WrapAlignment.center,
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: actions,
            ),
    );
  }
}
