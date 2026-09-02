import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum HostAudienceView { people, audiences, forms, responses }

HostAudienceView hostAudienceViewFromName(String? name) =>
    HostAudienceView.values.firstWhere(
      (view) => view.name == name,
      orElse: () => HostAudienceView.people,
    );

/// Canonical Audience destination owner for route-level loading, auth, error,
/// and no-organizer states.
///
/// Those states replace only the page body. The Audience title, peer tabs,
/// semantic body rhythm, responsive content lane, scroll ownership, and shell
/// terminal clearance remain identical to the loaded destination.
class HostAudienceStateScaffold extends StatelessWidget {
  const HostAudienceStateScaffold({
    super.key,
    required this.selected,
    required this.scrollKey,
    required this.slivers,
    this.onChanged,
  }) : assert(slivers.length > 0);

  final HostAudienceView selected;
  final PageStorageKey<String> scrollKey;
  final List<Widget> slivers;
  final ValueChanged<HostAudienceView>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold.withPrimaryRail(
      header: CatchRootScreenHeader.title(
        title: context.l10n.hostNavigationAudience,
      ),
      primaryRail: HostAudienceTabRail(
        selected: selected,
        selectionPosition: selected.index.toDouble(),
        onChanged: onChanged ?? (view) => _openView(context, view),
      ),
      body: CatchRootScreenBody.single(
        page: CatchRootScreenPageSpec.scroll(
          bodyLayout: CatchScreenBodyLayout.standard,
          page: CatchRootScreenPageScrollView(
            scrollKey: scrollKey,
            bodyLayout: CatchScreenBodyLayout.standard,
            constrainToContentWidth: true,
            slivers: slivers,
          ),
        ),
      ),
    );
  }

  static void _openView(BuildContext context, HostAudienceView view) {
    context.goNamed(
      Routes.hostAudienceScreen.name,
      queryParameters: {'view': view.name},
    );
  }
}

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
