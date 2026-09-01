import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum HostAudienceView { people, audiences, forms, responses }

HostAudienceView hostAudienceViewFromName(String? name) =>
    HostAudienceView.values.firstWhere(
      (view) => view.name == name,
      orElse: () => HostAudienceView.people,
    );

class HostAudienceTabRail extends StatelessWidget
    implements PreferredSizeWidget {
  const HostAudienceTabRail({
    super.key,
    required this.selected,
    required this.selectionPosition,
    required this.onChanged,
  });

  final HostAudienceView selected;
  final double selectionPosition;
  final ValueChanged<HostAudienceView> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(CatchLayout.tabRailHeight);

  @override
  Widget build(BuildContext context) {
    return CatchTabRail<HostAudienceView>(
      groupKey: const ValueKey<String>('host-audience-view-tabs'),
      selected: selected,
      selectionPosition: selectionPosition,
      onChanged: onChanged,
      scrollable: true,
      options: [
        CatchOption(
          value: HostAudienceView.people,
          label: context.l10n.hostCustomersViewPeople,
        ),
        CatchOption(
          value: HostAudienceView.audiences,
          label: context.l10n.hostCustomersViewAudiences,
        ),
        CatchOption(
          value: HostAudienceView.forms,
          label: context.l10n.hostFormsViewForms,
        ),
        CatchOption(
          value: HostAudienceView.responses,
          label: context.l10n.hostFormsViewResponses,
        ),
      ],
    );
  }
}
