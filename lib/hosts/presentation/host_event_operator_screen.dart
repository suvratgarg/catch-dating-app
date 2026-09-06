import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
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
    return CatchAsyncValueView<HostEventOperatorAccess>(
      value: accessAsync,
      onRetry: () => ref.invalidate(hostEventOperatorAccessProvider(eventId)),
      loadingBuilder: (_) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostsEventOperatorTitle,
          divider: scrolledUnder,
          leadingType: CatchTopBarLeading.back,
        ),
        body: const CatchRouteBody.standardViewport(
          child: HostRouteLoadingBody(padding: EdgeInsets.zero),
        ),
      ),
      errorBuilder: (_, error, _) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostsEventOperatorTitle,
          divider: scrolledUnder,
          leadingType: CatchTopBarLeading.back,
        ),
        body: CatchRouteBody.standardViewport(
          child: CatchErrorState.fromError(
            error,
            context: AppErrorContext.event,
            onRetry: () =>
                ref.invalidate(hostEventOperatorAccessProvider(eventId)),
          ),
        ),
      ),
      builder: (context, access) {
        if (access.eventStatus == 'cancelled') {
          return CatchRouteScaffold(
            topBarBuilder: (context, scrolledUnder) => CatchTopBar(
              title: access.title,
              subtitle: context.l10n.hostsEventOperatorTitle,
              divider: scrolledUnder,
              leadingType: CatchTopBarLeading.back,
            ),
            body: CatchRouteBody.standardViewport(
              child: CatchErrorBody(
                title: context.l10n.hostsEventOperatorCancelledTitle,
                message: context.l10n.hostsEventOperatorCancelledMessage,
                icon: CatchIcons.eventBusyOutlined,
                secondaryAction: const CatchErrorBackAction(),
              ),
            ),
          );
        }
        return CatchRouteScaffold(
          topBarBuilder: (context, scrolledUnder) => CatchTopBar(
            title: access.title,
            subtitle: context.l10n.hostsEventOperatorTitle,
            divider: scrolledUnder,
            leadingType: CatchTopBarLeading.back,
          ),
          body: CatchRouteBody.standardSections(
            sections: [
              CatchResponsiveSectionItem(
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
              CatchResponsiveSectionItem(
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
