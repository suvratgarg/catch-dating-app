import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
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
          icon: CatchIcons.closeRounded,
          tooltip: 'Close recap',
          onPressed: () => context.pop(),
        ),
      ),
      body: recapAsync.when(
        loading: () => const EventRecapLoadingBody(),
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
          // Resolve every roster profile in one batched fetch instead of a
          // realtime stream per grid tile.
          final rosterProfiles =
              ref
                  .watch(
                    publicProfilesByIdsProvider(
                      PublicProfilesQuery(attendeeIds),
                    ),
                  )
                  .asData
                  ?.value ??
              const <String, PublicProfile>{};

          return ListView(
            padding: CatchInsets.pageBodyTight,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CatchLayout.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _recapHero(
                        context,
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
                        style: CatchTextStyles.proseM(context, color: t.ink2),
                      ),
                      gapH14,
                      if (attendeeIds.isEmpty)
                        _emptyRoster()
                      else
                        GridView.builder(
                          itemCount: attendeeIds.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: responsiveGridCount(
                                  MediaQuery.of(context).size.width,
                                ),
                                crossAxisSpacing: CatchLayout.eventRecapGridGap,
                                mainAxisSpacing: CatchLayout.eventRecapGridGap,
                                childAspectRatio:
                                    CatchAspectRatio.eventRecapVibeTile,
                              ),
                          itemBuilder: (context, index) {
                            final attendeeId = attendeeIds[index];
                            return _vibeTile(
                              context,
                              key: SwipeKeys.vibeTile(attendeeId),
                              profile: rosterProfiles[attendeeId],
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class EventRecapLoadingBody extends StatelessWidget {
  const EventRecapLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ListView(
      padding: CatchInsets.pageBodyTight,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CatchLayout.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _recapHeroSkeleton(context),
                gapH24,
                CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
                gapH8,
                FractionallySizedBox(
                  widthFactor: 0.88,
                  alignment: Alignment.centerLeft,
                  child: CatchSkeleton.text(),
                ),
                gapH14,
                _vibeGridSkeleton(context),
                gapH24,
                CatchSkeleton.box(
                  width: double.infinity,
                  height: CatchLayout.buttonLgHeight,
                  radius: CatchRadius.pill,
                  borderColor: t.line,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _recapHeroSkeleton(BuildContext context) {
  final t = CatchTokens.of(context);

  return CatchSurface(
    padding: CatchInsets.contentRelaxed,
    backgroundColor: t.ink,
    borderWidth: 0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
        gapH10,
        CatchSkeleton.text(width: CatchSpacing.s16 * 2),
        gapH4,
        CatchSkeleton.text(width: CatchSpacing.s16 * 3),
        gapH18,
        Row(
          children: [
            Expanded(child: _recapStatSkeleton()),
            Expanded(child: _recapStatSkeleton()),
            Expanded(child: _recapStatSkeleton()),
          ],
        ),
      ],
    ),
  );
}

Widget _recapStatSkeleton() {
  return Padding(
    padding: const EdgeInsets.only(right: CatchLayout.eventRecapStatInset),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
        gapH6,
        CatchSkeleton.text(width: CatchSpacing.s12),
      ],
    ),
  );
}

Widget _vibeGridSkeleton(BuildContext context) {
  return GridView.count(
    crossAxisCount: responsiveGridCount(MediaQuery.of(context).size.width),
    crossAxisSpacing: CatchLayout.eventRecapGridGap,
    mainAxisSpacing: CatchLayout.eventRecapGridGap,
    childAspectRatio: CatchAspectRatio.eventRecapVibeTile,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (var i = 0; i < 6; i++)
        CatchSkeleton.box(
          height: double.infinity,
          radius: CatchRadius.md,
          borderColor: CatchTokens.of(context).line,
        ),
    ],
  );
}

Widget _recapHero(
  BuildContext context, {
  required Event event,
  required int checkedInCount,
}) {
  final t = CatchTokens.of(context);
  final closesAt = swipeWindowClosesAt(event);
  final windowLabel = closesAt.isAfter(DateTime.now())
      ? 'Catches open until ${EventFormatters.time(closesAt)}'
      : 'Catch window closed';

  return CatchSurface(
    padding: CatchInsets.contentRelaxed,
    backgroundColor: t.ink,
    borderWidth: 0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${event.title.toUpperCase()} · COMPLETE',
          style: CatchTextStyles.labelM(
            context,
            color: t.surface.withValues(
              alpha: CatchOpacity.eventRecapHeroKicker,
            ),
          ).copyWith(fontWeight: FontWeight.w800),
        ),
        gapH10,
        Text(
          event.distanceLabel,
          style: CatchTextStyles.headline(context, color: t.surface),
        ),
        gapH4,
        Text(
          '${event.activitySummaryLabel} · $checkedInCount checked in',
          style: CatchTextStyles.supporting(
            context,
            color: t.surface.withValues(alpha: CatchOpacity.eventRecapHeroMeta),
          ),
        ),
        gapH18,
        Row(
          children: [
            _recapStat(context, label: 'When', value: event.shortDateLabel),
            _recapStat(
              context,
              label: 'Time',
              value: event.compactTimeRangeLabel,
            ),
            _recapStat(context, label: 'Catches', value: windowLabel),
          ],
        ),
      ],
    ),
  );
}

