import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_view_model.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventRecapScreen extends ConsumerStatefulWidget {
  const EventRecapScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventRecapScreen> createState() => _EventRecapScreenState();
}

class _EventRecapScreenState extends ConsumerState<EventRecapScreen> {
  final Set<String> _selectedVibes = {};

  @override
  Widget build(BuildContext context) {
    final recapAsync = ref.watch(eventRecapViewModelProvider(widget.eventId));

    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      appBar: CatchTopBar(
        title: 'Event recap',
        leading: CatchTopBarIconAction(
          icon: Icons.close_rounded,
          tooltip: 'Close recap',
          onPressed: () => context.pop(),
        ),
      ),
      body: recapAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (error, _) => CatchErrorState.fromError(
          error,
          context: AppErrorContext.event,
          onRetry: () {
            ref.invalidate(watchEventProvider(widget.eventId));
            ref.invalidate(
              watchEventParticipationsForEventProvider(widget.eventId),
            );
            ref.invalidate(uidProvider);
            ref.invalidate(eventRecapViewModelProvider(widget.eventId));
          },
        ),
        data: (viewModel) {
          if (viewModel == null) {
            return const CatchErrorState(
              title: 'Event not found',
              message: 'This event is no longer available.',
            );
          }
          final t = CatchTokens.of(context);
          final event = viewModel.event;
          final attendeeIds = viewModel.attendeeIds;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              CatchSpacing.s3,
              CatchSpacing.s5,
              CatchSpacing.s6,
            ),
            children: [
              _RecapHero(
                event: event,
                checkedInCount: viewModel.checkedInCount,
              ),
              gapH24,
              Text(
                'Who brought the vibe?',
                style: CatchTextStyles.titleL(context),
              ),
              gapH4,
              Text(
                "Tap people you remember. They'll be easier to spot when you open the catches deck.",
                style: CatchTextStyles.bodyLead(context, color: t.ink2),
              ),
              gapH14,
              if (attendeeIds.isEmpty)
                const _EmptyRoster()
              else
                GridView.builder(
                  itemCount: attendeeIds.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: responsiveGridCount(
                      MediaQuery.of(context).size.width,
                    ),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.74,
                  ),
                  itemBuilder: (context, index) {
                    final attendeeId = attendeeIds[index];
                    return _VibeTile(
                      key: SwipeKeys.vibeTile(attendeeId),
                      uid: attendeeId,
                      selected: _selectedVibes.contains(attendeeId),
                      onTap: () => setState(() {
                        _selectedVibes.contains(attendeeId)
                            ? _selectedVibes.remove(attendeeId)
                            : _selectedVibes.add(attendeeId);
                      }),
                    );
                  },
                ),
              gapH24,
              CatchButton(
                key: SwipeKeys.openCatchesDeckButton,
                label: 'Open catches deck',
                onPressed: () => context.goNamed(
                  Routes.swipeEventScreen.name,
                  pathParameters: {'eventId': event.id},
                  extra: _selectedVibes,
                ),
                fullWidth: true,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecapHero extends StatelessWidget {
  const _RecapHero({required this.event, required this.checkedInCount});

  final Event event;
  final int checkedInCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final closesAt = swipeWindowClosesAt(event);
    final windowLabel = closesAt.isAfter(DateTime.now())
        ? 'Catches open until ${EventFormatters.time(closesAt)}'
        : 'Catch window closed';

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s5),
      backgroundColor: t.ink,
      borderWidth: 0,
      radius: CatchRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${event.title.toUpperCase()} · COMPLETE',
            style: CatchTextStyles.labelM(
              context,
              color: t.surface.withValues(alpha: 0.68),
            ).copyWith(fontWeight: FontWeight.w800),
          ),
          gapH10,
          Text(
            event.distanceLabel,
            style: CatchTextStyles.displayL(context, color: t.surface),
          ),
          gapH4,
          Text(
            '${event.activitySummaryLabel} · $checkedInCount checked in',
            style: CatchTextStyles.supporting(
              context,
              color: t.surface.withValues(alpha: 0.76),
            ),
          ),
          gapH18,
          Row(
            children: [
              _RecapStat(label: 'When', value: event.shortDateLabel),
              _RecapStat(label: 'Time', value: event.compactTimeRangeLabel),
              _RecapStat(label: 'Catches', value: windowLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecapStat extends StatelessWidget {
  const _RecapStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: CatchTextStyles.supporting(
                context,
                color: t.surface.withValues(alpha: 0.56),
              ),
            ),
            gapH3,
            Text(
              value,
              style: CatchTextStyles.labelM(context, color: t.surface),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _VibeTile extends ConsumerWidget {
  const _VibeTile({
    super.key,
    required this.uid,
    required this.selected,
    required this.onTap,
  });

  final String uid;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(watchPublicProfileProvider(uid)).asData?.value;
    final t = CatchTokens.of(context);

    final name = profile?.name ?? 'runner';

    return Tooltip(
      message: selected ? 'Remove $name' : 'Remember $name',
      child: Semantics(
        button: true,
        selected: selected,
        label: profile?.name ?? 'Runner',
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(CatchRadius.md),
              border: Border.all(
                color: selected ? t.primary : t.line,
                width: selected ? 3 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ProfilePhoto(profile: profile),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.74),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Text(
                    profile?.name ?? 'Runner',
                    style: CatchTextStyles.labelM(context, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selected)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: t.primary,
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: t.primaryInk,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.profile});

  final PublicProfile? profile;

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile?.primaryPhotoThumbnailUrl;
    if (photoUrl == null) {
      return Container(
        color: CatchTokens.of(context).primarySoft,
        alignment: Alignment.center,
        child: const Icon(Icons.person_rounded, size: 38),
      );
    }
    return Image.network(photoUrl, fit: BoxFit.cover);
  }
}

class _EmptyRoster extends StatelessWidget {
  const _EmptyRoster();

  @override
  Widget build(BuildContext context) {
    return const CatchEmptyState(
      icon: Icons.group_off_rounded,
      title: 'No runners to tag',
      message: 'No other checked-in runners are attached to this event yet.',
      surface: true,
    );
  }
}
