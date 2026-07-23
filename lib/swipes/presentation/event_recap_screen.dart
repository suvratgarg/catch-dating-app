import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
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
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen_state.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_view_model.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventRecapScreen extends ConsumerStatefulWidget {
  const EventRecapScreen({
    super.key,
    required this.eventId,
    this.initialSelectedVibeIds = const <String>{},
  });

  final String eventId;
  final Set<String> initialSelectedVibeIds;

  @override
  ConsumerState<EventRecapScreen> createState() => _EventRecapScreenState();
}

class _EventRecapScreenState extends ConsumerState<EventRecapScreen> {
  late final Set<String> _selectedVibes = {...widget.initialSelectedVibeIds};

  @override
  Widget build(BuildContext context) {
    final recapAsync = ref.watch(eventRecapViewModelProvider(widget.eventId));
    final viewModel = recapAsync.asData?.value;
    final rosterProfiles = _watchRosterProfiles(viewModel);
    final screenState = buildEventRecapScreenState(
      l10n: context.l10n,
      eventId: widget.eventId,
      viewModel: _catchAsyncState(recapAsync),
      rosterProfiles: rosterProfiles,
      selectedVibeIds: _selectedVibes,
    );

    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      appBar: CatchTopBar(
        title: context.l10n.swipesEventRecapScreenTitleEventRecap,
        leading: CatchIconAction(
          icon: CatchIcons.closeRounded,
          tooltip: context.l10n.swipesEventRecapScreenTooltipCloseRecap,
          onPressed: () => context.pop(),
        ),
      ),
      body: switch (screenState) {
        EventRecapLoading() => const EventRecapLoadingBody(),
        EventRecapError(:final error, :final retryIntent) =>
          CatchErrorState.fromError(
            error,
            context: AppErrorContext.event,
            onRetry: () => _retry(retryIntent),
          ),
        EventRecapMissingEvent() => CatchErrorState(
          title: context.l10n.swipesEventRecapScreenTitleEventNotFound,
          message: context.l10n.swipesEventRecapScreenMessageThisEventIsNo,
          secondaryAction: const CatchErrorBackAction(),
        ),
        EventRecapReady ready => EventRecapReadyBody(
          state: ready,
          onToggleVibe: _toggleVibe,
          onRetryRosterProfiles: _retryRosterProfiles,
          onOpenCatchesDeck: _openCatchesDeck,
        ),
      },
    );
  }

  CatchAsyncState<Map<String, PublicProfile>> _watchRosterProfiles(
    EventRecapViewModel? viewModel,
  ) {
    final attendeeIds = viewModel?.attendeeIds ?? const <String>[];
    if (attendeeIds.isEmpty) {
      return const CatchAsyncState.data(<String, PublicProfile>{});
    }

    // Resolve every roster profile in one batched fetch instead of a realtime
    // stream per grid tile.
    return _catchAsyncState(
      ref.watch(publicProfilesByIdsProvider(PublicProfilesQuery(attendeeIds))),
    );
  }

  void _retry(EventRecapRetryIntent intent) {
    ref.invalidate(watchEventProvider(intent.eventId));
    ref.invalidate(watchEventParticipationsForEventProvider(intent.eventId));
    ref.invalidate(uidProvider);
    ref.invalidate(eventRecapViewModelProvider(intent.eventId));
  }

  void _toggleVibe(String attendeeId) {
    setState(() {
      _selectedVibes.contains(attendeeId)
          ? _selectedVibes.remove(attendeeId)
          : _selectedVibes.add(attendeeId);
    });
  }

  void _retryRosterProfiles(Iterable<String> attendeeIds) {
    ref.invalidate(
      publicProfilesByIdsProvider(PublicProfilesQuery(attendeeIds)),
    );
  }

  void _openCatchesDeck(EventRecapOpenDeckIntent intent) {
    context.goNamed(
      Routes.swipeEventScreen.name,
      pathParameters: {'eventId': intent.eventId},
      extra: intent.selectedVibeIds,
    );
  }
}

class EventRecapReadyBody extends StatelessWidget {
  const EventRecapReadyBody({
    super.key,
    required this.state,
    required this.onToggleVibe,
    required this.onRetryRosterProfiles,
    required this.onOpenCatchesDeck,
  });

