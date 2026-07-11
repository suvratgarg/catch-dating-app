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
                const Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s1,
                  children: [
                    CatchBadge(
                      label: 'Host tools',
                      tone: CatchBadgeTone.brand,
                      uppercase: true,
                    ),
                    CatchBadge(label: 'Club', uppercase: true),
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
                  'Manage this club, publish events, and track upcoming demand.',
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                gapH12,
                Row(
                  children: [
                    Expanded(
                      child: HostStatChip(
                        label: 'Booked',
                        value: '$totalBooked',
                        icon: CatchIcons.checkCircleOutlineRounded,
                      ),
                    ),
                    gapW8,
                    Expanded(
                      child: HostStatChip(
                        label: 'Waitlist',
                        value: '$totalWaitlist',
                        icon: CatchIcons.accessTimeRounded,
                      ),
                    ),
                    gapW8,
                    Expanded(
                      child: HostStatChip(
                        label: usesDemandPricing ? 'Base est.' : 'Revenue',
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
                    'Base estimate uses starting prices; demand-priced bookings may settle higher.',
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
                gapH12,
                CatchButton(
                  key: ClubActionKeys.addEventButton,
                  label: 'Add event',
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
                            ? 'Post quota used'
                            : 'Post update',
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
                  label: 'Edit club',
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
              title: 'Post to followers',
              subtitle:
                  '$remainingQuota of ${ClubPostsRepository.weeklyQuota} posts left this week.',
              keyboardSafe: true,
              action: CatchButton(
                label: pending ? 'Posting...' : 'Post update',
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
                          showCatchSnackBar(context, 'Posted to followers.');
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
                    title: 'Update',
                    controller: controller,
                    placeholder:
                        'Share a route note, meetup detail, or club update.',
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 5,
                    minLines: 3,
                    inputFormatters: [LengthLimitingTextInputFormatter(500)],
                    helperText:
                        '${500 - controller.text.length} characters left',
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  if (error != null) ...[
                    gapH10,
                    Text(
                      'Could not post this update. Please try again.',
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
