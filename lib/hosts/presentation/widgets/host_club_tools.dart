import 'package:catch_dating_app/clubs/data/club_posts_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/club_action_keys.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/hosts/presentation/host_club_post_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_follower_update_composer.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_tools.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostClubManagementPanel extends StatelessWidget {
  const HostClubManagementPanel({
    super.key,
    required this.club,
    required this.events,
    required this.onEditClub,
    required this.onCreateEvent,
  });

  final Club club;
  final List<Event> events;
  final VoidCallback onEditClub;
  final VoidCallback onCreateEvent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = HostToolPalette.defaultPanel(context);
    final totalBooked = events.fold(0, (sum, r) => sum + r.signedUpCount);
    final totalWaitlist = events.fold(0, (sum, r) => sum + r.waitlistCount);
    final baseRevenueEstimate = events.fold(
      0,
      (sum, r) => sum + r.signedUpCount * r.priceInPaise,
    );
    final usesDemandPricing = events.any(
      (event) => event.effectiveEventPolicy.usesDemandPricing,
    );

    return CatchSurface(
      padding: EdgeInsets.zero,
      backgroundColor: palette.background,
      borderColor: palette.border,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CatchSurface(
              tone: CatchSurfaceTone.transparent,
              radius: 0,
              padding: EdgeInsets.zero,
              duration: Duration.zero,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: palette.gradientColors,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Padding(
            padding: CatchInsets.content,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s1,
                  children: [
                    CatchBadge.functional(
                      label: context.l10n.hostsHostClubToolsLabelHostTools,
                      tone: CatchBadgeTone.brand,
                    ),
                    CatchBadge.functional(
                      label: context.l10n.hostsHostClubToolsLabelClub,
                    ),
                  ],
                ),
                gapH8,
                Text(
                  club.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.sectionTitle(context),
                ),
                gapH4,
                Text(
                  context.l10n.hostsHostClubToolsTextManageThisClubPublish,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                gapH12,
                Row(
                  children: [
                    Expanded(
                      child: HostStatChip(
                        label: context.l10n.hostsHostClubToolsLabelBooked,
                        value: context.l10n
                            .hostsHostClubToolsVisiblecopyTotalbooked(
                              totalBooked: totalBooked,
                            ),
                        icon: CatchIcons.checkCircleOutlineRounded,
                      ),
                    ),
                    gapW8,
                    Expanded(
                      child: HostStatChip(
                        label: context.l10n.hostsHostClubToolsLabelWaitlist,
                        value: context.l10n
                            .hostsHostClubToolsVisiblecopyTotalwaitlist(
                              totalWaitlist: totalWaitlist,
                            ),
                        icon: CatchIcons.accessTimeRounded,
                      ),
                    ),
                    gapW8,
                    Expanded(
                      child: HostStatChip(
                        label: usesDemandPricing
                            ? context.l10n.hostsHostClubToolsLabelBaseEst
                            : context.l10n.hostsHostClubToolsLabelRevenue,
                        value: baseRevenueEstimate > 0
                            ? EventFormatters.priceInPaise(
                                baseRevenueEstimate,
                                currencyCode: events.isEmpty
                                    ? defaultCurrencyCode
                                    : events.first.currency,
                              )
                            : '-',
                        icon: CatchIcons.paymentsRounded,
                      ),
                    ),
                  ],
                ),
                if (usesDemandPricing) ...[
                  gapH8,
                  Text(
                    context.l10n.hostsHostClubToolsTextBaseEstimateUsesStarting,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
                gapH12,
                CatchButton(
                  key: ClubActionKeys.addEventButton,
                  label: context.l10n.hostsHostClubToolsLabelAddEvent,
                  onPressed: onCreateEvent,
                  icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                  fullWidth: true,
                ),
                gapH10,
                Consumer(
                  builder: (context, ref, child) {
                    final quotaAsync = ref.watch(
                      watchClubPostRemainingWeeklyQuotaProvider(club.id),
                    );
                    final remainingQuota =
                        catchAsyncStateFromAsyncValue(quotaAsync).value ??
                        ClubPostsRepository.weeklyQuota;
                    final quotaExhausted = remainingQuota <= 0;
                    return CatchButton(
                      label: quotaExhausted
                          ? context.l10n.hostsHostClubToolsLabelPostQuotaUsed
                          : context.l10n.hostsHostClubToolsLabelPostUpdate,
                      onPressed: quotaExhausted
                          ? null
                          : () => showHostFollowerUpdateComposer(
                              context: context,
                              club: club,
                              remainingQuota: remainingQuota,
                              requestIdFactory:
                                  HostClubPostController.generateRequestId,
                              onSubmitPost:
                                  ({required requestId, required text}) async {
                                    await ref
                                        .read(hostClubPostControllerProvider)
                                        .createPost(
                                          clubId: club.id,
                                          requestId: requestId,
                                          text: text,
                                        );
                                  },
                            ),
                      icon: Icon(CatchIcons.megaphone, size: CatchIcon.md),
                      variant: CatchButtonVariant.secondary,
                      fullWidth: true,
                    );
                  },
                ),
                gapH10,
                CatchButton(
                  key: ClubActionKeys.editButton,
                  label: context.l10n.hostsHostClubToolsLabelEditClub,
                  onPressed: onEditClub,
                  icon: Icon(CatchIcons.editOutlined, size: CatchIcon.md),
                  variant: CatchButtonVariant.secondary,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HostStatChip extends StatelessWidget {
  const HostStatChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.statChipContent,
      backgroundColor: t.surface,
      borderWidth: 0,
      radius: CatchRadius.sm,
      child: CatchStatColumn(
        icon: icon,
        value: value,
        label: label,
        center: true,
      ),
    );
  }
}
