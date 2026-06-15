import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/attended_event_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SwipeHubScreen extends ConsumerWidget {
  const SwipeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);

    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      body: uidAsync.when(
        loading: () => const CatchSkeletonList(),
        error: (e, _) => CatchErrorState.fromError(
          e,
          context: AppErrorContext.auth,
          onRetry: () => ref.invalidate(uidProvider),
        ),
        data: (uid) {
          if (uid == null) return const SizedBox.shrink();

          final eventsAsync = ref.watch(watchAttendedEventsProvider(uid));

          return eventsAsync.when(
            loading: () => const CatchSkeletonList(),
            error: (e, _) => CatchErrorState.fromError(
              e,
              context: AppErrorContext.event,
              onRetry: () => ref.invalidate(watchAttendedEventsProvider(uid)),
            ),
            data: (events) {
              final activeEvents = eventsWithOpenSwipeWindow(events);

              if (activeEvents.isEmpty) {
                return const _CatchesEmptyState();
              }

              return _CatchesHubContent(activeEvents: activeEvents);
            },
          );
        },
      ),
    );
  }
}

class _CatchesHubContent extends StatelessWidget {
  const _CatchesHubContent({required this.activeEvents});

  final List<Event> activeEvents;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final featuredRun = activeEvents.first;
    final remaining = swipeWindowClosesAt(
      featuredRun,
    ).difference(DateTime.now());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          CatchSpacing.s2,
          CatchSpacing.s5,
          CatchSpacing.s6,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _CatchesHeader(),
                  gapH16,
                  _CatchesIntroCard(
                    event: featuredRun,
                    remaining: remaining,
                    onTap: () => context.pushNamed(
                      Routes.swipeEventScreen.name,
                      pathParameters: {'eventId': featuredRun.id},
                    ),
                  ),
                  gapH24,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Open catch windows',
                          style: CatchTextStyles.titleL(context),
                        ),
                      ),
                      Text(
                        '${activeEvents.length}',
                        style: CatchTextStyles.mono(context, color: t.primary),
                      ),
                    ],
                  ),
                  gapH12,
                  for (final event in activeEvents) ...[
                    AttendedEventTile(event: event),
                    if (event != activeEvents.last) gapH12,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatchesHeader extends StatelessWidget {
  const _CatchesHeader();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Catches', heavy: true),
              gapH2,
              Text('After the event', style: CatchTextStyles.headline(context)),
            ],
          ),
        ),
        CatchIconTile(
          icon: CatchIcons.favoriteRounded,
          iconColor: t.primary,
          backgroundColor: t.primarySoft,
          borderColor: t.primarySoft,
          radius: CatchRadius.pill,
        ),
      ],
    );
  }
}

class _CatchesIntroCard extends StatelessWidget {
  const _CatchesIntroCard({
    required this.event,
    required this.remaining,
    required this.onTap,
  });

  final Event event;
  final Duration remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      key: SwipeKeys.activeCatchWindowCard,
      onTap: onTap,
      padding: CatchInsets.contentRelaxed,
      gradient: t.heroGrad,
      borderWidth: 0,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: CatchLayout.catchesHubBackgroundIconRightOffset,
            top: CatchLayout.catchesHubBackgroundIconTopOffset,
            child: Icon(
              CatchIcons.favoriteRounded,
              size: CatchLayout.catchesHubBackgroundIconSize,
              color: t.ink.withValues(alpha: CatchOpacity.clubRatingFill),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '24H WINDOW OPEN',
                style: CatchTextStyles.kicker(context, color: t.ink),
              ),
              gapH10,
              Text(
                'You ran together.\nNow you can catch.',
                style: CatchTextStyles.headline(context, color: t.ink),
              ),
              gapH10,
              Text(
                'Only checked-in runners from ${event.title} are here.',
                style: CatchTextStyles.proseM(
                  context,
                  color: t.ink.withValues(
                    alpha: CatchOpacity.photoSlotDeleteChrome,
                  ),
                ),
              ),
              gapH18,
              Row(
                children: [
                  _PillStat(
                    label: 'Closes in',
                    value: _formatCountdown(remaining),
                  ),
                  gapW10,
                  _PillStat(label: 'Roster', value: '${event.attendedCount}'),
                ],
              ),
              gapH18,
              const CatchButton(
                label: 'Start catching',
                onPressed: null,
                variant: CatchButtonVariant.light,
                fullWidth: true,
                isInteractive: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatCountdown(Duration remaining) {
    if (remaining.isNegative) return 'Closed';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
}

class _PillStat extends StatelessWidget {
  const _PillStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Expanded(
      child: CatchSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.micro10,
        ),
        radius: CatchRadius.md,
        backgroundColor: t.ink.withValues(alpha: CatchOpacity.photoScrimMedium),
        borderColor: t.ink.withValues(
          alpha: CatchOpacity.eventSuccessSubtleBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: CatchTextStyles.supporting(
                context,
                color: t.ink.withValues(
                  alpha: CatchOpacity.rosterFilterSelectedLabel,
                ),
              ),
            ),
            gapH2,
            Text(value, style: CatchTextStyles.mono(context, color: t.ink)),
          ],
        ),
      ),
    );
  }
}

class _CatchesEmptyState extends StatelessWidget {
  const _CatchesEmptyState();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          CatchSpacing.s2,
          CatchSpacing.s5,
          CatchSpacing.s6,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _CatchesHeader(),
                  gapH40,
                  CatchEmptyState(
                    icon: CatchIcons.directionsRunRounded,
                    title: 'No active catches',
                    message:
                        'Book a group event, show up, and your 24-hour catch window opens here after check-in.',
                    action: CatchButton(
                      label: 'Find an event',
                      onPressed: () => context.go(Routes.exploreScreen.path),
                      variant: CatchButtonVariant.secondary,
                    ),
                  ),
                  gapH18,
                  CatchSurface(
                    padding: CatchInsets.content,
                    tone: CatchSurfaceTone.raised,
                    borderColor: t.line,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CatchIcons.lockClockRounded,
                          color: t.primary,
                          size: CatchIcon.control,
                        ),
                        gapW10,
                        Expanded(
                          child: Text(
                            'Dating stays locked until you actually event together. No cold stranger browsing.',
                            style: CatchTextStyles.proseM(
                              context,
                              color: t.ink2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
