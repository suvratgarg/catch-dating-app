// Public named factory inputs normalize to private shared storage.
// ignore_for_file: prefer_initializing_formals

import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Host route adapter. Screens supply a path; the shared viewport owns width,
/// pane chrome, dividers, and preservation across desktop/mobile transitions.
class HostNavigationWorkspace extends StatelessWidget {
  const HostNavigationWorkspace({
    super.key,
    required Widget index,
    required Uri uri,
    Widget? detail,
    Widget? preview,
    CatchWorkspacePaneMode indexMode = CatchWorkspacePaneMode.directory,
  }) : _index = index,
       _uri = uri,
       _detail = detail,
       _preview = preview,
       _indexMode = indexMode,
       _eventSelection = false,
       _initialEvent = null,
       _panes = null,
       _compactPaneId = null,
       _onBack = null;

  const HostNavigationWorkspace.event({
    super.key,
    required Widget index,
    required Uri uri,
    Event? initialEvent,
  }) : _index = index,
       _uri = uri,
       _detail = null,
       _preview = null,
       _indexMode = CatchWorkspacePaneMode.directory,
       _eventSelection = true,
       _initialEvent = initialEvent,
       _panes = null,
       _compactPaneId = null,
       _onBack = null;

  factory HostNavigationWorkspace.single({
    Key? key,
    required String id,
    required Widget child,
  }) => HostNavigationWorkspace.panes(
    key: key,
    panes: [CatchWorkspacePane(id: id, child: child)],
  );

  const HostNavigationWorkspace.panes({
    super.key,
    required List<CatchWorkspacePane> panes,
    String? compactPaneId,
    VoidCallback? onBack,
  }) : _panes = panes,
       _compactPaneId = compactPaneId,
       _onBack = onBack,
       _index = null,
       _uri = null,
       _detail = null,
       _preview = null,
       _indexMode = CatchWorkspacePaneMode.directory,
       _eventSelection = false,
       _initialEvent = null;

  final Widget? _index;
  final Uri? _uri;
  final Widget? _detail;
  final Widget? _preview;
  final CatchWorkspacePaneMode _indexMode;
  final bool _eventSelection;
  final Event? _initialEvent;
  final List<CatchWorkspacePane>? _panes;
  final String? _compactPaneId;
  final VoidCallback? _onBack;

  @override
  Widget build(BuildContext context) {
    final route = context
        .dependOnInheritedWidgetOfExactType<HostWorkspaceRouteScope>();
    final uri = _uri;
    final eventId = uri?.queryParameters['eventId'];
    final clubId = uri?.queryParameters['organizerId'];
    final detail =
        _detail ??
        (_eventSelection && eventId != null && clubId != null
            ? HostEventManageRouteScreen(
                key: ValueKey('$clubId/$eventId'),
                clubId: clubId,
                eventId: eventId,
                initialEvent: _initialEvent,
                initialSection: switch (uri!.queryParameters['section']) {
                  'live' => HostEventManageSection.live,
                  'report' => HostEventManageSection.report,
                  'guests' => HostEventManageSection.guests,
                  _ => HostEventManageSection.setup,
                },
              )
            : null);
    final back =
        _onBack ??
        (detail == null || uri == null
            ? null
            : () => context.go(hostWorkspaceIndexUri(uri).toString()));
    final routePanes = route?.panes ?? const <CatchWorkspacePane>[];
    final panes =
        _panes ??
        [
          CatchWorkspacePane(id: 'index', mode: _indexMode, child: _index!),
          if (detail != null)
            CatchWorkspacePane(
              id: 'detail',
              child: CatchWorkspaceBackScope(onBack: back!, child: detail),
            )
          else if (routePanes.isEmpty &&
              (_preview != null ||
                  _indexMode == CatchWorkspacePaneMode.directory))
            CatchWorkspacePane(
              id: 'preview',
              child:
                  _preview ??
                  CatchEmptyState(
                    icon: CatchIcons.chevronRightRounded,
                    title: context.l10n.coreCatchFieldVisiblecopySelect,
                  ),
            ),
        ];
    // An unselected directory's placeholder is auxiliary. A routed selection
    // takes its slot, rather than opening beside a meaningless empty column.
    final basePanes =
        routePanes.isNotEmpty &&
            detail == null &&
            (_compactPaneId == null || _compactPaneId == panes.first.id)
        ? panes.take(1).toList()
        : panes;
    return CatchNavigationViewport(
      onBack: routePanes.isEmpty ? back : route!.onBack,
      compactPaneId: routePanes.isNotEmpty
          ? routePanes.last.id
          : _compactPaneId ?? (detail == null ? panes.first.id : 'detail'),
      panes: [...basePanes, ...routePanes],
    );
  }
}

/// Router-owned attachment of selected content to the existing pane path.
class HostWorkspaceRouteScope extends InheritedWidget {
  const HostWorkspaceRouteScope({
    super.key,
    required this.panes,
    required this.onBack,
    required super.child,
    this.navigatorRoot = false,
  });

  /// Attaches router content to the existing viewport without owning geometry.
  factory HostWorkspaceRouteScope.route({
    Key? key,
    required Widget index,
    required Widget navigator,
    required List<CatchWorkspacePane> ancestors,
    required String? selectedRoute,
    required VoidCallback onBack,
  }) {
    final anchor = HostWorkspaceRouteScope(
      panes: const [],
      onBack: onBack,
      navigatorRoot: true,
      child: navigator,
    );
    return HostWorkspaceRouteScope(
      key: key,
      panes: [
        ...ancestors,
        if (selectedRoute != null)
          CatchWorkspacePane(
            id: selectedRoute,
            child: CatchWorkspaceBackScope(onBack: onBack, child: anchor),
          ),
      ],
      onBack: onBack,
      child: Stack(
        fit: StackFit.expand,
        children: [
          index,
          if (selectedRoute == null) Offstage(child: anchor),
        ],
      ),
    );
  }

  final bool navigatorRoot;
  static bool isNavigatorRoot(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<HostWorkspaceRouteScope>()
          ?.navigatorRoot ??
      false;

  final List<CatchWorkspacePane> panes;
  final VoidCallback onBack;
  @override
  bool updateShouldNotify(HostWorkspaceRouteScope oldWidget) => true;
}

Uri hostWorkspaceIndexUri(Uri uri) => uri.replace(
  queryParameters: {
    for (final entry in uri.queryParameters.entries)
      if (!const {'eventId', 'section', 'setting'}.contains(entry.key))
        entry.key: entry.value,
  },
);

void openHostOrganizerSetting(
  BuildContext context,
  Routes setting,
  String clubId,
) => context.goNamed(
  Routes.hostOrganizerScreen.name,
  queryParameters: {'clubId': clubId, 'setting': setting.name},
);