  final EventRecapReady state;
  final ValueChanged<String> onToggleVibe;
  final ValueChanged<Iterable<String>> onRetryRosterProfiles;
  final ValueChanged<EventRecapOpenDeckIntent> onOpenCatchesDeck;

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
                RecapHero(state: state.hero),
                gapH24,
                Text(
                  context.l10n.swipesEventRecapScreenTextWhoBroughtTheVibe,
                  style: CatchTextStyles.titleL(context),
                ),
                gapH4,
                Text(
                  context.l10n.swipesEventRecapScreenTextTapPeopleYouRemember,
                  style: CatchTextStyles.proseM(context, color: t.ink2),
                ),
                gapH14,
                if (!state.hasAttendees)
                  CatchEmptyState(
                    icon: CatchIcons.groupOffRounded,
                    title: context
                        .l10n
                        .swipesEventRecapScreenTitleNoAttendeesToTag,
                    message: context
                        .l10n
                        .swipesEventRecapScreenMessageNoOtherCheckedIn,
                  )
                else
                  switch (state.profileLookupStatus) {
                    EventRecapProfileLookupStatus.loading =>
                      const VibeGridSkeleton(),
                    EventRecapProfileLookupStatus.error =>
                      CatchInlineErrorState.fromError(
                        state.profileLookupError!,
                        context: AppErrorContext.profile,
                        onRetry: () => onRetryRosterProfiles(state.attendeeIds),
                      ),
                    EventRecapProfileLookupStatus.ready => VibeGrid(
                      rows: state.attendeeRows,
                      onToggleVibe: onToggleVibe,
                    ),
                  },
                gapH24,
                CatchButton(
                  key: SwipeKeys.openCatchesDeckButton,
                  label:
                      context.l10n.swipesEventRecapScreenLabelOpenCatchesDeck,
                  onPressed: state.openDeckActionEnabled
                      ? () => onOpenCatchesDeck(state.openDeckIntent)
                      : null,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VibeGrid extends StatelessWidget {
  const VibeGrid({super.key, required this.rows, required this.onToggleVibe});

  final List<EventRecapAttendeeRow> rows;
  final ValueChanged<String> onToggleVibe;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: rows.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsiveGridCount(MediaQuery.of(context).size.width),
        crossAxisSpacing: CatchLayout.eventRecapGridGap,
        mainAxisSpacing: CatchLayout.eventRecapGridGap,
        childAspectRatio: CatchAspectRatio.eventRecapVibeTile,
      ),
      itemBuilder: (context, index) {
        final row = rows[index];
        return VibeTile(
          key: SwipeKeys.vibeTile(row.attendeeId),
          row: row,
          onTap: () => onToggleVibe(row.attendeeId),
        );
      },
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
                const RecapHeroSkeleton(),
                gapH24,
                CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
                gapH8,
                FractionallySizedBox(
                  widthFactor: 0.88,
                  alignment: Alignment.centerLeft,
                  child: CatchSkeleton.text(),
                ),
                gapH14,
                const VibeGridSkeleton(),
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

class RecapHeroSkeleton extends StatelessWidget {
  const RecapHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
          CatchSkeleton.text(width: CatchLayout.skeletonTextTertiaryWidth),
          gapH4,
          CatchSkeleton.text(width: CatchLayout.skeletonTextDescriptionWidth),
          gapH18,
          const Row(
            children: [
              Expanded(child: RecapStatSkeleton()),
              Expanded(child: RecapStatSkeleton()),
              Expanded(child: RecapStatSkeleton()),
            ],
          ),
        ],
      ),
    );
  }
}

class RecapStatSkeleton extends StatelessWidget {
  const RecapStatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class VibeGridSkeleton extends StatelessWidget {
  const VibeGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class RecapHero extends StatelessWidget {
  const RecapHero({super.key, required this.state});

  final EventRecapHeroState state;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.contentRelaxed,
      backgroundColor: t.ink,
      borderWidth: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.kicker,
            style: CatchTextStyles.labelM(
              context,
              color: t.surface.withValues(
                alpha: CatchOpacity.eventRecapHeroKicker,
              ),
            ).copyWith(fontWeight: FontWeight.w800),
          ),
          gapH10,
          Text(
            state.distanceLabel,
            style: CatchTextStyles.headline(context, color: t.surface),
          ),
          gapH4,
          Text(
            state.activityCheckedInLabel,
            style: CatchTextStyles.supporting(
              context,
              color: t.surface.withValues(
                alpha: CatchOpacity.eventRecapHeroMeta,
              ),
            ),
          ),
          gapH18,
          Row(
            children: [
              RecapStat(
                label: context.l10n.swipesEventRecapScreenLabelWhen,
                value: state.whenLabel,
              ),
              RecapStat(
                label: context.l10n.swipesEventRecapScreenLabelTime,
                value: state.timeLabel,
              ),
              RecapStat(
                label: context.l10n.swipesEventRecapScreenLabelCatches,
                value: state.windowLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecapStat extends StatelessWidget {
  const RecapStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
}

class VibeTile extends StatelessWidget {
  const VibeTile({super.key, required this.row, required this.onTap});

  final EventRecapAttendeeRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Tooltip(
      message: row.tooltip,
      child: Semantics(
        button: true,
        selected: row.selected,
        label: row.semanticLabel,
        child: CatchSurface(
          onTap: onTap,
          backgroundColor: t.surface,
          radius: CatchRadius.md,
          borderColor: row.selected ? t.primary : t.line,
          borderWidth: row.selected
              ? CatchStroke.selection
              : CatchStroke.hairline,
          duration: CatchMotion.micro,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RecapProfilePhoto(profile: row.profile),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      CatchTokens.editorialBlack.withValues(
                        alpha: CatchOpacity.none,
                      ),
                      CatchTokens.editorialBlack.withValues(
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
                  row.displayName,
                  style: CatchTextStyles.labelM(
                    context,
                    color: CatchTokens.editorialWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (row.selected)
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
    );
  }
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return catchAsyncStateFromAsyncValue(value);
}

class RecapProfilePhoto extends StatelessWidget {
  const RecapProfilePhoto({super.key, required this.profile});

  final PublicProfile? profile;

  @override
  Widget build(BuildContext context) {
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
}
