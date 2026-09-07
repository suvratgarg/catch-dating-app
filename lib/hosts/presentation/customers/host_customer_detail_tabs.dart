import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

enum _HostCustomerDetailView { overview, details, memory, history }

class HostCustomerDetailTabs extends StatefulWidget {
  const HostCustomerDetailTabs({
    super.key,
    required this.overviewBuilder,
    required this.details,
    required this.memory,
    required this.history,
  });

  final Widget Function(VoidCallback openMemory) overviewBuilder;
  final Widget details;
  final Widget memory;
  final Widget history;

  @override
  State<HostCustomerDetailTabs> createState() => _HostCustomerDetailTabsState();
}

class _HostCustomerDetailTabsState extends State<HostCustomerDetailTabs> {
  _HostCustomerDetailView selected = _HostCustomerDetailView.overview;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CatchTabRail<_HostCustomerDetailView>(
        groupKey: const ValueKey('host-customer-detail-tabs'),
        scrollable: true,
        selected: selected,
        onChanged: (value) => setState(() => selected = value),
        options: [
          CatchOption(
            value: _HostCustomerDetailView.overview,
            label: context.l10n.hostCustomersOverview,
          ),
          CatchOption(
            value: _HostCustomerDetailView.details,
            label: context.l10n.hostCustomersDetails,
          ),
          CatchOption(
            value: _HostCustomerDetailView.memory,
            label: context.l10n.hostCustomersMemory,
          ),
          CatchOption(
            value: _HostCustomerDetailView.history,
            label: context.l10n.hostCustomersTimeline,
          ),
        ],
        contentPadding: EdgeInsets.zero,
      ),
      gapH20,
      switch (selected) {
        _HostCustomerDetailView.overview => widget.overviewBuilder(
          () => setState(() => selected = _HostCustomerDetailView.memory),
        ),
        _HostCustomerDetailView.details => widget.details,
        _HostCustomerDetailView.memory => widget.memory,
        _HostCustomerDetailView.history => widget.history,
      },
    ],
  );
}
