import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// An overlay drawer for the event roster, with an optional edge affordance.
///
/// The roster remains reachable without competing with the event's
/// lifecycle-owned primary workspace. Its panel overlays rather than rebuilds
/// the runtime, so opening it cannot reset live controls. The overlay is rooted
/// at the real viewport edge while the primary workspace keeps its bounded
/// reading lane. A caller that owns a more contextual roster entry point can
/// hide the edge handle.
class HostEventRosterDrawer extends StatefulWidget {
  const HostEventRosterDrawer({
    super.key,
    required this.open,
    required this.bookedCount,
    required this.onOpenChanged,
    required this.body,
    required this.roster,
    this.bodyMaxWidth = CatchLayout.maxContentWidth,
    this.showHandle = true,
    this.onMessageGuests,
  });

  final bool open;
  final int bookedCount;
  final ValueChanged<bool> onOpenChanged;
  final Widget body;
  final Widget roster;
  final double bodyMaxWidth;
  final bool showHandle;
  final VoidCallback? onMessageGuests;

  @override
  State<HostEventRosterDrawer> createState() => _HostEventRosterDrawerState();
}

class _HostEventRosterDrawerState extends State<HostEventRosterDrawer> {
  late bool _hasOpened = widget.open;

  @override
  void didUpdateWidget(covariant HostEventRosterDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open) _hasOpened = true;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations == true;
    final duration = reduceMotion ? Duration.zero : CatchMotion.standard;
    final t = CatchTokens.of(context);

    return CatchSceneViewport(
      maxWidth: double.infinity,
      builder: (context, viewport) {
        final handleWidth = CatchLayout.hostRosterDrawerHandleWidth;
        final drawerWidth = CatchLayout.hostRosterDrawerWidthFor(
          viewport.width,
        );
        final handleTop = CatchLayout.hostRosterDrawerHandleTopFor(
          viewport.height,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.bodyMaxWidth),
                  child: SizedBox.expand(child: widget.body),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !widget.open,
                child: AnimatedOpacity(
                  key: const ValueKey<String>('host_event_roster_drawer.scrim'),
                  duration: duration,
                  curve: CatchMotion.standardCurve,
                  opacity: widget.open ? 1 : 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onOpenChanged(false),
                    child: ColoredBox(color: t.overlay),
                  ),
                ),
              ),
            ),
            AnimatedPositionedDirectional(
              key: const ValueKey<String>('host_event_roster_drawer.panel'),
              duration: duration,
              curve: CatchMotion.standardCurve,
              top: 0,
              bottom: 0,
              end: widget.open ? 0 : -drawerWidth,
              width: drawerWidth,
              child: IgnorePointer(
                ignoring: !widget.open,
                child: ExcludeSemantics(
                  excluding: !widget.open,
                  child: HostEventRosterPanel(
                    bookedCount: widget.bookedCount,
                    onClose: () => widget.onOpenChanged(false),
                    onMessageGuests: widget.onMessageGuests,
                    child: _hasOpened ? widget.roster : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            if (widget.showHandle)
              AnimatedPositionedDirectional(
                key: const ValueKey<String>('host_event_roster_drawer.handle'),
                duration: duration,
                curve: CatchMotion.standardCurve,
                top: handleTop,
                end: widget.open ? drawerWidth : 0,
                width: handleWidth,
                height: CatchLayout.hostRosterDrawerHandleHeight,
                child: HostEventRosterHandle(
                  open: widget.open,
                  bookedCount: widget.bookedCount,
                  onTap: () => widget.onOpenChanged(!widget.open),
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity.abs() < 200) return;
                    final isRtl =
                        Directionality.of(context) == TextDirection.rtl;
                    final openingSwipe = isRtl ? velocity > 0 : velocity < 0;
                    widget.onOpenChanged(openingSwipe);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Counted edge control used to reveal or dismiss the host event roster.
class HostEventRosterHandle extends StatelessWidget {
  const HostEventRosterHandle({
    super.key,
    required this.open,
    required this.bookedCount,
    required this.onTap,
    required this.onHorizontalDragEnd,
  });

  final bool open;
  final int bookedCount;
  final VoidCallback onTap;
  final GestureDragEndCallback onHorizontalDragEnd;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final label = open
        ? context.l10n.hostsHostEventRosterDrawerClose
        : context.l10n.hostsHostEventRosterDrawerOpen(count: bookedCount);
    const radius = BorderRadiusDirectional.only(
      topStart: Radius.circular(CatchRadius.md),
      bottomStart: Radius.circular(CatchRadius.md),
    );

    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: GestureDetector(
          onHorizontalDragEnd: onHorizontalDragEnd,
          child: Material(
            color: t.raised,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: t.line2),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                catchSelectionHaptic();
                onTap();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CatchCountBadge(
                    count: bookedCount,
                    child: Icon(
                      CatchIcons.groupsRounded,
                      color: t.ink,
                      size: CatchIcon.md,
                    ),
                  ),
                  gapH4,
                  Icon(
                    open
                        ? CatchIcons.chevronRightRounded
                        : CatchIcons.arrowBackIosNewRounded,
                    color: t.ink2,
                    size: CatchIcon.sm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay panel chrome for roster content supplied by Host Event Manage.
class HostEventRosterPanel extends StatelessWidget {
  const HostEventRosterPanel({
    super.key,
    required this.bookedCount,
    required this.onClose,
    required this.child,
    this.onMessageGuests,
  });

  final int bookedCount;
  final VoidCallback onClose;
  final Widget child;
  final VoidCallback? onMessageGuests;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Material(
      color: t.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: t.line2)),
        ),
        child: SafeArea(
          left: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: CatchInsets.pageBody,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.hostsHostEventRosterDrawerTitle,
                            style: CatchTextStyles.headlineS(
                              context,
                              color: t.ink,
                            ),
                          ),
                          gapH2,
                          Text(
                            context.l10n.hostsHostEventRosterDrawerCount(
                              count: bookedCount,
                            ),
                            style: CatchTextStyles.supporting(
                              context,
                              color: t.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    gapW12,
                    if (onMessageGuests != null) ...[
                      CatchIconButton.icon(
                        icon: CatchIcons.forumOutlined,
                        tooltip: context
                            .l10n
                            .hostsHostEventRosterDrawerMessageGuests,
                        onTap: onMessageGuests,
                      ),
                      gapW8,
                    ],
                    CatchIconButton.icon(
                      icon: CatchIcons.closeRounded,
                      tooltip: context.l10n.hostsHostEventRosterDrawerClose,
                      onTap: onClose,
                    ),
                  ],
                ),
              ),
              Divider(height: CatchStroke.hairline, color: t.line),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
