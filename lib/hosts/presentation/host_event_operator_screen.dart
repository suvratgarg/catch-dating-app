import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/data/host_event_staff_repository.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_operational_roster_panel.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostEventOperatorScreen extends ConsumerWidget {
  const HostEventOperatorScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessAsync = ref.watch(hostEventOperatorAccessProvider(eventId));
    return CatchAsyncBoundary<HostEventOperatorAccess>(
      value: accessAsync,
      onRetry: () => ref.invalidate(hostEventOperatorAccessProvider(eventId)),
      loadingBuilder: (_) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostsEventOperatorTitle,
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
        ),
        body: const CatchRouteBody.standardViewport(
          child: HostRouteLoadingBody(padding: EdgeInsets.zero),
        ),
      ),
      errorBuilder: (_, error, _, onBoundaryRetry) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostsEventOperatorTitle,
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
        ),
        body: CatchRouteBody.standardViewport(
          child: CatchLocalizedErrorState(
            error,
            context: AppErrorContext.event,
            onRetry: onBoundaryRetry,
          ),
        ),
      ),
      builder: (context, access) {
        if (access.eventStatus == 'cancelled') {
          return CatchRouteScaffold(
            topBarBuilder: (context, scrolledUnder) => CatchTopBar(
              title: access.title,
              subtitle: context.l10n.hostsEventOperatorTitle,
              emphasis: scrolledUnder
                  ? CatchTopBarEmphasis.divided
                  : CatchTopBarEmphasis.plain,
              navigation: const CatchTopBarNavigation(
                mode: CatchTopBarNavigationMode.back,
              ),
            ),
            body: CatchRouteBody.standardViewport(
              child: CatchErrorState(
                title: context.l10n.hostsEventOperatorCancelledTitle,
                message: context.l10n.hostsEventOperatorCancelledMessage,
                icon: CatchIcons.eventBusyOutlined,
                actions: const [CatchErrorBackButton()],
              ),
            ),
          );
        }
        return CatchRouteScaffold(
          topBarBuilder: (context, scrolledUnder) => CatchTopBar(
            title: access.title,
            subtitle: context.l10n.hostsEventOperatorTitle,
            emphasis: scrolledUnder
                ? CatchTopBarEmphasis.divided
                : CatchTopBarEmphasis.plain,
            navigation: const CatchTopBarNavigation(
              mode: CatchTopBarNavigationMode.back,
            ),
          ),
          body: CatchRouteBody.standardSections(
            sections: [
              CatchSectionListItem(
                child: CatchSection.contained(
                  title: context.l10n.hostsEventOperatorAccessTitle,
                  subtitle: context.l10n.hostsEventOperatorAccessSubtitle,
                  child: Wrap(
                    spacing: CatchSpacing.s2,
                    runSpacing: CatchSpacing.s2,
                    children: [
                      CatchBadge.functional(
                        label: access.actorRole == HostEventOperatorRole.manager
                            ? context.l10n.hostsEventOperatorRoleManager
                            : context.l10n.hostsEventOperatorRoleStaff,
                        tone: CatchBadgeTone.success,
                      ),
                      CatchBadge(
                        label: AppTimeFormatters.dateTime(access.startAt),
                        icon: CatchIcons.scheduleOutlined,
                      ),
                      if (access.grantExpiresAt case final expiresAt?)
                        CatchBadge(
                          label: context.l10n.hostsEventOperatorExpires(
                            date: AppTimeFormatters.dateTime(expiresAt),
                          ),
                          tone: CatchBadgeTone.warning,
                        ),
                    ],
                  ),
                ),
              ),
              CatchSectionListItem(
                child: HostOperationalRosterPanel(
                  eventId: eventId,
                  organizerId: access.organizerId,
                  allowAttendanceChanges: access.has(
                    HostEventOperatorPermission.setAttendance,
                  ),
                  allowRuntimeClaimReview: access.has(
                    HostEventOperatorPermission.reviewRuntimeClaims,
                  ),
                  showAudienceInsights:
                      access.actorRole == HostEventOperatorRole.manager,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
