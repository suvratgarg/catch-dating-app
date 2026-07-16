import 'package:catch_dating_app/clubs/data/club_posts_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/club_action_keys.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_tools.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.gradientColors,
                ),
              ),
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
                if (AppConfig.enableClubPosts) ...[
                  gapH10,
                  Consumer(
                    builder: (context, ref, child) {
                      final quotaAsync = ref.watch(
                        watchClubPostRemainingWeeklyQuotaProvider(club.id),
                      );
                      final remainingQuota =
                          quotaAsync.asData?.value ??
                          ClubPostsRepository.weeklyQuota;
                      final quotaExhausted = remainingQuota <= 0;
                      return CatchButton(
                        label: quotaExhausted
                            ? context.l10n.hostsHostClubToolsLabelPostQuotaUsed
                            : context.l10n.hostsHostClubToolsLabelPostUpdate,
                        onPressed: quotaExhausted
                            ? null
                            : () => _showClubPostComposer(
                                context: context,
                                club: club,
                                remainingQuota: remainingQuota,
                                onSubmitPost: (text) async {
                                  await ref
                                      .read(clubPostsRepositoryProvider)
                                      .createPost(clubId: club.id, text: text);
                                  ref
                                      .read(appAnalyticsProvider)
                                      .logEvent(
                                        AnalyticsEvents.clubPostCreated,
                                        parameters: {
                                          AnalyticsParameters.clubId: club.id,
                                        },
                                      );
                                },
                              ),
                        icon: Icon(CatchIcons.megaphone, size: CatchIcon.md),
                        variant: CatchButtonVariant.secondary,
                        fullWidth: true,
                      );
                    },
                  ),
                ],
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

Future<void> _showClubPostComposer({
  required BuildContext context,
  required Club club,
  required int remainingQuota,
  required Future<void> Function(String text) onSubmitPost,
}) async {
  final controller = TextEditingController();
  Object? error;
  var pending = false;

  try {
    await showCatchBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final text = controller.text.trim();
            final canSubmit = !pending && remainingQuota > 0 && text.isNotEmpty;

            return CatchBottomSheetScaffold(
              title: context.l10n.hostsHostClubToolsTitlePostToFollowers,
              subtitle: context.l10n
                  .hostsHostClubToolsSubtitleRemainingquotaOfWeeklyquotaPosts(
                    remainingQuota: remainingQuota,
                    weeklyQuota: ClubPostsRepository.weeklyQuota,
                  ),
              keyboardSafe: true,
              action: CatchButton(
                label: pending
                    ? context.l10n.hostsHostClubToolsLabelPosting
                    : context.l10n.hostsHostClubToolsLabelPostUpdate,
                onPressed: canSubmit
                    ? () async {
                        setSheetState(() {
                          pending = true;
                          error = null;
                        });
                        try {
                          await onSubmitPost(text);
                          if (!sheetContext.mounted) return;
                          Navigator.of(sheetContext).pop();
                          if (!context.mounted) return;
                          showCatchSnackBar(
                            context,
                            context
                                .l10n
                                .hostsHostClubToolsCatchbuttonPostedToFollowers,
                          );
                        } catch (caught) {
                          setSheetState(() {
                            pending = false;
                            error = caught;
                          });
                        }
                      }
                    : null,
                fullWidth: true,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CatchField.input(
                    title: context.l10n.hostsHostClubToolsTitleUpdate,
                    controller: controller,
                    placeholder: context
                        .l10n
                        .hostsHostClubToolsPlaceholderShareARouteNote,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 5,
                    minLines: 3,
                    inputFormatters: [LengthLimitingTextInputFormatter(500)],
                    helperText: context.l10n
                        .hostsHostClubToolsHelpertextValue1CharactersLeft(
                          value1: 500 - controller.text.length,
                        ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  if (error != null) ...[
                    gapH10,
                    Text(
                      context.l10n.hostsHostClubToolsTextCouldNotPostThis,
                      style: CatchTextStyles.supporting(
                        context,
                        color: CatchTokens.of(context).danger,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  } finally {
    controller.dispose();
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