Widget _recapStat(
  BuildContext context, {
  required String label,
  required String value,
}) {
  final t = CatchTokens.of(context);
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.only(right: CatchLayout.eventRecapStatInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: CatchTextStyles.supporting(
              context,
              color: t.surface.withValues(
                alpha: CatchOpacity.eventRecapHeroStatLabel,
              ),
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

Widget _vibeTile(
  BuildContext context, {
  Key? key,
  required PublicProfile? profile,
  required bool selected,
  required VoidCallback onTap,
}) {
  final t = CatchTokens.of(context);
  final name = profile?.name ?? 'guest';

  return KeyedSubtree(
    key: key,
    child: Tooltip(
      message: selected ? 'Remove $name' : 'Remember $name',
      child: Semantics(
        button: true,
        selected: selected,
        label: profile?.name ?? 'Guest',
        child: CatchSurface(
          onTap: onTap,
          backgroundColor: t.surface,
          radius: CatchRadius.md,
          borderColor: selected ? t.primary : t.line,
          borderWidth: selected ? CatchStroke.selection : CatchStroke.hairline,
          duration: CatchMotion.micro,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _profilePhoto(context, profile: profile),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      CatchTokens.editorialDark.withValues(
                        alpha: CatchOpacity.none,
                      ),
                      CatchTokens.editorialDark.withValues(
                        alpha: CatchOpacity.eventRecapTileScrim,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: CatchSpacing.s2,
                right: CatchSpacing.s2,
                bottom: CatchSpacing.s2,
                child: Text(
                  profile?.name ?? 'Guest',
                  style: CatchTextStyles.labelM(
                    context,
                    color: CatchTokens.editorialLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected)
                Positioned(
                  right: CatchSpacing.s2,
                  top: CatchSpacing.s2,
                  child: CircleAvatar(
                    radius: CatchLayout.selectionBadgeRadius,
                    backgroundColor: t.primary,
                    child: Icon(
                      CatchIcons.checkRounded,
                      size: CatchIcon.xs,
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

Widget _profilePhoto(BuildContext context, {required PublicProfile? profile}) {
  final photoUrl = profile?.primaryPhotoThumbnailUrl;
  if (photoUrl == null) {
    return Container(
      color: CatchTokens.of(context).primarySoft,
      alignment: Alignment.center,
      child: Icon(CatchIcons.personRounded, size: CatchIcon.fallbackAvatar),
    );
  }
  return CatchNetworkImage(photoUrl);
}

Widget _emptyRoster() {
  return CatchEmptyState(
    icon: CatchIcons.groupOffRounded,
    title: 'No attendees to tag',
    message: 'No other checked-in attendees are attached to this event yet.',
  );
}
